--
--新手提示
--

NewerTipsWnd = class("NewerTipsWnd", UIWndBase)

function NewerTipsWnd:ctor(data, zorder)
    self.super.ctor(self, "hall/newer_dialog.csb", data, zorder);
end

function NewerTipsWnd:onInit()
    --关闭                             
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    local btn_img = ccui.Helper:seekWidgetByName(self.btn_close,"img")
    btn_img:loadTexture("hall/newer/img_next.png")
    --
    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_content");
    content:setString("小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！\n现在拉新用户下载游戏还能得钻石。成为代理月入3、4千，赶快联系客服吧！");
    --
    self.m_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.content = ccui.Helper:seekWidgetByName(self.m_pWidget, "content");

    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_back");
    self.btn_back:addTouchEventListener(handler(self,self.onClickButton))
end

function NewerTipsWnd:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.btn_close then
            UIManager.getInstance():popWnd(self);
            UIManager.getInstance():pushWnd(NewerTipsWnd1);
        elseif pWidget== self.btn_back then
            self.m_root:setBackGroundColorOpacity(0);
            transition.scaleTo(self.content, {scale = 0, 
                time = 0.4,
                onComplete = function ()
                    self.content:setVisible(false);
                    UIManager.getInstance():popWnd(self);
                end});
            transition.moveTo(self.content, {
                x = display.width - 380,
                y = display.height * 0.82, 
                time = 0.4});
        end
    end
end

--返回
function NewerTipsWnd:keyBack()
    
end