--朋友开房的玩家头像

FriendRoomPlayerHead = class("FriendRoomPlayerHead");

function FriendRoomPlayerHead:ctor(delegate, widget, data)
    self.m_delegate = delegate;
    self.m_pWidget = widget;
    self.m_data = data;
    self:initView();
    return self;
end

function FriendRoomPlayerHead:initView()
    self.headImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "headImg");
    self.playerName = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerName");
    self.leaveImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "leaveImg");
    self.speakingImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "speaking");

    self.headImg:setVisible(false);
    self.playerName:setVisible(false);
    self.leaveImg:setVisible(false);

    --先设置框的层级然后把默认头像放到层级之下头像之上
    local head_frame = ccui.Helper:seekWidgetByName(self.headImg,"headframe")
    head_frame:setLocalZOrder(2)
    local speaking = ccui.Helper:seekWidgetByName(self.headImg,"speaking")
    speaking:setLocalZOrder(2)
    
end

function FriendRoomPlayerHead:getHeadImg()
    return  self.headImg;  
end

function FriendRoomPlayerHead:getPlayerName()
    return  self.playerName;  
end

function FriendRoomPlayerHead:getLeaveImg()
    return  self.leaveImg;  
end

--显示正在说话
function FriendRoomPlayerHead:showSpeaking()
    self.speakingImg:stopAllActions();
    self.speakingImg:setVisible(true);
    self.speaking_img_index = 1;
    self.speakingImg:loadTexture("hall/friendRoom/speaking_" .. self.speaking_img_index .. ".png");
    self.speakingImg:performWithDelay(function ()
            self:updateSpeakingImg();
        end, 0.1);

    --防止没有收到播放结束回调
    self.m_pWidget:stopAllActions();
    self.m_pWidget:performWithDelay(function ()
            self:hideSpeaking();
    end, 60);
end

function FriendRoomPlayerHead:updateSpeakingImg()
    self.speaking_img_index = self.speaking_img_index + 1;
    if self.speaking_img_index >= 4 then
        self.speaking_img_index = 1;
    end
    self.speakingImg:loadTexture("hall/friendRoom/speaking_" .. self.speaking_img_index .. ".png");
    self.speakingImg:performWithDelay(function ()
            self:updateSpeakingImg();
        end, 0.2);
end

--隐藏正在说话
function FriendRoomPlayerHead:hideSpeaking()
    self.speakingImg:setVisible(false);
    self.speakingImg:stopAllActions();
    self.m_pWidget:stopAllActions();
end

function FriendRoomPlayerHead:dtor()   
end