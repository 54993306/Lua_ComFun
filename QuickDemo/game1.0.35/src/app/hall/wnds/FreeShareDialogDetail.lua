--[[---------------------------------------- 
-- 修改： 孙斌 
-- 日期： 2018年7月9日
-- 摘要： 微信分享到好友/群，朋友圈。
]]-------------------------------------------


local ShareToWX = require "app.hall.common.ShareToWX"

FreeShareDialogDetail = class("FreeShareDialogDetail", UIWndBase)

local kRes = {
    share_diamond2_csb = "hall/share_diamond2.csb",
}

-- Widget里的子元素名字
local kCsbElement = {
    window_title = "Label_21",
    content_state1 = "pan_content1",
    cs1_text1 = "lb_des",
    cs1_text2 = "lb_des_0",
    cs1_diamond_num_text = "lb_content",
    img_tag = "Image_dianond",

    content_state2 = "pan_content2",
    cs2_text1 = "lb_des",

    btn_haoyou = "btn_share_0",
    btn_pengyouquan = "btn_share",
    btn_close = "btn_close",
}

local kWindowTitle = {
    state1 = "分享有礼",
    state2 = "分享",
}


function FreeShareDialogDetail:ctor()
    FreeShareDialogDetail.super.ctor(self, kRes.share_diamond2_csb)
end

-- 功能： 初始化
-- 返回值： 无
function FreeShareDialogDetail:onInit()
    local function getWidget( name )
        return ccui.Helper:seekWidgetByName(self.m_pWidget, name)
    end

    -- 窗口标题
    self.mWindowTitle = getWidget(kCsbElement.window_title)

    -- 关闭窗口按钮
    self.mCloseWindow = getWidget(kCsbElement.btn_close)
    self.mCloseWindow:addTouchEventListener(handler(self, self.onClickButton))

    -- 此窗口有两个版式，不能同时显示
    self.mContentPanel1 = getWidget(kCsbElement.content_state1)
    self.mContentPanel1:setVisible(false)
    self.mContentPanel2 = getWidget(kCsbElement.content_state2)
    self.mContentPanel2:setVisible(false)

    -- Panel1 里面的提示字串
    self.mP1Text1 = getWidget(kCsbElement.cs1_text1)
    self.mP1Text2 = getWidget(kCsbElement.cs1_text2)
    -- 显示钻石数量
    self.mDiamondNumText = getWidget(kCsbElement.cs1_diamond_num_text)

    --钻石图标
    self.mDiamondNumImg = getWidget(kCsbElement.img_tag)

    -- Panel2 里面的提示字串
    self.mP2Text1 = getWidget(kCsbElement.cs2_text1)

    -- 分享到微信好友/群
    self.mShareToHaoyouQun = getWidget(kCsbElement.btn_haoyou)
    self.mShareToHaoyouQun:addTouchEventListener(handler(self, self.onClickButton))
    -- 分享到微信朋友圈
    self.mShareToPengyouquan = getWidget(kCsbElement.btn_pengyouquan)
    self.mShareToPengyouquan:addTouchEventListener(handler(self, self.onClickButton))


    -- 是否可以获得免费钻石
    local isFreeGetDiamound = self:isFreeGetDiamound()
    -- 设置对应的显示字串和版式
    if isFreeGetDiamound == true then
        self.mWindowTitle:setString(kWindowTitle.state1)
        self.mContentPanel1:setVisible(true)
    else
        self.mWindowTitle:setString(kWindowTitle.state2)
        self.mContentPanel2:setVisible(true)
    end

    -- 获取分享相关免费信息
    local shareGift = kGiftData_logicInfo:getShareGift()
    if shareGift then
        if shareGift.awL then
            local strs1 = string.split(shareGift.awL, "|")
            if strs1[1] then
                local strs2 = string.split(strs1[1], ":")
                if strs2[2] then
                    -- 显示字串，可以免费获取的钻石数量
                    self.mDiamondNumText:setString("x" .. strs2[2])
                    self.img_tag = strs2[1]
                end
            end
        end

        ---self.img_tag 10008 代表钻石，10009 代表元宝
        if self.img_tag and self.img_tag == "10009" then
            self.mDiamondNumImg:loadTexture("hall/huanpi2/Common/yuanbao.png")
            self.mDiamondNumImg:setScaleY(1.75)
        elseif  self.img_tag == "10008" then
            self.mDiamondNumImg:loadTexture("hall/huanpi2/Common/diamond.png")
            self.mDiamondNumImg:setScale(1.5)
        end
        if shareGift.de then
            self.mP2Text1:setString("每日分享朋友圈一次，即可获得:")
        end

        local keyid = kUserInfo:getUserId() .. "-" .. shareGift.Id
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(keyid)
        if userGiftInfo and userGiftInfo.status == 2 and self:isFreeGetDiamound() == true then
            self.mP1Text1:setString("恭喜成功获得")
            self.mP1Text2:setString("今日已领取")
        end
    end
end

-- 功能： 按钮回调函数
-- 返回值： 无
function FreeShareDialogDetail:onClickButton( pWidget, eventType )
    if eventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        if pWidget == self.mShareToHaoyouQun then
            Util.disableNodeTouchWithinTime(pWidget)
            ShareToWX.getInstance():shareToHaoYouQun(self.shareResult, self)
        elseif pWidget == self.mShareToPengyouquan then
            Util.disableNodeTouchWithinTime(pWidget)
            -- ShareToWX.getInstance():shareToPengYouQuan(self.shareResult, self)
            LoadingView.getInstance():show("正在分享,请稍后...", 2);
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult), ShareToWX.FreeShareFriendQuan)
        elseif pWidget == self.mCloseWindow then
            self:keyBack()
        end
    end
end

-- 功能： 接收分享操作后的结果
-- 返回值： 无
function FreeShareDialogDetail:shareResult(info)
    Log.i("shard button:", info)
    LoadingView.getInstance():hide()
    if info.errCode == 0 then
        Toast.getInstance():show("分享成功")
        self:getGift()
        local data = {
            wa = 1
        }
        -- SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
    elseif info.errCode == -8 then
        Toast.getInstance():show("您手机未安装微信")
    else
        Toast.getInstance():show("分享失败")
    end
end

-- 功能： 关闭窗口
-- 返回值： 无
function FreeShareDialogDetail:keyBack()
    UIManager:getInstance():popWnd(FreeShareDialogDetail)
end

-- 功能： 获得礼物
-- 返回值： 无
function FreeShareDialogDetail:getGift()
    local shareGift = kGiftData_logicInfo:getShareGift()
    if shareGift then
        local keyid = kUserInfo:getUserId() .. "-" .. shareGift.Id
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(keyid)
        if self:isFreeGetDiamound() == true and userGiftInfo.status ~= 2 then
            local data = {
                quI = shareGift.Id
            }
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_TASKFINISH, data)
        end
    end
end

-- 功能： 能否获得免费钻石
--      3.5横板里没有（kLoginInfo:isFreeGetDiamound()），这里包装一下
-- 返回值： True or False
function FreeShareDialogDetail:isFreeGetDiamound()
    return true
end
