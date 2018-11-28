-------------------------------------------------------------
--  @file   GameOverOtherPanel.lua
--  @brief  结算时其他玩家的版块
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-07-29 15:26:37
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local WWFacade = require "app.games.huaibeimj.custom.WWFacade"
local kCSBFile = "games/common/mj/over_item.csb"
local kWidgets = {
	namePanel 		= "root",
	nameLabNick 	= "Lab_nick",
	nameLabBean 	= "Lab_bean",
	nameImgPoChan 	= "Img_pochan",
	nameImgZhuang 	= "img_zhuang",
	nameImghead 	= "Img_head",
	nameBtnDetail   = "btn_detail",
}
local GameOverOtherPanel = class(GameOverOtherPanel, function()
    local ret = ccui.Widget:create()
    ret:ignoreContentAdaptWithSize(false)
    ret:setAnchorPoint(cc.p(0.5, 0.5))
    return ret
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function  GameOverOtherPanel:ctor()
	local widget 		= ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFile)
    widget:removeFromParent()
    self:addChild(widget)
    self.nick_lable 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameLabNick);
    self.bean_label 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameLabBean);
    self.pochan_img 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameImgPoChan);
    self.zhuang_img  	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameImgZhuang);
    self.head_img 		= ccui.Helper:seekWidgetByName(widget,kWidgets.nameImghead);
    self.detail_btn 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameBtnDetail);
    self.detail_btn:addTouchEventListener(handler(self, self.onClickDetailButton));
    self.site = 1
end	

--[[
-- @brief  显示函数
-- @param  index 座位索引
-- @return void
--]]
function GameOverOtherPanel:onShow(index)
    Log.i("GameOverOtherPanel:onShow....",index)
	self.site = index
	local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
	self.m_scoreitems = MjProxy:getInstance()._gameOverData.scoreItems
	-- 显示头像
	self:showImgHead(self.head_img, index)

    if MjProxy:getInstance():getBanPosition() == index then
        self.zhuang_img:setVisible(true)
    end
    if self.m_scoreitems[index]:getBroke() == 1 then
        self.pochan_img:setVisible(true)
    end
	self.nick_lable:setString(self.m_scoreitems[index]:getNickName())
  	if self.m_scoreitems[index]:getTotalGold() > 0 then
        self.bean_label:setString("+"..self.m_scoreitems[index]:getTotalGold())
    else
        self.bean_label:setString(self.m_scoreitems[index]:getTotalGold())
    end  
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function GameOverOtherPanel:onClose()

end

--[[
-- @brief  显示头像函数
-- @param  img_head 头像图片，site 座次 
-- @return void
--]]
function GameOverOtherPanel:showImgHead(img_head, site)
    local imgName = MjProxy:getInstance()._players[site]:getIconId()
    if string.len(imgName) > 3 then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            img_head:loadTexture(imgName);
        end
    else
        if imgName == "0" then
            imgName = "1";
        end
        local headFile = "hall/Common/default_head_" .. imgName .. ".png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            img_head:loadTexture(headFile);
        end
    end
end

--[[
-- @brief  点击详情按钮
-- @param  void
-- @return void
--]]
function GameOverOtherPanel:onClickDetailButton(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
  		WWFacade:dispatchCustomEvent(enMjEventUi.GAME_OVER_PANEL_DETAIL_BTN, {index = self.site})
    end
end

return GameOverOtherPanel	