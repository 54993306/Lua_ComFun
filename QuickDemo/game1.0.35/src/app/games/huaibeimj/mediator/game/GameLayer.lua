--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local ActionList = require "app.games.huaibeimj.mediator.game.model.ActionList"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local SetDialog = require "app.games.huaibeimj.mediator.game.dialog.SetDialog"
local GameOverDialog = require ("app.games.huaibeimj.mediator.game.dialog.GameOverDialog")
local BgLayer = require ("app.games.huaibeimj.mediator.game.BgLayer")
local PlayLayer = require ("app.games.huaibeimj.mediator.game.PlayLayer")
local PlayerFlowNode = require "app.games.huaibeimj.mediator.game.model.PlayerFlowNode"
--local PlayerChat = require "app.games.huaibeimj.mediator.game.model.PlayerChat"
--local MJArmatureCSB = require("app.games.huaibeimj.custom.MJArmatureCSB")
local tricks = require("app.games.huaibeimj.custom.MJTricks")
local PaoPeiAnimLayer = require ("app.games.huaibeimj.mediator.game.dialog.PaoPeiAnimLayer")
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"

-- 加入回放层
local VideoControlLayer = require "app.games.huaibeimj.mediator.game.model.VideoControlLayer"

local GameLayer = class("GameLayer", function ()
	return display.newLayer()
end)
function GameLayer:ctor(isResume, isContinue)
	Log.i("GameLayer:ctor")
	Log.i(isResume)
    -- ui显示状态
    self.onShowUI = false
    
    self._isResume = isResume
    MjProxy:getInstance():setResume(self._isResume)
	self._isContinue = isContinue
	if isResume ~= true then
		Log.d("GameLayer:ctor正常开局")
    else
        Log.d("GameLayer:ctor恢复对局")
        for i=1,#MjProxy:getInstance()._players do
        	-- WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjInfo, MjProxy:getInstance()._players[i]:getUserId())
        end
	end

    MjMediator:getInstance():getScene():setRunningLayer(self)

    if self._bgLayer then
    	self._bgLayer:removeFromParent()
    end
    if self._playLayer then
    	self._playLayer:removeFromParent()
    end

	self._bgLayer = BgLayer.new(isResume, isContinue)
	self._bgLayer:addTo(self)

	self._playLayer = PlayLayer.new(isResume)
	self._playLayer:addTo(self, 1)

    --绘制游戏界面ui
    if self.m_gameUIView then
        self.m_gameUIView:removeFromParent()
    end
    self.m_gameUIView = GameUIView.new()
    self.m_gameUIView.m_pWidget:addTo(self,10)
    self.m_gameUIView:setDelegate(self);
    self.m_gameUIView:onInit()
    self.m_gameUIView:hideXiaPaoOrLaPanel()

--    self._playerChat = nil
--    self._playerChat = PlayerChat.new()
--    self._playerChat:addTo(self,10)
        
    ------------- 加入录像回放控制层-------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- 加入录像回放控制层
        if self._videoLayer then
            self._videoLayer:removeFromParent()
        end
        self._videoLayer = VideoControlLayer.new()
        self._videoLayer:addTo(self, 11)
    end
    ----------------------------------------------------------

    -- 显示续局准备界面
    if isContinue and isContinue == true then
        -- 创建头像
        self:createHead()
        -- 显示
        self:createHeadActions()
        -- 显示自己的准备图片
        self.m_playerHeadNode:showReadySpr(Define.site_self)
    end
    self:onEnter()
    MjProxy:getInstance():setIsAction(false)
    --有人正在说话
    self.m_speaking = false;
    self.m_speakTable = {};
end

function GameLayer:onKeyboard()
    Log.i("GameLayer:onKeyboard")
    local keyBack = true
    if self.m_chatView then
        self.m_chatView:keyBack()
        keyBack = false
        self.m_chatView = nil
    end
end

function GameLayer:onEnter()
	Log.i("PlayLayer:onEnter#######################")
	self._m_pListener = cc.EventListenerTouchOneByOne:create()
	self._m_pListener:registerScriptHandler( function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(self._m_pListener, self)

	self._m_pListener:setEnabled(true)
end
function GameLayer:onTouchBegan(touch, event)
    local keyBack = true
    if self.menuBgSprite ~= nil and self.menuBgSprite:isVisible() then
        self.menuBgSprite:setVisible(false)
        keyBack = false
    end
    if self.m_chatView then
        self.m_chatView:keyBack()
        keyBack = false
        self.m_chatView = nil
    end
    if self.m_roomChargeView then
        self.m_roomChargeView:keyBack()
        self.m_roomChargeView = nil
        keyBack = false
    end

    -- local arrHeadNode = self._bgLayer._m_arrHeadNode
    -- if arrHeadNode ~= nil then
    --     for i,v in pairs(arrHeadNode) do
    --         if v.infoView then
    --             v.infoView:keyBack()
    --             keyBack = false
    --             v.infoView = nil
    --         end
    --     end
    -- end
    if self.m_dialog ~= nil and self.m_dialog and self.m_dialog.m_dialogData~= nil then
        self.m_dialog.m_dialogData.cancelCallBack()
        self.m_dialog:removeFromParent()
        self.m_dialog = nil
        keyBack = false
    end
   
end

function GameLayer:showMic()
    audio.pauseMusic();
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameLayer:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("hall/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameLayer:hideMic()
    if not kSettingInfo:getGameVoiceStatus() then
        audio.resumeMusic();
    end
    self.img_mic:setVisible(false);
end

function GameLayer:recChargeResult(packetInfo)
    CommonAnimManager.getInstance():showMoneyWinAnim();
    MJToast.getInstance():show("充值成功");
end
--发送系统定义的表情和文字短语 
function GameLayer:sendDefaultChat(m_type,index)
    local data = {};
    data.gaPI = MjProxy:getInstance():getGameId()
    data.usI = MjProxy:getInstance()._players[Define.site_self]:getUserId()
    data.ty = m_type
    data.emI = index;
    SocketManager.getInstance():send(CODE_TYPE_GAME, ww.mj.msgSendId.msgSend_default_char, data);
end
--发送自定文字
function GameLayer:sendUserChat(content)
    local data = {}
    data.gaPI = MjProxy:getInstance():getGameId()
    data.usI = MjProxy:getInstance()._players[Define.site_self]:getUserId()
    data.co = content
    data.ty = 0
    SocketManager.getInstance():send(CODE_TYPE_GAME,ww.mj.msgSendId.msgSend_user_chat, data)
end
function GameLayer:resume()
	-- self._bgLayer:showViews()

	self:on_gameStart()
    Log.d("GameLayer:resume", MjProxy:getInstance()._players[Define.site_self]:getUserStatus())
    if MjProxy:getInstance()._players[Define.site_self]:getUserStatus() == 1 then
--        MjProxy:getInstance():setSubstitute(true)
--        local my = self._playLayer._my
--        if my then
--            Log.i("GameLayer:resume 托管中")
--            my:setAutoPlay(true)
--        end 
    else
        MjProxy:getInstance():setSubstitute(false)       
    end

    for i=1,#MjProxy:getInstance()._players do
        if MjProxy:getInstance()._players[i]:getUserStatus() == 1 then
            self._bgLayer:showHeadSubstitute(i, true)
        else
            self._bgLayer:showHeadSubstitute(i, false)
        end

    end
    -- WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_substitute, 0)
end

function GameLayer:on_gameStart()
    MjProxy:getInstance():get_gameChatTxtCfg()
	assert(self._bgLayer ~= nil)
    self._bgLayer:removeMatchLoading()
    self:createHead()
    self:createHeadActions()
    -- self.m_gameUIView:onInit()
    self.m_gameUIView:resetWord()
    self.m_gameUIView:updateBattery()
    self.m_gameUIView:updateSignal()

    if MjProxy:getInstance():getXiaPaoFinished() then
        self:showUi()
    end

    -- 拉庄的时候庄家没有拉过默认发送0给服务器
    local banSite = MjProxy:getInstance():getBanPosition()
    -- local actType = MjProxy:getInstance():getModeType()
    if banSite == Define.site_self
        and MjProxy:getInstance()._players[Define.site_self]:getNeedFillingByType(Define.action_laZhuang)
        and MjProxy:getInstance()._players[Define.site_self]:getFillingNumByType(Define.action_laZhuang) < 0 then
        -- 庄家没有发过拉庄请求则需要发请求
        WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_laZhuang, 1, 0)
    elseif banSite ~= Define.site_self then
        --todo
        if MjProxy:getInstance()._players[Define.site_self]:getNeedFillingByType(Define.action_zuo)
            and MjProxy:getInstance()._players[Define.site_self]:getFillingNumByType(Define.action_zuo) < 0 then
            -- 闲家则发没有发过坐则发坐
            WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_zuo, 1, 0)
        end
    end   

    -- 更新庄家显示
    self.m_playerHeadNode:updateBan()
    -- 更新下跑或者拉庄显示
    for i=1,#MjProxy:getInstance()._players do
        -- local showList = MjProxy:getInstance():getShowFillingListBySite(i)
        local showList = MjProxy:getInstance()._players[i]:getFillingNum()
        for k, v in pairs(showList) do
            self.m_playerHeadActions:upDateXiaOrLaNum(i, k, v)
        end
    end
end

function GameLayer:showLaiziMj()
    local turn = require("app.games.huaibeimj.custom.MJTurnLaizigou")
    local turnLaizigou = turn.new(MjMediator:getInstance():getFanZi())
    turnLaizigou:addTo(self,10)
end

function GameLayer:showUi()
    -- 避免重复显示ui
    if self.onShowUI then
        return
    end
    self.onShowUI = true
    --绘制头像
    Log.i("GameLayer:showUi")
    self._bgLayer:removeMatchLoading()
    -- 重设头像位置
    self.m_playerHeadNode:setGameLayer()
    -- 重设拉跑坐位置
    self.m_playerHeadActions:setGameLayer()
    --绘制牌墙
    if self._isResume == true then
		self._bgLayer:on_gameStart()
		local data = MjProxy:getInstance()._gameStartData
		assert(data ~= nil)
		if data.firstplay == MjProxy:getInstance():getMyUserId() then
			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
		end
	    WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_startAniEnd)
    else
	    self:addMJOfTricks()
		self._bgLayer:on_gameStart()
		local data = MjProxy:getInstance()._gameStartData
		if self._isResume == true then
			data = MjProxy:getInstance()._gameStartData
		end
		assert(data ~= nil)
		if data.firstplay == MjProxy:getInstance():getMyUserId() then
			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
		end
	    self._MJTricks:diceAnimation(MjProxy:getInstance()._gameStartData.dice[1],MjProxy:getInstance()._gameStartData.dice[2])	
    end
    self.m_playerHeadNode:updateBan()
    MjProxy.getInstance():setGameState("gamePlaying")
end
--[[
-- @brief  创建头像函数
-- @param  void
-- @return void
--]]
function GameLayer:createHead()
--    self.m_playerHeadNode = UIManager.getInstance():pushWnd(PlayerHead);
    Log.i("GameLayer:showHead....")
    self:removeHead()
    self.m_playerHeadNode = PlayerHead.new()
    self.m_playerHeadNode.m_pWidget:addTo(self, 8)
    self.m_playerHeadNode:setDelegate(self);
    self.m_playerHeadNode:onInit()
end

--[[
-- @brief  创建头像函数
-- @param  void
-- @return void
--]]
function GameLayer:createHeadActions()
    Log.i("GameLayer:createHeadActions....")
    self:removeHeadActions()
    self.m_playerHeadActions = PlayerHeadActions.new()
    self.m_playerHeadActions.m_pWidget:addTo(self, 0)
    self.m_playerHeadActions:setDelegate(self);
    self.m_playerHeadActions:onInit()
end

function GameLayer:removeHead()
    if self.m_playerHeadNode ~= nil and self.m_playerHeadNode.m_pWidget ~= nil then
        self.m_playerHeadNode.m_pWidget:removeFromParent()
    end
  
end

function GameLayer:removeHeadActions()
    if self.m_playerHeadActions ~= nil and self.m_playerHeadActions.m_pWidget ~= nil then
        self.m_playerHeadActions.m_pWidget:removeFromParent()
    end
end
function GameLayer:on_payerAction(amimation,time,sex)
    if time == nil then
        time = 1
    end
    Log.d("amimation.....",amimation,"time.....",time)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/hu.csb")
    local armature = ccs.Armature:create("hu")
    armature:getAnimation():play(amimation)
    armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, time);
--    armature:setPosition(cc.p(display.cx, display.cy))
    self:addChild(armature,5)
    if sex == 1 then
        armature:setPosition(cc.p(display.cx,Define.mj_myCards_position_y+10))
    elseif sex == 2 then
        armature:setPosition(cc.p(Define.mj_rightCards_position_x-10,display.cy))
    elseif sex == 3 then
        armature:setPosition(cc.p(display.cx,Define.mj_otherCards_postion_y-10))
    elseif sex == 4 then
        armature:setPosition(cc.p(Define.mj_leftCards_position_x-10,display.cy))
    else
        armature:setPosition(cc.p(display.cx, display.cy))
    end
    return armature
end
function GameLayer:on_dianpaoAction(sex)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/dianpao.csb")
    local armature = ccs.Armature:create("dianpao")
    armature:getAnimation():play("Animation1")
    armature:performWithDelay(function()
                armature:removeFromParent(true)
        end, 0.8);
    armature:setScale(0.7);
    self:addChild(armature,5)
    if sex == 1 then
        armature:setPosition(cc.p(display.cx,Define.mj_myCards_position_y+10))
    elseif sex == 2 then
        armature:setPosition(cc.p(Define.mj_rightCards_position_x-10,display.cy))
    elseif sex == 3 then
        armature:setPosition(cc.p(display.cx,Define.mj_otherCards_postion_y-10))
    elseif sex == 4 then
        armature:setPosition(cc.p(Define.mj_leftCards_position_x-10,display.cy))
    else
        armature:setPosition(cc.p(display.cx, display.cy))
    end

    self:performWithDelay(function()
        local dianpao = display.newSprite("#dianpao.png")
        self:addChild(dianpao)
        dianpao:setScale(0.7)
        if sex == 1 then
            dianpao:setPosition(cc.p(display.cx,Define.mj_myCards_position_y+10))
        elseif sex == 2 then
            dianpao:setPosition(cc.p(Define.mj_rightCards_position_x-10,display.cy))
        elseif sex == 3 then
            dianpao:setPosition(cc.p(display.cx,Define.mj_otherCards_postion_y-10))
        elseif sex == 4 then
            dianpao:setPosition(cc.p(Define.mj_leftCards_position_x-10,display.cy))
        else
            dianpao:setPosition(cc.p(display.cx, display.cy))
        end
    end,0.8)
end
function GameLayer:on_playerHU(cx,cy)
    self:performWithDelay(function()
        local hu = display.newSprite("#hu.png")
        hu:setPosition(cc.p(cx, cy))
        self:addChild(hu)
    end,0.8)
end
--初始化牌墩数
function GameLayer:addMJOfTricks()
	Log.i("GameLayer:addMJOfTricks")
	self._MJTricks = tricks.new(1)
    self._MJTricks:initTriacks()
--	cc.Director:getInstance():getRunningScene():addChild(node, 1)
    self._MJTricks:addTo(self,0)
end

function GameLayer:on_playCard(playCardData)
	Log.i("GameLayer:on_playCard")
--	local data = MjProxy:getInstance()._playCardData
    local data = playCardData
    CommonSound.playSound("dapai")
	Log.d("处理出牌数据: %s打出牌: %s",data, tostring(data.playedbyID), tostring(data.playCard))
	-- local my = MjProxy:getInstance()._players[Define.site_self]
	assert(data ~= nil)
	assert(self._playLayer ~= nil)
	assert(self._bgLayer ~= nil)

	-- if my.m_bIsChangeFinish == false and data.nextplayerID == MjProxy:getInstance():getMyUserId() then
	-- 	MjProxy:getInstance()._otherData.m_otherFirstPlayerCardMsg = data
	-- 	Log.i("换牌没结束，对家先出牌，丢弃一次对家的出牌消息");
	-- 	return
	-- end

	self._playLayer:removeActionNode()
    -- 刷新显示剩余牌数
    -- self._bgLayer:refreshRemainCount()
	self._playLayer:playMj(data)
	if data.nextplayerID ~= MjProxy:getInstance():getMyUserId() then
		Log.i("如果轮到别家出牌")
		if #data.actions > 0 then
			local playIndex = 0
			local nextIndex = 0
			for i=1,#MjProxy:getInstance()._players do
				if data.playedbyID == MjProxy:getInstance()._players[i] then
					playIndex = i
				end
				if data.nextplayerID == MjProxy:getInstance()._players[i] then
					nextIndex = i
				end
			end
			if nextIndex - playIndex ~=1 or nextIndex - playIndex ~= -3 then
				local clock = self._bgLayer._clock
				clock:showLoading(true)
			end
		end
        if MjProxy:getInstance()._players ~= nil and #MjProxy:getInstance()._players > 0 then
		    MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
            local menPai = data.doorcard
        end
	else
		Log.i("如果轮到我出牌")
		--WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_clockPoint, 1)
        if MjProxy:getInstance()._players == nil or #MjProxy:getInstance()._players <= 0 then
            Log.i("玩家还没有生成")
            return
        end
		MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)

		local menPai = data.doorcard
		if menPai ~= 0 then
			Log.i("有门牌")
            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
			if data.playCard < 50 then
				self._playLayer._my:onJiaoPaiEnd(menPai)
			end
		else
			Log.i("没门牌，处理操作")
			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
            
            local my = self._playLayer._my
            assert(my ~= nil)

            if my._m_bIsAutoPlay == false and data.doorcard == 0 and data.playCard == 0 then --起手牌
                MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
            end

            local actions = data.actions
			if #actions == 0 then
				return
			end

			if my._m_bIsAutoPlay then
--                local actionCard = data.doorcard
--	            if actionCard == 0 then
--		            actionCard = data.playCard
--	            end
--                WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, actions[1], 0, actionCard)
				return
			end

			for i = 1, #actions do
				Log.d("处理打牌消息，可以进行的操作是 %s", tostring(actions[i]))
			end

			local clock = self._bgLayer._clock
			clock:setThePoint(1, clock._EType.e_type_action)
			self:handlePlayCardAction(data)
		end
	end

end

function GameLayer:on_dispenseCard(packageInfo)
	Log.i("GameLayer:on_dispenseCard")
    local info = packageInfo
	local clock = self._bgLayer._clock
    CommonSound.playSound("fapai")
    -- 统一在摸牌里面刷新显示牌数据
    self._bgLayer:refreshRemainCount()
	if packageInfo.userId ~= MjProxy:getInstance():getMyUserId() then
		for i=2,#MjProxy:getInstance()._userIds do
			if packageInfo.userId == MjProxy:getInstance()._userIds[i] then
				clock:setThePoint(i, clock._EType.e_type_play)
				-- self._playLayer._allPlayers[i]:getTheNewMj(1)
    --             self:performWithDelay(function ()
    --                 MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
    --             end,0.6)

                -------- 如果是在回放状态的调用另一个获得麻将接口---------
                if VideotapeManager.getInstance():isPlayingVideo() then
                    self._playLayer._allPlayers[i]:videoGetTheNewMj(info.card)
                    -- MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
                else
                    self._playLayer._allPlayers[i]:getTheNewMj(1)
                    self:performWithDelay(function ()
                        MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
                    end,0.6)
                end
                -----------------------------------------------

			end
		end

		MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
        self._playLayer._allPlayers[MjProxy:getInstance():getPlayerIndexById(packageInfo.userId)]._isDispenseCard = true
	else
--        MjProxy:getInstance()._reflashMyMJ[#MjProxy:getInstance()._reflashMyMJ+1] = info.card
--        Log.i("MjProxy:getInstance()._reflashMyMJ...",MjProxy:getInstance()._reflashMyMJ)
--        display.getRunningScene():performWithDelay(function()
            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
            self._playLayer:setPlayerTouchEnabled(true)
            Log.i("轮到自己打牌")
		    clock:setThePoint(1, clock._EType.e_type_play)
		    self._playLayer._my:getTheNewMj(info.card)
            self._playLayer._my._isDispenseCard = true


            -- self:performWithDelay(function()
            --     MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
            -- end,0.6)

            ----------------录像回放---------------------
            if VideotapeManager.getInstance():isPlayingVideo() then
                -- MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
            else
                self:performWithDelay(function()
                    MjProxy:getInstance():runPopAllMsgCache("dispenseCard")
                end,0.6)
            end
            ---------------------------------------------
--        end,#MjProxy:getInstance()._reflashMyMJ-1)
	end
end

function GameLayer:handlePlayCardAction(data)
    Log.i("handlePlayCardAction","GameLayer:handlePlayCardAction")
	assert(data ~= nil)
	local actionCard = data.doorcard
	if actionCard == 0 then
		actionCard = data.playCard
	end

	local actions = data.actions
	if #actions == 0 then
		return
	end
    local  needSubstitute = false
    if data.playedbyID == MjProxy:getInstance()._players[Define.site_left]:getUserId() then
        needSubstitute = true
    end

    local clock = self._bgLayer._clock
    clock:setNeedSubstitute(needSubstitute)

	if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() then
		Log.d("GameLayer:handlePlayCardAction 已经发送听 actions=", actions)
		local isShowAction = false
		for k, v in ipairs(actions) do
			if v == Define.action_dianPaoHu or v == Define.action_ziMoHu or v == Define.action_mingGang or v == Define.action_anGang or v == Define.action_jiaGang then
				isShowAction = true
				break
			end
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
            Log.d("GameLayer:handlePlayCardAction 已经发送听 needActions=", needActions)
            if #needActions > 0 then
			--     local actionList = ActionList.new(needActions, data)
			-- -- actionList:setPosition(cc.p(0, 180))
			--     self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)

            ---------------- 录像回放相关-------------------
            if VideotapeManager.getInstance():isPlayingVideo() then
                
            else
                local actionList = ActionList.new(needActions, data)
                -- actionList:setPosition(cc.p(0, 180))
                self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
            end
            -------------------------------------------------

		    end
        end
		
	else
		Log.i("GameLayer:handlePlayCardAction 处理操作")	
        local isCanOutMj = false
        local xiazhui = false
		for i=1,#actions do
			if actions[i]  == Define.action_ting or actions[i] == Define.action_jiaGang or actions[i] == Define.action_anGang or actions[i] == Define.action_ziMoHu then 
                isCanOutMj = true
                break
			end
		end
        if #actions > 0 then
            self._playLayer:setPlayerTouchEnabled(isCanOutMj)
		    -- local actionList = ActionList.new(actions, data)
		    -- self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
            ---------------- 录像回放相关-------------------
            if VideotapeManager.getInstance():isPlayingVideo() then
                
            else
                local actionList = ActionList.new(actions, data)
                self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
            end
            -------------------------------------------------
	    end
    end
end

function GameLayer:on_startAniEnd()
	assert(self._playLayer ~= nil)
	self._playLayer:initPlayers()
end  

function GameLayer:on_distrubuteEnd()
	assert(self._playLayer ~= nil)
	for i=1,MjProxy:getInstance():getPlayerCount() do
		MjProxy:getInstance()._players[i]:setFapaiFished(true)
	end
	self._playLayer:onMjDistrubuteEnd()
--    self:performWithDelay(function()
--        self:on_flower()
--    end,0.5)
    if #MjProxy:getInstance()._msgCache > 0 then
        self:performWithDelay(function()
            self:gameStartAction()
        end,#MjProxy:getInstance()._msgCache+0.5)
    else
        self:gameStartAction()
    end
end

-- 开局动作处理（暗杠 胡牌）
function GameLayer:gameStartAction()
    Log.i("GameLayer:gameStartAction","开局动作处理（暗杠 胡牌）")
	local data = MjProxy:getInstance()._gameStartData
    Log.d("data===",data)
	data.isGameStart = true
	if self._isResume then
		data = MjProxy:getInstance()._gameStartData
        data.isGameStart = false
	end

    if #data.actions ~= 0 and data.firstplay == MjProxy:getInstance():getMyUserId() then

        if (#data.actions == 1 and data.actions[1] == Define.action_xiaPao) 
            or (#data.actions == 1 and data.actions[1] == Define.action_laZhuang)
            or (#data.actions == 1 and data.actions[1] == Define.action_zuo) then --开局消息中的下炮不处理

        else
            local isCanOutMj = false
            if not self._isResume then
                local isCanOutMj = false
                for i=1,#data.actions do
                    if data.actions[i]  == Define.action_ting or data.actions[i] == Define.action_jiaGang or data.actions[i] == Define.action_anGang or data.actions[i] == Define.action_ziMoHu then 
                        isCanOutMj = true
                        break
                    end
                end
                self._playLayer:setPlayerTouchEnabled(isCanOutMj)
                -- local actionList = ActionList.new(data.actions, data)
                -- self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)

                ---------------- 录像回放相关 ------------------
                if VideotapeManager.getInstance():isPlayingVideo() then
                    
                else
                    local actionList = ActionList.new(data.actions, data)
                    self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
                end
                ------------------------------------------------------------------
            end
        end
	end
end

function GameLayer:showActionButton(actions,playCard)
--    local playCardData = MjProxy:getInstance()._gameStartData
    Log.d("showActionButton...",playCard)
 --    local actionList = ActionList.new(actions, playCard)
	-- -- actionList:setPosition(cc.p(0, 180))
	-- self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)

    ----------------------- 录像回放相关---------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        
    else
        local actionList = ActionList.new(actions, playCard)
        -- actionList:setPosition(cc.p(0, 180))
        self._playLayer:addChild(actionList, Define.e_zorder_player_layer_action, Define.e_tag_player_layer_action)
    end
    -----------------------------------------------------
end
function GameLayer:on_putDownMj(event)
	assert(self._bgLayer ~= nil)
	self._bgLayer:on_putDownMj(event)
end

function GameLayer:on_action(actionData)
	Log.d("GameLayer:on_action",actionData)
    MjProxy:getInstance():setIsAction(true)
    self:performWithDelay(function()
        MjProxy:getInstance():setIsAction(false)
    end,1)
	local clock = self._bgLayer._clock
	local data = actionData
	local userid = data.userid
	local actionid = data.actionID
    local cards = data.cbCards
	local lastPlayUserId = data.lastPlayUserId
	local lastPlayerindex = MjProxy:getInstance():getPlayerIndexById(lastPlayUserId)
    local index = MjProxy:getInstance():getPlayerIndexById(userid)
    Log.d("lastPlayUserId.....",lastPlayUserId,"lastPlayerindex....",lastPlayerindex)
    self._m_actionId = actionid
    if index > 0 then
        clock:setThePoint(index, clock._EType.e_type_play,lastPlayerindex)
    end

    -- if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then --徐州麻将杠牌打色子
    --     if  actionid == Define.action_anGang or actionid == Define.action_mingGang or actionid == Define.action_jiaGang then
    --         local Tricks = tricks.new(1)
    --         Tricks:addTo(self)
    --         Tricks:diceAnimation(math.random(6), math.random(6), true)   
    --     end        
    -- end

    --延时处理下一个动作
    -- self:performWithDelay(function()
    --     MjProxy:getInstance():runPopAllMsgCache("gameaciton")
    -- end,0.5)

    ----------------录像回放---------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- MjProxy:getInstance():runPopAllMsgCache("gameaciton")
    else
        self:performWithDelay(function()
            MjProxy:getInstance():runPopAllMsgCache("gameaciton")
        end,0.5)
    end
    ---------------------------------------------

	if userid == MjProxy:getInstance():getMyUserId() then
        Log.i("本家操作....")
		if actionid == Define.action_chi 
            or actionid == Define.action_peng 
            or actionid == Define.action_anGang 
            or actionid == Define.action_mingGang 
            or actionid == Define.action_jiaGang then
			-- if data.actionCard < 45 and data.actionCard ~= 41 then
                if actionid ~= Define.action_jiaGang and actionid ~= Define.action_buhua then
                    Log.i("GameLayer   setActionTimes...  本家操作")
                    MjProxy:getInstance()._players[Define.site_self]:setActionTimes(MjProxy:getInstance()._players[Define.site_self]:getActionTimes() + 1)
			    end
			    if actionid ==  Define.action_anGang or actionid ==  Define.action_mingGang then
				    MjProxy:getInstance()._players[Define.site_self]:setGangTimes(MjProxy:getInstance()._players[Define.site_self]:getGangTimes() + 1)
			    end
            -- else
            --     self.m_playerHeadNode:setBuhuaNumber(Define.site_self,data.actionCard)
            -- end
		end
		if actionid == Define.action_chi 
            or actionid == Define.action_peng 
            or actionid == Define.action_mingGang
            or MjProxy:getInstance()._actionData.isBuJG then -- 补加杠则移除最后一个
			--移除别人打出的牌
			self._bgLayer:actionRemoveOutMj(lastPlayerindex,cards[1])
--            self._bgLayer:removeActionPutOutMj(index,cards[1])
        -- 加杠要特殊处理，因为会有弃了然后补杠的问题
        elseif actionid == Define.action_jiaGang then
           
		end

		if actionid == Define.action_ting then
			-- self._playLayer._other:mingPai(MjTool.strToCharTable(data.cbCards))
			-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_ting, gameAnimate.player.my, self._playLayer)
			self._bgLayer:showTingMark(Define.site_self)
		end
        if actionid == Define.action_buhua then
            return
        end

        -------------- 由于有抢杠 所以加杠不做打牌设置---------------------------------
        if actionid == Define.action_jiaGang then
            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
        else
            MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
        end

		self._playLayer._my:handleMyAction(data)
		self._playLayer:setPlayerTouchEnabled(true)
	else
		Log.d("玩家动作。。。",index,"数据....",data,"userid...",userid)
		if actionid == Define.action_chi or actionid == Define.action_peng or actionid == Define.action_anGang or actionid == Define.action_mingGang or actionid == Define.action_jiaGang then
			-- if data.actionCard < 45 and data.actionCard ~= 41 then
                if actionid ~= Define.action_jiaGang then
                    Log.i("GameLayer   setActionTimes...  其他玩家炒作")
				    MjProxy:getInstance()._players[index]:setActionTimes(MjProxy:getInstance()._players[index]:getActionTimes() + 1)
			    
                end			
			    if actionid ==  Define.action_anGang or actionid ==  Define.action_mingGang then
				    MjProxy:getInstance()._players[index]:setGangTimes(MjProxy:getInstance()._players[index]:getGangTimes() + 1)
			    end
            -- else
            --     self.m_playerHeadNode:setBuhuaNumber(index,data.actionCard)
            -- end
		end

		if actionid == Define.action_ting then
			-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_ting, index)
			self._bgLayer:showTingMark(index)
		end

		if actionid == Define.action_chi 
            or actionid == Define.action_peng 
            or actionid == Define.action_mingGang
            or MjProxy:getInstance()._actionData.isBuJG then
			self._bgLayer:actionRemoveOutMj(lastPlayerindex,cards[1])
--            self._bgLayer:removeActionPutOutMj(index,cards[1])
		end
        if actionid ~= Define.action_buhua then
		    self._playLayer._allPlayers[index]:handleOtherAction(data)
            
        end
	end
    
	--[[TODO：操作过后可听或者杠等操作
	if userid == MjProxy:getInstance():getMyUserId() and playLayer._my and playLayer._my._m_bIsAutoPlay == false then
		local actions = MjTool.strToCharTable(data.actions)
		if #actions ~= 0 or #data.table then
			
		
		end
	end]]
end

function GameLayer:on_substitute()
	local data = MjProxy:getInstance()._substituteData
	assert(data ~= nil)

	if data.maPI == MjProxy:getInstance():getMyUserId() then
		local my = self._playLayer._my
		local result = false
		if data.isM == 0 then
			result = false
		elseif data.isM == 1 then
			result = true
		end

		if my then
			my:setAutoPlay(result)
		end
	else
		local site = MjProxy:getInstance():getPlayerIndexById(data.maPI)
		if site > 1 then
			local visible = false
			if data.isM == 0 then
				visible = false
			elseif data.isM == 1 then
				visible = true
			end 
			self._bgLayer:showHeadSubstitute(site, visible)
		end
	end

end

function GameLayer:on_msgGameOver()
	Log.i("处理结算逻辑")
    MjProxy.getInstance():setGameState("gameOver")
	local data = MjProxy:getInstance()._gameOverData
	assert(data ~= nil)
	local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
	audio.stopMusic()
    local clock = self._bgLayer._clock
    if clock then
        clock:clockStop()
    end
    self._playLayer:setPlayerTouchEnabled(false)
	local actionList = self._playLayer:getChildByTag(Define.e_tag_player_layer_action)
	if actionList then
		actionList:removeFromParent()
		actionList = nil
	end
	-- 亮出其他玩家的牌
	local winnerSite = MjProxy:getInstance():getPlayerIndexById(data.winnerId) 

	for i=1,MjProxy:getInstance():getPlayerCount()do
		local lastCard = 0
		if i == winnerSite then
			lastCard = data.scoreItems[i]:getLastCard()
		end
		
		self._playLayer:gameEndMingPai(i, data.scoreItems[i].closeCards, lastCard)
	end
	-- 刷新钱
	for i=1,MjProxy:getInstance():getPlayerCount()do
		for j=1,MjProxy:getInstance():getPlayerCount() do
			if data.scoreItems[i]:getUserId() == MjProxy:getInstance()._players[j]:getUserId() then
				self._bgLayer:setMoney(j, data.scoreItems[i]:getTotalCash())
                MjProxy:getInstance()._players[j]:setFortune(data.scoreItems[i]:getTotalCash())
			end
		end
	end

	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
	layer:addTo(self)
	Log.d("GameLayer:on_msgGameOver winnerSite="..winnerSite..';winType='..data.winType)
	local showResult = false
    local isPaoPei = false
	 if winnerSite == 1 then
	    showResult = true
        local pon = MjProxy:getInstance()._gameOverData.scoreItems[winnerSite].policyName
        if pon ~= nil and #pon> 0 then 
            for i=1, #pon do
                if pon[i] == "跑配" then
                    isPaoPei = true
                end
            end
        end
	 end

	 if data.huCount > 1 then --一炮多响
	     showResult = true

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        local armature = ccs.Armature:create("yipaoduoxiang")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)
	 end

	if data.winType == 3 then --流局了
	 	showResult = true
        CommonSound.playSound("liuju")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/liuju.csb")
        local armature = ccs.Armature:create("liuju")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
                 armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)

        self._bgLayer:setRemainPaiCount()
        ------------ 流局不显示流局界面录像回放相关-----------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            return      
        end
        ------------------------------------------------------
	end

	-- 结算界面
    local delayTime = 1
    if isPaoPei == true and MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
        delayTime = 3
        self:performWithDelay(function ()
            local paoPeiAnimLayer = PaoPeiAnimLayer.new()
            cc.Director:getInstance():getRunningScene():addChild(paoPeiAnimLayer)
            paoPeiAnimLayer:performWithDelay(function ()
                paoPeiAnimLayer:removeFromParent()
            end, 2)
        end, 1)        

    end
	self:performWithDelay(function ()
		layer:removeFromParent()
  --       self.m_gameOverDialogUI = GameOverDialog.new()
		-- cc.Director:getInstance():getRunningScene():addChild(self.m_gameOverDialogUI);
            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);   
		--朋友开房逻辑特殊处理
		if(kFriendRoomInfo:isFriendRoom()) then
			-- local tmpData={}
			-- tmpData.gameoverUI = self.m_gameOverDialogUI;
			-- local tmpScene = MjMediator:getInstance():getScene();
			-- tmpScene.m_friendOpenRoom:onShowGameOverUI(tmpData);	

        else
            -- Log.i("结算了.....")
            -- local roomInfo = MjProxy:getInstance():getRoomInfo()
            -- if kUserInfo:getMoney() < roomInfo.thM and roomInfo.ta == 1 and kSubsidyInfo:isCanSubsidy() then
            --     self:performWithDelay(function()
            --         UIManager:getInstance():pushWnd(SubsidyWnd);
            --     end, 0.5);
            -- end            
		end
		
	end, delayTime)
	
end

function GameLayer:on_msgChat()
	local players = MjProxy:getInstance()._players
    local chatData = MjProxy:getInstance()._chatData
    for i,v in pairs(players) do
        if chatData.usI == v:getUserId() then
            if chatData.ty == 0 then
                local site = i
--                self._playerChat:showChat(chatData, site);
                  self.m_playerHeadNode:showChat(1,site,chatData)
                break;
            end
        end
    end
end
--

--检测上传状态
function GameLayer:getUploadStatus()
    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end
    self.m_getUploadThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end, 0.1);
end

function GameLayer:onUpdateUploadStatus(info)
    Log.d("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
        self.m_getUploadThread = nil;
        local matchStr = string.match(info.fileUrl,"http://");
        Log.d("--------onUpdateUploadStatus", matchStr);

        --发送语音聊天
        if matchStr and kFriendRoomInfo:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = kUserInfo:getUserId();
            tmpData.niN = kUserInfo:getUserName();
            tmpData.roI = kFriendRoomInfo:getRoomInfo().roI;
            tmpData.ty = 1;
            tmpData.co = info.fileUrl;
            FriendRoomSocketProcesser.sendSayMsg(tmpData);
        end
    end
end

--检测播放状态
function GameLayer:getSpeakingStatus()
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end
    self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end, 0.5);
end

function GameLayer:onUpdateSpeakingStatus(info)
    Log.d("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        self.m_getSpeakingThread = nil;

        MjMediator:getInstance():on_hideSpeaking(info.usI); 
    end
end

function GameLayer:on_speaking(packetInfo)
    if not YY_IS_LOGIN then
        --语音初始化失败
        return;
    end
    if self.m_speaking or self.m_isTouchBegan then
        if #self.m_speakTable < 10 then
          table.insert(self.m_speakTable, packetInfo);
        end
    else
        local players = MjProxy:getInstance()._players
        for i, v in pairs(players) do
            if packetInfo.usI == v:getUserId() then
                self.m_speaking = true;
                -- self._playerChat:showSpeaking(i);
                -- 显示说话的语音条
                self.m_playerHeadNode:showSpeakPanel(i)
                --
                audio.pauseMusic();
                --
                local data = {};
                data.cmd = NativeCall.CMD_YY_PLAY;
                data.fileUrl = packetInfo.co;
                data.usI = packetInfo.usI .. "";
                NativeCall.getInstance():callNative(data);             
                self:getSpeakingStatus();
                --防止没有收到播放结束回调
                self.m_gameUIView:stopButtonAction()
                self:performWithDelay(function()
                   self.m_playerHeadNode:hideSpeakPanel(i)
                end, 60);

                break;
            end
        end
    end
end

function GameLayer:on_hideSpeaking(userId)
    Log.i("------GameLayer:on_hideSpeaking userId", userId);
    userId = userId or "0";
    local players = MjProxy:getInstance()._players;
    for i, v in pairs(players) do
        -- if tonumber(userId) == v:getUserId() then
        --     -- self._playerChat:hideSpeaking(i);
        --     -- 隐藏说话的语音条
        --     self.m_playerHeadNode:hideSpeakPanel(i)
        --     break;
        -- end
        self.m_playerHeadNode:hideSpeakPanel(i);
    end
    self.m_speaking = false;
    if not self.m_speaking and #self.m_speakTable > 0 then
        self:on_speaking(table.remove(self.m_speakTable, 1));
    else
        self:hideMic();
    end
end

function GameLayer:on_msgDefaultChar()
    Log.i("GameLayer:on_msgDefaultChar")
    local players = MjProxy:getInstance()._players
    local defaultChar = MjProxy:getInstance()._defaultChar
    local sSeat = MjProxy:getInstance():getPlayerIndexById(defaultChar.reI)
    Log.d("defaultChar......",defaultChar,"sSeat...",sSeat)
    for i,v in pairs(players) do
        if defaultChar.usI == v:getUserId() then
            if defaultChar.ty == 3 then
                self._bgLayer:showMoFaBiaoQing(sSeat,defaultChar,i)
            else
                local site = i
--                self._playerChat:showDefaultChat(defaultChar,site)
                self.m_playerHeadNode:showChat(2,site,defaultChar)
            end
        end
    end
end
function GameLayer:on_msgProp()
    local magicID = MjProxy:getInstance()._propData.PropId
    local fid = MjProxy:getInstance()._magicIDFid[magicID]
    local propCount = MjProxy:getInstance()._propCount[fid]
    local fromUserID = MjProxy:getInstance()._propData.FromUserId
    local fromSite = fromUserID == MjProxy:getInstance():getMyUserId() and Define.site_self or Define.site_other
    local toSite = fromSite == Define.site_self and Define.site_other or Define.site_self

    if propCount > 0 then
        MjProxy:getInstance()._propCount[fid] = propCount - 1
    end
  
end

function GameLayer:on_msgBuyProp()
    local buyPropData = MjProxy:getInstance()._buyPropData

    if buyPropData.result == 0 then
        local money = ww.mj.waBean
        local price = buyPropData.buyPrice
        MjProxy:getInstance():setWaBean(tonumber(buyPropData.userCash))

        local label = cc.Label:createWithSystemFont("-" .. price, "", 24)
        label:setTextColor(cc.c3b(0xbc, 0xff, 0xb1))
        label:setPosition(cc.p(525, 40))
        self:addChild(label, 1)

        label:runAction(cc.Sequence:create(
        		cc.Spawn:create(cc.EaseIn:create(cc.FadeOut:create(1), 2), 
                    cc.EaseOut:create(cc.MoveBy:create(1, cc.p(0, 100)), 2)),
				cc.RemoveSelf:create()))
    elseif buyPropData.result == 1 then
        WWFacade:dispatchCustomEvent(COMMON_EVENTS.SHOW_TOAST, "主人，您的蛙豆太少啦，要不充个值？", 2)
    else
        WWFacade:dispatchCustomEvent(COMMON_EVENTS.SHOW_TOAST, "使用道具失败!", 2)
    end

    -- if self._bgLayer and self._bgLayer._myNode then
    --     self._bgLayer._myNode:refreshUserData()
    -- end
end

function GameLayer:on_continueReady(userIds)
	-- local sites = {} 
	for i=1, #userIds do
        local site = MjProxy:getInstance():getPlayerIndexById(userIds[i])
        self.m_playerHeadNode:showReadySpr(site)
	end
    
end

function GameLayer:on_removeContinueReady()
	self._bgLayer:removeContinueReadyUi()
end

function GameLayer:on_showPaoMaDeng(content)
	self._bgLayer:on_showPaoMaDeng(content)
end

function GameLayer:on_updateTakenCash(info)
	if info and info.usI then
		local site = MjProxy:getInstance():getPlayerIndexById(info.usI)
		self._bgLayer:setMoney(site, info.ca)
	end
	
end

function GameLayer:on_dismissDesk(info)
    self._bgLayer:on_dismissDesk(info)
    
end

function GameLayer:handleLeaveStatus(info)
    local visible = false
    if info.leS == 0 then
        visible = false
    elseif info.leS == 1 then
        visible = true
    end
    local site = MjProxy:getInstance():getPlayerIndexById(info.plI)
    if site > 1 then
        self._bgLayer:showHeadSubstitute(site, visible)
    end
end
--[[
-- @brief  下跑函数
-- @param  void
-- @return void
--]]
function GameLayer:on_xiaPaoOrLaZhuang()
    -- 所有玩家都下炮了
    if MjProxy:getInstance():getXiaPaoFinished() == true then
        -- 设置恢复对局
        self.m_gameUIView:hideXiaPaoOrLaPanel()
        MjProxy:getInstance():setResume(false)  
        self._isResume = false
        self:showUi()
        local clock = self._bgLayer._clock
        if clock then
            clock:clockTick()
        end
    else
      
    end
    local data  = MjProxy:getInstance()._actionData
    local index = MjProxy:getInstance():getPlayerIndexById(data.userid)
    local num   = MjProxy:getInstance()._players[index]:getFillingNumByType(data.actionID)
    self.m_playerHeadActions:upDateXiaOrLaNum(index, data.actionID, num)
end

--[[
-- @brief  回放操作的字函数
-- @param  void
-- @return void
--]]
------------------ 回放相关----------------------------
function GameLayer:on_actionWord()
    local data  = MjProxy:getInstance()._actionData
    local userid = data.userid
    local index = MjProxy:getInstance():getPlayerIndexById(userid)
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- 加入录像回放控制层
        self._videoLayer:onShowActionLab(data, index)
    end
end
-------------------------------------------------------

function GameLayer:onExit()
    Log.i("GameLayer:onExit#######################");
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end
end

return GameLayer