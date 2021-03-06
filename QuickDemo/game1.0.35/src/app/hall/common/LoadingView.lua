--等待中提示

LoadingView = class("LoadingView");

LoadingView.getInstance = function()
    if not LoadingView.s_instance then
        LoadingView.s_instance = LoadingView.new();
    end

    return LoadingView.s_instance;
end

LoadingView.releaseInstance = function()
    if LoadingView.s_instance then
        if LoadingView.s_instance.m_pWidget then
            LoadingView.s_instance.m_pWidget:removeFromParent();
        end
        LoadingView.s_instance = nil;
    end
end

LoadingView.ctor = function(self)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    self.m_pWidget:setContentSize(cc.size(display.width, display.height));
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
    UIManager.getInstance():addToRoot(self.m_pWidget, WND_ZORDER_LOADINGVIEW);

    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));
    self.m_loadingView = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/loading.csb");
    self.m_pWidget:addChild(self.m_loadingView);
end 

function LoadingView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if self.isTouchable then
            self:hide();
        end
    end
end

--显示内容为text的LoadingView
LoadingView.show = function(self, text, time, touchable)
    self.isTouchable = touchable;
    time = time or 10;
    self.m_pWidget:setVisible(true);
    self.m_pWidget:setContentSize(cc.size(display.width, display.height));
    local size = self.m_loadingView:getContentSize();
    self.m_loadingView:setPosition(cc.p((display.width - size.width)/2, 0.5*display.height));

    transition.stopTarget(self.m_loadingView);
    local img_load = ccui.Helper:seekWidgetByName(self.m_loadingView, "img_load");
    local txt_load = ccui.Helper:seekWidgetByName(self.m_loadingView, "txt_load");
    --
    transition.stopTarget(img_load);
    img_load:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)));
    txt_load:setString(text or "正在加载中，请稍后...");
    if time and time > 0 then
        self.m_loadingView:performWithDelay(function()
            self:hide();
        end, time);
    end
end 

LoadingView.hide = function(self)
--    print( debug.traceback() )
    self.m_pWidget:setVisible(false);
end

LoadingView.getVisible = function(self)
    return self.m_pWidget:isVisible();
end