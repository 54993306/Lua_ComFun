-- 更新界面

HallUpdate = class("HallUpdate", UIWndBase);

function HallUpdate:ctor(info)
    self.super.ctor(self, "hall/hallUpdate.csb", info);
end

function HallUpdate:onShow()
    if self.m_data.neVDRL then
        local data = {};
        data.cmd = NativeCall.CMD_UPDATE_VERSION;
        data.URL = self.m_data.neVDRL;
        data.path = WRITEABLEPATH .. "update/";
        NativeCall.getInstance():callNative(data, HallUpdate.updatePro, self); 
    end
end

function HallUpdate:updatePro(info)
    if info.type == 1 then
        self.pb:setPercent(info.pro);
        self.lb_percent:setString(info.pro .. "%");
        if info.pro == 100 then
            self.lb_status:setString("内容解压中，不消耗流量，请稍候");
        end   
    elseif info.type == 3 then
        LoadingView.getInstance():hide();

        package.loaded["app.hall.HallConfig"] = nil;
        require("app.hall.HallConfig");
        package.loaded["app.config"] = nil;
        require("app.config");
        
        package.loaded["app.common.FileLog"] = nil;
        local FileLog = require("app.common.FileLog")
        FileLog.init(CACHEDIR)

        UIManager.getInstance():pushWnd(HallLogin);
    elseif info.type == 4 then
        Toast.getInstance().show("解压失败");
    end
end

-- 响应窗口回到最上层
function HallUpdate:onResume()
end

function HallUpdate:onClose()
    
end

function HallUpdate:onInit()
    local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");
    title:loadTexture(_gameTitlePath);

    self.pb = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb");
    self.pb:setPercent(0);

    self.lb_percent = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_percent");

    self.lb_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_status");
    self.lb_status:setString("更新中");
    
end

--返回
function HallUpdate:keyBack()
    
end