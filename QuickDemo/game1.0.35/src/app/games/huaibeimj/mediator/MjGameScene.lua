--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MjGameScene = class("MjGameScene",function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    scene.name = "MjGameScene"
    return scene
end)
function MjGameScene:ctor(data)
    self.m_date = data;
    cc.Director:getInstance():setAnimationInterval(1/40);
    self.m_runningScene = {}
--    self:onEnter()
end
--返回键
function MjGameScene:onKeyboard(code, event)
    Log.i("MainScene:onKeyboard code", code);
    if code == cc.KeyCode.KEY_BACK then
--        UIManager.getInstance():disPatchKeyBackEvent();
--        Log.i("点击返回按钮")
        if self.m_runningScene ~= nil then
            self.m_runningScene:onKeyboard()
        end
    end
end

function MjGameScene:onEnterBackGround()
    Log.i("MjGameScene:onEnterBackGround")
    if kSettingInfo:getMusicStatus() == true then
        audio:pauseMusic()
    end
    -- MjProxy:getInstance():setIsEnterBackground(true)
end
function MjGameScene:onEnterForeground()
    Log.i("MjGameScene:onEnterForeground")
    -- self:performWithDelay(function ()
    if MjProxy:getInstance():getGameOver() == false then
        -- MjProxy:getInstance()._msgCache = {}
        -- LoadingView.getInstance():show("正在重连...");    
        -- SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME,  { plID = MjProxy:getInstance():getPlayId()});
    end
    if kSettingInfo:getMusicStatus() == true then
        if audio.willPlayMusic() then
            audio.resumeMusic()
        else
            audio.playMusic("games/common/mj/mjsound/bgMusic.mp3", true)
        end
    end
    -- end, 1)

end

function MjGameScene:onEnter()
    Log.i("MjGameScene:onEnter....",self.m_date)
    UIManager.getInstance():changeToLandscape();
    --返回键监听
    if not self.m_add then
      self.m_add = true;
        --朋友开房逻辑特殊处理
      if(kFriendRoomInfo:isFriendRoom()) then
         Log.i("当前游戏是从朋友开房进入")
         --
         local data ={}
         data.startGameWay = StartGameType.FIRENDROOM;
         data.m_delegate = self;
         data.roomGameType = FriendRoomGameType.MJ; --麻将游戏
         self.m_friendOpenRoom = OpenRoomGame.new(data)
      end
      MjMediator.getInstance():onGameEntryComplete(self.m_date);

        local keyListener = cc.EventListenerKeyboard:create();
        keyListener:registerScriptHandler(handler(self, self.onKeyboard), cc.Handler.EVENT_KEYBOARD_RELEASED);
        local eventDispatch = self:getEventDispatcher();
        eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self);
    end
    SocketManager.getInstance():reStartReceivePacket();


--    local dispatchCustomEvent = cc.EventDispatcher:create()
--    dispatchCustomEvent:
--    data = {}
--	data.tipStr = "是否退出游戏？"
--	data.confirmStr = "退出游戏"
--	data.cancelStr = "取消"
--	data.confirmCallBack = function ()
--		SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom,  { });
--        CommonSound.playSound("anniu")
--	end
--	data.cancelCallBack = function ()
--		CommonSound.playSound("anniu")
--	end
--	self.m_dialog = MJCommonDialog.new(data)
--	cc.Director:getInstance():getRunningScene():addChild(self.m_dialog)   	
--    self.menuBgSprite:setVisible(false)
--    CommonSound.playSound("duihuakuang")
end

function MjGameScene:onExit()
  Log.i("MjGameScene:onExit()..............");
  --朋友开房逻辑特殊处理
  if(self.m_friendOpenRoom~=nil) then
	   self.m_friendOpenRoom:dtor();
	   self.m_friendOpenRoom=nil
  end
end
function MjGameScene:setRunningLayer(layer)
    self.m_runningScene = layer
end
return MjGameScene

--endregion
