--加钻提示

AddMoneyDialog = class("AddMoneyDialog", UIWndBase)

function AddMoneyDialog:ctor(data, zorder)
    self.super.ctor(self, "hall/addmoney_dialog.csb", data);
    -- if device.platform == "ios" then
    --     self.m_data.content = string.gsub(self.m_data.content,"补充钻石","游戏遇到问题")
    -- end
end

--获取内容类型
function AddMoneyDialog:getContentType()
    return self.m_data.contentType;
end

function AddMoneyDialog:onInit()
    --关闭                             
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
   
    --内容
    local testHeight = cc.Label:create();
    --testHeight:ignoreContentAdaptWithSize(false);
    -- --testHeight:setSize(CCSize(540, 0));
    testHeight:setWidth(540);
    testHeight:setHeight(0);
    testHeight:setSystemFontSize(40);
    testHeight:setString(self.m_data.content or "提示内容");
    local size = testHeight:getContentSize();
    Log.i("------size", size);

    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_content");
    if size.height > 250 then
        content:setContentSize(size);
        ccui.Helper:seekWidgetByName(self.m_pWidget, "content"):setContentSize(CCSize(660, size.height + 350));
        ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content"):setContentSize(CCSize(620, size.height + 310));
    end
    content:setString(self.m_data.content or "提示内容");
    self.content = content
    local size = content:getContentSize();
    Log.i("------size1", size);
end


function AddMoneyDialog:updateWechatId(str)
    self.content:setString(str)
end


function AddMoneyDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        self:keyBack();
    end
end

function AddMoneyDialog:onShow()
    TouchCaptureView.getInstance():show();
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