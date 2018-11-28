-------------------------------------------------------------
--  @file   RecordDialog.lua
--  @brief  战绩类定义
--  @author Zhu Can Qin
--  @DateTime:2016-09-22 12:05:19
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
RecordDialog = class("RecordDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn     = "close_btn",
    tagTableView    = "scrollView",
    tabItem         = "scrollViewItem",
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RecordDialog:ctor(info)
    self.super.ctor(self, "hall/record_dialog.csb", info)
    self.m_socketProcesser = HallSocketProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
    -- 请求战绩 -- 
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_RECORD_INFO)
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RecordDialog:onShow()
    print("onShow")

end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function RecordDialog:onClose()
    print("onClose")
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function RecordDialog:onInit()
    self.tableView  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTableView)
    self.itemUI     = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tabItem)
    self.itemUI:setVisible(false)

    self.button_close = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton));
end
--[[
-- @brief  显示战绩函数
-- @param  void
-- @return void
--]]
function RecordDialog:showRecordList(info)
    local function scrollFunc(data, mWight, nIndex)
        -- self.itemUI:setVisible(true)
        local time          = ccui.Helper:seekWidgetByName(mWight, "time_text")
        time:setString(data.ti)
        local date          = ccui.Helper:seekWidgetByName(mWight, "date_text")
        date:setString(data.da)
        local roomNub   = ccui.Helper:seekWidgetByName(mWight, "room_num")
        roomNub:setString(data.roID)
        for i=1, #data.usL do
            local nameStr       = string.format("player_name_%d", i)
            local playerName    = ccui.Helper:seekWidgetByName(mWight, nameStr) 
            playerName:setString(tostring(data.usL[i].niN))
            local scoreStr      = string.format("player_score_%d", i)
            local playerScore   = ccui.Helper:seekWidgetByName(mWight, scoreStr) 
            playerScore:setString(tostring(data.usL[i].ca))
            -- 请求详细信息
            local recListBtn = ccui.Helper:seekWidgetByName(mWight, "record_list_btn")
            recListBtn:addTouchEventListener(function (pWidget, EventType)
                if EventType == ccui.TouchEventType.ended then
                    SoundManager.playEffect("btn", "hall");
                    UIManager:getInstance():pushWnd(MatchRecordDialog, data.roID)
                end
            end)

        end
    end
    self.m_scrollView = new_cScrollView(self.tableView, self.itemUI, info.li, scrollFunc, 0, 20)
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function RecordDialog:onClickButton(pWidget, EventType)
    print(EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

function RecordDialog:keyBack()
    UIManager:getInstance():popWnd(RecordDialog)
end

-- 返回战绩
RecordDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_RECORD_INFO] = RecordDialog.showRecordList
}

--endregion
