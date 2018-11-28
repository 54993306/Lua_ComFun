--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.huaibeimj.mediator.game.Define"
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"
PlayerChat = class("PlayerChat")
function PlayerChat:ctor(type,info,chat_bg,site,head)
    self.m_type = type
    self.m_info = info
    self.m_chat_bg = chat_bg
    self.m_site = site
    self.m_head = head
    dump(self.m_type)
    if self.m_type == 1 then
        self:showChat()
    else
        self:showDefaultChat()
    end
end

function PlayerChat:showDefaultChat()
    Log.i("PlayerChat:showDefaultChat....",self.m_site)

    local cat_bg = nil
    local site = self.m_site
--    local bgSize = self._bgSprite:getContentSize()
    if self.m_info.ty == 1 then
        local face = cc.Sprite:create("hall/gameCommon/face/face_" .. self.m_info.emI .. ".png")
        local faceSize = face:getContentSize()
        local faceWidth = faceSize.width
        local faceHeight = faceSize.height
        if faceWidth < 102 then
            faceWidth = 102
        end
        if faceHeight < 91 then
            faceHeight = 91
        end
        local bgSize = cc.size(faceWidth,faceHeight+20)
        local posX,posY = self.m_chat_bg:getPosition()
        cat_bg = display.newScale9Sprite("games/common/chat_bg.png",posX,posY,bgSize)
       
        if site == Define.site_self then
            cat_bg:setAnchorPoint(cc.p(0,0))
        elseif site == Define.site_right then
            cat_bg:setFlippedX(true)
            face:setFlippedX(true)
            cat_bg:setAnchorPoint(cc.p(0,0))
        elseif site == Define.site_other then
             cat_bg:setFlippedX(true)
            face:setFlippedX(true)
            cat_bg:setAnchorPoint(cc.p(0,1))
        elseif site == Define.site_left then
            cat_bg:setAnchorPoint(cc.p(0,0))
        end
        cat_bg:setCapInsets(cc.rect(51,42,1,1))
        cat_bg:addTo(self.m_head)
        cat_bg:setContentSize(bgSize)
        local catBgSize = cat_bg:getContentSize()
        face:setPosition(cc.p(catBgSize.width/2,30+faceSize.height/2))
        face:addTo(cat_bg)
    elseif self.m_info.ty == 2 then
        --声音
        Sound.effect_yongyu(MjProxy.getInstance()._players[self.m_site]:getSex(), self.m_info.emI)
        local content = _gameChatTxtCfg[self.m_info.emI];
        local lenth = self:widthSingle(content)
        local textSize = 20
        local params = {}
        params.text = content
        params.font = "hall/font/bold.ttf"
        params.size = textSize
        params.x = 0
        params.y = 0
        params.color = display.COLOR_BLACK
        dimensions = cc.size((lenth%10)*20,20*(lenth/10)+20)
        local content_label = display.newTTFLabel(params)
        if lenth < 15 then
            content_label:setDimensions(lenth*textSize,textSize+20)
        else
            local texLen = math.ceil(lenth/15)
            content_label:setDimensions(15*textSize,(textSize+10)*texLen)
        end
        local contentSize = content_label:getContentSize()
        local posX,posY = self.m_chat_bg:getPosition()
        cat_bg = display.newScale9Sprite("games/common/chat_bg.png",posX,posY,bgSize)
        if site == Define.site_self then
            cat_bg:setAnchorPoint(cc.p(0,0))
        elseif site == Define.site_right then
            cat_bg:setFlippedX(true)
            content_label:setScaleX(-1)
            cat_bg:setAnchorPoint(cc.p(0,0))
        elseif site == Define.site_other then
            cat_bg:setFlippedX(true)
            content_label:setScaleX(-1)
            cat_bg:setAnchorPoint(cc.p(0,1))
        elseif site == Define.site_left then
            cat_bg:setAnchorPoint(cc.p(0,0))
        end
        if content then
            local contentWidth = contentSize.width
            local contentHeight = contentSize.height
            if contentWidth < 102 then
                contentWidth = 102
            end
            if contentHeight < 91 then
                contentHeight = 91
            end
            local bgSize = cc.size(contentWidth+30,contentSize.height+45)
            cat_bg:setContentSize(bgSize)
        end
        
        cat_bg:setCapInsets(cc.rect(51,42,1,1))
        cat_bg:addTo(self.m_head)
        content_label:addTo(cat_bg)
        local catBgSize = cat_bg:getContentSize()
        content_label:setPosition(cc.p(catBgSize.width/2,30+contentSize.height/2))
    end
    cat_bg:performWithDelay(function()
        cat_bg:removeAllChildren()
        cat_bg:setVisible(false)
    end, 2);
end
function PlayerChat:widthSingle(inputstr)
    -- 计算字符串宽度
    -- 可以计算出字符宽度，用于显示使用
   local lenInByte = #inputstr
   local width = 0
   local i = 1
    while (i<=lenInByte) 
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        end
         
        local char = string.sub(inputstr, i, i+byteCount-1)
        print(char)                                                     --看看这个字是什么
        i = i + byteCount                                               -- 重置下一字节的索引
        width = width + 1                                               -- 字符的个数（长度）
    end
    return width
end  
function PlayerChat:showChat()
    local cat_bg = nil
    local site = self.m_site
--    local bgSize = self._bgSprite:getContentSize()
    local content = self.m_info.co;
    local lenth = self:widthSingle(content)
    local textSize = 20
    local params = {}
    params.text = content
    params.font = "hall/font/bold.ttf"
    params.size = textSize
    params.x = 0
    params.y = 0
    params.color = display.COLOR_BLACK
    dimensions = cc.size((lenth%10)*20,20*(lenth/10)+20)
    local content_label = display.newTTFLabel(params)
    if lenth < 15 then
        content_label:setDimensions(lenth*textSize,textSize+20)
    else
        local texLen = math.ceil(lenth/15)
        Log.i("texLen.......",texLen)
        content_label:setDimensions(15*textSize,(textSize+10)*texLen)
    end
    local contentSize = content_label:getContentSize()
    local posX,posY = self.m_chat_bg:getPosition()
    cat_bg = display.newScale9Sprite("games/common/chat_bg.png",posX,posY,bgSize)
    
    if site == Define.site_self then
        cat_bg:setAnchorPoint(cc.p(0,0))
    elseif site == Define.site_right then
        cat_bg:setFlippedX(true)
        content_label:setScaleX(-1)
        cat_bg:setAnchorPoint(cc.p(0,0))
    elseif site == Define.site_other then
        cat_bg:setFlippedX(true)
        content_label:setScaleX(-1)
        cat_bg:setAnchorPoint(cc.p(0,1))
    elseif site == Define.site_left then
        cat_bg:setAnchorPoint(cc.p(0,0))
    end
    cat_bg:setCapInsets(cc.rect(51,42,1,1))
    cat_bg:addTo(self.m_head)
    if content then
        local contentWidth = contentSize.width
        local contentHeight = contentSize.height
        if contentWidth < 102 then
            contentWidth = 102
        end
        if contentHeight < 91 then
            contentHeight = 91
        end
        local bgSize = cc.size(contentWidth+30,contentSize.height+45)
        cat_bg:setContentSize(bgSize)
    end
    content_label:addTo(cat_bg)
    local catBgSize = cat_bg:getContentSize()
        
    content_label:setPosition(cc.p(catBgSize.width/2,30+contentSize.height/2))
    cat_bg:performWithDelay(function()
        cat_bg:removeAllChildren()
        cat_bg:setVisible(false)
    end, 2);
end

--显示正在说话
function PlayerChat:showSpeaking(site)
    Log.i("------showSpeaking site", site);
    if not self.speakingBgs then
        self.speakingBgs = {};
    end
    if self.speakingBgs[site] then
        return;
    end
    local bgSize = cc.size(160, 80);
    if site == Define.site_self then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", 130, 208, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        voice_bg:setPosition(cc.p(36, 40));
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setScaleX(-1);
    elseif site == Define.site_right then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", Define.visibleWidth - 296, Define.visibleHeight/2 + 76, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        voice_bg:setPosition(cc.p(124, 40));
        self.speakingBgs[site]:addChild(voice_bg);
    elseif site == Define.site_other then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", Define.visibleWidth - 482, Define.visibleHeight - 118, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setPosition(cc.p(124, 40));
    elseif site == Define.site_left then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", 130, Define.visibleHeight/2 + 76, bgSize);
         local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setPosition(cc.p(36, 40));
        voice_bg:setScaleX(-1);
    end
    self.speakingBgs[site]:setCapInsets(cc.rect(42, 40, 1, 1));
    self.speakingBgs[site]:addTo(self)
    self.speakingBgs[site]:setAnchorPoint(cc.p(0, 0));
end

--说话完毕
function PlayerChat:hideSpeaking(site)
    Log.i("------hideSpeaking site", site);
    if self.speakingBgs and self.speakingBgs[site] then
        self.speakingBgs[site]:setVisible(false);
        self.speakingBgs[site]:removeFromParent(true);
        self.speakingBgs[site] = nil;
    end
end