-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local Define = require "app.games.huaibeimj.mediator.game.Define"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local Robot = class("Robot", function ()
	return display.newNode()
end)

function Robot:ctor()
	
	local bgSprite = display.newSprite("games/common/mj/games/robot_bg.png")
--    local bgSprite = display.newScale9Sprite("games/common/mj/games/robot_bg.png",0, 0,cc.size(Define.visibleWidth,Define.visibleHeight))
--	bgSprite:setCapInsets(cc.rect(51,42,1,1))
    local item_canelshadow = cc.MenuItemSprite:create(bgSprite, nil, nil)
	item_canelshadow:registerScriptTapHandler(handler(self, self.btnCb))
--	item_canelshadow:setAnchorPoint(cc.p(0, 0))
	item_canelshadow:setPosition(cc.p(Define.visibleWidth / 2, 0))

	-- 取消托管
	local  btnSprite= display.newSprite("games/common/mj/common/game_btn_yellow.png")
	local  cancelTextSprite= display.newSprite("games/common/mj/games/robot_text_cancel.png")
	cancelTextSprite:setPosition(cc.p(btnSprite:getContentSize().width / 2, btnSprite:getContentSize().height / 2))
	cancelTextSprite:addTo(btnSprite)
	local cancelItem = cc.MenuItemSprite:create(btnSprite, btnSprite)
	cancelItem:registerScriptTapHandler(handler(self, self.btnCb))
	cancelItem:setPosition(cc.p(Define.visibleWidth / 2, cancelItem:getContentSize().height / 2 + 30 ))

	local menu = cc.Menu:create(item_canelshadow, cancelItem)
	menu:setPosition(cc.p(0, 0))
	self:addChild(menu)

end

function Robot:btnCb()
	WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_substitute, 0)
    CommonSound.playSound("anniu")
end

return Robot
