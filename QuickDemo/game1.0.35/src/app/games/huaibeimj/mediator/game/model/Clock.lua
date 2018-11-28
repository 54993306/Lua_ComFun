--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local WWFacade = require("app.games.huaibeimj.custom.WWFacade")
local Define = require "app.games.huaibeimj.mediator.game.Define"


local Clock = class("Clock", function ()
	return display.newNode()
end)

Clock._EType = {e_type_play = 1, e_type_action = 2}

function Clock:ctor(isResume)
	self._isResume = isResume
	self.needSubstitute = true
	Log.i("Clock:ctor")
	-- self:onNodeEve("exit", handler(self, self.onExit))
	self:addNodeEventListener(cc.NODE_EVENT, function (event)
		if event.name == "exit" then
			self:onExit()
		end
	end)
	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	-- self:setContentSize(cc.size(212, 116))
	self:setCascadeColorEnabled(true)

	-- 闹钟背景
	self.clockSprite = display.newSprite("games/common/mj/games/clock_bg.png")
	self.clockSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight /2))
	self.clockSprite:addTo(self)

	-- 门风
	
	self.lightSprites = {}
	local lightPaths = {"games/common/mj/games/clock_light_dong.png", "games/common/mj/games/clock_light_nan.png", "games/common/mj/games/clock_light_xi.png", "games/common/mj/games/clock_light_bei.png"}
	local textSpites = {}
	local textPaths = {"games/common/mj/games/clock_text_dong.png", "games/common/mj/games/clock_text_nan.png", "games/common/mj/games/clock_text_xi.png", "games/common/mj/games/clock_text_bei.png"}
	local rotateAngles = {0, -90, -180, -270}
	local space = 28
	local textSpace = 28
	local lightPostions = {cc.p(self.clockSprite:getContentSize().width / 2, space), cc.p(self.clockSprite:getContentSize().width - space, self.clockSprite:getContentSize().height / 2), cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height - space), cc.p(space, self.clockSprite:getContentSize().height / 2)}
	local textPostions = {cc.p(self.clockSprite:getContentSize().width / 2, textSpace), cc.p(self.clockSprite:getContentSize().width - textSpace, self.clockSprite:getContentSize().height / 2), cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height - textSpace), cc.p(textSpace, self.clockSprite:getContentSize().height / 2)}

	for i=1,4 do
		textSpites[i] = display.newSprite(textPaths[MjProxy:getInstance()._players[i]:getDoorWind()]):addTo(self.clockSprite)
		self.lightSprites[i] = display.newSprite(lightPaths[MjProxy:getInstance()._players[i]:getDoorWind()]):addTo(self.clockSprite)
		textSpites[i]:setRotation(rotateAngles[i])
		self.lightSprites[i]:setRotation(rotateAngles[i])
		self.lightSprites[i]:setPosition(lightPostions[i])
		textSpites[i]:setPosition(textPostions[i])
        self.lightSprites[i]:runAction(cc.FadeTo:create(0.01,0))
	end

	-- 倒计时
	self._timeLabel = cc.LabelAtlas:_create("00", "games/common/mj/games/game_num_clock.png", 15, 22, string.byte("0"))
	self._timeLabel:setAnchorPoint(cc.p(0.5, 0.5)):setPosition(cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height / 2 ))
	self._timeLabel:addTo(self.clockSprite)
    local dw = 1 
    for i,v in pairs(MjProxy:getInstance()._players) do
        if v:getUserId() == MjProxy:getInstance()._gameStartData.bankPlay then
            dw = i
        end
    end
	self._point = dw
	self.mTimeType = Clock._EType.e_type_play
end

function Clock:setThePoint(pointType, timeType,lastIndex)
	Log.i("Clock:setThePoint pointType=",pointType)
	Log.i("Clock:setThePoint timeType=",timeType)
    if lastIndex ~= nil then
        Log.i("Clock:setThePoint lastIndex =",lastIndex)
    end
	self.mTimeType = timeType
	if self._point ~=0 then
		self.lightSprites[self._point]:stopAllActions()
	end
	self._point = pointType
    local point = 1
    if self._point == 1 then
        point = 4
    else
        point = self._point-1
    end
    if lastIndex ~= nil and lastIndex ~= 0 then
        point = lastIndex
    end
--    self:setFadeOut(point)
    for i,v in pairs(self.lightSprites) do
        if i ~= self._point then
            self:setFadeOut(i)
        end
    end
	self.lightSprites[self._point]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 80), cc.FadeTo:create(0.5, 255))))

	self:clockTick()
end
function Clock:setFadeOut(index)
    if index ~= nil then
        self.lightSprites[index]:runAction(cc.FadeTo:create(0.5,0))
    elseif self._point ~= nil then
        self.lightSprites[self._point]:runAction(cc.FadeTo:create(0.5,0))
    end
end
function Clock:clockTick(time)
	if self.m_loadingSprite then
		self:showLoading(false)
	end
	self._timeLabel:setVisible(true)
	self:removeTimer()
	if self.mTimeType == Clock._EType.e_type_play then
		self._timeNum = MjProxy:getInstance():getPlayTimeOut()
	elseif self.mTimeType == Clock._EType.e_type_action then
		self._timeNum = MjProxy:getInstance():getActionTimeOut()			
	end
	if time then
		self._timeNum = time
	end
	if self._timeLabel then
		self._timeLabel:setString(tostring(self._timeNum))
	end

    self.m_close_time_update = self._timeLabel:performWithDelay(handler(self, self.updateClock), 1)
end

function Clock:clockStop()
	self:removeTimer()
	if self._timeLabel then
		self._timeLabel:setString("00")
	end
end

function Clock:updateClock()
	local number = 0
	if self.mTimeType == Clock._EType.e_type_play then
		number = MjProxy:getInstance():getPlayTimeOut()	
	elseif self.mTimeType == Clock._EType.e_type_action then
		number = MjProxy:getInstance():getActionTimeOut()			
	end
	
	if self._timeNum == number then
		self._timeNum = self._timeNum - 1
	end

	local time = tostring(self._timeNum)
	if self._timeNum < 10 then
		time = "0" .. self._timeNum
	end


	self._timeLabel:setString(time)

	if self._timeNum == 0 then
		if self._point == 1 then
			if self.needSubstitute == true and MjProxy:getInstance():getSubstitute() == false then
				local playLayer = self:getParent():getParent()._playLayer
				-- playLayer:setPlayerTouchEnabled(false)
				-- WWFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, ww.mj.msgSendId.msgSend_substitute, 1)
			end	
		else
			Log.i("对家时间到")
		end

		self:removeTimer()
		return
	end

	self._timeNum = self._timeNum - 1
    self.m_close_time_update = self._timeLabel:performWithDelay(handler(self, self.updateClock), 1)

end

function Clock:onExit()
	self:removeTimer()
end

function Clock:removeTimer()
    if self.m_close_time_update then
        transition.removeAction(self.m_close_time_update);
        self.m_close_time_update = nil;
    end
end

function Clock:showLoading(visible)
	if self.m_loadingSprite then
		self.m_loadingSprite:setVisible(visible)
	else
		self.m_loadingSprite = display.newSprite("games/common/mj/common/time_wait.png")
		self.m_loadingSprite:setPosition(cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height / 2))
		self.m_loadingSprite:addTo(self.clockSprite)
        self.m_loadingSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(0.3, 180), cc.DelayTime:create(0.3),cc.RotateBy:create(0.3, 180))))
    end
    if visible == true and self._timeLabel then
    	self._timeLabel:setVisible(false)
   	end
end

function Clock:setNeedSubstitute(needSubstitute)
	-- self.needSubstitute = needSubstitute --暂时屏蔽
end

return Clock
