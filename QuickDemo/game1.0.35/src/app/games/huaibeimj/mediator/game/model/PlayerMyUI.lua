-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local MjSide = require "app.games.huaibeimj.mediator.game.model.MjSide"
local MjTool = require "app.games.huaibeimj.custom.MjTool"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")

local PlayerMyUI = class("PlayerMyUI", function ()
	return display.newNode()
end)

function PlayerMyUI:ctor()
	Log.i("PlayerMyUI:ctor")
	self.m_pickOutMj = { }
	self.m_arrHuaPai = { }
	self.m_arrNoOrderMj = {}
	self.m_newMj = nil
	self.m_outMjPositionX = 0
	self.m_newPaiMovePositionX = 0
	self.m_newPaiIndex = -1
end

function PlayerMyUI:ui_recoveryMj()

    local gameLayer = self:getParent():getParent():getParent()
	local topencard =  MjProxy:getInstance()._players[Define.site_self].m_openCards
	local topencardType =  MjProxy:getInstance()._players[Define.site_self].m_openCardsType
	local openCardsUserIds = MjProxy:getInstance()._players[Define.site_self].m_openCardsUserIds
	local openActionCards = MjProxy:getInstance()._players[Define.site_self].m_openActionCards

	Log.i("PlayerMyUI:ui_recoveryMj topencard=",topencard)
	Log.i("PlayerMyUI:ui_recoveryMj topencardType=",topencardType)
	Log.i("PlayerMyUI:ui_recoveryMj openCardsUserIds=",openCardsUserIds)
	Log.i("PlayerMyUI:ui_recoveryMj openActionCards=",openActionCards)

	if #topencard ~= #topencardType then
		Log.i("恢复对局操作的牌类型和牌值数量不一致")
	end

    Log.i("#topencard///////////",#topencard)
	for i = 0, #topencard - 1 do
		local card = topencard[i + 1]
		local action = topencardType[i + 1]
		local userId = openCardsUserIds[i + 1]
		local actionCard  = openActionCards[i + 1]
        Log.i("card...........",card)
        -- if card <45 and card ~= 41 then
            Log.i("PlayerMyUI   setActionTimes...")
		    MjProxy:getInstance()._players[Define.site_self]:setActionTimes(MjProxy:getInstance()._players[Define.site_self]:getActionTimes() + 1)
        -- else
        --     gameLayer.m_playerHeadNode:setBuhuaNumber(Define.site_self,card)
        -- end
		local table = nil
		if action == Define.action_chi then
			table = { card, card + 1, card + 2 }
		elseif action == Define.action_peng then
			table = { card, card, card }
		elseif action == Define.action_mingGang or action == Define.action_anGang or action == Define.action_jiaGang then
            Log.i("aaa....",card)
            table = { card, card, card, card }
		    if action ~= Define.action_jiaGang then
			    MjProxy:getInstance()._players[Define.site_self]:setGangTimes(MjProxy:getInstance()._players[Define.site_self]:getGangTimes() + 1)
		    end
		end
		self:ui_drawActionMj(MjProxy:getInstance()._actionData,action, table, true, userId, actionCard)
	end
	self:ui_removeAllMj()
	self:ui_drawAllMj()
	WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_distrubuteEnd)

    
end

function PlayerMyUI:setOutMjPositionX(x)
	self.m_outMjPositionX = x
end

function PlayerMyUI:ui_distrMj()
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	local temp = MjTool.tableCopy(myCards)
    --把牌打乱
	for i = 1, #temp do
		local random = math.random(#temp)
		self.m_arrNoOrderMj[#self.m_arrNoOrderMj + 1] = temp[random]
		table.remove(temp, random)
	end
	self:ui_distrMajiangAction(1)
end

function PlayerMyUI:ui_distrMajiangAction(times)
	assert(self.m_arrNoOrderMj ~= nil and #self.m_arrNoOrderMj ~= 0)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	local data = MjProxy:getInstance()._gameStartData
	if data == nil or data == { } then
		return
	end
	local nPai = 13
	if data.bankPlay == MjProxy:getInstance()._userIds[Define.site_self] then
		nPai = 14
	end	
	
	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > nPai then
		to = nPai
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
	backPokerSprite:setOpacity(255)
	backPokerSprite:setCascadeOpacityEnabled(true)
	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = self.m_arrNoOrderMj[from + i -1 ]
				mj:setPosition(cc.p(Define.g_pai_start_x + (from+i -2) * Define.g_pai_width, Define.g_pai_y )):addTo(self)
			end		
			if 	times < 5 then
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function ()
					self:ui_distrMajiangAction(times)
				end)))
			end
			if times == 5 then
				local backPokers = {}
				local callFunc1 = cc.CallFunc:create(function ()
					for i=1,nPai do
						self.m_arrNoOrderMj[i]:removeSelf()
					end
					for i=1,nPai do
						local pokerSprite = display.newSprite("#self_gang_poker.png")
						pokerSprite:setAnchorPoint(cc.p(0, 0.5))
						pokerSprite:setScale(1.65, 1.6)
						pokerSprite:setPosition(cc.p(Define.g_pai_start_x +(i -1)*pokerSprite:getContentSize().width*1.65, Define.g_pai_y))
						pokerSprite:addTo(self)
						backPokers[i] = pokerSprite
					end	
                    CommonSound.playSound("koupai")			
				end)
				local callFunc = cc.CallFunc:create(function ()
					
					for i=1,nPai do
						backPokers[i]:removeSelf()
						local mj = myCards[i]
                        local paren = mj:getParent()
                        if paren == nil then
                            mj:setPosition(cc.p(Define.g_pai_start_x + (i -1) * Define.g_pai_width, Define.g_pai_y )):addTo(self)
                        else
                            mj:setPosition(cc.p(Define.g_pai_start_x + (i -1) * Define.g_pai_width, Define.g_pai_y ))
                        end
                        if i == 14 then
                            mj:runAction(cc.MoveBy:create(0.2,cc.p(15,0)))
                            self.m_newMj = mj
                        end
                        CommonSound.playSound("koupai")	
					end
                    self:performWithDelay(function ()
                        WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_distrubuteEnd)
                    end,0.2)
				end)
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), callFunc1))
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), callFunc))
			end
		end
	end)	
    if Define.isVisibleTrick == true then
	    backPokerSprite:setPosition(cc.p(Define.visibleWidth / 2 - 30, Define.visibleHeight / 2))
    else
        backPokerSprite:setPosition(cc.p(Define.visibleWidth, Define.visibleHeight))
    end
	backPokerSprite:addTo(self)
	local easeIn = cc.EaseSineOut:create(cc.MoveTo:create(Define.game_distrMjAction_time, cc.p(Define.g_pai_start_x+(times-1)*backPokerSprite:getContentSize().width*4*1.65, 120)))
	local spawn = cc.Spawn:create(easeIn, cc.ScaleTo:create(Define.game_distrMjAction_time, 1.5), cc.FadeTo:create(0.2, 255))
	backPokerSprite:runAction(cc.Sequence:create(spawn ,cc.CallFunc:create(function() CommonSound.playSound("fapai") end),cc.DelayTime:create(0.1),call))
end

function PlayerMyUI:ui_addBuhuaSprite0(doorCard)
	Log.i("PlayerMyUI:ui_addBuhuaSprite0........",doorCard)
    
    local gameLayer = self:getParent():getParent():getParent()
	assert(gameLayer ~= nil)
    
	assert(doorCard ~= nil and type(doorCard) == "number")
	local bgLayer = self:getParent():getParent():getParent()._bgLayer
	assert(bgLayer ~= nil)
    if doorCard > #self.m_arrHuaPai then
        doorCard = #self.m_arrHuaPai
    end
	self.m_arrHuaPai = self.m_arrHuaPai or { }
    Log.i("移除花牌",doorCard,#self.m_arrHuaPai)
    if self.m_arrHuaPai ~= nil and #self.m_arrHuaPai > 0 then
        Log.i("self.m_arrHuaPai..",self.m_arrHuaPai[1]._value)
		self.m_arrHuaPai[1]:removeFromParent()
        table.remove(self.m_arrHuaPai,1)
    end
    MjProxy:getInstance():runPopAllMsgCache("flower")

    if #MjProxy:getInstance()._msgCache<=0 
        or MjProxy:getInstance()._msgCache[1].msg_k ~= ww.mj.msgReadId.msgRead_mjAction 
        or MjProxy:getInstance()._msgCache[1].msg_v.actionID ~= Define.action_buhua then
        MjProxy:getInstance():setBuHua(false)
    end
end
function PlayerMyUI:ui_drawNewMj(mj)
    local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
    Log.d("MjProxy:getInstance():getCurrentAction()....",MjProxy:getInstance():getCurrentAction())
    self:ui_getTheNewMj(mj)
end
function PlayerMyUI:ui_getTheNewMj(mj)
    local gameLayer = self:getParent():getParent():getParent()
    -- 刷新界面剩余牌数
    -- gameLayer._bgLayer:refreshRemainCount()
    local playerMy = self:getParent()
	assert(playerMy ~= nil)
	Log.d("PlayerMyUI:ui_getTheNewMj",mj)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
    if #myCards >= 14 then
        for i = 14, #myCards do
            table.remove(myCards,#myCards)
        end
    end
    --如果有新牌过来先检测最后一张牌是否是最大的   如果不是直接插入  防止两张牌同时过来的情况

	self.m_newMj = Mj.new(mj, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	self.m_newMj:setOpacity(200)
	self.m_newMj:setPosition(cc.p(myCards[#myCards]:getPositionX() + 100, Define.g_pai_y ))
	self.m_newMj:addTo(self)
	self.m_newMj:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.EaseBounceOut:create(cc.MoveTo:create(0.2, cc.p(self.m_newMj:getPositionX(), Define.g_pai_y)))))

	self.m_newMj:retain()
	table.insert(myCards, self.m_newMj)
	-- 叫牌结束后
    if self._m_bIsAutoPlay then
		return
	end
    MjProxy:getInstance():setIsAction(false)
    playerMy.m_actionPG = false
end

function PlayerMyUI:ui_gameEndMingPai(closeCards, card)
	Log.i("PlayerMyUI:ui_gameEndMingPai closeCards=", closeCards)
    CommonSound.playSound("tuipai")
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	for k, v in ipairs(myCards) do
		v:removeFromParent()
		v = nil
	end
	myCards = nil

	local actionPaiWidth = Define.g_pai_peng_space *MjProxy:getInstance()._players[Define.site_self]:getActionTimes()
	local closeMjs = {}
	for i = 0, #closeCards -1 do
		local mj = Mj.new(closeCards[i +1], Mj._EType.e_type_normal, Mj._ESide.e_side_self)
		mj:setPosition(cc.p(Define.g_pai_start_x + i * Define.g_pai_width + actionPaiWidth , Define.g_pai_y))
		self:addChild(mj)
		closeMjs[i+1] = mj
	end	
    local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
    -- 把牌拿到手上
	if card ~= 0 and winnerSite == Define.site_self 
		and MjProxy:getInstance()._gameOverData.winType == 2 then
		local  lastCard = Mj.new(card, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
		lastCard:setOpacity(200)
		lastCard:setPosition(cc.p(closeMjs[#closeMjs]:getPositionX() + 85, Define.g_pai_y ))
		lastCard:addTo(self)
	end

end

function PlayerMyUI:ui_playeMajiang(mj)
	Log.i("PlayerMyUI:ui_playeMajiang")
	-- local playLayer = require "mj.mediator.game.PlayLayer"
	local playLayer = self:getParent():getParent()
	assert(playLayer ~= nil)
	playLayer:removeActionNode()
	
	if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() == false 
	and MjProxy:getInstance()._players[Define.site_self]:getHasClickTing() == true then
		WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_ting, 1, mj, { mj })
		Log.i("PlayerMyUI:ui_playeMajiang ting")

		local myCards = MjProxy:getInstance()._players[Define.site_self].cards
		assert(myCards ~= nil)
		for k, v in ipairs(myCards) do
			v:setMjState(Mj._EState.e_state_touch_invalid)
		end
		MjProxy:getInstance()._players[Define.site_self]:setHasSendTing(true)
		playLayer:removeBuTing()
		return
	end

	playLayer:playerSound(MjProxy.getInstance()._players[Define.site_self]:getSex(), mj)

	WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_turnOut, mj)
end

function PlayerMyUI:ui_autoPlayMj(mj)
	self:ui_playeMajiang(mj)

	assert(self.m_newMj ~= nil)
	WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 1, self.m_newMj:getPositionX(), self.m_newMj:getPositionY(), self.m_newMj._value)

	self.m_newMj:removeFromParent()
	self.m_newMj = nil

	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	table.remove(myCards, #myCards)
end

function PlayerMyUI:ui_playSomeMj(mj)
	self:ui_playeMajiang(mj)

	local myCards = MjProxy:getInstance().MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)

	local index = -1
	for i = 1, #myCards do
		local node = myCards[i]
		if node._value == mj then
			WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 1, node:getPositionX(), node:getPositionY(), node._value)
			node:removeFromParent()
			node = nil
			index = i
			break
		end
	end

	if index ~= -1 then
		table.remove(myCards, index)
	end

	table.sort(myCards, function(a, b)
		return a:getSortValue() < b:getSortValue()
	end )
    
	self:ui_drawAllMajiangAgain()
end

function PlayerMyUI:ui_playMjAction(mj)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)

	local index = -1
	for i = 0, #myCards - 1 do
		local node = myCards[i + 1]
		if node._value == mj then
			index = i
			break
		end
	end

	if index ~= -1 then
		local node = myCards[index + 1]
		WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 1, node:getPositionX(), node:getPositionY(), node._value)
		self.m_outMjPositionX = node:getPositionX()
		node:removeFromParent()
		node = nil
        Log.i("ui_playMjAction")
		self:ui_reflash(index)
	end
end

function PlayerMyUI:ui_reflash(mjOutIndex)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	assert(#myCards ~= 0 and mjOutIndex <= #myCards - 1)
	-------- 如果是在回放状态的调用另一个获得麻将接口---------
    if VideotapeManager.getInstance():isPlayingVideo() and VideotapeManager:getInstance():isSpeedVideo() then
        table.remove(myCards, mjOutIndex + 1)
        table.sort(myCards,function(a,b) if a == nil or b == nil then return end return a:getSortValue() < b:getSortValue() end)
        local actionPaiWidth = Define.g_pai_peng_space *MjProxy:getInstance()._players[Define.site_self]:getActionTimes() 
        local newPaiMoveX = 0
        local newPaiMoveY = 0
        for i=1,#myCards do 
            local mj = myCards[i]
            mj:setPosition(Define.g_pai_start_x + (i-1) * Define.g_pai_width + actionPaiWidth , Define.g_pai_y)
        end
        return
    end
    -----------------------------------------------------------
	local playLayer = self:getParent():getParent()
	assert(playLayer ~= nil)
	self.m_newMj = self.m_newMj or nil
	if self.m_newMj == nil then
		Log.i("没有新叫牌")
		table.remove(myCards, mjOutIndex + 1)
		playLayer:deleteDragingMj()
		for i = mjOutIndex, #myCards - 1 do
			local mj = myCards[i + 1]
			mj:runAction(cc.MoveTo:create(0.2, cc.p(mj:getPositionX() - Define.g_pai_width, mj:getPositionY())))
		end
		-- 如果有新叫牌	
	else
		Log.i("有新叫牌")
		if mjOutIndex == #myCards - 1 then
			Log.i("打出的是新叫的牌")
			self.m_newMj:removeFromParent()
			self.m_newMj = nil
			table.remove(myCards, mjOutIndex + 1)
		else
			Log.i("打出的不是新叫的牌")
			playLayer:deleteDragingMj()
			local node = myCards[mjOutIndex + 1]
			local outMjX = node:getPositionX()
			table.remove(myCards, mjOutIndex + 1)
			local tempNew = Mj.new(self.m_newMj._value, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
			tempNew:setPosition(cc.p(myCards[#myCards]:getPositionX() + 85, Define.g_pai_y)):addTo(self)            
			if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() then
				tempNew:setMjState(Mj._EState.e_state_touch_invalid)
			end
			self.m_newMj:removeFromParent()
			self.m_newMj = nil
			table.remove(myCards, #myCards)
			if #myCards == 0 then
				tempNew:runAction(cc.MoveTo:create(0.2, cc.p(outMjX, tempNew:getPositionY())))
				tempNew:retain()
				table.insert(myCards, tempNew)
				return
			end

			if tempNew:getSortValue() >= myCards[#myCards]:getSortValue() and tempNew._value ~= MjProxy:getInstance():getLaizi() then
				Log.i("新叫的牌最大, 直接挪牌，不用插入")
				local pointX, pointY = myCards[#myCards]:getPosition()
				if mjOutIndex == #myCards then
                    Log.i("直接挪牌...........",myCards)
					tempNew:runAction(cc.MoveTo:create(0.2, cc.p(pointX + Define.g_pai_width, pointY)))
				else
					for i = mjOutIndex, #myCards - 1 do
						local mj = myCards[i + 1]
						mj:runAction(cc.MoveTo:create(0.2, cc.p(mj:getPositionX() - Define.g_pai_width, mj:getPositionY())))
					end
					tempNew:runAction(cc.MoveTo:create(0.2, cc.p(pointX, pointY)))
				end

				tempNew:retain()
				table.insert(myCards, tempNew)
			else
				Log.i("需要插入和挪牌")
				for i = 0, #myCards - 1 do
					local mj = myCards[i + 1]
					if tempNew:getSortValue() < mj:getSortValue() then
						self.m_newPaiIndex = i
						break
					end
				end
                table.insert(myCards, tempNew)
				if self.m_newPaiIndex == mjOutIndex then
					Log.i("self.m_newPaiIndex == mjOutIndex")
					self.m_newPaiMovePositionX = self.m_outMjPositionX
				elseif self.m_newPaiIndex < mjOutIndex then
					Log.i("self.m_newPaiIndex < mjOutIndex")
					self.m_newPaiMovePositionX = myCards[self.m_newPaiIndex + 1]:getPositionX()
					assert(mjOutIndex - 1 >= 0)
					for i = self.m_newPaiIndex, mjOutIndex - 1 do
						local mj = myCards[i + 1]
						mj:runAction(cc.MoveTo:create(0.2, cc.p(mj:getPositionX() + Define.g_pai_width, mj:getPositionY())))
					end
				else
					Log.i("self.m_newPaiIndex > mjOutIndex")
					self.m_newPaiMovePositionX = myCards[self.m_newPaiIndex + 1]:getPositionX() - Define.g_pai_width
					assert(self.m_newPaiIndex - 1 >= 0)

					for i = mjOutIndex, self.m_newPaiIndex - 1 do
						local mj = myCards[i + 1]
						mj:runAction(cc.MoveTo:create(0.2, cc.p(mj:getPositionX() - Define.g_pai_width, mj:getPositionY())))
					end
				end
				tempNew:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(tempNew:getPositionX(), tempNew:getPositionY() + 50)),
				cc.DelayTime:create(0.1),
				cc.MoveTo:create(0.3, cc.p(self.m_newPaiMovePositionX, tempNew:getPositionY() + 50)),
				cc.DelayTime:create(0.2),
				cc.MoveTo:create(0.2, cc.p(self.m_newPaiMovePositionX, tempNew:getPositionY()))))
				tempNew:retain()
				table.insert(myCards, self.m_newPaiIndex + 1, tempNew)
                table.remove(myCards,#myCards)
			end
		end
	end
end

function PlayerMyUI:ui_MJ_reflash(mjOutIndex)
    if mjOutIndex == 1 or self.m_newMj == nil then
        Log.i("手上只有一张牌不需要调换位置")
        return
    end
    Log.i("mjOutIndex.....",mjOutIndex)
    local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
    assert(#myCards ~= 0)
    -------- 如果是在回放状态的调用另一个获得麻将接口---------
    if VideotapeManager.getInstance():isPlayingVideo() and VideotapeManager:getInstance():isSpeedVideo() then
        table.sort(myCards,function(a,b) if a == nil or b == nil then return end return a:getSortValue() < b:getSortValue() end)
        local actionPaiWidth = Define.g_pai_peng_space *MjProxy:getInstance()._players[Define.site_self]:getActionTimes() 
        local newPaiMoveX = 0
        local newPaiMoveY = 0
        for i=1,#myCards do 
            local mj = myCards[i]
            mj:setPosition(Define.g_pai_start_x + (i-1) * Define.g_pai_width + actionPaiWidth , Define.g_pai_y)
        end
        return
    end
    -----------------------------------------------------------
    local s_card = #myCards
    local tempNew = self.m_newMj
    local mjNewRef = Mj.new(self.m_newMj._value, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	mjNewRef:setPosition(cc.p(self.m_newMj:getPosition())):addTo(self)

    if mjOutIndex > s_card or tempNew == nil then
        return
    end
    Log.i("s_card.......",s_card,"self.m_newMj..",self.m_newMj._value)
    Log.d("需要插入的牌...",mjOutIndex,"s_card...",s_card,"#myCards",#myCards,"tempNew...",tempNew._value)
   
        Log.i("需要插入和挪牌",mjOutIndex)
        local newPaiIndex = 0
        local moveIndex = mjOutIndex -1
        for j=1,#myCards do
            local mj = myCards[j]
            Log.i("tempNew:getSortValue()....",tempNew:getSortValue(),"mj:getSortValue()....",mj:getSortValue())
            if tempNew:getSortValue() <= mj:getSortValue() then
                newPaiIndex = j
                break
            end
        end
        table.sort(myCards,function(a,b) if a == nil or b == nil then return end return a:getSortValue() < b:getSortValue() end)

        local actionPaiWidth = Define.g_pai_peng_space *MjProxy:getInstance()._players[Define.site_self]:getActionTimes()
        local newCarde = nil
        local newPaiMoveX = 0
        local newPaiMoveY = 0
	    for i = #myCards,1,-1 do
		    local mj = myCards[i]
            if mj == nil then
                Log.i("麻将为空的了。。。。",i,#myCards)
                return
            end
            Log.i("剩下的牌...",mj._value,Define.g_pai_start_x + (i-1) * Define.g_pai_width + actionPaiWidth ,i)
            if i > newPaiIndex and mjOutIndex < mjOutIndex then
                mj:runAction(cc.MoveTo:create(0.2,cc.p(mj:getPositionX() + Define.g_pai_width , Define.g_pai_y)))
            else
                mj:setPosition(Define.g_pai_start_x + (i-1) * Define.g_pai_width + actionPaiWidth , Define.g_pai_y)
            end
            if i == newPaiIndex then
                mj:setVisible(false)
                newCarde = mj
                newPaiMoveX = Define.g_pai_start_x + (i-1) * Define.g_pai_width + actionPaiWidth
            end
        end
        
        mjNewRef:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(mjNewRef:getPositionX(), Define.g_pai_y + 60)),
        cc.DelayTime:create(0.05),
		cc.MoveTo:create(0.2, cc.p(newPaiMoveX, Define.g_pai_y + 60)),
        cc.DelayTime:create(0.05),
		cc.MoveTo:create(0.1, cc.p(newPaiMoveX, Define.g_pai_y)),cc.CallFunc:create(function ()
            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
            mjNewRef:removeFromParent()
            if newCarde ~= nil then
                newCarde:setVisible(true)
            end
        end)))
end

function PlayerMyUI:ui_drawActionMj(actiondata,actionType, mjs, recoveryHasAddGang, userId, actionCard)
	local mj = mjs[1]

    Log.d("牌型：","actionType:"..actionType.."..mJ:" ..mj)
	recoveryHasAddGang = recoveryHasAddGang or false
	if actionType == Define.action_jiaGang and recoveryHasAddGang == true then
		actionType = Define.action_mingGang
	end
    if actionType == Define.action_chi or actionType == Define.action_peng then
		self:ui_drawActionThree(actiondata,mjs, actionType, userId, actionCard)
	elseif actionType == Define.action_mingGang or actionType == Define.action_anGang then
		self:ui_drawActionFour(actiondata,mjs, actionType, userId)
	end
	if actionType == Define.action_jiaGang and recoveryHasAddGang == false then
		local actionNode = self:getChildByTag(150 + mj)
		if actionNode then
			local node = Mj.new(mj, Mj._EType.e_type_action_tang,Mj._ESide.e_side_self)
			node:addTo(self)
            local lastPlayerIndex = 1
            local yPre = 8
            local xPre = 5
            local threeArray = self:getActionThreeArray()
            if threeArray == nil or #threeArray == 0 then
                Log.i("没有碰牌不能加杠")
                return
            end
            for i,v in pairs(threeArray) do
                if mj == v.mj then
                    lastPlayerIndex = v.playerIndex
                end
            end
            if lastPlayerIndex == 2 then
            	node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + Define.g_action_tang_pai_height + yPre))
            elseif lastPlayerIndex == 3 then
            	node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + Define.g_action_tang_pai_height + yPre))
            else
            	node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + Define.g_action_tang_pai_height + yPre))
            end
			-- 记录结算操作数据
            for i=1, #MjProxy:getInstance()._players[Define.site_self].m_arrMyActionType do
            	if MjProxy:getInstance()._players[Define.site_self].m_arrMyActionType[i] == Define.action_peng then
            		if MjProxy:getInstance()._players[Define.site_self].m_arrMyActionMj[i][1] == mj then
						MjProxy:getInstance()._players[Define.site_self].m_arrMyActionType[i] = actionType
						MjProxy:getInstance()._players[Define.site_self].m_arrMyActionMj[i] = {mj, mj, mj, mj}
            		end
            	end
            end
            node:setAnchorPoint(cc.p(-0.5, 0))
		end
		return
	end
	if actionType == Define.action_chi then
		mj = mj + 100
	end

	assert(type(MjProxy:getInstance()._players[Define.site_self].m_arrMyActionMj) == "table")
	assert(type(MjProxy:getInstance()._players[Define.site_self].m_arrMyActionType) == "table")
	local lastPlayerIndex = 0
	if userId == nil then
        lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._actionData.lastPlayUserId)
    else
        lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(userId)
    end
    if actionType ~= Define.action_buhua and actionType ~= Define.action_jiaGang then
        Log.i("PlayerMyUI添加动作牌....",cards)
	    table.insert(MjProxy:getInstance()._players[Define.site_self].m_arrMyActionMj, mjs)
	    table.insert(MjProxy:getInstance()._players[Define.site_self].m_arrMyActionType, actionType)
	   	table.insert(MjProxy:getInstance()._players[Define.site_self].m_arrLastPlayerIndexs, lastPlayerIndex)
    end

end

function PlayerMyUI:getChiActionIndex(cards, actionCard)
	local lastPlayerIndex = 2
	for i=1, #cards do
		if actionCard == cards[1] then
			lastPlayerIndex = 4
		elseif actionCard == cards[2] then
			lastPlayerIndex = 3
		elseif actionCard == cards[3] then
			lastPlayerIndex = 2
		end
	end
	return lastPlayerIndex
end

function PlayerMyUI:ui_drawActionThree(actiondata, mjs, actionType, userId, actionCard)
    print("PlayerMyUI:ui_drawActionThree")
	local lastPlayerIndex = 0
    if userId == nil then
       lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(actiondata.lastPlayUserId)
       if actionType == Define.action_chi then
       		local cbCards = actiondata.cbCards
       		lastPlayerIndex = self:getChiActionIndex(cbCards, actiondata.actionCard )
       end
    else
       lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(userId)
       if actionType == Define.action_chi then
       		if actionCard and actionCard ~=0 then
       			lastPlayerIndex = self:getChiActionIndex(mjs, actionCard )
       		end
       end
    end
    if lastPlayerIndex == 1 then
   		lastPlayerIndex = 2
    end    
     Log.i("PlayerMyUI:drawActionThree lastPlayerIndex=", lastPlayerIndex)

	local gangTimes = MjProxy:getInstance()._players[Define.site_self]:getGangTimes()
	local actionTimes = MjProxy:getInstance()._players[Define.site_self]:getActionTimes() -gangTimes
--	if actionTimes < 0 then
--		actionTimes = 0
--	end
	local actionPaiWidth = Define.g_pai_peng_space *actionTimes + Define.g_pai_peng_space*(gangTimes-1)
    
	for i = 0, 2 do
		local node = nil
		local yPre = 7
        local xPre = 2
        local xOffer = 1
	    local mj = mjs[1]
		if actionType == Define.action_chi then
			mj = mjs[i+1]
		end
		if lastPlayerIndex == 2 then --下家
			if i == 2 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x + 2*Define.g_action_pai_width  + actionPaiWidth+xOffer, Define.g_action_pai_y - yPre))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x + i * Define.g_action_pai_width + actionPaiWidth, Define.g_action_pai_y))
			end
		elseif lastPlayerIndex == 3 then --对家
			if i == 1 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x +Define.g_action_pai_width  + actionPaiWidth+xOffer, Define.g_action_pai_y - yPre))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			elseif i == 0 then
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x  + actionPaiWidth, Define.g_action_pai_y))

			elseif i == 2 then
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x +  Define.g_action_pai_width + Define.g_action_tang_pai_width + actionPaiWidth-xPre, Define.g_action_pai_y))
			end			
		elseif lastPlayerIndex == 4 then --上家 
			if i == 0 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x + i*Define.g_action_pai_width  + actionPaiWidth, Define.g_action_pai_y - yPre))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
				node:setPosition(cc.p(Define.g_action_pai_x + (i -1)* Define.g_action_pai_width + Define.g_action_tang_pai_width + actionPaiWidth-xPre, Define.g_action_pai_y))
			end			
		end
		self:addChild(node,2)
		node:setAnchorPoint(cc.p(-0.5, 0))
	end
    local threeArray = {}
    threeArray.mj = mjs[1]
    threeArray.playerIndex = lastPlayerIndex
    self:setActionThreeArray(threeArray)
end

function PlayerMyUI:setActionThreeArray(mjArray)
    if self._actionThreeArray == nil then
        self._actionThreeArray = {}
    end
    self._actionThreeArray[#self._actionThreeArray +1] = mjArray
end
function PlayerMyUI:getActionThreeArray()
    return self._actionThreeArray or {}
end

function PlayerMyUI:ui_drawActionThreeGang(actiondata,mj, actionType)
	Log.i("PlayerMyUI:ui_drawActionThreeGang ")
	local gangTimes = MjProxy:getInstance()._players[Define.site_self]:getGangTimes() -1
	local actionTimes = MjProxy:getInstance()._players[Define.site_self]:getActionTimes() -MjProxy:getInstance()._players[Define.site_self]:getGangTimes()
	if actionTimes < 0 then
		actionTimes = 0
	end
	local actionPaiWidth = Define.g_pai_peng_space *actionTimes + Define.g_pai_peng_space*gangTimes


	for i = 0, 2 do
		local node = nil
		if actionType == Define.action_anGang then
			node = display.newSprite("#self_gang_poker.png")
			node:setAnchorPoint(cc.p(0, 0.5))
		else
			node = Mj.new(mj, Mj._EType.e_type_action,Mj._ESide.e_side_self)
			node:setAnchorPoint(cc.p(-0.5, 0))
		end

		node:setPosition(cc.p(Define.g_action_pai_x + i * Define.g_action_pai_width + actionPaiWidth, Define.g_action_pai_y))
		self:addChild(node,2)

		if i == 1 and(actionType == Define.action_peng or actionType == Define.action_mingGang
			or actionType == Define.action_anGang or actionType == Define.action_jiaGang) then
			node:setTag(150 + mj)
		end

		if actionType == Define.action_chi then
			mj = mj + 1
		end
	end
end

function PlayerMyUI:ui_drawActionFour(actiondata,mjs, actionType,userId)
	Log.i("PlayerMyUI:ui_drawActionFour")
	local mj = mjs[1]
	if actionType == Define.action_anGang then
        self:ui_drawActionThreeGang(actiondata,mj, actionType)
    elseif actionType == Define.action_mingGang then
        self:ui_drawActionThree(actiondata,mjs,Define.action_mingGang,userId)
    end
	local actionNode = self:getChildByTag(150 + mj)
	if actionNode then
		local node = nil
		if actionType == Define.action_anGang then
            node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
            node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + 10))
            node:addTo(self,3)
		else
            local yPre = 8
            -- 添加最后一个杠躺着的牌
            node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
            node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + Define.g_action_tang_pai_height + yPre))
            node:addTo(self, actionNode:getLocalZOrder() - 1)
		end		
        node:setAnchorPoint(cc.p(-0.5, 0))   
	else
		Log.i("drawActionThree 没找到 %d 的tag值", mj)
	end
end

function PlayerMyUI:ui_drawAllMajiangAgain()
	self:ui_removeAllMj()
	self:ui_drawAllMj()
end

function PlayerMyUI:ui_removeAllMj()
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	for k, v in ipairs(myCards) do
		v:removeFromParent()
		v = nil
	end
end

function PlayerMyUI:ui_drawAllMj()
    Log.i("PlayerMyUI:ui_drawAllMj..... table.sort")
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	local sortFunc2 = function(a, b) 
         return a:getSortValue() < b:getSortValue()
    end
    self.m_newMj = nil
    table.sort(myCards, sortFunc2)
    local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
    local dispenseCard = MjProxy:getInstance()._gameStartData.dispenseCard

    -- if dispenseCard ~= nil 
    -- 	and dispenseCard ~= 0 
    -- 	and #MjProxy:getInstance()._gameStartData.actions <= 0 then
     if MjMediator:getInstance():isCanPlayCard() == enHandCardRemainder.CAN_PLAY then     
        for i,v in pairs(myCards) do
            if v._value == dispenseCard then
                myCards[#myCards+1] = v
                -- 将发的牌给到作为新牌处理
                self.m_newMj = v 
                table.remove(myCards,i)
                break
            end
        end
    end
    MjProxy:getInstance()._gameStartData.dispenseCard = 0
    Log.i("myCards的数量",#myCards)
    local actionPaiWidth = Define.g_pai_peng_space *MjProxy:getInstance()._players[Define.site_self]:getActionTimes()
	for i = 0, #myCards - 1 do
		local mj = myCards[i + 1]
        Log.i("剩下的牌...",mj._value)
        local mjX = 0
        -- if i == #myCards-1 
        -- 	and dispenseCard ~= nil 
        -- 	and dispenseCard ~= 0
        -- 	and #MjProxy:getInstance()._gameStartData.actions <= 0 then
       	 if self.m_newMj 
        	and i == #myCards-1 then  
            mjX = 15
        end
		mj:setPosition(cc.p(  Define.g_pai_start_x + i * Define.g_pai_width + actionPaiWidth + mjX , Define.g_pai_y))
		self:addChild(mj)
	end
end

return PlayerMyUI