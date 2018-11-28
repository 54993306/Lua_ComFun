-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

-- endregion
require("app.games.common.UIBase")
local MjGameScene = require "app.games.huaibeimj.mediator.MjGameScene"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local PlayerLeft = require("app.games.huaibeimj.mediator.game.model.PlayerLeft")
local PlayerRight = require("app.games.huaibeimj.mediator.game.model.PlayerRight")
local PlayerOther = require("app.games.huaibeimj.mediator.game.model.PlayerOther")
local PlayerMyUI = require("app.games.huaibeimj.mediator.game.model.PlayerMyUI")
local  Player = require("app.games.huaibeimj.mediator.game.data.Player")
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local MjSide = require "app.games.huaibeimj.mediator.game.model.MjSide"
local MjGameSocketProcesser = require "app.games.huaibeimj.mediator.game.MjGameSocketProcesser"
local GameLayer = require ("app.games.huaibeimj.mediator.game.GameLayer")
local PlayerFlowNode = require "app.games.huaibeimj.mediator.game.model.PlayerFlowNode"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"

MjMediator = class("MjMediator")

MjMediator.getInstance = function()
    if not MjMediator.s_instance then
        MjMediator.s_instance = MjMediator.new();
    end
    return MjMediator.s_instance;
end

MjMediator.releaseInstance = function()
    if MjMediator.s_instance then
        MjMediator.s_instance:dtor();
    end
    MjMediator.s_instance = nil;
end

MjMediator.ctor = function(self)
    Log.i("MjMediator.ctor............")
	self:init()
	self.m_socketProcesser = MjGameSocketProcesser.new(self)
	SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)

end 

MjMediator.dtor = function(self)
	SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
	for i=1,#self._listeners do
		WWFacade:removeEventListener(self._listeners[i])
	end
	self._listeners= {}
end

function MjMediator:init()
	self._listeners = {}
	self._listeners[1] = WWFacade:addCustomEventListener(MJ_EVENT.MSG_SEND, handler(self, self.onMsgSend))
	self._listeners[2] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_startAniEnd, handler(self, self.on_startAniEnd))
	self._listeners[3] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_distrubuteEnd, handler(self, self.on_distrubuteEnd))
	self._listeners[4] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgFlower, handler(self, self.on_flower)) 
	self._listeners[5] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_putDownMj, handler(self, self.on_putDownMj)) 
	self._listeners[6] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgGameStart, handler(self, self.on_gameStart))  
	self._listeners[7] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgPlayCard, handler(self, self.on_playCard))  
	self._listeners[8] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgAction, handler(self, self.on_action))
	self._listeners[9] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgSubstitute, handler(self, self.on_substitute))
	self._listeners[10] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgGameOver, handler(self, self.on_msgGameOver))
	self._listeners[11] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgResume, handler(self, self.on_msgResume))
    self._listeners[12] = WWFacade:addCustomEventListener(MJ_EVENT.GAME_msgFlowAction, handler(self, self.on_flowaction))
end

--进入麻将模块(测试用)
function MjMediator:entryMj()
    -- local glView = cc.Director:getInstance():getOpenGLView();
    -- local size = glView:getFrameSize();
    -- glView:setFrameSize(size.height, size.width);
    -- glView:setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.EXACT_FIT)\
    UIManager.getInstance():changeToLandscape()
	self:suitDefinePos()

	self._scene = cc.Scene:create()
    display.replaceScene(self._scene)

    -- 背景
	local bg = display.newSprite("games/common/mj/games/game_bg.jpg")
	
	bg:addTo(self._scene)
	bg:setScale(1,Define.visibleHeight / (bg:getContentSize().height))
	bg:setPosition(cc.p(Define.visibleWidth /2, Define.visibleHeight /2))	

	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	-- self:setContentSize(cc.size(212, 116))

	-- 闹钟背景
	local clockSprite = display.newSprite("games/common/mj/games/clock_bg.png")
	clockSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight /2))
	clockSprite:addTo(self._scene)
--    local _flowLayer = {}
--    local headPos = {cc.p(60, 205), cc.p(Define.visibleWidth - 70, Define.visibleHeight/2+100), cc.p(Define.visibleWidth - 273, Define.visibleHeight - 80), cc.p(60, Define.visibleHeight/2+100)}
--    for i=1,4 do
--        _flowLayer[i]=PlayerFlowNode.new(i)
--        _flowLayer[i]:setPosition(headPos[i])
--        self._scene:addChild(_flowLayer[i])
--    end
--    local play = 1
--    local flower = {55}
--    _flowLayer[1]:showFlow(flower)
--    _flowLayer[2]:showFlow(flower)
--    _flowLayer[3]:showFlow(flower)
--    _flowLayer[4]:showFlow(flower)
--    local callFunc = cc.CallFunc:create(function () 
--        flower = {55,53}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local call_2 = cc.CallFunc:create(function () 
--        flower = {55,53,52}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local call_3 = cc.CallFunc:create(function() 
--        flower = {55,53,52,56}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local call_4 = cc.CallFunc:create(function() 
--        flower = {55,53,52,56,51}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local call_5 = cc.CallFunc:create(function() 
--        flower = {55,53,52,56,51,54}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local call_6 = cc.CallFunc:create(function() 
--        flower = {55,53,52,56,51,54,57}
--        _flowLayer[play]:showFlow(flower)
--    end)
--    local dt = cc.DelayTime:create(0.5)
--    _flowLayer[play]:runAction(cc.Sequence:create(dt,callFunc,dt,call_2,dt,call_3,dt,call_4,dt,call_5,dt,call_6))
--    游戏结算界面
--    local GameOverDialog = require ("app.games.huaibeimj.mediator.game.dialog.GameOverDialog")
--    local endLayer = GameOverDialog.new()
--    endLayer:addTo(self._scene)
-- 发牌		
	self.m_arrNoOrderMj = {}
	self.m_arrNoOrderMj2 = {}
		-- self:distrSelfMajiangAction(1)
		-- bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function()
		-- 	self:distrRightMajiangAction(1)
		--  end)))
		-- bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.75), cc.CallFunc:create(function()
		-- 	self:distrOtherMajiangAction(1)
		--  end)))
		-- bg:runAction(cc.Sequence:create(cc.DelayTime:create(1.05), cc.CallFunc:create(function()
		-- 	self:distrLeftMajiangAction(1)
		--  end)))
	-- 闹钟背景
	-- local clockSprite = display.newSprite("games/common/mj/games/clock_bg.png")
	-- clockSprite:setPosition(cc.p(640, 360))
	-- clockSprite:addTo(self._scene)


-- 初始化玩家self
 	local t = { }
 	local closeCard = {11,12,13,15,18,19,19,19,21,25,41,41,32,33}
    local sortFunc = function(a, b) 
         return a < b
    end
    table.sort(closeCard, sortFunc)
    for i,v in pairs(closeCard) do
        if v == 18 then
            local laizi = v
            table.remove(closeCard,i)
            table.insert(closeCard,1,laizi)
        end
    end
    
 	for k, v in ipairs(closeCard) do
 		local mj = Mj.new(v, Mj._EType.e_type_normal)
 		mj:retain()
 		t[#t + 1] = mj
 	end
 	MjProxy:getInstance()._players[Define.site_self] = Player.new()
 	MjProxy:getInstance()._players[Define.site_self].cards = t
 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 1


 	--初始化左边
 	MjProxy:getInstance()._players[Define.site_left] = Player.new()
 	MjProxy:getInstance()._players[Define.site_left].actionTimes = 1
 	-- 初始化右边
 	MjProxy:getInstance()._players[Define.site_right] = Player.new()
 	MjProxy:getInstance()._players[Define.site_right].actionTimes = 1
 	-- 初始化对家
 	MjProxy:getInstance()._players[Define.site_other] = Player.new()
 	MjProxy:getInstance()._players[Define.site_other].actionTimes = 1

    MjProxy:getInstance():setLaizi(10)

--    
--    for i=1, 14 do
--        t[i]:addTo(self._scene)
--        local pokerSiz = t[i]:getContentSize()
--        t[i]:setPosition(cc.p(i*pokerSiz.width,100))
--    end
    --初始化牌墩，并拿牌
--    local tricks = require("app.games.huaibeimj.custom.MJTricks")
------	Log.i("GameLayer:addMJOfTricks")
--	self._MJTricks = tricks.new(1)
--    self._MJTricks:addTo(self._scene,3)
--    self._MJTricks:initTriacksCard(3,8)
--    --显示癞子
--    local turn = require("app.games.huaibeimj.custom.MJTurnLaizigou")
--    local turnLaizigou = turn.new(18)
--    turnLaizigou:addTo(self._scene,5)
----  自己的牌
-- 	local myUi = PlayerMyUI.new()
-- 	-- myUi:ui_distrMj(1)
-- 	MjProxy:getInstance()._players[Define.site_self].gangTimes = 1
-- 	myUi:ui_drawActionThree(11,2,2)
----    myUi:ui_drawActionMj(4,11)
----    myUi:ui_drawActionThree(22,2,2)
-- 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 2
---- 	myUi:ui_drawActionThree(22,2,2)
--    myUi:ui_drawActionFour(15,3,3)
----    myUi:ui_drawActionMj(4,15)
-- 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 3
---- 	myUi:ui_drawActionThree(14,2,3)
--    myUi:ui_drawActionFour(12,3,4)
-- 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 4
-- 	myUi:ui_drawActionThree(14,3,4)
---- 	MjProxy:getInstance()._players[Define.site_self].gangTimes = 2

---- 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 5
---- 	myUi:ui_drawActionFour(16,3,2)
---- 	MjProxy:getInstance()._players[Define.site_self].actionTimes = 6

-- 	myUi:addTo(self._scene)
-- -- -- 对家的牌
-- 	local other = PlayerOther.new()
-- 	-- other:distrMj()
--    MjProxy:getInstance()._players[Define.site_other].gangTimes = 1
-- 	other:drawActionThree({11},2,2)
----    other:drawActionMajiang(4,{11})
-- 	MjProxy:getInstance()._players[Define.site_other].actionTimes = 2
-- 	other:drawActionThree({12},2,4)
----    other:drawActionMajiang(4,{12})
-- 	MjProxy:getInstance()._players[Define.site_other].actionTimes = 3
-- 	other:drawActionFour({14},3,1)

-- 	MjProxy:getInstance()._players[Define.site_other].actionTimes = 4
-- 	other:drawActionThree({15},2,1)

-- 	other:addTo(self._scene)

--  -- 左家
 	local left = PlayerLeft.new()
-- 	 left:distrMj()
    MjProxy:getInstance()._players[Define.site_left].gangTimes = 1
 	left:drawActionFour({15},5,3)

    MjProxy:getInstance()._players[Define.site_left].actionTimes = 2
 	left:drawActionThree({11},2,3)--下家
--    left:drawActionMajiang(4,{11})
 	MjProxy:getInstance()._players[Define.site_left].actionTimes = 3
 	left:drawActionFour({12},5,1)--对家
--    left:drawActionMajiang(4,{12})
 	MjProxy:getInstance()._players[Define.site_left].actionTimes = 4
 	left:drawActionFour({13},3,2)--上家
--    left:drawActionMajiang(4,{15})

-- 	left:drawActionFour(15,3)

-- 	 mj:playMj(12)
 	left:addTo(self._scene)
-------- 	 -- 右家
-- 	local right = PlayerRight.new()
---- 	right:distrMj()
--    MjProxy:getInstance()._players[Define.site_right].actionTimes = 1
-- 	right:drawActionThree({11},2,4)--上家
----    right:drawActionMajiang(4,{11})
-- 	MjProxy:getInstance()._players[Define.site_right].actionTimes = 2
-- 	right:drawActionThree({13},2,4)--下家
--    right:drawActionMajiang(4,{13})
-- 	MjProxy:getInstance()._players[Define.site_right].actionTimes = 3
-- 	right:drawActionFour({14},3,1)--对家
-- 	MjProxy:getInstance()._players[Define.site_right].actionTimes = 4
-- 	right:drawActionFour({15},5,4)

-- 	right:addTo(self._scene)

-- --打出去的牌
--	local pais = {}
--	for i=1,25 do
--		pais[i] = 12
--	end
--	local column = 10
--	local line = 2
--	-- 自己
--	for i=1,#pais do
--		local xPos = Define.g_pai_out_x + ((i -1) % column) * Define.g_pai_out_space ;
--	    local yPos = Define.g_pai_out_y - math.floor(((i -1) / column))* Define.g_pai_out_height;
--	   	local node = Mj.new(pais[i], Mj._EType.e_type_out, Mj._ESide.e_side_self)
--	    if i > 20 then
--	    	xPos = Define.g_pai_out_x + (i -11)  * Define.g_pai_out_space ;
--	    end
--	   	if i > 10 then
--	    	yPos = Define.g_pai_out_y -  Define.g_pai_out_height*0.7;
--	    end
--	    node:addTo(self._scene)
--	    node:setPosition(cc.p(xPos, yPos))
--	end
---- 对家
--	for i=1,#pais do
--		local xPos = Define.g_other_pai_out_x - ((i -1) % column) * Define.g_other_pai_out_space ;
--	    local yPos = Define.g_other_pai_out_y + math.floor(((i -1) / column))* Define.g_other_pai_out_height;
--	   	local node = Mj.new(pais[i], Mj._EType.e_type_out, Mj._ESide.e_side_other)
--	    if i > 20 then
--	    	xPos = Define.g_other_pai_out_x - (i -11)  * Define.g_other_pai_out_space ;
--	    end
--	    node:setLocalZOrder(100)

--	    if i > 10 then
--	    	yPos = Define.g_other_pai_out_y +  Define.g_other_pai_out_height*0.7
--	    	node:setLocalZOrder(100-i)

--	    end
--	    node:addTo(self._scene)
--	    node:setPosition(cc.p(xPos, yPos))
--	end
--	-- 下家
--	column = 9
--	for i=1,#pais do
--		local xPos = Define.g_right_pai_out_x + math.floor(((i -1) / column))* Define.g_side_pai_out_width;
--	    local yPos = Define.g_right_pai_out_y + ((i -1) % column)* Define.g_right_pai_out_space;
--	   	local node = MjSide.new(pais[i], MjSide._EType.e_type_out, MjSide._ESide.e_side_right)
--	    node:addTo(self._scene)
--	   	node:setLocalZOrder(100-i)

--	    node:setPosition(cc.p(xPos, yPos))
--	end
---- 上家
--	for i=1,#pais do
--		local xPos = Define.g_left_pai_out_x - math.floor(((i -1) / column))* Define.g_side_pai_out_width;
--	    local yPos = Define.g_left_pai_out_y - ((i -1) % column)* Define.g_left_pai_out_space;
--	   	local node = MjSide.new(pais[i], MjSide._EType.e_type_out, MjSide._ESide.e_side_left)
--	    node:addTo(self._scene)
--	    node:setPosition(cc.p(xPos, yPos))
--	end	
end

function MjMediator:distrSelfMajiangAction(times)
	local  pokers = {23, 24, 12, 13, 14, 16, 18, 25, 35, 34, 33, 32, 31}
	

	local count = #pokers
	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > count then
		to = count
	end
	local index = 0
	local backPokerSprite = display.newSprite("#self_gang_poker.png")
	if to - from > 0 then
		for i=1,to - from do
			local pokerSprite = display.newSprite("#self_gang_poker.png")
			pokerSprite:setAnchorPoint(cc.p(0, 0.5))
			pokerSprite:addTo(backPokerSprite)
			pokerSprite:setPosition(cc.p(backPokerSprite:getContentSize().width*i,backPokerSprite:getContentSize().height / 2))
		end		
	end
	backPokerSprite:setOpacity(100)
	backPokerSprite:setCascadeOpacityEnabled(true)
	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = Mj.new(pokers[from+i-1], Mj._EType.e_type_normal, Mj._ESide.e_side_self)
				mj:setPosition(cc.p(Define.g_pai_start_x + (from+i -2) * Define.g_pai_width, Define.g_pai_y )):addTo(self._scene)
				self.m_arrNoOrderMj[#self.m_arrNoOrderMj + 1] =mj
			end		
			if 	times < 5 then
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function ()
						self:distrSelfMajiangAction(times)

				end)))
			end
			if times == 5 then
				local backPokers = {}
				local callFunc1 = cc.CallFunc:create(function ()
					for i=1,count do
						self.m_arrNoOrderMj[i]:removeSelf()
					end
					for i=1,count do
						local pokerSprite = display.newSprite("#self_gang_poker.png")
						pokerSprite:setAnchorPoint(cc.p(0, 0.5))
						pokerSprite:setScale(1.65, 1.6)
						pokerSprite:setPosition(cc.p(Define.g_pai_start_x +(i -1)*pokerSprite:getContentSize().width*1.65, Define.g_pai_y))
						pokerSprite:addTo(self._scene)
						backPokers[i] = pokerSprite
					end				
				end)
				local callFunc = cc.CallFunc:create(function ()
					for i=1,count do
						backPokers[i]:removeSelf()
						local mj = Mj.new(pokers[i], Mj._EType.e_type_normal, Mj._ESide.e_side_self)
						mj:setPosition(cc.p(Define.g_pai_start_x + (i -1) * Define.g_pai_width, Define.g_pai_y )):addTo(self._scene)
					end
				end)
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), callFunc1))
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), callFunc))
			end
		end
	end)	
	backPokerSprite:setPosition(cc.p(620, 360))
	backPokerSprite:addTo(self._scene)
	local easeIn = cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(Define.g_pai_start_x+(times-1)*backPokerSprite:getContentSize().width*4*1.65, 120)))
	local spawn = cc.Spawn:create(easeIn, cc.ScaleTo:create(0.1, 1.5), cc.FadeTo:create(0.1, 255))
	backPokerSprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),spawn ,cc.DelayTime:create(0.1),call))
end

function MjMediator:distrRightMajiangAction(times)
	local  pokers = {23, 24, 12, 13, 14, 16, 18, 25, 35, 34, 33, 32, 31}
	
	local count = #pokers
	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > count then
		to = count
	end
	local index = 0
	local backPokerSprite = display.newSprite("#right_gang_poker.png")
	backPokerSprite:setLocalZOrder(10)
	if to - from > 0 then
		for i=1,to - from +1 do
			local pokerSprite = display.newSprite("#right_gang_poker.png")
			pokerSprite:setAnchorPoint(cc.p(0.5, 0))
			pokerSprite:addTo(backPokerSprite)
			pokerSprite:setLocalZOrder(10-i)
			pokerSprite:setPosition(cc.p(backPokerSprite:getContentSize().width/2,Define.g_side_pai_height*i - Define.g_side_pai_height))
		end		
	end

	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = display.newSprite("#right_poker.png")
				mj:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_pai_start_y + (from+i -2) * Define.g_side_pai_height )):addTo(self._scene)
				self.m_arrNoOrderMj2[#self.m_arrNoOrderMj2 + 1] =mj
				self.m_arrNoOrderMj2[1]:setLocalZOrder(15)
				if #self.m_arrNoOrderMj2 > 1 then
					self.m_arrNoOrderMj2[#self.m_arrNoOrderMj2]:setLocalZOrder(self.m_arrNoOrderMj2[#self.m_arrNoOrderMj2 -1]:getLocalZOrder() -1 )
				end
			end		
			if 	times < 5 then
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.9),  cc.CallFunc:create(function ()
					self:distrRightMajiangAction(times)
				end)))
			end
		end
	end)	
	backPokerSprite:setPosition(cc.p(620, 360))
	backPokerSprite:addTo(self._scene)
	local easeIn = cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(Define.g_right_pai_x, Define.g_right_pai_start_y+(times-1)*Define.g_side_pai_height*4.5)))
	local spawn = cc.Spawn:create(easeIn, cc.FadeIn:create(0.1))
	backPokerSprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),spawn ,cc.DelayTime:create(0.1),call))
end

function MjMediator:distrOtherMajiangAction(times)
	local  pokers = {23, 24, 12, 13, 14, 16, 18, 25, 35, 34, 33, 32, 31}
	

	local count = #pokers
	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > count then
		to = count
	end
	local index = 0
	local backPokerSprite = display.newSprite("#other_gang_poker.png")
	if to - from > 0 then
		for i=1,to - from do
			local pokerSprite = display.newSprite("#other_gang_poker.png")
			pokerSprite:setAnchorPoint(cc.p(1, 0.5))
			pokerSprite:addTo(backPokerSprite)
			pokerSprite:setPosition(cc.p(-backPokerSprite:getContentSize().width*i +backPokerSprite:getContentSize().width  ,backPokerSprite:getContentSize().height / 2))
		end		
	end

	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = display.newSprite("#other_poker.png")
				mj:setPosition(cc.p(Define.g_other_pai_start_x - (from+i -2) * Define.g_other_pai_width,Define.g_other_pai_y )):addTo(self._scene)
			end		
			if 	times < 5 then
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.9),
				 cc.CallFunc:create(function ()
					self:distrOtherMajiangAction(times) 
				end)))
			end
		end
	end)	
	backPokerSprite:setPosition(cc.p(620, 360))
	backPokerSprite:addTo(self._scene)
	local easeIn = cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(Define.g_other_pai_start_x- (times-1)*backPokerSprite:getContentSize().width*4,Define.g_other_pai_y)))
	local spawn = cc.Spawn:create(easeIn,  cc.FadeIn:create(0.1))
	backPokerSprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),spawn ,cc.DelayTime:create(0.1),call))
end

function MjMediator:distrLeftMajiangAction(times)
	local  pokers = {23, 24, 12, 13, 14, 16, 18, 25, 35, 34, 33, 32, 31}
	local count = #pokers
	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > count then
		to = count
	end
	local index = 0
	local backPokerSprite = display.newSprite("#left_gang_poker.png")
	if to - from > 0 then
		for i=1,to - from do
			local pokerSprite = display.newSprite("#left_gang_poker.png")
			pokerSprite:setAnchorPoint(cc.p(0.5, 1))
			pokerSprite:addTo(backPokerSprite)
			pokerSprite:setPosition(cc.p(backPokerSprite:getContentSize().width/2,-Define.g_side_pai_height*(i-1) + Define.g_side_pai_height *0.6))

		end		
	end

	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = display.newSprite("#left_poker.png")
				mj:setPosition(cc.p(Define.g_left_pai_x, Define.g_left_pai_start_y - (from+i -2) * Define.g_side_pai_height )):addTo(self._scene)
			end		
			if 	times < 5 then
				-- self:distrLeftMajiangAction(times)
				self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.9),  cc.CallFunc:create(function ()
				self:distrLeftMajiangAction(times)
				end)))			
			end
		end
	end)	
	backPokerSprite:setPosition(cc.p(620, 360))
	backPokerSprite:addTo(self._scene)
	local easeIn = cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(Define.g_left_pai_x, Define.g_left_pai_start_y-(times-1)*Define.g_side_pai_height*4)))
	local spawn = cc.Spawn:create(easeIn, cc.FadeIn:create(0.1))
	backPokerSprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),spawn ,cc.DelayTime:create(0.1),call))
end

--进入房间
function MjMediator:onGameEntry(data)
	kGameManager:setEntryComplete(false);
	UIManager.getInstance():popAllWnd();
    LoadingView.releaseInstance();
	self._scene = MjGameScene.new(data)
	cc.Director:getInstance():pushScene(self._scene)
end

--进入房间
function MjMediator:onGameEntryComplete(data)
	local roomInfo = kGameManager:getRoomInfo(data.gaI, data.roI);
    MjProxy:getInstance():setRoomInfo(roomInfo)
    MjProxy:getInstance():setRoomId(kFriendRoomInfo:getRoomId());
    MjProxy:getInstance():setGameId(CONFIG_GAEMID)
 
    UIManager.getInstance():changeToLandscape()
	self:suitDefinePos()
	if data.isRusumeGame == nil or data.isRusumeGame == false then
		self._gameLayer = GameLayer.new(false)
		self._scene:addChild(self._gameLayer)	
	else 
		self._gameLayer = GameLayer.new(true)
		self._scene:addChild(self._gameLayer)
	end

	kGameManager:setEntryComplete(true);
end

function MjMediator:suitDefinePos()
	Define.visibleWidth = cc.Director:getInstance():getVisibleSize().width
	Define.visibleHeight = cc.Director:getInstance():getVisibleSize().height
--    Log.i("Define.visibleWidth",Define.visibleWidth)
--    Log.i("Define.visibleHeight",Define.visibleHeight)
	Define.g_pai_out_x = Define.visibleWidth / 2 - 165
	Define.g_pai_out_y = Define.visibleHeight / 2 - 153
    if display.width/display.height >= 1.9 then
        Define.g_pai_out_y = Define.visibleHeight / 2 - 123
    end
	Define.g_other_pai_y = Define.visibleHeight - 80
	Define.g_other_show_pai_y = Define.visibleHeight - 100
	Define.g_other_pai_out_y = Define.visibleHeight / 2 + 160
	Define.g_other_pai_out_x = Define.visibleWidth / 2 + 177
	Define.g_other_pai_start_x = Define.visibleWidth  - 390
	Define.g_left_pai_out_x = Define.visibleWidth / 2 - 220
	Define.g_left_pai_out_y = Define.visibleHeight / 2 + 117
	Define.g_left_pai_start_y = Define.visibleHeight / 2  + 270
    Define.g_left_pai_action_start_y = Define.visibleHeight / 2  + 310
	Define.g_right_pai_start_y = Define.visibleHeight / 2 - 160
	Define.g_right_action_pai_start_y = Define.visibleHeight / 2 - 200
	Define.g_right_pai_out_x = Define.visibleWidth / 2 + 235
	Define.g_right_pai_out_y = Define.visibleHeight / 2 - 112
	Define.g_right_pai_x = Define.visibleWidth  - 192
	Define.g_right_pai_action_x = Define.visibleWidth - 280
	Define.g_right_show_pai_x = Define.visibleWidth - 227

    Define.mj_myCards_position_x = Define.visibleWidth / 2 + 212
    Define.mj_myCards_position_y = Define.visibleHeight / 2 - 191
    Define.mj_leftCards_position_x = Define.visibleWidth / 2 -230
    Define.mj_leftCards_position_y = Define.visibleHeight / 2 -175
    Define.mj_otherCards_position_x = Define.visibleWidth / 2 - 209
    Define.mj_otherCards_postion_y = Define.visibleHeight / 2 + 185
    Define.mj_rightCards_position_x = Define.visibleWidth / 2 + 235
    Define.mj_rightCards_position_y = Define.visibleHeight / 2 + 165
end
function MjMediator:getScene()
    return self._scene
end
function MjMediator:on_gameStart()
    MjProxy.getInstance():setGameState("gameStarting")
	MjProxy:getInstance():initAuxiliaryData()
	if self._gameLayer then
		self._gameLayer:on_gameStart()
	end
end

function MjMediator:on_startAniEnd()
	if self._gameLayer then
		self._gameLayer:on_startAniEnd()
	end
end

function MjMediator:on_distrubuteEnd()
	if self._gameLayer then
		self._gameLayer:on_distrubuteEnd()		 
	end	
end

function MjMediator:on_flower()
	if self._gameLayer then
		self._gameLayer:on_flower()		   
	end	
end
function MjMediator:showActionButton(actions,playCard)
    
    if self._gameLayer then
       self._gameLayer:showActionButton(actions,playCard)
    end
end

function MjMediator:on_putDownMj(event)
	if self._gameLayer then
		self._gameLayer:on_putDownMj(event)		   
	end	
end

function MjMediator:on_payerAction(amimation,time,sex)
    if self._gameLayer then
        return self._gameLayer:on_payerAction(amimation,time,sex)
    end
    return nil
end
function MjMediator:on_dianpaoAction(sex)
    if self._gameLayer then
        return self._gameLayer:on_dianpaoAction(sex)
    end
end
function MjMediator:on_playerHU(cx,cy)
    if self._gameLayer then
        return self._gameLayer:on_playerHU(cx,cy)
    end
end
function MjMediator:on_playCard(playCardData)
	if self._gameLayer then
		self._gameLayer:on_playCard(playCardData)		   
	end	
end

function MjMediator:on_dispenseCard(packageInfo)
	if self._gameLayer then
		self._gameLayer:on_dispenseCard(packageInfo)
	end
end

function MjMediator:on_action(actionData)
    Log.i("MjMediator:on_action")
	if self._gameLayer then
		self._gameLayer:on_action(actionData)
	end
end
function MjMediator:on_otherFlower()
    if self._gameLayer then
        self._gameLayer:on_otherFlower()
    end
end
function MjMediator:on_flowaction(data)
    if self._gameLayer then
        self._gameLayer:on_flower(data)
    end
end

function MjMediator:on_substitute()
	if self._gameLayer then
		self._gameLayer:on_substitute()
	end
end

function MjMediator:on_msgGameOver()
	if self._gameLayer then
		self._gameLayer:on_msgGameOver()
	end
end

function MjMediator:on_msgChat()
	if self._gameLayer then
		self._gameLayer:on_msgChat()
	end
end

--语音聊天
function MjMediator:on_speaking(packetInfo)
    Log.i("------MjMediator:on_speaking packetInfo.usI", packetInfo.usI);
    if self._gameLayer then
        self._gameLayer:on_speaking(packetInfo);
    end
end

--语音聊天
function MjMediator:on_hideSpeaking(userId)
    Log.i("------MjMediator:on_hideSpeaking userId", userId);
    if self._gameLayer then
        self._gameLayer:on_hideSpeaking(userId)
    end
    -- if not kSettingInfo:getGameVoiceStatus() then
    --     audio.resumeMusic();
    -- end
end

function MjMediator:on_msgDefaultChar()
    if self._gameLayer then
        self._gameLayer:on_msgDefaultChar()
    end
end

function MjMediator:on_recChargeResult(packetInfo)
    if self._gameLayer then
        self._gameLayer:recChargeResult(packetInfo)
    end
end
function MjMediator:on_msgResume()
	Log.i("MjMediator:on_msgResume")
    MjProxy.getInstance():setGameState("gameResume")
	MjProxy:getInstance():initAuxiliaryData()
	if  MjProxy:getInstance():getNeedXiaOrLaZhuangPao() == true then
		MjProxy:getInstance()._players[Define.site_self]:setFapaiFished(MjProxy:getInstance():getXiaPaoFinished())
	else
		MjProxy:getInstance()._players[Define.site_self]:setFapaiFished(true) 
	end
	if self._gameLayer then
		self._gameLayer:removeFromParent()
		self._gameLayer = nil
	end

	self._gameLayer = GameLayer.new(true)
	self._scene:addChild(self._gameLayer)
	self._gameLayer:resume()
end

function MjMediator:continueGame(type)
	self:newGameLayer(type)
    if MjProxy:getInstance()._gameStartDataTable == nil then
        local data = {};
        data.gaI = MjProxy:getInstance():getGameId();
        -- data.plT = MjProxy:getInstance()._GameStart.plT;
        data.roI = MjProxy:getInstance():getRoomId();
        data.ty = type;-- 1 续局 2 换桌
        Log.d("MjMediator:continueGame data=", data)
        SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_GAMESTART, data);	
    else
        local data = MjProxy:getInstance()._gameStartDataTable
        self.m_socketProcesser:handle_gameStart(data.cmd,data.table)
        MjProxy:getInstance()._gameStartDataTable = nil
    end
end

function MjMediator:newGameLayer(mType)
	if self._gameLayer then
		self._gameLayer:removeFromParent()
		self._gameLayer = nil
	end
	self:clearData(mType)
	local isContinue = false
	if mType == 1 and MjProxy:getInstance():getDeskDismiss() == false then
		isContinue = true
	end
	self._gameLayer = GameLayer.new(false, isContinue)
	self._scene:addChild(self._gameLayer)
end

function MjMediator:exitGame()
	kGameManager:setEntryComplete(false);
	if self._gameLayer then
		self._gameLayer:onExit();
		self._gameLayer:removeFromParent()
		self._gameLayer = nil
	end
	LoadingView.getInstance():hide()
    Toast:releaseInstance()
    LoadingView:releaseInstance()
	UIManager.getInstance():popAllWnd(); --要删除管理类中的窗口，不然在换场景是报错是。
	self:clearData()
	MjProxy:releaseInstance()
	self:releaseInstance()
	package.loaded["app.games.changzhoumj.event.MjEvent"] = nil
	package.loaded["app.games.changzhoumj.init"] = nil
	package.loaded["app.games.changzhoumj.proxy.MjProxy"] = nil
	package.loaded["app.games.changzhoumj.event.MjEvent"] = nil
	package.loaded["app.games.changzhoumj.mediator.MjMediator"] = nil
	package.loaded["app.games.changzhoumj.MJConfig"] = nil
	--
    audio.stopMusic();
    cc.Director:getInstance():popScene();
end

function MjMediator:on_showFlowerNumber(number)
    self._gameLayer:showFlowNumber(number)
end

function MjMediator:isFanZi(card)
    local fanzi = 0
    local laizi = MjProxy:getInstance():getLaizi()
    if laizi == nil or laizi < 10 then
        return
    end
    if laizi<40 then
        if laizi%10 ~= 1 then
            fanzi = laizi-1
        elseif laizi%10== 1 then
            fanzi = laizi-laizi%10+9
        end
    elseif laizi > 40 and laizi < 50 then
        if (laizi > 41 and laizi < 45) or (laizi > 45 and laizi < 48) then
            fanzi = laizi -1
        elseif laizi == 41 then
            fanzi = 44
        elseif laizi == 45 then
            fanzi = 47
        end
    end
    if card == fanzi then
        -- Log.i("为幡子。。。。")
        return true
    end
    return false
end

function MjMediator:getFanZi()
    local fanzi = 0
    local laizi = MjProxy:getInstance():getLaizi()
    if laizi == nil or laizi < 10 then
        return
    end
    if laizi<40 then
        if laizi%10 ~= 1 then
            fanzi = laizi-1
        elseif laizi%10== 1 then
            fanzi = laizi-laizi%10+9
        end
    elseif laizi > 40 and laizi < 50 then
        if (laizi > 41 and laizi < 45) or (laizi > 45 and laizi < 48) then
            fanzi = laizi -1
        elseif laizi == 41 then
            fanzi = 44
        elseif laizi == 45 then
            fanzi = 47
        end
    end
    return fanzi
end

function MjMediator:getGameLayer()
    return self._gameLyer
end
    
function MjMediator:on_continueReady(userIds)
    self._gameLayer:on_continueReady(userIds)
end

function MjMediator:on_removeContinueReady()
    self._gameLayer:on_removeContinueReady()
end

function MjMediator:on_showPaoMaDeng(content)
    self._gameLayer:on_showPaoMaDeng(content)
end

function MjMediator:on_updateTakenCash(info)
    self._gameLayer:on_updateTakenCash(info)
end

function MjMediator:on_dismissDesk(info)
    self._gameLayer:on_dismissDesk(info)
end

-- 网络异常处理--

--重连成功
function MjMediator:onNetWorkReconnected()
    self._gameLayer:performWithDelay(function()
        MJLoadingView.getInstance():hide();
        MJToast.getInstance():show("重连成功");
    	MjProxy:getInstance()._msgCache = {}
    	self:requestResumeGame()
    end, 1);   
end 

--正在重连
function MjMediator:onNetWorkReconnect()
    
end 

--恢复对局
function MjMediator:requestResumeGame()
    MJLoadingView.getInstance():show("正在重连...");    
	SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME,  { plID = MjProxy:getInstance():getPlayId()});    
end

function MjMediator:onNetWorkClosed()
    Log.d("------MjMediator:onNetWorkClosed")
    MJLoadingView.getInstance():hide();

    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end

    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = "网络异常，请检查您的网络是否正常再进入游戏";
    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();
        self:exitGame();
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);    
end 

function MjMediator:onNetWorkClose()
    
end 

function MjMediator:onNetWorkConnectFail()
    Log.d("------MjMediator:onNetWorkConnectFail")
    MJLoadingView.getInstance():hide();

    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end

    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = "连接服务器失败，请检查您的网络是否正常再进入游戏";
    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();
        self:exitGame();
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);    
end

--服务器通知
function MjMediator:repBrocast(packetInfo)
    if packetInfo.ti == 4 then  -- 被踢下线
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.contentType = COMNONDIALOG_TYPE_KICKED;
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理";
        data.closeCallback = function ()
            SocketManager.getInstance():closeSocket();
            self:exitGame();
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif packetInfo.ti == 5 then -- 关服通知
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        UIManager.getInstance():pushWnd(CommonDialog, data);
    end
end

function MjMediator:handleLeaveStatus(packetInfo)
    self._gameLayer:handleLeaveStatus(packetInfo)
	
end

function MjMediator:onNetWorkConnectException()
    Log.d("------MjMediator:onNetWorkConnectException");
    MJLoadingView.getInstance():show("网络异常，正在重连...");    
end  

--连接弱
function MjMediator:onNetWorkConnectWeak()
    Log.d("------MjMediator:onNetWorkConnectWeak");
    MJLoadingView.getInstance():show("您当前的网络不稳定，请检查您的网络", 10, true);
    
end 
-- 网络异常处理--

-- 请求离开游戏
function MjMediator:requestExitRoom()
	SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom,  { });
	MJLoadingView.getInstance():show("正在退出游戏，请稍后...");
	self._gameLayer:performWithDelay(function ()
        self:exitGame();
    end, 2);
end 

function MjMediator:clearData(mType)
	MjProxy:getInstance()._gameStartData = nil
	MjProxy:getInstance()._msgCache = nil
	MjProxy:getInstance()._flowerData = nil 
	MjProxy:getInstance()._playCardData = nil
	MjProxy:getInstance()._actionData = nil  
	MjProxy:getInstance()._substituteData = nil
	MjProxy:getInstance()._gameOverData = nil
	MjProxy:getInstance()._userInfoData = nil
	MjProxy:getInstance()._chatData = nil
	MjProxy:getInstance()._propData = nil
	MjProxy:getInstance()._missionData = nil
	if mType  and mType == 1 then
	else
		MjProxy:getInstance()._players = nil 
	end
	MjProxy:getInstance()._commonOverData = nil 
	MjProxy:getInstance()._gameStartData = nil

end

--统一消息发送接口
function MjMediator:onMsgSend(event)
	------------------回放功能-----------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		return
	end
	-------------------------------------------
	local msgId = unpack(event._userdata)
	assert(msgId and type(msgId) == "number")
	Log.d("MjMediator:onMsgSend: %x", msgId)

	if msgId == ww.mj.msgSendId.msgSend_substitute then
		local _, param = unpack(event._userdata)
		--1托管，0取消托管
		SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, {maPI = MjProxy:getInstance():getMyUserId(), isM = param})
	elseif msgId == ww.mj.msgSendId.msgSend_turnOut then
		local _, param = unpack(event._userdata)		
		local playid = MjProxy:getInstance()._gameStartData.gamePlayID
		SocketManager.getInstance():send(CODE_TYPE_GAME, msgId, {plID = playid, usID = MjProxy:getInstance():getMyUserId(), ca = param});

	--请求操作
	elseif msgId == ww.mj.msgSendId.msgSend_mjAction then
        
		dump(event._userdata, "发送操作数据")
		local _, actionId, actionResult, actionCard, cbCard = unpack(event._userdata)
		Log.d("发送消息",MjProxy:getInstance():getMyUserId(),actionId, actionResult, actionCard, cbCard)

		local playid = MjProxy:getInstance()._gameStartData.gamePlayID
		if cbCard then
			SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, 
				{plID = playid, 
				usID = MjProxy:getInstance()._players[Define.site_self]:getUserId(), 
				acID = actionId, 
				acR = actionResult, 
				acC0 = actionCard, 
				cbC = cbCard});
		else
			SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, 
				{plID = playid, 
				usID = MjProxy:getInstance()._players[Define.site_self]:getUserId(), 
				acID = actionId, 
				acR = actionResult, 
				acC0 = actionCard});
		end
	end
  
end
--[[
-- @brief  下跑函数
-- @param  void
-- @return void
--]]
function MjMediator:on_xiaPaoOrLaZhuang()
	self._gameLayer:on_xiaPaoOrLaZhuang()
end

--[[
-- @brief  打牌能标志函数
-- @param  void
-- @return remainder = 1 不可以打牌 remainder = 2 可以打牌
--]]
function MjMediator:isCanPlayCard()
	local myCards 	= MjProxy:getInstance()._players[Define.site_self].cards
	local remainder = #myCards % 3
	return remainder
end


