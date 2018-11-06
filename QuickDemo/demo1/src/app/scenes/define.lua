

-- 定义路径和常量文件

require "lfs"

-- 工程缺少图片时的报错内容
-- Get data from file(hall/friendRoom/img_queding.png) failed, error code is 3

-- ProjectPath = "S_Trunk_GD_Dev"
ProjectPath = "S_Trunk_GD"
ProjectPath = "H_HN_3.6.1"
-- ProjectPath = "S_JS_tishen"

-- json UI工程文件的路径
dir_json_path = "D:\\Svn_2d\\UI_Heng\\hall_change\\Json"

CommonPath = "res\\" -- 本工程的相对路径，可不用绝对路径
-- CommonPath = "D:\\Lua_ComFun\\QuickDemo\\demo1\\res\\"  -- 存储位置的绝对路径

RecordPath = CommonPath .. ProjectPath  -- 存储记录文件的路径
-----------------------------------------------------------------
-----------------------------------------------------------------

-- 存储资源文件夹内的所有资源文件列表
r_all_resource = RecordPath .. "\\all_resource.txt"
-- 文件夹中包含的资源类型和数量的json文件
r_resouce_type = RecordPath .. "\\resource_type.json"
-----------------------------------------------------------------
-----------------------------------------------------------------

-- csb 文件路径
dir_csb_path = "D:\\Svn_2d\\" .. ProjectPath .."\\res\\hall"
-- 代码 文件路径
dir_code_path = "D:\\Svn_2d\\" .. ProjectPath .."\\src"
-- 项目图片位置
dir_png_path = "D:\\Svn_2d\\" .. ProjectPath .."\\res\\hall"

-----------------------------------------------------------------
-----------------------------------------------------------------

-- record file num 15
-- 记录json文件路径
r_json_paths = RecordPath .. "\\json_path.txt"
-- 记录csb文件路径
r_csb_paths  = RecordPath .. "\\csb_path.txt"
-- 记录文件夹中图片md5值
r_Fodel_MD5 = RecordPath .. "\\fodel_md5.txt"
-- 记录json中包含的图片信息
r_json_image_lines = RecordPath .. "\\json_images_lines.txt"
-- 记录从json文件中截取出来的图片路径
r_json_pngs = RecordPath .. "\\json_pngs.txt"
-- 记录json中去重后的路径
r_json_pngs_uniq = RecordPath .. "\\json_pngs_uniq.txt"
-- 记录文件夹中所有的图片路径
r_fodel_Images = RecordPath .. "\\fodel_Images.txt"
-- 记录文件夹中重复的图片路径
r_fodel_Repeat_pngs = RecordPath .. "\\fodel_repeat_pngs.txt"
-- 记录代码中包含png行内容
r_code_line_pngs = RecordPath .. "\\code_line_pngs.txt"
-- 记录代码中png的路径
r_code_pngs = RecordPath .. "\\code_pngs.txt"
-- 记录代码中png的路径
r_code_Single_pngs = RecordPath .. "\\code_Single_pngs.txt"
-- 记录代码中包含plist行内容
r_code_line_plist = RecordPath .. "\\code_line_plist.txt"
-- 记录代码中plist的路径
r_code_plist = RecordPath .. "\\code_plist.txt"
-- 记录代码中fnt的路径
r_code_fnt = RecordPath .. "\\code_fnt.txt"
-- 记录代码中包含fnt行内容
r_code_line_fnt = RecordPath .. "\\code_line_fnt.txt"
-- 记录将要删除的图片路径
r_delete_pngs = RecordPath .. "\\delete_pngs.txt"
-- 记录手动筛查的行
r_hand_lines = RecordPath .. "\\hand_lines.txt"

-- 每次记录的时候，可以把注释的内容给截取掉。

-- 规则比较复杂，手动设置不删除的图片列表
-- 出现这些图片的位置，是需要对代码做修改的位置，统一好格式
M_DontDelete = {
"green_num_0.png" ,
"room_num_0.png" ,
"yellow_num_0.png" ,
"spin0.png" ,
"spin1.png" ,
"img_diamond.png" ,
"yuanbao.png",
"face0.png",
"face1.png",
"speaking.png",
"speaking_1.png",
"speaking_2.png",
"speaking_3.png",
"diamond_L.png",
"diamond_XL.png",
"diamond_XXL.png",
"clubfx0.png",
}

-- 不需要删除图片的文件
-- 出现这些图片的位置，是需要对代码做修改的位置，统一好格式
M_DontDeletePath = {
    "/friendRoom/mic/",
    "/armature_pic/",
}

-- D:/Svn_2d/S_Trunk_GD_Dev/res/hall/friendRoom/spin0.png
-- D:/Svn_2d/S_Trunk_GD_Dev/res/hall/friendRoom/spin1.png
-- self.speakingImg:loadTexture("hall/friendRoom/speaking_"..self.speaking_img_index..".png");
-- paiMingImage:loadTexture("hall/ranking/bai_"..tmpData.ra..".png");

-- 创建存储路径
local function createRecordPath()
    local attr = lfs.attributes( RecordPath )
    if not attr then
        lfs.mkdir(RecordPath)
        attr = lfs.attributes( RecordPath )
        assert(type(attr) == 'table')
    end
end

createRecordPath()
