SelectServerWnd = class("SelectServerWnd", UIWndBase)

local tabText = {"06服务器", "142服务器", "外网服务器"}
local STR_WXID_FIRST = "WX_OPEN_ID_"
local COLOR_NORMAL = cc.c4b(38, 205, 250, 255)
local COLOR_CHOOSE = cc.c4b(38, 50, 250, 255)

function SelectServerWnd:ctor(uiConfig, data, zOrder, delegate)
	self.super.ctor(self, uiConfig, data, zOrder, delegate)

	self.m_pWidget = display.newLayer()

	--***************   按钮层    ***************--
	self.layBtnBg = cc.LayerColor:create(cc.c4b(255, 255, 255, 150))
	self.layBtnBg:setContentSize(cc.size(250, 400))
	self.layBtnBg:setPosition(cc.p(50, 430))
	self.layBtnBg:addTo(self.m_pWidget)

	local labelChoose = cc.LabelTTF:create("服务器选择", "hall/font/fangzhengcuyuan.TTF", 30)
	labelChoose:setPosition(cc.p(self.layBtnBg:getContentSize().width/2, 360))
	labelChoose:setColor(cc.c3b(0, 0, 0))
	labelChoose:addTo(self.layBtnBg)

	--复选按钮
	self.tabLayBtn = {}
	for i = 1, 3 do
		local lay = cc.LayerColor:create(COLOR_NORMAL)
		lay:setContentSize(cc.size(200, 80))
		lay:addTo(self.layBtnBg)
		local fXCentre = self.layBtnBg:getContentSize().width/2 - lay:getContentSize().width/2
		lay:setPosition(cc.p(fXCentre, 240 - 110*(i - 1)))
		if i == 1 then
			--默认
			SERVER_IP = tabServerIP[i]
			lay:setColor(COLOR_CHOOSE)
		end

		local labName = cc.LabelTTF:create(tabText[i], "hall/font/fangzhengcuyuan.TTF", 24)
		labName:setPosition(cc.p(lay:getContentSize().width/2, 45))
		labName:addTo(lay)
		self.tabLayBtn[i] = lay
	end

	--***************     输入层      *****************--
	self.layInputBg = cc.LayerColor:create(cc.c4b(255, 255, 255, 180))
	self.layInputBg:setContentSize(cc.size(400, 390))
	self.layInputBg:setPosition(cc.p(300, 430))
	self.layInputBg:addTo(self.m_pWidget)

	--描述文字
	local labDes = cc.LabelTTF:create("输入测试账户", "hall/font/fangzhengcuyuan.TTF", 24)
	labDes:setPosition(cc.p(20, 340))
	labDes:setColor(cc.c3b(0, 0, 0))
	labDes:setAnchorPoint(cc.p(0, 0.5))
	labDes:addTo(self.layInputBg)

	--输入框
	local fSide1 = 1
	local layEditBoxBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	layEditBoxBg:setPosition(cc.p(45, 280))
	layEditBoxBg:setContentSize(cc.size(300, 30))
	layEditBoxBg:addTo(self.layInputBg)
	local layCover =  cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	layCover:setPosition(fSide1, fSide1)
	layCover:setContentSize(layEditBoxBg:getContentSize().width - fSide1*2, layEditBoxBg:getContentSize().height - fSide1*2)
	layCover:addTo(layEditBoxBg)
	self.editBoxAct = ccui.EditBox:create(layEditBoxBg:getContentSize(), "hall/Common/advertNoSelect.png")
	self.editBoxAct:setPosition(layEditBoxBg:getContentSize().width/2, layEditBoxBg:getContentSize().height/2)
	self.editBoxAct:setFontColor(cc.c3b(0, 0, 0))
	self.editBoxAct:setMaxLength(32)
	self.editBoxAct:setPlaceHolder("在此输入快速登录的测试账户")
	self.editBoxAct:addTo(layEditBoxBg)
	local strAccountCache = self:getAccountCache()
	if strAccountCache ~= "" then
		self.editBoxAct:setText(strAccountCache)
	end

	--当前选择IP和端口	
	labDes = cc.LabelTTF:create("当前选择的IP和端口", "hall/font/fangzhengcuyuan.TTF", 24)
	labDes:setPosition(cc.p(20, 240))
	labDes:setColor(cc.c3b(0, 0, 0))
	labDes:setAnchorPoint(cc.p(0, 0.5))
	labDes:addTo(self.layInputBg)

	local layIPEditBoxBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	layIPEditBoxBg:setPosition(cc.p(45, 180))
	layIPEditBoxBg:setContentSize(cc.size(150, 30))
	layIPEditBoxBg:addTo(self.layInputBg)
	local layIPCover =  cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	layIPCover:setPosition(fSide1, fSide1)
	layIPCover:setContentSize(layIPEditBoxBg:getContentSize().width - fSide1*2, layIPEditBoxBg:getContentSize().height - fSide1*2)
	layIPCover:addTo(layIPEditBoxBg)
	self.editBoxIpAct = ccui.EditBox:create(layIPEditBoxBg:getContentSize(), "hall/Common/advertNoSelect.png")
	self.editBoxIpAct:setPosition(layIPEditBoxBg:getContentSize().width/2, layIPEditBoxBg:getContentSize().height/2)
	self.editBoxIpAct:setFontColor(cc.c3b(0, 0, 0))
	self.editBoxIpAct:setMaxLength(32)
	self.editBoxIpAct:setPlaceHolder("当前选择的IP")
	self.editBoxIpAct:addTo(layIPEditBoxBg)
	self.editBoxIpAct:setText(self:getIPCache())


    self.editBoxSex = ccui.EditBox:create(layIPEditBoxBg:getContentSize(), "hall/Common/advertNoSelect.png")
    self.editBoxSex:setPosition(100, 150)
    self.editBoxSex:setFontColor(cc.c3b(0, 0, 0))
    self.editBoxSex:setContentSize(cc.size(120, 30))
    self.editBoxSex:setMaxLength(32)
	self.editBoxSex:setPlaceHolder("当前性别")
	self.editBoxSex:addTo(self.layInputBg)
--	self.editBoxSex:setText("1")

	local layPortEditBoxBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	layPortEditBoxBg:setPosition(cc.p(200, 180))
	layPortEditBoxBg:setContentSize(cc.size(100, 30))
	layPortEditBoxBg:addTo(self.layInputBg)
	local layPortCover =  cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	layPortCover:setPosition(fSide1, fSide1)
	layPortCover:setContentSize(layPortEditBoxBg:getContentSize().width - fSide1*2, layPortEditBoxBg:getContentSize().height - fSide1*2)
	layPortCover:addTo(layPortEditBoxBg)

	self.editBoxPortAct = ccui.EditBox:create(layPortCover:getContentSize(), "hall/Common/advertNoSelect.png")
	self.editBoxPortAct:setPosition(layPortCover:getContentSize().width/2, layPortCover:getContentSize().height/2)
	self.editBoxPortAct:setFontColor(cc.c3b(0, 0, 0))
	self.editBoxPortAct:setMaxLength(15)
	self.editBoxPortAct:setPlaceHolder("当前选择的端口")
	self.editBoxPortAct:addTo(layPortCover)
	self.editBoxPortAct:setText(self:getPortCache())

	--快速登录按钮
	local fSide2 = 2
	local layLoginBg = cc.LayerColor:create(cc.c4b(137, 255, 39, 255), 180, 60)
	layLoginBg:addTo(self.layInputBg)
	local fXLoginBg = self.layInputBg:getContentSize().width/2 - layLoginBg:getContentSize().width/2
	layLoginBg:setPosition(cc.p(fXLoginBg, 50))

	local layLoginCover = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	layLoginCover:setPosition(fSide2, fSide2)
	layLoginCover:setContentSize(layLoginBg:getContentSize().width - fSide2*2, layLoginBg:getContentSize().height - fSide2*2)
	layLoginCover:addTo(layLoginBg)

	local btnLogin = ccui.Button:create()
	btnLogin:setPosition(cc.p(layLoginBg:getContentSize().width/2, layLoginBg:getContentSize().height/2 - 4))
	btnLogin:ignoreContentAdaptWithSize(false)
	btnLogin:setContentSize(layLoginBg:getContentSize())
	btnLogin:setTitleText("快速登录")
	btnLogin:setTitleColor(cc.c3b(0, 0, 0))
	btnLogin:setTitleFontSize(28)
	btnLogin:addTo(layLoginBg)
	btnLogin:addTouchEventListener(handler(self, self.onClickLoginButton))


	self:regTouchEvent()
end

function SelectServerWnd:onClose()
	self.tabLayBtn = {}
end

function SelectServerWnd:onTouchBegan(touch, event)
	return true;
end

function SelectServerWnd:onTouchEnded(touch, event)
	local location = touch:getLocation()
	local posParentX, posParentY = self.layBtnBg:getPosition()
	for i = 1, #self.tabLayBtn do
		local lay = self.tabLayBtn[i]
		local rect = lay:getBoundingBox()
		rect.x = rect.x + posParentX
		rect.y = rect.y + posParentY

		if cc.rectContainsPoint(rect, location) then
			self:onSelect(i)
		end
	end
end

function SelectServerWnd:onClickLoginButton(ref, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.m_delegate and self.m_delegate.loginFastForTest then
			local wxName = self.editBoxAct:getText()
			local port = self.editBoxPortAct:getText()
			local ip = self.editBoxIpAct:getText()
            local sex = tonumber(self.editBoxSex:getText())
			if self:checkPort(port) then
				if self:checkAccount(wxName) then
					SERVIER_PORT = port
					SERVER_IP = ip
					local wxOpenId = STR_WXID_FIRST .. wxName
				    cc.UserDefault:getInstance():setStringForKey("testServerIPCache", SERVER_IP)
				    cc.UserDefault:getInstance():setStringForKey("testServerPortCache", SERVIER_PORT)
					self.m_delegate:loginFastForTest(wxOpenId, wxName,sex)
				end
			end
		end
	end
end

function SelectServerWnd:onSelect(index)
	SERVER_IP = tabServerIP[index]
	Log.i(SERVER_IP, index)

	for i = 1, #self.tabLayBtn do
		if i == index then
			self.tabLayBtn[i]:setColor(COLOR_CHOOSE)
		else
			self.tabLayBtn[i]:setColor(COLOR_NORMAL)
		end
	end

	local bVisible = true
	if index == 3 then 		--外网服务器
		bVisible = false
	end
	--self.layInputBg:setVisible(bVisible)

	self.editBoxIpAct:setText(SERVER_IP)
end

function SelectServerWnd:checkPort(str)	
    if not str then
        Toast.getInstance():show("请输入帐号")
        return false
    else
        local len = string.len(str)
        local strTemp = string.match(str, "^[0-9]*$")
        if not strTemp or len ~= string.len(strTemp) then
            Toast.getInstance():show("请输入正确的端口号，仅为数字")
            return false
        end
    end
    return true
end

function SelectServerWnd:checkAccount(str)
    if not str then
        Toast.getInstance():show("请输入帐号")
        return false
    elseif string.len(str) < 6 then
        Toast.getInstance():show("请输入至少6位数的帐号")
        return false
    else
        local len = string.len(str)
        local strTemp = string.match(str, "%w+")
        if not strTemp or len ~= string.len(strTemp) then
            Toast.getInstance():show("请输入正确的帐号，不含空格、字符、汉字等")
            return false
        end
    end

    return true
end

function SelectServerWnd:getAccountCache()
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account")
    if accountInfoStr and accountInfoStr ~= "" then
    	local accountInfo = json.decode(accountInfoStr)
    	for v, k in pairs(accountInfo) do
    		local account = k.act
    		if account and type(account) == "string" then
    			local nLengthAll = string.len(account)
    			local nLengthFirst = string.len(STR_WXID_FIRST)
    			local strAccountFirst = string.sub(account, 1, nLengthFirst)
    			if strAccountFirst == STR_WXID_FIRST then
    				return string.sub(account, nLengthFirst + 1, nLengthAll)
    			end
    		end
    	end
    end

    return ""
end

function SelectServerWnd:getIPCache()
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("testServerIPCache")
    if accountInfoStr and accountInfoStr ~= "" then
    	return accountInfoStr
    end
    return SERVER_IP
end

function SelectServerWnd:getPortCache()
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("testServerPortCache")
    if accountInfoStr and accountInfoStr ~= "" then
    	if self:checkPort(accountInfoStr) then
    		return accountInfoStr
    	end
    end
    return SERVIER_PORT
end

function SelectServerWnd.tableConvert(tab)
	tab = checktable(tab)
	local tabDest = {}
	for v, k in pairs(tab) do
		tabDest[k] = v
	end

	return tabDest
end