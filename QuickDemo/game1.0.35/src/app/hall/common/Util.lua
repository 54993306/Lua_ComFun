local CURRENT_MODULE_NAME = ...

CURRENT_MODULE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6);

require(CURRENT_MODULE_NAME .. ".ToolKit");
require(CURRENT_MODULE_NAME .. ".Log");
require(CURRENT_MODULE_NAME .. ".UIWndBase");
require(CURRENT_MODULE_NAME .. ".UIManager");
require(CURRENT_MODULE_NAME .. ".Toast");
require(CURRENT_MODULE_NAME .. ".LoadingView");
require(CURRENT_MODULE_NAME .. ".CommonDialog");
require(CURRENT_MODULE_NAME .. ".LibDropDownItem");
require(CURRENT_MODULE_NAME .. ".IGameBase");
require(CURRENT_MODULE_NAME .. ".Deque");
require(CURRENT_MODULE_NAME .. ".PageViewWnd");
require(CURRENT_MODULE_NAME .. ".SliderIndicatorSprite");
require(CURRENT_MODULE_NAME .. ".SliderIndicatorWnd");

Util = {};

--获取文件名
Util.getFileNameFromUrl = function(url)
    if url == nil then
        return
    end
    local files = string.split(url, '/');
    if #files > 0 then
        local fileName = files[#files];
        if fileName then    
            return fileName;
        end
    end
end

--金豆数量转换
--最大显示位数6，超出6位后，用万代替，尾数为万超出4位后，用亿代替，小数点保留2位
Util.convMoneyIU = function(num)
    local ret;
    if(num>=1000000  and num<=9999999) then
	  local tmpNum = num / 10000;
	  ret = string.format("%.2f万",tmpNum);
	elseif (num >=100000000) then
	  local tmpNum = num / 100000000;
	  ret = string.format("%.2f亿",tmpNum);
	else
	  ret = string.format("%d",num);
	end
	return ret;
end
--取整数部分
Util.getCeil = function(num)
    
    if num <= 0 then
       return math.ceil(num);
    end
    if math.ceil(num) == num then
       num = math.ceil(num);
    else
       num = math.ceil(num) - 1;
    end
    return num;
end

--字符大小
Util.utfstrlen=function(str)
    if str == nil then return 0 end
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
		if(tmp ==nil) then
		  break
		end
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end

Util.getUTFTextString=function(msg,start,length)
    for k = start,string.len(msg) do
        local g = Util.truncateUTF8String(msg,start,k)
        if Util.utfstrlen(g) == length then
            return g,k
        end
    end
end	

--lua中截取UTF8字符串的方法（无乱码） 
Util.truncateUTF8String=function(s,start,n)
    local dropping = string.byte(s, n+1)
	if not dropping then return s end    
    if dropping ~= nil then
        if dropping >= 128 and dropping < 192 then
            return Util.truncateUTF8String(s, start,n-1)
        end
    end
    return string.sub(s, start, n)
end

--取出字符宽度
Util.getFontWidth =function(msg,fontSize)
    local len = Util.utfstrlen(msg)
	local zhLen = 0
	local engLen =0
	local total  = #msg
	local zhNum =0
    if len <  total then--说明里面有中文
        zhNum = (#msg - len)/2
        zhLen = zhNum*2			
    end 
	if( zhNum > 0) then
	   engLen = total - zhNum*3
	else
	   engLen= len
	end	
    return (zhLen+engLen) * fontSize
end

--取出字符宽度，字符个数
Util.getTextWidth=function(value,fontSize)
    if value == nil then return 0 end
    local len = Util.utfstrlen(value)
    local msgEnd,charPos = Util.getUTFTextString(value,0,len)  
    return Util.getFontWidth(msgEnd,fontSize),len
end

--
Util.split=function( str, splitchar )
    local arr = {}
    local head = 1
    local tail = nil
    while true do
        tail, _ = str:find(splitchar,head )
        if tail == nil then
            arr[ 1 + #arr ] = str:sub( head, -1 )
            break
        end
        arr[ 1 + #arr ] = str:sub( head, tail - 1 )
        head = tail + 1
    end
    return arr
end

--
Util.readCSV = function(fileName)
	local path = cc.FileUtils:getInstance():fullPathForFilename("res/csv/" .. fileName)

	local csv = {}
	
	if path ~= string.format("res/csv/%s",fileName) then
        local tmpIndex=1;
		for line in io.lines(path) do
            if(tmpIndex ~=2) then
               table.insert(csv,Util.split(line,","))
            end
            tmpIndex =tmpIndex+1
		end
	end

	return csv
end

--CSV转LUA
Util.CSV2Table = function(fileName)
    if device.platform == "windows" then
	  --return
	end
	
	local csv = Util.readCSV(fileName)

	if #csv > 0 then
		local path = cc.FileUtils:getInstance():fullPathForFilename("res/csv/" .. fileName)
		local path_root = string.sub( path , 1, -string.len(fileName) - 10)

		local table_path = path_root .. "/res/csv/" .. string.sub(fileName,1,-4) .. "lua"
		local file = io.open(table_path, "w")
		file:write( string.sub(fileName,1,-5) .. " ={\n" )
		for i , line in pairs(csv) do
			if i > 1 then
				file:write( "  [" .. line[1] .. "] = {")
				for m, element in pairs(line) do
					if m > 0 then
					    local keyText=csv[1][m];
						file:write(keyText .. "=")

						if tonumber(string.sub(element,1,1)) == nil then
							file:write("\"")
						end

						file:write(element)

						if tonumber(string.sub(element,1,1)) == nil then
							file:write("\"")
						end
					end
					
					if m ~=0 and m ~= #line then
						file:write(", ")
					end
				end

				file:write("}")
			end
			
			if i ~= 1 and i ~= #csv then
				file:write(", ")
			end
			
			file:write("\n")
		end

		file:write("}\n")
		file:close()
	end
end

--计算一定宽度下再求文本高度
Util.getTextHeight = function(strText,fontName,fontSize,width)
     local h= 0;
    if(width>0) then
		local tmpLabel= cc.LabelTTF:create(strText,fontName,fontSize);--ccui.Text:create(self.xin_text:getString(),self.xin_text:getFontName(),self.xin_text:getFontSize());
		local nLine = math.ceil(tmpLabel:getContentSize().width / width) -- math.ceil(w / self.xin_text:getContentSize().width) 
		h = nLine*fontSize;--计算文本高度 12为每行文本偏移
		Log.i("text height.....%d",h)
	end
	return h;
end

--计算一定宽度下再求文本宽度
Util.getTextWidth = function(strText,fontName,fontSize)
    local w= 0;
	local tmpLabel= cc.LabelTTF:create(strText,fontName,fontSize);
	w = tmpLabel:getContentSize().width 
	Log.i(w)
	
	return w;
end

--1：sum|2：sum 的格式
Util.analyzeString = function(strText)
   local retV={};
   if(strText==nil or strText=="")then return retV end
   
   local retTable = Util.split(strText,"|");
   for k,v in pairs(retTable) do
     local retTable2 = Util.split(v,":");
	 local tmpData={};
	 tmpData.id = retTable2[1];
	 tmpData.num = retTable2[2];
     table.insert(retV,tmpData)
   end
   return retV
end

Util.analyzeString_2 = function(strText)
   local retV={};
   if(strText==nil or strText=="")then return retV end
   local retTable = Util.split(strText,"|");
   return retTable
end
--下划线区分组
Util.analyzeString_3 = function(strText)
    local retV = {};
    if (strText == nil or strText == "" ) then return retV end
    local retTable = Util.split(strText,"_")
    return retTable
end
--替换查找符号信息
Util.replaceFindInfo=function(text,findFlag,replaceDataList)
	local retText=nil
	local bTrue=true
	local bFind=nil
	local index=1
	while bTrue do
		bFind = string.find(text,findFlag)
		if(bFind==nil or index>#replaceDataList) then
		   return retText
		end
		
		retText = string.gsub(text,findFlag,replaceDataList[index],1)
		text = retText
		index = index +1   
	end 	
end

--时间类型转换和00:00:00格式化
Util.timeFormat = function(totalTime)
	local hour = math.floor(totalTime/3600)
	local minute = math.floor(math.mod(totalTime,3600)/60)
	local second = 	math.mod(math.mod(totalTime,3600),60)
	--将int类型转换为string类型
	hour = hour..""
	minute = minute..""
	second = second..""
	--当显示数字为个位数时，前位用0补上
	if string.len(hour) == 1 then
		hour = "0"..hour
	end
	if string.len(minute) == 1 then
		minute = "0"..minute
	end
	if string.len(second) == 1 then
		second = "0"..second
	end
	return hour,minute,second
end

Util.stringSplit = function(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

-- 一定时间内, 禁止按钮的点击事件
Util.disableNodeTouchWithinTime = function(node, time, notGray)
    time = time or 1.5
    if not notGray then node:setColor(cc.c3b(168, 168, 168)) end
    node:setTouchEnabled(false)
    scheduler.performWithDelayGlobal(function()
        if tolua.isnull(node) then return end
        if not notGray then node:setColor(cc.c3b(255, 255, 255)) end
        node:setTouchEnabled(true)
        end, 1)
end

Util.debug_shield_value = function(value)
    -- Log.i("DEBUG_SHIELD_VALUE",DEBUG_SHIELD_VALUE)
    if DEBUG_SHIELD_VALUE and #DEBUG_SHIELD_VALUE> 0 then
        for i,v in pairs(DEBUG_SHIELD_VALUE) do
            if v == value then
                return true
            end
        end
        return false
    else
        return false
    end
end
