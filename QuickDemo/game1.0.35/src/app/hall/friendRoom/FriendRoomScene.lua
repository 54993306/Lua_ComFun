local Deque = require("app.hall.common.Deque")
local ShareToWX = require "app.hall.common.ShareToWX"
local choiceShare = require("app.hall.common.share.choiceShare")
--房间UI
FriendRoomScene = class("FriendRoomScene", UIWndBase);

function FriendRoomScene:ctor(data)
    self.super.ctor(self, "hall/friendRoomScene.csb", data);
    self.m_sayQueue = Deque.new();
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    --有人正在说话
    self.m_speaking = false;
    self.m_speakTable = {};
    self.m_headImage = {}
    self.m_headIndex = {}
end

function FriendRoomScene:onClose()
    if self.moren_head then
        self.moren_head = nil
    end
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end

    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end

    self:closeEditBox()
end
function FriendRoomScene:closeEditBox()
    local data = {};
    data.cmd = NativeCall.CMD_CLOSEEDITBOX;
    NativeCall.getInstance():callNative(data);
end

function FriendRoomScene:onInit()
    self.m_roomInfo = kFriendRoomInfo:getRoomInfo()

    --退出房间
    self.cancleBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "cancleBtn");
    self.cancleBtn:addTouchEventListener(handler(self, self.onCloseRoomButton));

    --本场玩法
    self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_sure");
    self.btn_sure:addTouchEventListener(handler(self, self.onClickButton));

    --微信邀请
    self.shardBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "shardBtn");
    self.shardBtn:addTouchEventListener(handler(self, self.onClickButton));

    self.sendPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "sendPanel");
    self.soundPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "soundPanel");
    self.soundPanel:setVisible(false);

    self.soundBtn= ccui.Helper:seekWidgetByName(self.m_pWidget, "soundBtn");
    self.soundBtn:addTouchEventListener(handler(self, self.onClickSoundButton));
    --self.soundBtn:setVisible(false);

    self.sayBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "sayBtn");
    self.sayBtn:addTouchEventListener(handler(self, self.onSayButton));

    self.sendMsgBtn= ccui.Helper:seekWidgetByName(self.m_pWidget, "sendMsgBtn");
    self.sendMsgBtn:addTouchEventListener(handler(self, self.onMsgButton));

    self.beginSayBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "beginSayBtn");
    self.beginSayBtn:addTouchEventListener(handler(self, self.onTouchSayButton));
    self.beginSayTxt = ccui.Helper:seekWidgetByName( self.beginSayBtn, "txt");
    self.beginSayTxt:setString("按住 说话");

    self.img_mic = ccui.Helper:seekWidgetByName(self.m_pWidget, "mic");

    local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");
    title:loadTexture(_gameTitlePath);

    --手指动画
    local signImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "signImg");
    local sequence = transition.sequence({
    				cc.MoveBy:create(0.3, cc.p(15,0)),
    				cc.MoveBy:create(0.3, cc.p(-15,0))
    });
    signImg:runAction(cc.RepeatForever:create(sequence));

    --红包
    self.redPackBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "redPackBtn");
    self.redPackBtn:addTouchEventListener(handler(self, self.onClickButton));
    local sequence = transition.sequence({
                    cc.ScaleTo:create(0.5, 0.9),
    				cc.ScaleTo:create(0.5, 1.2),
    				cc.ScaleTo:create(0.5, 1)
    });
    self.redPackBtn:runAction(cc.RepeatForever:create(sequence));

	self.sayListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "sayListView");
	self.sayListView:removeAllChildren();

    self.sayTextField = self:getWidget(self.m_pWidget, "sayTextField");

	--
	self.playerListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerListView");
	self.playerListView:removeAllChildren()
	local playerHeadPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerHeadPanel");
	self.m_playerHeadList = {};
    self.playerPanel = {}
	for i = 1, 4 do
      self.playerPanel[i] = playerHeadPanel:clone();
      self.playerListView:pushBackCustomItem(self.playerPanel[i]);
      self.m_playerHeadList[i] = FriendRoomPlayerHead.new(self, self.playerPanel[i]);
      if _isPositionVisible ~= false then
            self.playerPanel[i]:addTouchEventListener(handler(self, self.onClickPVButton));
      end
    end

	--
	local exitRoomLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "exitRoomLabel");
	local userID =kUserInfo:getUserId()
	local isRoom = kFriendRoomInfo:isRoomMain(userID)
	if(isRoom) then--如果是房主
	   exitRoomLabel:setString("解散房间")
	else
	   exitRoomLabel:setString("退出房间")
	end

    self:updateUI()

end
function FriendRoomScene:setMoRenHead(playerInfo,index)
    if self.moren_head == nil then
        self.moren_head = {}
    end
    if self.setMorenHeadThread == nil then
        self.setMorenHeadThread = {}
    end
    if self.moren_head[index] then
        self.moren_head[index]:removeFromParent()
        self.moren_head[index] = nil
    end
    if playerInfo ~= nil then
        local createTime = playerInfo.crT or 0
        local osTime = os.time()
        local updateTime = tonumber(osTime) - (tonumber(createTime)/1000)
        if createTime ~= 0 and updateTime < GAME_HEAD_UPDATE_TIME then
            local moren_head_img = "hall/Common/moren_man_head.png"
    --            Log.i("kUserInfo:getUserSex().......",kUserInfo:getUserSex())
            if kUserInfo:getUserSex() == 2 then
                moren_head_img = "hall/Common/moren_woman_head.png"
            end
            local headImg = self.m_playerHeadList[index]:getHeadImg();
            self.moren_head[index] = display.newSprite(moren_head_img)
            local frameSize = headImg:getContentSize()
            self.moren_head[index]:setName("moren_head")
            self.moren_head[index]:setScale(0.8)
            self.moren_head[index]:addTo(headImg,1)
            self.moren_head[index]:setPosition(cc.p(frameSize.width/2,frameSize.height/2))
            self.setMorenHeadThread[index] = scheduler.performWithDelayGlobal(function ()
                self:removeMoRneHead(index);
            end, GAME_HEAD_UPDATE_TIME-updateTime);
        end
    end

end
function FriendRoomScene:removeMoRneHead(index)
    if self.moren_head ~= nil and self.moren_head[index] then
        self.moren_head[index]:removeFromParent()
        self.moren_head[index] = nil
    end
    if self.setMorenHeadThread[index] then
        scheduler.unscheduleGlobal(self.setMorenHeadThread[index]);
        self.setMorenHeadThread[index] = nil
    end
end
function FriendRoomScene:onClickPVButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.playerPanel[1] then
            self:setPlayersPos(1)
        elseif pWidget == self.playerPanel[2] then
            self:setPlayersPos(2)
        elseif pWidget == self.playerPanel[3] then
            self:setPlayersPos(3)
        elseif pWidget == self.playerPanel[4] then
            self:setPlayersPos(4)
        end
    end
end
function FriendRoomScene:setPlayersPos(index)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local userID =playerInfos.owI
    local players = playerInfos.pl
    local other = {}
    local jindu = nil
    local weidu = nil
    local ipA = nil
    local wType = 1
    local headImage = nil
    local name = nil
    local crT = nil
    local index = index
    for i=1,#players do
        Log.i("i.....",i,userID,players[i])
        if players[i].we == index then
            jindu = players[i].jiD
            weidu = players[i].weD
            ipA = players[i].ipA
            wType = 1
            headImage = self.m_headImage[index]
            name = players[i].niN
            crT = players[i].crT or 0
            userID = players[i].usI
        else
            if other[i] == nil then
                other[i] = {}
            end
            other[i].lo =players[i].jiD
            other[i].la = players[i].weD
            other[i].name = players[i].niN
        end
    end
    local data = {type = wType,playerHeadImage = headImage,playerName = name,playerIP = ipA,lo = jindu,la = weidu,site = other,sex = kUserInfo:getUserSex(),crT = crT,index = index,panel = "FriendRoomScene",userid = userID}
    self.infoView = UIManager:getInstance():pushWnd(PlayerPosInfoWnd,data);
    self.infoView:setDelegate(self);
end
--增加阴影
function FriendRoomScene:onShow()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    --自己不是房主，提示玩法信息
    if self.m_data.isFirstEnter and playerInfos.owI ~= kUserInfo:getUserId() then
        UIManager:getInstance():pushWnd(FriendRoomEnterInfo);
    end
end

function FriendRoomScene:onMsgButton(pWidget, EventType)
  if EventType == ccui.TouchEventType.ended then
        local content = self.sayTextField:getText();

       if content and content ~= "" then
			--[[ type = 2,code=23000, 私有房聊天
			##  usI  int   玩家ＩＤ
			##  niN  String  玩家昵称
			##  roI  int  房间ID
			##  ty  int  类型 0文字 1语音
			##  co  String   chat 内容]]
			local tmpData={}
			tmpData.usI = kUserInfo:getUserId();
			tmpData.niN=kUserInfo:getUserName();
			tmpData.roI = kFriendRoomInfo:getRoomInfo().roI
			tmpData.ty=0
			tmpData.co=content
			FriendRoomSocketProcesser.sendSayMsg(tmpData)
             content = self.sayTextField:setText("");
        else
            Toast.getInstance():show("请输入聊天内容");
	 	end
  end

end


function FriendRoomScene:onSayButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.sayBtn then
    	    self.sendPanel:setVisible(true);
            self.soundPanel:setVisible(false);
	    end
    end
end

function FriendRoomScene:onTouchSayButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.began then
        if not self.m_isTouching then
            self.m_isTouchBegan = true;
            --开始录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data);
            self:showMic();
            self.beginSayTxt:setString("松开 发送");
        end

    elseif EventType == ccui.TouchEventType.ended then
        if self.m_isTouchBegan then
            --停止录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 1;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            self.beginSayTxt:setString("按住 说话");

            if YY_IS_LOGIN then
                self:getUploadStatus();
            else
                Toast.getInstance():show("功能未初始化完成，请稍后");
            end

            self.m_isTouchBegan = false;
            self.m_isTouching = true;
            self.m_pWidget:performWithDelay(function ()
                self.m_isTouching = false;
            end, 0.5);
        end

    elseif EventType == ccui.TouchEventType.canceled then
        if  self.m_isTouchBegan then
            --停止录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 0;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            self.beginSayTxt:setString("按住 说话");

            self.m_isTouchBegan = false;
        end
    end
end

function FriendRoomScene:showMic()
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function FriendRoomScene:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("hall/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function FriendRoomScene:hideMic()
    self.img_mic:setVisible(false);
    self.img_mic:stopAllActions();
end


function FriendRoomScene:onClickSoundButton(pWidget, EventType)
  if EventType == ccui.TouchEventType.ended then
    if pWidget == self.soundBtn then
        self.sendPanel:setVisible(false);
        self.soundPanel:setVisible(true);
	end
  end
end

function FriendRoomScene:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    Log.i("FriendRoomScene:onClickButton")
        if pWidget == self.btn_sure then
			UIManager:getInstance():pushWnd(FriendRoomEnterInfo);
        elseif(pWidget == self.sendMsgBtn) then --发送消息
		    local sayTextField = self.sayTextField:getText();
			if sayTextField == nil or sayTextField == "" then
			    Toast.getInstance():show("请输入聊天内容")
			    return
			end
			--type = 2,code=20015, 获取邀请房信息   client  <--> server
			local tmpData={}

			--FriendRoomSocketProcesser.sendRoomGetRoomInfo(tmpData)
		elseif(pWidget == self.redPackBtn) then--红包
		    UIManager:getInstance():pushWnd(FriendRoomRedPacket);

        elseif pWidget == self.dxBtn then

        elseif pWidget ==  self.shardBtn then
            local shareToWechat = function()
                self:onWxLogic(2)
            end
            local data = {}
            data.shareToWechat = shareToWechat
            data.type = "room" -- 房间等待界面的分享
            UIManager.getInstance():pushWnd(choiceShare, data)
        elseif pWidget == self.frientBtn then
		     self:onWxLogic(1)
        elseif pWidget == self.qqBtn then

        elseif pWidget == self.copyBtn then

	        local data = {};
			data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
			data.content  = string.format("%d",self.m_roomInfo.pa)--
			Log.i("copy code:" .. data.content)
			NativeCall.getInstance():callNative(data);
			Toast.getInstance():show("复制成功");
		elseif pWidget == self.wenHaoBtn then
		    local data = {};
			data.title = "客服问题";
			data.content = friendRoomContent
			LoadingView.getInstance():show("正在加载中");
			self.m_pWidget:performWithDelay(function()
              UIManager.getInstance():pushWnd(CommonTipsDialog, data)
              LoadingView.getInstance():hide()
            end, 0.1);
        end
    end
end

function FriendRoomScene:updateUI()
    local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
	local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo();

	--房间号
	local roomNumberLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "roomNumberLabel");
	roomNumberLabel:setString(string.format("%d", playerInfos.pa));
    self:playerListViewUpdate();

    local copyBtnLayout = ccui.Layout:create()
    -- local copyBtnLayout = display.newColorLayer(cc.c4b(100,100,100,255))
    copyBtnLayout:setContentSize(cc.size(200,50))
    roomNumberLabel:addChild(copyBtnLayout)
    copyBtnLayout:setPosition(cc.p(roomNumberLabel:getContentSize().width,
                                    -roomNumberLabel:getContentSize().height / 2 - 5))

    local copyRoomId = cc.Label:create()
    copyRoomId:setString("(复制房间号)")
    copyRoomId:setSystemFontSize(28)
    copyRoomId:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomId:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2))
    copyBtnLayout:addChild(copyRoomId)

    copyBtnLayout:setTouchEnabled(true)
    copyBtnLayout:setTouchSwallowEnabled(true)
    copyBtnLayout:addTouchEventListener(handler(self,self.onLabelClickButton));

    local copyRoomIdLine = cc.Label:create()
    copyRoomIdLine:setString("__________")
    copyRoomIdLine:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomIdLine:setSystemFontSize(28)
    copyRoomIdLine:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2 - 5))
    copyBtnLayout:addChild(copyRoomIdLine)
end


function FriendRoomScene:onCloseRoomButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		local data = {}
		data.type = 2;
		data.title = "提示";
		data.yesTitle  = "确定";
		data.cancelTitle = "取消";

		local userID =kUserInfo:getUserId()
		local isRoom = kFriendRoomInfo:isRoomMain(userID)
		if(isRoom) then--如果是房主
		  data.content = "您是否要解散房间?"
		else
		  data.content = "退出房间后如本房间仍有座位可重新进入房间!"
		end

		data.yesCallback = function()
		    local tmpData={}
			tmpData.usI= kUserInfo:getUserId()
		    FriendRoomSocketProcesser.sendRoomQuit(tmpData)
		end

		UIManager.getInstance():pushWnd(CommonDialog, data);
	end
end

function FriendRoomScene:onLabelClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        Log.i("onLabelClickButton........")
        local playerInfo = kFriendRoomInfo:getRoomInfo();

        local data = {};
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
        data.content  = string.format( "%s%s","【来来淮北麻将】",playerInfo.pa )
        Log.i("copy code",data.content)
        NativeCall.getInstance():callNative(data);
        Toast.getInstance():show("复制成功");
    end
end

--微信
function FriendRoomScene:onWxLogic(shardType)
    local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
    local playerInfo = kFriendRoomInfo:getRoomInfo();
	local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
    Log.i("selectSetInfo....",selectSetInfo)

    local data = {}

    data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    data.cmd = NativeCall.CMD_WECHAT_SHARE;
    local i, j = string.find(roomInfo.shareLink, "pkgname");
    if i and i > 0 then
        --应用宝地址直接使用
        data.url = roomInfo.shareLink;
    else
        --拼上房间号，用于直接进入房间
        -- data.url = roomInfo.shareLink .. "&code=" .. playerInfo.pa;

        -- if device.platform == "ios" then
        --     local subStrLength = string.find(roomInfo.shareLink, "?")
        --     local ioShareLink = string.sub( roomInfo.shareLink, 1,subStrLength )
        --     local iosUrl=ioShareLink .."open="..roomInfo.iosOpenurl.. CONFIG_GAEMID.."?code=" .. playerInfo.pa.. "&url="..roomInfo.iosurl..magicWindowUrl
        --     data.url = iosUrl
        -- else
        --     if roomInfo.landingPage ==nil  then
        --         roomInfo.landingPage=""
        --     end
        --     local socket = require("socket")
        --     local subStrLength = string.find(roomInfo.shareLink, "?")
        --     data.url = string.sub( roomInfo.shareLink, 1,subStrLength ) .. "gameID=".. GC_GameTypes[CONFIG_GAEMID] .. "&code=" .. playerInfo.pa .. "&time=".. socket:gettime()*10000 .."&url="..roomInfo.landingPage.."?".."gameId="..PRODUCT_ID..magicWindowUrl;
        -- end
        local shareType = ShareToWX.PaijuShareFriend
        if roomInfo.iosOpenurl and roomInfo.iosurl and roomInfo.landingPage then
            local subStrLength = string.find(roomInfo.shareLink, "?")
            local phpUrl = string.sub( roomInfo.shareLink, 1,subStrLength )
            -- local iosOpen = "iosOpen="..roomInfo.iosOpenurl.. CONFIG_GAEMID.."?code=" .. playerInfo.pa
            local iosOpen = "iosOpen="..WX_APP_ID.."://"
            local androidOpen = "gameID=".. MAGIC_WINDOWS_APP_NAME .. "&code=" .. playerInfo.pa .. "&time=".. socket:gettime()*10000
            local iosUrl = "iosUrl="..roomInfo.iosurl
            local androidUrl = "androidUrl="..roomInfo.landingPage.."?".."gameId="..PRODUCT_ID
            data.url=phpUrl..androidOpen.."&"..iosOpen.."&"..iosUrl.."&"..androidUrl..magicWindowUrl..shareType
        else
            data.url = roomInfo.shareLink .. "&code=" .. playerInfo.pa..shareType;
        end

        Log.i("--wangzhi--data.url--",data.url)
    end

    if(shardType==1) then
       data.type = 1--分享到朋友圈
    elseif(shardType==2) then
       data.type = 2--分享给朋友
    end

    data.headUrl = kUserInfo:getHeadImgSmall();

    LoadingView.getInstance():show("正在分享,请稍后...", 2);
    if data.headUrl and data.headUrl ~= "" then
        HttpManager.testUrlConnect(data.headUrl,
            function(event, code)
                Log.i("FriendRoomScene:onWxLogic testUrlConnect", event, code)
                if code ~= 200 then
                    data.headUrl = ""
                end
                self:shareToWx(data)
            end,
            3)
    else
        self:shareToWx(data)
    end
end

function FriendRoomScene:shareToWx(data)
    Log.i("--wangzhi--data--",data)
    Log.i(string.format("分享标题:") ..  data.title .. "/r/n 分享描述:" .. data.desc .. "/r/n 分享网址:" .. data.url .. "/r/n 分享头像:" .. data.headUrl);
    -- TouchCaptureView.getInstance():showWithTime()
    local callBack = function(info)
        Log.i("shard button:",info);
        LoadingView.getInstance():hide();
        if(info.errCode ==0) then --成功
            local data = {}
            data.wa = 3
            Log.i("--wangzhi--roomSharedata--",data)
            -- SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif (info.errCode == -8) then
            self.m_pWidget:performWithDelay(function()
                Toast.getInstance():show("您手机未安装微信");
            end, 0.1);
        else
            self.m_pWidget:performWithDelay(function()
                Toast.getInstance():show("邀请失败");
            end, 0.1);
        end
    end

    LoadingView.getInstance():show("正在分享,请稍后...", 2)
    WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.FRIEND_ROOM_FRIEND, callBack, ShareToWX.PaijuShareFriend, data)
end

function FriendRoomScene:recvRoomQuit(packetInfo)
   --##  usI  long  玩家id
   --re  int  结果（-1 失败，1 成功）
    if(packetInfo.re == 1) then

		local exitUserID = packetInfo.usI
		local localUserID = kUserInfo:getUserId()

		--如果是房主退出
		if(kFriendRoomInfo:isRoomMain(exitUserID)) then
            --玩法界面显示时，先关闭
            if UIManager.getInstance():getWnd(FriendRoomEnterInfo) then
                UIManager.getInstance():popToWnd(self);
            end

			if(exitUserID == localUserID) then--如果是房主
			   kFriendRoomInfo:clearData()
			   self:closeRoomSceneUI();
			   return
			else
				--房主已退出，此房间已经关闭，请选择其他游戏！确定
				local data = {}
				data.type = 1;
				data.title = "提示";
				data.closeTitle = "退出房间";
				data.content = "房间已解散";
				data.closeCallback = function ()
					kFriendRoomInfo:clearData()
					self:closeRoomSceneUI();
					return
				end

				UIManager.getInstance():pushWnd(CommonDialog, data);
			end

		else
			if(exitUserID ~= localUserID) then
                --别的玩家退出
    		   local playerName = packetInfo.niN;
    		   local str = string.format("%s已退出房间", playerName)
    		   --加到消息系统列表中。
               self:insertSayText(str, cc.c3b(0, 255, 0));
			else
			   kFriendRoomInfo:clearData()
			   self:closeRoomSceneUI();
			   return
			end
		end
	end
end

function FriendRoomScene:recvFriendRoomStartGame(packetInfo)
    Log.i("服务端检测到游戏要求人数已满，开始游戏...................")
    --玩法界面显示时，先关闭
    if UIManager.getInstance():getWnd(FriendRoomEnterInfo) then
        UIManager.getInstance():popToWnd(self);
    end
	UIManager:getInstance():popWnd(FriendRoomScene);
    kGameManager:enterFriendRoomGame(packetInfo);
end

function FriendRoomScene:recvRoomSceneInfo(packetInfo)
    Log.i("FriendRoomScene:recvRoomSceneInfo")
	self:playerListViewUpdate()
end

function FriendRoomScene:playerListViewUpdate()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    Log.i("FriendRoomScene:playerListViewUpdate...",playerInfos)
    for i = 1, #self.m_playerHeadList do
        local  headImg = self.m_playerHeadList[i]:getHeadImg();
        local  playerName = self.m_playerHeadList[i]:getPlayerName();
        local  leaveImg = self.m_playerHeadList[i]:getLeaveImg();
        local playerInfo = nil;
        for k, v in pairs(playerInfos.pl) do
            if v.we == i then
                playerInfo = v;
                break;
            end
        end
        if playerInfo then
            self:ipXiangTong(playerInfo,headImg)
            headImg:setVisible(true);
            playerName:setVisible(true);

		    local retName = ToolKit.subUtfStrByCn(playerInfo.niN,0,5,"")
            playerName:setString(retName);
            --玩家离线状态
            -- ##  st  int   是否在房间  0 在,1 =离开
            if(playerInfo.st ~= nil and playerInfo.st == 1) then
			   leaveImg:setVisible(true)
			else
			   leaveImg:setVisible(false)
			end

            --测试头像
            --playerInfo.heI = "http://wx.qlogo.cn/mmopen/ajNVdqHZLLCZHe0PtY7TzmVTYp94c8sDoyo9WN4FVmVz9iapgMqKjKCLWEdl6PU4ugBgwIu4j1wicKiaTpGdIcMqSpdDjRbF1SGdgPUiaJNWcWc/0";
            if playerInfo.heI and string.len(playerInfo.heI) > 4 then
                local imgName = playerInfo.usI .. ".jpg";
                local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
                self.m_headImage[i] = headFile
                if io.exists(headFile) then
                    headImg:loadTexture(headFile);
                else
				    self.netImgsTable[imgName] = {};
                    self.netImgsTable[imgName] = headImg
					self.m_headIndex[imgName] = i
                    HttpManager.getNetworkImage(playerInfo.heI, imgName);
                end
            else
                local headFile = "hall/Common/default_head_2.png";
                self.m_headImage[i] = headFile
                headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
                if io.exists(headFile) then
                    headImg:loadTexture(headFile);
                end
            end
        else
            headImg:setVisible(false);
            playerName:setVisible(false);
            leaveImg:setVisible(false);
            self.m_playerHeadList[i]:hideSpeaking();
        end

        self:setMoRenHead(playerInfo,i)
    end

end

function FriendRoomScene:onResponseNetImg(imgName)
    local  headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if self.m_headIndex[imgName] == nil then
        return
    end
    self.m_headImage[self.m_headIndex[imgName]] = imageName
    if io.exists(imageName) then
        headImg:loadTexture(imageName);
    end
end
--ip相同
function FriendRoomScene:ipXiangTong(playerInfo,head)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
	Log.i("playerInfos.....",playerInfos)
    local players = playerInfos.pl
    local myIp = playerInfo.ipA
	Log.i("myIp.....",myIp)
    local ipA = {}
    local player= 0
    local isIpHand = false
    for i=1,4 do
        if players[i] ~= nil and playerInfo.usI ~= players[i].usI then
            player = i
			Log.i("players[player]....",players[player],player)
            if players[player] ~= nil then
    --            ipA[i] = players[player].ipA
                if myIp == players[player].ipA then
                    self:drawIpXiangTong(head)
                    isIpHand = true
                end
            end
        end
    end
    if isIpHand == false then
        local headOneIp = head:getChildByName("ipxiangtong")
        if headOneIp ~= nil then
            headOneIp:removeFromParent()
        end
    end
end
function FriendRoomScene:drawIpXiangTong(head)
--    local head = self:getHead(site)
    local headOneIp = head:getChildByName("ipxiangtong")
    if headOneIp == nil then
        local ip = display.newSprite("games/common/mj/common/ipxiangtong.png")
        ip:setName("ipxiangtong")
        ip:addTo(head,10)
        local headSize = head:getContentSize()
        ip:setPosition(cc.p(headSize.width/2,headSize.height/2))
    end
end


function FriendRoomScene:closeRoomSceneUI(tmpData)

       UIManager:getInstance():popWnd(FriendRoomScene);
	   --当从游戏返回时,屏幕会黑屏
	   local tmpRet = UIManager:getInstance():getWnd(HallMain)
	   if(tmpRet==nil) then
			UIManager:getInstance():pushWnd(HallMain);
	   end
end

function FriendRoomScene:recvAddNewPlayerToRoom(packetInfo)
    local str = string.format("系统:玩家(%s)坐下", packetInfo.niN)
    self:insertSayText(str, cc.c3b(0, 255, 0));
end

--返回
function FriendRoomScene:keyBack()
   Log.i("FriendRoomScene:keyBack");
   self:onCloseRoomButton(self,ccui.TouchEventType.ended);
end

function FriendRoomScene:recvSayMsg(packetInfo)
    Log.i("------FriendRoomScene:recvSayMsg", packetInfo)
    if packetInfo.ty == 1 then
        if packetInfo.co then
            local status = kSettingInfo:getGameVoiceStatus()
            if status and packetInfo.usI ~= kUserInfo:getUserId() then

            else
                self:showSpeaking(packetInfo);
            end
        end
    else
        local str = string.format("%s: %s", packetInfo.niN, packetInfo.co)
        self:insertSayText(str, cc.c3b(66, 28, 0));
    end
end

--检测上传状态
function FriendRoomScene:getUploadStatus()
    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end
    self.m_getUploadThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end, 0.1);
end

function FriendRoomScene:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
        self.m_getUploadThread = nil;
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus", matchStr);

        --发送语音聊天
        if matchStr and kFriendRoomInfo:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = kUserInfo:getUserId();
            tmpData.niN = kUserInfo:getUserName();
            tmpData.roI = kFriendRoomInfo:getRoomInfo().roI;
            tmpData.ty = 1;
            tmpData.co = info.fileUrl;
            FriendRoomSocketProcesser.sendSayMsg(tmpData);
        end

    end
end

--检测播放状态
function FriendRoomScene:getSpeakingStatus()
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end
    self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end, 0.5);
end

function FriendRoomScene:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        -- if UIManager.getInstance():getWnd(HallMain) then
        --     local friendRoomScene = UIManager.getInstance():getWnd(FriendRoomScene);
        --     if friendRoomScene then
        --         friendRoomScene:hideSpeaking(info.usI);
        --     end
        -- else
        --     MjMediator:getInstance():on_hideSpeaking(data.usI);
        -- end

        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        self.m_getSpeakingThread = nil;

        self:hideSpeaking(info.usI);


    end
end

--显示正在说话
function FriendRoomScene:showSpeaking(packetInfo)
    if self.m_speaking or self.m_isTouchBegan then
        if #self.m_speakTable < 10 then
            table.insert(self.m_speakTable, packetInfo);
        end
    else
        local playerInfos = kFriendRoomInfo:getRoomInfo();
        for k, v in pairs(playerInfos.pl) do
            if v.usI == packetInfo.usI then
                if self.m_playerHeadList[v.we] then
                    self.m_speaking = true;
                    self.m_playerHeadList[v.we]:showSpeaking();
                    --
                    audio.pauseMusic();
                    --
                    local data = {};
                    data.cmd = NativeCall.CMD_YY_PLAY;
                    data.fileUrl = packetInfo.co;
                    data.usI = packetInfo.usI .. "";
                    NativeCall.getInstance():callNative(data);

                    self:getSpeakingStatus();

                    --防止没有收到播放结束回调
                    self.beginSayBtn:stopAllActions();
                    self.beginSayBtn:performWithDelay(function()
                        self:hideSpeaking();
                    end, 60);
                end

                break;
            end
        end
    end

end

--隐藏正在说话
function FriendRoomScene:hideSpeaking(userId)
    userId = userId or "0";
    Log.i("------hideSpeaking userId", userId)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    for k, v in pairs(playerInfos.pl) do
        if v.usI == tonumber(userId) then
            if self.m_playerHeadList[v.we] then
                self.m_playerHeadList[v.we]:hideSpeaking();
            end
            break;
        end
    end
    self.m_speaking = false;
    self:showNextSpeaking();
end

--隐藏正在说话
function FriendRoomScene:showNextSpeaking(userId)
    if not self.m_speaking or #self.m_speakTable > 0 then
        self:showSpeaking(table.remove(self.m_speakTable, 1));
    end
end


function FriendRoomScene:insertSayText(strText,color)
   local text = ccui.Text:create()
   text:setString(strText)
   text:setFontSize(32)
   text:setColor(color)
   text:setAnchorPoint(cc.p(0,0.5))
   local strTable={}
   while true do
		local labelStr,str=LibFont.subString(strText,550,text:getFontName(), text:getFontSize());
		strText = str;
		if labelStr == nil or labelStr == "" then
            break;
		else
            table.insert(strTable,labelStr);
		end
		if strText == nil or strText == "" then
			break;
		end
	end

	local cacheTable={}
	local nlen = #strTable
    local currentLen =nlen
	for i=1,nlen do
	    local str = strTable[currentLen]
		local text = ccui.Text:create()
		text:setString(str)
		text:setFontSize(32)
		text:setColor(color)
		text:setAnchorPoint(cc.p(0,0.5))
		--text:setTextAreaSize(cc.size(250,32))

		self.sayListView:insertCustomItem(text,0)
		self.sayListView:doLayout()

		currentLen= currentLen-1

		table.insert(cacheTable,text);--聊天条数超过20，任然有继续显示
	end

	--聊天条数超过20，任然有继续显示
	self.m_sayQueue:pushFront(cacheTable)
	if(self.m_sayQueue:size() >20) then
	    local tmpTable= self.m_sayQueue:back()
		for i=1,#tmpTable  do
		  local tmpIndex = self.sayListView:getIndex(tmpTable[i])
		  self.sayListView:removeItem(tmpIndex)
		end
	    self.m_sayQueue:popBack()
	end

end

FriendRoomScene.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = FriendRoomScene.recvRoomQuit; --InviteRoomEnter	 退出邀请房结果
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = FriendRoomScene.recvFriendRoomStartGame; --邀请房对局开始
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomScene.recvRoomSceneInfo; --InviteRoomEnter	邀请房信息
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_ADDPLAYER] = FriendRoomScene.recvAddNewPlayerToRoom; --新增玩家到房间
	[HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = FriendRoomScene.recvSayMsg; --私有房聊天
};
