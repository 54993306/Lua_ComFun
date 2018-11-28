
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

require "app.scenes.define"

local resource = require "app.scenes.resource"

local tools = require "app.scenes.tools"

local crypto = require "framework.crypto"

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- tools:ctor()

    -- resource:ctor()

    -- self:initDeleteFile()

    -- self:excuteDeleteFile()

    local languageString = { }


    languageString.Lxc_DDZ =
    {
        ddzrule1d = "游戏规则",
    }

    print("string : " .. languageString.Lxc_DDZ.ddzrule1d)
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

-- 初始化将要删除的图片
function MainScene:initDeleteFile()
    self:initJsonAndCsbFile()

    self:initTextures()
    local str = ""
    local delete_path = io.open(r_delete_pngs, "w+")
    local textures = tools:fileSaveToTable(r_fodel_Images)           -- 所有图片
    local json_pngs = tools:fileSaveToTable(r_json_pngs_uniq)        -- json中包含的图片
    local code_pngs = tools:fileSaveToTable(r_code_pngs)             -- 代码中包含的图片
    local code_plist = tools:fileSaveToTable(r_code_plist)           -- 代码中包含的plist
    local code_fnt = tools:fileSaveToTable(r_code_fnt)               -- 代码中包含的fnt
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

        if surplus then  -- 直接以文件名来间判断
            for _,png in pairs(M_DontDelete) do
                if png == string.match(fodelpath , "[/\\]([%w%-%._%s]*.png)") then
                    surplus = false  -- 判断在代码中是否使用
                    print("-------not delete " , string.match(fodelpath , "[/\\]([%w%-%._%s]*.png)"))
                end
            end
        end

        if surplus then  -- 直接以文件名来间判断
            for _,png in pairs(M_DontDeletePath) do
                if string.find(fodelpath , png ) then
                    surplus = false  -- 判断在代码中是否使用
                    print("-------not deletepath file " , fodelpath)
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
    tools:initPaths(dir_png_path, files)
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
    tools:initPaths(dir_code_path, files , ".lua")
    print("------------ lua files num : " .. #files )
    local image_lines = io.open( r_code_line_pngs , "w+")
    local code_pngs = io.open(r_code_pngs , "w+")
    local code_single_pngs = io.open(r_code_Single_pngs , "w+")
    local code_plists = io.open(r_code_plist , "w+")
    local code_fnt = io.open(r_code_fnt , "w+")
    local plist_lines = io.open(r_code_line_plist , "w+")
    local fnt_lines = io.open(r_code_line_fnt , "w+")
    local hand_lines = io.open(r_hand_lines , "w+")
    local code_file_texture = {}                                -- 存储代码文件中的png图
    local code_file_plist = {}
    local code_Single_pngs = {}
    for _,path in pairs(files) do
        local file = io.open(path, "r")
        for line in file:lines() do
            if string.find(line,".png") then -- 找到json中所有的png的行
                assert(image_lines:write(line , "\n"))
                self:matchstr(code_pngs,line,code_file_texture , "[\"]([%w%.%-%s_/]*.png)[\"]")
                self:matchstr(code_single_pngs,line,code_Single_pngs , "([%w%s_]+.png)[\"]")
                if string.find(line , "%.%.") or string.find(line , "%%s") then -- 包含.png和连接符的行要单独抽出来手工判断
                    -- 可以排除掉一些路径，上次筛查过的内容可以屏蔽掉。如果是已经被筛查过则不再显示出来
                    hand_lines:write(string.gsub(line," ","") ,"\n")
                end
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
    io.close(code_single_pngs)
    io.close(hand_lines)
    print("----------- code file has png num : " .. #code_file_texture)
    print("----------- code file has plist num : " .. #code_file_plist)
    print("----------- code file has single png num : " .. #code_Single_pngs)

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

return MainScene
