-- 两边玩家麻将
-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local define = require "app.games.huaibeimj.mediator.game.Define"

local MjSide = class("MjSide", function ()
	return display.newNode()
end)

local pai_png = {
	{ "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
	{ "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
	{ "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
	{ "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
	{ "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" }
}

MjSide._EType = {e_type_normal = 10, e_type_out = 11, e_type_action_tang =12,e_type_action_out = 13}
MjSide._ESide = {e_side_left =1, e_side_right=2}

function MjSide:ctor(mjValue, mjType, side )
	-- if type(mjValue) ~= "number" or mjValue < 11 or (mjValue > 19 and mjValue < 41) or (mjValue > 47 and mjValue < 51) or mjValue > 58 then
	-- 	error("MjSide:ctor")
	-- end

	self:setCascadeColorEnabled(true)
	self._value= mjValue
	self._spMjBg = nil
	self._type = mjType
	local pai = pai_png[math.modf(mjValue / 10)][mjValue % 10]
	assert(pai ~= "" and pai ~= nil)

	local mjBg = "#right_out_poker.png"
	local fengPositionY = 8

	if side == MjSide._ESide.e_side_left then
		if mjType == MjSide._EType.e_type_normal then
			mjBg = "#left_peng_poker.png"
            fengPositionY = 9
		elseif mjType == MjSide._EType.e_type_out then
			mjBg = "#left_out_poker.png"
		elseif mjType == MjSide._EType.e_type_action_tang then
			mjBg = "#left_poker_tang.png"
			fengPositionY = 8		
		end
	elseif side == MjSide._ESide.e_side_right then
		if mjType == MjSide._EType.e_type_normal then
			mjBg = "#right_peng_poker.png"
            fengPositionY = 9
		elseif mjType == MjSide._EType.e_type_out then
			mjBg = "#right_peng_poker.png"
		elseif mjType == MjSide._EType.e_type_action_tang then
			mjBg = "#right_poker_tang.png"	
			fengPositionY = 9			
		end
	end

	self._spMjBg = display.newSprite(mjBg)
	self._spMjBg:setCascadeColorEnabled(true)
	self:addChild(self._spMjBg)
	self:setContentSize(self._spMjBg:getContentSize())

	local spMj = cc.Sprite:createWithSpriteFrameName(pai)

	spMj:setPosition(cc.p(self._spMjBg:getContentSize().width / 2, self._spMjBg:getContentSize().height / 2 + fengPositionY))
	if mjType == MjSide._EType.e_type_out then
		spMj:setScale(0.41)
	elseif mjType == MjSide._EType.e_type_normal then
		spMj:setScale(0.48)
	elseif mjType == MjSide._EType.e_type_action_tang then
		spMj:setScale(0.33)		
	end
	if side == MjSide._ESide.e_side_left then
		if mjType == MjSide._EType.e_type_action_tang then
            spMj:setScaleX(0.45)
            spMj:setScaleY(0.31)
        elseif mjType == MjSide._EType.e_type_normal then
            spMj:setScaleX(0.40)
            spMj:setScaleY(0.48)
            spMj:rotateTo(0, 90)
        else
            spMj:rotateTo(0, 90)
		end
	elseif side == MjSide._ESide.e_side_right then
		if mjType == MjSide._EType.e_type_action_tang then
			spMj:rotateTo(0, -180)
            spMj:setScaleX(0.45)
            spMj:setScaleY(0.31)
        elseif mjType == MjSide._EType.e_type_normal then
            spMj:setScaleX(0.40)
            spMj:setScaleY(0.48)
            spMj:rotateTo(0, -90)
		else
			spMj:rotateTo(0, -90)
		end
	end
	self._spMjBg:addChild(spMj)
end



--[[
-- @brief  获取麻将数值
-- @param  void
-- @return void
--]]
function MjSide:getValue()
	return self._value
end

function MjSide:getSortValue()
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


return MjSide
