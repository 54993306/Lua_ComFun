local ScoreItem = class("ScoreItem")
function ScoreItem:ctor()
	self.closeCards = {}
	self.policyName = {}
	self.flowerCards = {}

end
function ScoreItem:setUserId(userId)
	self.userId = userId
end

function ScoreItem:getUserId()
	return self.userId or 0
end

function ScoreItem:setNickName(nickName)
	self.nickName = nickName
end

function ScoreItem:getNickName()
	return self.nickName or ""
end

function ScoreItem:setTotalGold(totalGold)
	self.totalGold = totalGold
end

function ScoreItem:getTotalGold()
	return self.totalGold or "0"
end

function ScoreItem:setTotalFan(totalFan)
	self.totalFan = totalFan
end

function ScoreItem:getTotalFan()
	return self.totalFan or 0
end

function ScoreItem:setTotalScore(totalScore)
	self.totalScore = totalScore
end

function ScoreItem:getTotalScore()
	return self.totalScore or 0
end

function ScoreItem:setTotalMutil(totalMutil)
	self.totalMutil = totalMutil
end

function ScoreItem:getTotalMutil()
	return self.totalMutil or 0
end

function ScoreItem:setLastCard(lastCard)
	self.lastCard = lastCard
end

function ScoreItem:getLastCard()
	return self.lastCard or 0
end

function ScoreItem:setAnGang(anGang)
	self.anGang = anGang
end

function ScoreItem:getAnGang()
	return self.anGang or 0
end

function ScoreItem:setGang(gang)
	self.gang = gang
end

function ScoreItem:getGang()
	return self.gang or 0
end

function ScoreItem:setResult(result)
	self.result = result
end

function ScoreItem:getResult()
	return self.result or 0
end

function ScoreItem:setTotalHuGold(totalHuGold)
	self.totalHuGold = totalHuGold
end

function ScoreItem:getTotalHuGold()
	return self.totalHuGold or 0
end

function ScoreItem:setTotalGangGold(totalGangGold)
	self.totalGangGold = totalGangGold
end

function ScoreItem:getTotalGangGold()
	return self.totalGangGold or 0
end

function ScoreItem:setTotalPaoGold(totalPaoGold)
	self.totalPaoGold = totalPaoGold
end

function ScoreItem:getTotalPaoGold()
	return self.totalPaoGold or 0
end

function ScoreItem:setTotalCash(totalCash)
	self.totalCash = totalCash
end

function ScoreItem:getTotalCash()
	return self.totalCash or 0
end

function ScoreItem:setBroke(broke)
	self.broke = broke
end

function ScoreItem:getBroke()
	return self.broke or 0
end

function ScoreItem:setHuMJ(humj)
    self.huMJ = humj
end

function ScoreItem:getHuMJ()
    return self.huMJ or 0
end
return ScoreItem