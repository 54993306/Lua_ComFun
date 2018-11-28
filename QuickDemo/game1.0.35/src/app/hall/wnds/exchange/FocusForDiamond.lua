----------------------------------
-- 关注送钻石对话框

FocusForDiamond = class("FocusForDiamond", UIWndBase)

-----------------
-- 构造函数
function FocusForDiamond:ctor(data)
    self.super.ctor(self, "hall/focusForDiamond.csb", data);
end

---------------
-- 重写初始化方法
function FocusForDiamond:onInit()
    Log.i("FocusForDiamond:onInit", self.m_data)
    -- 关闭按钮
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn")
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton))
    -- 关注送钻石的图片
    self.img_officalAccount = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_officalAccount")
    -- 复制公众号按钮
    self.btn_officalAccount = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_officalAccount")
    self.btn_officalAccount:addTouchEventListener(handler(self, self.onClickButton))
    if GC_OfficalAccountBtn then
        self.btn_officalAccount:loadTextureNormal(GC_OfficalAccountBtn)
    end
    -- 复制成功的提示
    self.img_copySuccess = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_copySuccess")
    -- 帮助按钮
    self.btn_getHelp = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_getHelp")
    -- 如果领取过, 则将"如何领取"的帮助按钮设为不可见
    if self.m_data.gotExchangeCode then
        self.btn_getHelp:setVisible(false)
        -- 左对齐，并且多行文字顶部对齐
        local label = display.newTTFLabel({
            text = "您已领取过礼包",
            font = "Arial",
            size = 36,
            color = cc.c3b(0, 103, 178),
        })
        label:setPosition(self.btn_getHelp:getPosition())
        label:addTo(self.btn_getHelp:getParent())
    else
        self.btn_getHelp:addTouchEventListener(handler(self, self.onClickButton))
    end
    -- 帮助图片
    self.img_exchangeHelp = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_exchangeHelp")
    if GC_OfficalAccountImg then
        self.img_exchangeHelp:loadTexture(GC_OfficalAccountImg)
    end
    self.img_copySuccess:setVisible(false)
end

---------------------------
-- 切换帮助显示
-- @bool showHelp 显示帮助图片
function FocusForDiamond:switchState(showHelp)
    self.img_officalAccount:setVisible(not showHelp)
    self.img_exchangeHelp:setVisible(showHelp)
end

---------------------------
-- 点击按钮的回调
function FocusForDiamond:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall")
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_officalAccount then
            Log.i("btn_officalAccount")
            if device.platform == "ios" or device.platform == "windows" then
                Toast.getInstance():show("请在微信搜索微信号：lailaibengbu")
                return
            end
            local data = {}
            data.cmd = NativeCall.CMD_CLIPBOARD_COPY
            -- 暂时写在config中
            data.content = GC_OfficalAccount or "xuzhoumajiang66"
            -- data.content = WX_OPENID
            Log.i("copy content:" .. data.content)
            NativeCall.getInstance():callNative(data)
            -- 提示复制成功
            local sequence = transition.sequence({
                cc.Show:create(),
                cc.FadeIn:create(0.5),
                cc.DelayTime:create(2),
                cc.FadeOut:create(0.5),
                cc.Hide:create()
            });
            self.img_copySuccess:stopAllActions()
            self.img_copySuccess:setOpacity(0)
            self.img_copySuccess:runAction(sequence)
        elseif pWidget == self.btn_getHelp then
            Log.i("btn_getHelp")
            self:switchState(true)
        end
    end
end

---------------------------
-- 重写关闭方法
function FocusForDiamond:keyBack()
    if self.img_exchangeHelp:isVisible() then
        self:switchState(false)
    else
        UIManager:getInstance():popWnd(FocusForDiamond)
    end
end
