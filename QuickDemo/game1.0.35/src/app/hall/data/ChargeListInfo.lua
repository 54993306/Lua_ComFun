--充值数据

ChargeListInfo = class("ChargeListInfo");

ChargeListInfo.getInstance = function()
    if not ChargeListInfo.s_instance then
        ChargeListInfo.s_instance = ChargeListInfo.new();
    end

    return ChargeListInfo.s_instance;
end

ChargeListInfo.releaseInstance = function()
    if ChargeListInfo.s_instance then
        ChargeListInfo.s_instance:dtor();
    end
    ChargeListInfo.s_instance = nil;
end

function ChargeListInfo:ctor()
    self.m_dataList = {};
end

function ChargeListInfo:dtor()

end

function ChargeListInfo:setChargeList(dataList)
    self.m_dataList = dataList;
end

function ChargeListInfo:getChargeList()
    return self.m_dataList;
end

function ChargeListInfo:setOpenChargeList(openList)
    self.m_gameOpenList = openList;
end

function ChargeListInfo:getOpenChargeList()
    return self.m_gameOpenList;
end

function ChargeListInfo:getChargeInfo(chargeId)
    for k, v in pairs(self.m_dataList) do
        if v.Id == chargeId then
            return v;
        end
    end
end

function ChargeListInfo:setChargeEnvironment(path, gameId, roomId)
    self.m_path = path;
    self.m_gameId = gameId;
    self.m_roomId = roomId;
end

function ChargeListInfo:getChargePath()
    return self.m_path or RECHARGE_PATH_STORE;
end

function ChargeListInfo:getRoomId()
    return self.m_roomId or 0;
end

function ChargeListInfo:getGameId()
    return self.m_gameId or 0;
end

kChargeListInfo = ChargeListInfo.getInstance();