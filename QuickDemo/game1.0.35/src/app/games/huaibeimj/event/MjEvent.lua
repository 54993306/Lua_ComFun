--region *.lua
--Date 2015/11/11
--麻将事件定义

--endregion

local prefixFlag = "MJ_EVENT_"
MJ_EVENT = 
{
	MJ_ENTRY			= prefixFlag .. "MjEntry",				--进入麻将
	HALL_ENTRY			= prefixFlag .. "HallEntry",			--进入大厅
	GAME_ENTRY			= prefixFlag .. "GameEntry",			--进入房间

	GAME_msgGameStart	= prefixFlag .. "GAME_gameStart",		--开始游戏
	GAME_startAniEnd	= prefixFlag .. "GAME_startAniEnd",		--开局动画结束
	GAME_distrubuteEnd	= prefixFlag .. "GAME_distrubuteEnd",	--发牌结束
	--GAME_jiaoEnd		= prefixFlag .. "GAME_jiaoEnd",			--叫牌结束
	GAME_msgFlower		= prefixFlag .. "GAME_flowerMsg",		--补花
	GAME_putDownMj		= prefixFlag .. "GAME_putDownMj",		--麻将落地
	--GAME_clockPoint		= prefixFlag .. "GAME_clockPoint",		--闹钟指针
	GAME_delTingQuery	= prefixFlag .. "GAME_delTingQuery",	--移除听牌查询
	GAME_enterError		= prefixFlag .. "GAME_enterError",		--进入房间失败



	GAME_msgPlayCard	= prefixFlag .. "GAME_playCard",		--收到打牌消息 
	GAME_msgAction		= prefixFlag .. "GAME_action",			--收到特殊操作消息
    GAME_msgFlowAction  = prefixFlag .. "GAME_flowaction",      --收到补花操作消息
	GAME_dispense		= prefixFlag .. "GAME_dispense",			--收到摸牌消息
	GAME_msgSubstitute	= prefixFlag .. "GAME_msgSubstitute",	--收到托管消息
	GAME_msgCommonOver  = prefixFlag .. "GAME_msgCommonOver",	--收到通用结算
	GAME_msgGameOver	= prefixFlag .. "GAME_msgGameOver",		--收到结算消息
	GAME_msgTingQuery	= prefixFlag .. "GAME_msgTingQuery",	--收到听牌查询消息
	GAME_msgMission		= prefixFlag .. "GAME_msgMission",		--收到任务消息
	GAME_msgUserInfo	= prefixFlag .. "GAME_msgUserInfo",		--收到玩家资料消息
	GAME_msgChat		= prefixFlag .. "GAME_msgChat",			--收到聊天消息
	GAME_msgProp		= prefixFlag .. "GAME_msgProp",			--收到道具消息
    GAME_msgBuyProp     = prefixFlag .. "GAME_msgBuyProp",      --收到购买互动道具消息
	GAME_msgResume		= prefixFlag .. "GAME_msgResume",		--收到恢复对局消息
	MSG_SEND			= prefixFlag .. "MsgSend"				--发送消息
}
-- 麻将ui事件
enMjEventUi = 
{
	GAME_OVER_PANEL_DETAIL_BTN 	= "MJ.UI.GAMEOVERPANELDETAILBTN", 	-- 更新详情按钮
	GAME_CLOSE_DETAIL_PANEL_BTN = "MJ.UI.GAMECLOSEDETAILPANELBTN",	-- 详细信息关闭按钮
}
