local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local Define = require "app.games.huaibeimj.mediator.game.Define"
local GameOverOtherPanel    = require "app.games.huaibeimj.mediator.game.dialog.GameOverOtherPanel"
local GameDetailPanel       = require "app.games.huaibeimj.mediator.game.dialog.GameDetailPanel"
local WWFacade              = require "app.games.huaibeimj.custom.WWFacade"
local XZGameDetailPanel = require "app.games.huaibeimj.mediator.game.dialog.XZGameDetailPanel"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"

local GameOverDialog = class("GameOverDialog", function ()
	return display.newLayer()
end)

function GameOverDialog:ctor(site)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mj/gameover.csb");
   	self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
    self.m_pWidget:addTo(self)
    self.m_scoreitems = MjProxy:getInstance()._gameOverData.scoreItems
    self.Btn_exit = ccui.Helper:seekWidgetByName(self.m_pWidget,"Btn_exit");
    self.Btn_exit:addTouchEventListener(handler(self, self.onClickButton));
    self.Btn_change = ccui.Helper:seekWidgetByName(self.m_pWidget,"Btn_change");
    self.Btn_change:addTouchEventListener(handler(self, self.onClickButton));
    self.Btn_continue = ccui.Helper:seekWidgetByName(self.m_pWidget,"Btn_continue");
    self.Btn_continue:addTouchEventListener(handler(self, self.onClickButton));
    self.pan_poker = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_poker");
    self.pan_detail = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_detail");
    self.pan_detail:addTouchEventListener(handler(self.m_pWidget, function ()
        self.pan_detail:setVisible(false)
    end));
	
    --朋友开房继续按钮
	self.btn_friendRoomContinue = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_friendRoomContinue");
    self.btn_friendRoomContinue:addTouchEventListener(handler(self, self.onClickButton));
	self.btn_friendRoomContinue:setVisible(false);
	
    -- 监听详细信息按钮
    self.handlers = {}
    table.insert(self.handlers, WWFacade:addCustomEventListener(
        enMjEventUi.GAME_OVER_PANEL_DETAIL_BTN, 
        handler(self, self.onEnvetRefresh)))
    table.insert(self.handlers, WWFacade:addCustomEventListener(
        enMjEventUi.GAME_CLOSE_DETAIL_PANEL_BTN, 
        handler(self, self.onEnvetCloseRefresh)))

    local panNames = {"Pan_bottom", "Pan_right", "Pan_top", "Pan_left"}
    local playerPans = {}
    local overItems = {}
    local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
    for i=1,4 do
        playerPans[i] = ccui.Helper:seekWidgetByName(self.m_pWidget,panNames[i]);
        -- 创建其他玩家面板
        local gamePanel
        -- 自己的结算界面特殊处理
        if i == 1 then
            if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
                gamePanel = XZGameDetailPanel.new()
            else
                gamePanel = GameDetailPanel.new()
            end
            gamePanel:onShow(i)
            gamePanel:enableCloseBtn(false)
        else
            gamePanel = GameOverOtherPanel.new()
            gamePanel:onShow(i)
        end
        playerPans[i]:addChild(gamePanel)  
    end

    local panDetailNames = {"pan_de_right", "pan_de_top", "pan_de_left"}
    self.playerDetailPans = {}
    for i=2,4 do
        self.playerDetailPans[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, panDetailNames[i-1]);
        local detailPanel = nil
            if MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
                detailPanel = XZGameDetailPanel.new()
            else
                detailPanel = GameDetailPanel.new()
            end
        detailPanel:onShow(i) 
        detailPanel:enableCloseBtn(true)  
        self.playerDetailPans[i]:addChild(detailPanel)
    end
    -- 显示胡牌的牌
    if winnerSite == 0 then
        return
    end

    if MjProxy:getInstance()._gameOverData.huCount > 1 then --一炮多响不展示牌
        ccui.Helper:seekWidgetByName(self.m_pWidget,"img_ypdx"):setVisible(true)
        return
    end

    local openCards = MjProxy:getInstance()._players[winnerSite].m_arrMyActionMj
    local winType = MjProxy:getInstance()._gameOverData.winType --1 自摸 2 点炮 3 流局
    local closeCards = self.m_scoreitems[winnerSite].closeCards
    local huMj = MjProxy:getInstance():getHuMj()
   
    if winType == 1 then
        if huMj ~= 0 then
            for i=1,#closeCards do
                if huMj == closeCards[i] then --自摸且不是天胡时，胡的牌已经在closecards里了，要去掉
                    table.remove(closeCards, i)
                    break
                end
            end
        end
    end
    
    local allMjValues = {}
    local openCardSize = 0

    for i = 1, #openCards do
        for j=1,#openCards[i] do
            allMjValues[#allMjValues +1] = openCards[i][j]
            openCardSize = openCardSize +1
        end
    end
    
    local laiziMj = {}
    local otherMj = {}
    for i=1,#closeCards do
        if closeCards[i] == MjProxy:getInstance():getLaizi() then
            laiziMj[#laiziMj + 1] = closeCards[i]
        else
            otherMj[#otherMj + 1] = closeCards[i]
        end
    end
    local laiziIndex = 0
    for i=1,#laiziMj do
        allMjValues[#allMjValues +1] = laiziMj[i]
        if i ==1 then
            laiziIndex = #allMjValues
        end
    end
    for i=1,#otherMj do
        allMjValues[#allMjValues +1] = otherMj[i]
    end
    if huMj ~= 0 then
        allMjValues[#allMjValues +1] = huMj
    end
    local widthMj = 70
    if #allMjValues > 16 then
        widthMj = 60
    end
    for i=1,#allMjValues do
        local majiang = Mj.new(allMjValues[i], Mj._EType.e_type_normal, Mj._ESide.e_side_self)
        majiang:setScale(widthMj/85)
        if openCardSize ~=0 and i >openCardSize then
            majiang:setPosition(cc.p(widthMj*(i -1) + 10, self.pan_poker:getContentSize().height / 2))
        else
            majiang:setPosition(cc.p(widthMj*(i -1), self.pan_poker:getContentSize().height / 2))

        end
        if huMj ~= 0 and i == #allMjValues and huMj == allMjValues[i] then
            local huIcon = display.newSprite("games/common/mj/common/icon_hu.png")
            huIcon:setAnchorPoint(cc.p(1,1))
            if widthMj == 60 then
                huIcon:setPosition(cc.p(widthMj /2 + 10 , majiang:getContentSize().height / 2 -12))
            elseif widthMj == 70 then
                huIcon:setPosition(cc.p(widthMj /2 + 8 , majiang:getContentSize().height / 2 -12))
            end
            majiang:addChild(huIcon)
        end
        if majiang._value == MjProxy:getInstance():getLaizi() then
            if majiang:getChildByName("mjLaizi") == nil then
                local mjLaizi = display.newSprite("#xuanzhonglaizi.png")
                mjLaizi:setName("mjLaizi")
                mjLaizi:setPosition(cc.p(0, 0))
                majiang:addChild(mjLaizi)
            end
        end

        self.pan_poker:addChild(majiang)   
     end
     local gameId = MjProxy:getInstance():getGameId()
     if gameId == Define.gameId_changzhou then
         local flower = MjMediator.getInstance()._gameLayer._flowLayer[winnerSite]:getFlowerIndex()
         if flower ~= nil or #flower > 0 then
            self:gameOverFlower(flower,10,-20)
         end
     end
end
-- @brief  显示玩家胡牌时的花数
-- @param  void
-- @return void
--]]
function GameOverDialog:gameOverFlower(flower,flowStartx,flowStarty)
    if flower == nil or #flower <= 0 then
        return
    else
        table.sort(flower, function(a,b) return a<b end )
    end
    for i,v in pairs(flower) do
        local flowSp = display.newSprite(self:getFlowerPng(v))
        local flowContSize = flowSp:getContentSize()
        flowSp:setPosition(cc.p(flowStartx+(flowContSize.width*(i-1)),flowStarty))
        flowSp:addTo(self.pan_poker)
    end
end
-- @brief  获取花对应的图片
-- @param  png
-- @return hua
--]]
function GameOverDialog:getFlowerPng(mj)
	local hua_png = ""
	if mj == 51 then
		hua_png = "#chun.png"
	elseif mj == 52 then
		hua_png = "#xia.png"
	elseif mj == 53 then
		hua_png = "#qiu.png"
	elseif mj == 54 then
		hua_png = "#dong.png"
	elseif mj == 55 then
		hua_png = "#mei.png"
	elseif mj == 56 then
		hua_png = "#lan.png"
	elseif mj == 57 then
		hua_png = "#ju.png"
	elseif mj == 58 then
		hua_png = "#zhu.png"
	end
	return hua_png
end
-- @brief  监听详细信息按钮函数
-- @param  void
-- @return void
--]]
function GameOverDialog:onEnvetRefresh(event)
    local index = event._userdata[1].index
    Log.i("GameOverDialog:onEnvetRefresh...",index)
    self.pan_detail:setVisible(true)
    for i=2,#self.playerDetailPans do
        self.playerDetailPans[i]:setVisible(false)
    end
    self.playerDetailPans[index]:setVisible(true) 
end

--[[
-- @brief  监听详细信息关闭按钮函数
-- @param  void
-- @return void
--]]
function GameOverDialog:onEnvetCloseRefresh(event)
    local index = event._userdata[1].index
    self.pan_detail:setVisible(false)
    for i=2,#self.playerDetailPans do
        self.playerDetailPans[i]:setVisible(false)
    end
    self.playerDetailPans[index]:setVisible(false)
end

function GameOverDialog:setArmature(fileName)
    local MJArmatureCSB = require("app.games.huaibeimj.custom.MJArmatureCSB")
    local armature = MJArmatureCSB.new("games/common/mj/armature/dianpao.csb")
    local action = armature:play("Animation1")
    action:setPosition(cc.p(display.cx, display.cy))
    self:addChild(action)
    armature:setRestoreOriginalTime(1)
end

function GameOverDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        -- 移除详细信息按钮监听
        table.walk(self.handlers, function(h)
            WWFacade:removeEventListener(h)
        end)
        self.handlers = {}
        
        if pWidget == self.Btn_exit then
            -- self:removeFromParent()
			--朋友开房逻辑特殊处理
			local tmpScene = MjMediator:getInstance():getScene();
			local friendRoomObj = tmpScene.m_friendOpenRoom
			if(friendRoomObj~=nil and kFriendRoomInfo:isFriendRoom()) then
		       friendRoomObj:quitGame()
			else
                MjMediator:getInstance():requestExitRoom()

			end
    
        CommonSound.playSound("anniu")
        elseif pWidget == self.Btn_change then
        	self:reqNextGame(2)
            CommonSound.playSound("anniu")
        elseif pWidget == self.Btn_continue then
		
         	self:reqNextGame(1);
            CommonSound.playSound("anniu");
			
		elseif(pWidget == self.btn_friendRoomContinue) then
		    --朋友开房逻辑特殊处理
		    self:friendRoomRequestContinueGame();
        end
        
    end
end

function GameOverDialog:checkRoomLimit()
    local desc = nil;
    local roomInfo = MjProxy:getInstance():getRoomInfo()
    if kUserInfo:getMoney() >= roomInfo.thM then
        if (roomInfo.thM0 == -1 or kUserInfo:getMoney() <= roomInfo.thM0) then
            return true;
        else
            local tmpRoomInfo = GameManager.getInstance():getFastRoomInfo(MjProxy:getInstance():getGameId());
            if tmpRoomInfo then
                local data = {}
                data.type = 2;
                data.title = "提示";                        
                data.yesTitle  = "去"; 
                data.cancelTitle = "不去";
                data.content = "您的金豆已超过本房间最高要求，将进入" .. tmpRoomInfo.na .. "游戏";
                data.yesCallback = function()
                    -- GameManager.getInstance():enterGame(MjProxy:getInstance():getGameId());
                    MjProxy:getInstance():setRoomInfo(tmpRoomInfo)
                    MjProxy:getInstance():setRoomId(tmpRoomInfo.id)
                    self:reqNextGame(0)

                end
                data.cancelCallback = function()
                    MjMediator:getInstance():requestExitRoom();
                end
                UIManager.getInstance():pushWnd(CommonDialog, data);
            end
        end
    else
        local chargeItem = GameManager.getInstance():getChargeItem(roomInfo.thM);
        if chargeItem then
            local data = {};
            data.chargeId = chargeItem.Id;
            data.notChargeExit = true;
            data.landScape = true;
            kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_BREAK,MjProxy:getInstance():getGameId(), MjProxy:getInstance():getRoomId());
            local roomChargeView = UIManager.getInstance():pushWnd(RoomChargeView, data);
            roomChargeView:setDelegate(self);
        else
            MjProxy:getInstance():requestExitRoom();
        end
    end
end

function GameOverDialog:reqNextGame(type)
    if not self:checkRoomLimit() then
        return;
    end
    self:removeFromParent()
    MjMediator:getInstance():continueGame(type)
                    
end

function GameOverDialog:showHead(img_head, site)
    local imgName = MjProxy:getInstance()._players[site]:getIconId()
    if string.len(imgName) > 3 then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            img_head:loadTexture(imgName);
        end
    else
        if imgName == "0" then
            imgName = "1";
        end
        local headFile = "hall/Common/default_head_" .. imgName .. ".png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            img_head:loadTexture(headFile);
        end
    end
end

--朋友开房续局
function GameOverDialog:friendRoomRequestContinueGame()
    --朋友开房逻辑特殊处理,如果当前游戏是从朋友开房进入的,完成一局游戏,游戏局数加1
    Log.i("朋友开房游戏中点击继续按钮..............")
	local tmpScene = MjMediator:getInstance():getScene();
	local friendRoomObj = tmpScene.m_friendOpenRoom
	if(friendRoomObj~=nil and kFriendRoomInfo:isFriendRoom()) then
        friendRoomObj:onContinueButton()
		self:removeFromParent()
        MjMediator:getInstance():newGameLayer(1)
	end
end

return GameOverDialog