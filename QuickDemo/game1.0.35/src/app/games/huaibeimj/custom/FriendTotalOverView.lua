
FriendTotalOverView = class("FriendTotalOverView", UIWndBase)

function FriendTotalOverView:ctor(...)
    self.super.ctor(self, "games/huaibeimj/game/mj_total_over.csb",...);
	self.m_data = ...
	Log.i("获取到奖励信息:",self.m_data.plL)
	self:sortPlayerInfo()
end

function FriendTotalOverView:onInit()
    -- 分享
    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share")
    self.btn_share:addTouchEventListener(handler(self, self.onClickButton));

    -- 返回
    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_back")
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton));
	
	--房间号
    local playerInfo = kFriendRoomInfo:getRoomInfo();
    self.lab_room_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_room_num")
    self.lab_room_num:setString("房间号:".. playerInfo.pa.."\n时间："..os.date("%y-%m-%d-%H:%M", os.time()) )
    
    -- local timeText = ccui.Helper:seekWidgetByName(self.m_pWidget, "time_text")
    -- timeText:setString(string.format("日期:%s", ))

    -- 玩家信息
    self.imgHeads = {};
    self.lv_player = ccui.Helper:seekWidgetByName(self.m_pWidget, "lv_player")
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/huaibeimj/game/mj_total_over_item.csb")
    if display.width / display.height >= 1.9 then
        itemModel:setScale(0.8)
    end
    for i = 1, #self.m_sortInfo do
	    local tmpData = self.m_sortInfo[i]
        local mItem = itemModel:clone();
        self.lv_player:pushBackCustomItem(mItem);
        local img_head = ccui.Helper:seekWidgetByName(mItem, "img_head");--头像
        self.imgHeads[i] = img_head

        local img_host = ccui.Helper:seekWidgetByName(mItem, "img_host");--房主标志
		if(i~=1) then
		  img_host:setVisible(false)
		end
		
        local lab_nick = ccui.Helper:seekWidgetByName(mItem, "lab_nick");--昵称
        local lab_id = ccui.Helper:seekWidgetByName(mItem, "lab_id");--id
        local lab_hu_num = ccui.Helper:seekWidgetByName(mItem, "lab_hu_num");--胡牌次数
        local img_dyj = ccui.Helper:seekWidgetByName(mItem, "img_dyj");--大赢家标志
        local lab_total = ccui.Helper:seekWidgetByName(mItem, "lab_total");--总分

		lab_hu_num:setString("" .. tmpData.hu)
        lab_nick:setString(ToolKit.subUtfStrByCn(tmpData.niN, 0, 5, ""));
		
        local totalScore = tmpData.to - 1000
        if totalScore > 0 then
            lab_total:setString("+" .. totalScore)

        else
            lab_total:setString("" .. totalScore)

        end
		
		if(totalScore<=0 or (tmpData.isMaxCO==nil or tmpData.isMaxCO==false)) then
		    img_dyj:setVisible(false);
		end
		
		lab_id:setString("" .. tmpData.usI)
        local imgURL = MjProxy:getInstance():getPlayerInfoByID(tmpData.usI):getIconId() .. "";
        if string.len(imgURL) > 3 then
            local imgName = MjProxy:getInstance():getPlayerInfoByID(tmpData.usI):getUserId()..".jpg";
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(headFile) then
                img_head:loadTexture(headFile);
            else
                self.imgHeads[imgName] = img_head;
                self:getNetworkImage(imgURL, imgName);
            end
        else        
            local headFile = "hall/Common/default_head_2.png";
            headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
            if io.exists(headFile) then
                img_head:loadTexture(headFile);
            end
        end   
    end
end

function FriendTotalOverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kFriendRoomInfo:setGameEnd(false)
        if pWidget == self.btn_share then 
            --self:keyBack()
			kGameManager:shareScreen()
        elseif pWidget == self.btn_back then
            MjMediator:getInstance():exitGame()
        end
    end
end

function FriendTotalOverView:getNetworkImage(preUrl, fileName)
    Log.i("FriendTotalOverView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("FriendTotalOverView.getNetworkImage", "-------fileName = ".. fileName);
    if preUrl == "" then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(fileName);
    end
    local url = preUrl;
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function FriendTotalOverView:onResponseNetImg(imgName)
    local imgHead = self.imgHeads[imgName];
    if imgHead then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            imgHead:loadTexture(imgName);
            --imgHead:setScale(100/self.imgHeads[i]:getContentSize().width ,100/self.imgHeads[i]:getContentSize().height);
        end
    end
    

end

function FriendTotalOverView:sortPlayerInfo()
	
    self.m_sortInfo = {}
    local hostSite = 1
    local playerCount = 4
    for i=1,playerCount do
        if(kFriendRoomInfo:isRoomMain(self.m_data.plL[i].usI)) then
            hostSite = i
            break
        end
    end
    for i=1,playerCount do
        local  site = (i - hostSite + playerCount)%playerCount +1
        self.m_sortInfo[site] = self.m_data.plL[i]
    end
	
	local maxValue = -99999
	for i=1,#self.m_sortInfo do
	   local tmpData= self.m_sortInfo[i]
	   if(tmpData.to>maxValue) then
	      maxValue =tmpData.to
	   end
	end
	
	for i=1,#self.m_sortInfo do
	    local tmpData= self.m_sortInfo[i]
		if(tmpData.to>=maxValue) then
		    self.m_sortInfo[i].isMaxCO = true;
		end
	end
	Log.i("排序后玩家信息:",self.m_sortInfo)
end
