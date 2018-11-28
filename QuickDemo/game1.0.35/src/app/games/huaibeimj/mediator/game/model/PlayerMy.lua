-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion


local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local ActionList = require "app.games.huaibeimj.mediator.game.model.ActionList"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local PlayerMyUI = require ("app.games.huaibeimj.mediator.game.model.PlayerMyUI")
local Robot = require ("app.games.huaibeimj.mediator.game.model.Robot")
local MJArmatureCSB = require("app.games.huaibeimj.custom.MJArmatureCSB")
local PlayerMy = class("PlayerMy", function ()
	return display.newNode()
end)

function PlayerMy:ctor(isResume)
	Log.i("PlayerMy:ctor")

	self._ui = PlayerMyUI.new()
	self._ui:addTo(self)

	local closeCard = { }
    local dispenseCard = nil
	if isResume == true then
		local resumeData = MjProxy:getInstance()._gameStartData
		assert(resumeData ~= nil and resumeData.t_closeCards ~= nil and MjProxy:getInstance()._players[Define.site_self] ~= nil)
		closeCard = resumeData.t_closeCards
        dispenseCard = resumeData.dispenseCard
	else
		local gameData = MjProxy:getInstance()._gameStartData
		assert(gameData ~= nil and gameData.t_closeCards ~= nil and MjProxy:getInstance()._players[Define.site_self] ~= nil)
		closeCard = gameData.t_closeCards
	end

    local sortFunc = function(a, b) 
         return a < b
    end
    table.sort(closeCard, sortFunc)

	local t = { }
	for k, v in ipairs(closeCard) do
		local mj = Mj.new(v, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
		mj:retain()
		-- 需要手动release
		t[#t + 1] = mj
        if isResume == true and dispenseCard ~= nil and dispenseCard ~= 0  then
            if v == dispenseCard then
                self._ui.m_newMj = mj
            end
        end
	end


    local sortFunc2 = function(a, b) 
         return a:getSortValue() < b:getSortValue()
    end

    table.sort(t, sortFunc2)
	for k, v in ipairs(t) do
		Log.i("PlayerMy:ctor 打印手牌: %s", tostring(v._value))
	end
	MjProxy:getInstance()._players[Define.site_self].cards = t
	self._m_bIsAutoPlay = false
    
    self._isDispenseCard = false
end

function PlayerMy:playMjAction(mj)
	self._ui:ui_playMjAction(mj)
end

function PlayerMy:distrMj()
	self._ui:ui_distrMj()
end

function PlayerMy:getTheNewMj(mj)
	self._ui:ui_drawNewMj(mj)
end

-- 摸到新牌后
function PlayerMy:onJiaoPaiEnd(mj)
    Log.i("PlayerMy:onJiaoPaiEnd....")
	local playCardData = MjProxy:getInstance()._playCardData
	assert(playCardData ~= nil)
	-- Log.i("PlayerMy:onJiaoPaiEnd打印数据", playCardData)

	local playLayer = self:getParent()
	assert(playLayer ~= nil)

	MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)

	local actions = playCardData.actions
    if actions == nil then
        return
    end 
    for i,v in pairs(actions) do
        if v == Define.action_buhua then
            return
        end
    end
	if #actions == 0 then
		if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
				return self:autoPlayMj(mj)
			end )))
		else
		
		end
	else
		if self._m_bIsAutoPlay then
--            local actionCard = playCardData.doorcard
--	        if actionCard == 0 then
--		        actionCard = playCardData.playCard
--	        end
--            WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, actions[1], 0, actionCard)
			return
		end
	    -- local  needSubstitute = false
	    -- if data.playedbyID == MjProxy:getInstance()._players[Define.site_left]:getUserId() then
	    --     needSubstitute = true
	    -- end
	    -- local clock = self._bgLayer._clock
	    -- clock:setNeedSubstitute(needSubstitute)

		if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() then
			if #actions <= 0 then
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
					return self:autoPlayMj(mj)
				end )))
			else
				Log.d("PlayerMy:onJiaoPaiEnd 已经发送听 actions=", actions)
				local isShowAction = false
				for k, v in ipairs(actions) do
					if v == Define.action_dianPaoHu or v == Define.action_ziMoHu or v == Define.action_mingGang or v == Define.action_anGang or v == Define.action_jiaGang then
						isShowAction = true
						break
					end
				end
				local actionCard = playCardData.doorcard
				if actionCard == 0 then
					actionCard = playCardData.playCard
				end
				if isShowAction == false then
					WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, actions[1], 0, actionCard)
				else

					local needActions = {}
					for i=1,#actions do
						local v = actions[i]
						if v == Define.action_dianPaoHu or v == Define.action_ziMoHu or v == Define.action_mingGang or v == Define.action_anGang or v == Define.action_jiaGang then
							needActions[#needActions + 1] = v
						end
					end
		            Log.d("PlayerMy:onJiaoPaiEnd 已经发送听 needActions=", needActions)

					-- local actionList = ActionList.new(needActions, playCardData)
					-- playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
					 ---------------- 录像回放相关-----------------------------------------
		            if VideotapeManager.getInstance():isPlayingVideo() then 

		            else
		            	local actionList = ActionList.new(needActions, playCardData)
						-- actionList:setPosition(cc.p(0, 180))
						playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)   	
		            end  
   					---------------------------------------------------------------------		
				end
			end
		else
            Log.i("PlayerMy:onJiaoPaiEnd...")
	        local isCanOutMj = false
			for i=1,#actions do
				if actions[i]  == Define.action_ting or actions[i] == Define.action_jiaGang or actions[i] == Define.action_anGang or actions[i] == Define.action_ziMoHu then 
	                isCanOutMj = true
	                break
				end
			end
	        playLayer:setPlayerTouchEnabled(isCanOutMj)
			-- local actionList = ActionList.new(actions, playCardData)
			-- playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
			---------------- 录像回放相关-----------------------------------------
            if VideotapeManager.getInstance():isPlayingVideo() then 

            else
            	local actionList = ActionList.new(actions, playCardData)
				playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action) 	
            end  
			---------------------------------------------------------------------		
		end
	end

end

function PlayerMy:setAutoPlay(bResult)
	assert(type(bResult) == "boolean")

	local playLayer = self:getParent()
	assert(playLayer ~= nil)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)

	if self._m_bIsAutoPlay == bResult then
		return
	end
    if bResult then
        --屏蔽托管
        return
    end
	self._m_bIsAutoPlay = bResult
    
	if bResult then
		Log.i("本家收到托管消息")
		playLayer:setPlayerTouchEnabled(false)
		playLayer:removeActionNode()
		-- playLayer:removeTingQuery()
		-- playLayer:removeCardsChange()

		if MjProxy:getInstance()._players[Define.site_self]:getHasClickTing() and MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() == false then
		MjProxy:getInstance()._players[Define.site_self]:setHasClickTing(false)
			for k, v in ipairs(myCards) do
				v:setMjState(Mj._EState.e_state_touch_valid)
			end
			playLayer:removeBuTing()
		end
		-- 显示托管界面
		local robot = self:getParent().m_RobotNode
		if robot then
			self:getParent().m_RobotNode:removeFromParent()
			self:getParent().m_RobotNode = nil
		end
		self:getParent().m_RobotNode = Robot.new()
        self:getParent().m_RobotNode:setAnchorPoint(0.5,0.5)
		self:getParent():addChild(self:getParent().m_RobotNode, Define.e_zorder_player_layer_substitute)
	else
		Log.i("本家收到取消托管消息")
		-- local playData = MjProxy:getInstance()._playCardData
		-- if playData then
		-- 	if playData.nextplayerID == MjProxy:getInstance():getMyUserId() then
		-- 		if #playData.actions > 0 then
		-- 			local card = playData.doorcard
		-- 			if card == 0 then
		-- 				card = playData.playCard
		-- 			end

		-- 			-- 取消托管有操作，点过
		-- 			WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, playData.actions[1], 0, card)
		-- 		end
		-- 	end
		-- end
		playLayer:setPlayerTouchEnabled(true)
		-- 隐藏托管界面
		local robot = self:getParent().m_RobotNode
		if robot then
			self:getParent().m_RobotNode:removeFromParent()
			self:getParent().m_RobotNode = nil
		end
	end

end

function PlayerMy:autoPlayMj(mj)
	self._ui:ui_autoPlayMj(mj)
end

function PlayerMy:handleMyAction(data)
	Log.i("PlayerMy:handleMyAction")
	Log.d( "本家处理操作的数据",data)

	------------------- 视频回放功能--------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:handleVideoMyAction(data)
		return 
	end
	----------------------------------------------
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
    Log.d("myCards...",#myCards)
--	local data = MjProxy:getInstance()._actionData
	local actionCard = data.cbCards[1]

	local cards = data.cbCards
    local action = nil
    local playLayer = self:getParent()
    self.m_actionPG = false
	-- 听
	if data.actionID == Define.action_ting then
		
        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_self)
        Sound.effect_ting(MjProxy.getInstance()._players[Define.site_self]:getSex())

	elseif data.actionID == Define.action_chi then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_chi, gameAnimate.player.my, self:getParent())
        Sound.effect_chi(MjProxy.getInstance()._players[Define.site_self]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_self)
		for k, v in ipairs(cards) do
			while true do
				if v == actionCard then break end

				for i = 1, #myCards do
					local mj = myCards[i]
					if mj._value == v then
						mj:removeFromParent()
						mj = nil

						table.remove(myCards, i)
						break
					end
				end

				break
			end
		end

		self._ui:ui_drawActionMj(data,Define.action_chi, cards)
		self._ui:ui_drawAllMajiangAgain()

		-- 碰	
	elseif data.actionID == Define.action_peng then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_peng, gameAnimate.player.my, self:getParent())
        Sound.effect_peng(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_self)
		local pengone = 0

        local function removeCard()
            for i = 1, #myCards do
	            local node = myCards[i]
	            if node._value == actionCard then
                    Log.d("node._value...",node._value)
                    if i == #myCards then
                        Log.i("碰的牌是最新的牌")
                        self._ui.m_newMj = nil
                    end
		            node:removeFromParent()
		            node = nil
    		        table.remove(myCards, i)
		            pengone = pengone+1
                    if pengone == 2 then
			            break
                    else
                        removeCard()
                        break
                    end
	            end
            end
        end
        removeCard()
        self.m_actionPG = true
		self._ui:ui_drawActionMj(data,Define.action_peng, cards)
		self._ui:ui_drawAllMajiangAgain()

		-- 明杠
	elseif data.actionID == Define.action_mingGang then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
        Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		local gang = -1
		local num = 0
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				num = num + 1
			end
		end

		if num ~= 3 then
			return
		end
        local function removeCard()
            for i = 1, #myCards do
			    local node = myCards[i]
			    if node._value == actionCard then
				    node:removeFromParent()
				    node = nil
                    table.remove(myCards, i)
                    removeCard()
				    break
			    end
		    end
        end
        removeCard()
--		for i = 0, 1 do
--			if gang >= #myCards then
--				return
--			end

--			local node = myCards[gang + 1]
--			node:removeFromParent()
--			node = nil
--			table.remove(myCards, gang + 1)
--		end
        self.m_actionPG = true
		self._ui:ui_drawActionMj(data,Define.action_mingGang, cards)
		self._ui:ui_drawAllMajiangAgain()

		-- 加杠
	elseif data.actionID == Define.action_jiaGang then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
        Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				break
			end
		end

		self._ui:ui_drawActionMj(data,Define.action_jiaGang, cards)
		table.sort(myCards, function(a, b)
			return a:getSortValue() < b:getSortValue()
		end )
        self.m_actionPG = true
		self._ui:ui_drawAllMajiangAgain()

		-- 暗杠
	elseif data.actionID == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
        Log.i("暗杠牌...",actionCard)
		local gang = -1
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				gang = i
                Log.i("删除这张牌,....",gang,#myCards)
				break
			end
		end

		if gang == -1 then
			return
		end

        -- if actionCard == 41 or actionCard >=45 then
        --     Log.i("杠牌后移动花牌")
        --     self._ui.m_newMj = myCards[#myCards]
        --     self._ui:ui_MJ_reflash(#myCards)
        --     return
        -- end

		for i = 0, 1 do
			local node = myCards[gang + 1]
			node:removeFromParent()
			node = nil
			table.remove(myCards, gang + 1)
		end

		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				break
			end
		end
        self.m_actionPG = true
		self._ui:ui_drawActionMj(data,Define.action_anGang, cards)
--		table.sort(myCards, function(a, b)
--			return a._value < b._value
--		end )
--        for i,v in pairs(myCards) do
--            if v == MjProxy:getInstance():getLaizi() then
--                local laizi = v
--                table.remove(myCards,i)
--                table.insert(myCards,1,laizi)
--            end
--        end
		self._ui:ui_drawAllMajiangAgain()
        
		-- 点炮胡
	elseif data.actionID == Define.action_dianPaoHu then
        Sound.effect_hu(data.actionID, MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._actionData.lastPlayUserId))
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_self)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_myCards_position_y+10)
		if result == 3 then
			-- 加倍

			-- local node = require ("app.games.huaibeimj.mediator.game.model.JiabeiAction").new(true, self:getParent())
			-- self:getParent():addChild(node)
			-- MjProxy:getInstance()._players[Define.site_self]:setRemainDoubleNum(MjProxy:getInstance()._players[Define.site_self]:getRemainDoubleNum() - 1)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 自摸胡
	elseif data.actionID == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_self)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_myCards_position_y+10)
        Sound.effect_hu(data.actionID, MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			-- local node = require ("app.games.huaibeimj.mediator.game.model.JiabeiAction").new(true, self:getParent())
			-- self:getParent():addChild(node)
			-- MjProxy:getInstance()._players[Define.site_self]:setRemainDoubleNum(MjProxy:getInstance()._players[Define.site_self]:getRemainDoubleNum() - 1)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 过
	elseif data.actionID == Define.action_guo then

		-- 换牌
	elseif data.actionID == 27 then
		
	end
end
--打出去的大麻将显示
function PlayerMy:removePutDownMj()
    
end
--打出去的麻将值
function PlayerMy:getPutMjValue()
    return 0
end

function PlayerMy:gameEndMingPai(cards, card )
	self._ui:ui_gameEndMingPai(cards, card)
end


------------------录像回放相关-----------------------------
function PlayerMy:handleVideoMyAction(data)
	Log.i("PlayerMy:handleMyAction")
	Log.i( "本家处理操作的数据",MjProxy:getInstance()._actionData)
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)

--	local data = MjProxy:getInstance()._actionData
	local actionCard = data.cbCards[1]

	local cards = data.cbCards
    local action = nil
    local playLayer = self:getParent()
	-- 听
	if data.actionID == Define.action_ting then
		
        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_self)
        Sound.effect_ting(MjProxy.getInstance()._players[Define.site_self]:getSex())

	elseif data.actionID == Define.action_chi then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_chi, gameAnimate.player.my, self:getParent())
        Sound.effect_chi(MjProxy.getInstance()._players[Define.site_self]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_self)
		for k, v in ipairs(cards) do
			while true do
				if v == actionCard then break end

				for i = 1, #myCards do
					local mj = myCards[i]
					if mj._value == v then
						mj:removeFromParent()
						mj = nil

						table.remove(myCards, i)
						break
					end
				end

				break
			end
		end

		self._ui:ui_drawActionMj(data, Define.action_chi, cards)
		self._ui:ui_drawAllMajiangAgain()

		-- 碰	
	elseif data.actionID == Define.action_peng then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_peng, gameAnimate.player.my, self:getParent())
        Sound.effect_peng(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_self)
		local pengone = -1
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				pengone = i
				break
			end
		end

		if pengone ~= -1 and pengone < #myCards then
			local node = myCards[pengone + 1]
			node:removeFromParent()
			node = nil
			table.remove(myCards, pengone + 1)
		end
        
		self._ui:ui_drawActionMj(data, Define.action_peng, cards)
		self._ui:ui_drawAllMajiangAgain()
		-- 明杠
	elseif data.actionID == Define.action_mingGang then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
        Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		local gang = -1
		local num = 0
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				num = num + 1
			end
		end

		if num ~= 3 then
			return
		end

		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				gang = i
				break
			end
		end

		for i = 0, 1 do
			if gang >= #myCards then
				return
			end

			local node = myCards[gang + 1]
			node:removeFromParent()
			node = nil
			table.remove(myCards, gang + 1)
		end
		self._ui:ui_drawActionMj(data, Define.action_mingGang, cards)
		self._ui:ui_drawAllMajiangAgain()

		-- 加杠
	elseif data.actionID == Define.action_jiaGang then
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
        Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				break
			end
		end

		self._ui:ui_drawActionMj(data, Define.action_jiaGang, cards)
		table.sort(myCards, function(a, b)
			return a:getSortValue() < b:getSortValue()
		end )
		self._ui:ui_drawAllMajiangAgain()

		-- 暗杠
	elseif data.actionID == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_self)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.my, self:getParent())
		local gang = -1
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				gang = i
				break
			end
		end

		if gang == -1 then
			return
		end

		for i = 0, 1 do
			local node = myCards[gang + 1]
			node:removeFromParent()
			node = nil
			table.remove(myCards, gang + 1)
		end

		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			if node._value == actionCard then
				node:removeFromParent()
				node = nil
				table.remove(myCards, i + 1)
				break
			end
		end

		self._ui:ui_drawActionMj(data, Define.action_anGang, cards)
--		table.sort(myCards, function(a, b)
--			return a._value < b._value
--		end )
--        for i,v in pairs(myCards) do
--            if v == MjProxy:getInstance():getLaizi() then
--                local laizi = v
--                table.remove(myCards,i)
--                table.insert(myCards,1,laizi)
--            end
--        end
		self._ui:ui_drawAllMajiangAgain()
        
		-- 点炮胡
	elseif data.actionID == Define.action_dianPaoHu then
        Sound.effect_hu(data.actionID, MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._actionData.lastPlayUserId))
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_self)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_myCards_position_y+10)
		if result == 3 then
			-- 加倍

			-- local node = require ("app.games.xuzhoumj.mediator.game.model.JiabeiAction").new(true, self:getParent())
			-- self:getParent():addChild(node)
			-- MjProxy:getInstance()._players[Define.site_self]:setRemainDoubleNum(MjProxy:getInstance()._players[Define.site_self]:getRemainDoubleNum() - 1)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 自摸胡
	elseif data.actionID == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_self)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_myCards_position_y+10)
        Sound.effect_hu(data.actionID, MjProxy.getInstance()._players[Define.site_self]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			-- local node = require ("app.games.xuzhoumj.mediator.game.model.JiabeiAction").new(true, self:getParent())
			-- self:getParent():addChild(node)
			-- MjProxy:getInstance()._players[Define.site_self]:setRemainDoubleNum(MjProxy:getInstance()._players[Define.site_self]:getRemainDoubleNum() - 1)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 过
	elseif data.actionID == Define.action_guo then

		-- 换牌
	elseif data.actionID == 27 then
		
	end
end
-----------------------------------------------------------

return PlayerMy
