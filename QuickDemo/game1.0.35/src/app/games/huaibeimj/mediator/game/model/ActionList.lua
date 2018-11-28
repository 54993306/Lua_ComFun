-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")

local actionBtn = require "app.games.huaibeimj.mediator.game.model.ActionBtn"
local actionBtnChi = require "app.games.huaibeimj.mediator.game.model.ActionBtnChi"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"

local ActionList = class("ActionList", function ()
	return display.newNode()
end)
local itemTag = { e_chiItemTag_one = 110, e_chiItemTag_two = 111, e_chiItemTag_three = 112 }
local anGangItemTag = {e_anGangItemTag_one = 113, e_anGangItemTag_two = 114 , e_anGangItemTag_three = 115}
local function getChiCard(one, two, three)
	return { one, two, three }
end

local function getGangCards(mj)
	return { mj, mj, mj, mj }
end

local function getChiCards(mj)
	-- age: left_a, left_b, mj, right_a, right_b
	local left_a = false
	local left_b = false
	local right_a = false
	local right_b = false


	local arrChiCards = { }
	local myCards = MjProxy:getInstance()._players[Define.site_self].cards

	for i = 0, #myCards - 1 do
		local node = myCards[i + 1]
		local value = node._value
		if value ~= MjProxy:getInstance():getLaizi() then
			if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou and mj == 47 then
				mj = MjProxy:getInstance():getLaizi()
			end

			if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou and value == 47 then
				value = MjProxy:getInstance():getLaizi()
			end

			if value == mj - 2 then
				left_a = true
			end
			if value == mj - 1 then
				left_b = true
			end
			if value == mj + 1 then
				right_a = true
			end
			if value == mj + 2 then
				right_b = true
				break
			end			
		end

	end

	if left_a and left_b then
		table.insert(arrChiCards, getChiCard(mj - 2, mj - 1, mj))
	end
	if left_b and right_a then
		table.insert(arrChiCards, getChiCard(mj - 1, mj, mj + 1))
	end
	if right_a and right_b then
		table.insert(arrChiCards, getChiCard(mj, mj + 1, mj + 2))
	end
	return arrChiCards
end

function ActionList:ctor(actions, param)
	if #actions ==0 then
		return
	end
	self.gangItems = {}
	local anGangIndex = 0
	local otherActions = {}
	if #actions == 3 and  param.anGangCards and #param.anGangCards > 1 then --操作等于3个且有多个暗杠的时候暗杠放左边第1个
		for i=1, #actions do
			if actions[i] == Define.action_anGang then
				anGangIndex = i
			else
				otherActions[#otherActions + 1] = actions[i]
			end
		end
	end
	if anGangIndex ~= 0 then
		otherActions[#otherActions + 1] = actions[anGangIndex]
		actions = {}
		actions = otherActions
	end
	-- assert(type(actions) == "table")
	-- assert(#actions ~= 0)
	-- assert(param ~= nil)
	local xSpace = 190
	Log.i("生成操作栏时，actions", actions)
	Log.i("生成操作栏时，param数据", param)
	
	self._param = param

	self._chiCard = -1

	WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_delTingQuery)

	self._m_actions = actions

	self._chiCard = param.playCard
	self._bg = display.newSprite()
	self._bg:setContentSize(cc.size(1280, 200))
	self:setContentSize(self._bg:getContentSize())
	self._bg:setAnchorPoint(cc.p(0, 0.5)):addTo(self)
	self:setPosition(cc.p(0, 185))
	self._menu = cc.Menu:create()
	self._menu:setPosition(cc.p(0, 0))
	self._bg:addChild(self._menu, 10)

	local itemGuo = actionBtn.createWithType(Define.action_guo, 0)
	itemGuo:registerScriptTapHandler(handler(self, self.actionMenuCallback))
	
	itemGuo:setTag(Define.action_guo)
	itemGuo:setAnchorPoint(cc.p(0, 0.5))
	itemGuo:setPosition(cc.p(Define.visibleWidth - 240, self._bg:getContentSize().height / 2))

	self._menu:addChild(itemGuo)
	local lastActionPx = itemGuo:getPositionX()
	if self._chiCard == -1 then
		return
	end

	-- if #actions == 1 and actions[1] == Define.action_chi and #(getChiCards(self._chiCard)) > 1 then
	-- 	Log.i("只有一个吃操作、直接显示所有吃法")
	-- 	self:showChiActionsItem(getChiCards(self._chiCard))
	-- else
	for i = 0, #actions - 1 do
		local action = actions[i + 1]
		Log.i("ActionList要显示的操作菜单是 %s", tostring(action))

		if action >= 14 and action <= 21 then
			return
		end
			
		local card = { }
		if action == Define.action_jiaGang then
			card = param.addGangCards
		elseif action == Define.action_anGang then
			card = param.anGangCards
		else
			local doorCard = param.doorcard or 0 
			if doorCard ~= 0 then
				table.insert(card, param.doorcard)
			else
				table.insert(card, param.playCard)
			end
		end

		dump(card, "card")
		if  (action == Define.action_dianPaoHu or action == Define.action_ziMoHu ) and #card == 0 and param.isGameStart then--天胡
				local item = actionBtn.createWithType(action, 0)
				item:registerScriptTapHandler(handler(self, self.actionMenuCallback))
				item:setAnchorPoint(cc.p(0, 0.5))
				item:setTag(action)
				item:setPosition(cc.p(itemGuo:getPositionX() - xSpace, self._bg:getContentSize().height / 2))
				self._menu:addChild(item)
				lastActionPx = item:getPositionX()
		end
		if  action == Define.action_ting  and param.isGameStart then--天听
				local item = actionBtn.createWithType(action, 0)
				item:registerScriptTapHandler(handler(self, self.actionMenuCallback))
				item:setAnchorPoint(cc.p(0, 0.5))
				item:setTag(action)
				item:setPosition(cc.p(lastActionPx - xSpace, self._bg:getContentSize().height / 2))
				self._menu:addChild(item)
				lastActionPx = item:getPositionX()
		end				
		for j = 0, #card - 1 do
			Log.i("可以胡时循环")

			local actionCard = card[j + 1]
			Log.i("actionCard: %d", actionCard)

			local item = actionBtn.createWithType(action, actionCard)
			-- 暗杠
			if action == Define.action_anGang then

				item:registerScriptTapHandler(handler(self, function ()
					if #card > 1 then --有多个暗杠，弹出选择框
						item:setVisible(false)
						self:showGangActionsItem(Define.action_anGang, card)
					else 
						WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_anGang, 1, actionCard, getGangCards(actionCard))
						self:removeFromParent()
					end
				end))

			elseif action == Define.action_jiaGang then

				item:registerScriptTapHandler(handler(self, function ()
					if #card > 1 then
						item:setVisible(false)
						self:showGangActionsItem(Define.action_jiaGang, card)
					else
						WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_jiaGang, 1, actionCard, getGangCards(actionCard))
						self:removeFromParent()
					end
					
				end))	
							
			else
				item:registerScriptTapHandler(handler(self, self.actionMenuCallback))
				item:setTag(action)
			end
			item:setAnchorPoint(cc.p(0, 0.5))

			if #actions == 4 then --四个时分两排，上面三个，下面一个加弃
				if i > 0 then
					if i == 1 then
						lastActionPx = 	itemGuo:getPositionX()
						item:setPosition(cc.p(lastActionPx , self._bg:getContentSize().height / 2 + 160))
						lastActionPx = item:getPositionX()
					else 
						item:setPosition(cc.p(lastActionPx - xSpace, self._bg:getContentSize().height / 2 + 160))
						lastActionPx = item:getPositionX()

					end	
				else
					item:setPosition(cc.p(lastActionPx - xSpace, self._bg:getContentSize().height / 2))
					lastActionPx = item:getPositionX()				
				end
			else
				item:setPosition(cc.p(lastActionPx - xSpace, self._bg:getContentSize().height / 2))
				lastActionPx = item:getPositionX()
			end
			self._menu:addChild(item)
			if action == Define.action_anGang and #card > 1 then --有多个暗杠只显示一个杠按钮
				break
			end
			if action == Define.action_jiaGang and #card > 1 then --有多个加杠只显示一个杠按钮
				break
			end 
		end
		
	end
end

function ActionList:actionMenuCallback(tag, sender)
	local param = self._param

	local playLayer = self:getParent()
	assert(playLayer ~= nil)
	local needRemoveAllItem = true
	-- 吃
	if tag == Define.action_chi then
		local card = param.playCard					
		Log.i("点击吃 =",card)

		local table = getChiCards(card)
		if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
			for i=1, #table do
				for j=1, #table[i] do
					if table[i][j] == MjProxy:getInstance():getLaizi() then
						table[i][j] = 47
					end
				end
			end
		end
		if #table == 0 then
			return
		elseif #table == 1 then
			WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_chi, 1, card, table[1])
		else
			-- 显示多种吃法
			self:showChiActionsItem(table)
			sender:setVisible(false)
			needRemoveAllItem = false
			return
		end
		-- 碰	
	elseif tag == Define.action_peng then
		local card = param.playCard
          
		Log.i("点击碰 %s", tostring(card))
		WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_peng, 1, card)
		-- 明杠
	elseif tag == Define.action_mingGang then
		local card = param.playCard
		Log.i("点击明杠 %s", tostring(card))
		WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_mingGang, 1, card, getGangCards(card))

		-- 听
	elseif tag == Define.action_ting then
        MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)

		playLayer:setPlayerTouchEnabled(true)
		local ting = param.tingCards

		local myCards = MjProxy:getInstance()._players[Define.site_self].cards
		for i = 0, #myCards - 1 do
			local node = myCards[i + 1]
			for j = 0, #ting - 1 do
				local mj = ting[j + 1]
				if node._value ~= mj then
					node:setMjState(Mj._EState.e_state_touch_invalid)
				else
					node:setMjState(Mj._EState.e_state_touch_valid)
					break
				end
			end
		end

		playLayer:setLastMjNormal()
		playLayer:showBuTing(sender:getPositionX())
		MjProxy:getInstance()._players[Define.site_self]:setHasClickTing(true)
		-- 胡
	elseif tag == Define.action_dianPaoHu or tag == Define.action_ziMoHu then
		local card = param.doorcard or 0
			if card == 0 then
				card = param.playCard
			end
		Log.i("点击胡 %s", tostring(card))
		WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, tag, 1, card)
		-- 过
	elseif tag == Define.action_guo then
		playLayer:setPlayerTouchEnabled(true)
		local card = param.doorcard or 0
			if card == 0 then
				card = param.playCard
			end

		Log.i("点击过 %s", tostring(card))
		Log.i("self._m_actions", self._m_actions)
		if self._m_actions[1] == Define.action_chi 
			or self._m_actions[1] == Define.action_peng 
			or self._m_actions[1] == Define.action_mingGang 
			or self._m_actions[1] == Define.action_xiaPao
			or self._m_actions[1] == Define.action_laZhuang then

			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(false)
		end

		if self._m_actions[1] == Define.action_ziMoHu then
			if MjProxy:getInstance()._players[Define.site_self]:getHasSendTing() == true then
				playLayer._my:autoPlayMj(card)
				return
			else 
				WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, self._m_actions[1], 0, card)
			end
		else
			if #self._m_actions ~= 0 and card then
				WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, self._m_actions[1], 0, card)
			end
		end
		if param.doorcard == 0 and param.playCard == 0 then
			MjProxy:getInstance()._players[Define.site_self]:setCanPlay(true)
		end
		
	end
	if needRemoveAllItem == true then
		self:removeFromParent()
	end

	
end

function ActionList:actionChiMenuCallback(tag, sender)
	Log.i("ActionList:actionChiMenuCallback")
	if self._chiCard == -1 then
		return
	end

	local arr = getChiCards(self._chiCard)
	if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
		for i=1, #arr do
			for j=1, #arr[i] do
				if arr[i][j] == MjProxy:getInstance():getLaizi() then
					arr[i][j] = 47
				end
			end
		end
	end
	-- dump(arr, "多种吃法table")
	if #arr == 0 then
		Log.i("error")
		return
	end

	local playLayer = self:getParent()
	assert(playLayer ~= nil)
	playLayer:setPlayerTouchEnabled(true)

	Log.i("吃 判断tag : %s", tostring(tag))
	local chiCards = {}

	if tag == itemTag.e_chiItemTag_one then
		Log.i("选择吃法一")
		chiCards = arr[1]
	elseif tag == itemTag.e_chiItemTag_two then
		Log.i("选择吃法二")
		chiCards = arr[2]
	elseif tag == itemTag.e_chiItemTag_three then
		Log.i("选择吃法三")
		chiCards = arr[3]
	end
	WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_chi, 1, self._chiCard, chiCards)
	self:removeFromParent()
end

function ActionList:showChiActionsItem(content)
	if #content == 0 then
		return
	end
    Log.i("ActionList:showChiActionsItem........")
	local tag = 110 + #content - 1
    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local startX = (visibleWidth/2)+(220*(#content/2))-165
	for i = #content, 1, -1 do
		local item = actionBtnChi.createWithTable(content[i], actionBtnChi._type.e_type_chi)
		item:setTag(tag )
		item:registerScriptTapHandler(handler(self, self.actionChiMenuCallback))
		item:setAnchorPoint(cc.p(0, 0.5))
--        local startX = 550
--		if #table > 1 and #self._m_actions == 3 then
--			startX = 450
--		end
		item:setPosition(cc.p(startX - 220 *(#content - i), self._bg:getContentSize().height / 2 - 15))

		self._menu:addChild(item)
		tag = tag -1
	end

end

function ActionList:showGangActionsItem(action, content)
    Log.i("ActionList:showGangActionsItem..",action,content)
	if #content == 0 then
		return
	end
    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    Log.i("ActionList:showGangActionsItem............",visibleWidth,action,content)
    Log.i("action....",action)
    Log.i("content....",content)

    if content ~= nil and #content > 0 and action == Define.action_anGang then
        content = self:removeRepeat(content)
        if #content == 1 then
            WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, Define.action_anGang, 1, content[1], getGangCards(content[1]))
	        self:removeFromParent()
        end
    end

	if #self.gangItems > 0 then
		for i=1,#self.gangItems do
			self.gangItems[i]:removeFromParent()
		end
		self.gangItems = {}
	end
    local startX = (visibleWidth/2)+(160*(#content/2))-120
    Log.i("startX........",startX)
	for i = #content, 1, -1 do
		local card = {}
		card[1] = content[i]
		local item = actionBtnChi.createWithTable(card, actionBtnChi._type.e_type_gang)
		local baseTag = 200
		if action == Define.action_jiaGang then
			baseTag = 300
		end
		item:setTag(baseTag+content[i])
		item:registerScriptTapHandler(handler(self, self.actionGangMenuCallback))
		item:setAnchorPoint(cc.p(0, 0.5))
		item:setPosition(cc.p(startX - 160 *(#content - i), self._bg:getContentSize().height / 2 - 15))
		self._menu:addChild(item)
		self.gangItems[#self.gangItems + 1] = item
	end
end
function ActionList:removeRepeat(content)
    Log.i("ActionList:removeRepeat...",content)
    local aa={}
    for key,val in pairs(content) do
        aa[val] = true
    end
    local bb={}
    for key,val in pairs(aa) do
        table.insert(bb,key)                --将key插入到新的table，构成最终的结果
    end
    table.sort(bb,function(a, b) return a<b end)
    return bb
end
function ActionList:actionGangMenuCallback(tag, sender)
	Log.i("ActionList:actionGangMenuCallback")
	
	local playLayer = self:getParent()
	assert(playLayer ~= nil)
	playLayer:setPlayerTouchEnabled(true)
	local actionCard = tag - 200
	local action = Define.action_anGang
	if tag > 300 then
		actionCard = tag - 300
		action = Define.action_jiaGang
	end
	WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, action, 1, actionCard, getGangCards(actionCard))
	self:removeFromParent()
end

return ActionList
