--游戏基类
OpenRoomGame = class("OpenRoomGame",UIWndBase)

--构造函数
function OpenRoomGame:ctor(...)
    Log.i("OpenRoomGame:ctor")
    --占时用个空层
    self.super.ctor(self, "hall/null_layer.csb", ...);
    
	self.m_data = ...
	self.m_delegate = self.m_data.m_delegate
	self.roomGameType=self.m_data.roomGameType
	
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
	
    self.m_infoCache={} --网络信息缓存
	self.m_isShowGameOverUI = false --当前是否显示结算UI
	
	local tmpParam={}
	tmpParam.roomGameType = self.roomGameType
	self.m_openRoomGameOverUI = OpenRoomGameOverUI.new(tmpParam)
	
	_gameUserChatTxt = true;--大厅麻将及斗地主聊天内都不显示输入框内容，朋友开房进入的游戏界面显示聊天内的输入框内容。
end

--析构函数
function OpenRoomGame:dtor()
    Log.i("OpenRoomGame:dtor")

	_gameUserChatTxt = false;--大厅麻将及斗地主聊天内都不显示输入框内容，朋友开房进入的游戏界面显示聊天内的输入框内容。
	if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
		self.m_timerProxy:removeTimer("continue_duration_timer")
		self.m_timerProxy=nil
   end
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	kFriendRoomInfo:clearData()
end

--游戏初始化
function OpenRoomGame:init()
  
	Log.i("OpenRoomGame:init")
end

-- 网络关闭
function OpenRoomGame:onNetWorkClosed()
    Log.i("------UIWndBase:onNetWorkClosed")
    LoadingView.getInstance():hide();
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = "网络异常，请检查您的网络是否正常再进入游戏";
    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();
        MjMediator:getInstance():exitGame();
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

--开始游戏
function OpenRoomGame:starGame()
   Log.i("OpenRoomGame:starGame")
   
end

--游戏进行中
function OpenRoomGame:gameDoing()
  Log.i("OpenRoomGame:gameDoing")
  
end

--结束游戏
function OpenRoomGame:endGame()
 Log.i("OpenRoomGame:endGame")
end

--下一轮/下一局 游戏
function OpenRoomGame:nextRoundGame()
 Log.i("OpenRoomGame:nextRoundGame")

end

--游戏结算UI回调
function OpenRoomGame:gameOverUICallBack(tmpData)
   --奖励的UI层次要大于关闭房间的UI层次
   function comps(a,b)
	  return a.zorder < b.zorder
   end
   table.sort(self.m_infoCache,comps);


   for k, v in pairs(self.m_infoCache) do
      Log.i("游戏结算UI出现后回调:",k)
      if v.obj then
           v.funCall(v.obj,v.param);
      else
           v.funCall(v.param);
      end
   end
   self.m_infoCache=nil
   self.m_infoCache={}
end

--在游戏中点击退出游戏
function OpenRoomGame:normalQuitGame()
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local curCount=roomInfo.noRS
    local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
    local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    local tmpCount =0
    local isAward=false --是否已经发放过奖励,发送过以后,局数计算重新计算,策划设定只会只会发放一次奖励
    if(curCount<awardCount) then
      tmpCount = awardCount-curCount
    else
      tmpCount = totalCount-curCount
	  isAward=true
    end
	
	local data = {}
	data.type = 2;
	data.title = "提示";                        
	data.yesTitle  = "确定";
	data.cancelTitle = "取消";

	local userID =kUserInfo:getUserId()
	local isRoom = kFriendRoomInfo:isRoomMain(userID)
	
	if(isRoom) then--如果是房主
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏后将托管至本局结束并关闭好友房间.确定要退出吗?",curCount,tmpCount);
	  else
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,退出游戏后将托管至本局结束并关闭好友房间.确定要退出吗?",curCount,tmpCount);
	  end
	else
	  --
	  if(isAward) then
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,此操作将托管至本局结束并退出好友房间.确定要退出吗？",curCount,tmpCount);
	  else
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,此操作将托管至本局结束并退出好友房间,确定要退出吗?",curCount,tmpCount);
	  end
	end

	data.yesCallback = function()
		self:closeRoom()
	end

	local tipUI =UIManager.getInstance():pushWnd(CommonDialog, data)
	--tipUI.m_pWidget:setGlobalZOrder(99999)
end

--游戏打完一局后,手动点击退出游戏,才能向服务器发送关闭房间 
function OpenRoomGame:quitGame()
   local roomInfo = kFriendRoomInfo:getRoomInfo()
   local curCount=roomInfo.noRS
   local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
   local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    local tmpCount =0
    local isAward=false --是否已经发放过奖励,发送过以后,局数计算重新计算,策划设定只会只会发放一次奖励
    if(curCount<awardCount) then
      tmpCount = awardCount-curCount
    else
      tmpCount = totalCount-curCount
	  isAward=true
    end
   
	local data = {}
	data.type = 2;
	data.title = "提示";                        
	data.yesTitle  = "确定";
	data.cancelTitle = "取消";

	local userID =kUserInfo:getUserId()
	local isRoom = kFriendRoomInfo:isRoomMain(userID)
	
	if(isRoom) then--如果是房主
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏将关闭好友房间,确定要退出吗?",curCount,tmpCount);
	  else
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,此操作将关闭好友房间,确定要关闭吗?",curCount,tmpCount);
	  end
	else
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏将退出好友房间,确定要退出吗?",curCount,tmpCount);
	  else
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,退出游戏将退出好友房间,确定要退出吗？",curCount,tmpCount);
	  end
	 
	end

	data.yesCallback = function()
		local tmpData={}
		tmpData.usI= kUserInfo:getUserId()
		FriendRoomSocketProcesser.sendRoomQuit(tmpData)
	end

	local tipUI = UIManager.getInstance():pushWnd(CommonDialog, data);
    --tipUI.m_pWidget:setGlobalZOrder(99999)
end

--游戏打完一局后,才能向服务器发送关闭房间
function OpenRoomGame:recvRoomQuit(packetInfo)
    Log.i("退出邀请房结果",packetInfo)
	
	--##  usI  long  玩家id
    --re  int  结果（-1 失败，1 成功）
	if(packetInfo.re==1) then
	
	   if(self.m_isShowGameOverUI) then--如果已经显示结算UI
	        --self:onRecvRoomQuit(packetInfo)
	   else
	      	local tmpData={}
	        tmpData.param = packetInfo
	        tmpData.funCall= self.onRecvRoomQuit
			tmpData.obj = self
			tmpData.zorder=10
	        --self.m_infoCache["recvRoomQuit"] = tmpData 
			Log.i("缓存退出邀请房结果recvRoomQuit")
	   end
	end
end

--因为结算界面做了时间严时，所以提示框得在它后面创建
function OpenRoomGame:onRecvRoomQuit(packetInfo)

    local exitUserID = packetInfo.usI
	local localUserID = kUserInfo:getUserId()
	
	--如果是房主退出
	if(kFriendRoomInfo:isRoomMain(exitUserID)) then
	
		if(exitUserID == localUserID) then--如果是房主
		
		    --Toast.getInstance():show("房间已关闭!");
		   --SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom, {});
		   self:closeRoom()
		  
		else
			--房主已退出，此房间已经关闭，请选择其他游戏！确定
			local data = {}
			data.type = 1;
			data.title = "提示";
			data.closeTitle = "退出房间";
			data.content = "房主关闭当前房间,请重新选择其他游戏！";
			data.closeCallback = function ()
				  --SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom, {});
				  Log.i("点击房主关闭当前房间确定按钮")
				  self:closeRoom()
			end
			
			UIManager.getInstance():pushWnd(CommonDialog, data)

		end
	
	else  
	    --别的玩家退出
		--local exitPlayerInfo = kFriendRoomInfo:getRoomPlayerListInfo(exitUserID)
		
		--自己方收到消息则不用提示
		if(exitUserID ~= localUserID) then 
		    local playerName = packetInfo.niN--exitPlayerInfo.niN
            local str = string.format("%s退出当前房间,请重新邀请其他人继续游戏！",playerName)
		   	
			local data = {}
			data.type = 1;
			data.title = "提示";
			data.closeTitle = "退出房间";
			data.content = str;
			data.closeCallback = function ()
				--SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom, {});
				Log.i("点击退出房间确定按钮")
				self:returnRoomUI()
			end
			
			local tmpUI  = UIManager.getInstance():pushWnd(CommonDialog, data);
			tmpUI.m_pWidget:performWithDelay(function ()
			  	self:returnRoomUI()		
		    end,5);--如果有的玩家一直不点击确定按钮,刚等到一定时间自动把玩家拉回到房间

		else
		    --UIManager:getInstance():popWnd(FriendRoomScene);
			self:closeRoom()
		end 	
	end
	
	--更新玩家列表，从列表中删除退出房间的人
	--kFriendRoomInfo:removeRoomPlayerInfo(exitUserID)

end

--发放奖励
function OpenRoomGame:recvRoomReWard(packetInfo)
   kFriendRoomInfo:setGameEnd(true)
   if(self.m_isShowGameOverUI) then--如果已经显示结算UI
		self:OnRecvRoomReWard(packetInfo)
   else
		local tmpData={}
		tmpData.param = packetInfo
		tmpData.funCall= self.OnRecvRoomReWard
		tmpData.obj = self
		tmpData.zorder=50
		self.m_infoCache["recvRoomReWard"] = tmpData 
		Log.i("邀请房发放奖励结果recvRoomReWard")
   end
	
end

function OpenRoomGame:OnRecvRoomReWard(packetInfo)
--[[
   		local data = {}
		data.type = 1;
		data.title = "提示";
		data.content = packetInfo.ti;
		data.closeCallback = function ()
		    Log.i("点击领取奖励确定按钮")
			--UIManager.getInstance():popWnd(CommonDialog)
		end
		UIManager.getInstance():pushWnd(CommonDialog, data) 
]]	
		--CommonAnimManager.getInstance():showMoneyWinAnim(100)
--        MjProxy:getInstance():setDrawDissolutionView(true)
		local param=packetInfo
		UIManager.getInstance():pushWnd(FriendTotalOverView,param);
end

--房间关闭时
function OpenRoomGame:recvRoomEnd(packetInfo)
    
   if(self.m_isShowGameOverUI) then--如果已经显示结算UI
		--self:onRecvRoomEnd(packetInfo)
   else
		local tmpData={}
		tmpData.param = packetInfo
		tmpData.funCall= self.onRecvRoomEnd
		tmpData.obj = self
		tmpData.zorder=10
		--self.m_infoCache["recvRoomEnd"] = tmpData 
--		Log.i("邀请房房间关闭结果recvRoomEnd")
        if packetInfo.ty~= nil and packetInfo.ty == 1 then
            self:onRecvRoomEnd(packetInfo)
        end
   end
end

function OpenRoomGame:onRecvRoomEnd(packetInfo)
    Log.i("房主关闭房间,或者打满一定局数游戏自动关闭房间")
	local data = {}
	data.type = 1;
	data.title = "提示";
	data.content = packetInfo.ti;
	data.closeCallback = function ()
	   Log.i("点击房间关闭确定按钮")
	   self:closeRoom(packetInfo);
	end
	UIManager.getInstance():pushWnd(CommonDialog, data) 
end


--房主关闭房间,或者打满一定局数游戏自动关闭房间
function OpenRoomGame:closeRoom(tmpData)
   Log.i("有玩家退出房间")
   if(self.roomGameType == FriendRoomGameType.DDZ ) then

       self.m_delegate:requestExitRoom()
	   
   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
		MjMediator:getInstance():requestExitRoom()
        --MjMediator:getInstance():exitGame();
   end
   
end


--如果不是房主关闭房间,刚别的玩家一局游戏结束后,自己把别的玩家拉到房间UI界面上
function OpenRoomGame:returnRoomUI(tmpData)
 
   Log.i("不是房主退出房间,玩家强制拉回到房间UI界面上");
   Log.i("不能发送正常游戏的20014消息,会导致服务端把房间关闭,导致房间不存在");
   FriendRoomInfo.g_isReturnFriendRoom=true
   if(self.roomGameType == FriendRoomGameType.DDZ) then
		self.m_delegate:onExitRoom();	
   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
        MjMediator:getInstance():exitGame();
   end
end

--
function OpenRoomGame:recvRoomSceneInfo(packetInfo)
   Log.i("更新所有玩家信息.........")
end


function OpenRoomGame:recvFriendRoomStartGame(packetInfo)
   Log.i("收到玩家点击继续玩游戏按钮消息.........")
   LoadingView.getInstance():hide();
   
   self.m_isShowGameOverUI=false;
   if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
		self.m_timerProxy:removeTimer("continue_duration_timer")
		self.m_timerProxy=nil
   end
   
   if(self.roomGameType == FriendRoomGameType.DDZ) then
   
      self.m_delegate:repGameStart(packetInfo);

   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
   
   end
end

--游戏中点击继续按钮
function OpenRoomGame:onContinueButton(tmpDataParam)
 
   local tmpData={}
   FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);
   
   LoadingView.getInstance():show("您的好友还没选择继续,请耐心等待!");
   if(self.roomGameType == FriendRoomGameType.DDZ) then
	   local function updateContinue()
		  LoadingView.getInstance():show("您的好友还没选择继续,请耐心等待!");
	   end
	   if(self.m_timerProxy==nil) then
		   self.m_timerProxy = require "app.common.TimerProxy".new()
		   self.m_timerProxy:addTimer("continue_duration_timer", updateContinue,15,-1)
	   end
   end
   
   self:updateCountUI();
end

--显示游戏结算界面时
function OpenRoomGame:onShowGameOverUI(tmpDataParam)
    self.m_isShowGameOverUI=true
	self:nextRoundGame();
	self:gameOverUICallBack()
	
	self.m_openRoomGameOverUI:setGameOverUIDelegate(tmpDataParam.gameoverUI)
	self.m_openRoomGameOverUI:changBalanceUI()
end

--设置还有多少局
function OpenRoomGame:setCountUI(tmpWidget)

   local roomInfo = kFriendRoomInfo:getRoomInfo()
   local curCount=roomInfo.noRS
   local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
   local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    self.m_substituteLabel = cc.Label:create()
	local n = totalCount-curCount-1;
	if(n<=0)then
	   n=0;
	end
	local strC = string.format("房间关闭还剩%d局",n)
    self.m_substituteLabel:setString(strC);
    self.m_substituteLabel:setSystemFontSize(25)
    self.m_substituteLabel:setSystemFontName ("hall/font/bold.ttf")
	self.m_substituteLabel:setColor(cc.c3b(0,0,0));
	tmpWidget:addChild(self.m_substituteLabel);
	
	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	
	if(self.roomGameType == FriendRoomGameType.DDZ) then
	   self.m_substituteLabel:setPosition(cc.p(visibleWidth*0.5,visibleHeight-135))
	else
	  self.m_substituteLabel:setPosition(cc.p(visibleWidth*0.5,visibleHeight*0.5+80))
	end
end

--更新还有多少局
function OpenRoomGame:updateCountUI()
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local curCount=roomInfo.noRS
    local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
    local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
	local n = totalCount-curCount-1;
	if(n<=0)then
	   n=0;
	end
	local strC = string.format("房间关闭还剩%d局",n)
    self.m_substituteLabel:setString(strC);
end
	
--
function OpenRoomGame:recvFriendRoomLeaveGame(packetInfo)
    if MjProxy:getInstance()._players == nil or #MjProxy:getInstance()._players <=0 then
        cc.Director:getInstance():getRunningScene():performWithDelay(function()
            if(self.m_isCreate==nil) then
              self.m_isCreate=true
              self.m_dismissDeskView = UIManager:getInstance():pushWnd(DismissDeskView,nil,100)
	        end
   
            self.m_dismissDeskView:updateUI(packetInfo)
        end,1)
    else
        if(self.m_isCreate==nil) then
          self.m_isCreate=true
          self.m_dismissDeskView = UIManager:getInstance():pushWnd(DismissDeskView,nil,100)
	    end
   
        self.m_dismissDeskView:updateUI(packetInfo)
    end
   
end

function OpenRoomGame:recvSayMsg(packetInfo)
    Log.i("------recvSayMsg", packetInfo);
	local status = kSettingInfo:getGameVoiceStatus()
	if(status) then
	  Log.i("关闭玩家语音。。。。。。。。。")
	  return;
	end
    if packetInfo.ty == 1 then
        --语音聊天
        MjMediator:getInstance():on_speaking(packetInfo);
    end
end	


-- 网络重连成功
function OpenRoomGame:onNetWorkReconnected()
    Log.i("------UIWndBase:onNetWorkReconnected");
    LoadingView.getInstance():hide();
	--游戏重连逻辑
	MjMediator:getInstance():onNetWorkReconnected();
end
	
--
OpenRoomGame.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = OpenRoomGame.recvRoomQuit; --InviteRoomEnter	 退出邀请房结果
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_REWARD] = OpenRoomGame.recvRoomReWard; 	--InviteRoomRankAward	 邀请房排行奖励
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_END] = OpenRoomGame.recvRoomEnd; 	--InviteRoomEnd	 邀请房结束
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = OpenRoomGame.recvRoomSceneInfo; --InviteRoomInfo	 邀请房信息
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = OpenRoomGame.recvFriendRoomStartGame; --邀请房对局开始
	[HallSocketCmd.CODE_FRIEND_ROOM_LEAVE] = OpenRoomGame.recvFriendRoomLeaveGame;--解散桌子信息
    [HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = OpenRoomGame.recvSayMsg; --私有房聊天
};