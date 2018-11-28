HallSocketProcesser = class("HallSocketProcesser", SocketProcesser)

function HallSocketProcesser:repServerInfo(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    kServerInfo:setData(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:clearUserData()
    kUserData_userInfo:release();
    kUserData_userExtInfo:release();
    kUserData_userPointInfo:release();
    kGiftData_logicInfo:release();
    kUserInfo.releaseInstance();
end

function HallSocketProcesser:repLogin(cmd, packetInfo)
    self:clearUserData();
    
    packetInfo = checktable(packetInfo);
    kUserInfo.releaseInstance();
    kUserInfo = UserInfo.getInstance();
    kUserInfo:setUserId(packetInfo.usI);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo1(cmd, packetInfo)
--    Toast.getInstance():show("更新用户信息repUserInfo1........."..info.code)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo2(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo3(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repGameStart(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repChargeList(cmd, packetInfo)
    info = checktable(packetInfo);
    kChargeListInfo:setChargeList(info.reL);
    Log.i("info", info)
end

function HallSocketProcesser:repResumeGame(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repBrocast(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repAdTxt(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    kServerInfo:setAdTxt(packetInfo.co);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repSystemConfig(cmd, packetInfo)
    info = checktable(packetInfo);
    kSystemConfig:setSystemConfigList(info.li);
end

--type = 2,code=20012, 邀请房列表请求
function HallSocketProcesser.sendRoomConfig(tmpData)
   tmpData.gaI = kFriendRoomInfo:getGameID()
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_FRIEND_ROOM_CONFIG,tmpData);
end  

--type = 2,code=20013, 邀请房配置
--Config		
--##    Id  int  
--##    gaI  int  游戏ID
--##    roS  int  排行对局数
--##    roS0  int  总对局数
--##    exT  int  过期时间，单位分钟
--##    aw  String  排行发奖
--##    plS  int  游戏人数
--##    inS  int  初始积分
--##    an  int  底注
--##    roFT  int  房费类型（填入物品ID，可以是金豆和元宝，开房卡）
--##    roF  int  房费数量
--##  inRC:[Config]  inRC  List<Config>  
function HallSocketProcesser:recvRoomConfig(cmd, packetInfo)
   packetInfo = checktable(packetInfo);
   kFriendRoomInfo:setRoomBaseInfo(packetInfo)
   self.m_delegate:handleSocketCmd(cmd,packetInfo);
end  

function HallSocketProcesser:recvFriendRoomStartGame(cmd, packetInfo)
    Log.i("......接收邀请房开始对局消息.........")
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function HallSocketProcesser:recvRoomSceneInfo(cmd, packetInfo)
    Log.i("HallSocketProcesser:recvRoomSceneInfo")
    packetInfo = checktable(packetInfo)
	kFriendRoomInfo:setRoomInfo(packetInfo)
end

--
function HallSocketProcesser.sendPlayerGameState(tmpData)
   tmpData.usI = kUserInfo:getUserId();
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_PLAYER_ROOM_STATE,tmpData);
   LoadingView.getInstance():show("正在获取信息,请稍后...");
end

-- type = 2,code=20018,玩家游戏过程中状态    client  <-->  server
--##  usI  long  用户ID
--##  gaT  int   游戏类型(0:大厅  1:普通子游戏 2:朋友开房 3:比赛)
function HallSocketProcesser:recvPlayerGameState(cmd, packetInfo)
    Log.i("......接收到玩家在游戏中状态.........")
	LoadingView.getInstance():hide();
    packetInfo = checktable(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function HallSocketProcesser:recvOpenRoomMoney(cmd, packetInfo)
    Log.i("......接收到玩家有多少钻石消息.........")
    packetInfo = checktable(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
	kFriendRoomInfo:setMoneyInfo(packetInfo)
end

function HallSocketProcesser:recordInfo(cmd, packetInfo)
    Log.i("接收战绩记录信息",packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--[[
-- @brief  接收战绩详细记录
-- @param  void
-- @return void
--]]
function HallSocketProcesser:recordDetailedInfo(cmd, packetInfo)
    Log.i("......接收战绩详细记录信息",packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--已创建房间玩法信息
function HallSocketProcesser:recvRoomCreate(cmd, packetInfo)
    kFriendRoomInfo:setSelectRoomInfo(packetInfo);
end

--已创建房间信息
function HallSocketProcesser:recvRoomSceneInfo(cmd, packetInfo)
    kFriendRoomInfo:setRoomInfo(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--支付成功
function HallSocketProcesser:recChargeResult(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:recvRoomEnter(cmd, packetInfo)
    packetInfo = checktable(packetInfo)
    kFriendRoomInfo:setSelectRoomInfo(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

function HallSocketProcesser:recvGiftLogicInfo(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

function HallSocketProcesser:recvGiftList(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    kHallGiftInfo:setGiftBaseInfo(packetInfo);
end

function HallSocketProcesser:repHallRefreshUI(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

HallSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_SERVERINFO]   = HallSocketProcesser.repServerInfo;
    [HallSocketCmd.CODE_REC_LOGIN]      = HallSocketProcesser.repLogin;

    [HallSocketCmd.CODE_USERDATA_USERINFO]   = HallSocketProcesser.repUserInfo1;
    [HallSocketCmd.CODE_USERDATA_EXT]   = HallSocketProcesser.repUserInfo2;
    [HallSocketCmd.CODE_USERDATA_POINT]   = HallSocketProcesser.repUserInfo3;
    [HallSocketCmd.CODE_USERDATA_QUEST]   = HallSocketProcesser.recvGiftLogicInfo;
    
    [HallSocketCmd.CODE_REC_RESUMEGAME]   = HallSocketProcesser.repResumeGame;
    [HallSocketCmd.CODE_REC_GAMESTART]   = HallSocketProcesser.repGameStart;
    [HallSocketCmd.CODE_REC_CHARGLIST]   = HallSocketProcesser.repChargeList;
    
    [HallSocketCmd.CODE_REC_BROCAST]   = HallSocketProcesser.repBrocast;
    [HallSocketCmd.CODE_REC_AD_TXT]   = HallSocketProcesser.repAdTxt;
    
    [HallSocketCmd.CODE_REC_SYSTEM_CONFIG]   = HallSocketProcesser.repSystemConfig;
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_CONFIG] = HallSocketProcesser.recvRoomConfig; 	--邀请房配置
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = HallSocketProcesser.recvRoomSceneInfo; --InviteRoomEnter	邀请房信
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = HallSocketProcesser.recvFriendRoomStartGame; --邀请房对局开始
	[HallSocketCmd.CODE_PLAYER_ROOM_STATE]       = HallSocketProcesser.recvPlayerGameState;--有未完成对局,恢复游戏对局提示
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_MONENY]       = HallSocketProcesser.recvOpenRoomMoney;--接收开房是否有房卡
    [HallSocketCmd.CODE_RECV_RECORD_INFO]       = HallSocketProcesser.recordInfo;--有未完成对局,恢复游戏对局提示

    [HallSocketCmd.CODE_FRIEND_ROOM_CREATE] = HallSocketProcesser.recvRoomCreate;     --InviteRoomCreate   创建邀请房结果

    [HallSocketCmd.CODE_REC_CHARGERESULT]   = HallSocketProcesser.recChargeResult;
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = HallSocketProcesser.recvRoomEnter; --InviteRoomEnter  进入邀请房结果

    [HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO]     = HallSocketProcesser.recordDetailedInfo;--详细战绩信息
    [HallSocketCmd.CODE_REC_GIFTLIST]   = HallSocketProcesser.recvGiftList;
    [HallSocketCmd.CODE_REC_HALL_REFRESH_UI]  = HallSocketProcesser.repHallRefreshUI;
};