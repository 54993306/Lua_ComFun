
require "lfs"  

local json = require("framework.json")
-- local model2 = ...

local crypto = require "framework.crypto"
-- local crypto = import (... , "app.framework.crypto")
-- local crypto = model(model2 , "app.framework.crypto")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

-- 是否记录到文件中
local RECORD_IN_FILE = true
-- json 文件路径
local s_json_path = "D:\\Svn_2d\\UI_Shu\\Json"     -- 斜杠是转义符，表示后面的斜杠是斜杠本身 
-- csb 文件路径
local s_csb_path = "D:\\Svn_2d\\S_Resource_GD\\res\\hall"  -- 反斜杠
-- Ui图片位置
local s_FolderTexturePath = "D:\\Svn_2d\\UI_Shu\\Resources"
-- 项目图片位置
local s_ProjectTextures = "D:\\Svn_2d\\S_Resource_GD\\res\\hall"
-- 记录文件夹中图片md5值
local s_Fodel_MD5 = "res\\fodel_md5.txt"
-- 记录json中包含的图片信息
local s_Json_Pngs = "res\\json_pngs.txt"
-- 记录从json文件中截取出来的图片路径
local s_json_image_path = "res\\json_image_path.txt"
-- 记录json中去重后的路径
local s_json_uniq_path = "res\\json_uniq_path.txt"
-- 记录文件夹中所有的图片路径
local s_Fodel_Image_Path = "res\\fodel_image_path.txt"
-- 记录文件夹中重复的图片路径
local s_Fodel_Repeat_Image = "res\\fodel_repeat_image.txt"
-- 代码路径
local s_code_path = "D:\\Svn_2d\\S_Resource_GD\\src"
-- 记录代码中包含png行内容
local s_code_include_png_path = "res\\code_include_png_path.txt"
-- 记录代码中png的路径
local s_code_png_path = "res\\code_png_path.txt"

-- 比较json和csb文件表的差异，找出差异项,json和csb应该是一一对应的
function MainScene:compareFile()
    local Json_unEqual = {}
    local num = 0
    for _,v in pairs(self.tab_json_FileName) do
        if not self:hasValueInTab(self.tab_csb, v) then
            num = num + 1
            self:uniqInsert(Json_unEqual , v)
        end
    end
    for _,v in pairs(Json_unEqual) do
        print(v)
    end
    print("------------------unEqual json : " .. num)

    local Csb_unEqual = {}
    num = 0
    for _,v in pairs(self.tab_csb) do
        if not self:hasValueInTab(self.tab_json_FileName, v) then
            num = num + 1
            self:uniqInsert(Csb_unEqual , v)
        end
    end
    for _,v in pairs(Csb_unEqual) do
        print(v)
    end
    print("-------------------unEqual csb : " .. num)

    self:hasEqualValue(Json_unEqual,Csb_unEqual)
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

-- 初始化json和csb文件名表
function MainScene:initFileNameTable()
    -- json 文件
    local num = 0
    for file in lfs.dir(s_json_path) do
        local b = string.find(file, ".json")
        if b then
            table.insert(self.tab_json_FileName,string.sub( file, 1, b-1))
            num = num + 1
        end
        -- print(file)
    end
    print("------- json file num : " .. num)
    
    -- csb 文件
    num = 0
    for file in lfs.dir(s_csb_path) do
        local b = string.find(file, ".csb")
        if b then
            table.insert(self.tab_csb,string.sub( file, 1, b-1))
            num = num + 1
        end
        -- print(file)
    end
    print("------- csb file num :" .. num)
end

-- 判断去重后的情况
function MainScene:judgeUniq(tab , uniqtab)
    local succeed = true
    for _,v in pairs(tab) do
        local hasstr = true
        for _,v2 in pairs(uniqtab) do
            if v == v2 then
                hasstr = false
            end
        end
        if hasstr then
            print("[ ERROR ] uniq failed ... " .. v)
            succeed = false
        end
    end
    return succeed
end

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
    -- crypto = require "app.framework.crypto"
    self.tab_json_FileName = {}     -- json文件名表  ， 接上路径和json可得到完整json路径

    self.tab_csb = {}               -- csb文件名表

    self.textureFiles = {}   -- 指定路径下所有的图片表,存储的是绝对路径

    self.fodelTextureMd5 = {} -- 存在文件夹下图片的md5值

    self.repeatTextures = {}    -- 存储指定路径下重复的图片资源路径

    self.json_contain_texture = {} -- json中包含png的字符串表

    self.json_texture = {}      -- 存储去重后json中所使用的所有图片

    self.code_file_texture = {} -- 存储代码文件中的png图

    self.deleteFiles = {}        -- 多余的文件

    -- self:initCodeFilePngs()     -- 初始化代码文件中包含的png

    self:matchCodePng()         -- 捕获代码文件中的png内容

    -- self:initFileNameTable()  -- 初始化json和csb文件名表

    -- self:compareFile()  -- 比较csb文件和json文件的差异

    -- self:initTextures()

    -- self:surplusTexture() -- 比较json中纹理和文件夹中纹理的差异，查找多余的图片md5 比较,直接比较路径更直接

    -- self:initDeleteFiles()

    -- self:test()
end

-- 目录下的所有文件存入pathes中
function MainScene:getpaths(rootpath, pathes , pattern)
    pathes = pathes or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath..'\\'..entry
            local attr = lfs.attributes(path)
            assert(type(attr) == 'table')
            if attr.mode == 'directory' then
                self:getpaths(path, pathes , pattern)
            else
                if string.find(path,pattern or ".png") then
                    table.insert(pathes, path)
                end
            end
        end
    end
    return pathes
end

-- 初始化将要删除的图片
function MainScene:initDeleteFiles()
    local str = ""
    for _,fodelpath in pairs(self.textureFiles) do
        str = string.gsub(fodelpath ,"\\" , "/" )
        str = string.match(str , "hall/([%w%-%._/%s]*.png)")
        if not str then
            print(" -----------error line " .. fodelpath )
        else
            -- print("fodel path : " .. str)
            -- print("delete fodel path : " .. fodelpath)
        end
        local surplus = true
        -- 判断在json文件中是否使用
        for _,jsonpng in pairs(self.json_texture) do
            if str == jsonpng then
                surplus = false
            end
        end
        -- 判断在代码中是否使用
        if surplus then
            -- 判断在代码中是否同样不存在该文件
            for _,codepng in pairs(self.code_file_texture) do
                if codepng == str then
                    surplus = false
                end
            end
        end

        if surplus then
            table.insert(self.deleteFiles , fodelpath)
        end
    end
    -- for _,jsonpng in pairs(self.json_texture) do
    --     print("json path : " .. jsonpng)
    -- end
    print(" ----------- delete file num :" .. #self.deleteFiles)
end

-- 初始化纹理文件表
function MainScene:initTextures()
    self:initFolderTexture()
    self:initJsonTexture()
end

-- 初始化json文件中的纹理文件表
function MainScene:initJsonTexture()
    -- dump(self.tab_json_FileName)
    local recordfile = io.open(s_Json_Pngs, "w+")
    local json_image_file = io.open(s_json_image_path,"w+")
    local json_uniq_path = io.open(s_json_uniq_path , "w+")
    for _,path in pairs(self.tab_json_FileName) do
        local _path = s_json_path .."\\".. path .. ".json"
        local file = io.open(_path, "r")
        if file then
            local linenum = 0
            for line in file:lines() do 
                linenum = linenum + 1
                if string.find(line,".png") and not string.find(line,":\\")then -- 找到json中所有的png的行
                    if recordfile:write(line , "\n") == nil then 
                        print("----- err write file initJsonTexture")
                        return
                    end                
                    self:matchPngPath(json_image_file,json_uniq_path,line)
                end
                -- print(line)
            end
            io.close(file)
        end
    end
    io.close(json_image_file)
    io.close(recordfile)
    io.close(json_uniq_path)
    print("----------- json has png : " .. #self.json_contain_texture)

    if self:judgeUniq(self.json_contain_texture,self.json_texture) then
        print(" ----------- uniq json png num : " .. #self.json_texture)
    end
end

-- 匹配图片路径
function MainScene:matchPngPath(recordfile , uniqfile, line)
    local str = string.match(line , "[\"]([%w/_%.%s%-]*.png)[\"]")
    -- local str = string.match(line , "([%w/_%.]*.png)")
    if str then
        recordfile:write(str,"\n")  -- 匹配整个模式，但是从中截取出图片路径   
        table.insert(self.json_contain_texture,str)

        if self:uniqInsert(self.json_texture,str) then -- 去重后的路径
            uniqfile:write(str,"\n")
        else
            -- print(str)
        end
    else
        print("pattern dif : " .. line) -- 目标模式匹配不到的行则打印出来
    end
end

-- 初始化文件夹中的纹理文件表
function MainScene:initFolderTexture()
    local pathes = {}
    -- self:getpaths('.', pathes)  -- .表示当前文件
    self:getpaths(s_ProjectTextures, pathes)
    local md5file = io.open(s_Fodel_MD5, "w+")
    local pathfile = io.open(s_Fodel_Image_Path , "w+")
    local repeatfile = io.open(s_Fodel_Repeat_Image , "w+")
    for i = 1, #(pathes) do
        -- print(pathes[i])
        table.insert(self.textureFiles,pathes[i])
        local md5 = crypto.md5file(pathes[i])                   -- 名称不同但是图片相同，路径不同但是图片相同
        if self:uniqInsert(self.fodelTextureMd5 , md5) then
            md5file:write(md5 , "\n")
            pathfile:write(pathes[i] , "\n")
        else
            -- print(path)
            repeatfile:write(pathes[i] , "\n")  -- 用 ， 分隔内容与用 .. 连接内容效果一样，但是效率更高
            table.insert(self.repeatTextures,pathes[i])
        end
    end
    io.close(md5file)
    io.close(pathfile)
    io.close(repeatfile)
    print("----------- fodel all texture num : "..#(pathes))
    print("----------- repeat texture num : " .. #self.repeatTextures) -- 重复的文件可能在不同的地方用到了。
    print("----------- fodel uniq md5 num : " .. #self.fodelTextureMd5)
    -- dump(self.fodelTextureMd5)
end

-- 纹理文件比较
function MainScene:surplusTexture()

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
    local md2 = crypto.md5file("teg_examine.png")
    if md1 == md2 then
        -- print("--- file md5 equal")
    end

    -- self:charSetText()

    self:changeFile()

    -- self:operatePathAndFile()
end

-- 裁切字符串
function MainScene:testCutString()
    -- 从字符串中裁切出最后的图片文件名
    local str = "D:\\Svn_2d\\S_Resource_GD\\res\\hall\\yaoqing\\pro_front.png"
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

-- 修改文件内容,直接对文件流修改会发生什么事
function MainScene:changeFile()
    -- 读取json数据并输出
    -- local str4 = self:readFile("res\\aaa.json")  -- 读取文件时要注意路径，从src去读取是找不到的，需要加res。
    -- print(str4)
    -- local tb = json.decode(str4)
    -- dump(tb)
    -- self:readFileByLine("res\\aaa.json")

    -- "r+": 更新模式，所有之前的数据将被保存
    -- local file = io.open(path, "r")
    -- if file then
    --     for line in file:lines() do 
    --         print(line)
    --     end
    --     io.close(file)
    -- end
end

-- 初始化代码文件中的png表
function MainScene:initCodeFilePngs()
    local files = {}
    self:getpaths(s_code_path, files , ".lua")
    print("------------ lua files num : " .. #files )
    local recordfile = io.open( s_code_include_png_path , "w+")  -- s_code_png_path
    for _,path in pairs(files) do
        -- print(path)
        local file = io.open(path, "r")
        if not file then
            print("open file failed : " .. path)
            return
        end
        for line in file:lines() do 
            if string.find(line,".png") then -- 找到json中所有的png的行
                if recordfile:write(line , "\n") == nil then 
                    print("----- err write file initCodeFilePngs")
                    return
                end                
            end
        end
        io.close(file)
    end
    io.close(recordfile)
end

-- 捕获代码文件中的png路径
function MainScene:matchCodePng()
    local file = io.open( s_code_include_png_path , "r")  -- s_code_png_path
    local recorefile = io.open(s_code_png_path , "w+")
    if not file then
        print(" ------------  un have code png file ")
        return
    end
    local num = 0
    for line in file:lines() do 
        local str = string.match(line , "([%w%.%-%s_/]*.png)[\"]")
        if str then
            if self:uniqInsert(self.code_file_texture,str) then
                recorefile:write(str,"\n")
            else
                -- print("repeat code path : " .. str)
            end
        else
            -- print("un catch line : " .. line)
        end
    end
    io.close(file)
    io.close(recorefile)   -- 如果不调用该方法，有可能导致文件写入异常
    print("code png line : " .. num)
    print(" code file has png num : " .. #self.code_file_texture)
end

return MainScene