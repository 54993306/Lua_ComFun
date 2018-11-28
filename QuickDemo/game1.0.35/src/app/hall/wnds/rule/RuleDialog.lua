-------------------------------------------------------------
--  @file   RuleDialog.lua
--  @brief  规则显示对话框
--  @author Zhu Can Qin
--  @DateTime:2016-09-22 16:30:22
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
RuleDialog = class("RuleDialog", UIWndBase)


local kWidgets = {
    tagCloseBtn     = "rule_close_btn",
    tagRuleText   	= "rule_lable",		-- 文本
    tagListView  	= "listView",
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RuleDialog:ctor(info)
    self.super.ctor(self, "hall/rule_dialog.csb", info)
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RuleDialog:onShow()
    print("onShow")
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function RuleDialog:onClose()
    print("onClose")
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function RuleDialog:onInit()
    self.button_close 	= ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton))
    -- 文本内容
    self.listeView 		= ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagListView)
    local content = ccui.Text:create();
    content:setColor(cc.c3b(0, 0, 0))
    -- content:setFontName("font/bold.ttf");
    -- content:enableShadow();
    content:setTextAreaSize(cc.size(640, 0));
    -- 规则显示 
    content:setString(_gameHelpContentText or "提示内容");
  
    content:setFontSize(26);
    content:ignoreContentAdaptWithSize(false)
    self.listeView:pushBackCustomItem(content);
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function RuleDialog:onClickButton(pWidget, EventType)
    print(EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

function RuleDialog:keyBack()
    UIManager:getInstance():popWnd(RuleDialog)
end

--endregion
