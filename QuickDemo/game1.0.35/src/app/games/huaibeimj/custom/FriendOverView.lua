local Define = require "app.games.huaibeimj.mediator.game.Define"
FriendOverView = class("FriendOverView", UIWndBase)
-- 头像显示模式类型
local kModePng = {
    [Define.action_xiaPao] = "games/huaibeimj/game/friendRoom/icon_pao.png",
    [Define.action_laZhuang] = "games/huaibeimj/game/friendRoom/icon_la.png",
    [Define.action_zuo] = "games/huaibeimj/game/friendRoom/icon_zuo.png",
}

function FriendOverView:ctor(data)
    self.super.ctor(self, "games/huaibeimj/game/mj_over.csb", data);
end

function FriendOverView:onInit()
    local gamePath = "app.games."..kFriendRoomInfo:getGameType()..".mediator.game.model.Mj"
    local Mj = require(gamePath)

    self.m_scoreitems = MjProxy:getInstance()._gameOverData.scoreItems

    self.btn_start = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_start");
    self.btn_start:addTouchEventListener(handler(self, self.onClickButton));
    self.lab_rule = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_rule");
    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    local itemList= Util.analyzeString_2(palyingInfo.wa);
    Log.i("itemList.....",itemList)
    local ruleStr = ""
    if (#itemList > 0 ) then
        for i, v in pairs(itemList) do
            local content = kFriendRoomInfo:getPlayingInfoByTitle(v)
            if ruleStr == "" then
                ruleStr = content.ch
            else
                ruleStr = string.format("%s %s", ruleStr, content.ch)
            end
        end
    end
    self.lab_rule:setString(ruleStr)
    
    -- 赢了
    local img_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_title");
    img_title:setVisible(true)

    for i=1,#self.m_scoreitems do
        if self.m_scoreitems[i]:getUserId() == kUserInfo:getUserId() and self.m_scoreitems[i]:getResult() == enResult.WIN then --我赢了
            img_title:setVisible(true)
            break
        elseif self.m_scoreitems[i]:getUserId() == kUserInfo:getUserId() and self.m_scoreitems[i]:getResult() == enResult.FAILED then
            img_title:loadTexture("games/huaibeimj/game/friendRoom/mjOver/text_fail.png")
            break
        elseif self.m_scoreitems[i]:getUserId() == kUserInfo:getUserId() and self.m_scoreitems[i]:getResult() == enResult.BUREAU then
            local bureau = true
            for j =1,#self.m_scoreitems do
                if self.m_scoreitems[j]:getResult() ~= enResult.BUREAU then
                    bureau = false
                end
            end
            if bureau == true then
                img_title:loadTexture("games/huaibeimj/game/friendRoom/mjOver/text_bureau.png")
            else
                img_title:setVisible(false)
            end
            break
        end
    end 

    -- 玩家信息
    self:addPlayers()
    -- 开始或者查看战绩文字
    local img_start = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_start");
    if kFriendRoomInfo:isGameEnd() then
        img_start:loadTexture("games/huaibeimj/game/friendRoom/mjOver/text_total_point.png")
    end
end

function FriendOverView:addPlayers()
    local winnerId = 0
    for i=1,#self.m_scoreitems do
        if self.m_scoreitems[i]:getResult() == enResult.WIN then
            winnerId = self.m_scoreitems[i]:getUserId()
            break
        end
    end
    local winnerSite = MjProxy:getInstance():getPlayerIndexById(winnerId) -- 赢家的位置
    -- local detail = ""
    -- local winSize = 0
    -- if winnerSite ~= 0 then
    --     local pon = self.m_scoreitems[winnerSite].policyName or {}
    --     local pos = self.m_scoreitems[winnerSite].policyScore or {}
    --     local adPN = self.m_scoreitems[winnerSite].addPolicyName or {}
    --     local adPS = self.m_scoreitems[winnerSite].addPolicyScore or {}
    --     local textUnit = "番"
    --     winSize = #pon
    --     local policyName = ""
    --     for i=1, #pon do
    --         policyName = pon[i]..pos[i]..textUnit.." "
    --         local kg = ""
    --         detail = detail..policyName
    --     end
    --     Log.i("FriendOverView:addPlayers....gameId",MjProxy:getInstance():getGameId())
    -- end
    
    self.m_sortScoreitems = {}
    local hostSite = 1
    local playerCount = 4
    for i=1,playerCount do
        if kFriendRoomInfo:getRoomMainID() == self.m_scoreitems[i]:getUserId() then
            hostSite = i
            break
        end
    end
    for i=1,playerCount do
        local  site = (i - hostSite + playerCount)%playerCount +1
        self.m_sortScoreitems[site] = self.m_scoreitems[i]
    end

    -- 玩家信息
    self.lv_player = ccui.Helper:seekWidgetByName(self.m_pWidget, "lv_player");
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/huaibeimj/game/mj_over_item.csb")
    if display.width / display.height >=1.9 then
        self.lv_player:setScale(0.8)
    end
    for i=1,playerCount do
        local item = itemModel:clone()
        self.lv_player:pushBackCustomItem(item);
        -- self:playerItemView(item, scoreItem)
        local img_zhuang = ccui.Helper:seekWidgetByName(item, "img_zhuang");
        local lab_nick = ccui.Helper:seekWidgetByName(item, "lab_nick");
        local lab_point = ccui.Helper:seekWidgetByName(item, "lab_point");
        local lab_fan = ccui.Helper:seekWidgetByName(item, "lab_fan");

        local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
        local pan_mj = ccui.Helper:seekWidgetByName(item, "pan_mj");
        local strNickName = self.m_sortScoreitems[i]:getNickName()
        local strNickNameLen = string.len(strNickName)
        local nickName = ""
        nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
        lab_nick:setString(nickName) 
        if self.m_sortScoreitems[i]:getResult() == enResult.WIN then
            lab_nick:setTextColor(display.COLOR_WHITE)
        end
        -- 区分正负，如果大于0就是正数，小于等于0就默认显示
        if self.m_sortScoreitems[i]:getTotalGold() > 0 then
            lab_point:setString("+"..self.m_sortScoreitems[i]:getTotalGold())
        else
            lab_point:setString(self.m_sortScoreitems[i]:getTotalGold()) 
        end
        -- 改变赢家分数颜色
        if self.m_sortScoreitems[i]:getResult() == enResult.WIN then
            lab_nick:setColor(display.COLOR_WHITE)
        end

        if self.m_sortScoreitems[i]:getUserId() == MjProxy:getInstance():getBankerId() then
            img_zhuang:setVisible(true)
        else
            img_zhuang:setVisible(false)
        end

        lab_fan:setString("")
        Log.i("FriendOverView:addPlayers  detail",self.m_sortScoreitems[i]:getTotalGold(), detail)
        if self.m_sortScoreitems[i]:getResult() == enResult.WIN then --胡牌玩家
            img_hu:setVisible(true)
--             if winSize > 5 then
-- --                lab_fan:setDimensions(400,60)
--                 lab_fan:ignoreContentAdaptWithSize(false)
--                 lab_fan:setTextAreaSize(cc.size(480, 45))
--             end
            -- lab_fan:setString(detail)
            -- 点炮胡的要把点炮的玩家显示出来
        elseif self.m_sortScoreitems[i]:getResult() == enResult.FAILED 
            and MjProxy:getInstance()._gameOverData.winType == enGameOverType.FANG_PAO then
            img_hu:setVisible(true)
            img_hu:loadTexture("games/huaibeimj/game/friendRoom/mjOver/text_fangpao.png", ccui.TextureResType.localType)
        else
            
            img_hu:setVisible(false)
        end
        self:addPlayerMjs(i,pan_mj)

        -- -- 结算条跑拉字样
        -- local paoLaPanel = ccui.Helper:seekWidgetByName(item, "Panel_pao_la")
        -- -- 跑或者拉的个数
        local paoUsid = self.m_sortScoreitems[i]:getUserId()
        local paoLaNum = -1
        local fillingList = {}
        local paoLaPanel1 = ccui.Helper:seekWidgetByName(item, "Panel_pao_la_1")
        paoLaPanel1:setVisible(false)
        local paoLaPanel2 = ccui.Helper:seekWidgetByName(item, "Panel_pao_la_2")
        paoLaPanel2:setVisible(false)
        for t=1, #MjProxy:getInstance()._players do
            if paoUsid == MjProxy:getInstance()._players[t]:getUserId() then
                -- local list = MjProxy:getInstance():getShowFillingListBySite(t)
                -- dumo(list)
                local nums = MjProxy:getInstance()._players[t]:getFillingNum()
                for k, v in pairs(nums) do
                    local panel = nil
                    if v > 0 then
                        if paoLaPanel1:isVisible() then
                            panel = paoLaPanel2
                        else
                            panel = paoLaPanel1
                        end
                        panel:setVisible(true)
                        self:upDateXiaOrLaNum(panel, t, k, v) 
                    end
                end
                break
            end
        end

        -- 显示胡牌提示
        local detail = ""
        local pon = self.m_sortScoreitems[i].policyName or {}
        local pos = self.m_sortScoreitems[i].policyScore or {}
        if #pon > 0  
            and #pos > 0 then
            local textUnit = "番"
            local policyName = ""
            for i=1, #pon do
                policyName = pon[i]..pos[i]..textUnit.." "
                detail = detail..policyName
            end
            Log.i("FriendOverView:addPlayers....gameId",MjProxy:getInstance():getGameId())
            -- lab_fan:setDimensions(400,60)
            -- lab_fan:ignoreContentAdaptWithSize(false)
            -- lab_fan:setTextAreaSize(cc.size(480, 22))
            lab_fan:setString(detail)
        end
    end
end


--[[
-- @brief  更新下跑或者拉庄个数函数
-- @param  void
-- @return void
--]]
function FriendOverView:upDateXiaOrLaNum(panel, site, actType, num)
    --跑1图片
    if num <= 0 
        or num > 2 then
        print("FriendOverView:upDateXiaOrLaNum 输入的数量是0或者过大"..num)
        return
    end
    --容器
    for i=1, 2 do
        local str = "image_pao_la"..i
        local image_pao = ccui.Helper:seekWidgetByName(panel, str)
        if i <= num then
            image_pao:setVisible(true)
            -- 修改图片
            image_pao:loadTexture(kModePng[actType], ccui.TextureResType.localType)
        else
            image_pao:setVisible(false)
        end
    end
end

function FriendOverView:addPlayerMjs(index, pan_mj)
    local gamePath = "app.games."..kFriendRoomInfo:getGameType()..".mediator.game.model.Mj"
    local Mj = require(gamePath)
    local winType = MjProxy:getInstance()._gameOverData.winType --1 自摸 2 点炮 3 流局
    local closeCards = self.m_sortScoreitems[index].closeCards
    local huMj =self.m_sortScoreitems[index]:getHuMJ()
    local winnerId = 0
--    if self.m_scoreitems[index]:getTotalGold() > 0 then
--        winnerId = self.m_scoreitems[index]:getUserId()
--    end

    if winType == enGameOverType.ZI_MO then
        if huMj ~= 0 then
            for i=1,#closeCards do
                if huMj == closeCards[i] then --自摸且不是天胡时，胡的牌已经在closecards里了，要去掉
                    table.remove(closeCards, i)
                    break
                end
            end
        end
    end

    local playerIndex = 1
    for i=1,#MjProxy:getInstance()._players do
        if MjProxy:getInstance()._players[i]:getUserId() == self.m_sortScoreitems[index]:getUserId() then
            playerIndex = i
            break
        end
    end
    local openCards = MjProxy:getInstance()._players[playerIndex].m_arrMyActionMj
    local openType = MjProxy:getInstance()._players[playerIndex].m_arrMyActionType
    Log.i("FriendOverView:addPlayerMjs policyName=",openCards)
    Log.i("FriendOverView:addPlayerMjs closeCards=",closeCards)
    Log.i("FriendOverView:addPlayerMjs huMj = ",huMj)
    Log.i("FriendOverView:addPlayerMjs index = ",index)
    local allMjValues = {}
    
    -- local laiziMj = {}
    local otherMj = {}
    for i=1,#closeCards do
        -- if closeCards[i] == MjProxy:getInstance():getLaizi() then
        --     laiziMj[#laiziMj + 1] = closeCards[i]
        -- else
            otherMj[#otherMj + 1] = closeCards[i]
        -- end
    end
    -- for i=1,#laiziMj do
    --     allMjValues[#allMjValues +1] = laiziMj[i]
    -- end
    for i=1,#otherMj do
        allMjValues[#allMjValues +1] = otherMj[i]
    end
   
    if huMj ~= 0 then
        allMjValues[#allMjValues +1] = huMj
    end
    local length = 0
    local lastOpenCardXpos = 0
    local widthMj = 50
    local spaceX = 10
    local pos = {}
    -- 动作牌
    for i = 1, #openCards do
        local aType = openType[i]
        local mjValues = openCards[i]
        length = length + #mjValues
        for j=1, #mjValues do
            local majiang = Mj.new(mjValues[j], Mj._EType.e_type_action, Mj._ESide.e_side_self)
            pan_mj:addChild(majiang)          
            majiang:setPosition(cc.p(( (length - #mjValues) + (j - 1)) * widthMj + (i-1)*spaceX, pan_mj:getContentSize().height / 2))
            lastOpenCardXpos = majiang:getPositionX()
            if j == 3 then
                pos.x = ((length - #mjValues) + (j - 1)) * widthMj + (i-1)*spaceX
                pos.y = pan_mj:getContentSize().height / 2
                pos.mj = majiang
            end
        end
        -- 暗杠提示
        if aType == 5 then
            local atBg = display.newSprite("games/common/mj/common/angang_bg.png")
            atBg:setPosition(cc.p(pos.x-pos.mj:getContentSize().width/2, atBg:getContentSize().height/2 ))
            pan_mj:addChild(atBg)

            local atIcon = display.newSprite("games/common/mj/common/angang.png")
            atIcon:setPosition(cc.p(atBg:getContentSize().width /2  , atBg:getContentSize().height / 2 ))
            atBg:addChild(atIcon)
        end
    end

    -- 手牌
    for i=1,#allMjValues do
        local majiang = Mj.new(allMjValues[i], Mj._EType.e_type_action, Mj._ESide.e_side_self)
        pan_mj:addChild(majiang)
        if huMj ~= 0 and i == #allMjValues 
            and huMj == allMjValues[i] 
            and self.m_sortScoreitems[index]:getResult() == enResult.WIN then

            local huIcon = display.newSprite("games/common/mj/common/icon_hu.png")
            huIcon:setAnchorPoint(cc.p(1,1))
            huIcon:setScale(0.8)
            huIcon:setPosition(cc.p(widthMj /2  , majiang:getContentSize().height / 2 ))
            majiang:addChild(huIcon)
            if #openCards > 0 then
                majiang:setPosition(cc.p(lastOpenCardXpos + i *widthMj + spaceX*2, pan_mj:getContentSize().height / 2))

            else
                majiang:setPosition(cc.p(lastOpenCardXpos + (i -1) *widthMj + 10, pan_mj:getContentSize().height / 2))
            end
        else
            if #openCards > 0 then
                majiang:setPosition(cc.p(lastOpenCardXpos + i *widthMj + spaceX, pan_mj:getContentSize().height / 2))
            else
                majiang:setPosition(cc.p(lastOpenCardXpos + (i-1) *widthMj , pan_mj:getContentSize().height / 2))
            end
        end
              
        -- if majiang._value == MjProxy:getInstance():getLaizi() then
        --     if majiang:getChildByName("mjLaizi") == nil then
        --         local mjLaizi = display.newSprite("#xuanzhonglaizi.png")
        --         mjLaizi:setName("mjLaizi")
        --         mjLaizi:setPosition(cc.p(0, 0))
        --         mjLaizi:setScale(widthMj/mjLaizi:getContentSize().width)
        --         majiang:addChild(mjLaizi)
        --     end
        -- end
    end    
end

function FriendOverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_start then 
            MjProxy.getInstance():setGameState("gameStart")
		    if(kFriendRoomInfo:isGameEnd()) then
		        local tmpScene = MjMediator:getInstance():getScene();
			    tmpScene.m_friendOpenRoom:gameOverUICallBack();
		    else
               self:keyBack()
               MjMediator:getInstance():continueGame(1) 
			end
        end
    end
end
