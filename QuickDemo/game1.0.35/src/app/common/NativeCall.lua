--本地调用

NativeCall = class("NativeCall");

--获取手机信息
NativeCall.CMD_GET_PHONEINFO = 1001;
--切换屏幕
NativeCall.CMD_CHANGE_ORIENTAION = 1002;
--上传头像
NativeCall.CMD_CHANGE_HEADIMG = 1003;
--创建缓存路径
NativeCall.CMD_GETCACHE = 1004;
--获取电量信息
NativeCall.CMD_GETBATTERY = 1005;
--震动
NativeCall.CMD_SHAKE = 1006;
--微信分享
NativeCall.CMD_WECHAT_SHARE = 1007;
--用户协议
NativeCall.CMD_USER_AGREEMENT = 1008;
--复制到剪切板
NativeCall.CMD_CLIPBOARD_COPY = 1009;
--充值
NativeCall.CMD_CHARGE = 1010;
--获取当前屏幕是否为竖屏
NativeCall.CMD_IS_PORTRAIT =1011;
--微信登录
NativeCall.CMD_WECHAT_LOGIN = 1012;
--微信分享截屏
NativeCall.CMD_WECHAT_SHARE_SCREEN = 1013;
--信号强度
NativeCall.CMD_WECHAT_SIGNAL = 1014;
--呀呀登录
NativeCall.CMD_YY_LOGIN = 1015;
--开始录音
NativeCall.CMD_YY_START = 1016;
--停止录音
NativeCall.CMD_YY_STOP = 1017;
--播放录音
NativeCall.CMD_YY_PLAY = 1018;
--上传录音
NativeCall.CMD_YY_UPLOAD_SUCCESS = 1019;
--获取经纬度
NativeCall.CMD_LOCATION = 1020;
--关闭EditBox
NativeCall.CMD_CLOSEEDITBOX = 1021;
--获取链接传递的房间号
NativeCall.CMD_GET_ENTERCODE = 1022;
--播放录音结束
NativeCall.CMD_YY_PLAY_FINISH = 1023;
--版本更新
NativeCall.CMD_UPDATE_VERSION = 1024;
--umeng统计(type：1登录，2退出，3事件统计)
NativeCall.CMD_UMENG_LOGIN_OFF = 1025;
--打开一个url
NativeCall.CMD_OPEN_URL = 1026;

--分享图片
NativeCall.CMD_SHARE_PICTURE = 1031;

--检查文件是否存在
NativeCall.CMD_CHECKFILEEXIST = 1050   
-- 微信系统分享
NativeCall.CMD_WECHAT_SHARE_SYSTEM = 1051

NativeCall.getInstance = function()
    if not NativeCall.s_instance then
        NativeCall.s_instance = NativeCall.new();
    end

    return NativeCall.s_instance;
end

function NativeCall:ctor()
    self.m_callbacks = {};
end

function NativeCall:callNative(data, callback, obj)
    data = checktable(data);
    if callback then
        local func_obj = {};
        func_obj.func = callback;
        func_obj.obj = obj;
        self.m_callbacks[data.cmd] = func_obj;
    end
    
    if device.platform == "android" then
        -- Java 类的名称
        local className = "org/cocos2dx/lua/AppActivity";
        -- 调用 Java 方法需要的参数
        local dataString = json.encode(data);
        local args = {dataString};

        if data.cmd == NativeCall.CMD_YY_LOGIN then
            table.insert(args, NativeCallyyLogin);
            -- 调用 Java 方法
            luaj.callStaticMethod(className, "luaCall", args);
            return;
        end

        if callback then
            table.insert(args, NativeCallLua);
            -- 调用 Java 方法
            luaj.callStaticMethod(className, "luaCall", args);
        else
            luaj.callStaticMethod(className, "luaCall1", args);
        end

    elseif device.platform == "windows" or device.platform == "mac" then
        if callback then
            self:windowsCallLua(data, callback, obj);
        end
    elseif device.platform == "ios" then
        if data.cmd == NativeCall.CMD_GET_PHONEINFO then
            if callback then
--                self:windowsCallLua(data, callback, obj);
                scheduler.performWithDelayGlobal(function()
                    data.callback = NativeCallLua
                    luaoc.callStaticMethod("RootViewController", "getLocation", data);  
                end, 0.5);
            end
        elseif data.cmd == NativeCall.CMD_CHANGE_ORIENTAION then
            if data.orient == 1 then
                local data1 = {};
                data1.orient = 1;
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerV", data1);
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerH", data);
                
            elseif data.orient == 2 then
                local data1 = {};
                data1.orient = 2;
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerH", data1);
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerV", data);
            end
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShard", data);
        elseif data.cmd == NativeCall.CMD_CHANGE_HEADIMG then
            Log.i("开始选择图片......")
            luaoc.callStaticMethod("SendMsgWXRequest", "sendPictureView", data);
        elseif data.cmd == NativeCall.CMD_CHARGE then
            data.callback = NativeCallLua;
            luaoc.callStaticMethod("SendMsgWXRequest", "recharge", data);
        elseif data.cmd == NativeCall.CMD_USER_AGREEMENT then
            luaoc.callStaticMethod("AppController", "showUserAgreement", data);
        elseif data.cmd == NativeCall.CMD_GETBATTERY then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "deviceLevel", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SIGNAL then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "getNetWorkState", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_LOGIN then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXLogin", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE_SCREEN then
            data.callback = NativeCallLua
            data.path = CACHEDIR .. "screen.jpg";
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShareScreen", data);
        elseif data.cmd == NativeCall.CMD_LOCATION then
            data.callback = NativeCallLua
        elseif data.cmd == NativeCall.CMD_GET_ENTERCODE then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "getEnterCode", data);
        elseif data.cmd == NativeCall.CMD_YY_LOGIN then
            local func_obj = {};
            func_obj.func = NativeCallyyLogin;
            self.m_callbacks[NativeCall.CMD_YY_LOGIN] = func_obj;

            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "yayaLogin", data);
        elseif data.cmd == NativeCall.CMD_YY_START then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "yayaStart", data);
        elseif data.cmd == NativeCall.CMD_YY_STOP then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "yayaStop", data);
        elseif data.cmd == NativeCall.CMD_YY_PLAY then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "yayaPlay", data);
        elseif data.cmd == NativeCall.CMD_UPDATE_VERSION then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "download", data);
        elseif data.cmd == NativeCall.CMD_YY_UPLOAD_SUCCESS then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "getYYUploadStatus", data);
        elseif data.cmd == NativeCall.CMD_YY_PLAY_FINISH then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "getYYPlayStatus", data);
        elseif data.cmd == NativeCall.CMD_UMENG_LOGIN_OFF then
            data.callback = NativeCallLua;
            luaoc.callStaticMethod("AppController", "getUMData", data);
        elseif data.cmd == NativeCall.CMD_SHAKE then
            data.callback = NativeCall;
            luaoc.callStaticMethod("AppController","getShock",data);
        elseif data.cmd == NativeCall.CMD_CLIPBOARD_COPY then
            data.callback = NativeCall;
            luaoc.callStaticMethod("RootViewController","getCopy",data);
        elseif data.cmd == NativeCall.CMD_SHARE_PICTURE then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShareScreen", data);   
        elseif data.cmd == NativeCall.CMD_CHECKFILEEXIST then  --检查文件是否存在
            data.callback = NativeCallLua 
            luaoc.callStaticMethod("RootViewController","imageIsExists",data);
        elseif data.cmd == NativeCall.CMD_GETCACHE then  --返回路径
            data.callback = NativeCallLua 
            luaoc.callStaticMethod("RootViewController","getFilePath",data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE_SYSTEM then
            data.callback = NativeCall;
            luaoc.callStaticMethod("SendMsgWXRequest","iosShareWX",data);
        end

    end
end

function NativeCall:callLua(args)
    local data = {}
    if type(args) == "table" then
        data = args
    else
        data = json.decode(args);
    end
    local func_obj =  self.m_callbacks[data.cmd];
    if func_obj then
        --ios平台下的充值返回立刻调用，不走gl线程切换
        if args.cmd == NativeCall.CMD_CHARGE and device.platform == "ios" then
            if func_obj.obj then
                func_obj.func(func_obj.obj, data);
            else
                func_obj.func(data);
            end
        else
            scheduler.performWithDelayGlobal(function()
                if func_obj.obj then
                    func_obj.func(func_obj.obj, data);
                else
                    func_obj.func(data);
                end
                    
                --self.m_callbacks[data.cmd] = nil;
                --func_obj = nil;

            end, 0.1);
        end
    end
end

function NativeCall:windowsCallLua(data, callback, obj)
    --Log.i("------windowsCallLua", data);
    local args = {};
    if data.cmd == NativeCall.CMD_GET_PHONEINFO then
        
        args.cmd = NativeCall.CMD_GET_PHONEINFO;
        args.imei = IMEI;
        args.model = MODEL;
        args.pu = REGION;
        args.spid = SPID;
        args.version = VERSION;
        args.netmode = NETMODE;
        args.latitude = WEIDU
        args.longitude = JINDU
        args.packageName = "com.dashengzhangyou.pykf.huaibei"
        local argStr = json.encode(args);

        NativeCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_GETBATTERY then
        args.cmd = NativeCall.CMD_GETBATTERY;
        args.baPro = 80;
        local argStr = json.encode(args);

        NativeCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_WECHAT_SHARE then
        args.cmd = NativeCall.CMD_WECHAT_SHARE;
        args.errCode = 0;
        local argStr = json.encode(args);

        NativeCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_GETCACHE then
        args.cmd = NativeCall.CMD_GETCACHE
        args.path = WRITEABLEPATH .. "cache/"
        local argStr = json.encode(args);
        NativeCallLua(argStr)
    elseif data.cmd == NativeCall.CMD_CHECKFILEEXIST then
        args.cmd = NativeCall.CMD_CHECKFILEEXIST
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(data.filePath);
        -- print(headFile)
        args.ret = io.exists(headFile) and 1 or 0
        args.fileFullPath = headFile
        local argStr = json.encode(args);
        NativeCallLua(argStr)
    elseif data.cmd == NativeCall.CMD_IS_PORTRAIT then
    elseif data.cmd == NativeCall.CMD_WECHAT_SIGNAL then
        args.cmd = NativeCall.CMD_WECHAT_SIGNAL;
        args.rssi = 4
        args.type = "Wi-Fi"
        local argStr = json.encode(args);

        NativeCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_YY_UPLOAD_SUCCESS then
        args.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        args.fileUrl = "fileUrl"
        local argStr = json.encode(args);

        NativeCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_YY_PLAY_FINISH then
        args.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        args.usI = kUserInfo:getUserId();
        local argStr = json.encode(args);

        NativeCallLua(argStr);
     elseif data.cmd == NativeCall.CMD_OPEN_URL then
        Log.i("url:".. data.url);
        device.openURL(data.url);
        NativeCallLua(data.url);
    end
end

NativeCallLua = function(args)
    Log.i("------NativeCallLua", args);
    NativeCall.getInstance():callLua(args);
end

--lua 被调用
NativeCallyyLogin = function(args)
    Log.i("------NativeCallLuaPlayerFinish ");
    YY_IS_LOGIN = true;
end
