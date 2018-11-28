-- 登录界面

HallLogin = class("HallLogin", UIWndBase);

function HallLogin:ctor(info)
    self.super.ctor(self, "hall/hallLogin.csb", info);
    SocketManager.getInstance():setUserDataProcesser(UserDataProcesser.new());
    self.m_socketProcesser = HallSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    --登陆之前先把数据清除
    self.m_socketProcesser:clearUserData()
    self.m_AutomaticLogin = false 
    SocketManager.getInstance().pause = false
end

function HallLogin:onShow()
    if device.platform == "android" or device.platform == "ios" then
        if _isChooseServerForTest then
            self.m_selSerWnd = UIManager:getInstance():pushWnd(SelectServerWnd)
            self.m_selSerWnd:setDelegate(self)
        else
            local lastAccount = kLoginInfo:getLastAccount();
            if not self.m_data.isExit then
                if lastAccount then
                    self.account = lastAccount.act;
                    self.pwd = lastAccount.pwd;
                    scheduler.performWithDelayGlobal(function()
                        self:login();
                    end,0.3)
                else
                    if IS_YINGYONGBAO then
                        --LoadingView.getInstance():show("正在检测版本更新，请稍后...", 120);
                    end
                end
            end 
        end
    else
       -- 以上代码为正常的自动登录流程, self:addTestLoginBtn()可以添加4个不同的帐号, 方便登录
       self:addTestLoginBtn();
    end
    if IS_YINGYONGBAO or (IS_IOS and not kLoginInfo:getIsReview()) then
        self.btn_login:loadTextureNormal("hall/loginUI/btn_login_visitor.png");
        self.isVisitor = true;
    else
        self.btn_login:loadTextureNormal("hall/loginUI/btn_login.png");
        self.isVisitor = false;
    end
    
end
-- 加入四个测试用的登录按钮
function HallLogin:addTestLoginBtn()
    self.testLoginBtns = {};
    self.testWXIDs = {};
    self.testNames = {};

    local i = 1;
    for i = 1, 4, 1 do
        local testLoginBtn = ccui.Button:create("hall/GUI/selected01.png")
        testLoginBtn:setPosition(cc.p(0 + (i - 1) % 2 * self.btn_login:getContentSize().width, 450 - math.floor((i - 1) / 2) * 200)) -- 按钮位置(相对于父节点)
        testLoginBtn:addTo(self.btn_login)
        testLoginBtn:addTouchEventListener(handler(self, self.onClickButton)); -- 按钮回调
        testLoginBtn:setTitleText("user" .. i) -- 设置按钮文字
        testLoginBtn:setTitleFontSize(18); -- 按钮文字的字体大小
        testLoginBtn:setColor(display.COLOR_GREEN)
        testLoginBtn:setScale(2.0)
        if GC_TestID ==nil then
            GC_TestID = "userid_39"
        end
        table.insert(self.testLoginBtns, testLoginBtn)
        table.insert(self.testWXIDs, GC_TestID .. i)
        table.insert(self.testNames, "user" .. i)
    end
end

--快速登录用于测试
function HallLogin:loginFastForTest(wxOpenId, wxName,sex)
    if sex == nil then
        sex = 0
    end
    WX_OPENID = wxOpenId; -- 登录的openID, 服务器以此为标记确定登录的帐号
    WX_NAME = wxName; -- 玩家昵称
    WX_SEX = sex;
    WX_PR = "广东";
    WX_CITY = "深圳";
    WX_CO = "中国";
    WX_HEAD = "";

    LoadingView.getInstance():show("正在连接服务器，请稍后...", 1000);
    kLoginInfo:getPhoneInfoAndLink();
end

-- 响应窗口回到最上层
function HallLogin:onResume()
end

function HallLogin:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function HallLogin:onInit()
    --
    self.btn_login = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_login");
    self.btn_login:addTouchEventListener(handler(self, self.onClickButton));
    --
    self.btn_login1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_login1");
    self.btn_login1:addTouchEventListener(handler(self, self.onClickButton));
    --
    self.btn_login_visitor = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_login_visitor");
    self.btn_login_visitor:addTouchEventListener(handler(self, self.onClickButton));
    --
    self.btn_login:setVisible(true);
    self.btn_login1:setVisible(false);
    self.btn_login_visitor:setVisible(false);
    --
    self.cb_agreement = ccui.Helper:seekWidgetByName(self.m_pWidget, "cb_agreement");
    self.cb_agreement:setSelected(true);

    self.btn_user = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_user");
    self.btn_user:addTouchEventListener(handler(self, self.onClickButton));

    local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");
    title:loadTexture(_gameTitlePath);
	--软件著作权
	local softTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "softTitle");
    softTitle:setString(_gameSoftTitle);
	
    self.pan_server = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_server");
    if DEBUG > 1 then
        self.pan_server:setVisible(true);
        self:showServerView();
    else
        self.pan_server:setVisible(false);
    end
end
function HallLogin:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then

        SoundManager.playEffect("btn", "hall");
        if pWidget == self.btn_login or pWidget == self.btn_login1 then
            if not self.cb_agreement:isSelected() then
                Toast.getInstance():show("请勾选用户协议");
                return;
            end
            if self.isVisitor then
                LoadingView.getInstance():show("正在连接服务器，请稍后...", 1000);
                self:setVistorAccount();
                kLoginInfo:getPhoneInfoAndLink();
            else
                self:login();
            end 
        elseif pWidget == self.btn_login_visitor then
            self.isVisitor = true;
            if not self.cb_agreement:isSelected() then
                Toast.getInstance():show("请勾选用户协议");
                return;
            end 
            self:setVistorAccount();
            kLoginInfo:getPhoneInfoAndLink();
            
        elseif pWidget == self.btn_user then 
            if device.platform == "android" or device.platform == "ios" then
                local data = {};
                data.cmd = NativeCall.CMD_USER_AGREEMENT;
                NativeCall.getInstance():callNative(data); 
            else
                Toast.getInstance():show("用户协议");
            end
        else
            -- 在此处理测试用按钮的登录流程
            local i = 1;
            for i = 1, #self.testLoginBtns do
                if pWidget == self.testLoginBtns[i] then
                    Log.i("click testLoginBtns ", i);
                    Log.i("openid", self.testWXIDs[i]);
                    Log.i("wx_name", self.testNames[i]);
                    WX_OPENID = self.testWXIDs[i]; -- 登录的openID, 服务器以此为标记确定登录的帐号
                    WX_NAME = self.testNames[i]; -- 玩家昵称
                    self.login();
                end
            end
        end;
    end 
end

function HallLogin:setVistorAccount()
    Log.i("------kLoginInfo:getVisitorAccount()", kLoginInfo:getVisitorAccount());
    if not kLoginInfo:getVisitorAccount() or kLoginInfo:getVisitorAccount() == "" then
        math.newrandomseed();
        WX_OPENID = "visitor" .. os.time() .. math.random(1000, 10000) .. math.random(1000, 10000) .. math.random(1000, 10000);
    else
       WX_OPENID = kLoginInfo:getVisitorAccount();
    end
    
    WX_NAME = device.model;
end

--登录
function HallLogin:login()
    LoadingView.getInstance():show("正在连接服务器，请稍后...", 1000);
    local FileLog = require("app.common.FileLog")
    FileLog.init(CACHEDIR)
    
    if device.platform == "ios" or device.platform == "android" then
--    if device.platform == "ios" then
        WX_OPENID = cc.UserDefault:getInstance():getStringForKey("openid");
        local access_token = cc.UserDefault:getInstance():getStringForKey("access_token");
        local refresh_token = cc.UserDefault:getInstance():getStringForKey("refresh_token");

        WX_NAME = cc.UserDefault:getInstance():getStringForKey("wx_name");
        WX_HEAD = cc.UserDefault:getInstance():getStringForKey("wx_head");
        WX_SEX = cc.UserDefault:getInstance():getStringForKey("wx_sex");
        WX_CO = cc.UserDefault:getInstance():getStringForKey("wx_co");
        WX_PR = cc.UserDefault:getInstance():getStringForKey("wx_pr");
        WX_CITY = cc.UserDefault:getInstance():getStringForKey("wx_city");

        if WX_NAME and WX_NAME ~= "" then
            kLoginInfo:getPhoneInfoAndLink();
            if refresh_token  and refresh_token ~= "" then
               
                local info = {};
                info.openid = openid;
                info.refresh_token = refresh_token;
                HttpManager.getWeChatRefresh_token1(info);
            end
        else
            scheduler.performWithDelayGlobal(function()
--                Toast.getInstance():show("获取信息.....")
                cc.UserDefault:getInstance():setStringForKey("updateHeadTime", os.time());
                local data = {};
                data.cmd = NativeCall.CMD_WECHAT_LOGIN;
                NativeCall.getInstance():callNative(data, LoginInfo.weChatLoginCallBack, kLoginInfo);
            end, 0.1);
        end
    else
--        self:setVistorAccount()
--        local updateHeadTime = cc.UserDefault:getInstance():getStringForKey("updateHeadTime");
--        if updateHeadTime~= "" and tonumber(os.time()) - tonumber(updateHeadTime) >= GAME_HEAD_UPDATE_TIME then
--            self.m_AutomaticLogin = true
--        else
--            self.m_AutomaticLogin = false
--        end
        LoadingView.getInstance():show("正在连接服务器，请稍后...", 1000);
        kLoginInfo:getPhoneInfoAndLink();
    end
end

function HallLogin:showServerView()
    self.cb_server1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "cb_server1");
    self.cb_server2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "cb_server2");
    Log.i("------server", cc.UserDefault:getInstance():getStringForKey("server"));
    if cc.UserDefault:getInstance():getStringForKey("server") == "2" then
        self.cb_server2:setSelected(true);
        self.cb_server1:setSelected(false);
        SERVER_IP = SERVER_IP_TEST;
    else
        self.cb_server1:setSelected(true);
        self.cb_server2:setSelected(false);
        SERVER_IP = SERVER_IP_DEV;
    end
    self.cb_server1:addEventListener(function(obj, event)
        Log.i("------event", event);
        if event == 0 then
            self.cb_server2:setSelected(false);
            cc.UserDefault:getInstance():setStringForKey("server", 1);
            kLoginInfo:clearAccountInfo();
            SERVER_IP = SERVER_IP_DEV;
        else
            self.cb_server1:setSelected(true);
        end
    end)
    self.cb_server2:addEventListener(function(obj, event)
        if event == 0 then
            self.cb_server1:setSelected(false);
            cc.UserDefault:getInstance():setStringForKey("server", 2);
            kLoginInfo:clearAccountInfo();
            SERVER_IP = SERVER_IP_TEST;
        else
            self.cb_server2:setSelected(true);
        end
    end) 
end

--返回
function HallLogin:keyBack()
    local data = {}
    data.type = 2;
    data.title = "提示";                        
    data.yesTitle  = "退出";
    data.cancelTitle = "取消";
    data.content = "确定要退出游戏吗？";
    data.yesCallback = function()
        MyAppInstance:exit();
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 网络连通
function HallLogin:onNetWorkConnected()
    Log.i("HallLogin:onNetWorkConnected()")

    kLoginInfo:requestLogin();
    LoadingView.getInstance():show("正在登录，请稍后...", 1000);

    local FileLog = require("app.common.FileLog")
    FileLog.uploadAllLog()
end

--登录返回
function HallLogin:onRepLogin(info)
   --##验证结果(0 - 验证失败  1 - 成功  2 服务器异常 4 版本已过期) su
    --## 结果描述 de
    --##当前版本号 ve
--    LoadingView.getInstance():hide();
    if info.su == 1 or info.su == 5 then
        if device.platform == "android" or device.platform == "ios" then
            --呀呀登录
            local data = {};
            data.cmd = NativeCall.CMD_YY_LOGIN;
            data.usI = info.usI .. "";
            data.niN = info.niN;
            NativeCall.getInstance():callNative(data);

            --umeng登录统计
            local data = {};
            data.cmd = NativeCall.CMD_UMENG_LOGIN_OFF;
            data.usI = info.usI .. "";
            data.type = 1;
            NativeCall.getInstance():callNative(data);  
        end

        if self.isVisitor then
            if info.pa then
                kLoginInfo:recordVisitorAccountInfo(info.ac);
            end
            --跳转大厅
            SocketManager.getInstance().pause = true
--            UIManager.getInstance():replaceWnd(HallMain);
            scheduler.performWithDelayGlobal(function ()
--                kUserInfo:setUpdateHeadInfo(self.m_AutomaticLogin)
                UIManager.getInstance():replaceWnd(HallMain);
            end, 0.1);
        else
            if info.pa then
                local account = {};
                account.act = info.ac;
                account.pwd = info.pa;
                kLoginInfo:recordAccountInfo(account);
            end
            --跳转大厅
            SocketManager.getInstance().pause = true
--            UIManager.getInstance():replaceWnd(HallMain);
            scheduler.performWithDelayGlobal(function ()
--                kUserInfo:setUpdateHeadInfo(self.m_AutomaticLogin)
                UIManager.getInstance():replaceWnd(HallMain);
            end, 0.1);
        end
        HttpManager.getPlayerLocalIP()
    elseif info.su == 4 then
        SocketManager.getInstance():closeSocket();

        --提示有更新
        -- local data = {}
        -- data.type = 1;
        -- data.title = "提示";
        -- data.content = info.de or "登录失败";
        -- data.contentType = COMNONDIALOG_TYPE_NETWORK;
        -- UIManager.getInstance():pushWnd(CommonDialog, data);

        --调用热更新
        local data = {};
        data.neVDRL = info.neVDRL;
        data.newVersion = info.ve;
        UIManager.getInstance():pushWnd(HallUpdate, data);
    else
        Toast.getInstance():show(info.de or "登录失败");
        SocketManager.getInstance():closeSocket();
    end
end

HallLogin.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_LOGIN] = HallLogin.onRepLogin;
};
