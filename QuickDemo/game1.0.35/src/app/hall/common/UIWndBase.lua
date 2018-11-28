--窗口基类
UIWndBase = class("UIWndBase")

-- 构造函数
function UIWndBase:ctor(uiConfig, data, zOrder, delegate)
	self.m_uiConfig = uiConfig 	or "";			-- UI配置文件	
	self.m_data = data or {};					-- 数据
    self.zOrder = zOrder or 0;                  -- 窗口层级
    self.m_delegate = delegate;                 -- 代理
	self.netImgsTable = {};                     -- 网络加载图片
end

function UIWndBase:setDelegate(delegate)
    self.m_delegate = delegate;
end

function UIWndBase:getWidget()
    return self.m_pWidget;
end

-- 响应窗口资源初始化 在执行load后会执行
function UIWndBase:onInit()end

-- 窗口隐藏
function UIWndBase:setVisible(visible)
	if self.m_pWidget then
		self.m_pWidget:setVisible(visible);
	end
end

-- 响应窗口显示
function UIWndBase:onShow()
end

-- 响应窗口回到最上层
function UIWndBase:onResume()
end

-- 窗口被关闭响应
function UIWndBase:onClose()
end

--返回网络图片
function UIWndBase:onResponseNetImg(fileName)
    if fileName == nil then
        return;
    end
    local imgViews = self.netImgsTable[fileName];
    if imgViews then 
    	for k, v in ipairs(imgViews) do
    		if v then
    			v:loadTexture(fileName);
    		end
    	end
        
    end
end

-- 加载UI资源
function UIWndBase:loadUIConfig()
	if self.m_pWidget ~= nil then
		return
	end

	-- 加载ui配置文件
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.m_uiConfig);
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
	if self.m_pWidget == nil then
		printError("加载"..self.m_uiConfig.."文件失败");
		return;
	end
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function UIWndBase:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
	if(widget == nil) then 
        return; 
    end
    local m_type = widget:getDescription();
    if m_type == "Label" then
        if args then
            if args.shadow == true then
                widget:enableShadow();
            elseif args.bold == true then
                widget:setFontName("hall/font/bold.ttf");
            end
        end
    end
    local tfName = widget:getName();
    if m_type == "TextField" then
        return self:setTextFieldToEditBox(widget);
    end
    return widget;
end
function UIWndBase:addWidgetClickFunc(widget, callfunc)
    if widget ~= nil and callfunc ~= nil then
        widget:addTouchEventListener(function(pWidget, EventType)
            if EventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end);
    end
end
function UIWndBase:setTextFieldToEditBox(textfield)
    
    local tfS = textfield:getContentSize()
    local parent = textfield:getParent()
    local tfPosX = textfield:getPositionX()
    local tfPosY = textfield:getPositionY()
    local tfPH = textfield:getPlaceHolder()
    local anchor = textfield:getAnchorPoint()
    local zorder = textfield:getLocalZOrder()
    local tfColor = textfield:getColor()
    local ispe = textfield:isPasswordEnabled()
    local tfFS = textfield:getFontSize()
    local ftMaxLength = 0
    if textfield:isMaxLengthEnabled() then
        ftMaxLength = textfield:getMaxLength()
    end
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            Log.i("began。。。。。。。")
        elseif event == "changed" then
            Log.i("changed。。。。。。。")
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            Log.i("ended。。。。。。。")
        elseif event == "return" then
            -- 从输入框返回
            Log.i("从输入框返回")
            local data = {};
            data.cmd = NativeCall.CMD_CLOSEEDITBOX;
            NativeCall.getInstance():callNative(data);
        end
    end
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "hall/Common/blank.png",
        listener = onEdit,
        size = tfS
    })
--    local imageNormal = display.newScale9Sprite("hall/Common/blank.png")

--    local editbox = ccui.EditBox:create(cc.size(tfS.width,tfS.height), imageNormal)
    editbox:setContentSize(tfS)
    editbox:setName(tfName)
    editbox:setPosition(cc.p(tfPosX,tfPosY))
    editbox:setPlaceHolder(tfPH)
    editbox:setFontName("hall/font/bold.ttf")
    editbox:setPlaceholderFontColor(cc.c3b(128,128,128)) 
    editbox:setAnchorPoint(cc.p(anchor.x,anchor.y))
    editbox:setLocalZOrder(zorder)
    editbox:setFontColor(tfColor)
    editbox:setFontSize(tfFS)

    if ftMaxLength ~= 0 then
        editbox:setMaxLength(ftMaxLength)
    end
    if ispe then
        editbox:setInputFlag(0)
    end
    parent:removeChild(textfield,true)
    parent:addChild(editbox)
    
    return editbox
end
-- 显示窗口
function UIWndBase:show(AnimType)
	-- 如果没有加载过，进行加载
	self:loadUIConfig();
	UIManager:getInstance():addToRoot(self.m_pWidget, self.zOrder);
	-- 执行初始化
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setTouchEnabled(false);
    TouchCaptureView.getInstance():show();
	self:onInit();
    if AnimType == TRAN_RIGHT_TO_LEFT then
        self.m_AnimType = TRAN_RIGHT_TO_LEFT;
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
            onComplete = function()
                self.m_pWidget:setVisible(true);
                local topWnd = UIManager.getInstance():getSecondTopWnd();
                topWnd.m_pWidget:setTouchEnabled(false);
                topWnd.m_pWidget:moveBy(0.2, -display.width, 0);
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
                    onComplete = function()
                        TouchCaptureView.getInstance():hide();
                        self.m_pWidget:setTouchEnabled(true);
                        local topWnd = UIManager.getInstance():getSecondTopWnd();
                        topWnd.m_pWidget:setTouchEnabled(true);
                    end
                    }); 
            end
            });
    elseif AnimType == PUSH_BOTTOM_TO_TOP then
        self.m_AnimType = PUSH_BOTTOM_TO_TOP;
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
            onComplete = function()
                self.m_pWidget:setVisible(true);
                local topWnd = UIManager.getInstance():getSecondTopWnd();
                topWnd.m_pWidget:setTouchEnabled(false);
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
                    onComplete = function()
                        TouchCaptureView.getInstance():hide();
                        self.m_pWidget:setTouchEnabled(true);
                        local topWnd = UIManager.getInstance():getSecondTopWnd();
                        topWnd.m_pWidget:setTouchEnabled(true);
                    end
                    }); 
            end
            });
    else
        TouchCaptureView.getInstance():hide();
        self.m_pWidget:setVisible(true);
        self.m_pWidget:setTouchEnabled(true);
    end

end

-- 关闭窗口
function UIWndBase:close(noAnim)
	if self.m_pWidget == nil then
		return;
	end
    --
    TouchCaptureView.getInstance():show();
    self.m_pWidget:setTouchEnabled(false);
    if not noAnim and self.m_AnimType == TRAN_RIGHT_TO_LEFT then
        local topWnd = UIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        topWnd.m_pWidget:moveBy(0.2, display.width, 0);
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(display.width, 0)), {
            onComplete = function()
                TouchCaptureView.getInstance():hide();
                local topWnd = UIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);

                self:onClose();
                UIManager.getInstance():removeToRoot(self.m_pWidget);
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    elseif not noAnim and self.m_AnimType == PUSH_BOTTOM_TO_TOP then
        local topWnd = UIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, -display.height)), {
            onComplete = function()
                TouchCaptureView.getInstance():hide();
                local topWnd = UIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);
                self:onClose();
                UIManager.getInstance():removeToRoot(self.m_pWidget);
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    else
        TouchCaptureView.getInstance():hide();
        self:onClose();
        UIManager.getInstance():removeToRoot(self.m_pWidget);
        self.m_pWidget = nil;
        --
        self.netImgsTable = {};
    end


    
end

-- 收到返回键事件
function UIWndBase:onKeyBack()
    if self.m_pWidget and self.m_pWidget:isVisible() and self.m_pWidget:isTouchEnabled() then
        self:keyBack();
    end
    
end

-- 收到返回键事件
function UIWndBase:keyBack()
    UIManager.getInstance():popWnd(self);
end

-- 网络连通
function UIWndBase:onNetWorkConnected()
end

-- 网络关闭
function UIWndBase:onNetWorkClosed()
    Log.i("------UIWndBase:onNetWorkClosed")
    LoadingView.getInstance():hide();
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = "网络异常，请检查您的网络是否正常再进入游戏";
    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();
        if UIManager.getInstance():getWnd(HallLogin) then
            --在登录界面
            return;
        end

        if UIManager.getInstance():getWnd(HallMain) then 
            -- 在大厅
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 网络关闭
function UIWndBase:onNetWorkClose()
end

-- 网络连通失败
function UIWndBase:onNetWorkConnectFail()
    Log.i("------UIWndBase:onNetWorkConnectFail")
    LoadingView.getInstance():hide();
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = "连接服务器失败，请检查您的网络是否正常再进入游戏";
    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();

        if UIManager.getInstance():getWnd(HallMain) then 
            -- 在大厅
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 网络连通异常
function UIWndBase:onNetWorkConnectWeak()
    Log.i("------UIWndBase:onNetWorkConnectWeak");
    LoadingView.releaseInstance();
    LoadingView.getInstance():show("您当前的网络不稳定，请检查您的网络", 10, true);
end

-- 网络连通异常
function UIWndBase:onNetWorkConnectException()
    Log.i("------UIWndBase:onNetWorkConnectException");
    LoadingView.getInstance():show("网络异常，正在重连...");
end

-- 网络重连成功
function UIWndBase:onNetWorkReconnected()
    Log.i("------UIWndBase:onNetWorkReconnected");
    LoadingView.getInstance():hide();
    Toast.getInstance():show("重连成功");
end

function UIWndBase:onTouchBegan(touch, event)
  return false;
end

function UIWndBase:onTouchMoved(touch, event)

end

function UIWndBase:onTouchEnded(touch, event)

end

--注册触摸事件
function UIWndBase:regTouchEvent()
   	    -- handing touch events
        local touchBeginPoint = nil
        local function onTouchBegan(touch, event)
		    local location = touch:getLocation()
            Log.i("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
            return self:onTouchBegan(touch, event)
        end

        local function onTouchMoved(touch, event)
            local location = touch:getLocation()
            Log.i("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
             self:onTouchMoved(touch, event)
        end

        local function onTouchEnded(touch, event)
            local location = touch:getLocation()
            Log.i("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
            self:onTouchEnded(touch, event)
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_pWidget)
end



function UIWndBase:handleSocketCmd(cmd, ...)
	if not self.s_socketCmdFuncMap[cmd] then
		printLog("UIWndBase", "Not such socket cmd="..cmd.."in current wnd");
		return;
	end

	return self.s_socketCmdFuncMap[cmd](self, ...);
end

UIWndBase.s_socketCmdFuncMap = {
	
};