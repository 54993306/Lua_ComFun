--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local Define = require "app.games.huaibeimj.mediator.game.Define"

local ActionBtnChi = {}
ActionBtnChi._type = {e_type_chi=1, e_type_gang=2}

local function createSp(table, actionType)
	local pai_png = {
		{ "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
		{ "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
		{ "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
		{ "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
		{ "h_mei.png", "h_lan.png", "h_zhu.png", "h_ju.png", "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png" }
	}
	local spPath = nil
	if actionType == ActionBtnChi._type.e_type_chi then
		spPath = "games/common/mj/games/bg_action_chi.png"
	elseif actionType == ActionBtnChi._type.e_type_gang then
		spPath = "games/common/mj/games/bg_action_gang.png"		
	end
	if not spPath then
		return
	end
	local sp = display.newSprite(spPath)

	local x = 55
	local wide = 52
	for i = 1, #table do
		local pai = pai_png[math.modf(table[i] / 10)][table[i] % 10]
		local bg = display.newSprite("#self_poker.png")
		local spMj = cc.Sprite:createWithSpriteFrameName(pai)
		spMj:setPosition(cc.p(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 8))
		bg:addChild(spMj)
		bg:setScale(wide/bg:getContentSize().width, 70/bg:getContentSize().height)
		if actionType == ActionBtnChi._type.e_type_chi then
			bg:setPosition(cc.p(x+(i-1)*(wide + 2), sp:getContentSize().height / 2 + 2))
		elseif actionType == ActionBtnChi._type.e_type_gang then
			bg:setPosition(cc.p(sp:getContentSize().width / 2, sp:getContentSize().height / 2 +2))
		end
		sp:addChild(bg)
	end
	return sp
end

function ActionBtnChi.createWithTable(table, actionType)
	local spNormal = createSp(table, actionType)
	local spSelect = createSp(table, actionType)
	spSelect:setCascadeColorEnabled(true)
	spSelect:setColor(cc.c3b(166, 166, 166))

	local item = cc.MenuItemSprite:create(spNormal, spSelect)
	return item
end

return ActionBtnChi
