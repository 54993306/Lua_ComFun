--广告视图ui类
AdvertView = class("AdvertView", function()
	local node = display.newNode()
	--node:setContentSize(display.width, display.height)
	--node:setTouchEnabled(true)
    --node:setTouchSwallowEnabled(true)
	node:setPosition(cc.p(10,10));
	return node
end)

-- start --
function AdvertView:ctor(params)

    self:setContentSize(660,305)--设置视图大小
    self.m_page=nil
	self.m_actionTime=1;--动作时间间隔
	self.m_currentPageIndex=0;--当前页面
	self.m_pageNum=0;--总页面数
	self.m_isCanMove= true;--页面在手动滑动进，是否能自动轮播。
	self.m_downFileNum=0;--下载文件总数
	self.m_currentDownFileNum=0;--当前已经下载文件数
	
    self.content = cc.LayerColor:create(
            cc.c4b(125,0,125,250))
    self.content:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height));
    --self.content:setTouchEnabled(true)
    --self.content:addTo(self)
	self.content:setTouchSwallowEnabled(false)
	self.content:setAnchorPoint(cc.p(0,0));
	
end

function AdvertView:dtor()
   self:stopUpdate()
   self.m_page=nil
end

function AdvertView:onFinishCallBack(listener)
	self.onListener = listener
	return self
end

--创建广告视图
function AdvertView:createAdvertView()
    self:createPageView();
	
	--指示灯
	self.m_sliderWnd = SliderIndicatorWnd.new();
	self.m_sliderWnd :addTo(self)
	self.m_sliderWnd :addIndicator(self.m_downFileNum)
	self.m_sliderWnd :setPosition(cc.p(self:getContentSize().width*0.5,50));
	self.m_sliderWnd :setAnchorPoint(cc.p(0.5,0.5));
	
	--把父节点中的广告图隐藏掉。
	if self.onListener ~=nil  then
	    --Log.i("把父节点中的广告图隐藏掉。")
	    self.onListener(self)
	end
end
--
function AdvertView:getAdvertFromServer()

	local tmpInfo = json.decode(kServerInfo:getMainAdUrl1());
	self.m_advertList = tmpInfo;
    Log.i("广告信息:",self.m_advertList)

	self.m_downFileNum = #self.m_advertList;
	
	if(self.m_downFileNum>0)then
	   self.m_pageNum = self.m_downFileNum;
	end
	

	local tmpFileNum=0;
	for i=1,self.m_downFileNum do 
	    local tmpInfo = self.m_advertList[i];
	    Log.i("广告信息",tmpInfo)
	    local imgName=tmpInfo.imgName;
		local delay=tmpInfo.delay;
		if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
		    Log.i("loading advert image.....")
			local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
			if io.exists(imgFile) then
			    self.m_currentDownFileNum = self.m_currentDownFileNum+1;
				if(self.m_currentDownFileNum>=self.m_downFileNum) then
				  if IS_YINGYONGBAO == false then 
				       Log.i("加载本地广告图完成")
					   self:createAdvertView();
				  end
				end
			else
				self:getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName);
			end
		end
	end
end

function AdvertView:getNetworkImage(preUrl, fileName)
    Log.i("AdvertView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("AdvertView.getNetworkImage", "-------fileName = ".. fileName);
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
            Log.i("------AdvertView onReponseNetworkImage code", code);
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

function AdvertView:onResponseNetImg(imgName)
    for i=1,#self.m_advertList do
	    local name= self.m_advertList[i].imgName
        if imgName == name then
            name = cc.FileUtils:getInstance():fullPathForFilename(name);
            if io.exists(name) then
                self.m_currentDownFileNum = self.m_currentDownFileNum+1;
				if(self.m_currentDownFileNum>=self.m_downFileNum) then
				  if IS_YINGYONGBAO == false then 
				       Log.i("加载网络广告图完成1111")
					   self:createAdvertView();
					   return;
				  end
				end
                break
            end
        end
    end

end

function AdvertView:createPageView()

   self.m_page= PageViewWnd.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        viewRect = cc.rect(0,0,self:getContentSize().width,self:getContentSize().height),
        column = 1, row = 1,
        padding = {left =8, right = 0, top = 0, bottom =0},
        columnSpace =0, rowSpace =0}
        :onTouch(handler(self, self.touchListener))
        :addTo(self)
  
    for i=1,self.m_downFileNum do
        local item = self.m_page:newItem()
		local fileName = self.m_advertList[i].imgName;
		fileName = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        local s=fileName
		Log.i("加载路径",s)
		
        local btnimage= ccui.Button:create(s,s,s,0)
		btnimage:setAnchorPoint(cc.p(0,0));
		btnimage:setTouchEnabled(false)
		
        item:addChild(btnimage)
        self.m_page:addItem(item)        
    end
    self.m_page:reload()
	
	self.m_actionTime = self.m_advertList[1].delay;--初始化时间
	
    self:startUpdate();
end

function AdvertView:touchListener(event)
    --dump(event, "TestUIPageViewScene - event:")
    local listView = event.listView
	
	local nIndex = self.m_page:getCurPageIdx();
    self.m_actionTime = self.m_advertList[nIndex].delay; --设置当前视图轮播时间 
	
	if(event.name =="clicked") then
	    local data ={}
		data.url =kServerInfo:getImgUrl();
		data.imageFileName =  self.m_advertList[nIndex].imgSmall;
	    UIManager:getInstance():pushWnd(AdvertViewDialog,data);
	elseif(event.name =="pageChange") then
		self.m_sliderWnd:changeIndicator(nIndex)
		
	elseif(event.name =="touchBegan") then	
	    self:stopUpdate();
    elseif(event.name =="touchEnded") then	
	    self:startUpdate();
	end
end

--
function AdvertView:startUpdate()
    if(self.m_update_hander==nil and self.m_pageNum>0 and self.m_page ) then
	    self.m_updateTime=1;
		self.m_update_hander = scheduler.scheduleGlobal(function()
	        --Log.i("check is move....")
			if(self.m_page) then
				if(self.m_page:getIsMove()==false) then
					--Log.i("wait time....." .. self.m_actionTime)
					self.m_actionTime = self.m_actionTime-self.m_updateTime;
					if(self.m_actionTime<0) then
					   local nextIndex = self.m_page:getCurPageIdx()+1;
					   if(self.m_page:getPageCount()<nextIndex) then
						  self.m_page:gotoPage(1,true,true);
						  self.m_actionTime = self.m_advertList[1].delay; --设置当前视图轮播时间 
					   else
						  self.m_page:gotoPage(nextIndex,true,true);
						  self.m_actionTime = self.m_advertList[nextIndex].delay; --设置当前视图轮播时间 
					   end
					   
					end
				else
				   --重设时间
				   self.m_actionTime = self.m_advertList[self.m_page:getCurPageIdx()].delay; --设置当前视图轮播时间
				end
			end
		end,self.m_updateTime);
	end
end

function AdvertView:stopUpdate()
   if(self.m_update_hander~=nil) then
       scheduler.unscheduleGlobal(self.m_update_hander)
	   self.m_update_hander=nil
	   Log.i("关闭定时器。。。。。")
   end
end

--点击图按钮
function AdvertView:onImageButton(pWidget, EventType)
  if EventType == ccui.TouchEventType.ended then
        local rx,ry = pWidget:getTouchBeganPosition();
		local dx,dy = pWidget:getTouchEndPosition();
		local dis  = cc.pGetDistance(cc.p(rx,ry),cc.p(dx,dy))
		
		Log.i("位移:",dis)
        Log.i("click image " .. pWidget:getTag());
	    if(dis<10)then
	   
	    end
  end
end
