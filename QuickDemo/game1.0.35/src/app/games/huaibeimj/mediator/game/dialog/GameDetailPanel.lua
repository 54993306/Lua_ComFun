-------------------------------------------------------------
--  @file   GameDetailPanel.lua
--  @brief  结算时其他玩家的版块
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-07-29 15:26:37
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local WWFacade = require "app.games.huaibeimj.custom.WWFacade"
local kCSBFile = "games/common/mj/over_item_detail.csb"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local kWidgets = {
	namePanel 		= "root",
	nameLabNick 	= "Lab_nick",
	nameLabBean 	= "Lab_bean",
	nameImgPoChan 	= "Img_pochan",
	nameImgZhuang 	= "img_zhuang",
	nameImghead 	= "Img_head",
    nameLabDetail   = "lab_detail",
	nameBtnClose    = "btn_close",
    nameSVPan       = "pan_ScrollView",
}
local GameDetailPanel = class(GameDetailPanel, function()
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
function  GameDetailPanel:ctor()
	local widget 	    = ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFile)
    widget:removeFromParent()
    self:addChild(widget)
    self.nick_label     = ccui.Helper:seekWidgetByName(widget, kWidgets.nameLabNick)
    self.bean_label 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameLabBean)
    self.pochan_img 	= ccui.Helper:seekWidgetByName(widget, kWidgets.nameImgPoChan)
    self.zhuang_img     = ccui.Helper:seekWidgetByName(widget, kWidgets.nameImgZhuang)
    self.head_img 	    = ccui.Helper:seekWidgetByName(widget, kWidgets.nameImghead)
    self.detail_lab     = ccui.Helper:seekWidgetByName(widget, kWidgets.nameLabDetail)
    self.close_btn      = ccui.Helper:seekWidgetByName(widget, kWidgets.nameBtnClose)
    self.pan_scrollview = ccui.Helper:seekWidgetByName(widget, kWidgets.nameSVPan)
    self.site = 1
end	

--[[
-- @brief  显示函数
-- @param  index 座位索引
-- @return void
--]]
function GameDetailPanel:onShow(index)
	self.site = index
	local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
    Log.i("winnerSite....",winnerSite)
--    local winnerSite = self.site
	self.m_scoreitems = MjProxy:getInstance()._gameOverData.scoreItems
    local gameId = MjProxy:getInstance():getGameId()
    local detail = {}
    if winnerSite ~= 0 then
        Log.i("self.m_scoreitems[winnerSite].policyName...",self.m_scoreitems[winnerSite].policyName)
        local pon = self.m_scoreitems[winnerSite].policyName or {}
        local pos = self.m_scoreitems[winnerSite].policyScore or {}
        local adPN = self.m_scoreitems[self.site].addPolicyName or {}
        local adPS = self.m_scoreitems[self.site].addPolicyScore or {}
        local textUnit = "番"
        Log.i("pon........",pon)
        for i=1, #pon do
            Log.i("GameDetailPanel:onShow   pon[i]....",pon[i])
            if pon[i] == "花" then
                Log.i("等于花")
--                pon[i] = ""
--                textUnit = "花"
                detail[#detail+1] = pos[i].."花"
            else 
                if pon[i] == "普通自摸" or pon[i] == "自摸" then
                    Log.i("普通自摸")
--                    pon[i] = "自摸"
--                    textUnit = ""
--                    pos[i] = ""
                    
                    if gameId ~= Define.gameId_changzhou then
                        detail[#detail+1] = "自摸"
                    end
                else
                    if pon[i] == "四癞子" then
                        pon[i] = "四原子"
                    end
                    detail[#detail+1] = pon[i]
                end
                
                if pos[i] ~= nil and pos[i] ~= "" then
                    local pos_i = tonumber(pos[i])
				    if pos_i >= 100 then
--					    textUnit = "倍底注"
                        detail[#detail] = detail[#detail].." "..pos_i.."倍底注"
                    else
                        if pos_i > 0 then
                            detail[#detail] = detail[#detail].." "..pos_i.."番"
                        end
				    end
                end
            end
--            detail = detail..pon[i].." "..pos[i]..textUnit.."  "
        end
        for i = 1, #adPN do
            detail[#detail+1] = adPN[i].." "..adPS[i].."倍"
        end
    end
    Log.i("GameDetailPanel:onShow....",detail)
    local function scrollFunc(data,mWight,nIndex)
        mWight:setString(detail[nIndex])
        local labContSize = mWight:getContentSize()
        local dataLen = string.len(detail[nIndex])
        local dataSize = dataLen*20 
        if labContSize.width < dataSize then
            mWight:setContentSize(cc.size(dataSize,labContSize.height))
        end
    end
    self.m_scollView = new_cScrollView(self.pan_scrollview,self.detail_lab,detail,scrollFunc,5,3)
--    Log.i("dataString==========",dataString)
	-- 显示头像
	self:showImgHead(self.head_img, index)

    if MjProxy:getInstance():getBanPosition() == index then
        self.zhuang_img:setVisible(true)
    end

 	if self.m_scoreitems[index]:getBroke() == 1 then
 		self.pochan_img:setVisible(true)
 	end
		self.nick_label:setString(self.m_scoreitems[index]:getNickName())
  	if self.m_scoreitems[index]:getTotalGold() > 0 then
        self.bean_label:setString("+"..self.m_scoreitems[index]:getTotalGold())
    else
        self.bean_label:setString(self.m_scoreitems[index]:getTotalGold())
    end
--    self.detail_lab:setString(detail)
--    if self.m_scoreitems[index]:getTotalGold() == 0   then
--        if MjProxy:getInstance()._players[index]:getFillingNumByType() > 0 then
--            self.detail_lab:setString("下"..MjProxy:getInstance()._players[index]:getFillingNumByType().."跑子")
--        end
--    else
--        if MjProxy:getInstance()._players[index]:getFillingNumByType() > 0 then
--            self.detail_lab:setString("下"..MjProxy:getInstance()._players[index]:getFillingNumByType().."跑子 "..detail)
--        else
--            self.detail_lab:setString(detail)
--        end
--    end        
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function GameDetailPanel:onClose()

end

--[[
-- @brief  关闭函数 必须要在创建类之后调用该函数
-- @param  isShow true 显示 false 隐藏
-- @return void
--]]
function GameDetailPanel:enableCloseBtn(isShow)
    if isShow then
        self.close_btn:setVisible(true)
        self.close_btn:addTouchEventListener(handler(self, self.onClickCloseButton))
    else
        self.close_btn:setVisible(false)
    end
end

--[[
-- @brief  显示头像函数
-- @param  img_head 头像图片，site 座次 
-- @return void
--]]
function GameDetailPanel:showImgHead(img_head, site)
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
-- @brief  点击关闭按钮
-- @param  void
-- @return void
--]]
function GameDetailPanel:onClickCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        WWFacade:dispatchCustomEvent(enMjEventUi.GAME_CLOSE_DETAIL_PANEL_BTN, {index = self.site})
    end
end

return GameDetailPanel	