--玩家账户数据

UserData_userPointInfo = class("UserData_userPointInfo", UserData_base);

UserData_userPointInfo.getInstance = function()
    if not UserData_userPointInfo.s_instance then
        UserData_userPointInfo.s_instance = UserData_userPointInfo.new();
    end

    return UserData_userPointInfo.s_instance;
end

UserData_userPointInfo.releaseInstance = function()
    if UserData_userPointInfo.s_instance then
        UserData_userPointInfo.s_instance:dtor();
    end
    UserData_userPointInfo.s_instance = nil;
end

function UserData_userPointInfo:ctor()
    self.super.ctor(self);
end

function UserData_userPointInfo:dtor()

end

kUserData_userPointInfo = UserData_userPointInfo.getInstance();