-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local define = require "app.games.huaibeimj.mediator.game.Define"

local Mj = class("Mj", function ()
	return display.newNode()
end)

local pai_png = {
	{ "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
	{ "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
	{ "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
	{ "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
	{ "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" }
}

Mj._EState = {e_state_normal = 1, e_state_selected = 2, e_state_touch_invalid = 3, e_state_touch_valid = 4}
Mj._EType = {e_type_normal = 10, e_type_out = 11, e_type_action = 12, e_type_action_tang =13} --e_type_action_tang牌是躺着的
Mj._ESide = {e_side_self =1, e_side_other=3}

function Mj:ctor(mjValue, mjType, side)
	-- if type(mjValue) ~= "number" or mjValue < 11 or (mjValue > 19 and mjValue < 41) or (mjValue > 47 and mjValue < 51) or mjValue > 58 then
	-- 	error("Mj:ctor")
	-- end

	self:setCascadeColorEnabled(true)
	self._value= mjValue
	self._spMjBg = nil
	self._state = Mj._EState.e_state_normal

	local pai = pai_png[math.modf(mjValue / 10)][mjValue % 10]
	assert(pai ~= "" and pai ~= nil)

	local mjBg = "#self_poker.png"
    local mjLaiziBg = "#xuanzhonglaizi.png"
	local wanPositionY = 32 
	local wanNumPositionY = 17 
	local fengPositionY = 8
    
	if mjType == Mj._EType.e_type_out then
		wanPositionY = 33;
		wanNumPositionY = 15;
		fengPositionY = -7;
	elseif mjType == Mj._EType.e_type_action then
		if side == Mj._ESide.e_side_other then
			wanPositionY = 32;
			wanNumPositionY = 15;
			fengPositionY = -5;	
		else
			wanPositionY = 32;
			wanNumPositionY = 15;
			fengPositionY = -10;	
		end
	end

	if side == Mj._ESide.e_side_self then
		if mjType == Mj._EType.e_type_normal then
			mjBg = "#self_poker.png"
--            if mjValue == MjProxy:getInstance():getLaizi() then
--                mjLaiziBg = "#xuanzhonglaizi.png"
--            end
		elseif mjType == Mj._EType.e_type_out then
			mjBg = "#self_out_poker.png"
		elseif mjType == Mj._EType.e_type_action then
			mjBg = "#self_peng_poker.png"
		elseif mjType == Mj._EType.e_type_action_tang then
			mjBg = "#self_poker_tang.png"
            fengPositionY = -18
		end			
	elseif side == Mj._ESide.e_side_other then
		if mjType == Mj._EType.e_type_normal then
			mjBg = "#other_poker.png"
            
		elseif mjType == Mj._EType.e_type_out then
			mjBg = "#other_out_poker.png"
		elseif mjType == Mj._EType.e_type_action then
			mjBg = "#other_peng_poker.png"
            fengPositionY = -7
		elseif mjType == Mj._EType.e_type_action_tang then
			mjBg = "#other_poker_tang.png"
            fengPositionY = 8	
		end
	end

	self._spMjBg = display.newSprite(mjBg)
	self._spMjBg:setCascadeColorEnabled(true)
	self:addChild(self._spMjBg)
	self:setContentSize(self._spMjBg:getContentSize())

	local spMj = cc.Sprite:createWithSpriteFrameName(pai)
	spMj:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2 - fengPositionY))
	if mjType == Mj._EType.e_type_out then
		spMj:setScale(0.41)
	elseif mjType == Mj._EType.e_type_action then
		if side == Mj._ESide.e_side_other then
			spMj:setScale(0.40)
		else
			spMj:setScale(0.5)
		end
	elseif mjType == Mj._EType.e_type_action_tang then
        if side == Mj._ESide.e_side_self then
--		    spMj:setScale(0.45)
            spMj:setScaleX(0.49)
            spMj:setScaleY(0.47)
		    spMj:setRotation(-90)
		    spMj:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2 + 12))
        elseif side == Mj._ESide.e_side_other then
            spMj:setScaleX(0.33)
            spMj:setScaleY(0.35)
		    spMj:setRotation(-90)
		    spMj:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2 + 7))
		end
    elseif mjType == Mj._EType.e_type_normal then
        if side == Mj._ESide.e_side_self then
            spMj:setScale(0.8)
            spMj:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2 - fengPositionY-5))
        end
	end

	self._spMjBg:addChild(spMj)

--    if mjValue == MjProxy:getInstance():getLaizi() and side == Mj._ESide.e_side_self and mjType == Mj._EType.e_type_normal then
--        local mjLaizi = display.newSprite(mjLaiziBg)
--        mjLaizi:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2))
--        self._spMjBg:addChild(mjLaizi)
--    end

end

function Mj:setMjState(state)
	if self._spMjBg then
		self._spMjBg:setOpacity(255)
	end

	if state == self._EState.e_state_normal then
		if self:getPositionY() ~= define.g_pai_y then
			self._state = state
			self:setPosition(cc.p(self:getPositionX(), define.g_pai_y))
		end
	elseif state == self._EState.e_state_selected then
		if self:getPositionY() == define.g_pai_y then
			self._state = state
			self:setPosition(cc.p(self:getPositionX(), define.g_pai_y + 20))
		end
	elseif state == self._EState.e_state_touch_invalid then
		self._state = state
		if self._spMjBg then
			self:setColor(cc.c3b(166, 166, 166))
		end
	elseif state == self._EState.e_state_touch_valid then
		self._state = state
		if self._spMjBg then
			self:setColor(display.COLOR_WHITE)
		end
	end
end

function Mj:isContainsTouch(px, py)
	local nodePoint = cc.p(px, py)
	local rect = self:getBoundingBox()
	rect.x = rect.x - self:getContentSize().width / 2
	rect.y = rect.y - self:getContentSize().height / 2
	local b = cc.rectContainsPoint(rect, nodePoint)
	return b
end

function Mj:getValue()
	return self._value
end

function Mj:getSortValue()
	local value = self._value
	if MjProxy:getInstance():getGameId() == define.gameId_xuzhou then
		if self._value == 47 then --白板
			value = MjProxy:getInstance():getLaizi()
		end
	end
	if self._value == MjProxy:getInstance():getLaizi() then
		value = 0
	end
	return value
end

return Mj
