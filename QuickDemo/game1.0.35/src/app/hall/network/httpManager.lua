--http连接管理器

HttpManager = {}

--获取网络图片
HttpManager.getNetworkImage = function (url, fileName)
    Log.i("HttpManager.getNetworkImage", "-------url = " .. url);
   
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkImage", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetImg(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

--获取网络json文件
HttpManager.getNetworkJson = function (url, fileName)
    Log.i("HttpManager.getNetworkJson", "-------url = " .. url);
    local onReponseNetworkJson = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkJson code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkJson", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetJson(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkJson, url, "GET");
    request:start();
end

--获取微信access_token
HttpManager.getWeChatAccess_token = function (info)
    Log.i("HttpManager.getWeChatAccess_token");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatAccess_token code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatAccess_token", responseString);
        local info = json.decode(responseString);
        if info.errcode and info.errcode == 40029 then
            LoadingView.getInstance():hide();
            Toast.getInstance():show("微信登录失败，请重试");
            return;
        end
        if info.access_token then
            cc.UserDefault:getInstance():setStringForKey("access_token", info.access_token);
        end
        if info.openid then
            cc.UserDefault:getInstance():setStringForKey("openid", info.openid);
        end
        if info.refresh_token then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", info.refresh_token);
        end
        --
        HttpManager.getWeChatUserInfo(info);
    end
    local url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" .. info.appid .. "&secret=" .. info.secret .. "&code=" .. info.code .. "&grant_type=authorization_code";
    --Log.i("------getWeChatUserInfo url", url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

--刷新微信access_token
HttpManager.getWeChatRefresh_token = function (info)
    Log.i("------HttpManager.getWeChatRefresh_token");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatRefresh_token code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatRefresh_token", responseString);
        local info = json.decode(responseString);
        if info.errcode and info.errcode == 40030 then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
            LoadingView.getInstance():hide();
            Toast.getInstance():show("您的微信授权已过期，请重新登录");
            return;
        end
        if info.access_token then
            cc.UserDefault:getInstance():setStringForKey("access_token", info.access_token);
        end
        if info.openid then
            cc.UserDefault:getInstance():setStringForKey("openid", info.openid);
        end
        if info.refresh_token then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", info.refresh_token);
        end
        --
        HttpManager.getWeChatUserInfo(info);
    end
    local url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=".. WX_APP_ID .. "&grant_type=refresh_token&refresh_token=" .. info.refresh_token;
    Log.i("------getWeChatRefresh_token url", url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

HttpManager.getWeChatUserInfo = function (info)
    Log.i("------HttpManager.getWeChatUserInfo");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatUserInfo code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatUserInfo", responseString);
        local info = json.decode(responseString);
        WX_OPENID = info.openid;
        WX_NAME = info.nickname;
        WX_PR = info.province;
        WX_CITY = info.city;
        WX_CO = info.country;
        WX_HEAD = info.headimgurl;
        WX_SEX = info.sex;
        --
        cc.UserDefault:getInstance():setStringForKey("wx_name", WX_NAME);
        cc.UserDefault:getInstance():setStringForKey("wx_head", WX_HEAD);
        cc.UserDefault:getInstance():setStringForKey("wx_sex", WX_SEX);
        cc.UserDefault:getInstance():setStringForKey("wx_co", WX_CO);
        cc.UserDefault:getInstance():setStringForKey("wx_pr", WX_PR);
        cc.UserDefault:getInstance():setStringForKey("wx_city", WX_CITY);
        if info.unionid then
            cc.UserDefault:getInstance():setStringForKey("union_id", info.unionid)
        end
        --获取手机信息登录
        kLoginInfo:getPhoneInfoAndLink();
    end
    local url = "https://api.weixin.qq.com/sns/userinfo?access_token=" .. info.access_token .. "&openid=" .. info.openid;
    Log.i("------getWeChatUserInfo url", url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

--刷新微信access_token
HttpManager.getWeChatRefresh_token1 = function (info)
    Log.i("------HttpManager.getWeChatRefresh_token1");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatRefresh_token1 code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatRefresh_token1", responseString);
        local info = json.decode(responseString);
        if info.errcode and info.errcode == 40030 then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
            --LoadingView.getInstance():hide();
            --Toast.getInstance():show("您的微信授权已过期，请重新登录");
            return;
        end
        if info.access_token then
            cc.UserDefault:getInstance():setStringForKey("access_token", info.access_token);
        end
        if info.openid then
            cc.UserDefault:getInstance():setStringForKey("openid", info.openid);
        end
        if info.refresh_token then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", info.refresh_token);
        end
        --
        HttpManager.getWeChatUserInfo1(info);
    end
    local url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=".. WX_APP_ID .. "&grant_type=refresh_token&refresh_token=" .. info.refresh_token;
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

HttpManager.getWeChatUserInfo1 = function (info)
    Log.i("------HttpManager.getWeChatUserInfo1");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatUserInfo1 code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatUserInfo1", responseString);
        local info = json.decode(responseString);
        WX_OPENID = info.openid;
        WX_NAME = info.nickname;
        WX_PR = info.province;
        WX_CITY = info.city;
        WX_CO = info.country;
        WX_HEAD = info.headimgurl;
        WX_SEX = info.sex;
        --
        cc.UserDefault:getInstance():setStringForKey("wx_name", WX_NAME);
        cc.UserDefault:getInstance():setStringForKey("wx_head", WX_HEAD);
        cc.UserDefault:getInstance():setStringForKey("wx_sex", WX_SEX);
        cc.UserDefault:getInstance():setStringForKey("wx_co", WX_CO);
        cc.UserDefault:getInstance():setStringForKey("wx_pr", WX_PR);
        cc.UserDefault:getInstance():setStringForKey("wx_city", WX_CITY);
        if info.unionid then
            cc.UserDefault:getInstance():setStringForKey("union_id", info.unionid)
        end
    end
    local url = "https://api.weixin.qq.com/sns/userinfo?access_token=" .. info.access_token .. "&openid=" .. info.openid;
    Log.i("------getWeChatUserInfo1 url", url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

--获取网络json文件
HttpManager.getNetworkJson = function (url, fileName)
    Log.i("HttpManager.getNetworkJson", "-------url = " .. url);
    local onReponseNetworkJson = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkJson code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkJson", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetJson(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkJson, url, "GET");
    request:start();
end

---- 获取微信号轮换数据
HttpManager.getWechatIdData = function (url, wechatIdStrLb)
    Log.i("HttpManager.getWechatIdData", "-------url = " .. url);
    local onReponseWechatIdData = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWechatIdData code", code);
            return;
        end

        -- 请求成功，显示服务端返回的内容
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWechatIdData", responseString);
        
        --解析
        local tab = Util.stringSplit(responseString, "|");
        if not tab then return end
        local arr = {};
        for i=2, #tab do
            table.insert(arr, tab[i]);
        end


        local hallMain = UIManager.getInstance():getWnd(HallMain);
        -- wechatIdStrLb
        hallMain:exchangeWechatId(arr, tab[1], wechatIdStrLb);
    end
    --
    local request = network.createHTTPRequest(onReponseWechatIdData, url, "GET");
    request:start();
end

HttpManager.getPlayerLocalIP = function (  )
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束
            Log.i("------getPlayerLocalIP code", code);
            return;
        end
        ---本地外网ip信息
        local responseString = request:getResponseString();

        --解析
        local p1 = string.find(responseString, "{")
        if p1 == 0 or p1 == nil then return end
        local p2 = string.len(responseString)
        local e = string.byte("}")
        while p2 > 0 do
            local b = string.byte(responseString, p2)
            if b == e then -- 46 = char "."
                break
            end
            p2 = p2 - 1
        end
        if p2 == 0 then return end

        local str = string.sub(responseString, p1, p2)
        local tab = json.decode(str)
        dump(tab)
        if tab and tab["cip"] and tab["cip"] ~= "" then
            local data = {}
            data.ip = tab["cip"]--.."0001"
            --Log.i("============data.ip=======",data.ip)
            SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_IP, data)
            local HallMain = UIManager:getInstance():getWnd(HallMain)
            if HallMain then
                HallMain:setIP(tab["cip"])
            end
            PLAYER_IP = data.ip
            Log.d("HttpManager.getPlayerLocalIP decodeIp", PLAYER_IP)
        end
    end
    local url = "http://pv.sohu.com/cityjson"
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();    
end

--获取网络图片并回调
HttpManager.getNetworkImageWithUrl = function (url, fileNameFullPath, downFinishCB)
    Log.i("HttpManager.getNetworkImageWithUrl", "-------url = " .. url)
    if not url or string.len(url) < 4 then
        return
    end

    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = fileNameFullPath
        Log.i("HttpManager.getNetworkImageWithUrl", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        downFinishCB(savePath)
    end
    
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

-- 测试url的访问情况
HttpManager.testUrlConnect = function (url, callback, responseTime)
    Log.i("HttpManager.getNetworkImage", "-------url = " .. url);
    if not callback then return end
    local responseTimeOut = false -- 响应超时

    local onReponseNetwork = function (event)
        if responseTimeOut then return end
        if event == nil then
            return;
        end
        -- print(event.name)
        if event.name == "failed" then
            responseTimeOut = true
            callback(event, code)
        elseif event.name == "completed" then
            responseTimeOut = true
            local request = event.request
            local code = request:getResponseStatusCode()
            callback(event, code)
        end
    end
    --
    local request = network.createHTTPRequest(onReponseNetwork, url, "GET");
    request:start();

    scheduler.performWithDelayGlobal(function()
        if responseTimeOut then return end
        responseTimeOut = true
        callback({name = "timeout"})
        end, responseTime or 10)
end

--测试界面获取网络消息
HttpManager.getTestRUL = function (url, hookFun)
    Log.i("HttpManager.getTestRUL", "-------url = " .. url);
    local onReponseGetURL = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseUrl code", code);
            return;
        end
        Log.i("HttpManager.getTestRUL");

        local body=request:getResponseString()

        hookFun(body)
    end
    local request = network.createHTTPRequest(onReponseGetURL, url, "GET");
    request:start();
end

--获取网络内容
HttpManager.getURL = function (url, hookFun)
    Log.i("HttpManager.getURL", "-------url = " .. url);
    local onReponseGetURL = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseUrl code", code);
            return;
        end
        Log.i("HttpManager.getURL");

        local body=request:getResponseString()

        hookFun(body)

    end
    --
    local request = network.createHTTPRequest(onReponseGetURL, url, "GET");
    request:start();
end

