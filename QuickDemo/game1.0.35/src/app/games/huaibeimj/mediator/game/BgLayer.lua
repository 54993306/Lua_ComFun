-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- endregion
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local Mj = require "app.games.huaibeimj.mediator.game.model.Mj"
local MjSide = require "app.games.huaibeimj.mediator.game.model.MjSide"
local Define = require "app.games.huaibeimj.mediator.game.Define"
-- local UIAnimateSp = require "app.views.UIAnimateSp"
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local Clock = require ("app.games.huaibeimj.mediator.game.model.Clock")
local MJTricks = require("app.games.huaibeimj.custom.MJTricks")
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local BgLayer = class("BgLayer", function ()
    return display.newLayer()
end)

local KEY_GSM_ANIM = "KEY_GSM_ANIM"
local KEY_WIFI_ANIM = "KEY_WIFI_ANIM"

function BgLayer:ctor(isResume, isContinue)
    Log.i("BgLayer:ctor isResume=".. (isResume and "true" or "false"))
    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
    Sound.loadEffectTable()
    CommonSound.loadEffectName()

    CommonSound.music()
    -- 打出去的牌
    self._m_arrOutMj = {}
    self._m_arrOutMj[1] ={}
    self._m_arrOutMj[2] ={}
    self._m_arrOutMj[3] ={}
    self._m_arrOutMj[4] ={}
    self._clock = nil
    -- 速配界面
    self.matchLoadingLayer = nil

    -- 续局准备界面
    self.m_continueReadyLayer = nil
    
    self.m_roomType = nil
    self._isResume = isResume
    self.m_brocastContent = {};

    -- 背景
    local bgSprite = display.newSprite("games/common/mj/games/game_bg.png")
    if display.width / display.height >= 1.9 then
        bgSprite:setScale(Define.visibleWidth/(bgSprite:getContentSize().width),1)
    else
	    bgSprite:setScale(1,Define.visibleHeight / (bgSprite:getContentSize().height))
    end
    bgSprite:setPosition(cc.p(Define.visibleWidth /2, Define.visibleHeight /2))
    bgSprite:addTo(self)
    --背景纹理1
    local game_bg_wenli_1 = display.newSprite("games/common/mj/games/game_bg_wenli_1.png")
    game_bg_wenli_1:setPosition(cc.p(Define.visibleWidth/2,Define.visibleHeight/2))
    game_bg_wenli_1:setOpacity(10)
    game_bg_wenli_1:addTo(self)
     
    local gameId = MjProxy:getInstance():getGameId()
    local guizhe1 = ""
    local guizhe2 = ""
    local palyingInfo = kFriendRoomInfo:getPlayingInfo()
    local ruleNum = 1 -- 规则条数
    for k, v in pairs(palyingInfo) do
        if ruleNum < 3 then
            guizhe1 = guizhe1..v
        else
            guizhe2 = guizhe2..v
        end
        ruleNum = ruleNum + 1
    end
    local text = ccui.Text:create()
    text:setString(guizhe1)
    text:setFontSize(25)
    text:setColor(cc.c3b(237,251,78))
    text:setFontName("hall/font/bold.ttf")
    text:setAnchorPoint(cc.p(0.5,0.5))
    text:setPosition(cc.p(Define.visibleWidth/2,Define.visibleHeight/2-80))
    text:addTo(self)

    local text1 = text:clone()
    text1:setString(guizhe2)
    text:setFontSize(25)
    text:setColor(cc.c3b(237,251,78))
    text:setFontName("hall/font/bold.ttf")
    text1:setPosition(cc.p(Define.visibleWidth/2,Define.visibleHeight/2-105))
    text1:addTo(self)

    local remainCount = 0
    if nil == MjProxy:getInstance()._gameStartData then
        remainCount = 0
    else
        remainCount = MjProxy:getInstance()._gameStartData.rRemainCount
    end

    if nil == remainCount then
        remainCount = 0
    end
    --------------视频回放功能 ----------------------------------------
    local syText = ""
    if VideotapeManager.getInstance():isPlayingVideo() then
        local jushu  = kPlaybackInfo:getCurrentGamesNum()
        syText = string.format("第 %d 局",jushu)
    else
        local jushu  = FriendRoomInfo.getInstance():getTotalCount() - FriendRoomInfo.getInstance():getShengYuCount()+1
        syText = string.format("第 %d/%d 局",jushu, FriendRoomInfo.getInstance():getTotalCount())
        if isContinue then
            syText = string.format("第 %d/%d 局",jushu,FriendRoomInfo.getInstance():getTotalCount())
        end
        if remainCount == 0 then
            syText = string.format("第 %d/%d 局",jushu,FriendRoomInfo.getInstance():getTotalCount())
        end
    end
    ------------------------------------------------------------------
    self._shengyu = ccui.Text:create()
    self._shengyu:setString(syText)
    self._shengyu:setFontSize(25)
    self._shengyu:setColor(cc.c3b(238,253,72))
    self._shengyu:setFontName("hall/font/bold.ttf")
    self._shengyu:setAnchorPoint(cc.p(0.5,0.5))
    self._shengyu:setPosition(cc.p(Define.visibleWidth/2,Define.visibleHeight/2+100))
    self._shengyu:addTo(self)

    self._outPokerLayer = display.newLayer()
    self._outPokerLayer:addTo(self, 1)
    if isContinue == nil then
        self:showMatchLoading()
    end

    if isResume == false and isContinue ~= nil and isContinue == false then
        self:showMatchLoading()
    end
    -- self:startUpDownGame()

end

function BgLayer:onEnter()
    -- timerProxy:addTimer("refreshTimeAndSignal", handler(self, self.refreshTimeAndSignal), 1, -1)
end

function BgLayer:onExit()
    -- timerProxy:removeTimer("refreshTimeAndSignal")
    if self.refreshTimeSchedule then 
        scheduler.unscheduleGlobal(self.refreshTimeSchedule) 
    end
end



function BgLayer:getRoomTypePic(mutil)
    if mutil == 1 then
        return "game_pic_room_cainiao.png"
    elseif mutil == 2 then
        return "game_pic_room_gaoshou.png"
    elseif mutil == 4 then
        return "game_pic_room_dashi.png"
    elseif mutil == 10 then
        return "game_pic_room_queshen.png"
    end
end

function BgLayer:refreshMyHead()

end

function BgLayer:showLoading()
    -- self._midTable = require ("app.games.huaibeimj.mediator.game.BgMidTable").new()
    -- self._midTable:addTo(self)
    -- self._midTable:showLoading(self._isResume)
end

function BgLayer:showViewFirst()

end

function BgLayer:setMoney(site, money)
    self:getParent().m_playerHeadNode:setMoney(site,money)
end

function BgLayer:showHeadSubstitute(site, visible)
    self:getParent().m_playerHeadNode:showHeadSubstitute(site,visible)
end

function BgLayer:showCardCount()
    local count = 0
    if self._isResume == true then
        count = MjProxy:getInstance()._gameStartData.rRemainCount
    else
        count = MjProxy:getInstance()._gameStartData.rRemainCount
    end
    if count == nil then
        count = 0
    end
    local gameid = MjProxy:getInstance():getGameId()
    if gameid == Define.gameId_xuzhou then
        count = math.ceil(count/2)
    elseif gameid == Define.gameId_changzhou then
        count = count
    end
    --------------视频回放功能 ----------------------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        local jushu  = kPlaybackInfo:getCurrentGamesNum()
        local syText = string.format("剩余 %s 张    第 %d 局", count, jushu)
        self._shengyu:setString(syText) 
    else
        local jushu  = FriendRoomInfo.getInstance():getTotalCount() - FriendRoomInfo.getInstance():getShengYuCount()+1
        local syText = string.format("剩余 %s 张    第 %d/%d 局",count,jushu,FriendRoomInfo.getInstance():getTotalCount())
        self._shengyu:setString(syText) 
    end
    ------------------------------------------------------------------
end

function BgLayer:showViews()

    if self._isResume == true then
        self:resumeShowPutDownMj()      
--      self:getParent():showLaiziMj()
    end

    self:showCardCount()
   
    local baseNum = 0
    if(kFriendRoomInfo:isFriendRoom()) then
        baseNum = kFriendRoomInfo:getCurRoomBaseInfo().an; --底注
    else
        baseNum = MjProxy:getInstance():getRoomInfo().an or ""      
    end

    --恢复对局托管
    if self._isResume == true then
        for i=1, #MjProxy:getInstance()._players do
            local userStatus = MjProxy:getInstance()._players[i]:getUserStatus()
            local visible = false
            if userStatus == 2 then --正常
                visible = false
            elseif userStatus == 3 then --离线
                visible = true
            end
            if i > 1 then
                Log.i("showHeadSubstitute =",i)
                self:showHeadSubstitute(i, visible)
            end   
        end
    end
    
    --朋友开房逻辑特殊处理
    if(kFriendRoomInfo:isFriendRoom()) then 
        local tmpScene = MjMediator:getInstance():getScene();
        -- tmpScene.m_friendOpenRoom:setCountUI(self);
    end
    
end

function BgLayer:on_gameStart()
    Log.i("BgLayer:on_gameStart")
    -- 移除速配界面
    self:removeMatchLoading()
    self:removeContinueReadyUi()
    -- 添加闹钟
    if not self._clock then
        self._clock = Clock.new(self._isResume)
        self._clock:addTo(self)
    end

    -- 添加头像
    
    -- local headPos = {cc.p(80, 235), cc.p(Define.visibleWidth - 90, Define.visibleHeight/2+100), cc.p(Define.visibleWidth - 273, Define.visibleHeight - 90), cc.p(80, Define.visibleHeight/2+100)}
--    self:getParent():showHead()
    self:showViews()

    -- self:getParent().m_playerHeadNode:updateBan()
end

function BgLayer:getHeadNode(site)
    if site == 1 then
        return self:getParent().m_playerHeadNode.panel_head_my
    elseif site == 2 then
        return self:getParent().m_playerHeadNode.panel_head_right
    elseif site == 3 then
        return self:getParent().m_playerHeadNode.panel_head_other
    elseif site == 4 then
        return self:getParent().m_playerHeadNode.panel_head_my
    else
        return self:getParent().m_playerHeadNode.panel_head_left
    end
end
function BgLayer:showMFAnim(ty, dSeat, dpx, dpy, sSeat, spx, spy)
    Log.i("------showMFAnim type", ty);
    if ty == 1 then
        SoundManager.playEffect("magic_face_1");
        self:showHezuo(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 3 then
        SoundManager.playEffect("magic_face_3");
        self:showJinggubang(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 2 then
        SoundManager.playEffect("magic_face_2");
        self:showSongtao(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 4 then
        local sex =  MjProxy:getInstance()._players[sSeat]:getSex()
            SoundManager.playEffect("magic_face_4"..sex);
        self:showJinguzou(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 5 then
        SoundManager.playEffect("magic_face_5");
        self:showWuzhishan(dSeat, dpx, dpy, sSeat, spx, spy);
    end
end

function BgLayer:showHezuo(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/hezuo/hezuo.csb");
    local armature = ccs.Armature:create("hezuo");
    self:getParent():addChild(armature,4);
    armature:setPosition(cc.p(spx, spy));
    --armature:setScale(0.68);
    local moveTime = 0.8;
    if sSeat == 1 then
        armature:getAnimation():play("Animation1");
        if dSeat == 4  then
            moveTime = 0.4;
        end
    elseif sSeat == 2 then
        armature:getAnimation():play("Animation2");
        if dSeat == 3 then
            moveTime = 0.4;
        end
    elseif sSeat == 3 then
        if dSeat == 2 then
            armature:getAnimation():play("Animation1");
            moveTime = 0.4;
        else
            armature:getAnimation():play("Animation2");
        end
    elseif sSeat == 4 then
        
        if dSeat == 1 then
            armature:getAnimation():play("Animation2");
            moveTime = 0.4;
        else
            armature:getAnimation():play("Animation1");
        end
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation3");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 1);
    end});
end
function BgLayer:showJinggubang(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/jingubang/jingubang.csb");
    local armature = ccs.Armature:create("jingubang");
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+30));
    --armature:setScale(0.68);
    local moveTime = 1.1;
    
    if (dSeat == 1 and sSeat == 4) 
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
    else
        moveTime = 0.8
--        transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 1.8});
    end
    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 1.9);
    end});
end
function BgLayer:showSongtao(dSeat, dpx, dpy, sSeat, spx, spy)
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/songtao/songtao.csb");
    local armature = ccs.Armature:create("songtao")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy));
    armature:setScale(0.78);
--    local moveTime = 2;
    moveTime = 1.1;
     if sSeat == 1 then
        if dSeat == 4  then
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    elseif sSeat == 2 then
--        transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
        if dSeat == 3 then
            moveTime = 0.4;
        end
    elseif sSeat == 3 then
        if dSeat == 2 then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    elseif sSeat == 4 then
        
        if dSeat == 1 then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.25);
    end});
    
end

function BgLayer:showJinguzou(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/jinguzhou/jinguzhou.csb");
    local armature = ccs.Armature:create("jinguzhou")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+50));
    --armature:setScale(0.68);
    local moveTime = 0.8
    if (dSeat == 1 and sSeat == 4) 
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
    --    transition.scaleTo(armature, {scaleX = 0.85, scaleY = 0.85, time = 0.8});
        moveTime = 0.4;
    else
    ---    transition.scaleTo(armature, {scaleX = 0.85, scaleY = 0.85, time = 1.8});
    end
    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.67);
    end});
end
function BgLayer:showWuzhishan(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/wuzhishan/wuzhishan.csb");
    local armature = ccs.Armature:create("wuzhishan")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+20));
    local moveTime = 0.8
    if (dSeat == 1 and sSeat == 4) 
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
        moveTime = 0.4;
    else
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.67);
    end});
end

function BgLayer:refreshRemainCount()
    local data = MjProxy:getInstance()._playCardData
    -- if self._shengyu and data then
    if self._shengyu then
        local count = MjProxy:getInstance()._gameStartData.rRemainCount
        if count < 0 then
            count = 0
        end
        --------------视频回放功能 ----------------------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            local jushu  = kPlaybackInfo:getCurrentGamesNum()
            local syText = string.format("剩余 %s 张    第 %d 局", count, jushu)
            self._shengyu:setString(syText) 
        else
            local jushu  = FriendRoomInfo.getInstance():getTotalCount() - FriendRoomInfo.getInstance():getShengYuCount()+1
            local syText = string.format("剩余 %s 张    第 %d/%d 局",count,jushu,FriendRoomInfo.getInstance():getTotalCount())
            self._shengyu:setString(syText)
        end
        ------------------------------------------------------------------
    end
end

function BgLayer:setRemainPaiCount()
    local gameId = MjProxy:getInstance():getGameId()
    if gameId == Define.gameId_changzhou then
        if self.m_remainPaiCount then
            self.m_remainPaiCount:setString(string.format("%s", 0))
        end
    end
end

function BgLayer:on_putDownMj(event)
    Log.i("打出去的牌落地")
    local index, x, y, mj = unpack(event._userdata)
    assert(x ~= nil and y ~= nil and mj ~= nil)
    Log.d("打出去的牌落地",index,mj,x,y)
    local node = Mj.new(mj, Mj._EType.e_type_out, Mj._ESide.e_side_self)
	
    if index == 3 then
        node = Mj.new(mj, Mj._EType.e_type_out, Mj._ESide.e_side_other)
    elseif index == 2 then
        node = MjSide.new(mj, MjSide._EType.e_type_out, MjSide._ESide.e_side_right)
    elseif index ==4 then
        node = MjSide.new(mj, MjSide._EType.e_type_out, MjSide._ESide.e_side_left)
    end     
    node:setOpacity(200)
    node:setPosition(cc.p(x, y)):addTo(self._outPokerLayer)

    local xPos = 0
    local xPos = 0
    local point = cc.p(0, 0)
    if index == 1 then
        Log.i("index:",index)
        local  size = #self._m_arrOutMj[index]
        column = 10
        xPos = Define.g_pai_out_x + (size % column) * Define.g_pai_out_space ;
        yPos = Define.g_pai_out_y - math.floor((size / column))* Define.g_pai_out_height;

        if (size + 1) > 20 then
            xPos = Define.g_pai_out_x + (size -10)  * Define.g_pai_out_space ;
        end
        if (size + 1) > 10 then
            yPos = Define.g_pai_out_y -  Define.g_pai_out_height*0.7;
        end
        point.x = xPos
        point.y = yPos + node:getContentSize().height / 2
    elseif index == 2 then
        Log.i("index:",index)
        column = 9
        local  size = #self._m_arrOutMj[index]
        if size > 0 then
            node:setLocalZOrder(self._m_arrOutMj[index][size]:getLocalZOrder() - 1)
        end
        xPos = Define.g_right_pai_out_x + math.floor((size / column))* Define.g_side_pai_out_width
        yPos = Define.g_right_pai_out_y + (size % column)* Define.g_right_pai_out_space 
        point.x = xPos
        point.y = yPos + node:getContentSize().height / 2
    elseif index == 3 then
        Log.i("index:",index)
        local  size = #self._m_arrOutMj[index]
        column = 10
        xPos = Define.g_other_pai_out_x - (size % column) * Define.g_other_pai_out_space ;
        yPos = Define.g_other_pai_out_y + math.floor((size / column))* Define.g_other_pai_out_height;

        if (size + 1) > 20 then
            xPos = Define.g_other_pai_out_x - (size  -10)  * Define.g_other_pai_out_space ;
        end
        point.x = xPos
        point.y = yPos + node:getContentSize().height / 2           
        if (size + 1) > 10 then
            yPos = Define.g_other_pai_out_y +  Define.g_other_pai_out_height*0.7
            if size > 0 then
                node:setLocalZOrder(self._m_arrOutMj[index][size]:getLocalZOrder()-1)
            end
            point.y = yPos + node:getContentSize().height / 2 - 5           
        end 
    elseif index == 4 then
        Log.i("index:",index)
        column = 9
        local  size = #self._m_arrOutMj[index]
        xPos = Define.g_left_pai_out_x - math.floor((size / column))* Define.g_side_pai_out_width;
        yPos = Define.g_left_pai_out_y - (size % column)* Define.g_left_pai_out_space;          
        point.x = xPos
        point.y = yPos + node:getContentSize().height / 2
    end
    local out = cc.EaseBounceOut:create(cc.MoveTo:create(0.2, cc.p(xPos, yPos)))
    node:runAction(cc.Spawn:create(cc.FadeIn:create(0.2),out))
    node:retain()
    
    -- 指针
    if self.pointSprite then
        self.pointSprite:removeFromParent()
        self.pointSprite = nil
    end

    self.pointSprite = display.newSprite("games/common/mj/games/out_poker_point.png")
    self.pointSprite:setPosition(cc.p(x, y + node:getContentSize().height / 2))
    self.pointSprite:addTo(self._outPokerLayer)

    local pointAction = cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveTo:create(0.2, point))
    self.pointSprite:runAction(pointAction)
    self.pointSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)),cc.MoveBy:create(0.5, cc.p(0, -5)))))
    self.pointSprite:setLocalZOrder(node:getLocalZOrder())

    self:removeLastOutMj()
    local  size = #self._m_arrOutMj[index]
	self._m_arrOutMj[index][size+1] = node
    Log.i("添加打出去的牌")
    
    self._m_lastOutMj = {}
    self._m_lastOutMj.mj = node
    self._m_lastOutMj.site = index
    self._m_lastOutMj.pos = size+1
end

function BgLayer:resumeShowPutDownMj()
    for index=1,#MjProxy:getInstance()._players do
        for i=1,#MjProxy:getInstance()._players[index].m_disCards do
            local xPos = 0
            local yPos = 0
            local node = nil
            local column = 0        
            if index == 1 then
                column = 10
                node = Mj.new(MjProxy:getInstance()._players[index].m_disCards[i], Mj._EType.e_type_out, Mj._ESide.e_side_self)
                xPos = Define.g_pai_out_x + ((i -1) % column) * Define.g_pai_out_space ;
                yPos = Define.g_pai_out_y - math.floor(((i -1) / column))* Define.g_pai_out_height;             
                if i > 20 then
                    xPos = Define.g_pai_out_x + (i -11)  * Define.g_pai_out_space ;
                end
                if i > 10 then
                    yPos = Define.g_pai_out_y -  Define.g_pai_out_height*0.7;
                end             
            elseif index ==2 then
                column = 9
                node = MjSide.new(MjProxy:getInstance()._players[index].m_disCards[i], MjSide._EType.e_type_out, MjSide._ESide.e_side_right)
                local  size = #self._m_arrOutMj[index]
                xPos = Define.g_right_pai_out_x + math.floor(((i -1) / column))* Define.g_side_pai_out_width;
                yPos = Define.g_right_pai_out_y + ((i -1) % column)* Define.g_right_pai_out_space;
                if size > 0 then
                    node:setLocalZOrder(self._m_arrOutMj[index][size]:getLocalZOrder() - 1)
                end
            elseif index == 3 then
                column = 10
                node = Mj.new(MjProxy:getInstance()._players[index].m_disCards[i], Mj._EType.e_type_out, Mj._ESide.e_side_other)
                local  size = #self._m_arrOutMj[index]
                xPos = Define.g_other_pai_out_x - ((i -1) % column) * Define.g_other_pai_out_space ;
                yPos = Define.g_other_pai_out_y + math.floor(((i -1) / column))* Define.g_other_pai_out_height;
                if i > 20 then
                    xPos = Define.g_other_pai_out_x - (i -11)  * Define.g_other_pai_out_space ;
                end

                if i > 10 then
                    yPos = Define.g_other_pai_out_y +  Define.g_other_pai_out_height*0.7
                    if size > 0 then
                        node:setLocalZOrder(self._m_arrOutMj[index][size]:getLocalZOrder() - 1)
                    end
                end
            elseif index == 4 then
                column = 9
                node = MjSide.new(MjProxy:getInstance()._players[index].m_disCards[i], MjSide._EType.e_type_out, MjSide._ESide.e_side_left)
                xPos = Define.g_left_pai_out_x - math.floor(((i -1) / column))* Define.g_side_pai_out_width;
                yPos = Define.g_left_pai_out_y - ((i -1) % column)* Define.g_left_pai_out_space;
            end
            
            if node then
                node:setPosition(cc.p(xPos, yPos)):addTo(self._outPokerLayer)
                local  size = #self._m_arrOutMj[index]
                self._m_arrOutMj[index][size+1] = node                      
            end
        end
    end
end

function BgLayer:actionRemoveOutMj(index,actionCard)
    Log.d("BgLayer:actionRemoveOutMj.........",index,actionCard)
    local player = self:getParent()._playLayer._allPlayers[index]
    player:removePutDownMj()
    if #self._m_arrOutMj[index] > 0 then
		local node = self._m_arrOutMj[index][#self._m_arrOutMj[index]]
        local playMj = player:getPutMjValue()
        if (playMj == nil or playMj == 0) and actionCard == node._value then
		    node:removeFromParent()
		    node = nil
            self._m_lastOutMj = nil
		    table.remove(self._m_arrOutMj[index])
            self.removePutOutMj = true
		    if self.pointSprite then
			    self.pointSprite:removeFromParent()
			    self.pointSprite = nil
		    end
        end
	end
end
function BgLayer:removeActionPutOutMj(index,actionCard)
    Log.d("self.removePutOutMj...........",index,actionCard)
--    if (self.removePutOutMj == nil or not self.removePutOutMj) and self._m_arrOutMj~= nil then
        local v = self._m_arrOutMj[player]
        for i = 1,#self._m_arrOutMj do
            local player = index + i
            if player > 4 then
                player = player - 4
            end
            if v ~= nil and #v > 0 then
                local mjNode = v[#v]
				Log.i("self._m_arrOutMj........",mjNode._value)
                if mjNode._value == actionCard then
                    mjNode:setVisible(false)
                    mjNode:removeFromParent()
                    mjNode = nil
                    self._m_lastOutMj = nil
                    table.remove(v)
                    if self.pointSprite then
                        self.pointSprite:setVisible(false)
			            self.pointSprite:removeFromParent()
			            self.pointSprite = nil
		            end
                    break
                end
            end
        end
--    end
--    self.removePutOutMj = false
end
function BgLayer:removeLastOutMj()
    if self:getParent()._m_actionId then
        if self._m_lastOutMj ~= nil and #self._m_lastOutMj > 0 then
            self._m_lastOutMj.mj:removeFromParent()
            table.remove(self._m_arrOutMj[self._m_lastOutMj.site])
            self._m_lastOutMj = nil
             if self.pointSprite then
			    self.pointSprite:removeFromParent()
			    self.pointSprite = nil
		    end
        end
        self:getParent()._m_actionId = nil
    else
        self._m_lastOutMj = nil
        self:getParent()._m_actionId = nil
    end
end
-- 显示听牌标志
function BgLayer:showTingMark(index)
    local ting = display.newSprite("games/common/mj/games/icon_ting.png")
    local space = 70
    local  tingPos = {cc.p(display.cx, display.cy - ting:getContentSize().height / 2 - space ), cc.p(display.cx + ting:getContentSize().width / 2 + space, display.cy), cc.p(display.cx, display.cy + ting:getContentSize().height / 2 + space), cc.p(display.cx - ting:getContentSize().width / 2 - space, display.cy)}
    ting:setPosition(tingPos[index])
    self:addChild(ting)
end

function BgLayer:on_msgMission()
    Log.i("BgLayer:on_msgMission")
    local data = MjProxy:getInstance()._missionData
    if data == nil then
        return
    end

    if data.typee == 99 then
        local finish = nil
        for i = 1, #MjProxy:getInstance()._userIds do  
            if data.userId == MjProxy:getInstance()._userIds[i] then
                finish = display.newSprite("#desk_task_1.png")
                MjProxy:getInstance()._players[i]:setTaskFinished(true)
            end
        end  
        
        finish:setScale(5)
        finish:setOpacity(0)
        finish:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
        finish:setPosition(ww.p(1140, 572))
        self:addChild(finish, 1)
        finish:runAction(cc.Spawn:create(cc.ScaleTo:create(0.2, 1.0), cc.FadeIn:create(0.2)))
    end

    self.taskBg = self.taskBg or nil
    if self.taskBg then
        return
    end

    self.taskBg = cc.Sprite:create("mj/game/game_task_base.png")
    self.taskBg:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_TOP])
    self.taskBg:setPosition(cc.p(1138, 70 + cc.Director:getInstance():getVisibleSize().height))
    self:addChild(self.taskBg, 2)

    local actionPng = ""
    if data.typee == 0 then
        actionPng = "action_chi.png"
    elseif data.typee == 1 then
        actionPng = "action_peng.png"
    elseif data.typee == 2 then
        actionPng = "action_gang.png"
    elseif data.typee == 3 then
        actionPng = "action_ting.png"
    elseif data.typee == 4 then
        actionPng = "action_hu.png"
    elseif data.typee == 5 then
        actionPng = "action_jiabei.png"
    end

    if actionPng == "" then
        return
    end

    local actionDo = display.newSprite("#" .. actionPng)
    actionDo:setAnchorPoint(cc.p(0, 0.5))
    actionDo:setPosition(cc.p(22, 49))
    actionDo:setScale(0.6)
    self.taskBg:addChild(actionDo)

    if data.card ~= 0 then
        local mj = data.card
        local pai_png = {
            { "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
            { "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
            { "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
            { "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
            { "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" }
        }

        local pai = pai_png[math.modf(mj / 10)][mj % 10]
        assert(pai ~= "" and pai ~= nil)

        local taskCardBg = display.newSprite("#game_mj_paimian.png")
        taskCardBg:setPosition(cc.p(actionDo:getContentSize().width + 16, 48))
        taskCardBg:setScale(0.8)
        self.taskBg:addChild(taskCardBg)

        local taskCard = display.newSprite("#" .. pai)
        if mj >= 11 and mj <= 19 then
            taskCard:setScale(0.8)
            taskCard:setPosition(taskCardBg:getContentSize().width / 2, taskCardBg:getContentSize().height - 18)
            taskCardBg:addChild(taskCard)

            local spwan = display.newSprite("#w_w.png")
            spwan:setScale(0.8)
            spwan:setPosition(cc.p(taskCardBg:getContentSize().width / 2, taskCard:getPositionY() - taskCard:getContentSize().height + 3))
            taskCardBg:addChild(spwan)
        else
            taskCard:setPosition(cc.p(taskCardBg:getContentSize().width / 2, taskCardBg:getContentSize().height / 2))
            taskCard:setScale(0.9)
            taskCardBg:addChild(taskCard)
        end
    end

    if data.typee ~= 5 then
        if data.card == 0 then
            local anyCard = display.newSprite("#game_task_rehepai.png")
            anyCard:setScale(0.9)
            anyCard:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
            anyCard:setPosition(cc.p(actionDo:getContentSize().width - 18, 48))
            self.taskBg:addChild(anyCard)
        end
    else
        local beiNum = cc.LabelAtlas:_create(string.format("%s", tostring(data.number)), "mj/game/desk_task_nuber.png", 30, 37, string.byte("0"))
        beiNum:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
        beiNum:setPosition(cc.p(actionDo:getContentSize().width - 45, 48))
        self.taskBg:addChild(beiNum)

        local ci = display.newSprite("#desk_task_ci.png")
        ci:setAnchorPoint(ddisplay.ANCHOR_POINTS[display.LEFT_CENTER])
        ci:setPosition(cc.p(beiNum:getPositionX() + beiNum:getContentSize().width + 2, beiNum:getPositionY()))
        self.taskBg:addChild(ci)
    end

    local taskNum = cc.LabelAtlas:_create(string.format("x:%s", tostring(data.multiple)), "mj/game/game_task_num.png", 27, 38, string.byte("2"))
    taskNum:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    if data.card == 0 then
        taskNum:setPosition(cc.p(145, 48))
    else
        taskNum:setPosition(cc.p(125, 48))
    end
    self.taskBg:addChild(taskNum)
    self.taskBg:runAction(cc.EaseBounceOut:create(cc.MoveTo:create(0.4, ww.p(1138, 698))))

    MjProxy:getInstance()._players[Define.site_self]:setTaskMultiple(data.multiple)

end

function BgLayer:showMatchLoading()
    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height
    -- 防作弊速配中
    self.matchLoadingLayer =  display.newLayer()
    self.matchLoadingLayer:addTo(self)

    local countDownBgSprite = display.newSprite("games/common/mj/games/match_bg.png")
    countDownBgSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight / 2))
    countDownBgSprite:addTo(self.matchLoadingLayer) 

    local match_label = cc.Label:create()
    local match_text = "防作弊排队中."
    match_label:setString(match_text)
    match_label:setSystemFontName ("hall/font/bold.ttf")

    local actionString = ""
    local function labelActionFunc()
        local asLen = string.len(actionString)
        if asLen>=0 and asLen < 5 then
            actionString = actionString.."."
        else
            actionString = ""
        end 
        match_label:setString(match_text..actionString)
        local cf = cc.CallFunc:create(labelActionFunc)
        local dt = cc.DelayTime:create(0.3)
        match_label:runAction(cc.Sequence:create(dt,cf))
    end
    labelActionFunc()
    match_label:setAnchorPoint(0,0.5)
    match_label:setSystemFontSize(40)
    match_label:setPosition(cc.p(countDownBgSprite:getContentSize().width/2-match_label:getContentSize().width/2, countDownBgSprite:getContentSize().height/2))
    match_label:setColor(display.COLOR_WHITE)
    match_label:addTo(countDownBgSprite)
   
end

--更新开始时间
function BgLayer:updateMatchTime()
    self.m_matchTime = self.m_matchTime - 1;
    if self.m_matchTime < 0 then
        self.m_matchTime = 10;
    end
    
    self.match_timeLabel:setString(self.m_matchTime);

    self.m_match_time_update = self.match_timeLabel:performWithDelay(handler(self, self.updateMatchTime), 1);
end

function BgLayer:removeMatchLoading()
    if self.matchLoadingLayer then
        if self.m_match_time_update then
            transition.removeAction(self.m_match_time_update);
            self.m_match_time_update = nil;
        end     
        self.matchLoadingLayer:removeFromParent()
        self.matchLoadingLayer = nil
    end
end

function BgLayer:onTouchSayButton(pWidget, EventType)
    Log.i("------EventType", EventType);
    if EventType == ccui.TouchEventType.began then
        --开始录音
        local data = {};
        data.cmd = NativeCall.CMD_YY_START;
        NativeCall.getInstance():callNative(data); 
        self:showMic();
        
        -- self.beginSayTxt:setString("松开 发送");
    elseif EventType == ccui.TouchEventType.ended then
        --停止录音
        local data = {};
        data.cmd = NativeCall.CMD_YY_STOP;
        data.send = 1;
        NativeCall.getInstance():callNative(data); 
        self:hideMic();
        -- self.beginSayTxt:setString("按住 说话");
    elseif EventType == ccui.TouchEventType.canceled then
        --停止录音
        local data = {};
        data.cmd = NativeCall.CMD_YY_STOP;
        data.send = 0;
        NativeCall.getInstance():callNative(data);
        self:hideMic();
        -- self.beginSayTxt:setString("按住 说话");
    end
end

function BgLayer:showMic()
    audio.pauseMusic();
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function BgLayer:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("hall/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function BgLayer:hideMic()
    if not kSettingInfo:getGameVoiceStatus() then
        audio.resumeMusic();
    end
    self.img_mic:setVisible(false);
end

function BgLayer:removeContinueReadyUi()
    if self.m_continueReadyLayer then
        self.m_continueReadyLayer:removeFromParent()
        self.m_continueReadyLayer = nil
    end
end

function BgLayer:on_showPaoMaDeng(content)
    Log.i("BgLayer:on_showPaoMaDeng")
    if content then
        if not self.pan_notice then
            self.pan_notice = display.newSprite("games/common/mj/common/notice_bg.png")

            self.pan_notice:addTo(self)
            self.pan_notice:setPosition(cc.p(display.cx, display.height - self.pan_notice:getContentSize().height/2))
            self.pan_notice:setVisible(false)
            self.pan_notice:setScale(808/1014, 1)
            self.lb_notice = cc.Label:create()
            self.lb_notice:setSystemFontName ("hall/font/bold.ttf")
            self.lb_notice:setAnchorPoint(0,0.5)
            self.lb_notice:setSystemFontSize(26)
            self.lb_notice:setPosition(cc.p(808, self.pan_notice:getContentSize().height/2))
            self.lb_notice:setColor(display.COLOR_WHITE)
            self.lb_notice:addTo(self.pan_notice)
        end
        
        if not self.pan_notice:isVisible() then
            self.pan_notice:setVisible(true);
            self.lb_notice:setString(content);
            local size = self.lb_notice:getContentSize();
            local moveX = -808 - size.width;
            local showTime = -moveX/130;
            transition.execute(self.lb_notice, cc.MoveBy:create(showTime, cc.p(moveX, 0)), {
                onComplete = function()
                    self.lb_notice:setPosition(cc.p(808, 21));
                    self.pan_notice:setVisible(false);
                    --
                    if #self.m_brocastContent > 0 then
                        local content = table.remove(self.m_brocastContent, 1);
                        self:on_showPaoMaDeng(content);
                    end
                end
            });
        else
            table.insert(self.m_brocastContent, content);
        end
    end 
end

function BgLayer:on_dismissDesk(info)
    if self.m_continueReadyLayer then
        self.m_continueReadyLayer:removeFromParent()
        self.m_continueReadyLayer = nil
        self:showMatchLoading()
    end
    
end

return BgLayer
