-------------------------------------------------------------
--  @file   VideoControlLayer.lua
--  @brief  录像回放控制层
--  @author ZCQ
--  @DateTime:2016-10-27 15:08:03
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define = require "app.games.huaibeimj.mediator.game.Define"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local VideoControlLayer = class("VideoControlLayer", function ()
	local ret = display.newLayer()
	-- ret:setTouchSwallowEnabled(false)
	-- local ret = display.newColorLayer(cc.c3b(255, 255, 255))
	-- ret:setTouchEnabled(false)
	return ret
end)
local kPngPath = "games/common/mj/games/" -- 操作根目录
-- 动作图片
local kPngName = {
	[Define.action_chi] 	= "game_btn_chi.png",
	[Define.action_peng] 	= "game_btn_peng.png",
	[Define.action_mingGang] 	= "game_btn_gang.png",
	[Define.action_anGang] 	= "game_btn_gang.png",
	[Define.action_jiaGang] 	= "game_btn_bugang.png",
	[Define.action_ting] 	= "game_btn_ting.png",
	[Define.action_buTing] 	= "game_btn_buting.png",
	[Define.action_dianPaoHu] 	= "game_btn_hu.png",
	[Define.action_guo] 	= "game_btn_qi.png",
	[Define.action_jiaBei] 	= "btn_jiabei.png",
	[Define.action_ziMoHu] 	= "game_btn_zimo.png",
}

-- 摆放起始位置
local kStartPos = {
	
}
-- 旋转
local kRotateAngles = {
	[Define.site_self] 	= 0,
	[Define.site_right] = -90,
	[Define.site_other] = 360,
	[Define.site_left] 	= 90,
}
-- 透明度数值
local kOpacity 	= 180 
-- 按钮开关
local kBtnType = {
    ON  = 0, -- 开
    OFF = 1, -- 关
}

local kEffect = {
	[Define.action_chi] 	= "AnimationCHI",
	[Define.action_peng] 	= "AnimationPENG",
	[Define.action_mingGang] 	= "AnimationGANG",
	[Define.action_anGang] 	= "AnimationGANG",
	[Define.action_jiaGang] 	= "AnimationGANG",
	[Define.action_ting] 	= "AnimationTING",
	[Define.action_dianPaoHu] 	= "AnimationHU",
	[Define.action_ziMoHu] 	= "AnimationHU",
	[Define.action_buhua] 	= "AnimationBUHUA",

}

local isSpeed 	= false
local speedTime = 0.3
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:ctor()

	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/video_layer.csb")
	self:addChild(self.m_pWidget)
	
	self.actionSpr 	= {} --  动作精灵
	self.actionNode = {} --  动作节点
	self.visibleWidth = cc.Director:getInstance():getVisibleSize().width
	self.visibleHeight = cc.Director:getInstance():getVisibleSize().height

	local actPos = {
		[Define.site_self] = cc.p(self.visibleWidth / 2 + 260, self.visibleHeight / 2 - 260),
		[Define.site_right] = cc.p(self.visibleWidth / 2 + 400, self.visibleHeight / 2 + 150),
		[Define.site_other] = cc.p(self.visibleWidth / 2 - 150, self.visibleHeight / 2 + 180),
		[Define.site_left] = cc.p(self.visibleWidth / 2 - 400, self.visibleHeight / 2 - 100),
	}
	for i=1, 4 do
		-- 创建节点
		local actNode = display.newNode()
		actNode:setPosition(actPos[i])
		actNode:setScale(0.8)
		self:addChild(actNode)
		table.insert(self.actionNode, actNode)
		--  创建动作字
		local pngPath = kPngPath..kPngName[i] -- 默认是吃
		local actSpr = display.newSprite(pngPath)
		local size 	= actSpr:getContentSize()
		-- actSpr:setScale(0.8)
		actSpr:setPosition(cc.p(0 - size.width / 2, size.height / 2))
		actNode:addChild(actSpr)
		table.insert(self.actionSpr, actSpr)
		-- 创建 弃字 
		local qiPng = kPngPath..kPngName[Define.action_guo] -- 默认是吃
		local qiSpr = display.newSprite(qiPng)
		qiSpr:setPosition(cc.p(size.width / 2, size.height / 2))
		local size 	= qiSpr:getContentSize()
		actNode:addChild(qiSpr)
		actNode:setRotation(kRotateAngles[i])
		actNode:setVisible(false)
	end
	-- 初始化控制版块
	self:initContralPanel()
	--  注册监听入口，出口函数
	self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
end

--[[
-- @brief  创建操作界面函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:initContralPanel()
	-- 回放面板
	self.allowSpeed = false
	local videoPanel = display.newSprite("hall/friendRoom/videoPanel.png")
	videoPanel:setPosition(cc.p(self.visibleWidth / 2, self.visibleHeight / 2 - 220))
	self:addChild(videoPanel)
	local panelSize = videoPanel:getContentSize()

	-- 快进按钮
    self.fastBtn = ccui.Button:create()
    self.fastBtn:loadTextureNormal("hall/friendRoom/kuaiJin1.png")
    self.fastBtn:setPosition(cc.p(panelSize.width / 2, panelSize.height / 2)) 
    self.fastBtn:addTo(videoPanel)
    self.fastBtn:addTouchEventListener(handler(self, self.onClickedFast))
    self.fastBtn:setOpacity(kOpacity)
    self.fastBtn:setTouchEnabled(false)

    local onImage 	= cc.MenuItemImage:create("hall/friendRoom/boFang.png", "hall/friendRoom/boFang.png", "hall/friendRoom/boFang1.png")
    onImage:setOpacity(kOpacity)
    local offImage  = cc.MenuItemImage:create("hall/friendRoom/zanTing.png", "hall/friendRoom/zanTing.png", "hall/friendRoom/boFang1.png")
    offImage:setOpacity(kOpacity)
    self.toggleClickVideo = cc.MenuItemToggle:create(onImage, offImage)
    self.toggleClickVideo:setEnabled(false)
    local clickSize = self.toggleClickVideo:getContentSize()
    local menu = cc.Menu:create(self.toggleClickVideo)
    menu:setPosition(cc.p(clickSize.width / 2 + 30, panelSize.height / 2 - 2))
    menu:addTo(videoPanel)  
    -- 暂停播放按钮响应
    self.toggleClickVideo:registerScriptTapHandler(handler(self, function ()
	
	    if(VideotapeManager:getInstance():isPlayingEndState()==false) then --视频是否播放结束
		
			if self.toggleClickVideo:getSelectedIndex() == kBtnType.ON then
				VideotapeManager:getInstance():resume()
				-- 设置不允许快进
				self:setAllowSpeedVisible(false)
			elseif self.toggleClickVideo:getSelectedIndex() == kBtnType.OFF then
				VideotapeManager:getInstance():pause()
				-- 设置允许快进
				self:setAllowSpeedVisible(true)
			end
			
		end
    end)) 

    --  退出按钮
    local exitBtn = ccui.Button:create()
    exitBtn:loadTextureNormal("hall/friendRoom/fanHui.png")
    exitBtn:setPosition(cc.p(panelSize.width - clickSize.width / 2 - 30, panelSize.height / 2)) 
    exitBtn:addTo(videoPanel)
    exitBtn:addTouchEventListener(handler(self, self.onClickedExit))
    exitBtn:setOpacity(kOpacity)

    self:performWithDelay(function ()
        self.toggleClickVideo:setEnabled(true)
 		self.allowSpeed = true
    end, kPlaybackInfo:getSpeedDelayTime())
end

--[[
-- @brief  快进按钮函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:setAllowSpeedVisible(isShow)
	-- setVisible(visible)
	if isShow 
	and self.allowSpeed then
		self.fastBtn:loadTextureNormal("hall/friendRoom/kuaiJin.png")
		self.fastBtn:setTouchEnabled(true)
	else
		self.fastBtn:loadTextureNormal("hall/friendRoom/kuaiJin1.png")
		self.fastBtn:setTouchEnabled(false)
	end

end

--[[
-- @brief  快进按钮函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onClickedFast(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
		print("VideoControlLayer:onClickedFast")
		if(VideotapeManager:getInstance():isPlayingEndState()==false) then --视频是否播放结束
		    VideotapeManager:getInstance():speed()
		    isSpeed = false
            self:performWithDelay(function()
                isSpeed = true
            end, speedTime)
		else
	        VideotapeManager:getInstance():showEndReturnUI(false)
	    end
	end
end

--[[
-- @brief  退出房间按钮函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onClickedExit(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
		print("VideoControlLayer:onClickedExit")
		-- MjMediator:getInstance():exitGame()
		-- display.getRunningScene():onExit()
		--  设置是从回放返回
		kPlaybackInfo:setVideoReturn(true)
		MjMediator:getInstance():exitGame()
	end
end


--[[
-- @brief  入口函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onEnter()
	
end

--[[
-- @brief  退出函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onExit()
	-- self:stopTimeSchedule()
	-- 反激活回放管理器
	VideotapeManager:getInstance():deactivate()
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onClose()
	-- self:stopTimeSchedule()
	-- 反激活回放管理器
	VideotapeManager:getInstance():deactivate()
end
--[[
-- @brief  显示函数
-- @param  actionType: 操作类型
-- @param  site: 坐位
-- @return void
--]]
function VideoControlLayer:onShowActionLab(data, site)

	self.actionNode[site]:setVisible(true)
	local actPng = kPngPath..kPngName[data.actionID] -- 默认是吃
	self.actionSpr[site]:setTexture(actPng)

	local scaleTo 	= cc.ScaleTo:create(0.2, 0.7)
	local scaleReverse 	= cc.ScaleTo:create(0.2, 1) --  还原
	local delay 	= cc.DelayTime:create(0.5)
	local delay02 	= cc.DelayTime:create(0.5)
	local callFun 	= cc.CallFunc:create(
		function ()
			self.actionNode[site]:setVisible(false)
			-- 显示操作动画
			-- MjMediator:getInstance():on_payerAction(kEffect[data.actionID], 1, site)
			WWFacade:dispatchCustomEvent(enMjEventUi.ACTION_SHOW_BTN_NTF)
		end
		)
	self.actionSpr[site]:runAction(
		cc.Sequence:create(
			delay02,
			scaleTo,
			scaleReverse,
			delay,
			callFun
			)
		)
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onHide()
	
end

return VideoControlLayer
