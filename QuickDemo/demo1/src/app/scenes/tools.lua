
------ 在渲染的位置打Log，运行所有的功能，将使用到的内容记录下来，并打印出来。

local tools = {}

local json = require("framework.json")

-- 类的入口函数
function tools:ctor()
    -- local str = "D:\\Svn_2d\\H_HN_3.6.1\\res\\hall\\about_us.csb"   -- 带点号的文件夹会对文件类型获取造成干扰

    -- print("===========>>> " ..  string.match(str , "[.]([%w]+)"))
    -- print("===========>>> " ..  string.match(str , "[.]([%w]+)"))
end

function tools:CacheCollect()
    -- 性能监测
    Log.i("CacheCollect begin")
    local files = io.open("out.txt" , "w+")
    local memory = io.open("memory.txt" , "w+")
    if not files then return end
    local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    FrameProcesser = scheduler.scheduleUpdateGlobal(function()
        -- Log.i(cc.Director:getInstance():getFrameRate())
        if cc.Director:getInstance():getFrameRate() < 30 then
            local outstr = ""
            outstr = string.format("Frame rate = %.1f \n %s \n %s \n %s \n============================= %s ============================= \n",
                tostring(cc.Director:getInstance():getFrameRate()),
                string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")),
                debug.traceback(),
                sharedTextureCache:getCachedTextureInfo(),
                os.date()
                )
            files:write(outstr)
        end
    end);

    MemoryProcesser = scheduler.scheduleGlobal(function()
        memory:write(
            string.format("%.1f|%.3f|%.3f" ,
                cc.Director:getInstance():getFrameRate() ,
                cc.Director:getInstance():getSecondsPerFrame() ,
                collectgarbage("count")),
            "\n")
    end, 0.5)
    -- files:close()
end

-- 异步图片加载方案
function tools:syncLoadSpriteFrame()
    local t_btn = ccui.Button:create("hall/GUI/selected01.png")
    t_btn:setPosition(cc.p((i - 1) % 4 * 130 + 100, 430 - math.floor((i - 1) / 4) * 120)) -- 按钮位置(相对于父节点)
    t_btn:addTo(lay)
    t_btn:setTitleFontSize(18) -- 按钮文字的字体大小
    t_btn:setTitleText("666")
    t_btn:setColor(display.COLOR_RED)
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/Common/test.plist")
    t_btn:addTouchEventListener( function(pWidget,touchType)   -- 使用异步加载精灵帧的方式来判断，合集图片是否会影响界面创建
        if touchType ==ccui.TouchEventType.ended then
            display.addSpriteFrames("hall/Common/test.plist" , "hall/Common/test.png" , function(plist, image)
                local layc = class("layc", UIWndBase)
                function layc:ctor(...)
                    self.super.ctor(self, "hall/lay_test.csb", ...);    -- 使用的是大图来进行的界面拼装
                end

                Log.i("===========>>>" , plist , image)
                UIManager:getInstance():pushWnd(layc)
            end)
        end
    end)
end

-- 去重插入
function tools:uniqInsert(tab , value)
    for _,v in pairs(tab)do
        if value == v then
            -- print("-------repeat value :" .. tostring(value))
            return false
        end
    end
    table.insert(tab,value)
    return true
end

-- 形成json文件的文件夹包含内容报告
function tools:initResourceTypeNum(tab , path)
    local file = io.open(path , "w+")
    local strs = {}
    for _, v in pairs(tab) do
        if string.match(v , "[.]([%w]+)") then
            local key = string.match(v , "[.]([%w]+)")
            if key then
                if strs[key] then
                    strs[key].num = strs[key].num + 1
                    table.insert(strs[key].path , v)
                else
                    strs[key] = {}
                    strs[key].num = 1
                    strs[key].path = {}
                    table.insert(strs[key].path , v)
                end
                -- strs[key] = (strs[key] or 0) + 1
            end
        end
    end
    file:write(json.encode(strs))   -- alt + e快捷键可以格式化json的内容
    io.close(file)   -- 可以以追加的方式写在总文件的最后
end

-- 目录下的所有文件存入paths中 self:initPaths('.', paths)  -- . 表示当前文件
function tools:initPaths(rootpath, paths , pattern)
    paths = paths or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath..'\\'..entry
            local attr = lfs.attributes(path)
            assert(type(attr) == 'table')
            if attr.mode == 'directory' then
                self:initPaths(path, paths , pattern)
            else
                if string.find(path,pattern or ".png") then
                    table.insert(paths, path)
                end
            end
        end
    end
    return paths
end

-- 从表中移除包含模式的内容
function tools:removeIncludePattern(tab , pattern)
    local oldnum = #tab
    for index = oldnum , 1 , -1 do
        if string.find(tab[index] , pattern) then
            -- print("remove content : " ..  tostring(tab[index]))
            table.remove(tab , index)
        end
    end
    print("remove num : " .. (oldnum - #tab))
end

-- 将表中的内容写到文件中
function tools:writeTabToFile(tab , path)
    if not tab or not path then
        print(" tab or path is nil")
        return false
    end
    local file = io.open(path , "w+")
    for _,v in pairs(tab) do
        file:write( v , "\n")
    end
    io.close(file)
    return true
end


-- 将文件中的内容存储到table中
function tools:fileSaveToTable(path)
    local tab = {}
    local file = io.open(path , "r")
    assert(file)
    for line in file:lines() do
        table.insert(tab , line)
    end
    print("------------ path : " .. path  .." " .. " num : " .. #tab)
    return tab
end

-- 根据切割符(flag)切割字符串str
function tools:cutStrByFlag( str, flag)
    local ts = string.reverse(str)
    local b = string.find(ts, flag)
    local len = string.len( str )
    return string.sub(str, len-b+2, len)
end

-- 裁切匹配内容的字符串
function tools:cutStrByStr(str,curstr)
    return string.sub(str , 1 , string.find(str , curstr) - 1)
end

-- 读取文件中所有内容
function tools:readFile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

-- 写入内容到文件
function tools:writeFile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

-- 判断文件是否存在
function tools:fileExists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

-- 读取并输出文件每一行内容
function tools:readFileByLine(path)
    local file = io.open(path, "r")
    if file then
        for line in file:lines() do
            print(line)
        end
        io.close(file)
    end
end


--[[
    -- 使用文件的md5判断文件是否为同一个文件
    -- 获取json图片的路径，json中图片的路径会发生改变。
    -- 取得每个文件的文件名和md5值，相应的文件原来的路径是，修改后文件的路径是
    -- 根据md5值来匹配每一个具体的文件，就知道这个文件到底是去了什么地方
    -- 测试文件修改名称后md5值是否发生改变
--]]

function tools:test()
    local md1 = crypto.md5file("3333.png")
    local md2 = crypto.md5file("4444.png")
    if md1 == md2 then  -- 文件名改变md5值不改变
        -- print("--- file md5 equal")
    end

    self:charSetText()

    -- self:operatePathAndFile()

    self:LuaCommand()
end

-- 裁切字符串
function tools:testCutString()
    -- 从字符串中裁切出最后的图片文件名
    local str = "D:\\Svn_2d\\S_Trunk_GD_Dev\\res\\hall\\yaoqing\\pro_front.png"
    local str2 = self:cutStrByFlag(str , "\\")
    local str3 = self:cutStrByStr(str2,".png")
    -- print(str3)
end

-- 读取行内容
function tools:testReadLine()
    -- local jsonpath = "D:\\Svn_2d\\UI_Shu\\Json\\about_us.json"
    local jsonpath = "D:\\Svn_2d\\UI_Shu\\Json\\hall.json"
    local file = io.open(jsonpath, "r")
    if file then
        local num = 0
        for line in file:lines() do
            if string.find(line,".png")then
                -- print(line)
                num = num + 1
            end
            -- print(line)
        end
        io.close(file)
        -- print("-----------json has png num:"..num)
    end
end

-- 字符集测试
function tools:charSetText()
    -- 魔法字符 () . % - + * ? [ ] $ 需要用 % 来进行转义 , \ 是默认转义字符用于转义 " " 等符号
    local strmatch = "                        \"path\": \"huanpi2/bindingPhone/red_1.png\","
    local strmatch2 = "huanpi2/bindingPhone/text_changePhone.png"
    local strmatch3= "huanpi2/bindingPhone/text_changePhone.plist,huanpi2/bindingPhone/text_changePhone2.png"
    local strmatch4= "huanpi2/bindingPhone/text_changePhone.fnt"
    strmatch = string.gsub(strmatch," ","") -- 去除空格
    print(strmatch)
    local cc = string.match(strmatch , "\"%a+\"")
    print(cc)
    local bb,dd = string.find(strmatch , "\"%a+\"")  -- %a+ 表示一个或多个字母序列
    local ee = string.sub(strmatch , dd+1,string.len(strmatch))
    print(bb .. " " .. dd .. " " .. ee)


    -- bb,dd = string.find("0101010101" , "[01]*")  -- [01] lua 模式匹配中字符集的使用测试 , 表示匹配0和1，只匹配一个字符，是0或1则返回
    -- 匹配大小写字母(%w),斜杠(/),下划线(_),和点(%.)，点是魔法字符需要用%转义，每个字符集匹配一个字符
    -- 最后的*表示匹配多个, .png表示直接匹配 .png
    bb,dd = string.find(strmatch , "[%w/_%.]*.png")
    local str2 = string.sub(strmatch , bb , dd )
    if bb and dd then
        print("------" .. bb .. " " .. dd .. " str: " .. str2)
    end

    -- 用捕获(从目标字符串中抽出匹配于模式的内容)功能获取匹配到的字符串，而不是用裁切
    -- 模式串可以很长，但是只捕获需要的部分，将需要捕获的内容放入到圆括号中
    local str3 = string.match(strmatch , "([%w/_%.]*.png)")  -- 将需要捕获的内容写入到圆括号内
    print("----- 捕获 : ".. str3 )
    local str4 = string.match(strmatch , "[\"]([%w/_%.]*.png)[\"]") -- 匹配整个模式，但是从中截取出图片路径
    print("----- 捕获指定内容 :" .. str4)

    -- 一行中多次捕获
    local file = io.open("res\\aaa.json", "r")
    for line in file:lines() do
        for path in string.gmatch(line , "([%w%.%-%s_/]*.png)[\"]") do  -- 一行中有可能存在多个png的情况
            print(path)
        end
    end

    local str5 = string.match(strmatch3 , "[\"]([%w/_%.]*.(png)|(fnt))[\"]")
    print(str5)
end

-- 创建路径和文件，删除文件和路径
function tools:operatePathAndFile()
    local path = "res/aaa"
    lfs.mkdir(path) -- 创建路径的，创建文件要使用io.open的方式来

    local file1 = io.open("res/aaa/ccc.txt" , "a+")   -- 可以在已经存在的目录中创建文件
    file1:write("cccc","\n")
    io.close(file1)

    os.remove("res/aaa/ccc.txt") -- 删除文件
    lfs.rmdir(path)  -- 里面有文件则删除不掉路径
end

-- 读取图片尺寸
function tools:limage(path,typed)
    --读取文件大小和图片宽高
    reslimage = {}
    if path then
        --要先安装https://github.com/keplerproject/luafilesystem/
        local lfs   = require "lfs"
        --local filepath="./ed724426a341d666369a244a2e8c54ad.jpg"

        local res=lfs.attributes(path)
        local size = res["size"]
        if size ~=  nil and tonumber(size) >= 0 then
            reslimage["size"] = size
        end

        if typed == "dpi" then
        --要先安装https://github.com/yufei6808/limage
            local width,height=image_size(path)
            if width and height then
                reslimage["dpi"] = width.."x"..height
            end
        end
    end
    return reslimage
end


-- 测试seek函数
function tools:seekUser()
    -- 打开文件
    local myfile = io.open("seektest.txt", "w")
    -- 记录文件开始位置
    local beginpos = myfile:seek()
    print("file begin pos = "..beginpos)
    -- 向后移动100个字节
    local movehundred = myfile:seek("cur", 100)
    print("after move hundred file pos = "..movehundred)
    -- 回退95个字节，开始输入内容
    local moveback = myfile:seek("cur", -95)
    print("after move back file pos = "..moveback)
    myfile:write("file begin......................")
    myfile:write("................................")
    -- 向后移动20字节，插入内容
    myfile:seek("set", 20)
    myfile:write("\nthis is insert content\n")
    -- 从后回退15字节插入内容
    myfile:seek("end", -15)
    myfile:write("\nbingo end")
    -- 记录此文件大小
    local curfilesize = myfile:seek("end")
    print("cur file size = "..curfilesize)
    -- 结尾向后扩大10字节插入内容
    myfile:seek("end", 10)
    myfile:write("test")
    -- 记录最终文件大小作比较
    local finalfilesize = myfile:seek("end")
    print("final file size = "..finalfilesize)
    -- 移动文件指针到开头
    myfile:seek("set")
    myfile:write("haha ")
    myfile:close();
    myfile = io.open("seektest.txt", "r")
    -- 读取文件内容
    local content = myfile:read("*a");
    myfile:close();
    -- 打印内容
    print("\nfile content is:")
    print(content)
end

-- lua 命令行测试 sed/awk

function tools:LuaCommand()
    -- local t = io.popen('adb help') -- 和直接在dos界面执行命令的结果是一样的，但是这个命令的结果保存在文件当中
    -- local a = t:read("*all")
    -- print(a)
    -- io.close(t)

    -- os.execute("color 02");      -- 修改输出窗口的字体颜色
    local originalPath = "D:\\Lua_ComFun\\QuickDemo\\demo1\\res\\3333.png"
    local backupPath = "D:\\Lua_ComFun\\QuickDemo\\demo1\\res\\222"
    local copyret = os.execute("copy " .. originalPath .. ",".. backupPath) -- 整个字符串是一个命令，一个dos命令
    print("copyret = "..copyret)
    -- os.execute("pause");

    local res = lfs.attributes("D:\\Lua_ComFun\\QuickDemo\\demo1\\res\\fat")
    print(type(res))
    -- dump(res)

end

return tools
