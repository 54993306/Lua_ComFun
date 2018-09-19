
require "lfs"

local json = require("framework.json")

local crypto = require "framework.crypto"

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local ProjectPath = "S_Trunk_GD_Dev"

-- local CommonPath = "D:\\Lua_ComFun\\QuickDemo\\demo1\\res\\"
local CommonPath = "res\\" -- 相对路径可以用

-- json 文件的路径
local dir_json_path = "D:\\Svn_2d\\UI_Shu\\Json"
-- csb 文件路径
local dir_csb_path = "D:\\Svn_2d\\" .. ProjectPath .."\\res\\hall"
-- 代码 文件路径
local dir_code_path = "D:\\Svn_2d\\" .. ProjectPath .."\\src"
-- 项目图片位置
local dir_png_path = "D:\\Svn_2d\\" .. ProjectPath .."\\res\\hall"
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-- record file num 15
-- 记录json文件路径
local r_json_paths = "res\\".. ProjectPath .."\\json_path.txt"
-- 记录csb文件路径
local r_csb_paths  = "res\\".. ProjectPath .."\\csb_path.txt"
-- 记录文件夹中图片md5值
local r_Fodel_MD5 = "res\\".. ProjectPath .."\\fodel_md5.txt"
-- 记录json中包含的图片信息
local r_json_image_lines = "res\\".. ProjectPath .."\\json_images_lines.txt"
-- 记录从json文件中截取出来的图片路径
local r_json_pngs = "res\\".. ProjectPath .."\\json_pngs.txt"
-- 记录json中去重后的路径
local r_json_pngs_uniq = "res\\".. ProjectPath .."\\json_pngs_uniq.txt"
-- 记录文件夹中所有的图片路径
local r_fodel_Images = "res\\".. ProjectPath .."\\fodel_Images.txt"
-- 记录文件夹中重复的图片路径
local r_fodel_Repeat_pngs = "res\\".. ProjectPath .."\\fodel_repeat_pngs.txt"
-- 记录代码中包含png行内容
local r_code_line_pngs = "res\\".. ProjectPath .."\\code_line_pngs.txt"
-- 记录代码中png的路径
local r_code_pngs = "res\\".. ProjectPath .."\\code_pngs.txt"
-- 记录代码中包含plist行内容
local r_code_line_plist = "res\\".. ProjectPath .."\\code_line_plist.txt"
-- 记录代码中plist的路径
local r_code_plist = "res\\".. ProjectPath .."\\code_plist.txt"
-- 记录代码中fnt的路径
local r_code_fnt = "res\\".. ProjectPath .."\\code_fnt.txt"
-- 记录代码中包含fnt行内容
local r_code_line_fnt = "res\\".. ProjectPath .."\\code_line_fnt.txt"
-- 记录将要删除的图片路径
local r_delete_pngs = "res\\".. ProjectPath .."\\delete_pngs.txt"

-- 规则比较复杂，手动设置不删除的图片列表
local notDelete = {"green_num_0.png" , "room_num_0.png" , "yellow_num_0.png" , "spin0.png" , "spin1.png"}
-- D:/Svn_2d/S_Trunk_GD_Dev/res/hall/friendRoom/spin0.png
-- D:/Svn_2d/S_Trunk_GD_Dev/res/hall/friendRoom/spin1.png

-- 工程缺少图片时的报错内容
-- Get data from file(hall/friendRoom/img_queding.png) failed, error code is 3

--[[
    -- 资源清理
    -- 操作目录
    -- 操作文件
    -- 裁切字符进行匹配
    -- 判断文件是否存在
    -- 输出文件数量
    -- 从json找图片，从lua中找csb
    -- 找到某个目录下的所有的图片
    -- 查找同名的文件都有哪些。文件名相同，但是文件不同的。
    -- 在文件中，是否都分别使用了它们。
]]
function MainScene:ctor()
    self:createPath()

    self:initJsonAndCsbFile()

    self:initTextures()

    self:initDeleteFile()

    -- self:excuteDeleteFile()
    -- self:test()
end

-- 创建存储路径
function MainScene:createPath()
    local attr = lfs.attributes( CommonPath .. ProjectPath )
    if not attr then
        lfs.mkdir(CommonPath .. ProjectPath)
        attr = lfs.attributes( CommonPath .. ProjectPath )
        print(type(attr))
    end
end

-- 初始化json文件和csb文件相关
function MainScene:initJsonAndCsbFile()
    self.tab_JsonFileName = {}          -- json文件名表  ， 接上路径和json可得到完整json路径

    self.tab_CsbFileName = {}           -- csb文件名表

    self:initCsbRecord()                -- 初始化csb文件表

    self:initJsonRecord()               -- 初始化json文件表

    self:compare_Json_Csb()             -- 比较csb文件和json文件的差异
end

-- 比较json和csb文件表的差异，找出差异项,json和csb应该是一一对应的
function MainScene:compare_Json_Csb()
    local Json_unEqual = {}
    for _,v in pairs(self.tab_JsonFileName) do
        if not self:hasValueInTab(self.tab_CsbFileName, v) then
            self:uniqInsert(Json_unEqual , v)
        end
    end
    if #Json_unEqual > 0 then
        for _,v in pairs(Json_unEqual) do
            print("------------ rich json : " .. v)
        end
        print("----------- rich json num : " .. #Json_unEqual)
    end


    local Csb_unEqual = {}
    for _,v in pairs(self.tab_CsbFileName) do
        if not self:hasValueInTab(self.tab_JsonFileName, v) then
            self:uniqInsert(Csb_unEqual , v)
        end
    end
    if #Csb_unEqual > 0 then
        for _,v in pairs(Csb_unEqual) do
            print("----------- rich csb : " .. v)
        end
        print("----------- rich csb num : " .. #Csb_unEqual)
    end
    self:hasEqualValue(Json_unEqual,Csb_unEqual)
end

-- 初始化含有json文件表
function MainScene:initJsonRecord()
    local r_json = io.open(r_json_paths , "w+")
    for file in lfs.dir(dir_json_path) do          -- 没有嵌套目录的情况,只读取当前目录中包含json的文件
        if file ~= "." and file ~= ".." then
            local filename = string.match(file , "([%w_]*).json")
            if filename then
                table.insert(self.tab_JsonFileName,filename)
                r_json:write(dir_json_path,"\\",file,"\n")
            else
                print("catch str failed in MainScene:initJsonRecord 1 : " .. file)
            end
            -- print(file)
        end
    end
    io.close(r_json)
    print("------- json file num : " .. #self.tab_JsonFileName)
end

-- 初始化csb文件表
function MainScene:initCsbRecord()
    local r_csb = io.open(r_csb_paths , "w+")
    for file in lfs.dir(dir_csb_path) do           -- 没有嵌套目录的情况,只读取当前目录中包含csb的文件
        if file ~= "." and file ~= ".." then
            local attr = lfs.attributes(dir_csb_path .. "\\" .. file)
            assert(type(attr) == 'table')
            if attr.mode ~= 'directory' then
                local filename = string.match(file , "([%w_]*).csb")
                if filename then
                    table.insert(self.tab_CsbFileName,filename)
                    r_csb:write(dir_csb_path,"\\",file,"\n")
                else
                    print("catch str failed in MainScene:initCsbRecord 2 : " .. file)
                end
                -- print(filename)
            end
        end
    end
    io.close(r_csb)
    print("------- csb file num :" .. #self.tab_CsbFileName)
end

-- 目录下的所有文件存入paths中 self:initPaths('.', paths)  -- . 表示当前文件
function MainScene:initPaths(rootpath, paths , pattern)
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
-- selected01
-- 初始化将要删除的图片
function MainScene:initDeleteFile()
    local str = ""
    local delete_path = io.open(r_delete_pngs, "w+")
    local textures = self:fileSaveToTable(r_fodel_Images)           -- 所有图片
    local json_pngs = self:fileSaveToTable(r_json_pngs_uniq)        -- json中包含的图片
    local code_pngs = self:fileSaveToTable(r_code_pngs)             -- 代码中包含的图片
    local code_plist = self:fileSaveToTable(r_code_plist)           -- 代码中包含的plist
    local code_fnt = self:fileSaveToTable(r_code_fnt)               -- 代码中包含的fnt
    local deleteNum = 0
    for _,fodelpath in pairs(textures) do
        local surplus = true  -- 默认图片是多余的
        for _,jsonpng in pairs(json_pngs) do
            str = string.match(fodelpath , "hall/([%w%-%._/%s]*.png)")   -- json中不包含hall目录
            assert(str,fodelpath)
            if str == jsonpng then
                surplus = false  -- 判断在json文件中是否使用
            end
        end

        if surplus then
            for _,codepng in pairs(code_pngs) do
                if codepng == str
                or codepng == string.match(fodelpath , "(hall/[%w%-%._/%s]*.png)")      -- 代码中的路径有以hall开头的
                or codepng == string.match(fodelpath , "(res/hall/[%w%-%._/%s]*.png)")
                then
                    surplus = false  -- 判断在代码中是否使用
                end
            end
        end

        if surplus then
            for _,codelist in pairs(code_plist) do
                if codelist == string.match(fodelpath , "(hall/[%w%-%._/%s]*.png)") then
                    surplus = false  -- 判断在代码中是否使用
                end
            end
        end

        if surplus then
            for _,codefnt in pairs(code_fnt) do
                if codefnt == string.match(fodelpath , "(hall/[%w%-%._/%s]*.png)") then
                    surplus = false  -- 判断在代码中是否使用
                end
            end
        end

        if surplus then
            for _,png in pairs(notDelete) do
                if png == string.match(fodelpath , "[/\\]([%w%-%._%s]*.png)") then
                    surplus = false  -- 判断在代码中是否使用
                    print("-------not delete " , string.match(fodelpath , "[/\\]([%w%-%._%s]*.png)"))
                end
            end
        end

        if surplus then
            deleteNum = deleteNum + 1
            delete_path:write(fodelpath,"\n")
        end
    end
    io.close(delete_path)
    print("----------- delete file num :" .. deleteNum)
end

-- 执行删除文件
function MainScene:excuteDeleteFile()
    local delete_path = io.open(r_delete_pngs, "r")
    local num = 0
    for line in delete_path:lines() do
        if os.remove(line) then
            print("delete : " .. line)
            num = num + 1
        else
            print("delete failed : " .. line)
        end
    end
    print("------------delete num : " .. num  )
    io.close(delete_path)
end

-- 初始化纹理文件表
function MainScene:initTextures()
    self:initFolderTexture()        -- 初始化文件夹中包含的图片文件
    self:initJsonTexture()          -- 初始化json中使用到的图片文件
    self:initCodeFilePngs()      -- 初始化代码文件中包含的png
end

-- 初始化json文件中的纹理文件表
function MainScene:initJsonTexture()
    local json_image_lines = io.open(r_json_image_lines, "w+")
    local json_uniq_path = io.open(r_json_pngs_uniq , "w+")
    local json_pngs = io.open(r_json_pngs,"w+")
    local jsonFiles = io.open(r_json_paths , "r")               -- 存储json文件的路径
    local json_contain_texture = {}                             -- json中包含png的字符串表
    local json_texture = {}                                     -- 存储去重后json中所使用的所有图片
    for path in jsonFiles:lines() do
        local file = io.open(path, "r")
        for line in file:lines() do
            if string.find(line,".png") and not string.find(line,":\\")then -- 找到json中所有的png的行
                assert(json_image_lines:write(line , "\n"))                 -- 记录json中包含png的行
                for str in string.gmatch(line , "[\"]([%w/_%.%s%-]*.png)[\"]") do  -- 一行中有可能存在多个png的情况
                    json_pngs:write(str,"\n")
                    table.insert(json_contain_texture,str)
                    if self:uniqInsert(json_texture,str) then -- 去重后的路径
                        json_uniq_path:write(str,"\n")
                    else
                        -- print(str)
                    end
                end
                -- self:printCantMatchline("[\"]([%w%.%-%s_/]*.png)[\"]" , line)
            end
            -- print(line)
        end
        io.close(file)
    end
    io.close(jsonFiles)
    io.close(json_pngs)
    io.close(json_uniq_path)     -- 去重后json中所使用的图片
    io.close(json_image_lines)
    print("----------- json has png : " .. #json_contain_texture)
    print("----------- uniq json png num : " .. #json_texture)
end

-- 初始化文件夹中的纹理文件表
function MainScene:initFolderTexture()
    local files = {}
    self:initPaths(dir_png_path, files)
    local fodel_md5 = io.open(r_Fodel_MD5, "w+")            -- 记录去重后的md5值
    local fodel_Images = io.open(r_fodel_Images , "w+")     -- 记录文件夹下所有的图片路径
    local repeatfile = io.open(r_fodel_Repeat_pngs , "w+")  -- 记录文件夹下重复的图片路径
    local fodelTextureMd5 = {}                              -- 存在文件夹下图片的md5值
    local repeatTextures = {}                               -- 存储指定路径下重复的图片资源路径
    for _,path in pairs(files) do
        path = string.gsub(path , "\\" , "/")               -- 把反斜杠转化为正斜杠
        fodel_Images:write(path , "\n")
        local md5 = crypto.md5file(path)                    -- 名称不同但是图片相同，路径不同但是图片相同
        if self:uniqInsert(fodelTextureMd5 , md5) then
            fodel_md5:write(md5 , "\n")
        else
            -- print(path)
            repeatfile:write(path , "\n")  -- 用，分隔内容与用..连接内容效果一样，但是效率更高
            table.insert(repeatTextures,path)
        end
    end
    io.close(fodel_md5)
    io.close(fodel_Images)
    io.close(repeatfile)
    print("----------- fodel all texture num : "..#files)
    print("----------- repeat texture num : " .. #repeatTextures) -- 重复的文件可能在不同的地方用到了。
    print("----------- fodel uniq md5 num : " .. #fodelTextureMd5)
end

-- 初始化代码文件中的png表
function MainScene:initCodeFilePngs()
    local files = {}
    self:initPaths(dir_code_path, files , ".lua")
    print("------------ lua files num : " .. #files )
    local image_lines = io.open( r_code_line_pngs , "w+")
    local code_pngs = io.open(r_code_pngs , "w+")
    local code_plists = io.open(r_code_plist , "w+")
    local code_fnt = io.open(r_code_fnt , "w+")
    local plist_lines = io.open(r_code_line_plist , "w+")
    local fnt_lines = io.open(r_code_line_fnt , "w+")
    local code_file_texture = {}                                -- 存储代码文件中的png图
    local code_file_plist = {}
    for _,path in pairs(files) do
        local file = io.open(path, "r")
        for line in file:lines() do
            if string.find(line,".png") then -- 找到json中所有的png的行
                assert(image_lines:write(line , "\n"))
                self:matchstr(code_pngs,line,code_file_texture , "[\"]([%w%.%-%s_/]*.png)[\"]")
            end

            if string.find(line , ".plist") then
                assert(plist_lines:write(line , "\n"))
                self:matchstr(code_plists,line,code_file_plist , "[\"]([%w%.%-%s_/]*.plist)[\"]")
            end

            if string.find(line , ".fnt") then  -- 字体文件
                assert(fnt_lines:write(line , "\n"))
                self:matchstr(code_fnt,line,code_file_plist , "[\"]([%w%.%-%s_/]*.fnt)[\"]")
            end
        end
        io.close(file)
    end
    io.close(image_lines)
    io.close(code_pngs)
    io.close(code_plists)
    io.close(plist_lines)
    io.close(code_fnt)
    io.close(fnt_lines)
    print("----------- code file has png num : " .. #code_file_texture)
    print("----------- code file has plist num : " .. #code_file_plist)

    self:replacePattern(r_code_plist,".plist",".png")
    self:replacePattern(r_code_fnt,".fnt",".png")
end

-- 匹配包含png的 行的内容
function MainScene:matchstr(recordfile , line ,tab , pattern)
    for str in string.gmatch(line ,pattern) do  -- 一行中有可能存在多个png的情况
        if self:uniqInsert(tab,str) then
            recordfile:write(str,"\n")
        else
            -- print("repeat code path : " .. str)
        end
    end
    -- self:printCantMatchline(pattern , line)
end

-- 输出无法捕获的样式
function MainScene:printCantMatchline(pattern , line)
    if not string.match(line , pattern) then
        print("pattern dif : " .. line) -- 目标模式匹配不到的行则打印出来
    end
end

-- 得到文件的行数
function MainScene:getFileLinsNum(file)
    local file = io.open(path , "w")
    if file then
        local num = 0
        for line in file:lines() do
            num = num + 1
        end
        io.close(file)
    end
end

-- 修改文件内容,直接对文件流修改会发生什么事
function MainScene:replacePattern(path , pattern , replace)
    local files = {}
    for line in io.lines(path) do
        if string.match(line,pattern) then      -- 有可能一行有多个plist的情况出现
            -- print(line)
            line = string.gsub(line, pattern , replace)
            -- print(line)
        end
        table.insert(files , line)
    end
    local file2 = io.open(path, "w+")              -- 存储在新的位置，或者直接改变原来的文件
    for _,v in pairs(files) do
        file2:write(v,"\n")                        -- 将修改后的内容逐行写入到文件中
    end
    io.close(file2)
end

-- 将文件中的内容存储到table中
function MainScene:fileSaveToTable(path)
    local tab = {}
    local file = io.open(path , "r")
    assert(file)
    for line in file:lines() do
        table.insert(tab , line)
    end
    print("------------ path : " .. path  .." " .. " num : " .. #tab)
    return tab
end

-- 字母大小写不同也不相等 adverView_page 和 adverview_page 字母v不同大小写
function MainScene:hasEqualValue(tab1,tab2)
    for _,v in pairs(tab1) do
        for _ , _v in pairs(tab2)do
            -- print("v1 :" .. v .. " v2: " .. _v)
            if v == _v then
                print("[ Tips ] has equal value : " .. v)
                return true
            end
        end
    end
    return false
end

-- 表中是否包含某个值
function MainScene:hasValueInTab(tab , value)
    for _,v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end

-- 表中是否包含某个键
function MainScene:hasKeyInTab(tab , key)
    for k , _ in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end

-- 去重插入
function MainScene:uniqInsert(tab , value)
    for _,v in pairs(tab)do
        if value == v then
            -- print("-------repeat value :" .. tostring(value))
            return false
        end
    end
    table.insert(tab,value)
    return true
end

-- 根据切割符(flag)切割字符串str
function MainScene:cutStrByFlag( str, flag)
    local ts = string.reverse(str)
    local b = string.find(ts, flag)
    local len = string.len( str )
    return string.sub(str, len-b+2, len)
end

-- 裁切匹配内容的字符串
function MainScene:cutStrByStr(str,curstr)
    return string.sub(str , 1 , string.find(str , curstr) - 1)
end

-- 读取文件中所有内容
function MainScene:readFile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

-- 写入内容到文件
function MainScene:writeFile(path, content, mode)
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
function MainScene:fileExists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

-- 读取并输出文件每一行内容
function MainScene:readFileByLine(path)
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

function MainScene:test()
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
function MainScene:testCutString()
    -- 从字符串中裁切出最后的图片文件名
    local str = "D:\\Svn_2d\\S_Trunk_GD_Dev\\res\\hall\\yaoqing\\pro_front.png"
    local str2 = self:cutStrByFlag(str , "\\")
    local str3 = self:cutStrByStr(str2,".png")
    -- print(str3)
end

-- 读取行内容
function MainScene:testReadLine()
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
function MainScene:charSetText()
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
function MainScene:operatePathAndFile()
    local path = "res/aaa"
    lfs.mkdir(path) -- 创建路径的，创建文件要使用io.open的方式来

    local file1 = io.open("res/aaa/ccc.txt" , "a+")   -- 可以在已经存在的目录中创建文件
    file1:write("cccc","\n")
    io.close(file1)

    os.remove("res/aaa/ccc.txt") -- 删除文件
    lfs.rmdir(path)  -- 里面有文件则删除不掉路径
end

-- 读取图片尺寸
function MainScene:limage(path,typed)
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
function MainScene:seekUser()
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

function MainScene:LuaCommand()
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

return MainScene
