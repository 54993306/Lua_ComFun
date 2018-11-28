-----------------------------------------------------------
--  @file   quickpayment.lua
--  @brief  快捷支付
--  @author wy
--  @DateTime:2017-6-6
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ChargeIdTool = require("app.PayConfig")

quickpayment = class("quickpayment", UIWndBase)

local diamound_num_to_img = {
    [15] = "diamond_L.png",
    [50] = "diamond_XL.png",
    [300] = "diamond_XXL.png",
    [1000] = "diamond_XXL.png",
}

local kWidgets = {
    tagCloseBtn     = "close_btn",
    tagTableView    = "scrollView",
    tabItem         = "scrollViewItem",
}
function quickpayment:ctor()
    self.super.ctor(self, "hall/record_dialog.csb", info)
end

function quickpayment:getChargeListData()
    local chargeList = {}
    local daList = kChargeListInfo:getChargeList();
    if G_LOCAL_IOS_CHARGE_FOR_AUDIT then
        daList = IosLocalRechargeData
    end
    for k, v in pairs(daList) do
        if not v.go then
            local config = v.trI
            local pos = string.find(config, ":")
            v.go = string.sub(config, pos + 1)
        end
        v.pr = v.pr or 0
    end
    if device.platform == "ios" and not G_LOCAL_IOS_CHARGE_FOR_AUDIT then
        for k,v in pairs(daList) do
            local iosProductId = ChargeIdTool.getIosProductId(v.Id)
            if iosProductId > 0 then
                chargeList[#chargeList+1] = {sellNum = v.go, giveNum = v.pr, price = v.pa0, Id = iosProductId}
            end
        end
    else
        for k,v in pairs(daList) do
            chargeList[#chargeList+1] = {sellNum = v.go, giveNum = v.pr, price = v.pa0, Id = v.Id}
        end
    end
    return chargeList
end

function quickpayment:onInit()
    --获取商品列表
    self:addWidgetClickFunc(self.m_pWidget, handler(self, self.keyBack))
    kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_STORE, 0, 0); --暂时用商城充值（更多充值）
    local daList = self:getChargeListData();
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagCloseBtn);
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_11")
    title:loadTexture("hall/main/txt_charge.png")

    self.listView = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTableView)
    -- 移除csb的item
    local csbItem = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tabItem)
    if csbItem then csbItem:removeFromParent() end

    local function scrollFunc(data, mWight, nIndex)
        local showStr1 = "钻石x"..tostring(data.sellNum)
        local cnt = ccui.Helper:seekWidgetByName(mWight,"cnt")
        cnt:setString(showStr1)

        local diamond_img = ccui.Helper:seekWidgetByName(mWight,"Image_7")
        if diamound_num_to_img[data.sellNum] then
            diamond_img:loadTexture("hall/huanpi2/Common/"..diamound_num_to_img[data.sellNum])
        end

        local free = ccui.Helper:seekWidgetByName(mWight,"free")
        free:setString("送" .. tostring(data.giveNum) .. "钻石")
        if(data.giveNum == 0) then
            free:setVisible(false)
            cnt:setPositionY(cnt:getPositionY() - 30)
        end

        local btn = ccui.Helper:seekWidgetByName(mWight,"btn_buy");
        btn:setTitleText(tostring(data.price) .. "元")
        self:addWidgetClickFunc(btn, function() self:requestBuy(data) end)

        local itemBg = ccui.Helper:seekWidgetByName(mWight, "panel_bg")
        self:addWidgetClickFunc(itemBg, function() self:requestBuy(data) end)
    end
    self.m_scrollView = new_cScrollView(self.listView, self:modifyItem(), daList, scrollFunc, 0, 20)
end

-- 修改itemModel
function quickpayment:modifyItem()
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/quickpayitem.csb");
    -- for k, v in pairs(ccui.Helper:seekWidgetByName(itemModel, "panel_bg"):getChildren()) do
    --     Log.i("v", tolua.type(v), v:getName())
    -- end

    local itemBg = ccui.Helper:seekWidgetByName(itemModel, "panel_bg") -- 背景
    itemBg:setLayoutType(0)
    itemBg:setBackGroundImageScale9Enabled(true)
    itemBg:setBackGroundImage("hall/friendRoom/rule_bg.png")
    itemBg:setContentSize(cc.size(640, 300))

    ccui.Helper:seekWidgetByName(itemModel, "Image_11"):removeFromParent() -- 隐藏一条竖线
    local biaoqian = ccui.Helper:seekWidgetByName(itemModel, "biaoqian") -- 销售标签
    biaoqian:setPositionX(biaoqian:getPositionX() + 5)
    biaoqian:setPositionY(biaoqian:getPositionY() - 5)
    ccui.Helper:seekWidgetByName(itemModel,"price"):removeFromParent() -- 金额改为直接写在按钮上

    local btnPosX = 340 -- 各子项的位置
    ccui.Helper:seekWidgetByName(itemModel,"Image_7"):setPositionX(btnPosX) -- 钻石
    ccui.Helper:seekWidgetByName(itemModel,"cnt"):setPositionX(btnPosX):setColor(cc.c3b(81, 152, 240)) -- 获得多少钻
    ccui.Helper:seekWidgetByName(itemModel,"free"):setPositionX(btnPosX):setColor(cc.c3b(81, 152, 240)) -- 赠送多少钻

    local btn = ccui.Helper:seekWidgetByName(itemModel,"btn_buy");
    btn:loadTextureNormal("hall/main/btn_charge.png")
    btn:loadTexturePressed("hall/main/btn_charge.png")
    btn:setTitleText("6元")
    btn:setTitleFontSize(40)
    btn:setContentSize(cc.size(167, 75))
    btn:setPositionX(btnPosX)
    btn:setPositionY(btn:getPositionY() + 10)

    return itemModel
end

function quickpayment:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            UIManager:getInstance():popWnd(quickpayment)
        elseif pWidget == self.btn_applyAgent then
            UIManager:getInstance():popWnd(quickpayment)
            UIManager.getInstance():pushWnd(Contact_us)
        end
    end
end

function quickpayment:requestBuy(goodInfo)
    SoundManager.playEffect("btn");
    if device.platform == "ios" then
        local data = {};
        data.cmd = NativeCall.CMD_CHARGE;
        data.type = 4;
        data.product = goodInfo.Id..""
        NativeCall.getInstance():callNative(data, GameManager.getInstance().sendIOSCharge, GameManager.getInstance());
        LoadingView.getInstance():show("正在生成订单,请稍后...");
    else
        local data = {};
        data.stID = goodInfo.Id;
        data.buW = 2;
        data.gaI = kChargeListInfo:getGameId();
        data.roI = kChargeListInfo:getRoomId();
        data.paW = kChargeListInfo:getChargePath();
        LoadingView.getInstance():show("正在生成订单,请稍后...");
        SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_GETORDER, data);
    end
end

return quickpayment