--子游戏管理
local ChargeIdTool = require("app.PayConfig")
GameManager = class("GameManager");
local choiceShare = require("app.hall.common.share.choiceShare")
GameManager.getInstance = function()
    if not GameManager.s_instance then
        GameManager.s_instance = GameManager.new();
    end

    return GameManager.s_instance;
end

GameManager.releaseInstance = function()
    if GameManager.s_instance then
        GameManager.s_instance:dtor();
    end
    GameManager.s_instance = nil;
end

function GameManager:ctor()
    self.m_gameListInfo = {};
    self.m_openGameListInfo = {};
    self.m_RoomListInfo = {};
end

function GameManager:dtor()
end

--进入游戏，roomId为空表示快速进入
function GameManager:enterGame(gameId, roomId)
    Log.i("-----enterGame gameId", gameId);
    local gameInfo = self:getGameInfo(gameId);
    if not gameInfo then
        Toast.getInstance():show("玩命开发中！");
        return;
    end

    ----------暂时用来测试---------------
    local pathName = gameInfo.clP;


    -------------------------
    local gameConfig = "app.games." .. pathName .. "/GameConfig";
    package.loaded[gameConfig] = nil;


    local isSuccess, errMsg = pcall(require, gameConfig);
    if not isSuccess then
        Toast.getInstance():show("您的版本太低了，请升级更新！");
        return;
    end

    local roomListInfo = self.m_RoomListInfo[gameId];
    if not roomListInfo then
        local data = {};
        data.gaI = gameId;
        SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ROOMLIST, data);
        return;
    end

    if roomId then
        local roomInfo = self:getRoomInfo(gameId, roomId);
        if not roomInfo then
            Toast.getInstance():show("该房间不存在！");
            return;
        end

        if kUserInfo:getMoney() >= roomInfo.thM then
            if roomInfo.thM0 == -1 or kUserInfo:getMoney() <= roomInfo.thM0 then
                local data = {};
                data.gaI = gameId;
                data.plT = roomInfo.ty;
                data.roI = roomInfo.id;
                data.ty = 0;

                SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_GAMESTART, data);
                LoadingView.getInstance():show("正在加载中，请稍后...");
            else
                local tmpRoomInfo = self:getFastRoomInfo(gameId);
                if tmpRoomInfo then
                    local data = {}
                    data.type = 2;
                    data.title = "提示";
                    data.yesTitle  = "去";
                    data.cancelTitle = "不去";
                    data.content = "您的金豆已超过本房间最高要求，将进入" .. tmpRoomInfo.na .. "游戏";
                    data.yesCallback = function()
                        GameManager.getInstance():enterGame(gameId);
                    end
                    UIManager.getInstance():pushWnd(CommonDialog, data);
                end
            end
        else
		    --金豆补助
		    if roomInfo.ta == 1 and kSubsidyInfo:isCanSubsidy() then
			     UIManager:getInstance():pushWnd(SubsidyWnd);
			else
                local chargeItem = self:getChargeItem(roomInfo.thM);
                if chargeItem then
                    kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_FAST, gameId, roomId);
                    local data = {};
                    data.chargeId = chargeItem.Id;
                    if roomInfo.ta == 0 then
                        data.chargeFirst = true;
                    end
                    UIManager.getInstance():pushWnd(RoomChargeView, data);
                else
                    Toast.getInstance():show("金豆不足");
                end
			end

        end

    else
        --快速进入
        local tmpRoomInfo = self:getFastRoomInfo(gameId);
        if tmpRoomInfo then
            local data = {};
            data.gaI = gameId;
            data.plT = tmpRoomInfo.ty;
            data.roI = tmpRoomInfo.id;
            data.ty = 0;

            SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_GAMESTART, data);
            LoadingView.getInstance():show("正在加载中，请稍后...");
        else
            --金豆补助
            if(kSubsidyInfo:isCanSubsidy()) then
                UIManager:getInstance():pushWnd(SubsidyWnd);
            else
                local chargeItem = self:getChargeItem(roomListInfo[1].thM);
                if chargeItem then
                    kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_FAST, gameId, 0);
                    local data = {};
                    data.landScape = true;
                    data.chargeId = chargeItem.Id;
                    UIManager.getInstance():pushWnd(RoomChargeView, data);
                else
                    Toast.getInstance():show("金豆不足");
                end

            end
        end
    end
end

--朋友开房间入口
function GameManager:enterFriendRoomGame(packetInfo)
    Log.i("GameManager:enterFriendRoomGame", packetInfo);

    if  packetInfo.re == 1 then
		--changzhouMJ 常州麻将 xuzhou 徐州麻将
		local gameType = kFriendRoomInfo:getGameType();

		local pathName = gameType
		local gameName = string.upper(pathName);

		local gameConfig = "app.games." .. pathName .. "/GameConfig";
		package.loaded[gameConfig] = nil;

		local isSuccess, errMsg = pcall(require, gameConfig);
		if not isSuccess then
			Toast.getInstance():show("请先下载此游戏！");
			return;
		end

		local gameConfig = "app.games." .. pathName .. "." .. gameName .. "Config";
		package.loaded[gameConfig] = nil;
		require(gameConfig);

		kFriendRoomInfo.m_isFriendRoom = StartGameType.FIRENDROOM --设置游戏是从朋友开房进入

		enterGame(packetInfo);
    end

    --LoadingView.getInstance():hide();

end

--获取快速进入的房间
function GameManager:getFastRoomInfo(gameId)
    local roomListInfo = self.m_RoomListInfo[gameId];
    local tmpRoomInfo = nil;
    local tmpDelta = 0 ;
    for i = #roomListInfo, 1, -1 do
        local roomInfo = roomListInfo[i];
        if kUserInfo:getMoney() >= roomInfo.thM then
            if roomInfo.thM0 == -1 or kUserInfo:getMoney() <= roomInfo.thM0 then
                if not tmpRoomInfo then
                    tmpRoomInfo = roomInfo;
                    tmpDelta  = math.abs((roomInfo.thM + roomInfo.thM0)/2);
                else
                    local delta = math.abs((roomInfo.thM + roomInfo.thM0)/2);
                    if delta < tmpDelta then
                        tmpDelta = delta;
                        tmpRoomInfo = roomInfo;
                    end
                end
            end
        end
    end
    return tmpRoomInfo;
end

--根据房间最低准入获取充值选项
function GameManager:getChargeItem(roomThm)
    local chargeItem = nil;
    local daList = kChargeListInfo:getChargeList();
    for k, v in pairs(daList) do
        if v.trI then
            local kvTab = string.split(v.trI, ",");
            for k1, v1 in pairs(kvTab) do
                local kvTab1 = string.split(v1, ":");
                if kvTab1[1] == "10001" then
                    if tonumber(kvTab1[2]) >= roomThm then
                        chargeItem = v;
                    end
                    break;
                end
            end
        end

        if chargeItem then
            break;
        end
    end
    return chargeItem;
end

function GameManager:getGameRule(gameId)
    local gameInfo = self:getGameInfo(gameId);
    if not gameInfo then
        --Toast.getInstance():show("此游戏不存在！");
        return;
    end
    local pathName = gameInfo.clP;
    ----------暂时用来测试---------------


    -------------------------
    local gameConfig = "app.games." .. pathName .. "/GameConfig";
    package.loaded[gameConfig] = nil;

    local isSuccess, errMsg = pcall(require, gameConfig);
    if not isSuccess then
        --Toast.getInstance():show("玩命开发中！");
        return;
    else

        return _gameRuleStr;
    end
end

function GameManager:setGameListInfo(gameListInfo)
    if cc.UserDefault:getInstance():getBoolForKey("isNewClient", true) then
        cc.UserDefault:getInstance():setBoolForKey("isNewClient", false);
        local ComNum = 0;
        for k, v in pairs(gameListInfo) do
            if v.le ~= 10 then
                ComNum = ComNum + 1;
            end
        end
        if #self:getOpenGameListInfo() > 0 and ComNum ~= #self:getOpenGameListInfo() then
            cc.UserDefault:getInstance():setBoolForKey("isShieldGame", true);
        end
    end
    if cc.UserDefault:getInstance():getBoolForKey("isShieldGame", false) then

        local ComNum = 0;
        for k, v in pairs(gameListInfo) do
            if v.le ~= 10 then
                ComNum = ComNum + 1;
            end
        end
        if ComNum == #self:getOpenGameListInfo() then
            cc.UserDefault:getInstance():setBoolForKey("isShieldGame", false);
        end

        if cc.UserDefault:getInstance():getBoolForKey("isShieldGame", false) then
            local openList = self:getOpenGameListInfo();
            for k, v in pairs(gameListInfo) do
                local isSheild = true;
                for k1, v1 in pairs(openList) do
                    if v.Id == v1 then
                        isSheild = false;
                        break;
                    end
                end
                if isSheild then
                    v.le = 10;
                end
            end
        end
    end

    if cc.UserDefault:getInstance():getBoolForKey("isShieldGame", false) then
        local newGameListInfo = {};
        for k, v in pairs(gameListInfo) do
            if v.le ~= 10 then
                table.insert(newGameListInfo, v);
            end
        end
        gameListInfo = newGameListInfo;
    end


    self.m_gameListInfo = gameListInfo;
end

function GameManager:setOpenGameListInfo(openList)
    self.m_openGameListInfo = openList;
end

function GameManager:getOpenGameListInfo()
    return  self.m_openGameListInfo;
end

--模块开放列表
function GameManager:setFunctionOpenList(openList)
    self.m_functionOpenList = openList;
end

function GameManager:IsFriendRoomOpen()
    if self.m_functionOpenList then
        for k, v in pairs(self.m_functionOpenList) do
            if v == 50 then
                return true;
            end
        end
    end
    return false;
end

function GameManager:getGameListInfo()
    return self.m_gameListInfo or {};
end

function GameManager:getGameInfo(gameId)
    local gameInfo = nil;
    for k, v in pairs(self.m_gameListInfo) do
        if v.Id == gameId then
            gameInfo = v;
        end
    end
    return gameInfo;
end

function GameManager:getGameNameById(gameId)
    for k, v in pairs(self.m_gameListInfo) do
        if v.Id == gameId then
            return v.gaN;
        end
    end
end

function GameManager:setRoomListInfo(gameId, roomListInfo)
    self.m_RoomListInfo[gameId] = roomListInfo;
end

function GameManager:getRoomListInfo(gameId)
    return self.m_RoomListInfo[gameId] or {};
end

function GameManager:getRoomInfo(gameId, roomId)
    local roomInfo = nil;
    local gameRoomListInfo = self.m_RoomListInfo[gameId];
    if gameRoomListInfo then
        for k, v in pairs(gameRoomListInfo) do
            if v.id == roomId then
                roomInfo = v;
            end
        end
    end
    return roomInfo;
end

--游戏是否已经存本地
function GameManager:isHaveGame(data)
    local gameInfo = self:getGameInfo(data.gaI);
	if(gameInfo==nil) then
	    return false
	end
    local pathName = gameInfo.clP;
    ----------暂时用来测试---------------


    -------------------------

    local gameConfig = "app.games." .. pathName .. "/GameConfig";
    package.loaded[gameConfig] = nil;

    local isSuccess, errMsg = pcall(require, gameConfig);
    if not isSuccess then
        --Toast.getInstance():show("请先下载此游戏！");
        return false;
    end

    return true
end

--充值
function GameManager:reCharge(info)
    if info.buW then
        if info.buW == 2 then --微信支付
            local data = {};
            data.cmd = NativeCall.CMD_CHARGE;
            data.type = 2;
            data.appid = info.apI;
            data.partnerid = info.mcID;
            data.prepayid = info.prPI;
            data.noncestr = info.noS;
            data.sign = info.si;
            data.timestamp = info.tiS;
            NativeCall.getInstance():callNative(data, function(info)
                Log.i("------reCharge info", info)
                if info.errCode and info.errCode == -8 then
                    Toast.getInstance():show("您手机未安装微信");
                end
            end);
        elseif info.buW == 1 then --支付宝
            local data = {};
            data.cmd = NativeCall.CMD_CHARGE;
            data.type = 1;
            data.orderInfo = info.orI;
            data.sign = info.si;
            data.signType = info.siT;
            NativeCall.getInstance():callNative(data);
        elseif info.buW == 3 then --银联
            local data = {};
            data.cmd = NativeCall.CMD_CHARGE;
            data.type = 3;
            data.tn = info.tn;
            NativeCall.getInstance():callNative(data);
        end
    end

end

--苹果支付成功了，请求发货
function GameManager:sendIOSCharge(info)
    if info.errCode == 0 then
        LoadingView.getInstance():show("正在为您加房卡,请稍后...");
        local data = {};
        data.boS = info.bodyString;
        data.stID = ChargeIdTool.getServerGoodId(tonumber(info.product));
        --data.stID = 10070;
        data.buW = 4;
        data.gaI = kChargeListInfo:getGameId();
        data.roI = kChargeListInfo:getRoomId();
        data.pa = tonumber(info.price);
        data.paW = kChargeListInfo:getChargePath();
        SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_IOSCHARGE, data);
    else
        LoadingView.getInstance():hide();
        Toast.getInstance():show("支付失败");
    end
end

--分享截屏
function GameManager:shareScreen()
    local shareToWechat = function()
        display.captureScreen(function()
            local data = {};
            data.cmd = NativeCall.CMD_WECHAT_SHARE_SCREEN;
            NativeCall.getInstance():callNative(data);
        end , CACHEDIR .. "screen.jpg");
    end
    local data = {}
    data.shareToWechat = shareToWechat
    data.type = "roompicture"
    UIManager.getInstance():pushWnd(choiceShare, data)
end

--进入房间完成
function GameManager:isEntryComplete()
    return self.m_GameEntryComplete;
end

--进入房间完成
function GameManager:setEntryComplete(isEntryComplete)
    self.m_GameEntryComplete = isEntryComplete;
end

kGameManager = GameManager.getInstance();
