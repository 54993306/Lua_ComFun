--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local UIBase = class("UIBase")

UIBase.getInstance = function()
    if not UIBase.s_instance then
        UIBase.s_instance = UIBase.new();
    end

    return UIBase.s_instance;
end
function UIBase:ctor()
end

function UIBase:setDelegate(delegate)
    self.m_delegate = delegate;
end
--获取子控件
function UIBase:getWidget(parent,name,...)
    local widget = nil
    local args = ...
    widget = ccui.Helper:seekWidgetByName(parent,name)
	if(widget==nil) then return end
    local m_type = widget:getDescription()
    if m_type == "Label" then
        widget:setFontName("hall/font/bold.ttf")
        if args then
            if args.shadow == true then
                widget:enableShadow()
            end
        end
    end
 return widget
end

kUIBase = UIBase.getInstance();
--endregion
