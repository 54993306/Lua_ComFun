----------------------------------
-- 兑换码对话框

ExchangeDialog = class("ExchangeDialog", UIWndBase)

-----------------
-- 构造函数
function ExchangeDialog:ctor()
    self.super.ctor(self, "hall/exchangeDialog.csb");
end

---------------
-- 重写初始化方法
function ExchangeDialog:onInit()
    -- 关闭按钮
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close")
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton))
    -- 兑换按钮
    self.btn_exchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange")
    self.btn_exchange:addTouchEventListener(handler(self, self.onClickButton))
    -- 描述文字
    self.lb_des = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_des")

    self:addPasteInput()

    -- self.TextField_16 = self:getWidget(self.m_pWidget, "TextField_16")
end

---------------------------
-- 替换输入框
function ExchangeDialog:addPasteInput()
    self.pasteInput = self:getWidget(self.m_pWidget, "input_box")
    if not self.pasteInput then
        Log.i("替换输入框失败!!!!!")
        return
    end
    self.pasteInputSize = self.pasteInput:getContentSize()
    self:resetInputPos()
    local function onEdit(event, editbox)
        if event == "return" then
            -- 从输入框返回
            Log.i("从输入框返回")
            local text = editbox:getText()
            -- 输入的字符不同时, 隐藏之前的提示
            if self.lb_des and text ~= self.text then
                self.lb_des:setVisible(false)
            end
            self:resetInputPos()        
        end
    end
    -- 绑定事件回调
    self.pasteInput:registerScriptEditBoxHandler(onEdit)
    self.pasteInput:setPlaceholderFontColor(cc.c3b(211, 209, 199))
    self.pasteInput:setFontColor(cc.c3b(255, 255, 255))
end

-----------------------------
-- 重设输入框的文字位置
function ExchangeDialog:resetInputPos()
    -- 重置位置
    local children = self.pasteInput:getChildren()
    for i = 1, #children do
        children[i]:setAnchorPoint(cc.p(0.5, 0.5))
        children[i]:setPosition(cc.p(self.pasteInputSize.width/2, self.pasteInputSize.height/2))
    end
end

---------------------------
-- 手动添加输入框
function ExchangeDialog:addInputBox()
    local img_inputBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_inputBg")
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            Log.i("ExchangeDialog began。。。。。。。")
        elseif event == "changed" then
            Log.i("changed。。。。。。。")
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            Log.i("ExchangeDialog ended。。。。。。。")
        elseif event == "return" and self.lb_des and editbox:getText() ~= self.text then
            -- 从输入框返回
            Log.i("从输入框返回")
            self.lb_des:setVisible(false)
        end
    end
    self.pasteInput = cc.ui.UIInput.new({
        image = "hall/friendRoom/input_bg.png",
        -- listener = onEdit,
        size = img_inputBg:getContentSize(),
        x = 100,
        y = 30,
    })
    self.pasteInput:registerScriptEditBoxHandler(onEdit)
    self.pasteInput:setPlaceHolder("请输入兑换码")
    self.pasteInput:setFontName("Helvetica")
    self.pasteInput:setFontSize(48)
    self.pasteInput:setPlaceholderFontName("Helvetica")
    self.pasteInput:setPlaceholderFontSize(48)
    self.pasteInput:setPlaceholderFontColor(cc.c3b(211, 209, 199))
    self.pasteInput:setMaxLength(16)
    -- ANY 用户可输入任何文本，包括换行 
    -- EMAIL_ADDRESS 用户可输入一个电子邮件地址 
    -- NUMERIC 用户可输入一个整数 
    -- PHONE_NUMBER 用户可输入一个电话号码 
    -- URL 用户可输入一个URL 
    -- DECIMAL 用户可输入一个实数 跟NUMERIC相比，此模式可以多出一个小数点 
    -- SINGLE_LINE 用户可输入除换行符外的任何文本 
    self.pasteInput:setInputMode(6)
    -- 由于使用了相对布局, 在这里也需要先复制布局参数
    self.pasteInput:setLayoutParameter(img_inputBg:getLayoutParameter())
    self.pasteInput:setPosition(cc.p(img_inputBg:getPosition()))
    self.pasteInput:addTo(img_inputBg:getParent())
    img_inputBg:removeFromParent()
end

---------------------------
-- 点击按钮的回调
function ExchangeDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_exchange then
            Log.i("btn_exchange")
            if self.pasteInput then
                local text = self.pasteInput:getText()
                if not text or string.len(text) < 1 then
                    Toast.getInstance():show("兑换码不能为空")
                    return
                -- elseif text == self.text then
                --     Toast.getInstance():show("请不要输入相同的兑换码")
                --     return
                end
                self.text = text
                Log.i("input code", self.text)
                LoadingView.getInstance():show("正在兑换, 请稍候...", 5);
                local data = {};
                -- ex 兑换码
                -- gaI 游戏Id
                -- apI 微信appId
                data.ex = self.text;
                data.gaI = CONFIG_GAEMID
                data.unI = cc.UserDefault:getInstance():getStringForKey("union_id", "")
                data.apI = WX_APP_ID
                -- data.apI = WX_OPENID
                self.m_socketProcesser = ExchangeSocketProcesser.new(self)
                SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_EXCHANGE_CODE, data);
            end
        end
    end
end

---------------------------
-- 兑换结果
function ExchangeDialog:exchangeResult(result)
    Log.i("exchangeResult", result);
    LoadingView.getInstance():hide();
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
    -- re  int  兑换结果(0:操作成功，获得奖励  1:已经领取过奖励  2:无效激活码 3:未领取兑换码 4:兑换码已过期)
    if(result.re == 0) then --成功
        Toast.getInstance():show("兑换成功")
        -- 显示钻石动画
        CommonAnimManager.getInstance():showMoneyWinAnim(100)
        -- 关闭窗口
        self:keyBack()
    elseif result.er and self.lb_des then
        -- er  String  错误描述
        Toast.getInstance():show(result.er)
        self.lb_des:setString(result.er)
        self.lb_des:setVisible(true)
    end
end

---------------------------
-- 重写关闭方法
function ExchangeDialog:keyBack()
    Log.i("self.s_socketCmdFuncMap[cmd]", self.s_socketCmdFuncMap)
    UIManager:getInstance():popWnd(ExchangeDialog)
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end

---------------------------
-- 兑换结果通知
ExchangeDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_EXCHANGE_CODE]      = ExchangeDialog.exchangeResult;
};
