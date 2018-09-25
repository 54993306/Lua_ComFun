
--

local tools = require "app.scenes.tools"

local resource = {}

-- 初始化类的功能
function resource:ctor()
    self:initFodelInfo()
end

-- 输出文件夹内所包含的文件类型和对应的文件数量json文档
-- 资源的使用，分为两个部分，一个在代码中，一个在UI编辑器中。
-- 资源的分类，有图片，声音，动画，字体等。
-- 在UI编辑器中可能使用的图片资源类型有图片和字体两种。
function resource:initFodelInfo()
    local files = {}
    -- 获取所有的文件
    tools:initPaths(dir_png_path , files ,"%w")
    -- 移除不是资源的文件
    tools:removeIncludePattern(files , "[\\/].svn[\\/]")
    -- 将所有的资源文件写入文件
    tools:writeTabToFile(files, r_all_resource)
    -- 将资源分类计数并记录到json文件中
    print("-------------resource file num : " .. #files)
    tools:initResourceTypeNum(files , r_resouce_type)
end


return resource
