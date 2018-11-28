-- 牌局中消息处理

local Define = require "app.games.huaibeimj.mediator.game.Define"
local Player = require "app.games.huaibeimj.mediator.game.data.Player"
local ScoreItem = require "app.games.huaibeimj.mediator.game.data.ScoreItem"
local Sound = require "app.games.huaibeimj.mediator.game.model.Sound"


local MjGameSocketProcesser = class("MjGameSocketProcesser", SocketProcesser)

function MjGameSocketProcesser:handle_gameStart( cmd,table )
	Log.i("MjGameSocketProcesser:handle_gameStart...",table)
	Log.d("开局消息",table)
	MjMediator:getInstance():on_removeContinueReady()
	local selfRemoteSite = 1
	for i=1,table.plN do
		if MjProxy:getInstance():getMyUserId() == table.usII[i].usID then
			selfRemoteSite = i
			break
		end
	end
	MjProxy:getInstance()._players = nil 
	MjProxy:getInstance()._players =  {}
	-- 默认加注操作为完成
	MjProxy:getInstance():setXiaPaoFinished(true)
	for i=1,table.plN do
		local  site = (i - selfRemoteSite + table.plN)%table.plN +1
		MjProxy:getInstance()._players[site] = Player.new()
		MjProxy:getInstance()._players[site]:setUserId(table.usII[i].usID)
		MjProxy:getInstance()._players[site]:setNickName(table.usII[i].niN)
		MjProxy:getInstance()._players[site]:setFortune(table.usII[i].mo)
		MjProxy:getInstance()._players[site]:setIconId(table.usII[i].icID)
        MjProxy:getInstance()._players[site]:setTotal(table.usII[i].to)
        MjProxy:getInstance()._players[site]:setWin(table.usII[i].wi)
        MjProxy:getInstance()._players[site]:setLevel(table.usII[i].le)
        MjProxy:getInstance()._players[site]:setDoorWind(table.usII[i].doW)
        MjProxy:getInstance()._players[site]:setJinDu(table.usII[i].jiD)
        MjProxy:getInstance()._players[site]:setWeiDu(table.usII[i].weD)
        MjProxy:getInstance()._players[site]:setIpA(table.usII[i].ipA)
--        MjProxy:getInstance()._players[site]:setDoorWind(wind)
        --转换男女
        if table.usII[i].se == 0 or table.usII[i].se == 1 then
            table.usII[i].se = 0
        elseif table.usII[i].se == 2 then
            table.usII[i].se = 1
        end
        MjProxy:getInstance()._players[site]:setSex(table.usII[i].se)
        MjProxy:getInstance()._players[site]:setWinPre(table.usII[i].wiP)
		if table.flC then
			MjProxy:getInstance()._players[site].m_flowerCardsTwo = table.flC[i] or{}
		end
		MjProxy:getInstance()._userIds[site] = table.usII[i].usID
		Log.i(" MjGameSocketProcesser:handle_gameStart MjProxy:getInstance()._userIds["..site.."]="..MjProxy:getInstance()._userIds[site])
		-- -1 代表无效
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_xiaPao, table.usII[i].xiN)
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_laZhuang, table.usII[i].laZN)
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_zuo, table.usII[i].zuN)
		-- 设置是否需要加注
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_xiaPao, table.usII[i].seXP)
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_laZhuang, table.usII[i].seLZ)
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_zuo, table.usII[i].seZ)
		-- 设置是否完成下跑操作
		if table.usII[i].seXP then
			MjProxy:getInstance():setXiaPaoFinished(false)
		elseif table.usII[i].seLZ then
			MjProxy:getInstance():setXiaPaoFinished(false)
		elseif table.usII[i].seZ then
			MjProxy:getInstance():setXiaPaoFinished(false)
		end
	end
   
	MjProxy:getInstance()._gameStartData = MjProxy:getInstance()._gameStartData or {}
	MjProxy:getInstance()._gameStartData.actions = {}
	dump(table.ac)
	local index = 0
	if table.ac then
		for i=1,#table.ac do
			if table.ac[i] ~= Define.action_xiaPao 
				and table.ac[i] ~= Define.action_laZhuang
				and table.ac[i] ~= Define.action_zuo then --下跑和拉庄不在action里面处理
				index = index + 1
				MjProxy:getInstance()._gameStartData.actions[index] = table.ac[i]
			end
		end
	else
		MjProxy:getInstance()._gameStartData.actions = {}
	end

	MjProxy:getInstance()._gameStartData.addGangCards 	= table.adGC or {}
	MjProxy:getInstance()._gameStartData.anGangCards 	= table.anGC or {}
	MjProxy:getInstance()._gameStartData.bankPlay 		= table.baUID or 0
	MjProxy:getInstance()._gameStartData.base 			= table.ba or 0
	MjProxy:getInstance()._gameStartData.t_closeCards 	= table.clC or {}
	MjProxy:getInstance()._gameStartData.t_flowerCard 	= table.flCM or{}
	MjProxy:getInstance()._gameStartData.firstplay 		= table.baUID or 0
	MjProxy:getInstance()._gameStartData.gamePlayID 	= table.plID or 0
	
	MjProxy:getInstance()._gameStartData.totalFan 		= table.toF or 0
	MjProxy:getInstance()._gameStartData.tingCards 		= table.tiC or {}
	MjProxy:getInstance()._gameStartData.rRemainCount 	= table.reC or 0
	MjProxy:getInstance()._gameStartData.xiaPaoList 	= table.xi or {}  -- 下跑
	MjProxy:getInstance()._gameStartData.laZhuangList 	= table.laZ or {} -- 拉庄
	MjProxy:getInstance()._gameStartData.zuoList 		= table.zuL or {} -- 坐
    MjProxy:getInstance()._gameStartData.dice 			= table.di or {}

    -- MjProxy:getInstance()._gameStartData.reXiaoPao 		= table.re or false 	-- 是否需要重新下跑 true:需要下跑 false:不需要下跑
    -- MjProxy:getInstance()._gameStartData.reLaZhuang 	= table.re4 or false 	-- 是否需要重新拉庄 true:需要拉庄 false:不需要拉庄


    MjProxy:getInstance():setLaizi(table.la1 or 1)
    Log.i("MjGameSocketProcesser:handle_gameStart setLaizi=", table)
    MjProxy:getInstance():setBankerId(table.baUID)

    -- MjProxy:getInstance():setPlayTimeOut(table.plTO or 15)
    -- MjProxy:getInstance():setActionTimeOut(table.acTO or 10)

	MjProxy:getInstance():setPlayId(MjProxy:getInstance()._gameStartData.gamePlayID)
	MjProxy:getInstance():setPlayerCount(table.plN)

	Log.i("MjGameSocketProcesser:handle_gameStart", MjProxy:getInstance()._gameStartData)	
	if MjProxy.getInstance():getGameState() == "gameStart" then	
        Log.i("开局了.........")
	    MjProxy:getInstance():setDeskDismiss(false)
	    MjMediator:getInstance():on_gameStart();
    else
        Log.i("缓存开局数据......")
        MjProxy:getInstance()._gameStartDataTable = {}
        MjProxy:getInstance()._gameStartDataTable.cmd = cmd
        MjProxy:getInstance()._gameStartDataTable.table = table
    end
	return true
end

function MjGameSocketProcesser:handle_playCard( cmd,data )
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	Log.i("MjGameSocketProcesser:handle_playCard")
	Log.d("打牌消息",table)
	local  playCardData = {}
	playCardData.playedbyID   	= data.pl or 0
	playCardData.playCard    	= data.plC or 0
	playCardData.nextplayerID   = data.neP or 0
	playCardData.doorcard    	= data.Do or 0
	playCardData.flowerCards    = data.flC or {}
	playCardData.actions   		= data.ac0 or {}
	playCardData.addGangCards   = data.adGC or {}
	playCardData.anGangCards   	= data.anGC or {}
	playCardData.tingCards     	= data.tiC or {}
	playCardData.remainCount    = data.reC or 0
	playCardData.repeatt    	= data.re or 0
	playCardData.totalFan    	= data.toF or 0
	playCardData.actionCard    	= data.acC1 or 0
	playCardData.flag    		= data.fl or 0
	playCardData.nextDoorCard 	= data.neD or 0
--    if playCardData.repeatt ~= 0 then
--        return
--    end
	
	-- local acts = {}
	-- for k, v in pairs(data.ac0) do
	-- 	if v ~= Define.action_xiaPao
	-- 		and v ~= Define.action_laZhuang
	-- 		and v ~= Define.action_zuo then
	-- 		table.insert(acts, v)
	-- 	end
	-- end
	-- playCardData.actions = acts or {}
	--------------- 回放功能--------------------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		MjProxy:getInstance()._playCardData = playCardData
		MjMediator:getInstance():on_playCard(playCardData)
	else
		Log.d("打牌数据",playCardData)	
	    MjProxy:getInstance()._msgCache = MjProxy:getInstance()._msgCache or {}
	    MjProxy:getInstance()._msgCache[#MjProxy:getInstance()._msgCache + 1] = { msg_k = cmd..playCardData.playedbyID, msg_v = playCardData }
		Log.d("缓存打牌数据=",cmd..playCardData.playedbyID)
	    if MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() ~= nil 
	        and MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() == true
	        and #MjProxy:getInstance()._msgCache <= 1 then
	            MjProxy:getInstance():popAllMsgCache()
	    end
	end
	--------------------------------------------------------
	
	return true
end

function MjGameSocketProcesser:handle_mjAction( cmd,info )
    Log.d("动作消息", info)	
 	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	if info.opS and info.opS == -1 then
		Log.e("MjGameSocketProcesser:handle_mjAction erro ")
        MjMediator:getInstance():requestResumeGame()
		return true
	end

	MjProxy:getInstance()._actionData = {}
	MjProxy:getInstance()._actionData.actionCard 	= info.acC0 or 0
	MjProxy:getInstance()._actionData.actionID  	= info.acID or 0
	MjProxy:getInstance()._actionData.cbCards  		= info.cbC or {}
	MjProxy:getInstance()._actionData.actionResult  = info.acR or 0
	MjProxy:getInstance()._actionData.userid  		= info.usID or 0
	MjProxy:getInstance()._actionData.lastPlayUserId = info.laPUID or 0
    MjProxy:getInstance()._actionData.plyerCard 	= info.ca or 0
    MjProxy:getInstance()._actionData.isBuJG 		= info.isLG or false 	-- 是否是补加杠
    table.sort(MjProxy:getInstance()._actionData.cbCards)

	Log.d("MjGameSocketProcesser:handle_mjAction actionData", MjProxy:getInstance()._actionData)	
	if MjProxy:getInstance()._actionData.actionID == 0 then
        return
    end
	-- 加注动作处理
	if MjProxy:getInstance()._actionData.actionID == Define.action_xiaPao
		or MjProxy:getInstance()._actionData.actionID == Define.action_laZhuang
		or MjProxy:getInstance()._actionData.actionID == Define.action_zuo then-- 跑拉坐
		for i=1, #MjProxy:getInstance()._players do
			if MjProxy:getInstance()._players[i]:getUserId() == MjProxy:getInstance()._actionData.userid then

				MjProxy:getInstance()._players[i]:setFillingNumByType(
					MjProxy:getInstance()._actionData.actionID, 
					MjProxy:getInstance()._actionData.actionCard)
				
			end
		end
		local allHasXiaPao = true
		for i=1,#MjProxy:getInstance()._players do
			-- dump(MjProxy:getInstance()._players[i]:getFillingNum())
			for k, v in pairs(MjProxy:getInstance()._players[i]:getFillingNum()) do
				if v < 0 then

					allHasXiaPao = false
				end
			end
		end
		MjProxy:getInstance():setXiaPaoFinished(allHasXiaPao)
		MjMediator:getInstance():on_xiaPaoOrLaZhuang()
		return
	end

	MjProxy:getInstance()._gameOverData.winnerId =  0
	if MjProxy:getInstance()._actionData.actionResult == 1 and (MjProxy:getInstance()._actionData.actionID == Define.action_dianPaoHu or MjProxy:getInstance()._actionData.actionID == Define.action_ziMoHu) then--胡牌了
		MjProxy:getInstance():setHuMj(MjProxy:getInstance()._actionData.actionCard)
		MjProxy:getInstance()._gameOverData.winnerId = MjProxy:getInstance()._actionData.userid or 0
	end
    if MjProxy:getInstance()._players == nil or #MjProxy:getInstance()._players <= 0 then
--        MjMediator:getInstance():on_action()
        Log.e("MjGameSocketProcesser:handle_mjAction 没有玩家就已经发了牌局消息")
        return true
    end
	if MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() == false then
		--------------- 回放功能--------------------------------
		if VideotapeManager.getInstance():isPlayingVideo() then
			MjMediator:getInstance():on_action(MjProxy:getInstance()._actionData)
		else
			Log.d("缓存操作数据 handle_mjAction",MjProxy:getInstance()._msgCache)
			MjProxy:getInstance()._msgCache = MjProxy:getInstance()._msgCache or {}
			MjProxy:getInstance()._msgCache[#MjProxy:getInstance()._msgCache + 1] = { msg_k = cmd, msg_v = MjProxy:getInstance()._actionData }
	        Log.d("查看缓存数据",MjProxy:getInstance()._msgCache)
		end
		-------------------------------------------------------------
	else
        if MjProxy:getInstance()._actionData.actionID == Define.action_buhua then
            MjProxy:getInstance()._playCardData = {}
            MjProxy:getInstance()._flowActionData = MjProxy:getInstance()._flowActionData or {}
            MjProxy:getInstance()._flowActionData[#MjProxy:getInstance()._flowActionData+1] = MjProxy:getInstance()._actionData
            Log.d("查看补花数据",#MjProxy:getInstance()._flowActionData,MjProxy:getInstance()._flowActionData)
            if #MjProxy:getInstance()._flowActionData <= 1 then
                Log.d("立马补花....")
                MjMediator:getInstance():on_flower()
            end
            if info.ac1 ~= nil and #info.ac1 > 0  then
                if info.ac1[1] ~= Define.action_buhua and MjProxy:getInstance()._actionData.userid == MjProxy:getInstance():getMyUserId() then
                    local playCard = {}
                    playCard.anGangCards = info.anGC
                    playCard.addGangCards = info.adGC
                    playCard.isGameStart = true
                    Log.d("playCard.....",playCard)
                    MjMediator:getInstance():showActionButton(info.ac1,playCard)
                end
            end
        end
        if VideotapeManager.getInstance():isPlayingVideo() then
            MjMediator:getInstance():on_action(MjProxy:getInstance()._actionData)
        else
            MjProxy:getInstance()._msgCache = MjProxy:getInstance()._msgCache or {}
		    MjProxy:getInstance()._msgCache[#MjProxy:getInstance()._msgCache + 1] = { msg_k = cmd, msg_v = MjProxy:getInstance()._actionData }
	        if #MjProxy:getInstance()._msgCache <= 1 then
	            MjProxy:getInstance():popAllMsgCache()
            end
        end
    end
	return true
end

function MjGameSocketProcesser:handle_flowerAction(cmd,info)
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
    Log.d("补花动作....",info)
    local flowerData = {}
    flowerData.userid = info.usID
    flowerData.actionCard = info.flC
    flowerData.plyerCard = info.ca
    MjProxy:getInstance()._flowActionData = MjProxy:getInstance()._flowActionData or {}
    MjProxy:getInstance()._flowActionData[#MjProxy:getInstance()._flowActionData+1] = flowerData
    if #MjProxy:getInstance()._flowActionData > 1 then
        return
    end
    if MjProxy:getInstance()._players == nil or #MjProxy:getInstance()._players <= 0 
        or MjProxy:getInstance()._playLayer._allPlayers == nil or #MjProxy:getInstance()._playLayer._allPlayers <=0 then
--        MjMediator:getInstance():on_action()
        Log.d("MjGameSocketProcesser:handle_flowerAction 没有玩家就已经发了补花消息")
        return true
    end
    if MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() == true then
--        if flowerData.userid == MjProxy:getInstance()._players[Define.site_self]:getUserId() then
--            MjMediator:getInstance():on_flower()
--        else
--            MjMediator:getInstance():on_otherFlower()
--        end
    end
    return true
end
function MjGameSocketProcesser:handle_gameOver( cmd,info )
    Log.d("游戏结算消息...",info)
    if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	MjProxy:getInstance():setGameOver(true)

	local  playerCount = 4
	local selfRemoteSite = 1
	for i=1, playerCount do
		if MjProxy:getInstance():getMyUserId() == info.scI[i].usID then
			selfRemoteSite = i
			break
		end
	end
	MjProxy:getInstance()._gameOverData = MjProxy:getInstance()._gameOverData or {}
	MjProxy:getInstance()._gameOverData.scoreItems = {}
	MjProxy:getInstance()._gameOverData.gangScores = {}
	MjProxy:getInstance()._gameOverData.huScores = {}
	MjProxy:getInstance()._gameOverData.paymentDetails = {info.de or {}, info.de7 or {}, info.de8 or {}, info.de9 or {}} 
	for i=1, #MjProxy:getInstance()._gameOverData.paymentDetails do
		if MjProxy:getInstance()._gameOverData.paymentDetails[i] ~= {} then

		end
	end

	for i=1, playerCount do
		local  site = i
		local index = getOverPlayerIndex(site, info)
		MjProxy:getInstance()._gameOverData.scoreItems[site] = ScoreItem.new()
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setUserId(info.scI[index].usID)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setNickName(info.scI[index].niN)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalFan(info.scI[index].toF)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalScore(info.scI[index].toS)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalMutil(info.scI[index].toM)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setAnGang(info.scI[index].anG)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setGang(info.scI[index].ga)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setResult(info.scI[index].re)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalGold(info.scI[index].toG)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalHuGold(info.scI[index].toHG)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalGangGold(info.scI[index].toGG)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalCash(info.scI[index].taC)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setTotalPaoGold(info.scI[index].toPG)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setLastCard(info.scI[index].laC)
		MjProxy:getInstance()._gameOverData.scoreItems[site]:setBroke(info.scI[index].ba)
		MjProxy:getInstance()._gameOverData.scoreItems[site].closeCards = info.scI[index].clC
		MjProxy:getInstance()._gameOverData.scoreItems[site].policyName = info.scI[index].PoN
		MjProxy:getInstance()._gameOverData.scoreItems[site].policyScore = info.scI[index].PoS
        MjProxy:getInstance()._gameOverData.scoreItems[site].addPolicyName = info.scI[index].adPN
        MjProxy:getInstance()._gameOverData.scoreItems[site].addPolicyScore = info.scI[index].adPS
        MjProxy:getInstance()._gameOverData.scoreItems[site].flowerCards = info.scI[index].flC or {}
        MjProxy:getInstance()._gameOverData.scoreItems[site]:setHuMJ(info.scI[index].laC)
        if info.scI[index].laC > 0 then
            MjProxy:getInstance():setHuMj(info.scI[index].laC)
        end
	end

	MjProxy:getInstance()._gameOverData.winType = info.wi or 0--1自摸 2 炮胡 3 流局
	MjProxy:getInstance()._gameOverData.huCount = info.haHC or 0 -- 胡牌人数
    if #MjProxy:getInstance()._msgCache > 0 then
        display.getRunningScene():performWithDelay(function()
	        MjMediator:getInstance():on_msgGameOver()
        end,#MjProxy:getInstance()._msgCache+0.5)
    else
        MjMediator:getInstance():on_msgGameOver()
    end
	Log.d("MjGameSocketProcesser:handle_gameOver", info)	
	return true
end

function getOverPlayerIndex(site, info)
	for i=1,#info.scI do
		if MjProxy:getInstance()._userIds[site] == info.scI[i].usID then
			return i
		end
	end
end

function MjGameSocketProcesser:handle_substitute( cmd,info )
	Log.d("MjGameSocketProcesser:handle_substitute###huaibeimj",info)
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	MjProxy:getInstance()._substituteData = MjProxy:getInstance()._substituteData or {}
	MjProxy:getInstance()._substituteData = info
	if MjProxy:getInstance()._substituteData.maPI == kUserInfo:getUserId() then
		if MjProxy:getInstance()._substituteData.isM == 1 then 
			MjProxy:getInstance():setSubstitute(true)
		else
			MjProxy:getInstance():setSubstitute(false)
		end
	end
	Log.i("MjGameSocketProcesser:handle_substitute", MjProxy:getInstance()._substituteData)
	MjMediator:getInstance():on_substitute()

--    if MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() ~= nil 
--        and MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() == true then
--	        MjProxy:getInstance():popAllMsgCache()
--    end

	return true

end

function MjGameSocketProcesser:handle_chat( cmd,info )
    Log.d("聊天自定义输入..",info)
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	MjProxy:getInstance()._chatData = MjProxy:getInstance()._chatData or {}
	MjProxy:getInstance()._chatData = info
	-- self:dispatchEvent(MJ_EVENT.GAME_msgChat)
	MjMediator:getInstance():on_msgChat()
	return true

end

function MjGameSocketProcesser:handle_defaultChar(cmd,info)
    Log.d("系统文字聊天..",info)
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
    MjProxy:getInstance()._defaultChar = MjProxy:getInstance()._defaultChar or {}
    MjProxy:getInstance()._defaultChar = info
    MjMediator:getInstance():on_msgDefaultChar()
end

function MjGameSocketProcesser:handle_gameResume( cmd,table )
	Log.d("恢复对局消息",table)
    
	local selfRemoteSite = 1
	for i=1,table.plN do
		if MjProxy:getInstance():getMyUserId() == table.usII[i].usID then
			selfRemoteSite = i
			break
		end
	end

	MjProxy:getInstance()._players = nil
	MjProxy:getInstance()._players = {}
	MjProxy:getInstance():setXiaPaoFinished(true)
	for i=1,table.plN do
		local  site = (i - selfRemoteSite + table.plN)%table.plN + 1
		MjProxy:getInstance()._players[site] = Player.new()
		MjProxy:getInstance()._players[site]:setUserId(table.usII[i].usID)
		MjProxy:getInstance()._players[site]:setNickName(table.usII[i].niN)
		MjProxy:getInstance()._players[site]:setFortune(table.usII[i].mo)
		MjProxy:getInstance()._players[site]:setUserStatus(table.usII[i].usS or 0)
		MjProxy:getInstance()._players[site]:setTingStatus(table.usII[i].ti or 0)
		MjProxy:getInstance()._players[site]:setIconId(table.usII[i].icID)
		MjProxy:getInstance()._players[site]:setCardNum(table.usII[i].caN)
        MjProxy:getInstance()._players[site]:setDoorWind(table.usII[i].doW)
       	MjProxy:getInstance()._players[site]:setJinDu(table.usII[i].jiD)
        MjProxy:getInstance()._players[site]:setWeiDu(table.usII[i].weD)
        MjProxy:getInstance()._players[site]:setIpA(table.usII[i].ipA)
        -- Log.i(table.usII[i].usID .. "位置信息" .. table.usII[i].jiD .. "/" .. table.usII[i].weD .. 
        --转换男女
        if table.usII[i].se == 0 or table.usII[i].se == 1 then
            table.usII[i].se = 0
        elseif table.usII[i].se == 2 then
            table.usII[i].se = 1
        end
        MjProxy:getInstance()._players[site]:setSex(table.usII[i].se)
        MjProxy:getInstance()._players[site]:setTotal(table.usII[i].to)
        MjProxy:getInstance()._players[site]:setWin(table.usII[i].wi)
        MjProxy:getInstance()._players[site]:setLevel(table.usII[i].le)
        MjProxy:getInstance()._players[site]:setWinPre(table.usII[i].wiP)

		MjProxy:getInstance()._players[site].m_flowerCardsTwo = table.usII[i].flC or{}
		MjProxy:getInstance()._userIds[site] = table.usII[i].usID
		MjProxy:getInstance()._players[site].m_openCards = table.usII[i].opC or {}				-- 动作玩家动作的牌
		MjProxy:getInstance()._players[site].m_openCardsType = table.usII[i].opCT or {}			-- 玩家动作类型
		MjProxy:getInstance()._players[site].m_openCardsUserIds = table.usII[i].opCUI or {}     -- 被操作玩家的用户id
		MjProxy:getInstance()._players[site].m_openActionCards = table.usII[i].opCAC or {} 		-- 操作者动作的牌

		local  disCards = table.usII[i].diC0 or {}
		for i=1,#disCards do
			if disCards[i] > 0 then --小于0是被动作的牌
				local disCardSize = #MjProxy:getInstance()._players[site].m_disCards
				MjProxy:getInstance()._players[site].m_disCards[disCardSize+1] = disCards[i]
			end
		end

    	-- -1 代表无效
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_xiaPao, table.usII[i].xiN or -1)
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_laZhuang, table.usII[i].laN or -1)
		MjProxy:getInstance()._players[site]:setFillingNumByType(Define.action_zuo, table.usII[i].zuN or -1)
		-- 设置是否需要加注
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_xiaPao, table.usII[i].re or false)
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_laZhuang, table.usII[i].re1 or false)
		MjProxy:getInstance()._players[site]:setNeedFillingByType(Define.action_zuo, table.usII[i].re2 or false)
		-- 设置是否完成下跑操作
		if table.usII[i].re then
			MjProxy:getInstance():setXiaPaoFinished(false)
		elseif table.usII[i].re1 then
			MjProxy:getInstance():setXiaPaoFinished(false)
		elseif table.usII[i].re2 then
			MjProxy:getInstance():setXiaPaoFinished(false)
		end

	end
	MjProxy:getInstance()._gameStartData =  {}
	MjProxy:getInstance()._gameStartData.actions = {}

	MjProxy:getInstance()._gameStartData.addGangCards 	= table.adGC or {}
	MjProxy:getInstance()._gameStartData.anGangCards 	= table.anGC or {}
	MjProxy:getInstance()._gameStartData.bankPlay 		= table.baUID
	MjProxy:getInstance()._gameStartData.base 			= table.ba
	MjProxy:getInstance()._gameStartData.t_closeCards 	= table.clC or {}
	MjProxy:getInstance()._gameStartData.t_flowerCard 	= table.flCM or{}
	MjProxy:getInstance()._gameStartData.firstplay 		= table.neUID
	MjProxy:getInstance()._gameStartData.gamePlayID 	= table.plID
	MjProxy:getInstance()._gameStartData.totalFan 		= table.toF
	MjProxy:getInstance()._gameStartData.tingCards 		= table.tiC
	MjProxy:getInstance()._gameStartData.rRemainCount 	= table.reC or 0
	MjProxy:getInstance()._gameStartData.playCard 		= table.acC
	MjProxy:getInstance()._gameStartData.dispenseCard 	= table.DoC or 0 --听牌后的摸到的牌
    MjProxy:getInstance()._gameStartData.doorcard 		= table.DoC or 0

    MjProxy:getInstance():setLaizi(table.la or 1)
    MjProxy:getInstance():setBankerId(table.baUID)
    Log.d("MjGameSocketProcesser:handle_gameResume actionCard=", table.acC)

    MjProxy:getInstance()._gameStartData.xiaPaoList 	= table.xi or {} 	-- 下跑
	MjProxy:getInstance()._gameStartData.laZhuangList 	= table.laZL or {} 	-- 拉庄
	MjProxy:getInstance()._gameStartData.zuoList 		= table.zu or {}  	-- 坐

    MjProxy:getInstance()._gameStartData.dice = table.di or {}
	local index = 0
	if table.ac then
		for i=1,#table.ac do
			if table.ac[i] ~= Define.action_xiaPao 
				and table.ac[i] ~= Define.action_laZhuang
				and table.ac[i] ~= Define.action_zuo then --下跑和拉庄不在action里面处理
				index = index + 1
				MjProxy:getInstance()._gameStartData.actions[index] = table.ac[i]
			end
		end
	else
		MjProxy:getInstance()._gameStartData.actions = {}
	end

	MjProxy:getInstance():setPlayId(table.plID)
	Log.d("handle_gameResume恢复对局：MjProxy:getInstance()._gameStartData", MjProxy:getInstance()._gameStartData)
	MjProxy:getInstance():setDeskDismiss(false)
	MjMediator:getInstance():on_msgResume()
	return true
end


function MjGameSocketProcesser:handle_exitRoom(cmd,table)
	MjMediator:getInstance():exitGame()
	return true

end

function MjGameSocketProcesser:handle_dispenseCard(cmd,table)
    Log.d("摸牌消息",table)
    -- 摸牌自减
	MjProxy:getInstance()._gameStartData.rRemainCount = MjProxy:getInstance()._gameStartData.rRemainCount - 1
	if MjProxy:getInstance():getIsEnterBackground() then
		return true
	end
	local dispenseCardData = {}
	dispenseCardData.playId = table.plID
	dispenseCardData.userId = table.usID
	dispenseCardData.card = table.ca
    if MjProxy:getInstance()._players == nil or #MjProxy:getInstance()._players <= 0 then
        Log.e("MjGameSocketProcesser:handle_dispenseCard 没有玩家就已经发了牌局消息")
        return true
    end

    --------------- 回放功能--------------------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		MjMediator:getInstance():on_dispenseCard(dispenseCardData)
	else
		MjProxy:getInstance()._msgCache = MjProxy:getInstance()._msgCache or {}
		MjProxy:getInstance()._msgCache[#MjProxy:getInstance()._msgCache + 1] = { msg_k = cmd..dispenseCardData.userId, msg_v = dispenseCardData }
		Log.d("缓存摸牌数据 =",cmd..dispenseCardData.userId,MjProxy:getInstance()._msgCache)
        if MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() ~= nil 
            and MjProxy:getInstance()._players[Define.site_self]:getFapaiFished() == true
            and #MjProxy:getInstance()._msgCache <= 1 then
	            MjProxy:getInstance():popAllMsgCache()
        end
	end
	return true
end

function MjGameSocketProcesser:handle_roomStart(cmd,table)
	Log.d("MjGameSocketProcesser:handle_roomStart",table )
	if table.re == 4 or table.re == 3 then
         --朋友开房逻辑特殊处理
	    if(kFriendRoomInfo:isFriendRoom()) then
	
	    else
			data = {}
			data.tipStr = "金豆不够，速配失败！"
			if table.re == 3 then
				data.tipStr = "金豆超出房间上限，请到大厅重新选择房间"
			end
			data.btnNum = 1
			data.confirmStr = "确定"
			data.confirmCallBack = function ()
				MjMediator:getInstance():requestExitRoom()
			end
		    local dialog = MJCommonDialog.new(data)
		    cc.Director:getInstance():getRunningScene():addChild(dialog)
		end
	end
	return true	
end

function MjGameSocketProcesser:handle_roomResume(cmd,table)
	Log.d("恢复游戏对局结果 =", table)
	MJLoadingView.getInstance():hide()
	MjProxy:getInstance():setIsEnterBackground(false)
	MjProxy:getInstance()._msgCache = {}
    if table.re == 1 then
        MJToast.getInstance():show("重连成功");
    else
    	MjMediator:getInstance():requestExitRoom()
        MjMediator:getInstance():exitGame()
        MJToast.getInstance():show("对局已结束");
    end
	return true
end

function MjGameSocketProcesser:handle_reqSendPoker(cmd,table)
	Log.d("MjGameSocketProcesser:handle_reqSendPoker")
	if table.opS and table.opS == -1 then
		Log.i("MjGameSocketProcesser:handle_reqSendPoker erro ")
        MjMediator:getInstance():requestResumeGame()
	end
	return true
end

function MjGameSocketProcesser:handle_reqContinue(cmd,table)
	Log.d("MjGameSocketProcesser:handle_reqContinue=", table)
	if table and  table.usI then
		MjMediator:getInstance():on_continueReady(table.usI)
	end
	return true
end

function MjGameSocketProcesser:handle_repPaoMaDeng(cmd,table)
	if table.co then
		MjMediator:getInstance():on_showPaoMaDeng(table.co)
	end
	return true
end

function MjGameSocketProcesser:handle_repUpdateTakenCash(cmd,table)
	MjMediator:getInstance():on_updateTakenCash(table)
	return true
end
--支付成功
function MjGameSocketProcesser:recChargeResult(cmd, packetInfo)
--    info = checktable(packetInfo);
--    self.m_delegate:handleSocketCmd(cmd, info);
    MjMediator:getInstance():on_recChargeResult(packetInfo)
end
--获取订单号
function MjGameSocketProcesser:recOrder(cmd,info)
--    Log.i("MjGameSocketProcesser:recOrder....",info)
    MJLoadingView.getInstance():hide();
    kGameManager:reCharge(info);
end
-- 散桌
function MjGameSocketProcesser:handle_dismissDesk(cmd,table)
	if table.deI then
		-- if table.deI == MjProxy:getInstance():getPlayId() then
		MjProxy:getInstance():setDeskDismiss(true)
		MjMediator:getInstance():on_dismissDesk(packetInfo)
		-- end
	end
end


--重连成功
function MjGameSocketProcesser:onNetWorkReconnected()
	Log.d("游戏重连成功")
    if self.m_delegate and self.m_delegate.onNetWorkReconnected then
        self.m_delegate:onNetWorkReconnected();
    end
end 

--正在重连
function MjGameSocketProcesser:onNetWorkReconnect()
	Log.d("游戏正在重连")
    if self.m_delegate and self.m_delegate.onNetWorkReconnect then
        self.m_delegate:onNetWorkReconnect();
    end
end 

function MjGameSocketProcesser:onNetWorkClosed()
	Log.w("游戏网络关闭了")
    if self.m_delegate and self.m_delegate.onNetWorkClosed then
        self.m_delegate:onNetWorkClosed();
    end
end 

function MjGameSocketProcesser:onNetWorkClose()
    if self.m_delegate and self.m_delegate.onNetWorkClose then
        self.m_delegate:onNetWorkClose();
    end
end 

function MjGameSocketProcesser:onNetWorkConnectFail()
    if self.m_delegate and self.m_delegate.onNetWorkConnectFail then
        self.m_delegate:onNetWorkConnectFail();
    end
end

function MjGameSocketProcesser:onNetWorkConnectException()
    if self.m_delegate and self.m_delegate.onNetWorkConnectException then
        self.m_delegate:onNetWorkConnectException();
    end
end  

--连接弱
function MjGameSocketProcesser:onNetWorkConnectWeak()
	Log.w("网络连接弱")
    if self.m_delegate and self.m_delegate.onNetWorkConnectWeak then
        self.m_delegate:onNetWorkConnectWeak();
    end
end 

--服务器通知
function MjGameSocketProcesser:repBrocast(cmd, packetInfo)
    if self.m_delegate and self.m_delegate.repBrocast then
        self.m_delegate:repBrocast(packetInfo);
    end
end

function MjGameSocketProcesser:handle_leaveStatus(cmd, packetInfo)
	Log.d("MjGameSocketProcesser:handle_leaveStatus =",packetInfo)
	if packetInfo.leS then
	    if self.m_delegate and self.m_delegate.handleLeaveStatus then
	        self.m_delegate:handleLeaveStatus(packetInfo);
	    end		
	end
end

MjGameSocketProcesser.s_severCmdEventFuncMap={
	[ww.mj.msgReadId.msgRead_gameStart] 	= MjGameSocketProcesser.handle_gameStart;
	[ww.mj.msgReadId.msgRead_playCard] 		= MjGameSocketProcesser.handle_playCard;
	[ww.mj.msgReadId.msgRead_mjAction] 		= MjGameSocketProcesser.handle_mjAction;
	[ww.mj.msgReadId.msgRead_gameOver] 		= MjGameSocketProcesser.handle_gameOver;
	[ww.mj.msgReadId.msgRead_substitute] 	= MjGameSocketProcesser.handle_substitute;
	[ww.mj.msgReadId.msgRead_gameResume] 	= MjGameSocketProcesser.handle_gameResume;
	[HallSocketCmd.CODE_REC_ExitRoom] 		= MjGameSocketProcesser.handle_exitRoom;
	[HallSocketCmd.CODE_REC_GAMESTART] 		= MjGameSocketProcesser.handle_roomStart;
	[HallSocketCmd.CODE_REC_RESUMEGAME] 	= MjGameSocketProcesser.handle_roomResume;
	[ww.mj.msgReadId.msgRead_dispenseCard] 	= MjGameSocketProcesser.handle_dispenseCard;
	[ww.mj.msgSendId.msgSend_turnOut] 		= MjGameSocketProcesser.handle_reqSendPoker;
	[ww.mj.msgReadId.msgRead_continue] 		= MjGameSocketProcesser.handle_reqContinue;
	[HallSocketCmd.CODE_REC_PAOMADENG] 		= MjGameSocketProcesser.handle_repPaoMaDeng;
    [ww.mj.msgReadId.msgRead_user_chat] 	= MjGameSocketProcesser.handle_chat;
    [ww.mj.msgReadId.msgRead_default_char] 	= MjGameSocketProcesser.handle_defaultChar;
    [ww.mj.msgReadId.msgRead_update_taken_cash] = MjGameSocketProcesser.handle_repUpdateTakenCash;
    
	[ww.mj.msgReadId.msgRead_dismissDesk] 	= MjGameSocketProcesser.handle_dismissDesk;
    [ww.mj.msgReadId.msgRead_flower] 		= MjGameSocketProcesser.handle_flowerAction;
    [ww.mj.msgReadId.msgRead_leaveStatus] 	= MjGameSocketProcesser.handle_leaveStatus;
    [HallSocketCmd.CODE_REC_GETORDER] 		= MjGameSocketProcesser.recOrder;
    [HallSocketCmd.CODE_REC_CHARGERESULT]   = MjGameSocketProcesser.recChargeResult;
    [HallSocketCmd.CODE_REC_BROCAST]   		= MjGameSocketProcesser.repBrocast;
}

return MjGameSocketProcesser