
DismissDeskView = class("DismissDeskView",UIWndBase)

function DismissDeskView:ctor(...)
    self.super.ctor(self,"games/common/mj/dismiss_desk.csb", ...);
	self.m_playerNameList={};
end

function DismissDeskView:onInit()

    -- 同意
    self.btn_agree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_agree");
    self.btn_agree:addTouchEventListener(handler(self, self.onClickButton));
 
    -- 不同意
    self.btn_disagree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_disagree");
    self.btn_disagree:addTouchEventListener(handler(self, self.onClickButton));

	self.lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_title");
	 
    -- 倒计时
    self.lab_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_time");
   
    -- 玩家信息
    self:addPlayers()
end

-- 窗口被关闭响应
function DismissDeskView:onClose()
    Log.i("DismissDeskView:onClose()")
	if self.refreshTimeSchedule then 
		scheduler.unscheduleGlobal(self.refreshTimeSchedule)
		self.refreshTimeSchedule=nil
	end
end

		
function DismissDeskView:updateTime(packetInfo)
   if(self.m_time~=nil) then --已经接收过最新时间，不用再接收更新
      return 
   end
  
   Log.i("接收时间" .. packetInfo.CoD)
  
   self.m_time = packetInfo.CoD  --int  倒计时
   self.m_startTime= os.time(); --用于后台导致暂停不更新

    local refreshTimeFun = function ()
	    local sud = os.time() - self.m_startTime;
		--Log.i("系统时间" .. os.time() .. "time:" .. self.m_time)
        if sud > self.m_time or sud< 0 then
		    self.lab_time:setString("0")
		    --玩家选择时间为30秒，如果30内玩家未选择，时间结束后，系统默认选择同意
			self.btn_agree:setVisible(false)
            self.btn_disagree:setVisible(false)
            if self.refreshTimeSchedule then 
                scheduler.unscheduleGlobal(self.refreshTimeSchedule)
				self.refreshTimeSchedule=nil
				return;
            end
        end	
		local tmpSub =  math.floor(self.m_time-sud);
		if(tmpSub<0)then
		   tmpSub=0
		end
        self.lab_time:setString(tmpSub)
    end
    self.refreshTimeSchedule = scheduler.scheduleGlobal(refreshTimeFun,0.2)   

end

function DismissDeskView:addPlayers()
    self.imgHeads = {}
    self.labTips = {}

    for i=1, #MjProxy:getInstance()._players do
        local pan_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i);
        local img_head = ccui.Helper:seekWidgetByName(pan_head, "img_head");
        local lab_nick = ccui.Helper:seekWidgetByName(pan_head, "lab_nick");
        local lab_tip = ccui.Helper:seekWidgetByName(pan_head, "lab_tip");
		local playerID = MjProxy:getInstance()._players[i]:getUserId();
		local toStr = "" .. playerID;
        Log.i("player id :", toStr);
		
		--玩家昵称
		local strNickName=MjProxy:getInstance()._players[i]:getNickName()
		local retName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
        lab_nick:setString(retName)
		 
		lab_tip:setVisible(false);
		lab_tip:setString("")
        self.labTips[toStr] = lab_tip
		local imgURL = MjProxy:getInstance()._players[i]:getIconId() or ""
       
        
        Log.i("imgURL...", imgURL, "string.len(imgURL)...", string.len(imgURL), "site...", i)
        local imgName = playerID .. ".jpg";
    
        if string.len(imgURL) > 3 then
            Log.i("imagename ....", imgName, "site....", i)
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(headFile) then
                img_head:loadTexture(imgName);
            else
                self.imgHeads[imgName] = img_head;
                self:getNetworkImage(imgURL, imgName);
            end
        else              
            local headFile = "hall/Common/default_head_2.png";
            headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
            if io.exists(headFile) then
                img_head:loadTexture(headFile);
            end
        end   
        -- img_head:setScale(100/img_head:getContentSize().width , 100/img_head:getContentSize().height)
    end
end

function DismissDeskView:getNetworkImage(preUrl, fileName)
    Log.i("DismissDeskView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("DismissDeskView.getNetworkImage", "-------fileName = ".. fileName);
    if preUrl == "" then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(fileName);
    end
    local url = preUrl;
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function DismissDeskView:onResponseNetImg(imgName)
    for k, v in pairs(self.imgHeads) do
        if imgName == k then
            imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(imgName) then
                v:loadTexture(imgName);
                -- v:setScale(100/self.imgHeads[i]:getContentSize().width ,100/self.imgHeads[i]:getContentSize().height)
                break
            end
        end
    end

end

function DismissDeskView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_agree then 
            local tmpData={}
			tmpData.usI =  kUserInfo:getUserId()
			tmpData.re= 1
			tmpData.niN =kUserInfo:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            
        elseif pWidget == self.btn_disagree then
            local tmpData={}
			tmpData.usI =  kUserInfo:getUserId()
			tmpData.re= 2
			tmpData.niN =kUserInfo:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
        end
    end
end

--[[
type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
##  usI  long  玩家id
##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
##  CoD  --int  倒计时
##  asI  long  发起的用户Id
##  niN  String  发起的用户昵称
##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)
]]
function DismissDeskView:updateUI(packetInfo)
     
    Log.i("收到玩家解散桌子信息",packetInfo)
	self:updateTime(packetInfo)
	-- 谁发起的解散
    local nick = packetInfo.niN
    self.lab_title:setString("玩家"..nick.."发起解散牌桌")

	--玩家点击“同意”或“不同意”按钮以后，该玩家的“同意”和“不同意”按钮消失
	if(packetInfo.usI == kUserInfo:getUserId() and packetInfo.re~=-1 and  packetInfo.re~=0) then
		self.btn_agree:setVisible(false)
        self.btn_disagree:setVisible(false)
	end
	
	local toStr = "" .. packetInfo.usI
    local lab_tip = self.labTips[toStr];
	lab_tip:setVisible(true)
	
	local playerInfo = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.usI)
	
	if(packetInfo.re == 1 )  then --1:同意
	     lab_tip:setString("同意")
		 
		 --四名玩家全部选择同意后，直接关闭该界面，并弹出另一提示框，提示内容：经玩家【玩家1】，【玩家2】，【玩家3】同意，房间解散成功。设有“确定”按钮，点击“确定”关闭弹出框；

		 table.insert(self.m_playerNameList,playerInfo.niN)
		 
		 if(#self.m_playerNameList>=4) then
		    
		    local strText="全部玩家同意解散房间,房间已解散"
			--[[
			for i=1,#self.m_playerNameList do
			   --经玩家【玩家1】，【玩家2】，【玩家3】同意，房间解散成功
			    if(i==#self.m_playerNameList) then
				   strText = strText .. string.format("【%s】同意,房间解散成功",self.m_playerNameList[i])
				else
			       strText  = strText .. string.format("【%s】,",self.m_playerNameList[i])
				end
			end]]
		 
		    local data = {}
			data.type = 1;
			data.title = "提示";
			data.closeTitle = "退出房间";
			data.content = strText;
			data.closeCallback = function ()
			    local tmpScene = MjMediator:getInstance():getScene();
			    tmpScene.m_friendOpenRoom.m_isShowGameOverUI=true;
			    tmpScene.m_friendOpenRoom:gameOverUICallBack();
				return
			end
			
			local tmpScene = MjMediator:getInstance():getScene();
	        tmpScene.m_friendOpenRoom.m_isCreate=nil;
			UIManager.getInstance():popWnd(DismissDeskView);
		    UIManager.getInstance():pushWnd(CommonDialog, data);
		    --Toast.getInstance():show(strText);
		 end
	
	elseif(packetInfo.re == 2 )  then --2:不同意
	    --如果有1名选择选择不同意，则其他玩家无需在继续选择，4名玩家全部自动关闭该界面，并弹出另一提示框，提示内容：玩家xx不同意解散房间。设有“确定”按钮，点击“确定”关闭弹出框；
        lab_tip:setString("不同意")
	   
	   
	    local data = {}
		data.type = 1;
		data.title = "提示";
		data.closeTitle = "提示";
		data.content = string.format("玩家%s不同意解散房间",playerInfo.niN);
		data.closeCallback = function ()
			return
		end
		
		local tmpScene = MjMediator:getInstance():getScene();
	    tmpScene.m_friendOpenRoom.m_isCreate=nil;
	
		UIManager.getInstance():popWnd(DismissDeskView);
		
		--如果是自己发起的不同意则不用显示提示UI
		if(packetInfo.usI~=kUserInfo:getUserId()) then
		  UIManager.getInstance():pushWnd(CommonDialog, data);
		end
		
	end
     

end