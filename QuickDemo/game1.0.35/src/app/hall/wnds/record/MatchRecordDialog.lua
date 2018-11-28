-------------------------------------------------------------
--  @file   main.lua
--  @brief  lua 类定义
--  @author ZCQ
--  @DateTime:2016-10-19 10:08:25
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
MatchRecordDialog = class("MatchRecordDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn     = "close_btn",
    tagTableView    = "scrollView",
    tabItem         = "scrollViewItem",
    tagRecordBtn    = "record_btn",
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:ctor(info)
	MatchRecordDialog.super.ctor(self, "hall/record_match_dialog.csb", info)
    self.m_socketProcesser = HallSocketProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
    -- 请求战绩 -- 
    self.roomid = info
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_MATCH_RECORD_INFO, {roI = self.roomid})

    -- self:registerScriptHandler( function(event)
    --     if event == "enter" then
    --         self:onEnter()
    --     elseif event == "exit" then
    --         self:onExit()
    --     end
    -- end )
end

--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onInit()

    self.tableView  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTableView)
    self.itemUI     = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tabItem)
    self.itemUI:setVisible(false)

    self.button_close = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton));


end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onShow()
    print("onShow")

end
--[[
-- @brief  点击按钮函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end

--[[
-- @brief  显示战绩函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:showRecordList(info)

    local function scrollFunc(data, mWight, nIndex)
        -- self.itemUI:setVisible(true)
        local time          = ccui.Helper:seekWidgetByName(mWight, "time_text")
        time:setString(data.gaST)
        local date          = ccui.Helper:seekWidgetByName(mWight, "date_text")
        date:setString(data.gaSD)
        local matchNum      = ccui.Helper:seekWidgetByName(mWight, "match_num")
        local strMatch      = string.format("第%d局", nIndex)
        matchNum:setString(strMatch)

        for i=1, #data.usL do
            local nameStr       = string.format("player_name_%d", i)
            local playerName    = ccui.Helper:seekWidgetByName(mWight, nameStr) 
            playerName:setString(tostring(data.usL[i].niN))
            local scoreStr      = string.format("player_score_%d", i)
            local playerScore   = ccui.Helper:seekWidgetByName(mWight, scoreStr) 
            playerScore:setString(tostring(data.usL[i].ca))
            -- 回放按钮
            self.recordBtn = ccui.Helper:seekWidgetByName(mWight, "record_btn")
            self.recordBtn:addTouchEventListener(function (pWidget, EventType)
                if EventType == ccui.TouchEventType.ended then
                    SoundManager.playEffect("btn", "hall");              
                    -- 获取战绩数据表
                    self:getNetRecordFromJson(data.plBF)  
                    kPlaybackInfo:setCurrentGamesNum(nIndex)
                end          
            end)
        end
    end
    self.m_scrollView = new_cScrollView(self.tableView, self.itemUI, info.li, scrollFunc, 0, 2)
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

--[[
-- @brief  获取网络对战信息
-- @param  void
-- @return void
--]]
function MatchRecordDialog:getNetRecordFromJson(jsonFileName)
	Log.i("MatchRecordDialog:getNetRecordFromJson...",jsonFileName)
	-- 文件名字
    if nil == jsonFileName then
        printError("MatchRecordDialog:getNetRecordFromJson 找不到回放的数据")
        return
    end
    local recUrl = kServerInfo:getRecordUrl()
    recUrl = recUrl..jsonFileName
    Log.i("------imgUrl", recUrl);
    if string.len(recUrl) > 4 then
        HttpManager.getNetworkJson(recUrl, jsonFileName);  
    else
        printError("MatchRecordDialog:getNetRecordFromJson 获取对战信息失败")
    end
end

--[[
-- @brief  返回网络战绩json文件
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onResponseNetJson(fileName)
    Log.i("------MatchRecordDialog:onResponseNetJson fileName", fileName);
    VideotapeManager.getInstance():reSponseInfo(fileName)
end
-- -- 改变变量名字
-- --[[
-- -- @brief  拼装消息函数
-- -- @param  void
-- -- @return void
-- --]]
-- function MatchRecordDialog:contentNameChange(messages) 
--     local message = {}
--     message.subcode = messages.code
--     message.content = messages.jsonContent
--     message.code    = messages.type
--     return message
-- end

-- function MatchRecordDialog:getUrlFileName( strurl, strchar, bafter)  
--     local ts = string.reverse(strurl)  
--     local param1, param2 = string.find(ts, strchar)  -- 这里以"/"为例  
--     local m = string.len(strurl) - param2 + 1     
--     local result  
--     if (bafter == true) then  
--         result = string.sub(strurl, m+1, string.len(strurl))   
--     else  
--         result = string.sub(strurl, 1, m-1)   
--     end  
--     return result  
-- end

function MatchRecordDialog:keyBack()
    UIManager:getInstance():popWnd(MatchRecordDialog)
end

-- 返回战绩
MatchRecordDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO] = MatchRecordDialog.showRecordList
}

return MatchRecordDialog