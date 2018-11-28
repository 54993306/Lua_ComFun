-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- 两边玩家

local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local MjSide = require "app.games.huaibeimj.mediator.game.model.MjSide"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local MJArmatureCSB = require("app.games.huaibeimj.custom.MJArmatureCSB")

local PlayerRight = class("PlayerRight", function ()
	return display.newNode()
end)
local kHandGap = 35
function PlayerRight:ctor()
	-- Log.i("PlayerRight:ctor")
	self.m_arrMj = { }
	self.m_showMjBg = nil
	self.m_playMj = 0
	self.m_arrMingMj = { }

	self.m_newMj = nil
    self._isDispenseCard = false
end

function PlayerRight:recoveryMj()
	Log.i("PlayerRight:recoveryMj")
	local data = MjProxy:getInstance()._gameStartData
	local topencard = MjProxy:getInstance()._players[Define.site_right].m_openCards
	local topencardType = MjProxy:getInstance()._players[Define.site_right].m_openCardsType
	local openCardsUserIds = MjProxy:getInstance()._players[Define.site_right].m_openCardsUserIds
	local openActionCards = MjProxy:getInstance()._players[Define.site_right].m_openActionCards

	Log.i("PlayerRight:recoveryMj topencard=", topencard)
	Log.i("PlayerRight:recoveryMj topencardType=", topencardType)
	Log.i("PlayerRight:recoveryMj openCardsUserIds=", openCardsUserIds)	
	Log.i("PlayerRight:recoveryMj openActionCards=", openActionCards)	

	if #topencard ~= #topencardType then
		Log.i("右家恢复对局操作的牌类型和牌值数量不一致")
	end

	-- local nPai = 13
	-- if data.bankPlay == MjProxy:getInstance()._userIds[Define.site_right] then
	-- 	nPai = 14
	-- end

	for i = 0, #topencard - 1 do
		local card = topencard[i + 1]
		local action = topencardType[i + 1]
		local userId = openCardsUserIds[i + 1]
		local actionCard  = openActionCards[i + 1]
        -- if card <45 and card ~= 41 then
            Log.i("playerRight   setActionTimes...")
		    MjProxy:getInstance()._players[Define.site_right]:setActionTimes(MjProxy:getInstance()._players[Define.site_right]:getActionTimes() + 1)
        -- else
        --     local gameLayer = self:getParent():getParent()
        --     gameLayer.m_playerHeadNode:setBuhuaNumber(Define.site_right,card)
        -- end
		local table = nil
		if action == Define.action_chi then
			
			table = { card, card + 1, card + 2 }	
		elseif action == Define.action_peng then
			table = { card, card, card }
		elseif action == Define.action_mingGang or action == Define.action_anGang or action == Define.action_jiaGang then
            Log.i("aaaaaa....",card)
            table = { card, card, card, card }
		    if action ~= Define.action_jiaGang then
			    MjProxy:getInstance()._players[Define.site_right]:setGangTimes(MjProxy:getInstance()._players[Define.site_right]:getGangTimes() + 1)
		    end
		end
		self:drawActionMajiang(MjProxy:getInstance()._actionData, action, table, true, userId, actionCard)
	end

	local actionPaiHeight = Define.g_right_gang_pai_space *( MjProxy:getInstance()._players[Define.site_right]:getActionTimes() ) + kHandGap
	self.m_arrMj = { }
	local nPai = MjProxy:getInstance()._players[Define.site_right]:getCardNum()
	Log.i("PlayerRight:recoveryMj nPai", nPai)

	local statY = Define.g_right_action_pai_start_y
	if nPai >=13 then
		statY = Define.g_right_pai_start_y
	end
	for i = 0, nPai - 1 do
		local mj = display.newSprite("#right_poker.png")
		mj:setPosition(cc.p(Define.g_right_pai_x, statY +Define.g_side_pai_height * i + actionPaiHeight))
		mj:setLocalZOrder(nPai-1-i)
        mj:setScale(Define.majiang_shoupai_zuoyou_scale)
		self:addChild(mj)
		mj:retain()
		table.insert(self.m_arrMj, mj)
	end
end

function PlayerRight:distrMj()
	self:distrMjAction(1)
    
end

function PlayerRight:getTheNewMj(mj)
    Log.i("右家摸新牌")
    local gameLayer = self:getParent():getParent()
    -- 刷新界面剩余牌数
    -- gameLayer._bgLayer:refreshRemainCount()
--	Sound.effect("effect16")
	self.m_arrMj = self.m_arrMj or { }
	if #self.m_arrMj == 0 then
		return
	end

    local lastMj = self.m_arrMj[#self.m_arrMj]
    local rsMj = self.m_arrMj[#self.m_arrMj-1]
    if lastMj ~= nil and rsMj ~= nil then
        local lastPos_x,lastPos_y = lastMj:getPosition()
        local rsPos_x,rsPos_y = rsMj:getPosition()
        if lastPos_y > rsPos_y + Define.g_side_pai_height then
            lastMj:setPosition(cc.p(rsPos_x,rsPos_y + Define.g_side_pai_height))
        end
    end
	local newPaiY = self.m_arrMj[#self.m_arrMj]:getPositionY() + Define.g_side_pai_height

	self.m_newMj = display.newSprite("#right_poker.png")
	self.m_newMj:setOpacity(200)
	self.m_newMj:setLocalZOrder(self.m_arrMj[#self.m_arrMj]:getLocalZOrder() - 1)
	self.m_newMj:setPosition(cc.p(Define.g_right_pai_x, newPaiY + 5)):addTo(self)
    self.m_newMj:setScale(Define.majiang_shoupai_zuoyou_scale)
	self.m_newMj:retain()
	table.insert(self.m_arrMj, self.m_newMj)
	
end

function PlayerRight:playMj(mj)
	self.m_playMj = mj

	-----------录像回放新加入的内容---------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:videoPlayMj(mj)
		return
	end
	-----------------------------------------------------

	self.m_arrMj = self.m_arrMj or { }
	if #self.m_arrMj ~= 0 then
		local sps = self.m_arrMj[#self.m_arrMj]
		sps:removeFromParent()
		sps = nil
		table.remove(self.m_arrMj, #self.m_arrMj)
	end

    local lastMj = self.m_arrMj[#self.m_arrMj]
    local rsMj = self.m_arrMj[#self.m_arrMj-1]
    if lastMj ~= nil and rsMj ~= nil then
        local lastPos_x,lastPos_y = lastMj:getPosition()
        local rsPos_x,rsPos_y = rsMj:getPosition()
        if lastPos_y > rsPos_y + Define.g_side_pai_height then
            lastMj:setPosition(cc.p(rsPos_x,rsPos_y + Define.g_side_pai_height))
        end
    end
	if self.m_showMjBg ~= nil then
		self.m_showMjBg:removeFromParent()
		self.m_showMjBg = nil
	end

	self.m_showMjBg = display.newSprite("games/common/mj/games/bg_big_out_poker.png")
	self.m_showMjBg:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])
	self.m_showMjBg:setPosition(cc.p(Define.g_right_show_pai_x, Define.g_right_show_pai_y)):addTo(self:getParent():getParent(),100)

	local temp =Mj.new(mj, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	temp:setPosition(cc.p(self.m_showMjBg:getContentSize().width / 2, self.m_showMjBg:getContentSize().height / 2))
	self.m_showMjBg:addChild(temp)
	self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
		return self:putDownMjAction()
	end )))
end

function PlayerRight:refreshMj(action)
	self.m_arrMj = self.m_arrMj or { }
	for k, v in ipairs(self.m_arrMj) do
		v:removeFromParent()
		v = nil
	end
	self.m_arrMj = nil
	local nPai = 13
	nPai = nPai - (MjProxy:getInstance()._players[Define.site_right]:getActionTimes()-1)*3
    if action == Define.action_chi or action == Define.action_peng then
        nPai = nPai - 2
    else
	    nPai = nPai - 3
    end
	local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()  + kHandGap
	Log.i("getActionTimes..........",MjProxy:getInstance()._players[Define.site_left]:getActionTimes(),actionPaiHeight,nPai,Define.g_side_gang_pai_space)
	self.m_arrMj = self.m_arrMj or { }
	for i = 1, nPai do
		local mj = display.newSprite("#right_poker.png")
		mj:setLocalZOrder(nPai-1-i)
        mj:setScale(Define.majiang_shoupai_zuoyou_scale)
		mj:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y +Define.g_side_pai_height * (i-1) + actionPaiHeight))
		mj:addTo(self)
		mj:retain()
		table.insert(self.m_arrMj, mj)
	end
end

function PlayerRight:drawActionMajiang(data, actionType, cards, isRecovery, userId, actionCard)
	assert(type(cards) == "table" and #cards ~= 0)
	local mj = cards[1]

	isRecovery = isRecovery or false
	if actionType == Define.action_jiaGang and isRecovery == true then
		actionType = Define.action_mingGang
	end

    if actionType == Define.action_chi or actionType == Define.action_peng then
		self:drawActionThree(data,cards, actionType, userId, actionCard)
	elseif actionType == Define.action_anGang or actionType == Define.action_mingGang then
		self:drawActionFour(data, cards, actionType, userId)
	end

	if actionType == Define.action_jiaGang and isRecovery == false then
		Log.i("右家绘制加杠")

		local actionNode = self:getChildByTag(150 + mj)
		if actionNode then
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
            Log.i("加杠。。。。。",mj,"lastPlayerIndex....",lastPlayerIndex)
            local xPre = 5
            local yPre = 8
			local node = MjSide.new(mj, MjSide._EType.e_type_action_tang, MjSide._ESide.e_side_right)
            if lastPlayerIndex == 1 then
	            node:setPosition(cc.p(actionNode:getPositionX() - Define.g_side_tang_pai_width - xPre, actionNode:getPositionY()))
	            node:setLocalZOrder(actionNode:getLocalZOrder())
            elseif lastPlayerIndex == 3 then         
                node:setPosition(cc.p(actionNode:getPositionX() - Define.g_side_tang_pai_width - xPre, actionNode:getPositionY()))
	            node:setLocalZOrder(actionNode:getLocalZOrder() - 1)

            elseif lastPlayerIndex == 4 then          
               	node:setPosition(cc.p(actionNode:getPositionX() - Define.g_side_tang_pai_width - xPre, actionNode:getPositionY()))
	            node:setLocalZOrder(actionNode:getLocalZOrder() - 1)
            end
            node:addTo(self)
            node:setAnchorPoint(cc.p(0, -0.5))
            for i=1, #MjProxy:getInstance()._players[Define.site_right].m_arrMyActionType do
            	if MjProxy:getInstance()._players[Define.site_right].m_arrMyActionType[i] == Define.action_peng then
            		if MjProxy:getInstance()._players[Define.site_right].m_arrMyActionMj[i][1] == mj then
						MjProxy:getInstance()._players[Define.site_right].m_arrMyActionType[i] = actionType
						MjProxy:getInstance()._players[Define.site_right].m_arrMyActionMj[i] = {mj, mj, mj, mj}
            		end
            	end
            end
		end
		return
	end

	if actionType == Define.action_chi then
		mj = mj + 100
	end
	local lastPlayerIndex = 0
	if userId == nil then
        lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(data.lastPlayUserId)
    else
        lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(userId)
    end
    if actionType ~= Define.action_buhua and actionType ~= Define.action_jiaGang then
        Log.i("PlayerRight添加动作牌....",cards)
	    table.insert(MjProxy:getInstance()._players[Define.site_right].m_arrMyActionMj, cards)
	    table.insert(MjProxy:getInstance()._players[Define.site_right].m_arrMyActionType, actionType)
	   	table.insert(MjProxy:getInstance()._players[Define.site_right].m_arrLastPlayerIndexs, lastPlayerIndex)
    end
end

function PlayerRight:getChiActionIndex(cards, actionCard)
	local lastPlayerIndex = 1
	for i=1, #cards do
		if actionCard == cards[1] then
			lastPlayerIndex = 1
		elseif actionCard == cards[2] then
			lastPlayerIndex = 4
		elseif actionCard == cards[3] then
			lastPlayerIndex = 3
		end
	end
	return lastPlayerIndex
end

function PlayerRight:drawActionThree(data, mjs, actionType, userId, actionCard)
	local lastPlayerIndex = 0
    if userId == nil then
       lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(data.lastPlayUserId)
       if actionType == Define.action_chi then
       		local cbCards = data.cbCards
       		lastPlayerIndex = self:getChiActionIndex(cbCards, data.actionCard )
       end
    else
       lastPlayerIndex = MjProxy:getInstance():getPlayerIndexById(userId)

       if actionType == Define.action_chi then
       		if actionCard and actionCard ~=0 then
       			lastPlayerIndex = self:getChiActionIndex(mjs, actionCard )
       		end
       end
    end
    if lastPlayerIndex == 2 then
   		lastPlayerIndex = 1
    end
--    lastPlayerIndex = userId
    Log.i("PlayerRight:drawActionThree lastPlayerIndex=", lastPlayerIndex)
	local gangTimes = MjProxy:getInstance()._players[Define.site_right]:getGangTimes()
	local actionTimes = MjProxy:getInstance()._players[Define.site_right]:getActionTimes() - gangTimes
	if actionTimes < 0 then
		actionTimes = 0
	end
	local actionPaiHeight = Define.g_right_peng_pai_space *actionTimes + Define.g_right_peng_pai_space*(gangTimes-1)
    Log.i("gangTimes:",gangTimes)
    Log.i("actionTimes:",actionTimes)
	Log.i("actionPaiHeight:",actionPaiHeight)
	for i = 0, 2 do
		local node = nil
		local xPre = 8
        local yPre = -11
        local yPosit = 6
	    local mj = mjs[1]
		if actionType == Define.action_chi then
			mj = mjs[i+1]
		end
		if lastPlayerIndex == 1 then --上家
			if i == 0 then
				node = MjSide.new(mj, MjSide._EType.e_type_action_tang, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x + xPre, Define.g_right_action_pai_start_y  + actionPaiHeight-4+yPosit+1))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + (i -1) * Define.g_right_action_pai_height  + Define.g_side_tang_pai_height+ actionPaiHeight+yPre+yPosit+1))				
			end

		elseif lastPlayerIndex == 3 then --下家

			if i == 2 then
				node = MjSide.new(mj, MjSide._EType.e_type_action_tang, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x + xPre, Define.g_right_action_pai_start_y + 2 * Define.g_right_action_pai_height  + actionPaiHeight+yPosit))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_right_action_pai_height + actionPaiHeight-8+yPosit))
			end
		elseif lastPlayerIndex == 4 then --对家
			if i == 1 then
            	node = MjSide.new(mj, MjSide._EType.e_type_action_tang, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x + xPre, 
					Define.g_right_action_pai_start_y + Define.g_right_action_pai_height  + actionPaiHeight-3+yPosit+3))
                if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
            elseif i == 0 then
				node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y+ actionPaiHeight-10+yPosit))
			elseif i == 2 then
				node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
				node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + Define.g_right_action_pai_height  + Define.g_side_tang_pai_height + actionPaiHeight+yPre+yPosit+3))
			end			
		end
		node:setLocalZOrder(2-i+14-(actionTimes+gangTimes)*3)
		node:addTo(self)
		node:setAnchorPoint(cc.p(0, -0.5))
	end
    local threeArray = {}
    threeArray.mj = mjs[1]
    threeArray.playerIndex = lastPlayerIndex
    threeArray.actionTimes = actionTimes
    self:setActionThreeArray(threeArray)
end

function PlayerRight:setActionThreeArray(mjArray)
    
    if self._actionThreeArray == nil then
        self._actionThreeArray = {}
    end
--    Log.i("PlayerRight:setActionThreeArray....",mjArray)
    self._actionThreeArray[#self._actionThreeArray +1] = mjArray
end
function PlayerRight:getActionThreeArray()
--    Log.i("PlayerRight:getActionThreeArray....",self._actionThreeArray)
    return self._actionThreeArray or {}
end


function PlayerRight:drawActionThreeGang(data,mj, actionType)
	 local gangTimes = MjProxy:getInstance()._players[Define.site_right]:getGangTimes() 
	local actionTimes = MjProxy:getInstance()._players[Define.site_right]:getActionTimes() - MjProxy:getInstance()._players[Define.site_right]:getGangTimes() 
	if actionTimes < 0 then
		actionTimes = 0
	end
	local actionPaiHeight =  Define.g_right_peng_pai_space *actionTimes + Define.g_right_peng_pai_space*(gangTimes-1)
    local yPosit = -10
	for i = 0, 2 do
		local node = nil
		if actionType == Define.action_anGang then
			node = display.newSprite("#right_gang_poker.png")
			node:setAnchorPoint(cc.p(0.5, 0))
		else
			node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
			node:setAnchorPoint(cc.p(0, -0.5))
		end
		node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_right_pai_tang_heigh + actionPaiHeight+yPosit))
		node:setLocalZOrder(3-i)
		node:addTo(self)

		if i == 1 and(actionType == Define.action_peng or actionType == Define.action_mingGang or actionType == Define.action_anGang or actionType == Define.action_jiaGang) then
			node:setTag(150 + mj)
		end

		if actionType == Define.action_chi then
			mj = mj + 1
		end
	end
end

function PlayerRight:drawActionFour(data, mjs, actionType, userId)
	local mj = mjs[1]
    if actionType == Define.action_anGang then
	    self:drawActionThreeGang(data, mj, actionType)
    else
        self:drawActionThree(data, mjs, actionType, userId)
    end
	local actionNode = self:getChildByTag(150 + mj)
	if actionNode then
		local node = nil
		if actionType == Define.action_anGang then
--			node = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
            node = display.newSprite("#right_gang_poker.png")
            node:setPosition(cc.p(actionNode:getPositionX()-Define.g_right_pai_tang_width/2, actionNode:getPositionY()-Define.g_right_pai_tang_heigh/2 + 8 ))
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:addTo(self,3)
		else
            local xPre = 5
			node = MjSide.new(mj, MjSide._EType.e_type_action_tang, MjSide._ESide.e_side_right)
            node:setPosition(cc.p(actionNode:getPositionX() - Define.g_side_tang_pai_width - xPre, actionNode:getPositionY()))
            node:addTo(self, actionNode:getLocalZOrder())
		end
		
        node:setAnchorPoint(cc.p(0, -0.5))
	else
		Log.i("drawActionThree 没找到 %s 的tag值", tostring(mj))
	end
end

function PlayerRight:handleOtherAction(data)
	Log.i("PlayerRight:handleOtherAction")
	Log.i("PlayerRight:handleOtherAction 右家处理操作数据",data)
	assert(data ~= nil)
	------------------- 视频回放功能--------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:handleVideoOtherAction(data)
		return 
	end
	----------------------------------------------
	local actionType = data.actionID
	local actionCard = data.actionCard

	Log.i("PlayerRight:handleOtherAction 打印右家的cbCards", data.cbCards)

	local cards = data.cbCards or { }


	local gender = MjProxy:getInstance()._players[Define.site_right]:getGender()

    local action = nil
	-- 听
	if actionType == Define.action_ting then
		
        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_right)
	    Sound.effect_ting(MjProxy.getInstance()._players[Define.site_right]:getSex())
    --补花
--     elseif actionType == Define.action_buhua then
--         if self._isDispenseCard == false then
--             Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_right]:getSex(),true)
--         else
--             Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_right]:getSex())
--         end
--         CommonSound.playSound("buhua")
--         action = MjMediator:getInstance():on_payerAction("AnimationBUHUA",1,Define.site_right)
--         self._rightFlower = self._rightFlower or {}
--         self._rightFlower[#self._rightFlower+1] = data.actionCard
-- --        Log.i("补花_rightFlower...",self._rightFlower)
--         self:showBuHua(self._rightFlower)
--         for i,v in pairs(self.m_arrMj) do
--             if v._value == data.actionCard then
--                 self.m_arrMj[i]._value = data.actionCard
--             end
--         end
		-- 吃
	elseif actionType == Define.action_chi then
		Sound.effect_chi(MjProxy.getInstance()._players[Define.site_right]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_right)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_chi, gameAnimate.player.right, self:getParent())
		self:drawActionMajiang(data, actionType, cards)

		self:refreshMj(Define.action_chi)
		-- 碰	
	elseif actionType == Define.action_peng then
		Sound.effect_peng(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_right)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_peng, gameAnimate.player.right, self:getParent())
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_peng)
		-- 明杠
	elseif actionType == Define.action_mingGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.right, self:getParent())
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_mingGang)
		-- 暗杠
	elseif actionType == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
        local mj = cards[1]
        -- if mj == 41 or mj >=45 then
        --     self.m_arrMj = self.m_arrMj or { }
	       --  if #self.m_arrMj ~= 0 then
		      --   local sps = self.m_arrMj[#self.m_arrMj]
		      --   sps:removeFromParent()
		      --   sps = nil
		      --   table.remove(self.m_arrMj, #self.m_arrMj)
	       --  end
        --     return
        -- end
--         gameAnimate.showAnimate(end1meAnimate.animate_type.e_type_gang, gameAnimate.player.right, self:getParent())
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_anGang)
		-- 加杠
	elseif actionType == Define.action_jiaGang then
		Log.i("右家加杠 actionType == Define.action_jiaGang")
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
		-- gameAnimate.showAnimate(gameAnimate.animate_type.e_type_gang, gameAnimate.player.right, self:getParent())
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_jiaGang)
		-- 点炮胡
	elseif actionType == Define.action_dianPaoHu then
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(data.lastPlayUserId))
		action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_right)
        MjMediator:getInstance():on_playerHU(Define.mj_rightCards_position_x-10,display.cy)
        if result == 3 then
			-- 加倍

			-- local node = require ("app.games.huaibeimj.mediator.game.model.JiabeiAction").new(false, self:getParent())
			-- self:getParent():addChild(node)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 自摸糊
	elseif actionType == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_right)
        MjMediator:getInstance():on_playerHU(Define.mj_rightCards_position_x-10,display.cy)
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			-- 加倍

			-- local node = require ("app.games.huaibeimj.mediator.game.model.JiabeiAction").new(false, self:getParent())
			-- self:getParent():addChild(node)
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 加倍
	elseif actionType == Define.action_jiaBei then
--		

		-- local node = require ("app.games.huaibeimj.mediator.game.model.JiabeiAction").new(false, self:getParent())
		-- self:getParent():addChild(node)
	end
end

function PlayerRight:showBuHua(mj)
	local gameLayer = self:getParent():getParent()
	if gameLayer then
		gameLayer:refreshFlower(Define.site_right, mj)
	end

    local gameid = MjProxy:getInstance():getGameId()
    if gameid == Define.gameId_xuzhou then
	    gameLayer._bgLayer:refreshRemainPaiCount()
    elseif gameid == Define.gameId_changzhou then
        gameLayer._bgLayer:refreshRemainCount()
    end
end

function PlayerRight:gameEndMingPai(cards, card)
	assert(type(cards) == "table")
    CommonSound.playSound("tuipai")
	if self.m_arrMj then
		for k, v in ipairs(self.m_arrMj) do
			v:removeFromParent()
			v = nil
		end
		self.m_arrMj = nil
	end
	-- local gangTimes = MjProxy:getInstance()._players[Define.site_right]:getGangTimes()
	-- local actionTimes = MjProxy:getInstance()._players[Define.site_right]:getActionTimes() -gangTimes 
	-- if actionTimes < 0 then
	-- 	actionTimes = 0
	-- end
	local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()+ kHandGap
	for i = 0, #cards - 1 do
		local node = MjSide.new(cards[i + 1], MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
		-- node:setLocalZOrder(cards - 1 -i)
		node:setLocalZOrder(1-i+14)
		node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_side_end_ming_pai_height + actionPaiHeight))
		node:addTo(self)
	end
	-- local count = actionTimes*3 + gangTimes*4 + #cards
	-- if count > 13 then
	-- 	return
	-- end
    local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置

	if card ~= 0 and winnerSite == Define.site_right then
		local node = MjSide.new(card, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
		node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + 20 + #cards * Define.g_side_end_ming_pai_height + actionPaiHeight))
		node:addTo(self)
	end

end


function PlayerRight:distrMjAction(times)
	Log.i("PlayerRight:distrMjAction %s", tostring(times))

	local data = MjProxy:getInstance()._gameStartData
	if data == nil or data == { } then
		return
	end
	local nPai = 13
	if data.bankPlay == MjProxy:getInstance()._userIds[Define.site_right] then
		nPai = 14
	end	

	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > nPai then
		to = nPai
	end
	local index = 0
	local backPokerSprite = display.newSprite("#right_gang_poker.png")
	-- backPokerSprite:setLocalZOrder(10)
	if to - from > 0 then
		for i=1,to - from +1 do
			local pokerSprite = display.newSprite("#right_gang_poker.png")
			pokerSprite:setAnchorPoint(cc.p(0.5, 0))
			pokerSprite:addTo(backPokerSprite)
			pokerSprite:setLocalZOrder(backPokerSprite:getLocalZOrder()-i)
			pokerSprite:setPosition(cc.p(backPokerSprite:getContentSize().width/2,Define.g_side_pai_height*i - Define.g_side_pai_height))
		end		
	end
	backPokerSprite:setOpacity(255)
	backPokerSprite:setCascadeOpacityEnabled(true)
	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = display.newSprite("#right_poker.png")
				mj:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_pai_start_y + (from+i -2) * Define.g_side_pai_height )):addTo(self)
				mj:setLocalZOrder(nPai-i -from)
                mj:setScale(Define.majiang_shoupai_zuoyou_scale)
				self.m_arrMj[#self.m_arrMj + 1] = mj
			end		
			if 	times < 5 then
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function ()
					self:distrMjAction(times)
				end)))					
			end

			---------------回放相关-----------------
			if times == 5 then
				if VideotapeManager.getInstance():isPlayingVideo() then
					local userid = MjProxy:getInstance()._players[Define.site_right]:getUserId()
					local palyerInfo = kPlaybackInfo:getStartGameContentByid(userid)
					self:gameVideoMingPai(palyerInfo.clC, 0)
				end
			end
			----------------------------------------
		end
	end)	
	if Define.isVisibleTrick == true then
	    backPokerSprite:setPosition(cc.p(Define.visibleWidth / 2 - 30, Define.visibleHeight / 2))
    else
        backPokerSprite:setPosition(cc.p(Define.visibleWidth , Define.visibleHeight))
    end
	backPokerSprite:addTo(self)
	local easeIn = cc.EaseSineOut:create(cc.MoveTo:create(Define.game_distrMjAction_time, cc.p(Define.g_right_pai_x, Define.g_right_pai_start_y+(times-1)*Define.g_side_pai_height*4.5)))
	local spawn = cc.Spawn:create(easeIn, cc.FadeTo:create(Define.game_distrMjAction_time, 255))
	backPokerSprite:runAction(cc.Sequence:create(spawn,cc.CallFunc:create(function() CommonSound.playSound("fapai") end),cc.DelayTime:create(0.1),call))	
end

function PlayerRight:putDownMjAction()
	if self.m_showMjBg then
		self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create( function()
        self.m_showMjBg:removeFromParent()
        self.m_showMjBg = nil
		end )))
	end

	if self.m_playMj ~= 0 and self.m_arrMj ~= nil then
		WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 2, Define.g_right_pai_x, self.m_arrMj[#self.m_arrMj]:getPositionY(),  self.m_playMj)
	    self.m_playMj = 0
    end
end

--打出去的大麻将显示
function PlayerRight:removePutDownMj()
    if  self.m_showMjBg ~= nil then
        self.m_showMjBg:removeFromParent();
        self.m_showMjBg = nil;
    end
end
--打出去的麻将值
function PlayerRight:getPutMjValue()
    return self.m_playMj or 0
end


------------------------------视频回放相关--------------------------------------
--[[
-- @brief  游戏回放明牌函数
-- @param  void
-- @return void
--]]
function PlayerRight:gameVideoMingPai(cards, card)
	assert(type(cards) == "table")
    CommonSound.playSound("tuipai")
	if self.m_arrMj then
		for k, v in ipairs(self.m_arrMj) do
			v:removeFromParent()
			v = nil
		end
		self.m_arrMj = nil
	end
	self.m_arrMj = {}
	local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()+ kHandGap
	for i = 1, #cards do
		local node = MjSide.new(cards[i], MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
		-- local node = Mj.new(cards[i], MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
		-- node:setLocalZOrder(cards - 1 -i)
		node:setLocalZOrder(1-i+14)
		node:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_side_end_ming_pai_height + actionPaiHeight))
		node:addTo(self)
		table.insert(self.m_arrMj, node)
		--增加赖子变银色				
		if node._value == MjProxy:getInstance():getLaizi() then
			if node:getChildByName("mjLaizi") == nil then
			   local mjLaizi = ccui.ImageView:create("games/common/mj_shadow_1.png");
			   mjLaizi:setName("mjLaizi")
			   mjLaizi:setPosition(cc.p(0, 0))
			   node:addChild(mjLaizi)
			end
	    end	
	end
	-- 重新排序
	self:reSortMjListPosition()

end

--[[
-- @brief  获得新的麻将
-- @param  void
-- @return void
--]]
function PlayerRight:videoGetTheNewMj(mj)
    Log.i("右家摸新牌")
    local gameLayer = self:getParent():getParent()
    local gameid = MjProxy:getInstance():getGameId()
    -- gameLayer._bgLayer:refreshRemainCount()

	self.m_arrMj = self.m_arrMj or { }
	if #self.m_arrMj == 0 then
		return
	end

    local lastMj = self.m_arrMj[#self.m_arrMj]
    local rsMj = self.m_arrMj[#self.m_arrMj-1]
    if lastMj ~= nil and rsMj ~= nil then
        local lastPos_x,lastPos_y = lastMj:getPosition()
        local rsPos_x,rsPos_y = rsMj:getPosition()
        if lastPos_y > rsPos_y + Define.g_side_pai_height then
            lastMj:setPosition(cc.p(rsPos_x,rsPos_y + Define.g_side_pai_height))
        end
    end
	local newPaiY = self.m_arrMj[#self.m_arrMj]:getPositionY() + Define.g_side_pai_height

	self.m_newMj = MjSide.new(mj, MjSide._EType.e_type_normal, MjSide._ESide.e_side_right)
	self.m_newMj:setOpacity(200)
	self.m_newMj:setLocalZOrder(self.m_arrMj[#self.m_arrMj]:getLocalZOrder() - 1)
	self.m_newMj:setPosition(cc.p(Define.g_right_pai_x, newPaiY + 5)):addTo(self)
    -- self.m_newMj:setScale(Define.majiang_shoupai_zuoyou_scale)
		--增加赖子变银色				
	if self.m_newMj._value == MjProxy:getInstance():getLaizi() then
		if self.m_newMj:getChildByName("mjLaizi") == nil then
			   local mjLaizi = ccui.ImageView:create("games/common/mj_shadow_1.png");
			   mjLaizi:setName("mjLaizi")
			   mjLaizi:setPosition(cc.p(0, 0))
			   self.m_newMj:addChild(mjLaizi)
		end
	end	
	self.m_newMj:retain()
	table.insert(self.m_arrMj, self.m_newMj)
end


--[[
-- @brief  重新排序麻将
-- @param  
-- @return void
--]]
function PlayerRight:reSortMjListPosition()
	-- 排序
	table.sort(self.m_arrMj, function (x, y)
		return x:getSortValue() < y:getSortValue()
	end)
	self:resetCardPosition()
	-- local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()+ kHandGap
	-- for i=1, #self.m_arrMj do
	-- 	self.m_arrMj[i]:setLocalZOrder(-i)
	-- 	self.m_arrMj[i]:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_side_end_ming_pai_height + actionPaiHeight))
	-- end
end
--[[
-- @brief  回放功能其他玩家的操作
-- @param  void
-- @return void
--]]
function PlayerRight:handleVideoOtherAction(data)
	local actionType = data.actionID
	local actionCard = data.actionCard
	Log.i("PlayerRight:handleVideoOtherAction 打印右家的cbCards",data.cbCards)
	local cards = data.cbCards or { }
    local action = nil
	-- 听
	if actionType == Define.action_ting then
        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_right)
	    Sound.effect_ting(MjProxy.getInstance()._players[Define.site_right]:getSex())
    --补花
    elseif actionType == Define.action_buhua then
        if self._isDispenseCard == false then
            Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_right]:getSex(),true)
        else
            Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_right]:getSex())
        end
        CommonSound.playSound("buhua")
        action = MjMediator:getInstance():on_payerAction("AnimationBUHUA",1,Define.site_right)
        self._rightFlower = self._rightFlower or {}
        self._rightFlower[#self._rightFlower+1] = MjProxy:getInstance()._actionData.actionCard
        self:showBuHua(self._rightFlower)
        for i,v in pairs(self.m_arrMj) do
            if v._value == MjProxy:getInstance()._actionData.actionCard then
                self.m_arrMj[i]._value = MjProxy:getInstance()._actionData.actionCard
            end
        end
		-- 吃
	elseif actionType == Define.action_chi then
		Sound.effect_chi(MjProxy.getInstance()._players[Define.site_right]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_right)
		self:drawActionMajiang(data, actionType, cards)

		for k, v in ipairs(data.cbCards) do
			while true do
				if v == data.actionCard then break end

				for i = 1, #self.m_arrMj do
					local mj = self.m_arrMj[i]
					if mj._value == v then
						mj:removeFromParent()
						mj = nil

						table.remove(self.m_arrMj, i)
						break
					end
				end

				break
			end
		end

		-- 重绘手牌位置
		self:resetCardPosition()
		-- 碰	
	elseif actionType == Define.action_peng then
		Sound.effect_peng(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_right)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_peng)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 明杠
	elseif actionType == Define.action_mingGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_mingGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 暗杠
	elseif actionType == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_anGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 加杠
	elseif actionType == Define.action_jiaGang then
		Log.i("右家加杠 actionType == Define.action_jiaGang")
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_right)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_jiaGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 点炮胡
	elseif actionType == Define.action_dianPaoHu then
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._actionData.lastPlayUserId))
		action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_right)
        MjMediator:getInstance():on_playerHU(Define.mj_rightCards_position_x-10,display.cy)
        if result == 3 then

		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
		end
		-- 自摸糊
	elseif actionType == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_right)
        MjMediator:getInstance():on_playerHU(Define.mj_rightCards_position_x-10,display.cy)
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_right]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
		end
		-- 加倍
	elseif actionType == Define.action_jiaBei then

	end
end
--[[
-- @brief  移除操作的牌函数
-- @param  void
-- @return void
--]]
function PlayerRight:removeActionCard(data, actionType)
	local newT = {}  
	local maxRemove = 4 -- 最大移除麻将数量
	if actionType == Define.action_peng then
		maxRemove = 2
	else
		maxRemove = 4 
	end
	for k ,v in pairs(self.m_arrMj) do  
	    if data.actionCard == v:getValue() 
	    	and maxRemove > 0 then
	        v:removeFromParent() 
	     	maxRemove = maxRemove - 1
	    else
	     	table.insert(newT, v) 
	    end  
	end  
	self.m_arrMj = newT  
end

--[[
-- @brief  每次移除一个麻将
-- @param  void
-- @return void
--]]
function PlayerRight:removeOneMjFromHand(mjValue) 
	for i=1, #self.m_arrMj do
		if mjValue == self.m_arrMj[i]:getValue() then
	     	self.m_arrMj[i]:removeFromParent() 
	     	table.remove(self.m_arrMj, i)	
	     	break
	    end  
	end
end

--[[
-- @brief  重设手牌位置
-- @param  void
-- @return void
--]]
function PlayerRight:resetCardPosition()
	-- 重设位置
	-- local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()+ kHandGap
	local actionPaiHeight = Define.g_right_gang_pai_space *MjProxy:getInstance()._players[Define.site_right]:getActionTimes()
	for i = 1, #self.m_arrMj do
		self.m_arrMj[i]:setLocalZOrder(-i)
		self.m_arrMj[i]:setPosition(cc.p(Define.g_right_pai_x, Define.g_right_action_pai_start_y + i * Define.g_side_end_ming_pai_height + actionPaiHeight))
	end
end

--[[
-- @brief  打麻将函数
-- @param  void
-- @return void
--]]
function PlayerRight:videoPlayMj(mj)
	self.m_playMj = mj
 	-- 移除从手上打出去的麻将
 	self:removeOneMjFromHand(mj)
 	-- 重新排序
 	self:reSortMjListPosition()
	if self.m_showMjBg ~= nil then
		self.m_showMjBg:removeFromParent()
		self.m_showMjBg = nil
	end

	self.m_showMjBg = display.newSprite("games/common/mj/games/bg_big_out_poker.png")
	self.m_showMjBg:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])
	self.m_showMjBg:setPosition(cc.p(Define.g_right_show_pai_x, Define.g_right_show_pai_y)):addTo(self,100)

	local temp =Mj.new(mj, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	temp:setPosition(cc.p(self.m_showMjBg:getContentSize().width / 2, self.m_showMjBg:getContentSize().height / 2))
	self.m_showMjBg:addChild(temp)
	self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
		return self:putDownMjAction()
	end )))
end

--------------------------------------------------------------------------------------------

return PlayerRight
