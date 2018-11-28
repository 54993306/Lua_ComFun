
--创建与进入房间UI
FriendRoomEnterInfo = class("FriendRoomEnterInfo", UIWndBase);

function FriendRoomEnterInfo:ctor(...)
    self.super.ctor(self, "games/huaibeimj/game/FriendRoomEnterInfo.csb", ...);
    self.m_data=...;
end

function FriendRoomEnterInfo:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	
end

function FriendRoomEnterInfo:onInit()

   self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_sure");
   self.btn_sure:addTouchEventListener(handler(self, self.onClickButton));
  
   self:addShowder()

   self:updateUI()
   
end

--增加阴影
function FriendRoomEnterInfo:addShowder()
  
end

function FriendRoomEnterInfo:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
      if pWidget == self.btn_sure then
			UIManager:getInstance():popWnd(FriendRoomEnterInfo);
      end
    end
end

--
function FriendRoomEnterInfo:updateUI()
    
	local tmpData = kFriendRoomInfo:getSelectRoomInfo();
    Log.i("房主所设置游戏信息：", tmpData);
	
	--d的牌局
    local  nameLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
	local retName = ToolKit.subUtfStrByCn(tmpData.niN,0,5,"")
    nameLabel:setString(string.format("%s的牌局",retName))
   
    --局数
	local sushouLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "sushouLabel");
    sushouLabel:setString(string.format("%s局",tmpData.roS))
	
--	--玩法
    local playingListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "playingListView");
    playingListView:removeAllChildren()
   	local itemList= Util.analyzeString_2(tmpData.wa);
    Log.i("itemList.......",itemList)
    if (#itemList > 0 ) then
        for i, v in pairs(itemList) do
            local content = kFriendRoomInfo:getPlayingInfoByTitle(v)
            local text = ccui.Text:create()
            text:setString(content.ch)
            text:setFontSize(50)
            text:setColor(cc.c3b(0,0,0))
            text:setAnchorPoint(cc.p(0.5,0.5))
            playingListView:pushBackCustomItem(text)
            
        end
    end
end