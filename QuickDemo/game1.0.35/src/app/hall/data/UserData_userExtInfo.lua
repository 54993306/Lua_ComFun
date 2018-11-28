--玩家扩展数据

UserData_userExtInfo = class("UserData_userExtInfo", UserData_base);

UserData_userExtInfo.getInstance = function()
    if not UserData_userExtInfo.s_instance then
        UserData_userExtInfo.s_instance = UserData_userExtInfo.new();
    end

    return UserData_userExtInfo.s_instance;
end

UserData_userExtInfo.releaseInstance = function()
    if UserData_userExtInfo.s_instance then
        UserData_userExtInfo.s_instance:dtor();
    end
    UserData_userExtInfo.s_instance = nil;
end

function UserData_userExtInfo:ctor()
    self.super.ctor(self);
end

function UserData_userExtInfo:dtor()

end

kUserData_userExtInfo = UserData_userExtInfo.getInstance();