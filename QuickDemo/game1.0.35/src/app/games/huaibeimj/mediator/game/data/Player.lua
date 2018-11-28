local Player = class("Player")
function Player:ctor()
	self.m_arrMyActionMj = {} --记录动作的牌牌型跟玩家id
	self.m_arrMyActionType = {} 
	self.m_arrLastPlayerIndexs = {} --
	self.cards = { }
	self.gameInfo = { }
	self.m_openCards = { }
	self.m_openCardsType = { }
	self.m_openCardsUserIds = { }
	self.m_openActionCards = { }
	self.m_disCards = {}
	self.m_flowerCardsTwo = {}
    self.m_total = 0
    self.m_win = 0
    self.m_level = ""
    self.m_sex = 0
    self.m_winpre = 0
    self.m_jiD = 0
    self.m_weD = 0
    self.m_ipA = ""
    self.FillingNum 	= {} -- 记录加注的数目
    self.needFilling  	= {} -- 是否需要加注
end
function Player:setUserId(userId)
	self.userId = userId
end

function Player:getUserId()
	return self.userId or 0
end

function Player:setNickName(nickName)
	self.nickName = nickName
end

function Player:getNickName()
	return self.nickName
end

function Player:setFortune(fortune)
	self.fortune = fortune
end

function Player:getFortune()
	return self.fortune or "0"
end

function Player:setHasClickTing(hasClickTing)
	self.hasClickTing = hasClickTing
end

function Player:getHasClickTing()
	return self.hasClickTing or false
end

function Player:setHasSendTing(hasSendTing)
	self.hasSendTing = hasSendTing
end

function Player:getHasSendTing()
	return self.hasSendTing or false
end

function Player:setCanPlay(canPlay)
	self.canPlay = canPlay
end

function Player:getCanPlay()
	return self.canPlay or false
end

function Player:setActionTimes(actionTimes)
    Log.i("Player:setActionTimes.........",actionTimes)
	self.actionTimes = actionTimes
end

function Player:getActionTimes()
    if self.actionTimes == nil then
        self.actionTimes = 0
    end
	return self.actionTimes or 0
end

function Player:setGangTimes(gangTimes)
	self.gangTimes = gangTimes
end

function Player:getGangTimes()
    if self.gangTimes == nil then
        self.gangTimes = 0
    end
	return self.gangTimes or 0
end

function Player:setFapaiFished(fapaiFished)
	self.fapaiFished = fapaiFished
end

function Player:getFapaiFished()
	return self.fapaiFished or false
end

function Player:setTaskFinished(taskFinished)
	self.taskFinished = taskFinished
end

function Player:getTaskFinished()
	return self.taskFinished or false
end

function Player:setTaskMultiple(taskMultiple)
	self.taskMultiple = taskMultiple
end

function Player:getTaskMultiple()
	return self.taskMultiple or 0
end

function Player:setIsMingPai(isMingPai)
	self.isMingPai = isMingPai
end

function Player:getIsMingPai()
	return self.isMingPai or false
end

function Player:setGender(gender)
	self.gender = gender
end

function Player:getGender()
	return self.gender or 0
end

function Player:setJiabeiCount(jiaBeiCount)
	self.jiaBeiCount = jiaBeiCount
end

function Player:getJiabeiCount()
	return self.jiaBeiCount or 0
end

function Player:setDoubleNum(doubleNum)
	self.doubleNum = doubleNum
end

function Player:getDoubleNum()
	return self.doubleNum or 0
end

function Player:setChangeFinish(changeFinish)
	self.changeFinish = changeFinish
end

function Player:getChangeFinish()
	return self.changeFinish or true
end

function Player:setUserStatus(userStatus)
	self.userStatus = userStatus
end

function Player:getUserStatus()
	return self.userStatus or 0
end

function Player:setTingStatus(tingStatus)
	self.tingStatus = tingStatus
end

function Player:getTingStatus()
	return self.tingStatus or 0
end

function Player:setTotalDoubleNum(totalDoubleNum)
	self.totalDoubleNum = totalDoubleNum
end

function Player:getTotalDoubleNum()
	return self.totalDoubleNum or 0
end

function Player:setRemainDoubleNum(remainDoubleNum)
	self.remainDoubleNum = remainDoubleNum
end

function Player:getRemainDoubleNum()
	return self.remainDoubleNum or 0
end

--[[
-- @brief  获取加注类型
-- @param  void
-- @return void
--]]
function Player:getFillingNumByType(type)
	return self.FillingNum[type] or -1
end

--[[
-- @brief  获取加注
-- @param  void
-- @return void
--]]
function Player:getFillingNum()
	return self.FillingNum
end

--[[
-- @brief  设置加注类型
-- @param  void
-- @return void
--]]
function Player:setFillingNumByType(type, num)
	self.FillingNum[type] = num
end

--[[
-- @brief  获取需要加注
-- @param  void
-- @return void
--]]
function Player:getNeedFillingByType(type)
	return self.needFilling[type] or false
end

--[[
-- @brief  获取是否需要加注
-- @param  void
-- @return void
--]]
function Player:getNeedFilling()
	return self.needFilling
end

--[[
-- @brief  设置需要加注
-- @param  void
-- @return void
--]]
function Player:setNeedFillingByType(type, isNeed)
	self.needFilling[type] = isNeed
end


function Player:getDoorWind()
	return self.doorWind or 1
end

function Player:setDoorWind( doorWind )
	self.doorWind = doorWind
end

function Player:getIconId()
	return self.iconId or 1
end

function Player:setIconId( iconId )
	self.iconId = iconId
end

function Player:setTotal(total)
    self.m_total = total
end
function Player:getToatal()
    return self.m_total or 0
end
function  Player:setWin(win)
    self.m_win = win
end
function Player:getWin()
    return self.m_win or 0 
end
function Player:setLevel(level)
    self.m_level = level
end
function Player:getLevel()
    return self.m_level or " "
end
function Player:setSex(sex)
    self.m_sex = sex
end
function Player:getSex()
    return self.m_sex or 0 
end
function Player:setWinPre(winpre)
    self.m_winpre = winpre
end
function Player:getWinPre()
    return self.m_winpre or 0
end

function Player:setCardNum(cardNum)
    self.m_cardNum = cardNum
end

function Player:getCardNum()
    return self.m_cardNum or 0
end

function Player:setThreeCardActionTimes(times)
    self.m_threeCardActionTimes = times
end

function Player:getThreeCardActionTimes()
    return self.m_threeCardActionTimes or 0
end

function Player:setFourCardActionTimes(times)
    self.m_fourCardActionTimes = times
end

function Player:getFourCardActionTimes()
    return self.m_fourCardActionTimes or 0
end
function Player:setJinDu(jid)
    self.m_jiD = jid
end
function Player:getJinDu()
    return self.m_jiD or 0
end
function Player:setWeiDu(wed)
    self.m_weD = wed
end
function Player:getWeiDu()
    return self.m_weD or 0
end
function Player:setIpA(ipa)
    self.m_ipA = ipa
end
function Player:getIpA()
    return self.m_ipA or ""
end

return Player