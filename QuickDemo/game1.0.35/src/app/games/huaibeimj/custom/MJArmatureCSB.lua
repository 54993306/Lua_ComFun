--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
MJArmatureCSB = class("MJArmatureCSB")
local mjACSB = nil

MJArmatureCSB.getInstance = function()
    if mjACSB == nil then
        mjACSB = MJArmatureCSB.new()
    end
    return mjACSB
end

MJArmatureCSB.removeInstance = function()
    if MJArmatureCSB.getInstance then
        MJArmatureCSB.getInstance():dtor()
    end
    mjACSB = nil
end

function MJArmatureCSB:ctor()
--    local armatureName = string.format("%s/%s.csb",pathName,fileName)
end
function MJArmatureCSB:addArmatureFileInfo(pathName)
    local pN = string.gmatch(pathName,"%P+")
    local fileName = ""
    local gMatch = {}
    for w in pN do
        gMatch[#gMatch+1] = w
    end
    for i,v in pairs(gMatch) do
        if i == #gMatch-1 then
            fileName = v
        end
    end
--    Log.i("------fileName", fileName);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(pathName)
    self._fileName = fileName
    self._time = 0
end
function MJArmatureCSB:createArmature()
    self._armature = ccs.Armature:create(self._fileName)
    return self._armature
end
function MJArmatureCSB:getAnimation()
    return  self._armature:getAnimation()
end
function MJArmatureCSB:playEnd()
    if self._armature~= nil then
        self._armature:removeFromParent(true)
        self._armature = nil
    end
end

function MJArmatureCSB:play(armatureName)
    self:playEnd()
   if self._armature == nil then
        self:createArmature()
   end
    self._armature:getAnimation():play(armatureName)
    return self._armature
end
function MJArmatureCSB:getArmature()
    return self._armature
end
function MJArmatureCSB:playWithIndex(index)
    if self._armature == nil then
        self:createArmature()
    end
    self:getAnimation():playWithIndex(index)
    return self._armature
end
--vectorNames   const std::vector<std::string>& vectorNames
function MJArmatureCSB:playNames(vectorNames)
    if self._armature == nil then
        self:createArmature()
    end
    self:getAnimation():playWithNames(vectorNames)
    return self._armature
end
--indexes   const std::vector<int>& movementIndexes
function MJArmatureCSB:playWithIndexes(indexes)
    if self._armature == nil then
        self:createArmature()
    end
    self:getAnimation():playWithIndexes(indexes)
    return self._armature
end
function MJArmatureCSB:pause()
    self:getAnimation():pause()
end
function MJArmatureCSB:resume()
    self:getAnimation():resume()
end
function MJArmatureCSB:stop()
    self:getAnimation():stop()
end
function MJArmatureCSB:setRestoreOriginalTime(time) 
    self._armature:performWithDelay(function()
            self:playEnd();
            
        end, time);
end
return MJArmatureCSB
--endregion
