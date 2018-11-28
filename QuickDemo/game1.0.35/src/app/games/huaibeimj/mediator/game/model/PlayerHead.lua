--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.huaibeimj.mediator.game.Define"
PlayerHead = class("PlayerHead")
local kHeadPanel = {
    [Define.site_self] =  "Panel_head_my",
    [Define.site_right] =  "Panel_head_right",
    [Define.site_other] =  "Panel_head_other",
    [Define.site_left] =  "Panel_head_left",
}
-- 头像显示模式类型
local kModePng = {
    [Define.action_xiaPao] = "games/huaibeimj/game/friendRoom/icon_pao.png",
    [Define.action_laZhuang] = "games/huaibeimj/game/friendRoom/icon_la.png",
    [Define.action_zuo] = "games/huaibeimj/game/friendRoom/icon_zuo.png",
}
-- 最大下跑或者拉庄数
local maxNum = 2
function PlayerHead:ctor(data)
--    self.super.ctor(self, "games/common/mj/playerHead.csb", data);
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/huaibeimj/game/playerHead.csb");
    self.m_data = data
    self.m_headImage    = {}
    self.speakPanel     = {} -- 聊天条
    self.actionPanels   = {} -- 所有头像加注容器
end
function PlayerHead:setDelegate(delegate)
    self.m_delegate = delegate;
end
--获取子控件时赋予特殊属性(支持Label,TextField)
function PlayerHead:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
    if(widget == nil) then 
        return; 
    end
    
    return widget;
end
function PlayerHead:onInit()
--    self.site = self.m_data.site
    --自己的头像
    self.panel_head_my = self:getWidget(self.m_pWidget,"Panel_head_my")
    self:updateHead(self.panel_head_my, Define.site_self)
    --右家的头像
    self.panel_head_right = self:getWidget(self.m_pWidget,"Panel_head_right")
    self:updateHead(self.panel_head_right, Define.site_right)
    --对家的头像
    self.panel_head_other = self:getWidget(self.m_pWidget,"Panel_head_other")
    self:updateHead(self.panel_head_other, Define.site_other)
    --左家的头像
    self.panel_head_left = self:getWidget(self.m_pWidget,"Panel_head_left")
    self:updateHead(self.panel_head_left, Define.site_left)

    -- self:setGameLayer()
    self:initReadySprite()
end

function PlayerHead:updateHead(panel_head, site)
    local image_head_bg = self:getWidget(panel_head,"Image_head_bg")
    image_head_bg:setName("image_head_bg_"..site)
    image_head_bg:addTouchEventListener(handler(self,self.onClickHead))
    local bgSize = image_head_bg:getContentSize()
    --头像
    local image_head_Sprite = self:getWidget(panel_head,"Image_head_Sprite")
    image_head_Sprite:ignoreContentAdaptWithSize(false);
    image_head_Sprite:setContentSize(cc.size(bgSize.width - 6, bgSize.height - 6))
    self:getPlayerHead(image_head_Sprite,site)

--    local moren_head_img = "hall/Common/moren_woman_head.png"
--    if kUserInfo:getUserSex() == 1 then
--        moren_head_img = "hall/Common/moren_man_head.png"
--    end
--    local moren_head = display.newSprite(moren_head_img)
--    local frameSize = image_head_Sprite:getContentSize()
--    moren_head:setName("moren_head")
--    moren_head:setScale(0.8)
--    moren_head:addTo(image_head_Sprite)
--    moren_head:setPosition(cc.p(frameSize.width/2,frameSize.height/2))

    --名字
    local strNickName = MjProxy:getInstance()._players[site]:getNickName()
    local nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
    local label_player_name = self:getWidget(panel_head,"Label_player_name")
    label_player_name:setString(nickName)

    --积分
    local strMoney = tostring(MjProxy:getInstance()._players[site]:getFortune())
    local jifen = {
        text = "100",
        font = "games/common/mj/games/jifenNumber.fnt",
    }
    local jifenLabel = display.newBMFontLabel(jifen);
    jifenLabel:setString(strMoney);
    jifenLabel:setPosition(cc.p(bgSize.width/2, jifenLabel:getContentSize().height/2 - 5));
    jifenLabel:setName("jifenLabel")
    jifenLabel:addTo(panel_head,3);

    --庄
    
    local image_zhuang = self:getWidget(panel_head,"Image_zhuang")
    image_zhuang:setVisible(false)
    --聊天背景
    local image_cat_bg = self:getWidget(panel_head,"Image_cat_bg")
    image_cat_bg:setVisible(false)

    --离线图片
    local image_substitute = self:getWidget(panel_head,"Image_substitute")
    image_substitute:setVisible(false)

    --跑1容器
    local actionPanel1 = self:getWidget(panel_head, "Panel_action_1")
    actionPanel1:setVisible(false)
    if self.actionPanels[site] == nil then
        self.actionPanels[site] = {}
    end
    -- 容器对象内容
    local panelContent = {
        obj     = actionPanel1,
        status  = false,
    }
    table.insert(self.actionPanels[site], panelContent)
    --跑2容器
    local actionPanel2 = self:getWidget(panel_head, "Panel_action_2")
    actionPanel2:setVisible(false)
    -- 容器对象内容
    local panelContent = {
        obj     = actionPanel2,
        status  = false,
    }
    table.insert(self.actionPanels[site], panelContent)

    -- 聊天语音条
    self.speakPanel[site] = self:getWidget(panel_head,"Panel_speak")
    self.speakPanel[site]:setVisible(false)

    -- 更新ip相同
    self:ipXiangTong(MjProxy:getInstance()._players, image_head_Sprite,site)
end

function PlayerHead:onClickHead(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        local name = pWidget:getName()
        local site = tonumber(string.sub(name,15))
        Log.i("site........",site)
        local jindu = MjProxy:getInstance()._players[site]:getJinDu()
        local weidu = MjProxy:getInstance()._players[site]:getWeiDu()
        local ipA = MjProxy:getInstance()._players[site]:getIpA()
        local wType = 2
        local headImage = self.m_headImage[site]
        local name = MjProxy:getInstance()._players[site]:getNickName()
        local other = {}
        local player= 0
        local userid = MjProxy:getInstance()._players[site]:getUserId()
        for i=1,3 do
            if other[i] == nil then
                other[i] = {}
            end
            if i >= site then
                player = i+1
            else
                player = i
            end

            other[i].lo = MjProxy:getInstance()._players[player]:getJinDu()
            other[i].la = MjProxy:getInstance()._players[player]:getWeiDu()
            other[i].name = MjProxy:getInstance()._players[player]:getNickName()
        end
        local sex = MjProxy:getInstance()._players[site]:getSex()
        local data = {type = wType,playerHeadImage = headImage,playerName = name,playerIP = ipA,lo = jindu,la = weidu,site = other,sex = sex,userid = userid}
        self.infoView = UIManager:getInstance():pushWnd(PlayerPosInfoWnd,data);
        self.infoView:setDelegate(self);
    end
end

function PlayerHead:updateBan()
    local banSite = MjProxy:getInstance():getBanPosition()
    Log.i("PlayerHead:updateBan...",banSite)
    for i=1,4 do
        local head = self:getHead(i)
        local image_zhuang = self:getWidget(head,"Image_zhuang")
        if banSite == i then
            image_zhuang:setVisible(true)
        else
            image_zhuang:setVisible(false)
        end
    end
end

function PlayerHead:getPlayerHead(headSprite,site)
    --头像
    local imgURL = MjProxy:getInstance()._players[site]:getIconId() or "";
    Log.i("------ PlayerHead imgURL", imgURL);
    if string.len(imgURL) > 3 then
        local imgName = MjProxy:getInstance()._players[site]:getUserId().. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        self.m_headImage[site] = headFile;
        if io.exists(headFile) then
            headSprite:loadTexture(headFile);
        else
            self:getNetworkImage(headSprite,imgURL, imgName,site);
        end
    else        
        local headFile = "hall/Common/default_head_2.png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        self.m_headImage[site] = headFile;
        if io.exists(headFile) then
            headSprite:loadTexture(headFile);
        end
    end  
end

function PlayerHead:getNetworkImage(headSprite,url, fileName,site)
    Log.i("PlayerHead.getNetworkImage", "-------url = " .. url);
    Log.i("PlayerHead.getNetworkImage", "-------fileName = ".. fileName);
    if url == "" then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(headSprite,fileName,site);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function PlayerHead:onResponseNetImg(headSprite,imgName,site)
    imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    self.m_headImage[site] = imgName;
    if io.exists(imgName) then
        headSprite:loadTexture(imgName);
    end
end

function PlayerHead:showHeadSubstitute(site,visible)
    local head = self:getHead(site)
    local image_substitute = self:getWidget(head,"Image_substitute")
    image_substitute:setVisible(visible) 
end
function PlayerHead:showChat(index,site,info)
    local head = self:getHead(site)
    local image_cat_bg = self:getWidget(head,"Image_cat_bg")
--    image_cat_bg:setVisible(true)

    local playerChat = PlayerChat.new(index,info,image_cat_bg,site,head)
end

function PlayerHead:setMoney(site,money)
   -- Log.i("PlayerHead:setMoney....",site,money)
   -- local head = self:getHead(site)
   -- local jifenLabel = head:getChildByName("jifenLabel") --self:getWidget(head,"jifenLabel")
   -- jifenLabel:setString(money.."")
end
function PlayerHead:setGameLayer()
    self.panel_head_my:getLayoutParameter():setMargin({ left = 35, right = 0, top = 0, bottom = 179})
    self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 35, top = 0, bottom = 418})
    self.panel_head_other:getLayoutParameter():setMargin({ left = 0, right = 265, top = 35, bottom = 0})
    if display.width / display.height >= 1.9 then
        self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 35, top = 0, bottom = 380})
        self.panel_head_left:getLayoutParameter():setMargin({ left = 35, right = 0, top = 201, bottom = 0})
    else
        self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 35, top = 0, bottom = 418})
        self.panel_head_left:getLayoutParameter():setMargin({ left = 35, right = 0, top = 251, bottom = 0})
    end
    self.panel_head_left:getParent():requestDoLayout()
    if self.m_continueReadySprites ~= nil then
        for i,v in pairs(self.m_continueReadySprites) do
            v:removeFromParent()
        end
        self.m_continueReadySprites = nil
    end
end
--[[
-- @brief  初始化准备精灵函数
-- @param  void
-- @return void
--]]
function PlayerHead:initReadySprite()
    self.panel_head_my:getLayoutParameter():setMargin({ left = 590, right = 0, top = 0, bottom = 60})
    self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 60, top = 0, bottom = 360})
    self.panel_head_other:getLayoutParameter():setMargin({ left = 0, right = 590, top = 60, bottom = 0})
    if display.width / display.height >= 1.9 then
        self.panel_head_left:getLayoutParameter():setMargin({ left = 60, right = 0, top = 251, bottom = 0})
    else
        self.panel_head_left:getLayoutParameter():setMargin({ left = 60, right = 0, top = 360, bottom = 0})
    end
    -- 准备
    self.m_continueReadySprites = {}
    local gap = 20 -- 字与头像的间隙
    for i=1,#MjProxy:getInstance()._players do
        local head = self:getHead(i)
        self.m_continueReadySprites[i] = display.newSprite("games/common/mj/common/text_ready.png")
        self.m_continueReadySprites[i]:setAnchorPoint(cc.p(0.5,0.5))
        local position = cc.p(0,0)
        if i == 1 then
            position = cc.p(head:getContentSize().width / 2, 
                gap + head:getContentSize().height + self.m_continueReadySprites[i]:getContentSize().height / 2)
        elseif i == 2 then
            position = cc.p( 0 - self.m_continueReadySprites[i]:getContentSize().width / 2 - gap, 
                head:getContentSize().height / 2)
        elseif i == 3 then
            position = cc.p( head:getContentSize().width / 2 , 
                - self.m_continueReadySprites[i]:getContentSize().height / 2 - gap)
        elseif i == 4 then
            position = cc.p( gap + head:getContentSize().width + self.m_continueReadySprites[i]:getContentSize().width / 2 , 
                head:getContentSize().height / 2)
        end
        self.m_continueReadySprites[i]:setPosition(position)
        head:addChild(self.m_continueReadySprites[i])
        self.m_continueReadySprites[i]:setVisible(false)
    end
end
--[[
-- @brief  显示精灵图片函数
-- @param  void
-- @return void
--]]

function PlayerHead:showReadySpr(site)
    if self.m_continueReadySprites and self.m_continueReadySprites[site] then
        self.m_continueReadySprites[site]:setVisible(true)
    end
end

--[[
-- @brief  隐藏精灵图片函数
-- @param  void
-- @return void
--]]

function PlayerHead:hideReadySpr(site)
    if self.m_continueReadySprites and self.m_continueReadySprites[site] then
        self.m_continueReadySprites[site]:setVisible(false)
    end
end

function PlayerHead:getHead(site)
    local head = nil
    if site == 1 then
        head = self.panel_head_my
    elseif site == 2 then
        head = self.panel_head_right
    elseif site == 3 then
        head = self.panel_head_other
    elseif site == 4 then
        head = self.panel_head_left
    end
    return head
end
--[[
-- @brief  更新下跑或者拉庄个数函数
-- @param  void
-- @return void
--]]
function PlayerHead:upDateXiaOrLaNum(site, actType, num)
    --跑1图片
    if num <= 0 
        or num > maxNum then
        print("PlayerHead:upDateXiaOrLaNum 输入的数量是0或者过大"..num)
        return
    end
    --容器
    local actionPanel = nil
    if self.actionPanels[site][1].status then
        actionPanel = self.actionPanels[site][2].obj
        actionPanel = self.actionPanels[site][2].obj:setVisible(true)
        self.actionPanels[site][2].status = true
    else
        actionPanel = self.actionPanels[site][1].obj
        self.actionPanels[site][1].status = true
        actionPanel = self.actionPanels[site][1].obj:setVisible(true)
    end
    for i=1, maxNum do
        local str = string.format("Image_pao_%d", i)
        local image_pao = self:getWidget(actionPanel, str)
        
        if i <= num then
            image_pao:setVisible(true)
            -- 修改图片
            image_pao:loadTexture(kModePng[actType], ccui.TextureResType.localType)
        else
            image_pao:setVisible(false)
        end
    end
end

--[[
-- @brief  显示语音条
-- @param  site 座位
-- @return void
--]]
function PlayerHead:showSpeakPanel(site)
    self.speakPanel[site]:setVisible(true)
end

--[[
-- @brief  隐藏语音条
-- @param  site 座位
-- @return void
--]]
function PlayerHead:hideSpeakPanel(site)
    self.speakPanel[site]:setVisible(false)
end

--ip相同
function PlayerHead:ipXiangTong(playerInfo,head,site)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local players = playerInfos.pl
    local weizhi = 0
    if players == nil then
        return
    end
    for i,v in pairs(players) do 
        if v ~= nil and playerInfo[site]:getUserId() == v.usI then
            weizhi = v.we
        end
    end
    Log.i("playerInfos....",playerInfos)
    
    local myIp = playerInfo[site]:getIpA()
    Log.i("myIp....",myIp,site)
    Log.i("getUserId....",playerInfo[site]:getUserId())
    local ipA = {}
    local player= 0
    for i=1,4 do 
        if players[i] ~= nil and playerInfo[site]:getUserId() == players[i].usI then
            myIp = players[i].ipA
            Log.i("myIp1111111.....",myIp)
            Log.i("playerInfo[site]:getUserId()1111.....",playerInfo[site]:getUserId())
            Log.i("players[i].usI11111......",players[i].usI)
        end
    end
    for i=1,4 do
         if players[i] ~= nil and playerInfo[site]:getUserId() ~= players[i].usI then
            player = i
        end
        
        if players[player] ~= nil then
            Log.i("myIp.....",myIp)
            Log.i("players[player].ipA.....",players[player].ipA)
            if myIp == players[player].ipA then
                self:drawIpXiangTong(head)
                break
            end
        end
    end
end

function PlayerHead:drawIpXiangTong(head)
--    local head = self:getHead(site)
    local headOneIp = head:getChildByName("ipxiangtong")
    if headOneIp == nil then
        local ip = display.newSprite("games/common/mj/common/ipxiangtong.png")
        ip:setName("ipxiangtong")
        ip:addTo(head)
        local headSize = head:getContentSize()
        ip:setPosition(cc.p(headSize.width/2,headSize.height/2))
    end
end

--endregion
