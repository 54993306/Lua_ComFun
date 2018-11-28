--充值数据

SystemConfig = class("SystemConfig");

SystemConfig.getInstance = function()
    if not SystemConfig.s_instance then
        SystemConfig.s_instance = SystemConfig.new();
    end

    return SystemConfig.s_instance;
end

SystemConfig.releaseInstance = function()
    if SystemConfig.s_instance then
        SystemConfig.s_instance:dtor();
    end
    SystemConfig.s_instance = nil;
end

function SystemConfig:ctor()
    self.m_dataList = {};
end

function SystemConfig:dtor()

end

function SystemConfig:setSystemConfigList(dataList)
    self.m_dataList = dataList;
    if kLoginInfo:getIsReview() then
        return;
    end
end

function SystemConfig:getSystemConfigList()
    return self.m_dataList;
end

kSystemConfig = SystemConfig.getInstance();