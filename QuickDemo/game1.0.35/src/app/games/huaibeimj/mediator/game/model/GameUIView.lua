--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CommonSound = require "app.games.huaibeimj.custom.CommonSound"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local Define = require "app.games.huaibeimj.mediator.game.Define"
GameUIView = class("GameUIView")
local kWidgets = {
    tagAction          = "la_pao_panel_", -- 拉跑坐的版块
    -- tagAction2          = "la_pao_panel_2", -- 拉跑坐的版块
    tagSelectedBtn     = "run_btn_",  -- 选择按钮1
    tagSeleWord        = "word_btn_", -- 选择字1
}
--  显示拉庄或者跑的文字图片目录
local kWordPng = {
    [Define.action_xiaPao] = {
        "games/huaibeimj/game/common/text_buxia.png",    -- 不下
        "games/huaibeimj/game/common/text_one_pao.png",  -- 1跑
        "games/huaibeimj/game/common/text_two_pao.png",  -- 2跑
    },
    [Define.action_laZhuang] = {
        "games/huaibeimj/game/common/text_bula.png",     -- 不拉
        "games/huaibeimj/game/common/text_la1.png",      -- 1拉
        "games/huaibeimj/game/common/text_la2.png",      -- 2拉
    },
    [Define.action_zuo] = {
        "games/huaibeimj/game/common/text_buzuo.png",     -- 不坐
        "games/huaibeimj/game/common/text_zuo1.png",      -- 坐1
        "games/huaibeimj/game/common/text_zuo2.png",      -- 坐2
    },

}
local kMaxPanelNum  = 2 -- 最多的加注操作类型
local kMulti        = 10 -- 按钮标志乘数
function GameUIView:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/huaibeimj/game/gameItem.csb");
    self.m_data = data
    self._selectBtn = {
        agree = false,
        agreeTime = 0.5,
    }
    self.finishXia = false -- 下嘴完成标志
    self.actionPanel = {}
    -- self:onInit()
    -- self:initPaoPanel()
end
function GameUIView:setDelegate(delegate)
    self.m_delegate = delegate;
end
--获取子控件时赋予特殊属性(支持Label,TextField)
function GameUIView:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
	if(widget == nil) then 
        return; 
    end
    
    return widget;
end
function GameUIView:onInit()
    self:updateTitle()
    self:updateString()
    self:updateRoomId()
    self:initPaoPanel()
end
--更新电量信号时间信息
function GameUIView:updateTitle()
    local title_panel = self:getWidget(self.m_pWidget,"title_panel")
    --wifi信号
    self.image_wifi = self:getWidget(title_panel,"Image_wifi")
    self.wifi_1 = self:getWidget(self.image_wifi,"wifi_1")
    self.wifi_2 = self:getWidget(self.image_wifi,"wifi_2")
    self.wifi_3 = self:getWidget(self.image_wifi,"wifi_3")
    self.wifi_4 = self:getWidget(self.image_wifi,"wifi_4")
    --手机信号
    self.image_xinhao = self:getWidget(title_panel,"Image_xinhao")
    self.xinhao_1 = self:getWidget(self.image_xinhao,"xinhao_1")
    self.xinhao_2 = self:getWidget(self.image_xinhao,"xinhao_2")
    self.xinhao_3 = self:getWidget(self.image_xinhao,"xinhao_3")
    self.xinhao_4 = self:getWidget(self.image_xinhao,"xinhao_4")
    -- self:updateSignal()
    --手机电量
    self.image_bat_bg = self:getWidget(title_panel,"Image_bat_bg")
    self.progressBar_pro = self:getWidget(self.image_bat_bg,"ProgressBar_pro")
    -- self:updateBattery()

    --系统时间
    self.label_time = self:getWidget(title_panel,"Label_time")
    self.label_time:setString(os.date("%H:%M", os.time()))
    local function refreshTimeFun ()
        local time = os.date("%H:%M", os.time())
        if time == nil then
            time = " "
        end
        time = string.format(time)
--        Log.i("time ===",time)
        if self.label_time ~= nil then
            self.label_time:setString(time.."")
        end
        self.label_time:performWithDelay(refreshTimeFun,1)
    end
    refreshTimeFun()

    self.m_pWidget:performWithDelay(function()
        self:updateSignal()
        self:updateBattery()
    end, 2)
end

function GameUIView:updateSignal()
    local data = {}
    data.cmd = NativeCall.CMD_WECHAT_SIGNAL
    NativeCall.getInstance():callNative(data, self.onUpdateSignal, self); 
end
function GameUIView:onUpdateSignal(info)
        if tolua.isnull(self.image_wifi) 
            or tolua.isnull(self.image_xinhao) then
            return
        end
        local signalXH = {}
        if info.type ~= "Wi-Fi" then
            self.image_wifi:setVisible(false)
            self.image_xinhao:setVisible(true)
            return
        else
            self.image_wifi:setVisible(true)
            self.image_xinhao:setVisible(false)
        end
        if info.rssi == 4 then
            self.wifi_1:setVisible(true)
            self.wifi_2:setVisible(true)
            self.wifi_3:setVisible(true)
            self.wifi_4:setVisible(true)
        elseif info.rssi == 3 then
            self.wifi_1:setVisible(true)
            self.wifi_2:setVisible(true)
            self.wifi_3:setVisible(true)
            self.wifi_4:setVisible(false)
        elseif info.rssi == 2 then
            self.wifi_1:setVisible(true)
            self.wifi_2:setVisible(true)
            self.wifi_3:setVisible(false)
            self.wifi_4:setVisible(false)
        elseif info.rssi == 1 then
            self.wifi_1:setVisible(true)
            self.wifi_2:setVisible(false)
            self.wifi_3:setVisible(false)
            self.wifi_4:setVisible(false)
        end
    self.m_pWidget:performWithDelay(function()
        self:updateSignal()
    end,60)
end

function GameUIView:updateBattery()
    local data = {};
    data.cmd = NativeCall.CMD_GETBATTERY;
    NativeCall.getInstance():callNative(data, self.onUpdateBattery, self); 
end

function GameUIView:onUpdateBattery(info)
    if tolua.isnull(self.progressBar_pro) then
        return
    end
    self.progressBar_pro:setPercent(info.baPro)
    self.m_pWidget:performWithDelay(function()
        self:updateBattery();
    end, 60);
end
--实现设置聊天按钮
function GameUIView:updateString()
    local stting_panel = self:getWidget(self.m_pWidget,"stting_panel")
    self.button_stting = self:getWidget(stting_panel,"Button_stting")
    self.button_stting:addTouchEventListener(handler(self, self.sttingButton));
    
    self.button_jieshan = self:getWidget(stting_panel,"Button_back")
    self.button_jieshan:addTouchEventListener(handler(self,self.sttingButton))
    -- 语音按钮
    local speek_Panel = self:getWidget(self.m_pWidget,"speek_Panel")
    self.button_chat = self:getWidget(speek_Panel,"Button_chat")
    self.button_chat:addTouchEventListener(handler(self,self.sttingButton))
    -- 语音按钮
    self.Button_yuyin = self:getWidget(speek_Panel,"Button_yuyin")
    self.Button_yuyin:addTouchEventListener(handler(self,self.onTouchSayButton))
    self.Button_yuyin:setVisible(true)

    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height

    -- 语音图片
    local voice_panel = self:getWidget(self.m_pWidget,"voice_panel")
    self.img_mic = self:getWidget(voice_panel,"mic_img")
    self.img_mic:setPosition(cc.p(visibleWidth/2, visibleHeight/2))
    self.img_mic:setVisible(false)

    ---------- 录像回放相关----------------------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        stting_panel:setVisible(false)
    end
    --------------------------------------------------------------
end
function GameUIView:sttingButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.button_stting then
            UIManager:getInstance():pushWnd(HallSetDialog, 2);
            CommonSound.playSound("anniu")
        elseif pWidget == self.button_chat then
            if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then
                MjProxy:getInstance():get_gameChatTxtCfg()
            end
            self.m_chatView = UIManager.getInstance():pushWnd(RoomChatView);
            self.m_chatView:setDelegate(self.m_delegate);
            CommonSound.playSound("anniu")
        elseif pWidget == self.button_jieshan then
		    --告诉服务器玩家解散桌子
			--[[
			type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
			##  usI  long  玩家id
			##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
			##  niN  String  发起的用户昵称
			##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
			if self._selectBtn.agree == false then
                local tmpData={}
                tmpData.usI =  kUserInfo:getUserId()
                tmpData.re = 1
                tmpData.niN = kUserInfo:getUserName()
                tmpData.isF = 0
                SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
                self._selectBtn.agree = true
                self.button_jieshan:runAction(cc.Sequence:create(cc.DelayTime:create(self._selectBtn.agreeTime),cc.CallFunc:create(function() self._selectBtn.agree = false end)))
            end
        end
    end
end
--房间号
function GameUIView:updateRoomId()
    local room_Panel = self:getWidget(self.m_pWidget,"room_Panel")
    local label_room_id = self:getWidget(room_Panel,"Label_room_id")
    label_room_id:setString(MjProxy:getInstance():getRoomId())
end
--[[
-- @brief  初始化跑版块函数
-- @param  void
-- @return void
--]]
function GameUIView:initPaoPanel()
    for i=1, kMaxPanelNum do
        local panel = self:getWidget(self.m_pWidget, kWidgets.tagAction..i)
        table.insert(self.actionPanel, panel)
        panel:setVisible(false)
    end
end 

--[[
-- @brief  显示下跑函数
-- @param  void
-- @return void
--]]
function GameUIView:showXiaPaoOrLaPanel()
    for i=1,#self.actionPanel do
        self.actionPanel[i]:setVisible(true)
    end
end

--[[
-- @brief  隐藏下跑版块函数
-- @param  void
-- @return void
--]]
function GameUIView:hideXiaPaoOrLaPanel()
    for i=1,#self.actionPanel do
        self.actionPanel[i]:setVisible(false)
    end
end

--[[
-- @brief  下跑按钮回调
-- @param  void
-- @return void
--]]
function GameUIView:onBtnClicked(event, tag, obj)
    -- if self.finishXia then
    --     return
    -- end
    if event == ccui.TouchEventType.ended then
        print("GameUIView:onBtnClicked....")
        CommonSound.playSound("anniu")
        -- 隐藏跑模块
        obj:getParent():setVisible(false)
        -- 通过标志算出类型和加注倍数
        local actType = math.modf(tag / kMulti)
        local fillingNum = tag % kMulti
        WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_mjAction, actType, 1, fillingNum)
    end 
end

--[[
-- @brief  重设文字显示函数
-- @param  void
-- @return void
--]]
function GameUIView:resetWord() 
    -- 获取自己座位需要显示的列表
    local showFillingList = MjProxy:getInstance():getShowFillingListBySite(1)
    local count = 1
    for k, v in pairs(showFillingList) do
        self.actionPanel[count]:setVisible(true) 
        -- 重置文字重绑定按钮
        for t=1,3 do
            local wordStr = kWidgets.tagSeleWord..t
            local btn_word = self:getWidget(self.actionPanel[count], wordStr)
            btn_word:loadTexture(kWordPng[k][t], ccui.TextureResType.localType)
            local selected = self:getWidget(self.actionPanel[count], kWidgets.tagSelectedBtn..t)
            cc(selected):addComponent("app.hall.common.ButtonAction"):exportMethods()
            selected:onClicked(handler(self, GameUIView.onBtnClicked))
            local tag = k * kMulti + t-1 
            selected:setButtonTag(tag)
        end
        count = count + 1
    end
end

function GameUIView:onTouchSayButton(pWidget, EventType)
    Log.i("------EventType", EventType);
    if EventType == ccui.TouchEventType.began then
        --开始录音
        if not self.m_isTouching then
            self.m_isTouchBegan = true;
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data); 
            self:showMic();
        end
    elseif EventType == ccui.TouchEventType.ended then
        --停止录音
        if self.m_isTouchBegan then
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 1;
            NativeCall.getInstance():callNative(data); 
            self:hideMic();
            
            -- self.m_delegate:getUploadStatus();
            if YY_IS_LOGIN then
                self.m_delegate:getUploadStatus();
            else
                Toast.getInstance():show("功能未初始化完成，请稍后");
            end
            self.m_isTouchBegan = false;
            self.m_isTouching = true;
            self.m_delegate:performWithDelay(function ()
                self.m_isTouching = false;
            end, 0.5);
        end
        
    elseif EventType == ccui.TouchEventType.canceled then
        --停止录音
        if  self.m_isTouchBegan then
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 0;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            self.m_isTouchBegan = false;
        end
    end
end

function GameUIView:showMic()
    audio.pauseMusic();
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameUIView:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("games/huaibeimj/game/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameUIView:hideMic()
    if not kSettingInfo:getGameVoiceStatus() then
        audio.resumeMusic();
    end
    self.img_mic:setVisible(false);
end
--[[
-- @brief  停止语音动作和延时
-- @param  void
-- @return void
--]]
function GameUIView:stopButtonAction()
    --防止没有收到播放结束回调
    self.Button_yuyin:stopAllActions();
    -- self.m_delegate:performWithDelay(function()
    --     self:hideSpeaking();
    -- end, 60);
end

--endregion
