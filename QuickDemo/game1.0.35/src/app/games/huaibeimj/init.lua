--[[
	合集版麻将初始化
]]
ww = {}
local mj = 
{	
	userId = kUserInfo:getUserId(),

	waBean = "",

	gender = "",

	nickName = "",

	--配置数据
	config = 
	{
		gameId = 1016,
	},

	--发送消息Id
	msgSendId = 
	{
		msgSend_substitute = 30008,		--请求托管
		msgSend_turnOut = 31002,			--请求出牌
		msgSend_mjAction = 31004,			--请求特殊操作
        msgSend_user_chat = 30009,      --用户自定义输入
        msgSend_default_char = 30010,   --用户使用系统操作
	},

	--接收消息Id
	msgReadId = 
	{
		msgRead_gameStart = 31001,		--开局
		msgRead_playCard = 31003,		--打牌
		msgRead_mjAction = 31004,		--特殊操作
		msgRead_gameOver = 31006,		--结算
		msgRead_flower = 31008,			--补花
		msgRead_substitute = 30008,		--托管
		msgRead_gameResume = 31009,		--恢复对局响应
		msgRead_dispenseCard = 31011,		--摸牌
       	msgRead_continue = 30006,		--玩家确定续局
        msgRead_user_chat = 30009,      --用户自定义输入
        msgRead_default_char = 30010,   --用户使用系统操作
        msgRead_update_taken_cash = 30002 , --更新携带
        msgRead_dismissDesk = 30012 , --散桌
		msgRead_leaveStatus = 30017 --同步离开状态

	}
}

ww.mj = mj

