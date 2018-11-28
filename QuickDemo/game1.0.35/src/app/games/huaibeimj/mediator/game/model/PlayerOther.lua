-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local MjSide = require "app.games.huaibeimj.mediator.game.model.MjSide"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local MJArmatureCSB = require("app.games.huaibeimj.custom.MJArmatureCSB")
local PlayerOther = class("PlayerOther", function ()
	return display.newNode()
end)

function PlayerOther:ctor()
	Log.i("PlayerOther:ctor")
	self.m_arrMj = { }
	self.m_showMjBg = nil
	self.m_playMj = 0
	self.m_arrMingMj = { }
	self.m_newMj = nil
    self._isDispenseCard = false
end

function PlayerOther:recoveryMj()
	Log.i("PlayerOther:recoveryMj")
	local data = MjProxy:getInstance()._gameStartData
	local topencard = MjProxy:getInstance()._players[Define.site_other].m_openCards
	local topencardType = MjProxy:getInstance()._players[Define.site_other].m_openCardsType
	local openCardsUserIds = MjProxy:getInstance()._players[Define.site_other].m_openCardsUserIds
	local openActionCards = MjProxy:getInstance()._players[Define.site_other].m_openActionCards

	Log.i("PlayerOther:recoveryMj topencard=", topencard)
	Log.i("PlayerOther:recoveryMj topencardType=", topencardType)
	Log.i("PlayerOther:recoveryMj openCardsUserIds=", openCardsUserIds)	
	Log.i("PlayerOther:recoveryMj openActionCards=", openActionCards)	

	if #topencard ~= #topencardType then
		Log.i("对家恢复对局操作的牌类型和牌值数量不一致")
	end

	for i = 0, #topencard - 1 do
		local card = topencard[i + 1]
		local action = topencardType[i + 1]
		local userId = openCardsUserIds[i + 1]
		local actionCard  = openActionCards[i + 1]
        -- if card <45 and card ~= 41 then
            Log.i("PlayerOther   setActionTimes...")
		    MjProxy:getInstance()._players[Define.site_other]:setActionTimes(MjProxy:getInstance()._players[Define.site_other]:getActionTimes() + 1)
        -- -- else
        --     local gameLayer = self:getParent():getParent()
        --     gameLayer.m_playerHeadNode:setBuhuaNumber(Define.site_other,card)
        -- end
		local table = nil
		if action == Define.action_chi then
			table = { card, card + 1, card + 2 }
		elseif action == Define.action_peng then
			table = { card, card, card }
		elseif action == Define.action_mingGang or action == Define.action_anGang  or action == Define.action_jiaGang then
            Log.i("aaa....",card)
            table = { card, card, card, card }
		    if action ~=  Define.action_jiaGang then
			    MjProxy:getInstance()._players[Define.site_other]:setGangTimes(MjProxy:getInstance()._players[Define.site_other]:getGangTimes() + 1)
		    end
		end
		   	self:drawActionMajiang(MjProxy:getInstance()._actionData,action, table, true, userId, actionCard)
	end

	local nPai = MjProxy:getInstance()._players[Define.site_other]:getCardNum()
	Log.i("PlayerOther:recoveryMj nPai", nPai)

	local actionPaiWidth = Define.g_other_pai_peng_space *(MjProxy:getInstance()._players[Define.site_other]:getActionTimes()) 
	self.m_arrMj = { }
	for i = 0, nPai - 1 do
		local mj = display.newSprite("#other_poker.png")
		mj:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_width * i - actionPaiWidth - Define.g_other_pai_width*0.5, Define.g_other_pai_y))
		self:addChild(mj)
		mj:retain()
		table.insert(self.m_arrMj, mj)
	end
end

function PlayerOther:distrMj()
	self:distrMjAction(1)

end

function PlayerOther:getTheNewMj(mj)
    local gameLayer = self:getParent():getParent()
    -- gameLayer._bgLayer:refreshRemainCount()
--	Sound.effect("effect16")
	Log.i("叫牌时，没有明牌")
	self.m_arrMj = self.m_arrMj or { }
	if #self.m_arrMj == 0 then
		return
	end
    local lastMj = self.m_arrMj[#self.m_arrMj]
    local rsMj = self.m_arrMj[#self.m_arrMj-1]
    if lastMj ~= nil and rsMj ~= nil then
        local lastPos_x,lastPos_y = lastMj:getPosition()
        local rsPos_x,rsPos_y = rsMj:getPosition()
        if lastPos_x < rsPos_x - Define.g_other_pai_width then
            lastMj:setPosition(cc.p(rsPos_x - Define.g_other_pai_width,lastPos_y))
        end
    end
	local newPaix = self.m_arrMj[#self.m_arrMj]:getPositionX() - Define.g_other_pai_width-10

	self.m_newMj = display.newSprite("#other_poker.png")
	self.m_newMj:setOpacity(200)
	self.m_newMj:setPosition(cc.p(newPaix, Define.g_other_pai_y + 50)):addTo(self)

	self.m_newMj:retain()
	table.insert(self.m_arrMj, self.m_newMj)
	local out = cc.EaseBounceOut:create(cc.MoveTo:create(0.2, cc.p(self.m_newMj:getPositionX(), Define.g_other_pai_y)))
	self.m_newMj:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), out))
	
end

function PlayerOther:playMj(mj)
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
        if lastPos_x < rsPos_x - Define.g_other_pai_width then
            lastMj:setPosition(cc.p(rsPos_x - Define.g_other_pai_width,rsPos_y))
        end
    end
	if self.m_showMjBg ~= nil then
		self.m_showMjBg:removeFromParent()
		self.m_showMjBg = nil
	end

	self.m_showMjBg = display.newSprite("games/common/mj/games/bg_big_out_poker.png")
	self.m_showMjBg:setPosition(cc.p(353, Define.g_other_show_pai_y)):addTo(self:getParent():getParent(),100)

	local temp = Mj.new(mj, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	temp:setPosition(cc.p(self.m_showMjBg:getContentSize().width / 2, self.m_showMjBg:getContentSize().height / 2))
	self.m_showMjBg:addChild(temp)
	self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
		return self:putDownMjAction()
	end )))
end

function PlayerOther:refreshMj(action)
	self.m_arrMj = self.m_arrMj or { }
	for k, v in ipairs(self.m_arrMj) do
		v:removeFromParent()
		v = nil
	end
	self.m_arrMj = nil
	local nPai = 13
	nPai = nPai - (MjProxy:getInstance()._players[Define.site_other]:getActionTimes()-1)*3
    if action == Define.action_chi or action == Define.action_peng then
        nPai = nPai - 2
    else
	    nPai = nPai - 3
    end
	self.m_arrMj = self.m_arrMj or { }
    
    local actionPaiWidth = Define.g_other_pai_gang_space *MjProxy:getInstance()._players[Define.site_other]:getActionTimes() + 15
    Log.i("getActionTimes..........",MjProxy:getInstance()._players[Define.site_left]:getActionTimes(),actionPaiHeight,nPai,Define.g_side_gang_pai_space)
	for i = 1, nPai do
		local mj = display.newSprite("#other_poker.png")
		mj:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_width * (i-1) - actionPaiWidth, Define.g_other_pai_y))
		mj:addTo(self)
		mj:retain()
		table.insert(self.m_arrMj, mj)
	end

end

function PlayerOther:drawActionMajiang(data, actionType, cards, isRecovery, userId, actionCard)
	assert(type(cards) == "table" and #cards ~= 0)
	local mj = cards[1]
	isRecovery = isRecovery or false
	if actionType == Define.action_jiaGang and isRecovery == true then
		actionType = Define.action_mingGang
	end
    if actionType == Define.action_peng or actionType == Define.action_chi then
		self:drawActionThree(data,cards, actionType, userId, actionCard)
	elseif actionType == Define.action_anGang or actionType == Define.action_mingGang then
		self:drawActionFour(data,cards, actionType, userId)	
	end
	if actionType == Define.action_jiaGang and isRecovery == false then
		Log.i("对家绘制加杠")
		local actionNode = self:getChildByTag(150 + mj)
		if actionNode then
			local node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_other)
			local lastPlayerIndex = 1
            local yPre = 6
            local xPre = 1
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
--            Log.i("加杠。。。。。",mj,"lastPlayerIndex....",lastPlayerIndex)
            if lastPlayerIndex == 1 then
                -- node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY()- yPre-Define.g_other_pai_tang_action_height+1))
                node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() - Define.g_other_pai_tang_action_height))
            elseif lastPlayerIndex == 2 then
                -- node:setPosition(cc.p(actionNode:getPositionX()+Define.g_other_pai_tang_action_width-xPre, actionNode:getPositionY() -Define.g_other_pai_tang_action_height + yPre))
            	node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() - Define.g_other_pai_tang_action_height))
            elseif lastPlayerIndex == 4 then
                -- node:setPosition(cc.p(actionNode:getPositionX()-Define.g_other_pai_action_width+xPre, actionNode:getPositionY() -Define.g_other_pai_tang_action_height + yPre))
            	node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() - Define.g_other_pai_tang_action_height))
            end
            node:addTo(self,3)
		    node:setAnchorPoint(cc.p(0.5, 0))

            for i=1, #MjProxy:getInstance()._players[Define.site_other].m_arrMyActionType do
            	if MjProxy:getInstance()._players[Define.site_other].m_arrMyActionType[i] == Define.action_peng then
            		if MjProxy:getInstance()._players[Define.site_other].m_arrMyActionMj[i][1] == mj then
						MjProxy:getInstance()._players[Define.site_other].m_arrMyActionType[i] = actionType
						MjProxy:getInstance()._players[Define.site_other].m_arrMyActionMj[i] = {mj, mj, mj, mj}
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
        Log.i("PlayerOther添加动作牌....",cards)
	    table.insert(MjProxy:getInstance()._players[Define.site_other].m_arrMyActionMj, cards)
	    table.insert(MjProxy:getInstance()._players[Define.site_other].m_arrMyActionType, actionType)
	   	table.insert(MjProxy:getInstance()._players[Define.site_other].m_arrLastPlayerIndexs, lastPlayerIndex)
    end
end

function PlayerOther:getChiActionIndex(cards, actionCard)
	local lastPlayerIndex = 2
	for i=1, #cards do
		if actionCard == cards[1] then
			lastPlayerIndex = 2
		elseif actionCard == cards[2] then
			lastPlayerIndex = 1
		elseif actionCard == cards[3] then
			lastPlayerIndex = 4
		end
	end
	return lastPlayerIndex
end

function PlayerOther:drawActionThree(data , mjs, actionType, userId, actionCard)
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
   	if lastPlayerIndex == 3 then
   		lastPlayerIndex = 1
   	end
   Log.i("PlayerOther:drawActionThree lastPlayerIndex=", lastPlayerIndex)
--    lastPlayerIndex = userId
	local gangTimes = MjProxy:getInstance()._players[Define.site_other]:getGangTimes()
	local actionTimes = MjProxy:getInstance()._players[Define.site_other]:getActionTimes() -gangTimes
	if actionTimes < 0 then
		actionTimes = 0
	end
	local actionPaiWidth = (Define.g_other_pai_peng_space + 6) * actionTimes + (Define.g_other_pai_peng_space + 6) * (gangTimes-1)

	for i = 0, 2 do
		local node = nil
		local yPre = 9
        local xPre = 1
        local xPos = 4
	    local mj = mjs[1]
		if actionType == Define.action_chi then
			mj = mjs[i+1]
		end
		if lastPlayerIndex == 1 then --对家
			if i == 1 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_action_width  - actionPaiWidth+ xPre + xPos, Define.g_other_pai_y + yPre ))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			elseif i == 0 then
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x  - actionPaiWidth+xPre+xPos, Define.g_other_pai_y))

			elseif i == 2 then
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x -  Define.g_other_pai_action_width - Define.g_other_pai_tang_action_width - actionPaiWidth + xPre, Define.g_other_pai_y))
			end		

		elseif lastPlayerIndex == 2 then --上家
			if i == 0 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x  - actionPaiWidth+ xPos+xPre+6, Define.g_other_pai_y + yPre))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x - (i -1)* Define.g_other_pai_action_width - Define.g_other_pai_tang_action_width - actionPaiWidth+ xPos+3, Define.g_other_pai_y))
			end				

		elseif lastPlayerIndex == 4 then --下家
			if i == 2 then
				node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x - 2*Define.g_other_pai_action_width  - actionPaiWidth+ xPos, Define.g_other_pai_y + yPre))
				if actionType ~= Define.action_chi then
					node:setTag(150 + mj)
				end
			else
				node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
				node:setPosition(cc.p(Define.g_other_pai_start_x - i * Define.g_other_pai_action_width - actionPaiWidth-xPre+ xPos, Define.g_other_pai_y))
			end
		end
		self:addChild(node)
		node:setAnchorPoint(cc.p(0.5, 0))		
	end
    local threeArray = {}
    threeArray.mj = mjs[1]
    threeArray.playerIndex = lastPlayerIndex
    threeArray.actionTimes = actionTimes
    self:setActionThreeArray(threeArray)
end

function PlayerOther:setActionThreeArray(mjArray)
    if self._actionThreeArray == nil then
        self._actionThreeArray = {}
    end
    self._actionThreeArray[#self._actionThreeArray +1] = mjArray
end
function PlayerOther:getActionThreeArray()
    return self._actionThreeArray or {}
end

function PlayerOther:drawActionThreeGang(data,mj, actionType)

	 local gangTimes = MjProxy:getInstance()._players[Define.site_other]:getGangTimes()
	 local actionTimes = MjProxy:getInstance()._players[Define.site_other]:getActionTimes() - MjProxy:getInstance()._players[Define.site_other]:getGangTimes() 
	 if actionTimes < 0 then
	 	actionTimes = 0
	 end
	 local actionPaiWidth = Define.g_other_pai_peng_space *(actionTimes-1) + Define.g_other_pai_peng_space*gangTimes
    local xPos = 10
	for i = 0, 2 do
		local node = nil
		if actionType == Define.action_anGang then
			node = display.newSprite("#other_gang_poker.png")
			node:setAnchorPoint(cc.p(1, 0.5))

		else
			node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
			node:setAnchorPoint(cc.p(0.5, 0))
		end
		node:setPosition(cc.p(Define.g_other_pai_start_x - i * Define.g_other_pai_gai_width - actionPaiWidth+xPos, Define.g_other_pai_y))
		node:addTo(self)

		if i == 1 and(actionType == Define.action_peng or actionType == Define.action_mingGang or actionType == Define.action_anGang or actionType == Define.action_jiaGang) then
			node:setTag(150 + mj)
		end

		if actionType == Define.action_chi then
			mj = mj + 1
		end
	end
end


function PlayerOther:drawActionFour(data,mjs, actionType,userId)
	local mj = mjs[1]
    if actionType == Define.action_anGang then
	    self:drawActionThreeGang(data,mj, actionType)
    else
        self:drawActionThree(data,mjs, actionType,userId)
    end
	local actionNode = self:getChildByTag(150 + mj)
	if actionNode then
		local node = nil
		if actionType == Define.action_anGang then
--			node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
            node = display.newSprite("#other_gang_poker.png")
            node:setPosition(cc.p(actionNode:getPositionX()-Define.g_other_pai_tang_action_width/2, actionNode:getPositionY()-Define.g_other_pai_tang_action_height/2-3))
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:addTo(self,3)
		else
			local yPre = 6
			node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_other)
            -- 添加最后一个杠躺着的牌
            node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() - Define.g_other_pai_tang_action_height))
            node:addTo(self, actionNode:getLocalZOrder())
		end
		node:setAnchorPoint(cc.p(0.5, 0))
		
	else
		Log.i("drawActionThree 没找到 %s 的tag值", tostring(mj))
	end
end

function PlayerOther:handleOtherAction(data)
	Log.i("PlayerOther:handleOtherAction")
	-- dump(data, "PlayerOther:handleOtherAction 对家处理操作数据")
	assert(data ~= nil)
	------------------- 视频回放功能--------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:handleVideoOtherAction(data)
		return 
	end
	----------------------------------------------
	local actionType = data.actionID
	local actionCard = data.actionCard

	local cards = data.cbCards or { }
	
	local gender = MjProxy:getInstance()._players[Define.site_other]:getGender()
    local action = nil
	-- 听
	if actionType == Define.action_ting then
		if gender == 1 then

		else

		end
	    Sound.effect_ting(MjProxy.getInstance()._players[Define.site_other]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_other)
		-- 吃
	elseif actionType == Define.action_chi then
		Sound.effect_chi(MjProxy.getInstance()._players[Define.site_other]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_other)
		self:drawActionMajiang(data,actionType, cards)
		self:refreshMj(Define.action_chi)
		-- 碰	
	elseif actionType == Define.action_peng then
		Sound.effect_peng(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_other)
		self:drawActionMajiang(data,actionType, cards)
		self:refreshMj(Define.action_peng)

		-- 明杠
	elseif actionType == Define.action_mingGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_mingGang)
		-- 暗杠
	elseif actionType == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
        -- local mj = cards[1]
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
		self:drawActionMajiang(data,actionType, cards)
		self:refreshMj(Define.action_anGang)
		-- 加杠
	elseif actionType == Define.action_jiaGang then
		Log.i("对家加杠 actionType == Define.action_jiaGang")
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
		self:drawActionMajiang(data,actionType, cards)

		self:refreshMj(Define.action_jiaGang)
		-- 点炮胡
	elseif actionType == Define.action_dianPaoHu then
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(data.lastPlayUserId))
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_other)
		MjMediator:getInstance():on_playerHU(display.cx,Define.mj_otherCards_postion_y-10)
        if result == 3 then
			-- 加倍

		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 自摸糊
	elseif actionType == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_other)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_otherCards_postion_y-10)
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			-- 加倍
		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
			-- clock:clockStop()
		end
		-- 加倍
	elseif actionType == Define.action_jiaBei then
	end

end

function PlayerOther:showBuHua(mj)
	local gameLayer = self:getParent():getParent()
	if gameLayer then
		gameLayer:refreshFlower(Define.site_other, mj)
	end

    local gameid = MjProxy:getInstance():getGameId()
    if gameid == Define.gameId_xuzhou then
	    gameLayer._bgLayer:refreshRemainPaiCount()
    elseif gameid == Define.gameId_changzhou then
        gameLayer._bgLayer:refreshRemainCount()
    end
end

function PlayerOther:gameEndMingPai(cards, card)
	assert(type(cards) == "table")
    CommonSound.playSound("tuipai")
	if self.m_arrMj then
		for k, v in ipairs(self.m_arrMj) do
			v:removeFromParent()
			v = nil
		end
		self.m_arrMj = nil
	end
	local actionPaiWidth = Define.g_other_pai_peng_space *(MjProxy:getInstance()._players[Define.site_other]:getActionTimes() ) 

	for i = 0, #cards - 1 do
		local node = Mj.new(cards[i + 1], Mj._EType.e_type_action, Mj._ESide.e_side_other)
		node:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_width * i - actionPaiWidth- Define.g_other_pai_width*0.5, Define.g_other_pai_y))
		node:addTo(self)
	end
    local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置

	if card ~= 0 and winnerSite == Define.site_other then
		local node = Mj.new(card, Mj._EType.e_type_action, Mj._ESide.e_side_other)
		node:setPosition(cc.p(Define.g_other_pai_start_x - #cards*Define.g_other_pai_width   - actionPaiWidth- Define.g_other_pai_width*0.5 - 20, Define.g_other_pai_y))
		node:addTo(self)
	end
end

function PlayerOther:showChatMessage(word)
	if self.messWordBg then
		self.messWordBg:removeFromParent()
		self.messWordBg = nil
	end

	local label = cc.Label:create()
	label:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
	label:setString(word)
	label:setColor(display.COLOR_BLACK)
	label:setSystemFontSize(25.0)
	label:setPosition(cc.p(8, 24))
	if label:getContentSize().width > 300 then
		label:setDimensions(300, 0)
	end

	self.messWordBg = display.newSprite("#mess_other_mess_bg.png", { capInsets = cc.rect(12, 26, 15, 40), size = cc.size(label:getContentSize().width + 20, label:getContentSize().height + 60) })
	self.messWordBg:setAnchorPoint(display.ANCHOR_POINTS[display.RIGHT_TOP])
	self.messWordBg:addChild(label, 2)
	self.messWordBg:setPosition(cc.p(570, 630))
	self:addChild(self.messWordBg, 2)
	self.messWordBg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeOut:create(0.8),
	cc.CallFunc:create( function()
		if self.messWordBg then
			self.messWordBg:removeFromParent()
			self.messWordBg = nil
		end
	end )))
end

function PlayerOther:distrMjAction(times)
	Log.i("PlayerOther:distrMjAction %s", tostring(times))

	local data = MjProxy:getInstance()._gameStartData
	if data == nil or data == { } then
		return
	end
	local nPai = 13
	if data.bankPlay == MjProxy:getInstance()._userIds[Define.site_other] then
		nPai = 14
	end	

	local from = 4 *(times - 1) +1
	local to =  4 *times 
	if to > nPai then
		to = nPai
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
	backPokerSprite:setOpacity(255)
	backPokerSprite:setCascadeOpacityEnabled(true)
	local call = cc.CallFunc:create(function ()
		backPokerSprite:removeSelf()
		times = times +1
		if times < 6 then
			for i=1,to - from +1 do
				local mj = display.newSprite("#other_poker.png")
				mj:setPosition(cc.p(Define.g_other_pai_start_x - (from+i -2) * Define.g_other_pai_width,Define.g_other_pai_y )):addTo(self)
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
					local userid = MjProxy:getInstance()._players[Define.site_other]:getUserId()
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
	local easeIn = cc.EaseSineOut:create(cc.MoveTo:create(Define.game_distrMjAction_time, cc.p(Define.g_other_pai_start_x- (times-1)*backPokerSprite:getContentSize().width*4,Define.g_other_pai_y)))
	local spawn = cc.Spawn:create(easeIn,  cc.FadeTo:create(Define.game_distrMjAction_time, 255))
	backPokerSprite:runAction(cc.Sequence:create(spawn,cc.CallFunc:create(function() CommonSound.playSound("fapai") end),cc.DelayTime:create(0.1),call))	
end

function PlayerOther:putDownMjAction()
	if self.m_showMjBg then
		self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create( function()
        self.m_showMjBg:removeFromParent()
        self.m_showMjBg = nil
		end )))
	end

	if self.m_playMj ~= 0 then
		if self.m_arrMj and #self.m_arrMj > 0 then
			WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_putDownMj, 3, self.m_arrMj[#self.m_arrMj]:getPositionX() ,Define.g_other_pai_y,self.m_playMj)
		    self.m_playMj = 0
        end
	end
end
--打出去的大麻将显示
function PlayerOther:removePutDownMj()
    if  self.m_showMjBg ~= nil then
        self.m_showMjBg:removeFromParent();
        self.m_showMjBg = nil;
    end
end

--打出去的麻将值
function PlayerOther:getPutMjValue()
    return self.m_playMj or 0
end
------------------------------视频回放相关--------------------------------------
--[[
-- @brief  游戏回放明牌函数
-- @param  void
-- @return void
--]]
function PlayerOther:gameVideoMingPai(cards, card)
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
	local actionPaiWidth = Define.g_other_pai_peng_space *(MjProxy:getInstance()._players[Define.site_other]:getActionTimes() ) 
	for i = 1, #cards do
		local node = Mj.new(cards[i], Mj._EType.e_type_action, Mj._ESide.e_side_other)
		node:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_width * i - actionPaiWidth- Define.g_other_pai_width*0.5, Define.g_other_pai_y))
		node:addTo(self)
		table.insert(self.m_arrMj, node)
		--增加赖子变银色				
		if node._value == MjProxy:getInstance():getLaizi() then
			if node:getChildByName("mjLaizi") == nil then
			   local mjLaizi = ccui.ImageView:create("games/common/mj_shadow_2.png");
			   mjLaizi:setName("mjLaizi")
			   mjLaizi:setPosition(cc.p(0, 0))
			   node:addChild(mjLaizi)
			end
	    end	
	end
	-- 排序手牌
	self:reSortMjListPosition()
end
--[[
-- @brief  获得麻将函数
-- @param  void
-- @return void
--]]
function PlayerOther:videoGetTheNewMj(mj)
	Log.i("对家摸到牌")
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
        if lastPos_x < rsPos_x - Define.g_other_pai_width then
            lastMj:setPosition(cc.p(rsPos_x - Define.g_other_pai_width,lastPos_y))
        end
    end
	local newPaix = self.m_arrMj[#self.m_arrMj]:getPositionX() - Define.g_other_pai_width-10

	self.m_newMj = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_other)
	self.m_newMj:setOpacity(200)
	self.m_newMj:setPosition(cc.p(newPaix, Define.g_other_pai_y)):addTo(self)
    --增加赖子变银色				
	if self.m_newMj._value == MjProxy:getInstance():getLaizi() then
		if self.m_newMj:getChildByName("mjLaizi") == nil then
			   local mjLaizi = ccui.ImageView:create("games/common/mj_shadow_2.png");
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
function PlayerOther:reSortMjListPosition()
	-- 排序
	table.sort(self.m_arrMj, function (x, y)
		return x:getSortValue() < y:getSortValue()
	end)
	self:resetCardPosition()
end

function PlayerOther:handleVideoOtherAction(data)
	Log.i("PlayerOther:handleVideoOtherAction")
	assert(data ~= nil)
	local actionType = data.actionID
	local actionCard = data.actionCard
 
	local cards = data.cbCards or { }
	
	local gender = MjProxy:getInstance()._players[Define.site_other]:getGender()
    local action = nil
	-- 听
	if actionType == Define.action_ting then
		if gender == 1 then
--			Sound.effect("action_ting")
		else
--			Sound.effect("action_male_ting")
		end
	    Sound.effect_ting(MjProxy.getInstance()._players[Define.site_other]:getSex())

        action = MjMediator:getInstance():on_payerAction("AnimationTING",1,Define.site_other)
    --补花
    elseif actionType == Define.action_buhua then
        if self._isDispenseCard == false then
            Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_other]:getSex(),true)
        else
            Sound.effect_buhua(MjProxy.getInstance()._players[Define.site_other]:getSex())
        end
        CommonSound.playSound("buhua")
        action = MjMediator:getInstance():on_payerAction("AnimationBUHUA",1,Define.site_other)
        self._otherFlower =self._otherFlower or {}
        self._otherFlower[#self._otherFlower+1] = MjProxy:getInstance()._actionData.actionCard
--        Log.i("补花_otherFlower...",self._otherFlower)
        self:showBuHua(self._otherFlower)
        for i,v in pairs(self.m_arrMj) do
            if v._value == MjProxy:getInstance()._actionData.actionCard then
                self.m_arrMj[i]._value = MjProxy:getInstance()._actionData.actionCard
            end
        end
		-- 吃
	elseif actionType == Define.action_chi then
		Sound.effect_chi(MjProxy.getInstance()._players[Define.site_other]:getSex())
        action = MjMediator:getInstance():on_payerAction("AnimationCHI",1,Define.site_other)
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
		Sound.effect_peng(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("peng")
        action = MjMediator:getInstance():on_payerAction("AnimationPENG",1,Define.site_other)
		self:drawActionMajiang(data, actionType, cards)
		-- self:refreshMj(Define.action_peng)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()

		-- 明杠
	elseif actionType == Define.action_mingGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_mingGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 暗杠
	elseif actionType == Define.action_anGang then
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
		self:drawActionMajiang(data, actionType, cards)
		-- self:refreshMj(Define.action_anGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 加杠
	elseif actionType == Define.action_jiaGang then
		Log.i("对家加杠 actionType == Define.action_jiaGang")
		Sound.effect_gang(MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("gang")
        action = MjMediator:getInstance():on_payerAction("AnimationGANG",1,Define.site_other)
		self:drawActionMajiang(data, actionType, cards)

		-- self:refreshMj(Define.action_jiaGang)
		self:removeActionCard(data, actionType)
		-- 重绘手牌位置
		self:resetCardPosition()
		-- 点炮胡
	elseif actionType == Define.action_dianPaoHu then
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("fangpao")
		local result = data.actionResult
        MjMediator:getInstance():on_dianpaoAction(MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._actionData.lastPlayUserId))
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_other)
		MjMediator:getInstance():on_playerHU(display.cx,Define.mj_otherCards_postion_y-10)
        if result == 3 then

		else
			local clock = self:getParent():getParent()._bgLayer._clock
			assert(clock ~= nil)
		end
		-- 自摸糊
	elseif actionType == Define.action_ziMoHu then
		local result = data.actionResult
        action = MjMediator:getInstance():on_payerAction("AnimationHU",1,Define.site_other)
        MjMediator:getInstance():on_playerHU(display.cx,Define.mj_otherCards_postion_y-10)
        Sound.effect_hu(actionType, MjProxy.getInstance()._players[Define.site_other]:getSex())
        CommonSound.playSound("hupai")
		if result == 3 then
			-- 加倍
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
function PlayerOther:removeActionCard(data, actionType)
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
function PlayerOther:removeOneMjFromHand(mjValue) 
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
function PlayerOther:resetCardPosition()
	-- 重设位置
	local actionPaiWidth = Define.g_other_pai_peng_space *(MjProxy:getInstance()._players[Define.site_other]:getActionTimes() ) 
	for i=1, #self.m_arrMj do
		self.m_arrMj[i]:setPosition(cc.p(Define.g_other_pai_start_x - Define.g_other_pai_width * i - actionPaiWidth, Define.g_other_pai_y))
	end
end

--[[
-- @brief  回放打麻将函数
-- @param  void
-- @return void
--]]
function PlayerOther:videoPlayMj(mj)

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
	self.m_showMjBg:setPosition(cc.p(353, Define.g_other_show_pai_y)):addTo(self,100)

	local temp = Mj.new(mj, Mj._EType.e_type_normal, Mj._ESide.e_side_self)
	temp:setPosition(cc.p(self.m_showMjBg:getContentSize().width / 2, self.m_showMjBg:getContentSize().height / 2))
	self.m_showMjBg:addChild(temp)
	self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
		return self:putDownMjAction()
	end )))
end
--------------------------------------------------------------------------------------------


return PlayerOther
