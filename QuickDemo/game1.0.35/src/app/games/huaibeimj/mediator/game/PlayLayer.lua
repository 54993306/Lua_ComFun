-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local timerProxy = require "app.games.huaibeimj.custom.TimerProxy".new()
local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local ActionList = require "app.games.huaibeimj.mediator.game.model.ActionList"
local PlayerMy= require ("app.games.huaibeimj.mediator.game.model.PlayerMy")
local PlayerRight = require ("app.games.huaibeimj.mediator.game.model.PlayerRight")
local PlayerOther =  require ("app.games.huaibeimj.mediator.game.model.PlayerOther")
local PlayerLeft = require ("app.games.huaibeimj.mediator.game.model.PlayerLeft")

local PlayLayer = class("PlayLayer", function ()
	return display.newLayer()
end)

function PlayLayer:ctor(isResume)
	Log.i("PlayLayer:ctor")

	self._isResume = isResume
	self.m_RobotNode = nil --机器人图标
	self._m_bCanTouch = true
	self._m_dragingMj = nil
	self._m_lastSelectMj = nil
	self._m_hasClickOnceMj = nil
	self._m_pListener = nil
	self._m_sec = 5
	self._m_arrChangeCards = { }
	self.m_my_jiabei_node = nil
	self.m_other_jiabei_node = nil
	self.m_tingQueryPositionX = 0
	-- 所有玩家 PlayerMy  PlayerRight PlayerOther PlayerLeft
	self._allPlayers = {}
	self:onEnter()

	-- self:registerScriptHandler( function(event)
	-- 	if "enter" == event then
	-- 		self:onEnter()
	-- 	elseif "exit" == event then
	-- 		self:onExit()
	-- 	end
	-- end )

	-- WWFacade:addCustomEventListener(MJ_EVENT.GAME_delTingQuery, handler(self, self.removeTingQuery))
end

function PlayLayer:onTouchBegan(touch, event)
	Log.i("PlayLayer:onTouchBegan")
	if MjProxy:getInstance():getSubstitute() == true then
		return false
	end

   	Log.i("PlayLayer:onTouchBegan22")
    if MjProxy:getInstance():getBuHua() == true then
        Log.i("在补花中。。。。。")
        return false
    end
	if self._m_bCanTouch == false then
        Log.i("self._m_bCanTouch == false")
		return false
	end
   	Log.i("PlayLayer:onTouchBegan33")

	self._m_bCanTouch = false

	local touchTime = 0.1
	
	local function touchBeganCanTouch()
		self._m_bCanTouch = true
	end
	timerProxy:addTimer("ww_mj_playLayer_onTouchBegan", touchBeganCanTouch, touchTime)

	if self._m_dragingMj then
		self._m_dragingMj:removeFromParent()
		self._m_dragingMj = nil
	end

	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)
	local isClickOutSide = false
	for i = 0, #myCards - 1 do
		local majiang = myCards[i + 1]

		if majiang  then
            if majiang:isContainsTouch(touch:getLocation().x, touch:getLocation().y) then
            	isClickOutSide = true
			    if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() then
				    self.m_tingQueryPositionX = 1280 / 2
				    -- WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, 6, 2, 0)
				    return false
			    end

			    if self._m_lastSelectMj then
				    if majiang ~= self._m_lastSelectMj then
					    self._m_lastSelectMj:setMjState(Mj._EState.e_state_normal)
				    end
			    end

			    if majiang._state == Mj._EState.e_state_touch_invalid then
				    return false
			    end

			    -- if MjProxy:getInstance()._players[Define.site_self]:getHasClickTing() and self._m_lastSelectMj ~= majiang then
				   --  Log.i("点击要打出去的麻将，查听")
				   --  -- 查听
				   --  self.m_tingQueryPositionX = majiang:getPositionX()
				   --  local t = { majiang._value }
				   --  WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, 6, 2, majiang._value, t)
			    -- end
			    majiang:setMjState(Mj._EState.e_state_selected)
			    self._m_lastSelectMj = majiang
			    self._m_lastSelectMj:setTag(i)
			    Log.d("选中麻将 %s", tostring(majiang._value))
            else
--                Log.i("majiang._state...",majiang._state)
 
            end
		end
	end
	if isClickOutSide == false then
		for i = 0, #myCards - 1 do
			local majiang = myCards[i + 1]
			if majiang then
				if majiang._state == Mj._EState.e_state_selected or majiang._state == Mj._EState.e_state_touch_valid then
					majiang:setMjState(Mj._EState.e_state_normal)
		            self._m_lastSelectMj = nil
	        	end
       		end
		end
	end
	return true
end

function PlayLayer:onTouchEnd(touch, event)
	Log.i("PlayLayer:onTouchEnd")

    
	local canPlay = false

	local gameLayer = self:getParent()
	local clock = gameLayer._bgLayer._clock
	assert(clock ~= nil)

	if clock._point == 1 
		and MjMediator:getInstance():isCanPlayCard() == enHandCardRemainder.CAN_PLAY  then
		canPlay = true
	end
	Log.d("PlayLayer:onTouchEnd canPlay",canPlay,"clock._point..",clock._point,MjProxy:getInstance()._players[Define.site_self]:getCanPlay())

	local playerMyUI = self._my._ui
	assert(playerMyUI)
    if MjProxy:getInstance():getIsOnAction() == true then
        Log.i("正在执行动作暂时不允许打牌")
        canPlay = false
--        return false
    end
	-- 拖拽出牌
	if self._m_dragingMj and self._m_lastSelectMj then
		local px, py = self._m_dragingMj:getPosition()
		local mj = self._m_dragingMj._value

		self._m_dragingMj:removeFromParent()
		self._m_dragingMj = nil
		self._m_lastSelectMj:setMjState(Mj._EState.e_state_touch_valid)
		if canPlay then
			if touch:getLocation().y > Define.g_pai_y + 30 and mj < 50 then --花牌不能打
                MjProxy:getInstance():setIsPlayMahjong(true)
				playerMyUI:ui_playeMajiang(mj)--发送打牌消息

				self:removeTingQuery()
				WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 1, px, py, mj)
                self._m_lastSelectMj:removeFromParent()
				MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
				local tag = self._m_lastSelectMj:getTag()
				assert(playerMyUI ~= nil)
				playerMyUI:setOutMjPositionX(self._m_lastSelectMj:getPositionX())

				self._m_lastSelectMj = nil
				playerMyUI:ui_reflash(tag)
                MjProxy:getInstance():setIsOnAction(true)
			end
		end
		-- 单击或双击出牌	
	else
		local myCards = MjProxy:getInstance()._players[Define.site_self].cards
		assert(myCards ~= nil)
		if canPlay then
			for i = 0, #myCards - 1 do
				local majiang = myCards[i + 1]
				if majiang and majiang:isContainsTouch(touch:getLocation().x, touch:getLocation().y)  then
					if majiang._state == Mj._EState.e_state_touch_invalid or majiang._value > 50 then
						    return
					end
					if not self._m_lastSelectMj then
						Log.i("PlayLayer:onTouchEnd self._m_lastSelectMj == null")
					end           
					if self._m_lastSelectMj then
						if majiang == self._m_lastSelectMj then
                            Log.i("单击或双击出牌。。。已经出牌了")
                            MjProxy:getInstance():setIsPlayMahjong(true)
							local isSingleClick = MjProxy.getInstance():getSinglePlaying()
							if MjProxy:getInstance()._players[Define.site_self]:getHasClickTing() then
								isSingleClick = false
							end
							if not isSingleClick then
								if self._m_hasClickOnceMj == nil then
									self._m_hasClickOnceMj = majiang
									return
								elseif self._m_hasClickOnceMj ~= majiang then
									self._m_hasClickOnceMj = majiang
									return
								end
							end

							playerMyUI:ui_playeMajiang(majiang._value)--发送打牌消息

							self:removeTingQuery()
							WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 1, self._m_lastSelectMj:getPositionX(), self._m_lastSelectMj:getPositionY(), self._m_lastSelectMj._value)
							self._m_lastSelectMj:removeFromParent()
                            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
							local tag = self._m_lastSelectMj:getTag()
							assert(playerMyUI ~= nil)
							playerMyUI:setOutMjPositionX(self._m_lastSelectMj:getPositionX())
							
							self._m_lastSelectMj = nil
                            Log.i("打牌调整")
							playerMyUI:ui_reflash(tag)
                            MjProxy:getInstance():setIsOnAction(true)
						end
					end
					break
				end
			end

		end
	end

end

function PlayLayer:onTouchMoved(touch, event)
	-- Log.i("PlayLayer:onTouchMoved ")

	-- if MjProxy:getInstance()._myData.m_bIsChangeFinish == false then
	-- 	return
	-- end

	if self._m_lastSelectMj ~= nil and self._m_dragingMj ~= nil then
		self._m_dragingMj:setPosition(cc.p(touch:getLocation().x, touch:getLocation().y))
		self._m_lastSelectMj._spMjBg:setOpacity(190)
		return
	end

	local myCards = MjProxy:getInstance()._players[Define.site_self].cards
	assert(myCards ~= nil)

	for i = 0, #myCards - 1 do
		local majiang = myCards[i + 1]
		if majiang and majiang:isContainsTouch(touch:getLocation().x, touch:getLocation().y) then
			if majiang._state == Mj._EState.e_state_touch_invalid then
				return
			end

			if self._m_lastSelectMj ~= nil and majiang ~= self._m_lastSelectMj then
				self._m_lastSelectMj:setMjState(Mj._EState.e_state_normal)
				self:removeTingQuery()
			end

			majiang:setMjState(Mj._EState.e_state_selected)
			self._m_lastSelectMj = majiang
			self._m_lastSelectMj:setTag(i)

			local pt = touch:getLocation()
			if pt.y > Define.g_pai_y + 30 then
				if self._m_dragingMj then
					self._m_dragingMj:removeFromParent()
					self._m_dragingMj = nil
				end
				self._m_dragingMj = Mj.new(majiang._value, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
				self._m_dragingMj:setPosition(cc.p(pt.x, pt.y)):addTo(self)
			end
			break
		end
	end
end
function PlayLayer:resumePlayers()
	Log.i("PlayLayer:resumePlayers")
	local data = MjProxy:getInstance()._gameStartData
	assert(data ~= nil and data ~= { })

	if MjProxy:getInstance()._players[Define.site_self]:getTingStatus() == 1 then--听牌状态
		MjProxy:getInstance()._players[Define.site_self]:setHasSendTing(true)
		MjProxy:getInstance()._players[Define.site_self].cards = MjProxy:getInstance()._players[Define.site_self].cards or { }
		assert(#MjProxy:getInstance()._players[Define.site_self].cards ~= 0)

		for _, v in ipairs(MjProxy:getInstance()._players[Define.site_self].cards) do
			v:setMjState(Mj._EState.e_state_touch_invalid)
		end
	end

	for i=1,#self._allPlayers do
		if i ==1 then
			self._my._ui:ui_recoveryMj()
		else
			self._allPlayers[i]:recoveryMj()
		end
	end

	local clock = self:getParent()._bgLayer._clock
	-- 设置指针
	for i=1,#MjProxy:getInstance()._userIds do
		if data.firstplay == MjProxy:getInstance()._userIds[i] then
			if data.firstplay == MjProxy:getInstance():getMyUserId() and #data.actions > 0 then
				clock:setThePoint(i, clock._EType.e_type_action)
			else
				clock:setThePoint(i, clock._EType.e_type_play)
			end
		end
	end

	local actions = data.actions
	if #actions == 0 then
		Log.i("恢复对局，无操作")
		if data.firstplay == MjProxy:getInstance():getMyUserId() then
			Log.i("恢复对局，本家先出牌")
			self:setPlayerTouchEnabled(true)

			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
			if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() and data.dispenseCard ~= 0 then
				Log.d("恢复对局，听牌后打出 %s", tostring(data.dispenseCard))
				self.playerMy._ui:ui_playSomeMj(data.dispenseCard)
			end
		else
			Log.i("恢复对局，别家先出牌")
			self:setPlayerTouchEnabled(true)
			
		end
	else
		MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
		local tactions = actions
		for i = 1, #tactions do
			Log.d("恢复对局，可以进行的操作是 %s", tostring(tactions[i]))
		end

		-- 是否有听
		-- local isHasTingAction = false
		-- for i = 1, #tactions do
		-- 	local action = tactions[i]
		-- 	if action == Define.action_ting then
		-- 		isHasTingAction = true
		-- 		break
		-- 	end
		-- end

		-- 如果有听，去重
		-- if isHasTingAction then
		-- 	local t = { 6 }
		-- 	for i = 1, #tactions do
		-- 		local action = tactions[i]
		-- 		if action ~= Define.action_ting then
		-- 			table.insert(t, action)
		-- 		end
		-- 	end
		-- 	tactions = t
		-- end

		-- for i = 1, #tactions do
		-- 	Log.i("恢复对局，去重之后的操作是 %s", tostring(tactions[i]))
		-- end

		local isHasHuAction = false
		local huAction = 0
		for k, v in ipairs(tactions) do
			if v == Define.action_dianPaoHu or v == Define.action_ziMoHu then
				isHasHuAction = true
				huAction = v
				break
			end
		end

		if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() == true then
			if isHasHuAction == false then
                
				Log.i("复对局，显示其他操作,天听")
                self:setPlayerTouchEnabled(false)
			    local actionList = ActionList.new(tactions, data)
			    self:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
--				WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, tactions[1], 0, data.playCard)
			else
				Log.d("恢复对局，有胡，显示胡 playCard", data.playCard)
				local actionList = ActionList.new( { huAction }, data)
				-- actionList:setPosition(cc.p(0, 180))
				self:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
			end
		else

            local isCanOutMj = false
            for i=1,#tactions do
                if tactions[i]  == Define.action_ting or tactions[i] == Define.action_jiaGang or tactions[i] == Define.action_anGang or tactions[i] == Define.action_ziMoHu then 
                    isCanOutMj = true
                    break
                end
            end
			Log.i("恢复对局，显示其他操作")

            self:setPlayerTouchEnabled(isCanOutMj)
			local actionList = ActionList.new(tactions, data)
			self:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
		end

	end
end

function PlayLayer:distrMj()
	-- 发牌
    local pos = 1
    local data = nil
    if self._isResume == true then
    	data = MjProxy:getInstance()._gameStartData
    else
    	data = MjProxy:getInstance()._gameStartData
    end
    local diceValue = data.dice[1] + data.dice[2]
    local dicePos = self:quickTriacks(diceValue)
    self:getParent()._MJTricks:initTriacksCard(dicePos,diceValue)
	for i=1,#self._allPlayers do
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.15*i),cc.CallFunc:create(function ()
			self._allPlayers[i]:distrMj()
		end)))
	end
end

function PlayLayer:initPlayers()
	Log.i("PlayLayer:initPlayers")
	self.playerMy =  PlayerMy.new(self._isResume)
	self.playerMy:addTo(self)

	local playerRight = PlayerRight.new()
	playerRight:addTo(self)

	local playerOther = PlayerOther.new()
	playerOther:addTo(self)

	local playerLeft = PlayerLeft.new()
	playerLeft:addTo(self)

	self._my = self.playerMy
	self._other = playerOther
	self._allPlayers[Define.site_self] = self._my
	self._allPlayers[Define.site_right] = playerRight
	self._allPlayers[Define.site_other] = self._other
	self._allPlayers[Define.site_left] = playerLeft
	Log.i("发牌_allPlayers size="..(#self._allPlayers))

	-- 2016.11.17 zcq 修改了恢复对局状态统一管理
	self._isResume = MjProxy:getInstance():getResume()
	if self._isResume == true then
		Log.i("PlayLayer:initPlayers 恢复对局")
		self:resumePlayers()
	else
		self:distrMj()
	end
	-- --------视频回放功能启动------------------------------------
	-- if VideotapeManager.getInstance():isPlayingVideo() then
	-- 	-- 监听发牌结束之后明牌
	-- 	if self.distrEndHandle then
	-- 		WWFacade:removeEventListener(self.distrEndHandle)
	-- 		self.distrEndHandle = nil
	-- 	end
	-- 	self.distrEndHandle = WWFacade:addCustomEventListener(MJ_EVENT.GAME_distrubuteEnd, handler(self, self.distrubuteEnd))
	-- end
	-- ----------------------------------------------------------------------------------------------
end

-----------------------------------回放相关---------------
--[[
-- @brief  发牌结束之后需要明牌显示
-- @param  void
-- @return void
--]]
-- function PlayLayer:distrubuteEnd()
-- 	for i=2,4 do
-- 		local userid = MjProxy:getInstance()._players[i]:getUserId()
-- 		local palyerInfo = kPlaybackInfo:getStartGameContentByid(userid)
-- 		self._allPlayers[i]:gameVideoMingPai(palyerInfo.clC, 0)
-- 	end
-- end
------------------------------------------------------------

--确定发牌的位置
function PlayLayer:quickTriacks(diceValue)
    local banPosition = MjProxy:getInstance():getBanPosition()
    if diceValue == 5 or diceValue == 9 then
        if banPosition == 1 then
            return 1
        elseif banPosition == 2 then
            return 4
        elseif banPosition == 3 then
            return 3
        elseif banPosition == 4 then
            return 2
        end
    elseif diceValue == 2 or diceValue == 6 or diceValue == 10 then
        if banPosition == 1 then
            return 2
        elseif banPosition == 2 then
            return 3
        elseif banPosition == 3 then
            return 4
        elseif banPosition == 4 then
            return 1
        end
    elseif diceValue == 3 or diceValue == 7 or diceValue == 11 then
        if banPosition == 1 then
            return 3
        elseif banPosition == 2 then
            return 4
        elseif banPosition == 3 then
            return 1
        elseif banPosition == 4 then
            return 2
        end
    elseif diceValue == 4 or diceValue == 8 or diceValue == 12 then
        if banPosition == 1 then
            return 2
        elseif banPosition == 2 then
            return 1
        elseif banPosition == 3 then
            return 4
        elseif banPosition == 4 then
            return 3
        end
    end
    return 1
end

function PlayLayer:onMjDistrubuteEnd()
	local data = MjProxy:getInstance()._gameStartData
	assert(data ~= nil)

	if self._m_pListener then
		self._m_pListener:setEnabled(true)
	end
	
	local clock = self:getParent()._bgLayer._clock
	for i=1,#MjProxy:getInstance()._userIds do
		if data.bankPlay == MjProxy:getInstance()._userIds[i] then
			if #data.actions > 0 then
				clock:setThePoint(i, clock._EType.e_type_action)

			else
				clock:setThePoint(i, clock._EType.e_type_play)
			end
		end
	end
	-- self:showChangeThreeCard()
	-- 发送缓存的消息
	MjProxy:getInstance():popAllMsgCache()
end

function PlayLayer:playMj(playCardData)
	
	local data = playCardData
    Log.d("PlayLayer:playMj",data)
	assert(data ~= nil)

	if data.playCard == 0 or data.repeatt ~= 0 then
		-- self:performWithDelay(function() 
  --           MjProxy:getInstance():runPopAllMsgCache() 
  --       end,1)
		----------------录像回放---------------------
		if VideotapeManager.getInstance():isPlayingVideo() then
			 MjProxy:getInstance():runPopAllMsgCache() 
		else
			self:performWithDelay(function() 
            	MjProxy:getInstance():runPopAllMsgCache() 
        	end,0.2)
		end
		---------------------------------------------
		return
	end
    Log.d("data.playedbyID..",data.playedbyID,"MjProxy:getInstance():getMyUserId()...",MjProxy:getInstance():getMyUserId())
	-- 如果是我出牌
	if data.playedbyID == MjProxy:getInstance():getMyUserId() then
        
		self:removeActionNode()

		-- ------------------录像打牌-----------------
		-- -- 为了轮到自家出牌时自动出牌
		-- if (self._my and self._my._m_bIsAutoPlay == true)
		-- 	or VideotapeManager.getInstance():isPlayingVideo() then
		-- 	local gender = MjProxy.getInstance()._players[Define.site_self]:getSex()
		-- 	self:playerSound(gender, data.playCard)
		-- 	self._my:playMjAction(data.playCard)
		-- end
		-- --------------------------------------------

        Log.d("self._my._m_bIsAutoPlay...",self._my._m_bIsAutoPlay,MjProxy:getInstance():getIsPlayMahjong())
		if self._my and MjProxy:getInstance():getIsPlayMahjong() == false then
            Log.i("打完牌了")
			local gender = MjProxy.getInstance()._players[Define.site_self]:getSex()
			self:playerSound(gender, data.playCard)
			self._my:playMjAction(data.playCard)
            --
            Log.i("我出完牌了")
--            self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CalFunc:create(function () MjProxy:getInstance():runPopAllMsgCache()  end)))

		end
        MjProxy:getInstance():setIsPlayMahjong(false)
		local clock = self:getParent()._bgLayer._clock
		if clock then
			clock:clockStop()
		end

        -- self:performWithDelay(function() 
        --     MjProxy:getInstance():runPopAllMsgCache("playCard") 
        -- end,1)

        ----------------录像回放---------------------
		if VideotapeManager.getInstance():isPlayingVideo() then
			 MjProxy:getInstance():runPopAllMsgCache("playCard") 
		else
			self:performWithDelay(function() 
            	MjProxy:getInstance():runPopAllMsgCache("playCard") 
        	end,0.2)
		end
		---------------------------------------------
		-- 如果是别人出牌
	else
		if data.repeatt == 0 then
			for i=2,#MjProxy:getInstance()._userIds do
				if data.playedbyID == MjProxy:getInstance()._userIds[i] then
					local gender = MjProxy:getInstance()._players[i]:getSex()
					self:playerSound(gender, data.playCard)
					self._allPlayers[i]:playMj(data.playCard)
				end
			end	
		end

        -- self:performWithDelay(function() 
        --     MjProxy:getInstance():runPopAllMsgCache("playCard") 
        -- end,1)

        ----------------录像回放---------------------
		if VideotapeManager.getInstance():isPlayingVideo() then
			 MjProxy:getInstance():runPopAllMsgCache("playCard") 
		else
			self:performWithDelay(function() 
            	MjProxy:getInstance():runPopAllMsgCache("playCard") 
        	end,0.2)
		end
		---------------------------------------------
	end
end

function PlayLayer:setPlayerTouchEnabled(bEnable)
    Log.d("PlayLayer:setPlayerTouchEnabled bEnable...",bEnable)
	if self._m_pListener:isEnabled() == bEnable then
		return
	end

	self._m_pListener:setEnabled(bEnable)

	if bEnable == false then
		if self._m_dragingMj then
			self._m_dragingMj:removeFromParent()
			self._m_dragingMj = nil
		end
		if self._m_lastSelectMj then
			self._m_lastSelectMj:setMjState(Mj._EState.e_state_touch_valid)
			self._m_lastSelectMj:setMjState(Mj._EState.e_state_normal)
			self._m_lastSelectMj = nil
		end
	end
end
function PlayLayer:gameEnd()
	self._m_lastSelectMj = nil
	if self._m_dragingMj then
		self._m_dragingMj:removeFromParent()
		self._m_dragingMj = nil
	end
end

function PlayLayer:setLastMjNormal()
	if self._m_lastSelectMj then
		self._m_lastSelectMj:setMjState(Mj._EState.e_state_normal)
		self._m_lastSelectMj = nil
	end
end

function PlayLayer:showBuTing(x)
	local actionBtn = require "app.games.huaibeimj.mediator.game.model.ActionBtn"
	self.buting = actionBtn.createWithType(Define.action_buTing, 0)
	self.buting:registerScriptTapHandler(handler(self, function()
		if MjProxy:getInstance()._players[Define.site_self]:getHasClickTing() == true and MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() == false then
			MjProxy:getInstance()._players[Define.site_self]:setHasClickTing(false)
			local myCards = MjProxy:getInstance()._players[Define.site_self].cards
			for _, v in ipairs(myCards) do
				v:setMjState(Mj._EState.e_state_touch_valid)
			end
		end
		self.buting:removeFromParent()
		self.buting = nil
	end))


	self.buting:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self.buting:setPosition(cc.p(x, 180))

	local menu = cc.Menu:create(self.buting)
	menu:setPosition(cc.p(0, 0))
	self:addChild(menu, Define.e_zorder_player_layer_action)
end

function PlayLayer:removeBuTing()
	if self.buting then
		self.buting:removeFromParent()
		self.buting = nil
	end
end

function PlayLayer:deleteDragingMj()
	if self._m_dragingMj then
		self._m_dragingMj:removeFromParent()
		self._m_dragingMj = nil
	end
	if self._m_lastSelectMj then
		self._m_lastSelectMj:setMjState(Mj._EState.e_state_touch_valid)
	end
end

function PlayLayer:removeActionNode()
	local actionlist = self:getChildByTag(Define.e_tag_player_layer_action)
	if actionlist then
		actionlist:removeFromParent()
		actionlist = nil
	end
end

function PlayLayer:removeTingQuery()
	-- if self.m_tingQueryNode then
	-- 	self.m_tingQueryNode:removeFromParent()
	-- 	self.m_tingQueryNode = nil
	-- end
end

function PlayLayer:gameEndMingPai(site, cards, card )
	if self.m_RobotNode then
		self.m_RobotNode:removeFromParent()
		self.m_RobotNode = nil
	end
	self._allPlayers[site]:gameEndMingPai(cards, card)
end


function PlayLayer:onEnter()
	Log.i("PlayLayer:onEnter#######################")
	self._m_pListener = cc.EventListenerTouchOneByOne:create()
	self._m_pListener:registerScriptHandler( function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	self._m_pListener:registerScriptHandler( function(touch, event) return self:onTouchEnd(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
	self._m_pListener:registerScriptHandler( function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(self._m_pListener, self)
	self._m_pListener:setEnabled(false)
end

function PlayLayer:onExit()

end

function PlayLayer:playerSound(gender, card)
	if card > 10 and card < 20 then
        Sound.effect_wan(gender,card%10)
    elseif card > 20 and card < 30 then
        Sound.effect_tiao(gender,card%10)
    elseif card > 30 and card < 40 then
        Sound.effect_tong(gender,card%10)
    elseif card > 40 and card < 50 then
        Sound.effect_feng(gender,card%10)
    end
end

return PlayLayer