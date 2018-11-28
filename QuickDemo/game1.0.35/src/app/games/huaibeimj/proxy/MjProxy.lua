-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Define = require "app.games.huaibeimj.mediator.game.Define"
local WWFacade = require("app.games.huaibeimj.custom.WWFacade")

MjProxy = class("MjProxy")

MjProxy.getInstance = function()
    if not MjProxy.s_instance then
        MjProxy.s_instance = MjProxy.new();
    end

    return MjProxy.s_instance;
end

MjProxy.releaseInstance = function()
    if MjProxy.s_instance then
        MjProxy.s_instance:dtor();
    end
    MjProxy.s_instance = nil;
end

MjProxy.ctor = function(self)
	self:init()
end

MjProxy.dtor = function(self)
end

function MjProxy:init()
	self._allRooms = { }
	self._gameStartData = { }
	self._msgCache = { }
	self._flowerData = { }
	self._playCardData = { }
	self._actionData = { }
    self._flowActionData = { }
	self._substituteData = { }
	self._gameOverData = { }
	self._userInfoData = { }
	self._chatData = { }
	self._propData = { }
	self._missionData = { }
	self._tingQueryData = { }
	self._resumeData = { }
	self._players = {}
	self._userIds = {}
	self._xiaPaoData = {}
	self.gameOver = false
	self.substitute = false	
	-- self._allPlayerHasXiaPao = false
    self._isShowFlow = true
    self._defaultChar = {}
    self._reflashMyMJ = {}
    -- 设置动作类型，为了给拉庄和跑使用
    self.actionType   = Define.action_xiaPao

    self.modeTypeNum  = {} -- 模式类型数量

    self.isResume     = false -- 是否是恢复对局
end

-- 初始化游戏辅助数据
function MjProxy:initAuxiliaryData()
	Log.i("MjProxy:initAuxiliaryData.....................")
	self.gameOver = false
	self.substitute = false	
	self._gameOverData = { }
	 for i = 1, 4 do 
	 	if self._players[i] then
		self._players[i]:setHasClickTing(false)
		self._players[i]:setHasSendTing(false)
		self._players[i]:setCanPlay(false)
		self._players[i]:setActionTimes(0)
		self._players[i]:setGangTimes(0)
		self._players[i]:setFapaiFished(false)
		self._players[i]:setTaskFinished(false)
		self._players[i]:setTaskMultiple(0)
		self._players[i].m_arrMyActionMj = {} 
		self._players[i].m_arrMyActionType = {} 
		self._players[i].cards = { }
		self._players[i].gameInfo = { }
		end    
	end  
end
function MjProxy:runPopAllMsgCache(action)
    Log.i("MjProxy:runPopAllMsgCache....")
    if action ~= nil then
        self:setCurrentAction(action)
    end
    table.remove(self._msgCache,1)
    self:popAllMsgCache()

    if #self._msgCache <=1 then
--        self:setIsOnAction(false)
        MjMediator:getInstance()._gameLayer:performWithDelay(function() self:setIsOnAction(false) end,0.1)
    end
end
function MjProxy:popAllMsgCache()
    Log.i("MjProxy:popAllMsgCache..")
	self._players[Define.site_self]:setFapaiFished(true) 
	self._msgCache = self._msgCache or {}
    if self._msgCache == nil or #self._msgCache <=0 then
        return
    end
    self:setIsOnAction(true)
    Log.i("MjProxy:popAllMsgCache..........",self._msgCache)
--	for k, v in ipairs(self._msgCache) do
        local v = self._msgCache[1]
		Log.i("MjProxy:popAllMsgCache=",v.msg_v)
		if v.msg_v.playedbyID and v.msg_k == (ww.mj.msgReadId.msgRead_playCard..v.msg_v.playedbyID) then
			self._playCardData = v.msg_v
			Log.i("发送缓存的打牌数据=",v.msg_k)
            local playCardData = v.msg_v 
            MjMediator:getInstance():on_playCard(playCardData)
		elseif v.msg_k == ww.mj.msgReadId.msgRead_mjAction then
			Log.i("发送缓存的操作数据")
--             if v.msg_v.actionID == Define.action_buhua then
-- --			    self:setBuHuaAction(v.msg_v,k)
--                 MjMediator:getInstance():on_flowaction(v.msg_v)
--             else
                self._actionData = v.msg_v
                local actionData = v.msg_v
                MjMediator:getInstance():on_action(actionData)
            -- end
		elseif v.msg_v.userId and v.msg_k == (ww.mj.msgReadId.msgRead_dispenseCard..v.msg_v.userId) then
			Log.i("发送缓存的摸牌数据")
--            if #self._flowActionData > 0 then
--                display.getRunningScene():performWithDelay(function()
--                    MjMediator:getInstance():on_dispenseCard(v.msg_v)
--                end,#self._flowActionData-1)
--            else
                MjMediator:getInstance():on_dispenseCard(v.msg_v)
--            end
		end
--	end
end
--记录当前的动作
function MjProxy:setCurrentAction(action)
    self._currentAction = action
end
function MjProxy:getCurrentAction()
    return self._currentAction or ""
end

function MjProxy:getPlayerIndexById( userId )
    Log.i("#self._userIds...",#self._userIds)
	for i=1,#self._userIds do
        Log.i("_userIds...",self._userIds[i])
		if userId == self._userIds[i] then
			return i
		end
	end
	return 0
end

function MjProxy:setPlayerCount(count)
end

function MjProxy:getPlayerCount()
	return 4
end

function MjProxy:getPlayId()
	return self.playId
end

function MjProxy:setPlayId(playId)
	self.playId = playId
end

function MjProxy:getSubstitute()
	return self.substitute or false
end

function MjProxy:setSubstitute(substitute)
	self.substitute = substitute
end

function MjProxy:getGameOver()
	return self.gameOver or false
end

function MjProxy:setGameOver(gameOver)
	self.gameOver = gameOver
end

function MjProxy:setBuHua(buhua)
    self._buhua = buhua
end
function MjProxy:getBuHua()
    return self._buhua or false
end

function MjProxy:setIsAction(action)
    self._isAction = action
end
function MjProxy:getIsAction()
    return self._isAction
end
function MjProxy:getMyUserId()
	return kUserInfo:getUserId() or 0
end
function MjProxy:getUserSex()
    return kUserInfo:getUserSex() or 0
end
function MjProxy:getShowFlow()
    return self._isShowFlow or false
end
function MjProxy:getBanPosition()
    local banUserId = self._gameStartData.bankPlay
    for i,v in pairs(self._players) do
        if v:getUserId() == banUserId then
            return i
        end
    end
    return 1
end

function MjProxy:setPlayTimeOut(time)
    self.playTimeOut = time
end

function MjProxy:getPlayTimeOut()
    return self.playTimeOut or 15
end

function MjProxy:setActionTimeOut(time)
    self.actionTimeOut = time
end

function MjProxy:getActionTimeOut()
    return self.actionTimeOut or 10
end

function MjProxy:setLaizi(laizi)
    self.laizi = laizi
end

function MjProxy:getLaizi()
    return self.laizi or 1
end

function MjProxy:setGameId(gameId)
    self.gameId = gameId
end

function MjProxy:getGameId()
    return self.gameId or 0
end

function MjProxy:setRoomInfo(roomInfo)
    self.roomInfo = roomInfo
end

function MjProxy:getRoomInfo()
    return self.roomInfo
end

function MjProxy:setRoomId(roomId)
    self.roomId = roomId
end

function MjProxy:getRoomId()
    return self.roomId or 0
end

function MjProxy:setHuMj(mj)
    self.huMj = mj
end

function MjProxy:getHuMj()
    return self.huMj or 0
end
--是否是手动打的牌
function MjProxy:setIsPlayMahjong(play)
    self._is_playmahjong = play
end
function MjProxy:getIsPlayMahjong()
    return self._is_playmahjong or false
end
--背景音乐的开关
function MjProxy:setMusicPlaying(playing)
    kSettingInfo:setMusicStatus(playing)
end
function MjProxy:getMusicPlaying()
    local playingInfo = kSettingInfo:getMusicStatus()
    return playingInfo
end
--音效的开关
function MjProxy:setSoundPlaying(playing)
    kSettingInfo:setSoundStatus(playing)
end
function MjProxy:getSoundPlaying()
    local playingInfo = kSettingInfo:getSoundStatus()
    return playingInfo 
end
--方言的开关
function MjProxy:setDialectPlaying(playing)
    kSettingInfo:setGameDialectStatus(playing)
end
function MjProxy:getDialectPlaying()
    local playingInfo = kSettingInfo:getGameDialectStatus()
    return playingInfo
end
--单点设置
function MjProxy:setSinglePlaying(playing)
    kSettingInfo:setGameSingleStatus(_gameAudioEffectPath,playing)
end
function MjProxy:getSinglePlaying()
    local playingInfo = kSettingInfo:getGameSingleStatus(_gameAudioEffectPath)
    return playingInfo
end

function MjProxy:get_gameChatTxtCfg()
    local gameId = self:getGameId()
    local sex = self:getUserSex()
    local yuyan = "putong"
    if sex == 0 then
        --因为以前设定为第一句一定为男声第二句一定为女生
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "搏一搏，单车变摩托！",
            "不打的你满脸桃花开，你就不知道花儿为什么这样红！",
            "没了吧？用不用给你留点盘缠回家啊？",
            "哇！土豪，咱们做朋友吧!",
            "不是吧？这样都能赢！",
        };
    else
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "搏一搏，单车变摩托！",
            "不打的你满脸桃花开，你就不知道花儿为什么这样红！",
            "没了吧？用不用给你留点盘缠回家啊？",
            "哇！土豪，咱们做朋友吧!",
            "不是吧？这样都能赢！",
        };
    end
end

function MjProxy:setDeskDismiss(deskDismiss)
    self.deskDismiss = deskDismiss
end

function MjProxy:getDeskDismiss()
    return self.deskDismiss or false
end

function MjProxy:setIsEnterBackground(isEnterBackground)
    self.isEnterBackground = isEnterBackground
end
function MjProxy:setIsOnAction(action)
    self._isOnAction = action
end
function MjProxy:getIsOnAction()
    return self._isOnAction or false
end
function MjProxy:getIsEnterBackground()
    return self.isEnterBackground or false
end

--获取一个玩家信息
function MjProxy:getPlayerInfoByID(playerID)
   
	if(self._players==nil) then
	   Log.i("麻将所有玩家信息不存在")
	end
	
	Log.i("玩家ID:",playerID)
    for i=1,#self._players do
		local v = self._players[i];
		Log.i("麻将玩家信息",v:getUserId())
        if v:getUserId() == playerID then
            return v;
        end
    end
	return nil;
end

function MjProxy:setBankerId(bankerId)
    self.m_bankerId = bankerId
end

function MjProxy:getBankerId()
    return self.m_bankerId or 0
end
function MjProxy:setActionList(play,action)
    if self._actionList == nil then
        self._actionList = {}
    end
    if #self._actionList > 0 then
        for i , v in pairs(self._actionData) do
            log.i("V......",v)
            if v.player == play then
                table.insert(v.action,action)
                break
            else
                local data = {}
                data.player = play
                data.action = {}
                table.insert(data.action,action)
                table.insert(self._actionList,data)
            end
        end 
    else
        local data = {}
        data.player = play
        data.action = {}
        table.insert(data.action,action)
        table.insert(self._actionList,data)
    end
    Log.i("MjProxy:setActionList.....",self._actionList)
end
function MjProxy:getActionList()
    return self._actionList or {}
end
function MjProxy:setBuHuaNumber(site,index,number)
    if self.m_buhuaNumber == nil then
        self.m_buhuaNumber = {}
    end
    if self.m_buhuaNumber[site] == nil then
        self.m_buhuaNumber[site] = {}
    end
    self.m_buhuaNumber[site][index] = number
end
function MjProxy:getBuHuaNumber(site,index)
    if self.m_buhuaNumber == nil then
        self.m_buhuaNumber = {}
    end
    if self.m_buhuaNumber[site] == nil then
        self.m_buhuaNumber[site] = {}
    end
    return self.m_buhuaNumber[site][index] or 0
end

function MjProxy:getNeedXiaOrLaZhuangPao()
    return self._needXiaPaoOrLaZhuang or false
end

function MjProxy:setNeedXiaOrLaZhuangPao(needXiaPao)
    self._needXiaPaoOrLaZhuang = needXiaPao
end

function MjProxy:setXiaPaoFinished(finish)
    self.xiaPaoFinished = finish
end

function MjProxy:getXiaPaoFinished()
    return self.xiaPaoFinished or false
end

function MjProxy:setAllPlayerHasXiaPao(hasXiaPao)
    self._allPlayerHasXiaPao = hasXiaPao
end

function MjProxy:getAllPlayerHasXiaPao()
    return self._allPlayerHasXiaPao or false
end
--[[
-- @brief  设置拉或者跑动作类型函数
-- @param  void
-- @return void
--]]
function MjProxy:setModeType(hasXiaPao)
    self.actionType = hasXiaPao
end
--[[
-- @brief  获取拉或者跑动作类型函数
-- @param  void
-- @return void
--]]
function MjProxy:getModeType()
    return self.actionType or Define.action_xiaPao
end

--[[
-- @brief  设置全局拉跑模式数量
-- @param  modeNum 拉跑数量 site 座位索引
-- @return void
--]]
function MjProxy:setGlobalModeNum(site, modeNum)
    self.modeTypeNum[site] = modeNum
end
--[[
-- @brief  获取全局拉跑模式数量
-- @param  site, 座位索引
-- @return void
--]]
function MjProxy:getGlobalModeNum(site)
    return self.modeTypeNum[site]
end

--[[
-- @brief  设置是否是恢复对局
-- @param  bResume 恢复对局 bool类型
-- @return void
--]]
function MjProxy:setResume(bResume)
    self.isResume = bResume
end
--[[
-- @brief  获取是否是恢复对局
-- @param  
-- @return void
--]]
function MjProxy:getResume()
    return self.isResume
end

--[[
-- @brief  获取需要显示加注的列表
-- @param  site 座位
-- @return 需要显示的列表值
--]]

function MjProxy:getShowFillingListBySite(site)
    local showList = {}
    -- 判断是否是庄家,庄家只能坐和跑，不能拉
    local fillingList   = MjProxy:getInstance()._players[site]:getFillingNum()
    local needList      = MjProxy:getInstance()._players[site]:getNeedFilling()
    local userid        = MjProxy:getInstance()._players[site]:getUserId()
    if MjProxy:getInstance()._gameStartData.bankPlay == userid then
        for k, v in pairs(fillingList) do
            -- 不能拉庄
            if k ~= Define.action_laZhuang 
                and v < 0 
                and needList[k]  then
                showList[k] = v
            end
        end
    else
        -- 不是庄家只能跑和拉
        for k, v in pairs(fillingList) do
            -- 不能坐
            if k ~= Define.action_zuo 
                and v < 0 
                and needList[k] then
                showList[k] = v
            end
        end
    end
    return showList
end

--[[
-- @brief  设置游戏状态
-- @param  
-- @return void
--]]
function MjProxy:setGameState(state)
    self.m_gameState = state
end
--[[
-- @brief  获取游戏状态
-- @param  
-- @return void
--]]
function MjProxy:getGameState()
    return self.m_gameState
end

