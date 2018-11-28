require("app.hall.network.PacketBuffer");
require("app.hall.network.socketProcesser");
require("app.hall.network.commonSocketProcesser");
require("app.hall.network.socketCmd");
cc.net 	= require("app.framework.cc.net.init")

SocketManager = class("SocketManager")

SocketManager.getInstance = function()
	if not SocketManager.s_instance then 
		SocketManager.s_instance = SocketManager.new();
	end
	return SocketManager.s_instance;
end

SocketManager.releaseInstance = function()
	if SocketManager.s_instance then
		SocketManager.s_instance:dtor();
	end
	SocketManager.s_instance = nil;
end

function SocketManager:ctor()
	self.buf = PacketBuffer.new();
    self.msgs = {};
	--
	self.m_socketProcessers = {};
    self.m_status = NETWORK_EXCEPTION;
    --心跳间隔
    self.m_heartBeat_time = 10;
    --网络弱时间
    self.m_network_weak_time = 1.8;
    --网络异常时间
    self.m_network_exception_time = 10;
    --重连最大次数
    self.m_maxReconnect_time = 2;
    --连接尝试次数
    if IS_IOS then
        self.m_maxTry_time = 3;
    else
        self.m_maxTry_time = 1;
    end
    self.m_try_time = 0;

    self.pause = false
end

function SocketManager:dtor()
	if self._socket then
		self._socket:close();
		self._socket = nil;
	end
end

function SocketManager:getSocketTime()
    if self._socket then
        return self._socket:getTime();
    else
        return os.time();
    end
end

--获取网络连接状态
function SocketManager:getNetWorkStatus()
    return self.m_status;
end

function SocketManager:addSocketProcesser(socketProcesser)
	if not self:checkExist(self.m_socketProcessers, socketProcesser) then
		table.insert(self.m_socketProcessers, 1, socketProcesser);
	end
end

function SocketManager:setUserDataProcesser(socketProcesser)
    self.m_userDataProcessers = socketProcesser;
end

function SocketManager:removeSocketProcesser(socketProcesser)
	local index = self:getIndex(self.m_socketProcessers, socketProcesser);
	if index ~= -1 then
		table.remove(self.m_socketProcessers, index);
	end
end

function SocketManager:onConnected(event)
    Log.i("------SocketManager:onConnected ", "连通");
    self.m_status = NETWORK_NORMAL;
    self.m_try_time = 0; 
    if #self.m_socketProcessers > 0 then
        if self.m_isReconnent then
            if self.m_socketProcessers[1] then
                kLoginInfo:requestLogin();
                self.m_socketProcessers[1]:onNetWorkReconnected(event);
            end
            self.m_isReconnent = false;
            self.m_reconnectTime = 0;
        else
            if self.m_socketProcessers[1] then
                self.m_socketProcessers[1]:onNetWorkConnected(event);
            end
        end
    end

    self:startHeartBeat();
    if not self.m_msg_hander then
        self.m_msg_hander = scheduler.scheduleUpdateGlobal(function()
             self:onReceivePacket();
            end);
    end
end

function SocketManager:startHeartBeat()
    self:stopHeartBeat();
    self.heatBeatThread = scheduler.scheduleGlobal(function() 
        Log.i("心跳时间")
        --发送心跳消息
        self:send(CODE_TYPE_SYS, CODE_HEARTBEAT);
        --
        self.checkNetWorkThread = scheduler.performWithDelayGlobal(function ()
            self:onConnectException();
        end, self.m_network_exception_time);

        self.checkNetWorkWeakThread = scheduler.performWithDelayGlobal(function ()
            self:onConnectWeak();
        end, self.m_network_weak_time);

    end, self.m_heartBeat_time);
end

function SocketManager:stopHeartBeat()
    if self.heatBeatThread then
        scheduler.unscheduleGlobal(self.heatBeatThread);
        self.heatBeatThread = nil;
    end
    self:stopCheckNetWorkThread();
end

function SocketManager:stopCheckNetWorkThread()
	if self.checkNetWorkThread then
		scheduler.unscheduleGlobal(self.checkNetWorkThread);
        self.checkNetWorkThread = nil;
	end

    if self.checkNetWorkWeakThread then
        scheduler.unscheduleGlobal(self.checkNetWorkWeakThread);
        self.checkNetWorkWeakThread = nil;
    end
end

function SocketManager:onClosed(event)
    Log.i("SocketManager:onClosed self.m_manual_close", self.m_manual_close);

    if self.m_manual_close then --如果是强制退出则不理会断网
        return;
    end
    if #self.m_socketProcessers > 0 then
        self.m_status = NETWORK_EXCEPTION;
        self.m_socketProcessers[1]:onNetWorkClosed(event);
    end
    self:stopHeartBeat();
end

function SocketManager:onClose(event)
    Log.i("SocketManager:onClose", "---------socekt onClose");
    if self.m_manual_close then --如果是强制退出则不理会断网
        return;
    end
    self:stopHeartBeat();
end

function SocketManager:onConnectFail(event)
    Log.i("链接失败....")
    Log.i("SocketManager:onConnectFail self.m_isReconnent", self.m_isReconnent);
    Log.i("SocketManager:onConnectFail self.m_reconnectTime", self.m_reconnectTime);
    
    if self.m_isReconnent then
        if self.m_reconnectTime < self.m_maxReconnect_time then
            self:reconnetSocket();
        else
            self.m_manual_close = false;
            self:onClosed();
            self.m_isReconnent = false;
            self.m_reconnectTime = 0;
        end
        return;
    else
        self:stopHeartBeat();
        if self.m_try_time >= self.m_maxTry_time then
            if self.openNumber == nil then
                self.openNumber = 0
            end
            self.openNumber = self.openNumber + 1 
            local index = 1
            if self.openNumber > 3 and self.openNumber < 6 then
                index = 2
            end
            if self.openNumber < 7 then
                self:closeSocket()
                self:openSocket(index)
            else
                self:closeSocket();
                if #self.m_socketProcessers > 0 then
                    self.m_status = NETWORK_EXCEPTION;
                    self.m_socketProcessers[1]:onNetWorkConnectFail(event);
                end
            end
        else
            Log.i("重新链接.....")
            self:closeSocket();
            self:openSocket();
        end    
    end
    
end

function SocketManager:onConnectException(event)
    Log.i("SocketManager:onConnectException", "socekt 连接异常");
    self:closeSocket();
    if #self.m_socketProcessers > 0 then
        self.m_status = NETWORK_EXCEPTION;
        self.m_socketProcessers[1]:onNetWorkConnectException(event);
    end
    self:stopHeartBeat();
    self:reconnetSocket();
end

function SocketManager:onConnectWeak(event)
    Log.i("SocketManager:onConnectWeak", "socekt 连接弱");
    if #self.m_socketProcessers > 0 then
        self.m_socketProcessers[1]:onNetWorkConnectWeak(event);
    end
end

function SocketManager:onReceive(event)
	self:stopCheckNetWorkThread();
	--
	local msgs = self.buf:parseMessage(event.data); 
    for i = 1, #msgs do
        --开局或恢复对局消息需要等场景切换完成
        if (msgs[i].subcode > 30006  and msgs[i].subcode <= 40000 )
            and not kGameManager:isEntryComplete() then
--            if self.m_msg_hander then
--                scheduler.unscheduleGlobal(self.m_msg_hander);
--                self.m_msg_hander = nil;
--                for i = 1, #self.msgs do
--                    self:onReceivePacket();
--                end
                if self.resumeMsg == nil then
                    self.resumeMsg  = {}
                end
                self.resumeMsg[#self.resumeMsg + 1] = msgs[i];
--            end
        else
            table.insert(self.msgs, msgs[i]);
        end
        
    end
end

function SocketManager:reStartReceivePacket()
    if self.resumeMsg then
        for i,v in pairs(self.resumeMsg) do
            table.insert(self.msgs,v)
        end
        self:onReceivePacket();
        self.resumeMsg = nil;
    end
    if not self.m_msg_hander then
        self.m_msg_hander = scheduler.scheduleUpdateGlobal(function()
             self:onReceivePacket();
            end);
    end
end
local ts = 0
function SocketManager:onReceivePacket(msg)
    if self.pause then return end
   
    if not msg then
        if #self.msgs == 0 then
            return;
        end
         if kUserInfo:getUserId()== 0 then
--            Toast,.getInstance():show("UserId:"..kUserInfo:getUserId()..".."..self.msgs[1].subcode)
            for i,v in pairs(self.msgs) do
                if v.subcode == HallSocketCmd.CODE_REC_LOGIN then
                    msg = table.remove(self.msgs, i);
                    break
                end
            end
            if msg == nil then
                return
            end
        else
            msg = table.remove(self.msgs, 1);
        end
        
    end
    local info = {}
    if msg.subcode ~= CODE_HEARTBEAT then
        info = json.decode(msg.content);
    else
        return
    end
--    local info = json.decode(msg.content);
    local packetInfo = nil;
    if msg.code == CODE_TYPE_INSERT or msg.code == CODE_TYPE_UPDATE or msg.code == CODE_TYPE_DELETE then
        self.m_userDataProcessers:onSyncData(msg.subcode, msg.code, info);
        local tempInfo = {};
        tempInfo.code = msg.code;
        tempInfo.content = info;
        packetInfo = tempInfo
    else
        packetInfo = info;
    end
    for k, v in ipairs(self.m_socketProcessers) do
        
        if v:onReceivePacket(msg.subcode, packetInfo) then
            break;
        end
    end
end

--[[
-- @brief  回放模拟数据返回函数
-- @param  void
-- @return void
--]]
function SocketManager:onRecordReceivePacket(recordMsgs)
    if #recordMsgs == 0 then
        return;
    end
    local msg = table.remove(recordMsgs, 1);
    local info = json.decode(msg.content);
    local packetInfo = nil;
    if msg.code == CODE_TYPE_INSERT or msg.code == CODE_TYPE_UPDATE or msg.code == CODE_TYPE_DELETE then
        self.m_userDataProcessers:onSyncData(msg.subcode, msg.code, info);
        local tempInfo = {};
        tempInfo.code = msg.code;
        tempInfo.content = info;
        packetInfo = tempInfo
    else
        packetInfo = info;
    end
    for k, v in ipairs(self.m_socketProcessers) do
        if v:onReceivePacket(msg.subcode, packetInfo) then
            break;
        end
    end
end

function SocketManager:send(code, subcode, msgContent)
	if not self._socket then
		return;
	end 
    local data = (msgContent ~= nil) and json.encode(msgContent) or nil;
    if code > 0 then
        Log.i("------send msg code", code .. " subcode:" .. subcode);
        Log.i("------send msg data", data);
        Log.s("------send msg code: " .. tostring(code) .. "\n------send msg subcode: " .. tostring(subcode) .. "\n------send msg data: " .. tostring(data))
    end
	local buf = PacketBuffer.createMessage(code, subcode, data);
	self._socket:send(buf:getPack());

end

--打开连接
function SocketManager:openSocket(index)
    
    if index == nil then
        index = 1
    end
    self.m_manual_close = false;
    self.m_try_time = self.m_try_time + 1;
	if not self._socket then
        local host = SERVER_IPS[index];
        local port = SERVIER_PORT;
        Log.i("------SocketManager:openSocket host", host);
        Log.i("------SocketManager:openSocket port", port);
		self._socket = cc.net.SocketTCP.new(host, port, false);
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected));
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed));
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose));
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFail));
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onReceive));
		self._socket:connect();
	else
		self._socket:connect();
    end
end

--关闭连接
function SocketManager:closeSocket()
    self.m_try_time = 0;
    self:stopHeartBeat();
    self.m_manual_close = true;
    if self._socket then
        self._socket:close();
        self._socket = nil;
    end
end

function SocketManager:reconnetSocket()
    local host = SERVER_IP;
    local port = SERVIER_PORT;
    Log.i("SocketManager:reconnetSocket", "------host =" .. host);
    Log.i("SocketManager:reconnetSocket", "------port =" .. port);
    if self._socket then
        self:closeSocket();
    end
    self.m_isReconnent = true;
    self.m_reconnectTime = (self.m_reconnectTime or 0) + 1;
    self:openSocket();
end

function SocketManager:getIndex(vtable, value)
	for k, v in pairs(vtable or {}) do 
		if v == value then
			return k;
		end
	end

	return -1;
end

function SocketManager:checkExist(vtable, value)
	return self:getIndex(vtable, value) ~= -1;
end