--登录信息

LoginInfo = class("LoginInfo");

LoginInfo.getInstance = function()
    if not LoginInfo.s_instance then
        LoginInfo.s_instance = LoginInfo.new();
    end

    return LoginInfo.s_instance;
end

LoginInfo.releaseInstance = function()
    if LoginInfo.s_instance then
        LoginInfo.s_instance:dtor();
    end
    LoginInfo.s_instance = nil;
end

LoginInfo.cleanup = function()
    LoginInfo.releaseInstance();
end

LoginInfo.ctor = function(self)
    self.m_LoginInfo = {};
end 

LoginInfo.dtor = function(self)
    self.m_LoginInfo = {};
end 

--获取手机信息后连接服务器
LoginInfo.getPhoneInfoAndLink = function(self)
    local data = {};
    data.cmd = NativeCall.CMD_GET_PHONEINFO;
    NativeCall.getInstance():callNative(data, LoginInfo.getPhoneInfoCallBack, self);
end

function LoginInfo:getPhoneInfoCallBack(phoneInfo)
    Log.i("getPhoneInfoCallBack phoneInfo", phoneInfo);
    if phoneInfo then
        IMEI = phoneInfo.imei or IMEI;
        MODEL = phoneInfo.model or MODEL;
        REGION = phoneInfo.pu or REGION;
        SPID = phoneInfo.spid or SPID;
        VERSION = phoneInfo.version or VERSION;
        NETMODE = phoneInfo.netmode or NETMODE;
        JINDU = phoneInfo.longitude
        WEIDU = phoneInfo.latitude
        ENTERROOMCODE = phoneInfo.enterCode;
        if kLoginInfo:checkNetWork(NETMODE) then
            SocketManager.getInstance():openSocket();
        end
    end
end

function LoginInfo:weChatLoginCallBack(info)
    Log.i("weChatLoginCallBack info", info);
    if info.errCode == 0 then
        HttpManager.getWeChatAccess_token(info);
        LoadingView.getInstance():show("正在登录，请稍后...");
    elseif info.errCode == -8 then
        LoadingView.getInstance():hide();
        Toast.getInstance():show("您未安装微信,请安装微信后重试");
    else
        LoadingView.getInstance():hide();
    end 
end

LoginInfo.requestLogin = function (self)
    -- ##  ac  String  账号名,即微信的openid
    --     ##  niN  String  昵称
    --     ##  se  int  性别
    --     ##  pr  String  省份
    --     ##  ci  String  城市
    --     ##  co  String  国家
    --     ##  he  String  头像
    --     ##  pa  String  密码
    --     ##  sp  int  渠道号
    --     ##  ve  String  版本号
    --     ##  neF  int  网络标识（1 wifi 2 mobile）
    --     ##  ip  String  ip address
    --     ##  os  int  设备os
    local data = {};
    if  device.platform == "windows" then
        OS = 1;
    elseif device.platform == "mac" then
        OS = 2;
    elseif device.platform == "android" then
        OS = 1;
    elseif device.platform == "ios" then
        OS = 2;
    end
    if JINDU == nil or JINDU == "" then
        JINDU = 0
    end
    if WEIDU == nil or WEIDU == "" then
        WEIDU = 0
    end 
    data.os = tostring(OS);
    data.sp = tostring(SPID);
    data.ve = tostring(VERSION);
    data.neF = tostring(NETMODE);
    --
    data.ac = tostring(WX_OPENID);
    data.niN = tostring(WX_NAME);
    data.se = tostring(WX_SEX);
    data.wxP = tostring(WX_PR);
    data.wxC = tostring(WX_CITY);
    data.wxC0 = tostring(WX_CO);
    data.he = tostring(WX_HEAD);
    data.gaI = tostring(CONFIG_GAEMID);
    data.apI = tostring(WX_APP_ID);
    data.lo = tonumber(JINDU)
    data.la = tonumber(WEIDU)
    data.unI = cc.UserDefault:getInstance():getStringForKey("union_id", "")
    --开启链接之前先清空玩家数据
    if UIManager.getInstance():getWnd(HallMain) or UIManager.getInstance():getWnd(HallLogin) then
        kUserData_userInfo:release();
        kUserData_userExtInfo:release();
        kUserData_userPointInfo:release();
        kGiftData_logicInfo:release();
        kUserInfo:setUserId(0)
    end
    SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOGIN, data);
end

--网络检测
LoginInfo.checkNetWork = function (self, netMode)
    Log.i("------checkNetWork netMode", netMode);
    if netMode > 0 then
        return true;
    end
    scheduler.performWithDelayGlobal(function()
        local data = {};
        data.type = 2;
        data.title = "提示";
        data.yesTitle = "退出游戏";
        data.cancelTitle = "关闭";
        data.content = "网络未连接，请检查您的网络是否正常再进入游戏";
        data.yesCallback = function ()
            MyAppInstance:exit();
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
        LoadingView.getInstance():hide();
    end, 0.01);
end

--记录账号密码
LoginInfo.recordAccountInfo = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        for k, v in pairs(accountInfo) do
            if v.act == account.act and v.pwd == account.pwd then
                return;
            end
        end
    end
    table.insert(accountInfo, 1, account);
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
end

--记录游客账号密码
LoginInfo.recordVisitorAccountInfo = function(self, account)
    cc.UserDefault:getInstance():setStringForKey("visitor_account", account);
end

LoginInfo.getVisitorAccount = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("visitor_account");
    return accountInfoStr;
end

--是否过审
LoginInfo.getIsReview = function(self, account)
    local isReview = cc.UserDefault:getInstance():getBoolForKey("reveiw_version", false);
    return isReview;
end

LoginInfo.setIsReview = function (self)
    cc.UserDefault:getInstance():setBoolForKey("reveiw_version", true);
end

--是否新手
LoginInfo.getIsNewer = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("cf_isNewer", true);
end

LoginInfo.setIsNewer = function (self, isNewer)
    cc.UserDefault:getInstance():setBoolForKey("cf_isNewer", isNewer);
end

--记录账号密码并清除老账号
LoginInfo.recordAccountInfoAndClearOld = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        table.remove(accountInfo, 1);
        for k, v in pairs(accountInfo) do
            if v.act == account.act and v.pwd == account.pwd then
                return;
            end
        end
    end
    table.insert(accountInfo, 1, account);
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
end

--修改账号密码
LoginInfo.changeAccountPwd = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        for k, v in pairs(accountInfo) do
            if v.act == account.act then
                v.pwd = account.pwd;
                break;
            end
        end
    end
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
end

LoginInfo.delAccountInfo = function(self, index)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        local data = table.remove(accountInfo, index);
        if data and data.status and data.status == 0 then
            local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime") or 0;
            vTime = vTime - 1;
            cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", vTime);
        end
        local accountInfoStr = json.encode(accountInfo);
        cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    end
end  

LoginInfo.changeAccountInfo = function(self, index)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        local firstInfo = accountInfo[1];
        accountInfo[1] = accountInfo[index];
        accountInfo[index] = firstInfo;
        local accountInfoStr = json.encode(accountInfo);
        cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    end
end  

LoginInfo.getLastAccount = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr then
        accountInfo = json.decode(accountInfoStr);
        if accountInfo and accountInfo[1] then
            return accountInfo[1];
        end
    end
end

LoginInfo.getAccountRecord = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= ""then
        local accountInfo = json.decode(accountInfoStr);
        return accountInfo;
    end
end

LoginInfo.clearAccountInfo = function(self)
    local accountInfo = {};
    local accountInfoStr = json.encode(accountInfo);
    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", 0);
    cc.UserDefault:getInstance():setIntegerForKey("VisitorActiveTime", 0);
end  

LoginInfo.recordVisitorRegister = function (self)
    local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime", 0);
    vTime = vTime + 1;
    cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", vTime);
end

LoginInfo.getVisitorRegisterTime = function (self)
    return cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime") or 0;
end

LoginInfo.recordVisitorActive = function (self)
    local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorActiveTime") or 0;
    vTime = vTime + 1;
    cc.UserDefault:getInstance():setIntegerForKey("VisitorActiveTime", vTime);
end

LoginInfo.getVisitorActiveTime = function (self)
    return cc.UserDefault:getInstance():getIntegerForKey("VisitorActiveTime", 0);
end

kLoginInfo = LoginInfo.getInstance();