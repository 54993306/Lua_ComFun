-------------------------------------------------------------
--  @file   HallSetDialog.lua
--  @brief  设置对话框
--  @author Zhu Can Qin
--  @DateTime:2016-09-21 15:11:13
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

HallSetDialog = class("HallSetDialog", UIWndBase)
-- HallSetDialog = class("HallSetDialog", function ()
--     local layer = display.newLayer()
--     layer:setTouchEnabled(true)
--     layer:setTouchSwallowEnabled(true)
--     return layer
-- end)
local kWidgets = {
    tagNormalLanguge = "normal_languge_img", -- 单选普通话
    tagNativeLanguge = "native_languge_img", -- 单选方言
    tagCheckMusic    = "music_enable_check", -- 复选音乐
    tagCheckVibration = "vibration_enable_check",   --单选震动
    tagSoundBtn      = "sound_btn",          -- 音效按钮
    tagMusicBtn      = "music_btn",          -- 音乐按钮
    tagPanelSound    = "Panel_sound",        -- 声音版块
    tagExitBtn       = "exit_btn",           -- 退出按钮
    tagClsoeBtn      = "close_btn",          -- 关闭按钮
    tagMusicSlider   = "music_slider",       -- 音乐拖动条
    tagSoundSlider   = "sound_slider",       -- 声音拖动条
    tagPanelTop      = "Panel_top",          -- 上面版块
    tagExitWord      = "exit_word",          -- 退出游戏按钮的字
    tagWordLanguge   = "native_languge",     -- 本地语言字
    tagVer           = "Ver",                -- 版本号
}
-- 按钮开关
local kBtnType = {
    ON  = 0, -- 开
    OFF = 1, -- 关
}

-- 按钮开关
local kCSBFileList = {
    [1]     = "hall/set_dialog_hall.csb", 
    [2]     = "hall/set_dialog_game.csb",
}
local filename = ""-- 文件名 
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function HallSetDialog:ctor(data)
    if type(data) == "table" then
        self.data = data
        self.super.ctor(self, kCSBFileList[data.openId], data);
        -- 记录是从哪里打开的设置
        self.openId = data.openId or 1
    else
        self.super.ctor(self, kCSBFileList[data], data);
        -- 记录是从哪里打开的设置
        self.openId = data
    end
    -- self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFileList[self.openId]);
    -- self.m_pWidget:addTo(self)
end

--[[
-- @brief  创建声音相关函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onInit()

    self.exitBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagExitBtn);
    self.exitBtn:addTouchEventListener(handler(self, self.onClickButton));

    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagClsoeBtn);
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));
    -- 声音相关
    self:createSoundPanel()
    -- 上方模块
    self:createTopPanel()

    -- 获取进度条
    self.soundSlider  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagSoundSlider)
    self.musicSlider  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagMusicSlider)
    self.soundSlider:addEventListener(handler(self, self.onSliderSoundEvent))
    self.musicSlider:addEventListener(handler(self, self.onSliderMusicEvent))
    -- self.soundSlider:setPercent(50))  

    -- 设置音效值
    self.soundSlider:setPercent(SettingInfo.getInstance():getGameSoundValue()) 
    self.musicSlider:setPercent(SettingInfo.getInstance():getGameMusicValue())

    self.exitWord   = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagExitWord) 
    if self.openId == 1 then
        self.exitWord:setString("退出登录")
    elseif self.openId == 2 then
        self.exitWord:setString("解散牌桌")
    end

    --联系我们
    self.lianxi_label = ccui.Helper:seekWidgetByName(self.m_pWidget,"lianxi_Label")
    if self.lianxi_label then
        self.lianxi_label:addTouchEventListener(handler(self, self.onClickButton));
        if not IS_IOS_PRODUCT then
            self.lianxi_label:setVisible(false)
        end
    end
    self.ver  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagVer)
    self.ver:setString(tostring("Ver"..VERSION))
end
--[[
-- @brief  创建声音相关函数
-- @param  void
-- @return void
--]]
function HallSetDialog:createSoundPanel()
    --背景音乐设置
    local onImageMusic =  cc.MenuItemImage:create("hall/friendRoom/set/music_btn.png", "hall/friendRoom/set/music_btn.png")
    local offImageMusic = cc.MenuItemImage:create("hall/friendRoom/set/cha.png", "hall/friendRoom/set/cha.png")
    self.toggleClickMusic = cc.MenuItemToggle:create( onImageMusic, offImageMusic )
    -- 获取音乐
    if SettingInfo.getInstance():getMusicStatus() then
        self.toggleClickMusic:setSelectedIndex(kBtnType.ON)
    else
        self.toggleClickMusic:setSelectedIndex(kBtnType.OFF)
    end
    -- 音乐按钮响应
    self.toggleClickMusic:registerScriptTapHandler(handler(self, function ()
        SoundManager.playEffect("btn", "hall");
        if self.toggleClickMusic:getSelectedIndex() == kBtnType.ON then
            if self.openId == 2 then
                audio.playMusic(_gameBgMusicPath, true)
            end
            SettingInfo.getInstance():setMusicStatus(true)
            self.musicSlider:setPercent(100)
            SettingInfo.getInstance():setGameMusicValue(100)
            -- 设置音乐为最大
            audio.setMusicVolume(1)
        elseif self.toggleClickMusic:getSelectedIndex() == kBtnType.OFF then
            audio.stopMusic()
            SettingInfo.getInstance():setMusicStatus(false)
            self.musicSlider:setPercent(0)
            SettingInfo.getInstance():setGameMusicValue(0)
            -- 设置音乐最小
            audio.setMusicVolume(0)
        end
    end)) 

    --音效设置
    local onImageSound =  cc.MenuItemImage:create("hall/friendRoom/set/music_btn.png", "hall/friendRoom/set/music_btn.png")
    local offImageSound = cc.MenuItemImage:create("hall/friendRoom/set/cha.png", "hall/friendRoom/set/cha.png")
    self.toggleClickSound = cc.MenuItemToggle:create( onImageSound, offImageSound )
    if SettingInfo.getInstance():getSoundStatus() then
        self.toggleClickSound:setSelectedIndex(kBtnType.ON)
        audio.resumeAllSounds()     
    else
        self.toggleClickSound:setSelectedIndex(kBtnType.OFF)
        audio.stopAllSounds()
    end
    -- 音效按钮响应
    self.toggleClickSound:registerScriptTapHandler(handler(self, function ()
        SoundManager.playEffect("btn", "hall");
        if self.toggleClickSound:getSelectedIndex() == kBtnType.ON then
            audio.resumeAllSounds()
            SettingInfo.getInstance():setSoundStatus(true)
            self.soundSlider:setPercent(100)
            SettingInfo.getInstance():setGameSoundValue(100)
            -- 设置音效最大
            audio.setSoundsVolume(1)
        elseif self.toggleClickSound:getSelectedIndex() == kBtnType.OFF then
            audio.stopAllSounds()
            SettingInfo.getInstance():setSoundStatus(false)
            self.soundSlider:setPercent(0)
            SettingInfo.getInstance():setGameSoundValue(0)
            -- 设置音效最小
            audio.setSoundsVolume(0)
        end
    end)) 

    local panelSound    = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagPanelSound)
    local soundBtn      = ccui.Helper:seekWidgetByName(panelSound, kWidgets.tagSoundBtn)
    local musicBtn      = ccui.Helper:seekWidgetByName(panelSound, kWidgets.tagMusicBtn)
    self.toggleClickMusic:setPosition(musicBtn:getPosition())
    self.toggleClickSound:setPosition(soundBtn:getPosition())
    local menu = cc.Menu:create(self.toggleClickMusic, self.toggleClickSound)
    menu:setPosition(cc.p(0, 0))
    menu:addTo(panelSound)  
end

--[[
-- @brief  创建头顶模块
-- @param  void
-- @return void
--]]
function HallSetDialog:createTopPanel() 
    -- 语音开关
    local onImage2 =  cc.MenuItemImage:create("hall/friendRoom/set/select_on.png", "hall/friendRoom/set/select_on.png")
    local offImage2 = cc.MenuItemImage:create("hall/friendRoom/set/select_off.png", "hall/friendRoom/set/select_off.png")
    local toggleVoiceItem = cc.MenuItemToggle:create( onImage2, offImage2 )
    if SettingInfo.getInstance():getGameVoiceStatus() then
        toggleVoiceItem:setSelectedIndex(kBtnType.ON)
    else
        toggleVoiceItem:setSelectedIndex(kBtnType.OFF)
    end
    toggleVoiceItem:registerScriptTapHandler(handler(self, function ()
        SoundManager.playEffect("btn", "hall");
        if toggleVoiceItem:getSelectedIndex() == kBtnType.ON then
            SettingInfo.getInstance():setGameVoiceStatus(true)
        elseif toggleVoiceItem:getSelectedIndex() == kBtnType.OFF then
            SettingInfo.getInstance():setGameVoiceStatus(false)
        end
    end)) 
    -- 设置页面上的菜单
    local panelTop    = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagPanelTop)
    local voicelBtn   = ccui.Helper:seekWidgetByName(panelTop, kWidgets.tagCheckMusic)
    toggleVoiceItem:setPosition(voicelBtn:getPosition())

    --震动开关
    local onVibrationImage2 =  cc.MenuItemImage:create("hall/friendRoom/set/select_on.png", "hall/friendRoom/set/select_on.png")
    local offVibrationImage2 = cc.MenuItemImage:create("hall/friendRoom/set/select_off.png", "hall/friendRoom/set/select_off.png")
    local toggleVibrationItem = cc.MenuItemToggle:create(onVibrationImage2, offVibrationImage2)
    if SettingInfo.getInstance():getGameVibrationStatus() then
        toggleVibrationItem:setSelectedIndex(kBtnType.ON)
    else
        toggleVibrationItem:setSelectedIndex(kBtnType.OFF)
    end
    toggleVibrationItem:registerScriptTapHandler(handler(self,function ()
        if toggleVibrationItem:getSelectedIndex() == kBtnType.ON then
            SettingInfo.getInstance():setGameVibrationStatus(true)
        elseif toggleVibrationItem:getSelectedIndex() == kBtnType.OFF then
            SettingInfo.getInstance():setGameVibrationStatus(false)
        end
    end))
    local vibrationBtn   = ccui.Helper:seekWidgetByName(panelTop, kWidgets.tagCheckVibration)
    toggleVibrationItem:setPosition(cc.p(vibrationBtn:getPosition()))

    local menu = cc.Menu:create( toggleVoiceItem,toggleVibrationItem)
    menu:setPosition(cc.p(0, 0))
    menu:addTo(panelTop) 

end
--[[
-- @brief  Slider声音函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onSliderSoundEvent(event, type)
    if event:getPercent() == 0 
        and self.toggleClickSound:getSelectedIndex() == kBtnType.ON then
        self.toggleClickSound:setSelectedIndex(kBtnType.OFF)
        SettingInfo.getInstance():setSoundStatus(false)
    elseif event:getPercent() > 0 
        and self.toggleClickSound:getSelectedIndex() == kBtnType.OFF then
        self.toggleClickSound:setSelectedIndex(kBtnType.ON)
        SettingInfo.getInstance():setSoundStatus(true)
    end
    SettingInfo.getInstance():setGameSoundValue(event:getPercent())
    -- 设置音效
    audio.setSoundsVolume(event:getPercent() / 100)
end



--[[
-- @brief  Slider音乐函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onSliderMusicEvent(event, sliderType)
    if event:getPercent() == 0 
        and self.toggleClickMusic:getSelectedIndex() == kBtnType.ON then
        self.toggleClickMusic:setSelectedIndex(kBtnType.OFF)
        SettingInfo.getInstance():setMusicStatus(false)
        audio.pauseMusic()
    elseif event:getPercent() > 0  
        and self.toggleClickMusic:getSelectedIndex() == kBtnType.OFF then
        self.toggleClickMusic:setSelectedIndex(kBtnType.ON)
        SettingInfo.getInstance():setMusicStatus(true)
        if self.openId == 2 then
            audio.playMusic(_gameBgMusicPath, true)
        end
    end
    SettingInfo.getInstance():setGameMusicValue(event:getPercent())
    -- 设置音乐
    audio.setMusicVolume(event:getPercent() / 100)
end

--[[
-- @brief  按钮回调函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.exitBtn then
            
            if self.openId == 1 then

                --umeng退出统计
                local data = {};
                data.cmd = NativeCall.CMD_UMENG_LOGIN_OFF;
                data.usI = kUserInfo:getUserId() .. "";
                data.type = 2;
                NativeCall.getInstance():callNative(data);

                -- 退出到登录
                SocketManager.getInstance():closeSocket();
                kLoginInfo:clearAccountInfo();
                cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
                cc.UserDefault:getInstance():setStringForKey("wx_name", "");
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);

                 

            elseif self.openId == 2 then
                print("HallSetDialog:onClickButton 退出房间")
                UIManager:getInstance():popWnd(HallSetDialog)
		
		        --告诉服务器玩家解散桌子
				--[[
				type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
				##  usI  long  玩家id
				##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
				##  niN  String  发起的用户昵称
				##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
				FriendRoomSocketProcesser.sendFriendRoomLeaveGame();
            end
        elseif pWidget == self.closeBtn then
            UIManager:getInstance():popWnd(HallSetDialog)
        elseif pWidget == self.lianxi_label then
            local data = self.data
            UIManager.getInstance():pushWnd(AddMoneyDialog, data);
        end
    end
end

function HallSetDialog:keyBack()
    UIManager:getInstance():popWnd(HallSetDialog)
end
return HallSetDialog

