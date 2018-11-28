FreeShareDialog = class("FreeShareDialog", UIWndBase)

function FreeShareDialog:ctor()
    self.super.ctor(self, "hall/share_diamond.csb")
end

function FreeShareDialog:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_share1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share1");
    self.btn_share1:addTouchEventListener(handler(self, self.onClickButton));

    local bg = ccui.Helper:seekWidgetByName(self.btn_share1, "bg");

    self.btn_share2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share2");
    self.btn_share2:addTouchEventListener(handler(self, self.onClickButton))
    

    self.m_shareGiftInfo = kGiftData_logicInfo:getShareGift();
    
    if self.m_shareGiftInfo then
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(kUserInfo:getUserId() .. "-" .. self.m_shareGiftInfo.Id);
        if userGiftInfo and userGiftInfo.status == 2 then
            bg:setVisible(false);
            return;
        end   
    end

    local sequence = transition.sequence({
                    cc.FadeOut:create(0.1),
                    cc.DelayTime:create(0.3),
                    cc.FadeIn:create(0.1),
                    cc.DelayTime:create(0.3)
    });
    bg:runAction(cc.RepeatForever:create(sequence));

end

function FreeShareDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_share1 then
            UIManager:getInstance():pushWnd(FreeShareDialogDetail);
        elseif pWidget == self.btn_share2 then
            Toast.getInstance():show("功能暂时未开放");
        end
    end
end


function FreeShareDialog:keyBack()
    UIManager:getInstance():popWnd(FreeShareDialog)
end

