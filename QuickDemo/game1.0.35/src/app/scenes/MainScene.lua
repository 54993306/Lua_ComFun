--主场景
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    require("app.hall.HallConfig");
    SocketManager.getInstance():setUserDataProcesser(UserDataProcesser.new());
    cc.Director:getInstance():setAnimationInterval(1/40);
end

--返回键
function MainScene:onKeyboard(code, event)
    Log.i("MainScene:onKeyboard code", code);
    if code == cc.KeyCode.KEY_BACK then
        UIManager.getInstance():disPatchKeyBackEvent();
    end
end

function MainScene:onEnter()
    local glview = cc.Director:getInstance():getOpenGLView()
    if glview then
        --在游戏中被360清除，重启要旋转屏幕
        local size = glview:getFrameSize();
        if size.width > size.height then
            UIManager.getInstance():changeToPortrait();
        end
    end
    
    if not self.m_add then
        --刚启动游戏
        self.m_add = true;
        --返回键监听
        local keyListener = cc.EventListenerKeyboard:create();
        keyListener:registerScriptHandler(handler(self, self.onKeyboard), cc.Handler.EVENT_KEYBOARD_RELEASED);
        local eventDispatch = self:getEventDispatcher();
        eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self);
        --加载UI
        UIManager.getInstance():setCurScene(self);
        UIManager.getInstance():pushWnd(HallLogin);
        -- 初始化配置
        self:initConfig()
    else
        UIManager.getInstance():changeToPortrait();
        if SocketManager.getInstance():getNetWorkStatus() == NETWORK_NORMAL then
            UIManager.getInstance():replaceWnd(HallMain);
        else
            --网络异常退出到登录界面
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
	    
        --释放ccs动画
        if _gameArmatureFileInfoCfg then
            for k, v in pairs(_gameArmatureFileInfoCfg) do
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v);
            end
        end
        --释放无用资源
        if device.platform == "windows" or device.platform == "mac" then
        else
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("games/common/mj/flow.plist")
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("games/common/mj/majiang_pai.plist")
            cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames();
            cc.Director:getInstance():getTextureCache():removeUnusedTextures();
        end 
    end
    
end

--[[
-- @brief  初始化配置函数
-- @param  void
-- @return void
--]]
function MainScene:initConfig()
    -- 初始化音效音量
    local soundValue = SettingInfo.getInstance():getGameSoundValue()
    audio.setSoundsVolume(soundValue / 100)
    -- 初始化音乐音量
    local musicValue = SettingInfo.getInstance():getGameMusicValue()
    audio.setMusicVolume(musicValue / 100)
end

function MainScene:onEnterBackGround()
    Log.i("------MainScene:onEnterBackGround");
end

function MainScene:onEnterForeground()
    if not UIManager.getInstance():getWnd(FriendRoomScene) then
        local hallMain = UIManager.getInstance():getWnd(HallMain);
        if hallMain then
            scheduler.performWithDelayGlobal(function ()
                hallMain:getEnterCode();
            end, 0.5);
        end
    end
end

function MainScene:onExit()
end

return MainScene
