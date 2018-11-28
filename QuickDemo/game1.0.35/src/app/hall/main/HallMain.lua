-- 大厅主页
local ChargeIdTool = require("app.PayConfig")
local quickpayment = require("app.hall.wnds.quickpay.quickpayment")

HallMain = class("HallMain", UIWndBase);

function HallMain:ctor(info)
    self.super.ctor(self, "hall/hall.csb", info);
    self.m_socketProcesser = HallSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);

--    scheduler.performWithDelayGlobal(function()
        SocketManager.getInstance().pause = false
        LoadingView.getInstance():hide();
--    end,0.5)

    IS_IOS_PRODUCT = device.platform == "ios" and true or false
end

function HallMain:onShow()
    self:updateUserInfo();
    --新手提示
    if kLoginInfo:getIsNewer() and not IS_YINGYONGBAO then
        kLoginInfo:setIsNewer(false);
--        if _gameType == "anqingmj" then
--            UIManager.getInstance():pushWnd(NewerAdvertisementWnd);
--        else
            UIManager.getInstance():pushWnd(NewerTipsWnd);
--        end
    end
    --文字广告
    if kServerInfo:getAdTxt() then
        self:showBrocast();
    end

    --图片广告
    if kServerInfo:getMainAdUrl1() then
        self:repServerInfo();
    end
end

function HallMain:onResume()
    self:updateUserInfo();
end

function HallMain:onClose()
    if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
        self.m_timerProxy:removeTimer("wechatId_update_timer");
        self.m_timerProxy=nil
    end

    if(self.m_timer_wechat~=nil) then
        self.m_timer_wechat:finalizer()
        self.m_timer_wechat:removeTimer("reachre_wechatId_update_timer");
        self.m_timer_wechat=nil
    end 

    if(self.m_timer_marquee~=nil) then
        self.m_timer_marquee:finalizer()
        self.m_timer_marquee:removeTimer("marquee_wechatId_update_timer");
        self.m_timer_marquee=nil
    end 

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
    if self.setMorenHeadThread then
        scheduler.unscheduleGlobal(self.setMorenHeadThread);
    end
end
function HallMain:setIP(str)
    self.label_ip:setString("IP:".. str)
end
function HallMain:onInit()
    self.nickName = ccui.Helper:seekWidgetByName(self.m_pWidget, "nickName");
    self.money = ccui.Helper:seekWidgetByName(self.m_pWidget, "money");
    self.lb_id = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_id");

    self.label_ip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lb_ip");

    self.nickName:setString(kUserInfo:getUserName());
    self.money:setString(kUserInfo:getPrivateRoomDiamond());
    self.lb_id:setString("ID:".. kUserInfo:getUserId());

    self.img_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_head");

	self.btn_new = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_new");
	self.btn_new:addTouchEventListener(handler(self, self.onClickButton));

	self.btn_join = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_join");
	self.btn_join:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_record = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_record");
    self.btn_record:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_help = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_help");
    self.btn_help:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share");
    self.btn_share:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_setting");
    self.btn_setting:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_newer = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_newer");
    self.btn_newer:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_money = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_money");
    self.btn_money:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_ad = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_ad1");
    self.btn_ad:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_ad2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_ad2");
    self.btn_ad2:setVisible(false);



    self:addWechatId(self.btn_ad, 170, 50);


    -- 兑换码
    self.btn_exchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange");
    self.btn_exchange:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_exchange:setVisible(cc.UserDefault:getInstance():getBoolForKey("btn_exchange", false))
	
	local gameType = kFriendRoomInfo:getGameType();
    self.btn_ad:loadTexture(_gameHallAdPath);
    
	local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");
    title:loadTexture(_gameTitlePath);

    local pan_free_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_free_diamond");
    local particleSys = cc.ParticleSystemQuad:create("hall/main/particleDiamond.plist");
    pan_free_diamond:addChild(particleSys);
    particleSys:setPosition(50, 50);
	
    self.btn_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_diamond");
    self.btn_diamond:addTouchEventListener(handler(self, self.onClickButton));
    local sequence = transition.sequence({
                    cc.ScaleTo:create(0.4, 0.9),
                    cc.ScaleTo:create(0.4, 1.2),
                    cc.ScaleTo:create(0.4, 1)
    });
    self.btn_diamond:runAction(cc.RepeatForever:create(sequence));
    --红中打开免费钻石
    if _isDiamondVisible~=nil and  _isDiamondVisible==true then
        particleSys:setVisible(true);
	    self.btn_diamond:setVisible(true);
	else
	    self.btn_diamond:setVisible(false);
	    particleSys:setVisible(false);
    end

        -- ios的客服微信号放在这里打开
    if device.platform == "ios" then
        self.btn_kefu = ccui.Button:create("hall/main/btn_kefu.png")
        self.btn_kefu:setPositionX(self.btn_diamond:getPositionX())
        self.btn_kefu:setPositionY(self.btn_diamond:getPositionY() - 300)
        self.btn_kefu:addTo(self.btn_diamond:getParent(), 20)
        self.btn_kefu:addTouchEventListener(handler(self, self.onClickButton))
    end

	--活动描述
	self.activeLable = ccui.Helper:seekWidgetByName(self.m_pWidget, "activeLable");
	self.activeLable:setVisible(false)

    if IS_YINGYONGBAO then
        local moeny_bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"money_bg")
        moeny_bg:setVisible(false)
        self.btn_share:setVisible(false)
        self.btn_newer:setVisible(false)
    end

    -- 关注送钻石按钮
    self.btn_focusDiamond = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_focusDiamond")
    self.btn_focusDiamond:addTouchEventListener(handler(self, self.onClickButton))
    self.btn_focusDiamond:setVisible(cc.UserDefault:getInstance():getBoolForKey("btn_focusDiamond", false))

    ---------- 回放相关-------------------
    if kPlaybackInfo:getVideoReturn() then
        scheduler.performWithDelayGlobal(function()
            UIManager:getInstance():pushWnd(RecordDialog);
            end,
        0.3)
        kPlaybackInfo:setVideoReturn(false)
    end
    ------------------------------------
end

function HallMain:getMarqueeWechat(str)
    local content = string.split(str,">")
    local content_f = content[1]
    if content[2] == nil then
        content[2] = "测试跑马灯"
    end
    local wechat_str = string.split(content_f,"<")
    local wechat_list = wechat_str[2]
    local wechat_id_list = string.split(wechat_list,",")
    self.wechat_id_list = wechat_id_list
    self.marqueeTime = wechat_id_list[1] or 60
    
    local index = self.index or math.random(2,#wechat_id_list)
    if wechat_id_list[index] == nil then
        wechat_id_list[index] = "测试跑马灯"
    end
    local contentTab = wechat_str[1]..wechat_id_list[index]..content[2]
    return contentTab 
end

--更新电量
function HallMain:showBrocast()
    local content = kServerInfo:getAdTxt();
    content = self:getMarqueeWechat(content)
    self.lb_notice = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_notice");
    self.lb_notice:stopAllActions();
    self.lb_notice:setString(content);
    self.lb_notice:setPosition(cc.p(600, 20));
    local size = self.lb_notice:getContentSize();
    local moveX = -600 - size.width;
    local showTime = -moveX/100;
        transition.execute(self.lb_notice, cc.MoveBy:create(showTime, cc.p(moveX, 0)), {
            onComplete = function()
                self:showBrocast(); 
            end
        }); 

    if(self.m_timer_marquee == nil) then

        local function updateMarqueeWechat(  )
            local index = math.random(2,#self.wechat_id_list)
            while index == self.index and #self.wechat_id_list ~= 2 do
                index = math.random(2,#self.wechat_id_list)
            end
            self.index = index            
        end
       self.m_timer_marquee = require ("app.common.TimerProxy").new();
       self.m_timer_marquee:addTimer("marquee_wechatId_update_timer",updateMarqueeWechat, tonumber(self.marqueeTime), -1);
       updateMarqueeWechat()
    end
end

--返回
function HallMain:keyBack()
    local data = {}
    data.type = 2;
    data.title = "提示";                        
    data.yesTitle  = "退出";
    data.cancelTitle = "取消";
    data.content = "确定要退出游戏吗？";
    data.yesCallback = function()
        MyAppInstance:exit();
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

--返回网络图片
function HallMain:onResponseNetImg(fileName)
    Log.i("------HallMain:onResponseNetImg fileName", fileName);
     Log.i("------HallMain:onResponseNetImg fileName", fileName);
    if fileName == nil then
        return;
    end
    if fileName == kUserInfo:getUserId() .. ".jpg" then
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        if io.exists(headFile) then
            self.img_head:loadTexture(headFile);
        end 
    elseif kServerInfo:getMainAdUrl1() == fileName then
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        if io.exists(imgFile) then
            if IS_YINGYONGBAO == false then
                self.btn_ad:loadTexture(imgFile);
            end
        end 
    end
end

--获取链接传递的房间号
function HallMain:getEnterCode()
    --不在房间内
    if not UIManager.getInstance():getWnd(FriendRoomScene) then
        local data = {};
        data.cmd = NativeCall.CMD_GET_ENTERCODE;
        NativeCall.getInstance():callNative(data, HallMain.getEnterCodeCallback, self);
    end
end

function HallMain:getEnterCodeCallback(info)
    Log.i("------getEnterCodeCallback info", info);
    if info and info.enterCode then
        --直接进入房间
        if info.enterCode then
            self.m_enterRoomNum = info.enterCode;
            local tmpData={}
            tmpData.pa = tonumber(info.enterCode);
            FriendRoomSocketProcesser.sendRoomEnter(tmpData)
            LoadingView.getInstance():show("正在查找房间,请稍后......");
        end
    end
end

--个人基本信息
function HallMain:repUserInfo1(info)
    if info.code == CODE_TYPE_INSERT then
       
    elseif info.code == CODE_TYPE_UPDATE then
        
    end
    self:updateUserInfo(info)
end

--更新用户信息
function HallMain:updateUserInfo(info)
    local userInfo = kUserInfo:getUserInfo()
    Log.i("userInfo.........", table.nums(userInfo),userInfo)
    if (userInfo == nil or table.nums(userInfo)<=0) and info ~= nil then
        kUserData_userInfo:syncData(info.code, info.content);
        userInfo = kUserInfo:getUserInfo()
    end
    local createTime = kUserInfo:getUserCreateTime()
    local osTime = os.time()
    local updateTime = tonumber(osTime) - (tonumber(createTime)/1000)
   
    --先设置框的层级然后把默认头像放到层级之下头像之上
    local head_frame = ccui.Helper:seekWidgetByName(self.img_head,"head_frame")
    head_frame:setLocalZOrder(2)
    self:removeMoRneHead()
    if createTime ~= 0 and updateTime < GAME_HEAD_UPDATE_TIME then
        
        local moren_head_img = "hall/Common/moren_man_head.png"
--        Toast.getInstance():show("kUserInfo:getUserSex()......."..kUserInfo:getUserSex())
        if kUserInfo:getUserSex() == 2 then
            moren_head_img = "hall/Common/moren_woman_head.png"
        end
        self.moren_head = display.newSprite(moren_head_img)
        local frameSize = self.img_head:getContentSize()
        self.moren_head:setName("moren_head")
        self.moren_head:setScale(0.6)
        self.moren_head:addTo(self.img_head,1)
        self.moren_head:setPosition(cc.p(frameSize.width/2,frameSize.height/2))
        
        self.setMorenHeadThread = scheduler.performWithDelayGlobal(function ()
            self:removeMoRneHead();
        end, GAME_HEAD_UPDATE_TIME-updateTime);
    end
    self.nickName:setString(kUserInfo:getUserName());
    self.money:setString(kUserInfo:getPrivateRoomDiamond());
    self.lb_id:setString("ID:".. kUserInfo:getUserId());
    local ip = PLAYER_IP or kUserInfo:getUserIp()
    self.label_ip:setString("IP:"..ip);
    local imgUrl = kUserInfo:getHeadImg();
    Log.i("------imgUrl", imgUrl);
    if string.len(imgUrl) > 4 then
        local imgName = kUserInfo:getUserId() .. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            self.img_head:loadTexture(headFile);
        else
            HttpManager.getNetworkImage(imgUrl, kUserInfo:getUserId() .. ".jpg");
        end
    else
        local headFile = "hall/Common/default_head_2.png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            self.img_head:loadTexture(headFile);
        end
    end
	
	if(kFriendRoomInfo:isFreeActivities()) then --如果有活动
	    self.activeLable:setVisible(true)
	else --"N"
	    self.activeLable:setVisible(false)
	end
end
function HallMain:removeMoRneHead()
    if self.moren_head then
        self.moren_head:removeFromParent()
        self.moren_head = nil
    end
    if self.setMorenHeadThread then
        scheduler.unscheduleGlobal(self.setMorenHeadThread);
    end
end
--个人扩展信息
function HallMain:repUserInfo2(info)
    ---保存选择的城市id
    if info and info.content and info.content[1].preferredCity then
        local cityId = info.content[1].preferredCity
        SettingInfo.getInstance():setSelectAreaPlaceID(cityId)
        if cityId == 0 then            
            SettingInfo.getInstance():setClubGuidance(true) -- 新用户不显示亲友圈提示
        else -- 选择过城市, 提示亲友圈
            self:addQinyouquan()
        end
    end
end

--个人账户信息
function HallMain:repUserInfo3()
    self.money:setString(kUserInfo:getPrivateRoomDiamond());
end

function HallMain:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", "hall");
        if pWidget == self.btn_new then
            if not IS_YINGYONGBAO and kLoginInfo:getIsReview() and not kLoginInfo:getLastAccount() then
                SocketManager.getInstance():closeSocket();
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);
                Toast.getInstance():show("请用微信登录游戏");
                return;
            end
		    if(kUserInfo:getPrivateRoomDiamond() < 1 and kFriendRoomInfo:isFreeActivities()==false) then
                local data = {}
				data.type = 1;
				local content =kFriendRoomInfo:getRoomBaseInfo().roomFeeTip; --kServerInfo:getRechargeInfo();
                data.content = self.diamond_str_data.content or content
				UIManager.getInstance():pushWnd(CommonDialog, data); 
            else 
				UIManager:getInstance():pushWnd(FriendRoomCreate);
				
            end
		elseif pWidget == self.btn_join then
            if not IS_YINGYONGBAO and kLoginInfo:getIsReview() and not kLoginInfo:getLastAccount() then
                SocketManager.getInstance():closeSocket();
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);
                Toast.getInstance():show("请用微信登录游戏");
                return;
            end
		    UIManager:getInstance():pushWnd(FriendRoomCode);
        elseif pWidget == self.btn_record then
            UIManager:getInstance():pushWnd(RecordDialog);
        elseif pWidget == self.btn_help then
            UIManager:getInstance():pushWnd(RuleDialog);
        elseif pWidget == self.btn_share then
            UIManager:getInstance():pushWnd(ShareDialog);
        elseif pWidget == self.btn_setting then
            local data = self.data
            data.openId = 1
            UIManager:getInstance():pushWnd(HallSetDialog, data);
        elseif pWidget == self.btn_newer then
            UIManager.getInstance():pushWnd(NewerTipsWnd);
        elseif pWidget == self.btn_exchange then
            Log.i("btn_exchange")
            local unionId = cc.UserDefault:getInstance():getStringForKey("union_id", "")
            if unionId == "" then
                self:showExitDialog()
            else
                UIManager.getInstance():pushWnd(ExchangeDialog)
            end
        elseif pWidget == self.btn_focusDiamond then
            Log.i("btn_focusDiamond", self.hideBtn)
            local data = {}
            data.gotExchangeCode = cc.UserDefault:getInstance():getBoolForKey("gotExchangeCode", false)
            UIManager.getInstance():pushWnd(FocusForDiamond, data)
        elseif pWidget == self.btn_money then

            if IS_YINGYONGBAO then
                return
            end
            if IS_IOS_PRODUCT 
                and G_OPEN_CHARGE and type(IosChargeList) == "table" and ChargeIdTool.checkIosLocalConfig() then
                UIManager.getInstance():pushWnd(quickpayment);
--                local data = {}
--                data.type = 2;
--                data.content = "您将花12元购买6个钻石，是否确定购买？";
--                data.yesCallback = function ()
--                    LoadingView.getInstance():show("正在获取支付信息,请稍后...");
--                    local data = {};
--                    data.cmd = NativeCall.CMD_CHARGE;
--                    data.type = 4;
--                    if CONFIG_GAEMID == 10008 then
--                        data.product = 10071 .. "";
--                    elseif CONFIG_GAEMID == 10007 then
--                        data.product = 10070 .. "";
--                    elseif CONFIG_GAEMID == 10019 then
--                        data.product = 10072 .. "";
--                    elseif CONFIG_GAEMID == 10020 then
--                        data.product = 10073 .. "";
--                    elseif CONFIG_GAEMID == 10022 then
--                        data.product = 10077 .. "";
--                    elseif _gameType == "huainanmj" then
--                        data.product = 10074 .. "";
--                    elseif _gameType == "hongzhongmj" then
--                        data.product = 10076 .. "";
--                    end
--                    NativeCall.getInstance():callNative(data, GameManager.getInstance().sendIOSCharge, GameManager.getInstance());
--                end
--                UIManager.getInstance():pushWnd(CommonDialog, data); 
            else
                -- local data = self.data
                local data = self:resetRechargeInfo(kFriendRoomInfo:getRoomBaseInfo().roomFeeTip)
                -- Log.i("AddMoneyDialog..............",data)
                UIManager.getInstance():pushWnd(AddMoneyDialog, data); 
            end
        elseif pWidget == self.btn_kefu then
            local data = self.data
            UIManager.getInstance():pushWnd(AddMoneyDialog, data);
        elseif pWidget == self.btn_ad then
            UIManager:getInstance():pushWnd(FriendRoomRedPacket);
        elseif pWidget == self.btn_diamond then
            UIManager:getInstance():pushWnd(FreeShareDialog);
        end
    end
end

function HallMain:resetRechargeInfo(str_data)

    local data = {}
    local str = str_data or kServerInfo:getRechargeInfo()
    Log.i("str.......",str)
    data.type = 1;
    data.content = "";
    local contentTab = string.split(str, "|");
    if not contentTab then
        return data 
    end

    local str = ""
    for k,v in pairs(contentTab) do 
        local value = self:getRechargeWechat(v,k)
        str = str .. value  .. "\n"
    end
    data.content = str 
    return data 
end

function HallMain:getRechargeWechat(str,wechat_tag)
    local pos = string.find(str,"<")
    if not pos then
        return str
    end

    local strlist = string.split(str,"<")
    local weixinhao = strlist[#strlist]
    local weixinlist = string.split(weixinhao,",")
    local weixinhao1 = weixinlist[#weixinlist]
    weixinhao1 = string.sub(weixinhao1,1,-2)
    weixinlist[#weixinlist] = weixinhao1
  
    self.updateTime = weixinlist[1]
    local selectWechatId = math.random(2,#weixinlist)

    if wechat_tag == 1 then
        while self.keFuWechatId == selectWechatId and #weixinlist ~= 2 do
            selectWechatId = math.random(2,#weixinlist);
        end
        self.keFuWechatId = selectWechatId
    else
        while self.daiLiWechatId == selectWechatId and #weixinlist ~= 2 do
            selectWechatId = math.random(2,#weixinlist);
        end          
        self.daiLiWechatId = selectWechatId
    end

    return strlist[1]..weixinlist[selectWechatId]
end


function HallMain:updateRechargeWechat()
    local updateTime = self.updateTime or 5
    local function updateWechatId() 
        local data = self:resetRechargeInfo()
        updateTime = self.updateTime
        self.data = data
        -- local AddMoneyDialog = UIManager.getInstance():getWnd(AddMoneyDialog);
        -- if AddMoneyDialog then
        --     AddMoneyDialog:updateWechatId(data.content)
        -- end

        local diamond_str_data = self:resetRechargeInfo(kFriendRoomInfo:getRoomBaseInfo().roomFeeTip)
        self.diamond_str_data = diamond_str_data
    end    

    if(self.m_timer_wechat == nil) then
       self.m_timer_wechat = require ("app.common.TimerProxy").new();
       self.m_timer_wechat:addTimer("reachre_wechatId_update_timer", updateWechatId, tonumber(updateTime), -1);
       updateWechatId();
    end
end

--进入游戏
function HallMain:enterGame(data)
    local gameInfo = kGameManager:getGameInfo(data.gaI);
    ----------暂时用来测试---------------
    local pathName = gameInfo.clP;
    
    
    local gameName = string.upper(pathName);
    
    local gameConfig = "app.games." .. pathName .. "/GameConfig";
    package.loaded[gameConfig] = nil;

    local isSuccess, errMsg = pcall(require, gameConfig);
    if not isSuccess then
        Toast.getInstance():show("请先下载此游戏！");
        return;
    end

    local gameConfig = "app.games." .. pathName .. "." .. gameName .. "Config";
    package.loaded[gameConfig] = nil;
    require(gameConfig);
    enterGame(data);
end

--进入房间结果
function HallMain:repGameStart(packetInfo)
    Log.i("repGameStart", packetInfo);

    if packetInfo.ty == 0 and packetInfo.re == 1 then
        self:enterGame(packetInfo);
    end
    LoadingView.getInstance():hide();
end

--恢复游戏对局结果
function HallMain:repResumeGame(packetInfo)
    Log.i("repResumeGame", packetInfo);
    LoadingView.getInstance():hide();
    if packetInfo.re == 1 then
        packetInfo.roI = self.m_roI;
        packetInfo.gaI = self.m_gaI
        packetInfo.isRusumeGame = true
		kGameManager:enterFriendRoomGame(packetInfo);
        --self:enterGame(data);
    else
        Toast.getInstance():show("恢复游戏对局失败");
    end
end

--通知
function HallMain:repBrocast(packetInfo)
    Log.i("repBrocast", packetInfo);
    if packetInfo.ti == 3 then
        --修改昵称失败
        Toast.getInstance():show(packetInfo.co);
    elseif packetInfo.ti == 4 then
        LoadingView.getInstance():hide();
        SocketManager.getInstance():closeSocket();

        local data = {}
        data.type = 1;
        data.title = "提示";
        data.contentType = COMNONDIALOG_TYPE_KICKED;
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理";
        data.closeCallback = function ()
            if UIManager.getInstance():getWnd(HallMain) then 
                -- 在大厅
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);
            end
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif packetInfo.ti == 5 then
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        UIManager.getInstance():pushWnd(CommonDialog, data);
    end
end

function HallMain:repAdTxt(packetInfo)
--    Toast.getInstance():show(packetInfo.co)
    if not IS_YINGYONGBAO then
        kServerInfo:setAdTxt(packetInfo.co);
        self:showBrocast();
    end
end

--朋友开房
function HallMain:onClickFriendRoom(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    self.m_startGameType=2;--标示点击了开始朋友开房游戏
		local tmpData={}
		HallSocketProcesser.sendPlayerGameState(tmpData)
    end 
end

--接收朋友开房信息
function HallMain:recvFriendRoomStartGame(packetInfo)
 	Log.i("游戏恢复对局中。。。。。")
	kFriendRoomInfo.m_isFriendRoom = StartGameType.FIRENDROOM --设置游戏是从朋友开房进入
	
	local data = {};
	data.plI = packetInfo.plI;
	SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME, data);
end

--充值结果
function HallMain:recChargeResult(info)
    LoadingView.getInstance():hide();
    Toast.getInstance():show("购买成功");
end

--获取订单号
function HallMain:recOrder(info)
    LoadingView.getInstance():hide();
    kGameManager:reCharge(info);
end

--开始常规游戏
function HallMain:startCommonGame()
	 kGameManager:enterGame(self.m_gameId, self.m_selectRoomID);
end

--开始朋友开房游戏
function HallMain:startFriendRoomGame()
	--如果当前玩家在开房过程中，没有等当局游戏结束，刚进入到开房进行游戏状态
	local tmpData={}
    FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);	
end

--恢复游戏对局UI点击确定按钮回调
function HallMain:recoveryCallBackFun(packetInfo)
   --##  self.m_gameType  游戏类型(0:大厅  1:普通子游戏 2:朋友开房 3:比赛)
   self.m_isRecovery = true;
   LoadingView.getInstance():show();
   if(packetInfo.gaT == 1) then 
		local roomListInfo = kGameManager:getRoomListInfo(packetInfo.gaI);
		if roomListInfo and #roomListInfo <=0 then
			local data = {};
			data.gaI = packetInfo.gaI;
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ROOMLIST, data);--请求房间信息	
        else
            local data = {};
            data.plI = packetInfo.plI;
            SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME, data);
		end
	elseif(packetInfo.gaT == 2 )then --请求朋友开房信息
	    local tmpData={}
	    FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);	
	end
end

--显示恢复对局对话框
function HallMain:showRecoveryDialog(packetInfo)
	local data = {}
    data.type = 2;
    data.title = "提示";                        
    data.yesTitle  = "继续游戏";
    data.cancelTitle = "关闭";
    data.content = "您有未结束的的游戏对局，是否继续游戏？";
    data.yesCallback = function()
	    self:recoveryCallBackFun(packetInfo)
    end
	
    UIManager.getInstance():pushWnd(CommonDialog, data);
    self.m_gaI = packetInfo.gaI;
    self.m_roI = packetInfo.roI;
    self.m_plI = packetInfo.plI;
end

--恢复游戏对局
function HallMain:recvPlayerGameState(packetInfo)
    --##  gaT  int   游戏类型(0:大厅  4:在房间,5：游戏内
    LoadingView.getInstance():hide();
	if(4 == packetInfo.gaT) then--房间内
        if UIManager.getInstance():getWnd(FriendRoomScene) then
            UIManager.getInstance():popToWnd(HallMain);
        end 
        self:removeMoRneHead()
        UIManager:getInstance():pushWnd(FriendRoomScene);
	elseif(5 == packetInfo.gaT) then--游戏内
	    self.m_gaI = packetInfo.gaI;
        self.m_roI = packetInfo.roI;
        self.m_plI = packetInfo.plI;
	    local tmpData={}
	    FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);	
    else
        self:getEnterCode();
	end
end

--服务器配置信息
function HallMain:repServerInfo(packetInfo)
    Log.i("HallMain:repServerInfo......",packetInfo)
    local imgName = kServerInfo:getMainAdUrl1();
    Log.i("-----imgName.....",imgName)
    if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgFile) then
            if IS_YINGYONGBAO == false then 
                self.btn_ad:loadTexture(imgFile);
            end
        else
            HttpManager.getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName);
        end
    end
    self.data = self:resetRechargeInfo()
    self:updateRechargeWechat()
end

--邀请房信息（创建成功， 回复已创建房间）
function HallMain:recvRoomSceneInfo(packetInfo)
    if self.m_enterRoomNum then
        LoadingView.getInstance():hide();
        self.m_enterRoomNum = nil;
        local data = {};
        data.isFirstEnter = true;
        UIManager.getInstance():popToWnd(HallMain);
        self:removeMoRneHead()
        UIManager.getInstance():pushWnd(FriendRoomScene, data);
    else
        LoadingView.getInstance():show("正在进入房间，请稍后...");
    end
    
end

--邀请房配置
function HallMain:recvRoomConfig(packetInfo)
    if not tolua.isnull(self.activeLable) then
        if kFriendRoomInfo:isFreeActivities() then --如果有活动
	        self.activeLable:setVisible(true)
	    else
	        self.activeLable:setVisible(false)
	    end
    end
    
    
    --不是正在提审的包
    if kFriendRoomInfo:getReViewVersion() ~= VERSION then
        kLoginInfo:setIsReview();
    end
end

function HallMain:recvGetRoomEnter(packetInfo)
    --## re  int  结果（-2 = 无可用房间，1 成功找到）
    if(-1 == packetInfo.re) then
        LoadingView.getInstance():hide();
        Toast.getInstance():show("人数已满");
    elseif(-2 == packetInfo.re) then
        LoadingView.getInstance():hide();
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.closeTitle = "房间";
        data.content = "房间不存在";
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif packetInfo.re == 1 then
        kFriendRoomInfo:saveNumber(self.m_enterRoomNum);
    end
end

-- 礼包数据
function HallMain:onRecvGiftInfo(info)
    if info.code == CODE_TYPE_UPDATE then
        for k, v in pairs(info.content) do
            if v.status == 2 and v.keyID == kGiftData_logicInfo:getShareGiftKeyId() then
                CommonAnimManager.getInstance():showMoneyWinAnim(100);
                self:removeMoRneHead()
                UIManager.getInstance():popToWnd(HallMain);
            end
        end
    end
end

function HallMain:repHallRefreshUI(info)
    Log.i("HallMain:repHallRefreshUI", info)
    -- coB  int   是否显示兑换码按钮(0:不显示 1:显示 -1:不修改状态)
    if _gameType == "huaibeimj" then
        info.coB = 0 -- 蚌埠暂时关掉按钮
        info.weFB = 0 -- 蚌埠暂时关掉按钮
    end
    if self.btn_exchange and info.coB then
        if info.coB == 0 then
            self.btn_exchange:setVisible(false)
            cc.UserDefault:getInstance():setBoolForKey("btn_exchange", false)
        elseif info.coB == 1 then
            self.btn_exchange:setVisible(true)
            cc.UserDefault:getInstance():setBoolForKey("btn_exchange", true)
        elseif info.coB == -1 then
            -- 暂时什么也不做
        end
    end

    -- weFB  int   是否显示关注按钮(0:不显示 1:显示 -1:不修改状态)
    if self.btn_focusDiamond and info.weFB then
        if info.weFB == 0 then
            self.btn_focusDiamond:setVisible(false)
            cc.UserDefault:getInstance():setBoolForKey("btn_focusDiamond", false)
        elseif info.weFB == 1 then
            self.btn_focusDiamond:setVisible(true)
            cc.UserDefault:getInstance():setBoolForKey("btn_focusDiamond", true)
        elseif info.weFB == -1 then
            -- 暂时什么也不做
        end
    end

    -- weF  int   是否已关注微信公众号(0:未领取兑换码 1:已领取兑换码 -1:不修改状态)
    if info.weF == 0 then
        -- self.gotExchangeCode = false
        cc.UserDefault:getInstance():setBoolForKey("gotExchangeCode", false)
    elseif info.weF == 1 then
        -- self.gotExchangeCode = true
        cc.UserDefault:getInstance():setBoolForKey("gotExchangeCode", true)
    elseif info.weF == -1 then
        -- 暂时什么也不做
    end
end

function HallMain:showExitDialog()
    local data = {}
    data.type = 2;
    data.title = "提示";
    data.yesTitle  = "退出";
    data.cancelTitle = "取消";
    data.content = "您很久未微信授权登录游戏了，重新登录才能成功兑换奖励。\n点击确定即可重新登录。";
    data.yesCallback = function()
        -- 退出登录的函数
        --umeng退出统计
        local data = {};
        data.cmd = NativeCall.CMD_UMENG_LOGIN_OFF;
        data.usI = kUserInfo:getUserId() .. "";
        data.type = 2;
        NativeCall.getInstance():callNative(data);

        -- 退出到登录
        SocketManager.getInstance():closeSocket();
        kLoginInfo:clearAccountInfo();
        cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
        cc.UserDefault:getInstance():setStringForKey("wx_name", "");
        local info = {};
        info.isExit = true;
        UIManager.getInstance():replaceWnd(HallLogin, info);
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 微信号轮换 youme
function HallMain:addWechatId(parent, posX, posY)
    kWechatId1, kWechatId2 = "", "";
    -- majiang001
    local wechatIdStrLb = display.newTTFLabel({
        text = kWechatId1.." "..kWechatId2,
        font = "Arial",
        size = 22,
    });
    wechatIdStrLb:setAnchorPoint(0, 0.5)
    wechatIdStrLb:setPosition(posX, posY);
    wechatIdStrLb:addTo(parent);
    -- local url = "http://192.168.1.44:8081/dsqp_config66/webapi/adwechat/adimg.do?gameId="..CONFIG_GAEMID;
    local url = "http://lailai.stevengame.com:8081/dsqp_configll/webapi/adwechat/adimg.do?gameId="..CONFIG_GAEMID;
    HttpManager.getWechatIdData(url, wechatIdStrLb);
end

function HallMain:exchangeWechatId(arr, interval, wechatIdStrLb)
    -- 更新数据计时器
    local function updateWechatId() 
        --解析随机获取微信号组
        local index = math.random(#arr);
        if #arr > 1 then
            while (kWechatId1.."&"..kWechatId2) == arr[index] do
                index = math.random(#arr);
            end            
        end


        local retArr = Util.stringSplit(arr[index], "&");
        kWechatId1 = retArr[1] or ""
        kWechatId2 = retArr[2] or ""

        --刷新value
        wechatIdStrLb:setString(kWechatId1.."  "..kWechatId2);
        local friendRoomRedPacket = UIManager.getInstance():getWnd(FriendRoomRedPacket);
        if friendRoomRedPacket then
            friendRoomRedPacket:updateWechatId();
        end
    end    

    if(self.m_timerProxy == nil) then
       self.m_timerProxy = require ("app.common.TimerProxy").new();
       self.m_timerProxy:addTimer("wechatId_update_timer", updateWechatId, tonumber(interval), -1);
       -- self.m_timerProxy:addTimer("wechatId_update_timer", updateWechatId, 2, -1);
       updateWechatId();
    end
end


HallMain.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_USERDATA_USERINFO]      = HallMain.repUserInfo1;
    [HallSocketCmd.CODE_USERDATA_EXT]           = HallMain.repUserInfo2;
    [HallSocketCmd.CODE_USERDATA_POINT]         = HallMain.repUserInfo3;
    [HallSocketCmd.CODE_USERDATA_QUEST]         = HallMain.onRecvGiftInfo;
    [HallSocketCmd.CODE_REC_SERVERINFO]         = HallMain.repServerInfo;
    
    [HallSocketCmd.CODE_REC_RESUMEGAME]     = HallMain.repResumeGame;
    [HallSocketCmd.CODE_REC_GAMESTART]      = HallMain.repGameStart;
    [HallSocketCmd.CODE_REC_BROCAST]        = HallMain.repBrocast;
    [HallSocketCmd.CODE_REC_AD_TXT]   = HallMain.repAdTxt;
    [HallSocketCmd.CODE_REC_CHARGERESULT]   = HallMain.recChargeResult;
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START]  = HallMain.recvFriendRoomStartGame;--接收朋友开房信息
	[HallSocketCmd.CODE_PLAYER_ROOM_STATE]       = HallMain.recvPlayerGameState;--有未完成对局,恢复游戏对局提示
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO]  = HallMain.recvRoomSceneInfo; --InviteRoomInfo   邀请房信息
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_CONFIG] = HallMain.recvRoomConfig; 	--邀请房配置
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = HallMain.recvGetRoomEnter; --InviteRoomEnter  进入邀请房结果
    [HallSocketCmd.CODE_REC_HALL_REFRESH_UI]  = HallMain.repHallRefreshUI;
};