-- 徐州麻将结算详情
local GameDetailPanel = require "app.games.huaibeimj.mediator.game.dialog.GameDetailPanel"
local XZGameDetailPanel = class("XZGameDetailPanel", GameDetailPanel)

function  XZGameDetailPanel:ctor()
	self.super.ctor(self)
end	

--[[
-- @brief  显示函数
-- @param  index 座位索引
-- @return void
--]]
function XZGameDetailPanel:onShow(index)
    Log.i("XZGameDetailPanel:onShow")
	self.site = index
	local winnerSite = MjProxy:getInstance():getPlayerIndexById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
	self.m_scoreitems = MjProxy:getInstance()._gameOverData.scoreItems
    local detail = {}
    if winnerSite ~= 0 then
        local pon = self.m_scoreitems[winnerSite].policyName or {}
        local pos = self.m_scoreitems[winnerSite].policyScore or {}
        
        local textUnit = "番"
        for i=1, #pon do
            if pon[i] == "自摸" or pon[i] == "点炮" then
                textUnit = "倍底注"
            else
            	textUnit = "番"
            end
            local policyName = pon[i].." "..pos[i]..textUnit
            detail[#detail + 1] = policyName
        end
    end
	-- 显示头像
	self:showImgHead(self.head_img, index)

    if MjProxy:getInstance():getBanPosition() == index then
        self.zhuang_img:setVisible(true)
    end

    if self.m_scoreitems[index]:getBroke() == 1 then
        self.pochan_img:setVisible(true)
    end
		self.nick_label:setString(self.m_scoreitems[index]:getNickName())
  	if self.m_scoreitems[index]:getTotalGold() > 0 then
        self.bean_label:setString("+"..self.m_scoreitems[index]:getTotalGold())
    else
        self.bean_label:setString(self.m_scoreitems[index]:getTotalGold())
    end  
    if self.m_scoreitems[index]:getTotalGold() == 0   then
        if MjProxy:getInstance()._players[index]:getFillingNumByType() > 0 then
            detail = {"下"..MjProxy:getInstance()._players[index]:getFillingNumByType().."嘴"}
        else
            detail = {""}
        end
    else
        if MjProxy:getInstance()._players[index]:getFillingNumByType() > 0 then
            table.insert(detail,1, "下"..MjProxy:getInstance()._players[index]:getFillingNumByType().."嘴 ")
        end
    end  
    local function scrollFunc(data,mWight,nIndex)
        mWight:setString(detail[nIndex])
        local labContSize = mWight:getContentSize()
        local dataLen = string.len(detail[nIndex])
        local dataSize = dataLen*20 
        if labContSize.width < dataSize then
            mWight:setContentSize(cc.size(dataSize,labContSize.height))
        end
    end
    self.m_scollView = new_cScrollView(self.pan_scrollview,self.detail_lab,detail,scrollFunc,5,3)
      
end

return XZGameDetailPanel