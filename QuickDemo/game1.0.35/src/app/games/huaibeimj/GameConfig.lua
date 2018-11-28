--进入游戏界面
function enterGame(data)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    Log.i("huaibeimj###########enterGame",data)
--   	MjMediator:getInstance():entryMj()
    MjProxy.getInstance():setGameState("gameStart")
	MjMediator:getInstance():onGameEntry(data)

end

function loadGameRule(gameId)
    local Define = require "app.games.huaibeimj.mediator.game.Define"
    if gameId == Define.gameId_changzhou then
        _gameRuleStr = ""
    elseif gameId == Define.gameId_xuzhou then
        _gameRuleStr = ""
    else
        _gameRuleStr = "" 
    end
end
GAME_HEAD_UPDATE_TIME = 0
CONFIG_GAEMID = 10020;--游戏ID
--是否支持用户自定义聊天
_gameUserChatTxt = true;
--游戏图标
_gameTitlePath = "games/huaibeimj/image/title.png";

--大厅广告图
_gameHallAdPath = "games/huaibeimj/image/ad_hall.png";

--红包广告
_gameRedpacketAdPath = "games/huaibeimj/image/ad_redPacket.png";

-- 背景音乐
_gameBgMusicPath = "games/huaibeimj/audio/mp3/music/bgMusic.mp3";

-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示钻石
_isDiamondVisible = true

--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};
--朋友开房的玩法
FriendRoomPalyingTable = {
    ["zimo"] = {[1]     ="自摸底翻番" ,  [2] = "自摸底不翻番"},
    ["dianpao"]={[1]    = "带点炮胡",    [2] = "不带点炮胡"},
    ["dianpao"]={[1] = "带点炮胡",[2]="不带点炮胡"},
}

--游戏玩法规则  qianggangsuanzimo|gangdandusuan|ganglejiuyou|bulazhuang|buxiazui
-- qianggangbaosanjia|qianggangfuziji|qiduijiafan|shisanbukaojiafan|gangsuihuzou|ganglejiuyou|lapaozuo
_gamePalyingName={
    [1] = {title = "qianggangbaosanjia",    ch = "抢杠包三家"},
    [2] = {title = "qianggangfuziji",       ch = "抢杠付自己"},
    [3] = {title = "gangsuihuzou",          ch = "杠随胡走"},
    [4] = {title = "ganglejiuyou",          ch = "杠了就有"},
    [5] = {title = "qiduijiafan",           ch = "七对加番"},
    [6] = {title = "shisanbukaojiafan",     ch = "十三不靠加番"},
    [7] = {title = "lapaozuo",              ch = "拉跑坐"},
}
_gameSoftTitle="著作权人:北京大圣掌游文化发展有限公司 出版服务单位:上海雪鲤鱼计算机科技有限公司 审批文号:新广出审【2016】4954号       ISBN:978-7-7979-3488-6";--软件著作权
_gameHelpContentText = [[您需要邀请3个好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！

一、麻将用具
“来来淮北麻将”由饼（1至9）、条（1至9）、万（1至9）、东、南、西、北、中、發、白各四张组成，合计136张牌。
二、基本玩法
淮北麻将以推倒胡形式。
拉：玩家可以下拉，只能闲家下拉，结算为庄闲有效。
跑：玩家可以下跑，可以4家下跑，结算全部有效。
底番：庄2点（跑有效），闲家1点。
自摸：1番。
可以杠，可以碰，但不能吃牌。
明杠：1点（不管风和字，都一样）
暗杠：2点（不管风和字，都一样）
最后剩14个牌为黄庄（流局）。
七对子也可以胡，但没有任何加点。
杠开：算自摸，就没别的点数加。
三、和牌方式
淮北麻将以推倒胡的形式(没有刻意规定胡法)。
七对也可胡牌，没加点。
抢杠也可胡，算放冲。
十三不靠也可胡，加番。
四、特殊玩法
漏胡：如果胡牌一方,在别人打出牌胡家没有胡,这样另外的一方打出同一张牌的时候，那胡牌的那家绝对不能胡牌(可以吃和碰)。只有过了自己后才能胡同一张牌。
]];

-- 获取分享信息
function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    -- Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
    local paramData = {}
    paramData[1] = playerInfo.pa .. ""
    local title = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        title = Util.replaceFindInfo(roomInfo.shareTitle, '房间号', {'亲友圈房间号'})
        title = Util.replaceFindInfo(title, 'd', paramData)
    else
        title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)
    end

    local itemList=Util.analyzeString_2(selectSetInfo.wa);
    if(#itemList>0) then
        local str=""
        for i=1,#itemList do
            local st = string.format("%s,",kFriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
            Log.i("st", st)
            str = str .. st 
        end
        paramData[1] = str
    else
        paramData[1] = ""
    end      
    --
    local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
    paramData[2] = playernum

    paramData[2]= paramData[2] .. selectSetInfo.roS;
    -- Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
    local wanjiaStr = "";
    for k, v in pairs(playerInfo.pl) do
       local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
       wanjiaStr = wanjiaStr .. retName .. ","
    end
    paramData[1] = paramData[1] .. wanjiaStr
    local charge = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        charge = "亲友圈付费"
    else
        local texts = {"房主付费", "大赢家付费", "AA付费"}
        charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
    end
    paramData[2] = paramData[2] .. "局," .. charge

    local s = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})

    local desc = Util.replaceFindInfo(s, 'd', paramData)

    return title, desc
end