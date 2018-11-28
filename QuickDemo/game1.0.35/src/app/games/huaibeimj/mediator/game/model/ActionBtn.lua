-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local Define = require "app.games.huaibeimj.mediator.game.Define"

local ActionBtn = { }

local function getTaskPng(param)
	local pngStr = nil
	assert(param ~= nil)

	local actionType = param.typee
	if actionType == 0 then
		pngStr = "game_btn_chi.png"
	elseif actionType == 1 then
		pngStr = "game_btn_peng.png"
	elseif actionType == 2 then
		pngStr = "game_btn_gang.png"
	elseif actionType == 3 then
		pngStr = "Maction_ting.png"
	elseif actionType == 4 then
		pngStr = "game_btn_hu.png"
	elseif actionType == 5 then
		pngStr = "btn_jiabei.png"
	end
	return pngStr
end

local function getActionPng(actionType, param)
	local pngStr = nil
	if actionType == Define.action_chi then
		pngStr = "game_btn_chi.png"
	elseif actionType == Define.action_peng then
		pngStr = "game_btn_peng.png"
	elseif actionType == Define.action_mingGang or  actionType == Define.action_anGang then
		pngStr = "game_btn_gang.png"
	elseif actionType == Define.action_jiaGang  then
		pngStr = "game_btn_bugang.png"
	elseif actionType == Define.action_ting then
		pngStr = "game_btn_ting.png"
	elseif actionType == Define.action_buTing then
		pngStr = "game_btn_buting.png"
	elseif actionType == Define.action_dianPaoHu then
		pngStr = "game_btn_hu.png"
	elseif actionType == Define.action_ziMoHu  then
		pngStr = "game_btn_zimo.png"
	elseif actionType == Define.action_guo then
		pngStr = "game_btn_qi.png"
	elseif actionType == Define.action_jiaBei then
		pngStr = "btn_jiabei.png"
	elseif actionType == Define.action_task then
		pngStr = getTaskPng(param)
	end
	return pngStr
end

local function addActionCard(mj, btn)
		local pai_png = {
			{ "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
			{ "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
			{ "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
			{ "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
			{ "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" }
		}

	local pai = pai_png[math.modf(mj / 10)][mj % 10]
	assert(pai ~= "" and pai ~= nil)

	local kuang = display.newSprite("games/common/mj/games/bg_big_out_poker.png")
	kuang:setCascadeColorEnabled(true)
	kuang:setPosition(cc.p(148, btn:getContentSize().height / 2)):addTo(btn)

	local bg = display.newSprite("#self_poker.png")
	bg:setPosition(cc.p(kuang:getContentSize().width / 2, kuang:getContentSize().height / 2))
	kuang:addChild(bg)

	local spMj = display.newSprite("#" .. pai)
	assert(spMj ~= nil)

	if mj >= 11 and mj <= 19 then
		local spWan = display.newSprite("#w_w.png")
		spWan:setScale(0.8)
		spWan:setPosition(cc.p(38, 28))
		kuang:addChild(spWan)

		spMj:setScale(0.8)
		spMj:setPosition(cc.p(38, 58))
	else
		spMj:setPosition(cc.p(kuang:getContentSize().width / 2, kuang:getContentSize().height / 2))
		spMj:setScale(0.8)
	end
	kuang:addChild(spMj)
end

local function createSp(actionType, actionCard, param)
	-- local bg = "action_anniu_2.png"
	-- if actionType == Define.action_guo or actionType == Define.action_ting then
	-- 	bg = "action_anniu_1.png"
	-- end

	-- local btn = display.newSprite("#" .. bg)
    Log.i("actionType....",actionType)
	local actionPng = getActionPng(actionType)
	local actionPng2 = "games/common/mj/games/"..actionPng

		--todo
	assert(actionPng2 ~= nil)

	local action = display.newSprite(actionPng2)
	assert(action ~= nil)
	-- action:setAnchorPoint(cc.p(0, 0.5))
	-- action:setPosition(cc.p(0, btn:getContentSize().height / 2)):addTo(btn)

	-- 如果是任务显示
	-- if actionType == 103 then
	-- 	assert(param ~= nil)
	-- 	if param.typee ~= 5 then
	-- 		if param.card ~= 0 then
	-- 			addActionCard(param.card, btn)
	-- 		end
	-- 	end

	-- 	-- 如果是操作显示
	-- else
	-- 	if actionType == Define.action_chi or actionType == Define.action_peng or actionType == Define.action_mingGang
	-- 		or actionType == Define.action_jiaGang or actionType == Define.action_anGang then
	-- 		if actionCard ~= 0 then
	-- 			addActionCard(actionCard, btn)
	-- 		end
	-- 	end
	-- end

	return action
end

function ActionBtn.createWithType(actionType, actionCard, param)
    Log.i("ActionBtn.createWithType")
	local spNormal = createSp(actionType, actionCard, param)
	local spSelect = createSp(actionType, actionCard, param)
	spSelect:setCascadeColorEnabled(true)
	spSelect:setColor(cc.c3b(166, 166, 166))

	local item = cc.MenuItemSprite:create(spNormal, spSelect)
	return item
end

return ActionBtn
