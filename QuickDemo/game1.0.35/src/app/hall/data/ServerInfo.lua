--服务端系统数据

ServerInfo = class("ServerInfo");

ServerInfo.getInstance = function()
    if not ServerInfo.s_instance then
        ServerInfo.s_instance = ServerInfo.new();
    end

    return ServerInfo.s_instance;
end

ServerInfo.releaseInstance = function()
    if ServerInfo.s_instance then
        ServerInfo.s_instance:dtor();
    end
    ServerInfo.s_instance = nil;
end

function ServerInfo:ctor()
    self.m_data = {};
end

function ServerInfo:dtor()

end

function ServerInfo:setData(data)
    self.m_data = data;
end

function ServerInfo:getChargeList()
    return self.m_data;
end

--服务器时间
function ServerInfo:getServerTime()
    return self.m_data.syT or os.time()*1000;
end

--头像地址前缀
function ServerInfo:getHeadUrl()
    return self.m_data.heIURL or "";
end

--图片地址前缀
function ServerInfo:getImgUrl()
    return self.m_data.imURL;
end

--更新包地址前缀
function ServerInfo:getZipUrl()
    return self.m_data.gaZURL;
end

--获取充值信息
function ServerInfo:getRechargeInfo()
    return self.m_data.reT;
end

--首页广告url
function ServerInfo:getMainAdUrl()
    return self.m_data.adURL;
end
--首页广告url
function ServerInfo:getMainAdUrl1()
    if self.m_data.adURL then
        local urlTab = string.split(self.m_data.adURL, "|");
        return urlTab[1];
    end
end

--首页弹出广告url
function ServerInfo:getMainAdUrl2()
    if self.m_data.adURL then
        local urlTab = string.split(self.m_data.adURL, "|");
        return urlTab[2];
    end
end
--广告文字
function ServerInfo:getAdTxt()
    return self.m_adTxt;
end

--广告文字
function ServerInfo:setAdTxt(content)
    self.m_adTxt = content;
end

-- 回放包url
function ServerInfo:getRecordUrl()
    return self.m_data.reURL;
end

function ServerInfo:getDayShareInfo()
    if type(self.m_data.daS) == "string" then
        local tab = json.decode(self.m_data.daS)
        return tab or {}
    end
    return {}
end

function ServerInfo:getInviteShareInfo()
    if type(self.m_data.inS) == "string" then
        local tab = json.decode(self.m_data.inS)
        return tab or {}
    end
    return {}
end

function ServerInfo:getClubShareInfo()
    if type(self.m_data.clS) == "string" then
        local tab = json.decode(self.m_data.clS)
        return tab or {}
    end
    return {}
end

kServerInfo = ServerInfo.getInstance();