--窗口管理器

UIManager = class("UIManager");

UIManager.getInstance = function()
    if not UIManager.s_instance then
        UIManager.s_instance = UIManager.new();
    end

    return UIManager.s_instance;
end

UIManager.releaseInstance = function()
    if UIManager.s_instance then
        UIManager.s_instance:dtor();
    end
    UIManager.s_instance = nil;
end

function UIManager:ctor()
    self.m_scene = nil;    -- 场景
    self.m_wndsInRoot = {};    -- 在场景的所有窗口
    self.m_screen_orient = 0;
end

function UIManager:dtor()

end

--场景
function UIManager:setCurScene(scene)
    self.m_scene = scene;
end

--场景
function UIManager:getCurScene()
    return self.m_scene;
end

--添加到场景显示
function UIManager:addToRoot(widget, zOrder)
    display.getRunningScene():addChild(widget, zOrder);
end

--从场景删除
function UIManager:removeToRoot(widget)
    display.getRunningScene():removeChild(widget, true);
    widget = nil;
end

--添加窗口到场景
function UIManager:pushWnd(wndClass, ...)
    Log.d("UIManager:pushWnd", wndClass.__cname);
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    m_wnd:show();
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:onShow();
    return m_wnd;
end

--添加窗口到场景
function UIManager:pushWndwithAnim(wndClass, AnimType, ...)
    Log.d("UIManager:pushWnd", wndClass.__cname);
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:show(AnimType);
    m_wnd:onShow();
    return m_wnd;
end

--替换窗口到场景
function UIManager:replaceWnd(wndClass, ...)
    Log.d("UIManager:replaceWnd", wndClass.__cname);
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:show();
    for i = #self.m_wndsInRoot - 1, 1, -1 do
        wndData = table.remove(self.m_wndsInRoot, i);
        if wndData and wndData.wnd then
            wndData.wnd:close(true);
            wndData.wnd = nil;
        end
        wndData = nil; 
    end
    m_wnd:onShow();
    return m_wnd;
end

--从场景中移除目标窗口上所有的窗口
function UIManager:popToWnd(wndClass)
    Log.d("UIManager:popToWnd", wndClass.__cname);
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        for i = 1 , #self.m_wndsInRoot do
            if self.m_wndsInRoot[i].key == wndClass.__cname then
                wndData = self.m_wndsInRoot[i];
                break;
            end
        end
        if wndData then
            while true do
                if self.m_wndsInRoot[#self.m_wndsInRoot].key ~= wndClass.__cname then
                    self:popWnd();
                else
                    break;
                end
            end
        end
    end
end

function UIManager:popAllWnd()
    Log.d("UIManager:popAllWnd");
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        for i = 1 , #self.m_wndsInRoot do
            self:popWnd();
        end
    end
end

--如果存在指定窗口，返回指定窗口
function UIManager:getWnd(wndClass)
    Log.i("从场景中查找目标窗口", "------wndClass = "..wndClass.__cname);
    if #self.m_wndsInRoot > 0 then
        for i = 1 , #self.m_wndsInRoot do
            if self.m_wndsInRoot[i].key == wndClass.__cname then
                return self.m_wndsInRoot[i].wnd;
            end
        end
    end
	return nil
end

--返回最上层窗口
function UIManager:getSecondTopWnd()
    Log.d("------getTopWnd #self.m_wndsInRoot", #self.m_wndsInRoot);
    if #self.m_wndsInRoot > 0 then
        Log.d("------getTopWnd #self.m_wndsInRoot", self.m_wndsInRoot[#self.m_wndsInRoot - 1].key);
        return self.m_wndsInRoot[#self.m_wndsInRoot - 1].wnd;    
    end
end

--返回最上层窗口
function UIManager:getTopWnd()
    if #self.m_wndsInRoot > 0 then
        return self.m_wndsInRoot[#self.m_wndsInRoot].wnd;    
    end
end


--从场景中移除窗口
function UIManager:popWnd(wndClass)
    
    Log.d("UIManager:popWnd", wndClass and wndClass.__cname);
    
    
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        if wndClass then
            for i = #self.m_wndsInRoot, 1, -1 do
                if self.m_wndsInRoot[i].key == wndClass.__cname then
                    wndData = table.remove(self.m_wndsInRoot, i);
                    break;
                end
            end
        else
            wndData = table.remove(self.m_wndsInRoot);
        end
        if wndData and wndData.wnd then
            wndData.wnd:close();
            wndData.wnd = nil;
        end
        if self.m_wndsInRoot[#self.m_wndsInRoot] and self.m_wndsInRoot[#self.m_wndsInRoot].wnd then
            self.m_wndsInRoot[#self.m_wndsInRoot].wnd:onResume();
        end
    end
end

--安卓返回键分发
function UIManager:disPatchKeyBackEvent()
    if LoadingView.getInstance():getVisible() then
        return;
    end
    if #self.m_wndsInRoot > 0 then
        self.m_wndsInRoot[#self.m_wndsInRoot].wnd:onKeyBack();
    end
end

--网络获取图片返回
function UIManager:onResponseNetImg(url)
    printLog("onResponseNetImg", "---------url = "..url);
    if #self.m_wndsInRoot > 0 then
        for i = 1 , #self.m_wndsInRoot do
            local wndData = self.m_wndsInRoot[i];
            if wndData and wndData.wnd then
                wndData.wnd:onResponseNetImg(url);
            end
        end
    end
end

--网络获取回放数据返回
function UIManager:onResponseNetJson(url)
    printLog("onResponseNetJson", "---------url = "..url);
    if #self.m_wndsInRoot > 0 then
        -- for i = 1 , #self.m_wndsInRoot do
        --     local wndData = self.m_wndsInRoot[i]
        --     if wndData and wndData.wnd then
        --         dump(wndData.wnd)
        --         wndData.wnd:onResponseNetJson(url)
        --     end
        -- end
        -- 找到当前界面
        local wndData = self.m_wndsInRoot[#self.m_wndsInRoot]
        if wndData and wndData.wnd then
            wndData.wnd:onResponseNetJson(url)
        end
    end
end

--切换到横屏
function UIManager:changeToLandscape()
    if self.m_screen_orient == 1 then
        return;
    end
    -- design resolution
    CONFIG_SCREEN_WIDTH  = 1280;
    CONFIG_SCREEN_HEIGHT = 720;
    -- auto scale mode
    local width = display.width
    local height = display.height
    if width > height then
        if width/height >= 1.9 then
            CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
        else
            CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT";
        end
    else
        if height/width >= 1.9 then
            CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
        else
            CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH";
        end
    end

    if device.platform == "android" or device.platform == "ios" then
        local data = {};
        data.cmd = NativeCall.CMD_CHANGE_ORIENTAION;
        data.orient = 1;
        NativeCall.getInstance():callNative(data);
    end
    self:refreshScreenConfig();
    self.m_screen_orient = 1;
end

--切换到竖屏
function UIManager:changeToPortrait()
    if self.m_screen_orient == 2 then
        return;
    end
    -- design resolution
    CONFIG_SCREEN_WIDTH  = 720;
    CONFIG_SCREEN_HEIGHT = 1280;
    -- auto scale mode
    local width = display.width
    local height = display.height
    if width > height then
        if width/height >= 1.9 then
            CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
        else
            CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT";
        end
    else
        if height/width >= 1.9 then
            CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
        else
            CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH";
        end
    end

    if device.platform == "android" or device.platform == "ios" then
        local data = {};
        data.cmd = NativeCall.CMD_CHANGE_ORIENTAION;
        data.orient = 2;
        NativeCall.getInstance():callNative(data);
    end
    --
    self:refreshScreenConfig();

    self.m_screen_orient = 2;

end

--切换到竖屏
function UIManager:setScreenOrient(orient)
    self.m_screen_orient = orient;
end
function UIManager:getScreenOrient()
    return self.m_screen_orient or 2
end
--刷新配置
function UIManager:refreshScreenConfig()
    local glview = cc.Director:getInstance():getOpenGLView()
    if nil == glview then
       return;
    end
    
    local size = glview:getFrameSize();
    glview:setFrameSize(size.height, size.width);
    local size = glview:getFrameSize()
    display.sizeInPixels = {width = size.width, height = size.height}

    local w = display.sizeInPixels.width
    local h = display.sizeInPixels.height

    if CONFIG_SCREEN_WIDTH == nil or CONFIG_SCREEN_HEIGHT == nil then
        CONFIG_SCREEN_WIDTH = w
        CONFIG_SCREEN_HEIGHT = h
    end

    if not CONFIG_SCREEN_AUTOSCALE then
        if w > h then
            CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
        else
            CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
        end
    else
        CONFIG_SCREEN_AUTOSCALE = string.upper(CONFIG_SCREEN_AUTOSCALE)
    end

    local scale, scaleX, scaleY

    if CONFIG_SCREEN_AUTOSCALE and CONFIG_SCREEN_AUTOSCALE ~="NONE" then
        if type(CONFIG_SCREEN_AUTOSCALE_CALLBACK) == "function" then
            scaleX, scaleY = CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h, device.model)
        end

        if CONFIG_SCREEN_AUTOSCALE == "EXACT_FIT" then
            scale = 1.0
            glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.EXACT_FIT)
        elseif CONFIG_SCREEN_AUTOSCALE == "FILL_ALL" then
            CONFIG_SCREEN_WIDTH = w
            CONFIG_SCREEN_HEIGHT = h
            scale = 1.0
            if cc.bPlugin_ then
                glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)
            else
                glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
            end
        else
            if not scaleX or not scaleY then
                scaleX, scaleY = w / CONFIG_SCREEN_WIDTH, h / CONFIG_SCREEN_HEIGHT
            end

            if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
                scale = scaleX
                CONFIG_SCREEN_HEIGHT = h / scale
            elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
                scale = scaleY
                CONFIG_SCREEN_WIDTH = w / scale
            else
                scale = 1.0
                printError(string.format("display - invalid CONFIG_SCREEN_AUTOSCALE \"%s\"", CONFIG_SCREEN_AUTOSCALE))
            end
            glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
        end
    else
        CONFIG_SCREEN_WIDTH = w
        CONFIG_SCREEN_HEIGHT = h
        scale = 1.0
    end

    local winSize = cc.Director:getInstance():getWinSize()
    display.screenScale        = 2.0
    display.contentScaleFactor = scale
    display.size               = {width = winSize.width, height = winSize.height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.widthInPixels      = display.sizeInPixels.width
    display.heightInPixels     = display.sizeInPixels.height
end