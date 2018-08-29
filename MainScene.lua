
require "lfs"  

local json = require("framework.json")
-- local model2 = ...

local crypto = require "framework.crypto"
-- local crypto = import (... , "app.framework.crypto")
-- local crypto = model(model2 , "app.framework.crypto")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

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


-- 比较json和csb文件表的差异，找出差异项
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

    self:initFileNameTable()  -- 初始化json和csb文件名表

    -- self:compareFile()  -- 比较csb文件和json文件的差异

    self.textureFiles = {}   -- 指定路径下所有的图片表

    self.fodelTextureMd5 = {} -- 存在文件夹下图片的md5值

    self.repeatTextures = {}    -- 存储指定路径下重复的图片资源路径

    self.json_contain_texture = {} -- json中包含png的字符串表

    self.json_texture = {}      -- 存储json中所使用的所有图片

    self:initTextures()

    self:compareTexture() -- 比较json中纹理和文件夹中纹理的差异，查找多余的图片

    self:test()
end

-- 获取当前目录下的所有文件存入pathes中
function MainScene:getpaths(rootpath, pathes)
    pathes = pathes or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath..'\\'..entry
            local attr = lfs.attributes(path)
            assert(type(attr) == 'table')
            if attr.mode == 'directory' then
                self:getpaths(path, pathes)
            else
                if string.find(path,".png") then
                    table.insert(pathes, path)
                end
            end
        end
    end
    return pathes
end

-- 初始化纹理文件表
function MainScene:initTextures()
    self:initFolderTexture()
    self:initJsonTexture()
end

-- 初始化json文件中的纹理文件表
function MainScene:initJsonTexture()
    -- dump(self.tab_json_FileName)
    local recordfile = io.open(s_Json_Pngs, "w+b")
    for _,path in pairs(self.tab_json_FileName) do
        local _path = s_json_path .."\\".. path .. ".json"
        local file = io.open(_path, "r")
        if file then
            for line in file:lines() do 
                if string.find(line,".png") and not string.find(line,"C:\\")then
                    if recordfile:write(line .. "\n") == nil then 
                        print("----- err write file initJsonTexture")
                        return
                    end
                    table.insert(self.json_contain_texture,line)
                end
                -- print(line)
            end
            io.close(file)
        end
    end
    io.close(recordfile)
    print("----------- json has png : " .. #self.json_contain_texture)
end

-- 初始化文件夹中的纹理文件表
function MainScene:initFolderTexture()
    local pathes = {}
    -- self:getpaths('.', pathes)  -- .表示当前文件
    self:getpaths(s_ProjectTextures, pathes)
    local recordfile = io.open(s_Fodel_MD5, "w+b")
    for i = 1, #(pathes) do
        -- print(pathes[i])
        table.insert(self.textureFiles,pathes[i])
        local md5 = crypto.md5file(pathes[i])
        if self:uniqInsert(self.fodelTextureMd5 , md5) then
            recordfile:write(md5 .. "\n")
        else
            -- print(path)
            table.insert(self.repeatTextures,pathes[i])
        end
    end
    io.close(recordfile)
    print("----------- repeat texture num : " .. #self.repeatTextures)
    print("----------- fodel texture num : "..#(pathes))
    print("----------- md5 num : " .. #self.fodelTextureMd5)
    -- dump(self.fodelTextureMd5)
end

-- 纹理文件比较
function MainScene:compareTexture()

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
    -- 从字符串中裁切出最后的图片文件名
    local str = "D:\\Svn_2d\\S_Resource_GD\\res\\hall\\yaoqing\\pro_front.png"
    local str2 = self:cutStrByFlag(str , "\\")
    local str3 = self:cutStrByStr(str2,".png")
    -- print(str3)

    -- 读取json数据并输出
    local str4 = self:readFile("res\\aaa.json")  -- 读取文件时要注意路径，从src去读取是找不到的，需要加res。
    -- print(str4)
    local tb = json.decode(str4)
    -- dump(tb)
    -- self:readFileByLine("res\\aaa.json")

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
    self:charSetText()
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
    -- bb,dd = string.find(ee , "[\"][%w/_%.]*[\"]")  --
    bb,dd = string.find(strmatch , "[%w/_%.]*.png")  --
    local str222 = string.sub(strmatch , bb , dd )      
    if bb and dd then
        print("------" .. bb .. " " .. dd .. " str: " .. str222)
    end
end