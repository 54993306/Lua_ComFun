--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Define = require "app.games.huaibeimj.mediator.game.Define"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local MJTurnLaizigou = class("MJTurnLaizigou", function ()
	return display.newNode()
end)

function MJTurnLaizigou:ctor(atomType)
    local pai_png = {
	    { "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
	    { "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
	    { "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
	    { "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
	    { "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" }
    }
    local aType = 1
    local aValue = 1
    if atomType >=11 and atomType <=19 then
        aType = 1
        aValue = atomType - 10
    elseif atomType >=21 and atomType <=29 then
        aType = 2
        aValue = atomType - 20
    elseif atomType >=31 and atomType <=39 then
        aType = 3
        aValue = atomType - 30
    elseif atomType >=41 and atomType <=49 then
        aType = 4
        aValue = atomType - 40
    else
        aType = 1
        aValue = atomType - 10
    end
    CommonSound.playSound("lianglaizi")
--    local bg = display.newSprite("games/common/mj/games/laizidi.png")
--    bg:setPosition(cc.p(155+3,display.height - 51))
--    bg:addTo(self)
    self._myPoker = display.newSprite("#self_poker.png")
    local cardImage = string.format("#%s",pai_png[aType][aValue])
    local myCard = display.newSprite(cardImage)
    myCard:addTo(self._myPoker)
    local pokerSz = self._myPoker:getContentSize()
    myCard:setPosition(cc.p(pokerSz.width/2,pokerSz.height/2-5))
    myCard:setScale(0.8)
    self._myPoker:addTo(self)
    self._myPoker:setPosition(cc.p(display.cx,display.cy))
    self._myPoker:setScale(4)
    self:atomAnimation()
end
function MJTurnLaizigou:atomAnimation()
    local scaleto = cc.ScaleTo:create(0.5,0.5)
    local moveTo = cc.MoveTo:create(0.5,cc.p(260, display.height - 61))
    self._myPoker:runAction(cc.Sequence:create(scaleto,moveTo))
    local pokeSize = self._myPoker:getContentSize()
    local fjaoCallFunc = cc.CallFunc:create(function () 
        local laizifjaowijef = nil
        local gameid = MjProxy:getInstance():getGameId()
        if gameid == Define.gameId_xuzhou then
            laizifjaowijef = display.newSprite("games/common/mj/games/pezi.png")
        elseif gameid == Define.gameId_changzhou then
            laizifjaowijef = display.newSprite("games/common/mj/games/fanzi.png")
        else
            laizifjaowijef = display.newSprite("games/common/mj/games/laizifjaowijef.png")
        end
        laizifjaowijef:addTo(self)
        laizifjaowijef:setPosition(cc.p(260+pokeSize.width/2-7,display.height-61))
        laizifjaowijef:setOpacity(0)
        laizifjaowijef:runAction(cc.FadeIn:create(1))
    end)
    self._myPoker:runAction(cc.Sequence:create(cc.DelayTime:create(1),fjaoCallFunc))
end
return MJTurnLaizigou

--endregion
