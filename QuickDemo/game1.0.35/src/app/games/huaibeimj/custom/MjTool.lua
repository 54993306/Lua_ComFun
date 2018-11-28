--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local MjTool = {}

function MjTool.strToCharTable(str)
	assert(type(str) == "string")

	local table = {}
	local len = string.len(str)
	for i = 1, len do
		table[#table + 1] = string.byte(str, i)
	end
	return table
end

function MjTool.tableCopy(table)
	assert(type(table) == "table")

	local tab = {}
    for k, v in pairs(table) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = tableCopy(v)
        end
    end
    return tab
end

function MjTool.moneyToStr(str)
	return str
end

function MjTool.getAvatarUrl(userID)
    local vt = 1
    local st = 10202001
    local uid = tonumber(userID)
    local sp = 0
    local gid = 0
    local hid = 0
    local mst = 8
    local phototype = 1
--    local baseUrl = ww.LuaDataBridge:getInstance():getStrValueByKey("res_dl_url")
    local baseUrl = "http://192.168.10.91:8585/gamesrc/getsrc.jsp"
    local url = string.format("%s?vt=%d&st=%d&uid=%d&sp=%d&gid=%d&hid=%d&mst=%d&phototype=%d",baseUrl,vt,st,uid,sp,gid,hid,mst,phototype)


    return url
end

function MjTool.centerCropSprite(sprite, containerSize)
    local dwidth = sprite:getContentSize().width
    local dheight = sprite:getContentSize().height

    local vwidth = containerSize.width
    local vheight = containerSize.height

    local scale = 1.0

    if dwidth * vheight > vwidth * dheight then
        scale = vheight / dheight
    else
        scale = vwidth / dwidth
    end


	sprite:setScale(scale)
end

return MjTool