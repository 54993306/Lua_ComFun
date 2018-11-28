
IosChargeList = {
	[CONFIG_GAEMID] = { -- CONFIG_GAEMID
		[10073] = 10070, --key == iosProductId, value == serverGoodId
--		[10114] = 10071, --key == iosProductId, value == serverGoodId
--		[10115] = 10072, --key == iosProductId, value == serverGoodId
	},
	--todo
}

-- G_OPEN_CHARGE = true

--IOS商品提审 不通过服务器 客户端模拟加钻的开关
--仅对服务器没有做支付功能，但是IOS要提审商品的时候用。
--正常情况下必须走服务端的支付，也就是必须为false
G_LOCAL_IOS_CHARGE_FOR_AUDIT = true 
--IOS商品提审 不通过服务器 客户端模拟加钻的数据
--go是卖的数量，pr是赠送的数量, pa0是价格，Id是跟IosChargeList的serverGoodId对应
IosLocalRechargeData = {
    { go = 6, pr = 0, pa0 = 12, Id = 10073},
--    { go = 15, pr = 0, pa0 = 30, Id = 10071},
--    { go = 50, pr = 0, pa0 = 98, Id = 10072},
}

local ChargeIdTool = {}

function ChargeIdTool.getIosProductId(serverGoodId)
	if serverGoodId ~= nil and IosChargeList[CONFIG_GAEMID] ~= nil then
		for k,v in pairs(IosChargeList[CONFIG_GAEMID]) do
			if v == serverGoodId then
				return k
			end
		end
	end
	return 0
end

function ChargeIdTool.getServerGoodId(iosProductId)
	if iosProductId ~= nil and IosChargeList[CONFIG_GAEMID] ~= nil then
		if IosChargeList[CONFIG_GAEMID][iosProductId] ~= nil then
			return IosChargeList[CONFIG_GAEMID][iosProductId]
		end
	end
	return 0
end

function ChargeIdTool.checkIosLocalConfig()
	if IosChargeList[CONFIG_GAEMID] then
		for k,v in pairs(IosChargeList[CONFIG_GAEMID]) do
			return true
		end
	end
	return false
end

return ChargeIdTool