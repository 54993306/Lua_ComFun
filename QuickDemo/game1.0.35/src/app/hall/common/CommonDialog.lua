--
--通用对话框界面
--使用方法
-- local data = {}
-- data.type = 1                              --对话框类型：1,一个"确定"按钮  2，一个“取消”按钮和一个“确定”按钮
-- data.contentType = COMNONDIALOG_TYPE_NETWORK;  --对话框提示内容类型
-- data.content = "提示内容"                  --对话框提示内容
-- data.yesCallback                           --确定按钮回调
-- data.cancalCallback                        --取消按钮回调
-- data.closeCallback                         --关闭按钮回调
-- data.canKeyBack                            --能按物理返回键关闭
-- UIManager.getInstance():pushWnd(CommonDialog, data);

CommonDialog = class("CommonDialog", UIWndBase)

function CommonDialog:ctor(data, zorder)
    self.super.ctor(self, "hall/common_dialog.csb", data, WND_ZORDER_COMMONDDIALOG);
end

--获取内容类型
function CommonDialog:getContentType()
    return self.m_data.contentType;
end

function CommonDialog:onInit()
    --关闭                             
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
    --取消                           
    self.btn_cancal = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_cancal");
    self.btn_cancal:addTouchEventListener(handler(self, self.onClickButton));
    --确定                           
    self.btn_yes = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_yes");
    self.btn_yes:addTouchEventListener(handler(self, self.onClickButton));
   
    --按钮
    if not self.m_data.type or self.m_data.type == 1 then
        self.btn_cancal:setVisible(false);
        self.btn_yes:setVisible(false);
    else
        self.btn_close:setVisible(false);
    end
    --内容
    -- local testHeight =Label:create();
    -- testHeight:ignoreContentAdaptWithSize(false);
    -- testHeight:setSize(CCSize(520,0));
    -- testHeight:setString(self.m_data.content or "提示内容");
    -- testHeight:setFontSize(26);
    -- local size = testHeight:getContentSize();
    -- testHeight = nil;

    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_content");
    -- if size.height > 150 then
    --     content:setSize(size);
    --     UIHelper:seekWidgetByName(self.m_pWidget,"hint_bg"):setSize(CCSize(571, size.height + 170));
    -- end
    content:setString(self.m_data.content or "提示内容");
end

function CommonDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        self.m_data.canKeyBack = true;
        self:keyBack();
        if pWidget == self.btn_close then
            if self.m_data.closeCallback then
                self.m_data.closeCallback();
                return;
            end
        elseif pWidget == self.btn_yes then
            if self.m_data.yesCallback then
                self.m_data.yesCallback() 
            end
        elseif pWidget == self.btn_cancal then
            if self.m_data.cancalCallback then
                self.m_data.cancalCallback() 
            end
        end
    end
end

function CommonDialog:onShow()
    TouchCaptureView.getInstance():show();
    --SoundManager.playEffect("dialog_pop", "hall");
    self.m_pWidget:setTouchEnabled(false);
    local contentView = ccui.Helper:seekWidgetByName(self.m_pWidget, "content");
    contentView:setAnchorPoint(cc.p(0.5, 0.5));
    transition.execute(contentView, cc.ScaleTo:create(0.1, 0.9) ,{
        onComplete = function()
            transition.execute(contentView, cc.ScaleTo:create(0.1, 1) ,{
            onComplete = function()
                self.m_pWidget:setTouchEnabled(true);
                TouchCaptureView.getInstance():hide();
            end
            });
        end
    });
end

--返回
function CommonDialog:keyBack()
    if self.m_data.canKeyBack == nil or  self.m_data.canKeyBack == true then
        UIManager.getInstance():popWnd(self);
    end
end