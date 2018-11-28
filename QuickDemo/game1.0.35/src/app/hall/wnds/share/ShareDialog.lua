-------------------------------------------------------------
--  @file   ShareDialog.lua
--  @brief  分享对话框
--  @author Zhu Can Qin
--  @DateTime:2016-09-25 15:45:33
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local ShareToWX = require "app.hall.common.ShareToWX"

ShareDialog = class("ShareDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn         = "close_btn",
    tagTableView        = "listView",
    tagWeixinBtn        = "weixin_btn",
    tagFriendGroupBtn   = "friend_group_btn",
}
-- 麻将下载地址
local kDownloadUrl = {
    -- 徐州
    [10007] = "http://wxpt.stevengame.com/wxdsqp/front/downdetail",
    -- 常州
    [10008] = "http://wxpt.stevengame/wxdsqp/front/downdetail", 
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ShareDialog:ctor(...)
    self.super.ctor(self, "hall/shareDialog.csb")
    self.m_data = ... or {}
    self.m_giftBaseInfo = self.m_data.baseGiftData;
    self.m_logicData    = self.m_data.logicData
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function ShareDialog:onShow()
    print("onShow")

end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function ShareDialog:onClose()
    print("onClose")
    
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function ShareDialog:onInit()
    self.buttonClose = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.buttonClose:addTouchEventListener(handler(self, self.onClickButton))

    self.weiXinFriend = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagWeixinBtn)
    self.weiXinFriend:addTouchEventListener(handler(self, self.onClickButton))

    self.friendCircle = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagFriendGroupBtn)
    self.friendCircle:addTouchEventListener(handler(self, self.onClickButton))
    
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function ShareDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
    SoundManager.playEffect("btn", "hall");
        if pWidget == self.buttonClose then
            self:keyBack()
        elseif pWidget == self.weiXinFriend then
            Util.disableNodeTouchWithinTime(pWidget)

   --          local data = {};
   --          --分享标题 shT2="";
   --          --分享描述shD="";
   --          --分享链接shL="";
   --          data.cmd = NativeCall.CMD_WECHAT_SHARE;
   --          -- if(self.m_giftBaseInfo.shT==1) then 
   --          data.url = kFriendRoomInfo:getRoomBaseInfo().downloadLink;
   --          data.title = kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
   --          data.desc = kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
			-- data.headUrl = kUserInfo:getHeadImgSmall();
   --          data.type = 2;
   --          --LoadingView.getInstance():show("正在分享,请稍后...", 2);
   --          NativeCall.getInstance():callNative(data, self.shareResult, self);

            LoadingView.getInstance():show("正在分享,请稍后...", 1);
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_NO_REWARD_FRIEND, handler(self, self.shareResult), ShareToWX.ShareFriendQun)
        elseif pWidget == self.friendCircle then
            Util.disableNodeTouchWithinTime(pWidget)

            -- local data = {};
            -- --分享标题 shT2="";
            -- --分享描述shD="";
            -- --分享链接shL="";
            -- data.cmd = NativeCall.CMD_WECHAT_SHARE;
            -- -- if(self.m_giftBaseInfo.shT==1) then 
            -- data.url = kFriendRoomInfo:getRoomBaseInfo().downloadLink;
            -- data.title = kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
            -- data.desc = kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
            -- data.type = 1;
            -- --LoadingView.getInstance():show("正在分享,请稍后...", 2);
            -- NativeCall.getInstance():callNative(data, self.shareResult, self);

            LoadingView.getInstance():show("正在分享,请稍后...", 2);
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_NO_REWARD, handler(self, self.shareResult), ShareToWX.ShareFriendQuan)
        end
    end
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ShareDialog:shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
    if(info.errCode ==0) then --成功
         
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end

function ShareDialog:keyBack()
    UIManager:getInstance():popWnd(ShareDialog)
end

