--创建与进入房间UI

FriendRoomCode = class("FriendRoomCode", UIWndBase);

function FriendRoomCode:ctor(...)
    self.super.ctor(self, "hall/friendRoomCode.csb", ...);
    self.m_data=...;
    self.m_strNum=""
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function FriendRoomCode:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	
end

function FriendRoomCode:onInit()
   
  self:addShowder()
   
  self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn");
  self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));
  self.numLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "numLabel");
   
  self.last_roomNumber = self:getSaveNumber();
  if self.last_roomNumber and string.len(self.last_roomNumber) >= 6 then
    self.roomLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "roomLabel");
    self.roomLabel:setString(self.last_roomNumber);
    self.roomLabel:addTouchEventListener(handler(self, self.onClickButton));
  else
	 ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_record"):setVisible(false); 
  end
   

   self.numberScrollView = ccui.Helper:seekWidgetByName(self.m_pWidget, "numberScrollView");
   
   self.clearButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "clearButton");
   self.clearButton:addTouchEventListener(handler(self, self.onClickButton));
   
   self.backButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "backButton");
   self.backButton:addTouchEventListener(handler(self, self.onClickButton));
   --
   for i = 0, 9 do
    local btn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_code" .. i);
    btn:addTouchEventListener(handler(self, self.onIconClick));
    btn:setTag(i);
   end
end

function FriendRoomCode:onIconClick(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
	    local tag = pWidget:getTag()
		  self.m_strNum = self.m_strNum .. tag;
		
		  self.numLabel:setString(self.m_strNum)
		
		  if(string.len(self.m_strNum) == 6) then
		   	local tmpData={}
  			tmpData.pa = tonumber(self.m_strNum)
  			FriendRoomSocketProcesser.sendRoomEnter(tmpData)
  			LoadingView.getInstance():show("正在查找房间,请稍后......");
		  end
    end 
end

--增加阴影
function FriendRoomCode:addShowder()
  self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

function FriendRoomCode:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
      if pWidget == self.closeBtn then
		      UIManager:getInstance():popWnd(FriendRoomCode);
      elseif pWidget == self.clearButton then
		   	self.m_strNum = ""
		    self.numLabel:setString(self.m_strNum)
		
		  elseif pWidget == self.backButton then
		
		    local tmpLen = string.len(self.m_strNum)
  			if(tmpLen>0) then
  			   self.m_strNum = string.sub(self.m_strNum,0,tmpLen-1)
  			end
		    self.numLabel:setString(self.m_strNum)
      elseif pWidget == self.roomLabel then
        local tmpData={}
        tmpData.pa = tonumber(self.last_roomNumber)
        FriendRoomSocketProcesser.sendRoomEnter(tmpData)
        LoadingView.getInstance():show("正在查找房间,请稍后......");
      end
    end
end

function FriendRoomCode:recvGetRoomEnter(packetInfo)
    --## re  int  结果（-2 = 无可用房间，1 成功找到）
	--Log.i("进入结果：" .. tmpData.re)
    local tmpData = packetInfo
    if(-1 == tmpData.re) then
      LoadingView.getInstance():hide();
      Toast.getInstance():show("人数已满");
    elseif(-2 == tmpData.re) then
      LoadingView.getInstance():hide();
      UIManager:getInstance():popWnd(FriendRoomCode);
      local data = {}
    	data.type = 1;
    	data.title = "提示";
    	data.closeTitle = "房间";
    	data.content = "房间不存在";
      UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif tmpData.re == 1 then
      kFriendRoomInfo:saveNumber(self.m_strNum);
   end
end

function  FriendRoomCode:getSaveNumber()
  local roomNumberKey = cc.UserDefault:getInstance():getStringForKey("roomNumberKey");
  if(roomNumberKey ~= nil and roomNumberKey ~= "") then
	    return roomNumberKey
	end
  return nil;
end

function FriendRoomCode:recvRoomSceneInfo(packetInfo)
    Log.i("FriendRoomCode:recvRoomSceneInfo....")
    LoadingView.getInstance():hide();
    UIManager:getInstance():popWnd(FriendRoomCode);
    local data = {};
    data.isFirstEnter = true;
    UIManager.getInstance():pushWnd(FriendRoomScene, data);
end


FriendRoomCode.s_socketCmdFuncMap = {
  [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = FriendRoomCode.recvGetRoomEnter; --InviteRoomEnter	 进入邀请房结果
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomCode.recvRoomSceneInfo; --InviteRoomEnter	邀请房信息
};