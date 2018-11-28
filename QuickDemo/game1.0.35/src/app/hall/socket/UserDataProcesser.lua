UserDataProcesser = class("UserDataProcesser", SocketProcesser)

function UserDataProcesser:repUserInfo(code, packetInfo)
    Log.i("UserDataProcesser:repUserInfo..........")
    kUserData_userInfo:syncData(code, packetInfo);
end

function UserDataProcesser:repUserExtInfo(code, packetInfo)
Log.i(" UserDataProcesser:repUserExtInfo............")
    kUserData_userExtInfo:syncData(code, packetInfo);
end

function UserDataProcesser:repUserPointInfo(code, packetInfo)
Log.i("UserDataProcesser:repUserPointInfo.........")
    kUserData_userPointInfo:syncData(code, packetInfo);
end

function UserDataProcesser:repUserRecordInfo(code, packetInfo)
Log.i("UserDataProcesser:repUserRecordInfo/..............")
    kUserData_userRecordInfo:syncData(code, packetInfo);
end

--接收礼包UI信息
function UserDataProcesser:recvGiftLogicInfo(code, packetInfo)
Log.i("UserDataProcesser:recvGiftLogicInfo..........")
    kGiftData_logicInfo:syncData(code, packetInfo);
end

UserDataProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_USERDATA_USERINFO]   = UserDataProcesser.repUserInfo;
    [HallSocketCmd.CODE_USERDATA_EXT]   = UserDataProcesser.repUserExtInfo;
    [HallSocketCmd.CODE_USERDATA_POINT]   = UserDataProcesser.repUserPointInfo;
    [HallSocketCmd.CODE_USERDATA_RECORD_CODE]   = UserDataProcesser.repUserRecordInfo;
    [HallSocketCmd.CODE_USERDATA_QUEST]   = UserDataProcesser.recvGiftLogicInfo;
};