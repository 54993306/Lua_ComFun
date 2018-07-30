
local dongfengsite  = 1

local players = {}

players[1] = {site = 1,door = 0}
players[2] = {site = 2,door = 0}
players[3] = {site = 3,door = 0}
players[4] = {site = 4,door = 0}

for _,player in pairs(players) do
	if player.site == dongfengsite then
		player.door = 1
	end
end

local NextSite = 0
for i = 1, #players - 1 do 
		NextSite = (dongfengsite + i) % #players > 0 and (dongfengsite + i) % #players or #players
--		print("NextSite :", NextSite)
		for _,player in pairs(players) do
				if player.site == NextSite then
					player.door = 1 + i
				end
		end
end

print("-------------")
for _,player in pairs(players) do
	print("Player.door : ",player.door)
end

local PosTest = {}

PosTest.m_EARTH_RADIUS = 6378.137
-- 经度纬度，百度坐标拾取的是经度纬度值
function PosTest:CountDistance1(longitude1,latitude1, longitude2, latitude2)
	local longitude1_radians = self:ConvertDegreesToRadians(longitude1)
	local latitude1_radians = self:ConvertDegreesToRadians(latitude1)
	local longitude2_radians = self:ConvertDegreesToRadians(longitude2)
	local latitude2_radians = self:ConvertDegreesToRadians(latitude2)
	-- 弧度差值
	local vLon = math.abs( longitude1_radians - longitude2_radians )
	local vLat = math.abs( latitude1_radians - latitude2_radians)

	local h = self:HaverSin(vLat) + math.cos(latitude1_radians) * math.cos( latitude2_radians ) * self:HaverSin(vLon)
	local distance = 2 * 6378137 * math.asin( math.sqrt(h) )
	return distance
end

-- 功能： 计算角度一半的正弦平方值
-- 返回： 半角的正弦平方
-- theta： 角度值
function PosTest:HaverSin(theta)
	local v = math.sin(theta / 2)
	return v * v
end

-- 功能： 角度转换为弧度
-- 返回： 弧度
-- degrees： 角度
function PosTest:ConvertDegreesToRadians(degrees)
	return degrees * math.pi / 180
end

-- 功能： 弧度转化为角度
-- 返回： 角度
-- radian：弧度
function PosTest:ConvertRadiansToDegrees(radian)
	return radian * 180 / math.pi
end

-- local distance = PosTest:CountDistance1(39.94607, 116.32793, 31.24063, 121.42575)
--local distance = PosTest:CountDistance1(131.963745,22.545385, 131.963076, 22.545385)
--local distance = PosTest:CountDistance1(26.44584178049,42.32243995304, 19.035702839269, 12.136284785855)  --3436112
local distance = PosTest:CountDistance1(26.44584178049,42.32243995304, 34.984939285965, 30.156981449526) -- 1554231
print("--------distance : ",distance)

ComFun = function(str)
    if string.match(str,"[^%d%l%u]") then  -- 包含数字和字母以外的字符
        return false
    end

    if string.len(str) < 6 or string.len(str) > 14 then  -- 密码长度不符合要求
        return false
    end

    if not string.match(str , "%d") then
        return false;
    else
        if not string.match(str , "%l") and not string.match(str , "%u") then
            return false
        else
            return true
        end
    end
end
-- if ComFun("aaaaa1111111111") then
	-- print("succeed")
	-- else
	-- print("failed")
-- end


local formatPhoneNumber = function(phoneNum, cryp)
    -- if not ComFun.isPhoneNumber(phoneNum) then Log.e() return end -- 不是电话号码不做处理
    local formatNum = ""
    formatNum = string.sub(phoneNum,1,3) .. " "
    if cryp then
        formatNum = formatNum .. "**** "
    else
        formatNum = formatNum .. string.sub(phoneNum,4,7) .. " ";
    end
    formatNum = formatNum .. string.sub(phoneNum,8,11) ;
    return formatNum;
end

print(formatPhoneNumber(13622327013,false))

-- local data = {"a","b",nil,"d","","","","f"}
-- local index = #data
-- for k,v in pairs(data)do
	-- print(" k : " .. k.. " v : " .. v);
-- end

-- for i = index , 1 ,-1 do
	-- print(" k : " .. i.. " v : " .. tostring(data[i]));
-- end

-- for i = index , 1 ,-2 do
	-- if data[i] == nil or data[i] == "" then
		-- table.remove(data,i);
		-- print("----")
	-- end
-- end

-- for i = index , 1 ,-1 do
	-- print(" k : " .. i.. " v : " .. tostring(data[i]));
-- end

-- for k,v in pairs(data)do
	-- print(" k : " .. k.. " v : " .. v);
-- end







-- 字符转ASCII是用string.byte()
-- ASCII转字符用string.char() 

local str = "12345678"
for i=1,string.len(str) do  -- 0-9 对应的sacll码是  48-57
        -- print(string.byte(str,i))
        -- print(string.sub(str,i,i))
end

local bb = ""
local binary = nil
-- 十进制转二进制
binary = function(num)
	local t = num % 2
	if num >2 then
		binary(num / 2)
	end
	bb = bb .. math.floor(t)
end

print (binary(98))
print (bb)

-- 1100010  二进制转10进制
decimal = function(str)
	local num = 0
	local len = string.len(str)
	for i=1,len do  -- 0-9 对应的sacll码是  48-57
        num = num + tonumber(string.sub(str,i,i))*(2 ^ (len - i))   -- 幂次方运算符^
	end
	return num
end
print ("---" .. decimal(bb))


-- 1100010  98

-- 二进制转16进制
-- 取四位转换成一个十六进制数(取四合一法)
local Hexadecimal = {}
Hexadecimal["0000"] = 0
Hexadecimal["0001"] = 1
Hexadecimal["0010"] = 2
Hexadecimal["0011"] = 3
Hexadecimal["0100"] = 4
Hexadecimal["0101"] = 5
Hexadecimal["0110"] = 6
Hexadecimal["0111"] = 7
Hexadecimal["1000"] = 8
Hexadecimal["1001"] = 9
Hexadecimal["1010"] = "A"
Hexadecimal["1011"] = "B"
Hexadecimal["1100"] = "C"
Hexadecimal["1101"] = "D"
Hexadecimal["1110"] = "E"
Hexadecimal["1111"] = "F"

Hex = function(str)
	local len = string.len(str)
	local out = ""
	for i = 1 , math.ceil(len / 4) do 
		local index = len - 4 *(i-1)
		local index2 = index - 3 > 0 and index - 3 or 1
		local _str = string.sub(str , index2,index)   		-- 每次截取4位二进制
		_str = string.rep("0",4 - string.len(_str)) .. _str 	-- 不足4位前面补零处理
		out = Hexadecimal[_str] .. out								-- 匹配相应的十六进制数
	end
	return out
end

print (Hex("1100010"))		-- 98   ox62
print (Hex("1011100110111001"))   -- b9b9
-- 1011100110111001

--  十六进制转十进制
local TabHexToDec = { ["A"] = 10, ["B"] = 11, ["C"] = 12, ["D"] = 13, ["E"] = 14, ["F"] = 15}
HexToDec = function(str)
	str = string.upper(str)
	local num = 0
	local len = string.len(str)
	for i=1,len do  -- 0-9 对应的sacll码是  48-57
		local n = tonumber(string.sub(str,i,i)) or TabHexToDec[string.sub(str,i,i)]
        num = num + n*(16 ^ (len - i))   -- 幂次方运算符^
	end
	return num
end
print(HexToDec("b9b9"))    -- 47545










