-- 朋友开房基本信息
FriendRoomInfo = class("FriendRoomInfo");

-- 游戏类型
FriendRoomGameType =
{
    DDZ = 1,
    -- 地主
    MJ = 2,-- 麻将
}

-- 开始游戏入口
StartGameType =
{
    NONE = 0,
    -- 未知状态
    FIRENDROOM = 1,
    -- 朋友开房
    MATCH = 2,-- 比赛
}



-- 玩家在游戏过程中的状态
FriendRoomPlayerState = {
    EnterState = 1,
    -- 进入状态
    ExitState = 2,
    -- 退出状态
    playingState = 3,-- 玩游戏状态
}


-- 玩家排名信息
FriendRoomPlayerRankingStruct = {
    [1] = { title = "第一名", r = 255, g = 227, b = 0 },
    [2] = { title = "第二名", r = 206, g = 206, b = 206 },
    [3] = { title = "第三名", r = 140, g = 85, b = 65 },
    [4] = { title = "第四名", r = 130, g = 130, b = 130 }
}

FriendRoomInfo.g_isReturnFriendRoom = false;-- 是否是返回到朋友开房UI

function FriendRoomInfo:getPlayingInfoByTitle(title)
    for k, v in pairs(_gamePalyingName) do
        if (v.title == title) then
            return v
        end
    end
    return nil;
end

function FriendRoomInfo:getPlayingInfoByChina(ch)
    for k, v in pairs(_gamePalyingName) do
        if (v.ch == ch) then
            return v
        end
    end
    return nil;
end

FriendRoomInfo.getInstance = function()
    if not FriendRoomInfo.s_instance then
        FriendRoomInfo.s_instance = FriendRoomInfo.new();
    end

    return FriendRoomInfo.s_instance;
end

FriendRoomInfo.releaseInstance = function()
    if FriendRoomInfo.s_instance then
        FriendRoomInfo.s_instance:dtor();
    end
    FriendRoomInfo.s_instance = nil;
end

function FriendRoomInfo:ctor()
    self.m_roomBaseInfo = { };
    -- 配置数据
    self.m_roomInfo = { }
    -- 邀请房信息
    self.m_isFriendRoom = StartGameType.NONE
end

-- 获取游戏ID
function FriendRoomInfo:getGameID()
    return CONFIG_GAEMID;
end

function FriendRoomInfo:getGameType()
    return _gameType;
end


function FriendRoomInfo:clearData()
    Log.i("..................................重新初始化朋友开房数据.............................")
    self.m_isFriendRoom = StartGameType.NONE
    self.m_gameEnd = false;
    self.m_roomInfo = { };
end

function FriendRoomInfo:dtor()

end

--[[
 ["coI"] = {
 "configMap":{
"10007":{"gameId":10007,"initScore":1000,"RoomFeeType":10006,"ExpiredTime":24,
"playerSum":4,
"roundSum":"4|8|12|16",
"RoomFeeSum":"1|1|2|2",
"difen":"1|2|5|10",
"fengding":"3|4|5",
"wanfa":"dingque|huansanzhang|zimojiadi|zimojiafan|yaojiujiangdui|jingougou|zhigangcagua|jishiyu|sanhuaqihu|yifanqihu|kechi",
"wanfahuchi":["zimojiadi|zimojiafan", "zimojiafan|zimojiadi"],
"shareTitle":"d邀请您进入一个d房间！","shareDesc":"d邀请您进入一个d房间，邀请码是d！",
"shareLink":"http://wxpt.stevengame.com/wxdsqp/front/downdetail",
"roomFeeTip":"房卡不足，请联系群主或以下微信号xxxxxxxx。点击任意位置关闭提示信息。"},
"jiadi":"2|3|4"
]]

function FriendRoomInfo:setRoomBaseInfo(roomConfigInfo)
    self.m_roomBaseInfo = json.decode(roomConfigInfo.coI);
    Log.i("房间信息", self.m_roomBaseInfo)
end

function FriendRoomInfo:getRoomBaseInfo()
    return self.m_roomBaseInfo or { };
end


-- 从房间列表中取出一个房间基本信息
function FriendRoomInfo:getRoomInfoByGameID(gameID)
    Log.i("游戏ID", gameID)
    return self.m_roomBaseInfo
end


function FriendRoomInfo:setRoomInfo(packInfo)
    self.m_roomInfo = packInfo
end

function FriendRoomInfo:removeRoomPlayerInfo(playerid)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == playerid) then
                v = nil
                table.remove(self.m_roomInfo.pl, k)
                return
            end
        end
    end
end

-- 获取当前房间人数
function FriendRoomInfo:getRoomId()
    return self.m_roomInfo.pa;
end

-- 设置房间id
function FriendRoomInfo:setRoomId(roomid)
    self.m_roomInfo.pa = roomid
end


-- 获取正在提审的版本号
function FriendRoomInfo:getReViewVersion()
    return self.m_roomBaseInfo.reviewVersion;
end

-- 获取当前房间人数
function FriendRoomInfo:getRoomPlayerNum()
    local i = 0
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            i = i + 1
        end
    end
    return i
end

-- 获取邀请房全部信息
function FriendRoomInfo:getRoomInfo()
    return self.m_roomInfo;
end

-- 当前用户是否房主
function FriendRoomInfo:isRoomMain(userID)
    if (self.m_roomInfo.owI == userID) then
        return true
    end
    return false
end

function FriendRoomInfo:getRoomMainID()
    return self.m_roomInfo.owI;
end

function FriendRoomInfo:getRoomPlayerListInfo(playerID)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == playerID) then
                return v
            end
        end
    end
    return nil
end


-- 获取当前所开房间对应的房间基本信息
function FriendRoomInfo:getCurRoomBaseInfo()
    -- 测试
    local tmpData = { }
    tmpData.roS = tonumber(self:getSelectRoomInfo().roS)
    -- 发奖的对局数
    tmpData.roS0 = tmpData.roS
    -- 总对局数
    tmpData.an = self.m_roomBaseInfo.difen
    return tmpData
    -- kFriendRoomInfo:getRoomInfoByID(self.m_roomInfo.coI)
end

-- 从服务器获取房间配置信息
function FriendRoomInfo:getRoomConfigFromServer()
    if (self.m_getRoomConfigSucess == nil or self.m_getRoomConfigSucess == false) then
        -- 是否获取成功
        local tmpData = { }
        HallSocketProcesser.sendRoomConfig(tmpData)
        self.m_getRoomConfigSucess = false
    end
end

function FriendRoomInfo:isFriendRoom()
    if (self.m_isFriendRoom == StartGameType.FIRENDROOM) then
        -- 是否获取成功
        return true
    end
    return false
end

-- 按玩家排名返回玩家信息
function FriendRoomInfo:sortPlayerInfo()
    local playerInfo = { }
    if (self.m_roomInfo.pl ~= nil) then
        playerInfo = self.m_roomInfo.pl;
    end
    function comps(a, b)
        return a.ra < b.ra
    end
    table.sort(playerInfo, comps);

    return playerInfo
end

function FriendRoomInfo:setMoneyInfo(packetInfo)
    self.m_moneyInfo = packetInfo
end

function FriendRoomInfo:getMoneyInfo()
    return self.m_moneyInfo
end

function FriendRoomInfo:setSelectRoomInfo(packetInfo)
    self.m_selectRoomInfo = packetInfo
end

function FriendRoomInfo:getSelectRoomInfo()
    return self.m_selectRoomInfo
end

-- 取玩法规则
function FriendRoomInfo:getPlayingInfo()
    local retTable = { }
    local itemList = Util.analyzeString_2(self.m_selectRoomInfo.wa);
    if (#itemList > 0) then
        for i = 1, #itemList do
            local w = itemList[i]
            local ch = "  " .. kFriendRoomInfo:getPlayingInfoByTitle(w).ch;
            table.insert(retTable, ch)
        end
    end
    return retTable
end

-- --总对局数
-- function FriendRoomInfo:getTotalCount()
--   return tonumber(self:getSelectRoomInfo().roS);
-- end

-- --获取剩余局数
-- function FriendRoomInfo:getShengYuCount()
--    local totalNum=self:getTotalCount()--总对局数
--    local playingNum = kFriendRoomInfo:getRoomInfo().noRS
--    return (totalNum-playingNum)
-- end

-- 总对局数
function FriendRoomInfo:getTotalCount()
    local count = self:getSelectRoomInfo().roS or 0
    return tonumber(count);
end

-- 获取剩余局数
function FriendRoomInfo:getShengYuCount()
    local totalNum = self:getTotalCount() or 0
    -- 总对局数
    local playingNum = kFriendRoomInfo:getRoomInfo().noRS or 0
    return(totalNum - playingNum)
end

function FriendRoomInfo:saveNumber(number)
Log.i("number........",number)
    if number ~= nil and number ~= "" then
        cc.UserDefault:getInstance():setStringForKey("roomNumberKey", string.format("%d", number));
    end
end

-- 如果本局为房主所设局数的最后一局,“开始游戏”按钮改成“查看总战绩”按钮
function FriendRoomInfo:isGameEnd()
    return self.m_gameEnd;
end

function FriendRoomInfo:setGameEnd(isEnd)
    self.m_gameEnd = isEnd;
end

function FriendRoomInfo:getPalyerNameByID(tmpID)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == tmpID) then
                return v.niN
            end
        end
    end
    return nil
end

-- 是否有免费活动
function FriendRoomInfo:isFreeActivities()
    local tmpInfo = self:getRoomBaseInfo()
    if (tmpInfo.isNeedRoomFee ~= nil and tmpInfo.isNeedRoomFee == "N") then
        return true
    end
    return false
end
--
kFriendRoomInfo = FriendRoomInfo.getInstance();