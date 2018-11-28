--MJToast

MJToast = class("MJToast");

MJToast.getInstance = function()
    if not MJToast.s_instance then
        MJToast.s_instance = MJToast.new();
    end

    return MJToast.s_instance;
end

MJToast.releaseInstance = function()
    if MJToast.s_instance then
        if MJToast.s_instance.m_pWidget then
            MJToast.s_instance.m_pWidget:removeFromParent();
        end
        MJToast.s_instance = nil;
    end
end

MJToast.ctor = function(self)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    self.m_pWidget:setTouchEnabled(false);
    UIManager.getInstance():addToRoot(self.m_pWidget, 1000);
    self.toastTab = {};
end 

--显示内容为text的toast
MJToast.show = function(self, text)
    local toast = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/toast.csb");
    toast:setTouchEnabled(false);
    --
    local label = ccui.Helper:seekWidgetByName(toast, "txt");
    local bg = ccui.Helper:seekWidgetByName(toast, "toast");
    --
    --内容
    local testHeight = ccui.Text:create();
    testHeight:setTextAreaSize(cc.size(480, 0));
    testHeight:setString(text or "提示");
    testHeight:setFontSize(30);
    local size = testHeight:getContentSize();
    --Log.i("------size", size);
    --
    label:setString(text or "提示");
    -- if size.height > 42 then
    --     bg:setContentSize(cc.size(520, size.height));
    --     label:setLayoutSize(500, size.height);
    -- else
    --     bg:setContentSize(cc.size(520, 80));
    --     label:setLayoutSize(500, 42);
    -- end
    --
    local size = toast:getContentSize();
    toast:setPosition(cc.p((display.width - size.width)/2, 0.4*display.height));
    self.m_pWidget:removeAllChildren();
    self.m_pWidget:addChild(toast);
    --table.insert(self.toastTab, toast);
    transition.execute(toast, cc.MoveBy:create(1.5, cc.p(0, 0.2*display.height)), {
        onComplete = function()
            self.m_pWidget:removeAllChildren();
            if #self.toastTab > 0 then
                --self.m_pWidget:removeChild(self.toastTab[1], true);
                --table.remove(self.toastTab, 1);
            end
        end
    });
end 