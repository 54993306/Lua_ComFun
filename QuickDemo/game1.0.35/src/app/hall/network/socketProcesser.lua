SocketProcesser = class("SocketProcesser");

function SocketProcesser:ctor(delegate)
	self.m_delegate = delegate;
end

--连接成功
function SocketProcesser:onNetWorkConnected()
    if self.m_delegate and self.m_delegate.onNetWorkConnected then
        self.m_delegate:onNetWorkConnected();
    end
end 

--重连成功
function SocketProcesser:onNetWorkReconnected()
    if self.m_delegate and self.m_delegate.onNetWorkReconnected then
        self.m_delegate:onNetWorkReconnected();
    end
end 

--正在重连
function SocketProcesser:onNetWorkReconnect()
    if self.m_delegate and self.m_delegate.onNetWorkReconnect then
        self.m_delegate:onNetWorkReconnect();
    end
end 

function SocketProcesser:onNetWorkClosed()
    if self.m_delegate and self.m_delegate.onNetWorkClosed then
        self.m_delegate:onNetWorkClosed();
    end
end 

function SocketProcesser:onNetWorkClose()
    if self.m_delegate and self.m_delegate.onNetWorkClose then
        self.m_delegate:onNetWorkClose();
    end
end 

function SocketProcesser:onNetWorkConnectFail()
    if self.m_delegate and self.m_delegate.onNetWorkConnectFail then
        self.m_delegate:onNetWorkConnectFail();
    end
end

function SocketProcesser:onNetWorkConnectException()
    if self.m_delegate and self.m_delegate.onNetWorkConnectException then
        self.m_delegate:onNetWorkConnectException();
    end
end  

--连接弱
function SocketProcesser:onNetWorkConnectWeak()
    if self.m_delegate and self.m_delegate.onNetWorkConnectWeak then
        self.m_delegate:onNetWorkConnectWeak();
    end
end 

--local ts = 0
function SocketProcesser:onReceivePacket(cmd, packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then
--        scheduler.performWithDelayGlobal(function() Toast.getInstance():show("SocketProcesser:"..self.m_delegate.__cname..tostring(cmd)) end, ts)
--        ts = ts + 1
        
        local done = self.s_severCmdEventFuncMap[cmd](self, cmd, packetInfo);
        return done or true;
    end
    return false;
end

function SocketProcesser:onSyncData(cmd, code, packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then    
        local done = self.s_severCmdEventFuncMap[cmd](self, code, packetInfo);
        return done or true;
    end
    return false;
end

SocketProcesser.s_severCmdEventFuncMap = {
	
};