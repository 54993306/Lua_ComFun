--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.huaibeimj.mediator.game.Define"
local PlayerFlowNode = class("PlayerFlowNode",function ()
	return display.newNode()
end)
function PlayerFlowNode:ctor(site)
    self.m_site = site
end

function PlayerFlowNode:showFlow(flower)
    
    local pos = self.m_site
    local flowerIndex = self:getFlowerIndex()
    local flowerNumber = #flowerIndex
--    Log.i("哪个玩家..",pos,"flowerNumber...",flowerNumber,"#flower..",#flower,"花..",flower,"flowerIndex...",flowerIndex)
    if #flower <= flowerNumber then
        return
    end
    
    if flowerNumber == 0 then
        if #flower > 1 then
            table.sort(flower, function(a,b) return a<b end )
        end
    end
--    local flowers = flower
--    for i, v in pairs(flower) do
--        if v == nil or v <50 or v > 59 then
--            Log.i("花为空 或者花不在范围内...",v)
--            table.remove(flower,i)
--        end
--        local flowers = flower
--        for j,k in pairs(flowers) do
--            if j > 1 then
--                if k == flowers[j-1] then
--                    Log.i("已经有一张相同的花了...",k)
--                    table.remove(flower,i)
--                end
--            end
--        end
--    end
    if flower == nil or #flower <= 0 then
        Log.i("传入花的数量为零")
        return
    end
    for i= flowerNumber+1,#flower do
        if pos == 1 then
            self:myFlowAction(flower,flowerIndex,flowerNumber,i)
        elseif pos == 2 then
            self:rightFlow(flower,flowerIndex,flowerNumber,i)
        elseif pos == 3 then
            self:otherFlow(flower,flowerIndex,flowerNumber,i)
        elseif pos == 4 then
            self:leftFlow(flower,flowerIndex,flowerNumber,i)
        end
        self:setFlowerIndex(flower[i])
    end
    
--    if flowerNumber < #flower then
        
--    end
end

function PlayerFlowNode:myFlowAction(flower,flowerIndex,flowerNumber,i)
    Log.i("myFlowAction....",flower,"index...",i,"flowerNumber...",flowerNumber)
    local flowerPng = self:getFlowerPng(flower[i])
    if flowerPng == nil then
        return
    end
    local flowSp = display.newSprite(flowerPng)
    local flowSize = flowSp:getContentSize()
    flowSp:setTag(flower[i])
    flowSp:addTo(self)
    flowSp:setOpacity(0)
    flowSp:runAction(cc.FadeIn:create(1))
    local spacing = 5
    local yPre = 0
    local isFlowInst = 0
    if flowerNumber > 0 then
        for j,v in pairs(flowerIndex) do
            local flow_val = self:getChildByTag(v)
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if flower[i]<v then
                if isFlowInst == 0 then
                    flowSp:setPosition(cc.p(flow_x,flow_y))
                    
                    isFlowInst = 1
                end
                if j ~= 4 then
                    flow_val:runAction(cc.MoveBy:create(0.1,cc.p(flowSize.width+spacing,0)))
                else
                    flow_val:runAction(cc.MoveTo:create(0.1,cc.p(flowSize.width+spacing,yPre+spacing+flowSize.height)))
                end
            end
        end
        if flower[i] > flowerIndex[flowerNumber] then
            local flow_val = self:getChildByTag(flowerIndex[flowerNumber])
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if #flowerIndex ~= 4 then
                flowSp:setPosition(cc.p(flow_x+spacing+flowSize.width,flow_y))
            else
                flowSp:setPosition(cc.p(spacing+flowSize.width,yPre+spacing+flowSize.height))
            end
            flowSp:setOpacity(0)
            flowSp:runAction(cc.FadeIn:create(1))
        end
--        if i < #flower then
--            table.insert(flowerIndex,flower[i])
--            table.sort(flowerIndex, function(a,b) return a<b end )
--            self:setFlowerIndex(flowerIndex)
--            self:showFlow(flower)
--            return
--        end
    else
        if i < 5 then
            flowSp:setPosition(cc.p((flowSize.width+spacing)*(i-1)+flowSize.width+spacing,yPre))
        else
            flowSp:setPosition(cc.p((flowSize.width+spacing)*(i-5)+flowSize.width+spacing,yPre+spacing+flowSize.height))
        end
    end
end
function PlayerFlowNode:rightFlow(flower,flowerIndex,flowerNumber,i)
    Log.i("myFlowAction....",flower,"index...",i,"flowerNumber...",flowerNumber)
    local flowerPng = self:getFlowerPng(flower[i])
    if flowerPng == nil then
        return
    end
    local flowSp = display.newSprite(flowerPng)
    local flowSize = flowSp:getContentSize()
    flowSp:setTag(flower[i])
    flowSp:addTo(self)
    flowSp:setOpacity(0)
    flowSp:runAction(cc.FadeIn:create(1))
    local spacing = 5
    local xPos = Define.visibleWidth/18
    local xPre = -20
    local yPos = Define.visibleHeight/8
    local isFlowInst = 0
    if flowerNumber > 0 then
        local isFlowInst = 0
        for j,v in pairs(flowerIndex) do
            local flow_val = self:getChildByTag(v)
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if j ~= 4 then
                if flower[i]>v then
                    if flowerNumber < 4 or (flowerNumber>4 and j > 4 ) then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        flow_val:runAction(cc.MoveBy:create(0.1,cc.p(0,flowSize.height+spacing)))
                    end
                end
                if flower[i] < v then
                    if flowerNumber >= 4 then
                        if isFlowInst == 0 then
                            if flowerNumber < 4 or(flowerNumber > 4 and j > 4) then
                                flowSp:setPosition(cc.p(flow_x,flow_y+flowSize.height + spacing))
                            else
                                flowSp:setPosition(cc.p(flow_x,flow_y))
                            end
                            isFlowInst = 1
                        end
                        if j < 4 then
                            flow_val:runAction(cc.MoveBy:create(0.1,cc.p(0,-(flowSize.height+spacing))))
                        end
                    else
                        if isFlowInst == 0 then
                            flowSp:setPosition(cc.p(flow_x,flow_y+flowSize.height+spacing))
                            isFlowInst = 1
                        end
                    end
                end
            else
                if flower[i] < v then
                    if isFlowInst == 0 then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        isFlowInst = 1
                    end
                        flow_val:runAction(cc.MoveBy:create(0.1,cc.p(-(flowSize.width+spacing),(flowSize.height+spacing)*(flowerNumber-4))))
                end
                if flower[i] > v then
                     if flowerNumber < 4 or(flowerNumber > 4 and j > 4) then
                        flowSp:setPosition(cc.p(flow_x-(flowSize.width+spacing),flow_y+flowSize.height+spacing))
                    else
                        flowSp:setPosition(cc.p(flow_x-(flowSize.width+spacing),flow_y))
                    end
                end
            end
         end
    else
        if i < 5 then
            if #flower < 4 then
                flowSp:setPosition(cc.p(xPre-xPos,(flowSize.height+spacing)*(#flower-i)-yPos))
            else
                flowSp:setPosition(cc.p(xPre-xPos,(flowSize.height+spacing)*(4-i)-yPos))
            end
        else
            flowSp:setPosition(cc.p(xPre-flowSize.width-spacing-xPos,(flowSize.height+spacing)*(#flower-i)-yPos))
        end
    end
end
function PlayerFlowNode:otherFlow(flower,flowerIndex,flowerNumber,i)
    Log.i("myFlowAction....",flower,"index...",i,"flowerNumber...",flowerNumber)
    local flowerPng = self:getFlowerPng(flower[i])
    if flowerPng == nil then
        return
    end
    Log.i("flowerPng...",flowerPng)
    local flowSp = display.newSprite(flowerPng)
    local flowSize = flowSp:getContentSize()
    flowSp:setTag(flower[i])
    flowSp:addTo(self)
    flowSp:setOpacity(0)
    flowSp:runAction(cc.FadeIn:create(1))
    local spacing = 5
    local yPre = 20
    local xPos = 80
    local isFlowInst = 0
    if flowerNumber > 0 then
        for j,v in pairs(flowerIndex) do
            local flow_val = self:getChildByTag(v)
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if j ~= 4 then
                if flower[i] > v then
                    if flowerNumber < 4 or (flowerNumber > 4 and j > 4) then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        flow_val:runAction(cc.MoveBy:create(0.1,cc.p(-(flowSize.width+spacing),0)))
                    end
                end
                if flower[i] < v then
                    if flowerNumber >= 4 then
                        if isFlowInst == 0 then
                            if flowerNumber < 4 or(flowerNumber > 4 and j > 4) then
                                flowSp:setPosition(cc.p(flow_x-flowSize.width-spacing,flow_y))
                            else
                                flowSp:setPosition(cc.p(flow_x,flow_y))
                            end
                            isFlowInst = 1
                        end
                        if j < 4 then
                            flow_val:runAction(cc.MoveBy:create(0.1,cc.p(flowSize.width+spacing,0)))
                        end
                    else
                        if isFlowInst == 0 then
                            flowSp:setPosition(cc.p(flow_x-flowSize.width-spacing,flow_y))
                            isFlowInst = 1
                        end
                    end
                end
            else
                if flower[i] < v then
                    if isFlowInst == 0 then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        isFlowInst = 1
                    end
                        flow_val:runAction(cc.MoveBy:create(0.1,cc.p(-(flowSize.width+spacing)*(flowerNumber-4),-(flowSize.height+spacing))))
                end
                if flower[i] > v then
                    flowSp:setPosition(cc.p(flow_x,flow_y-(flowSize.height+spacing)))
                end
            end
        end
    else
        if i < 5 then
            if #flower > 4 then
                flowSp:setPosition(cc.p(-(flowSize.width+spacing)*(4-i)-xPos,0))
            else
                flowSp:setPosition(cc.p(-(flowSize.width+spacing)*(#flower-i)-xPos,0))
            end
        else
            flowSp:setPosition(cc.p(-(flowSize.width+spacing)*(#flower-i)-xPos,-(spacing+flowSize.height)))
        end
    end
end
function PlayerFlowNode:leftFlow(flower,flowerIndex,flowerNumber,i)
    Log.i("myFlowAction....",flower,"index...",i,"flowerNumber...",flowerNumber)
    local flowerPng = self:getFlowerPng(flower[i])
    if flowerPng == nil then
        return
    end
    Log.i("flowerPng...",flowerPng)
    local flowSp = display.newSprite(flowerPng)
    local flowSize = flowSp:getContentSize()
    flowSp:setTag(flower[i])
    flowSp:addTo(self)
    flowSp:setOpacity(0)
    flowSp:runAction(cc.FadeIn:create(1))
    local spacing = 5
    local yPre = 20
    local xpos = Define.visibleWidth / 15
    local isFlowInst = 0
    local yPos = Define.visibleHeight/5
    if flowerNumber > 0 then
        for j,v in pairs(flowerIndex) do
            local flow_val = self:getChildByTag(v)
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if j ~= 4 then
                if flower[i] < v then
                    if isFlowInst == 0 then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        isFlowInst = 1
                    end
                    flow_val:runAction(cc.MoveBy:create(0.1,cc.p(0,-(flowSize.height+spacing))))
                end
            else
                if flower[i] < v then
                    if isFlowInst == 0 then
                        flowSp:setPosition(cc.p(flow_x,flow_y))
                        isFlowInst = 1
                    end
                    flow_val:runAction(cc.MoveTo:create(0.1,cc.p(spacing+flowSize.width/2+(flowSize.width+spacing)+xpos,yPos)))
                end
            end
        end
        if flower[i] > flowerIndex[flowerNumber] then
            local flow_val = self:getChildByTag(flowerIndex[flowerNumber])
            local flow_x = flow_val:getPositionX()
            local flow_y = flow_val:getPositionY()
            if flowerNumber ~= 4 then
                flowSp:setPosition(cc.p(flow_x,flow_y-(flowSize.height+spacing)))
            else
                flowSp:setPosition(cc.p(flow_x+(flowSize.width+spacing),yPos))
            end
        end
    else
        if i < 5 then
            Log.i("i < 5....")
            flowSp:setPosition(cc.p(flowSize.width/2+xpos,-(flowSize.height+spacing)*(i-1)+yPos))
        else
            Log.i("i == 5....")
            flowSp:setPosition(cc.p(flowSize.width/2+(flowSize.width+spacing)+xpos,-(flowSize.height+spacing)*(i-5)+yPos))
        end
    end
end

function PlayerFlowNode:setFlowerIndex(flower)
    self._flowerCardNumber[#self._flowerCardNumber+1] = flower
    if #self._flowerCardNumber > 1 then
        table.sort(self._flowerCardNumber,function(a,b) return a<b end)
    end
--    Log.i("setFlowerIndex...",self._flowerCardNumber)
end
function PlayerFlowNode:getFlowerIndex()
    if self._flowerCardNumber == nil then
        self._flowerCardNumber = {}
    end
    return self._flowerCardNumber
end
function PlayerFlowNode:getFlowerPng(mj)
    Log.i("PlayerFlowNode:getFlowerPng...",mj)
	local hua_png = ""
	if mj == 51 then
		hua_png = "#chun.png"
	elseif mj == 52 then
		hua_png = "#xia.png"
	elseif mj == 53 then
		hua_png = "#qiu.png"
	elseif mj == 54 then
		hua_png = "#dong.png"
	elseif mj == 55 then
		hua_png = "#mei.png"
	elseif mj == 56 then
		hua_png = "#lan.png"
	elseif mj == 57 then
		hua_png = "#ju.png"
	elseif mj == 58 then
		hua_png = "#zhu.png"
	end
    Log.i("hua_png...",ng)
	return hua_png
end
function PlayerFlowNode:getFlowerPositionX(mj)
	local x = 0
	if mj == 51 then
		x = 22
	elseif mj == 52 then
		x = 43
	elseif mj == 53 then
		x = 65
	elseif mj == 54 then
		x = 87
	elseif mj == 55 then
		x = 134
	elseif mj == 56 then
		x = 157
	elseif mj == 57 then
		x = 180
	elseif mj == 58 then
		x = 202
	end
	return x
end

return PlayerFlowNode
--endregion
