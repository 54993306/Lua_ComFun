-------------------------------------------------------------
--  @file   FriendRoomCreate.lua
--  @brief  创建房间规则界面
--  @author ZCQ
--  @DateTime:2016-11-07 12:08:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
FriendRoomCreate = class("FriendRoomCreate", UIWndBase);
local kWidgets = {
	tagConfirm = "btn_sure", -- 确定
	tagCancel  = "cancleBtn",  -- 取消
    tagRule_btn_1   = "select_img_1",   -- 按钮1
	tagRule_btn_2   = "select_img_2",  	-- 按钮2
    tagRule_btn_3   = "select_img_3",   -- 按钮3
    tagRule_btn_4   = "select_img_4",   -- 按钮4

    tagRule5      = "selectCheckBox_5",    -- 七对加番
    tagRule6      = "selectCheckBox_6",     -- 十三不靠加番
    tagRule7      = "selectCheckBox_7",     -- 跑

	tagGame8   = "game_8",  	-- 8局
    tagGame16  = "game_16",     -- 16局
	tagWanFa   = "wanfanPanel",  	-- 玩法
}
-- 玩法规则
local kWanFa = {
    [1] = {
        _gamePalyingName[1].title,
        _gamePalyingName[2].title,
    },
    [2] = {
        _gamePalyingName[3].title,
        _gamePalyingName[4].title,
    }
}
-- 最后的规则内容
local kWanFaLaPao = {
    [1] =  _gamePalyingName[5].title,
    [2] =  _gamePalyingName[6].title,
    [3] =  _gamePalyingName[7].title,
}

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:ctor(...)
    self.super.ctor(self, "games/huaibeimj/game/friendRoomCreate.csb", ...);
    self.m_data=...;
    self.m_isOpen=false --是否打开下拉列表
	
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	
end
--[[
-- @brief  初始函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onInit()
--[[
 	  	##  gaI  int  游戏ID
 	  	##  roS  String  局数
 	  	##  RoFS  String  房费数量
 	  	##  di  String  底分
 	  	##  fe  String  封顶
 	  	##  wa  String  玩法
 	  	##  re  int  结果（-1 =创建失败不够资源，-2 =创建失败无可用房间， 非0 = 房间密码）
]]
    self.m_setData={}
    self.groups = {}
    self.cancleBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagCancel);
    self.cancleBtn:addTouchEventListener(handler(self, self.onClickButton));
   
    self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagConfirm);
    self.btn_sure:addTouchEventListener(handler(self, self.onClickButton));
    ------------第一组---------------------------------------
    local group1 = require("app.hall.common.RadioButtonGroup").new()
    self.btn_rule1 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule_btn_1);
    local radio = cc(self.btn_rule1):addComponent("app.hall.common.RadioButton"):exportMethods()
    radio:setButtonMode(enRadioButtonMode.CHANGE)
    radio:loadTextures("games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/select.png", "games/huaibeimj/game/friendRoom/select.png")
    group1:addRadioButton(radio)

    self.btn_rule2 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule_btn_2);
    local radio = cc(self.btn_rule2):addComponent("app.hall.common.RadioButton"):exportMethods()
    radio:setButtonMode(enRadioButtonMode.CHANGE)
    radio:loadTextures("games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/select.png", "games/huaibeimj/game/friendRoom/select.png")
    group1:addRadioButton(radio)

    group1:setChangeEventListener(handler(self, FriendRoomCreate.onSelectedRadioChanged1))
    group1:setSelectedRadioButton(1)
    table.insert(self.groups, group1)
    ------------第二组---------------------------------------
    local group2 = require("app.hall.common.RadioButtonGroup").new()
    self.btn_rule3 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule_btn_3);
    local radio = cc(self.btn_rule3):addComponent("app.hall.common.RadioButton"):exportMethods()
    radio:setButtonMode(enRadioButtonMode.CHANGE)
    radio:loadTextures("games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/select.png", "games/huaibeimj/game/friendRoom/select.png")
    group2:addRadioButton(radio)

    self.btn_rule4 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule_btn_4);
    local radio = cc(self.btn_rule4):addComponent("app.hall.common.RadioButton"):exportMethods()
    radio:setButtonMode(enRadioButtonMode.CHANGE)
    radio:loadTextures("games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/select.png", "games/huaibeimj/game/friendRoom/select.png")
    group2:addRadioButton(radio)

    group2:setChangeEventListener(handler(self, FriendRoomCreate.onSelectedRadioChanged2))
    group2:setSelectedRadioButton(1)
    table.insert(self.groups, group2)

    self:setInitSelect()
end

--[[
-- @brief  第一组函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onSelectedRadioChanged1(radio, idx)
    dump(idx)
end

--[[
-- @brief  第二组函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onSelectedRadioChanged2(radio, idx)
    dump(idx)
end

--[[
-- @brief  第三组函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onSelectedRadioChanged3(radio, idx)
    dump(idx)
    self.m_setData.roS = self.m_jushu_itemList[idx];
    self.m_setData.RoFS = self.m_fangfei_itemList[idx];
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.cancleBtn then
		
		   UIManager:getInstance():popWnd(FriendRoomCreate);

        elseif pWidget == self.btn_sure then
		    --当玩家剩余1张开房卡时，点击“开设房间”进入到选择牌局规则界面，如果选择12局或16局，点击“确定”，弹出提示：房卡不足，请联系群主或以下微信号xxxxxxxx。
		    --测试当前所消耗物品数量是否够开房间
		    --##    roFT  int  房费类型（填入物品ID，可以是金豆和元宝，开房卡）
	  	    --##    roF  int  房费数量
			Log.i("本局游戏要消耗钻石" .. self.m_setData.RoFS)
			if self.m_setData.RoFS ~= nil then
			    if(kUserInfo:getPrivateRoomDiamond() < tonumber(self.m_setData.RoFS) and kFriendRoomInfo:isFreeActivities()==false) then
                    -- Toast.getInstance():show("您的钻石不足");
                    local data = self:resetRechargeInfo(kFriendRoomInfo:getRoomBaseInfo().roomFeeTip)
                    UIManager.getInstance():pushWnd(AddMoneyDialog, data);
					return
				end
			end
			
		    self.m_setData.gaI = kFriendRoomInfo:getGameID();
            -- 玩法工厂
            self:wanFaFactory()
			local tmpData = self.m_setData;
			FriendRoomSocketProcesser.sendRoomCreate(tmpData)
            LoadingView.getInstance():show("正在创建房间,请稍后...");
        end
    end
end

function FriendRoomCreate:resetRechargeInfo(str_data)
    Log.i(debug.traceback())
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

function FriendRoomCreate:getRechargeWechat(str,wechat_tag)
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

function FriendRoomCreate:setInitSelect()
    local tmpData = kFriendRoomInfo:getRoomBaseInfo()
    --d的牌局
    local playerName = kUserInfo:getUserName()
    local  nameLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
    local retName = ToolKit.subUtfStrByCn(playerName,0,5,"")
    nameLabel:setString(string.format("%s的牌局",retName))
    
    --局数:
    self.m_jushu_itemList = Util.analyzeString_2(tmpData.roundSum);
    self.m_fangfei_itemList = Util.analyzeString_2(tmpData.RoomFeeSum);
    if(not self.m_jushu_itemList) then
        return;
    end
    
    --隐藏
    local juShunPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "juShunPanel");
    for i=1,4 do
        local selectPanel = ccui.Helper:seekWidgetByName(juShunPanel, "selectPanel_" .. i);
        selectPanel:setVisible(false);
    end
    local group3 = require("app.hall.common.RadioButtonGroup").new()
    for i = 1, #self.m_jushu_itemList do
        local selectPanel = ccui.Helper:seekWidgetByName(juShunPanel, "selectPanel_" .. i);
        selectPanel:setVisible(true);
        local strN= string.format("selectCheckBox_%d", i)
        local iconCheckBox = ccui.Helper:seekWidgetByName(juShunPanel, strN);
        local Label_10 = ccui.Helper:seekWidgetByName(iconCheckBox:getParent(), "Label_10");
        local str = string.format("%s(%s钻)", self.m_jushu_itemList[i], self.m_fangfei_itemList[i]);
        Label_10:setString(str) 
        local radio = cc(iconCheckBox):addComponent("app.hall.common.RadioButton"):exportMethods()
        radio:setButtonMode(enRadioButtonMode.CHANGE)
        radio:loadTextures("games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/selectBg.png", "games/huaibeimj/game/friendRoom/select.png", "games/huaibeimj/game/friendRoom/select.png")
        group3:addRadioButton(radio)

    end 

    group3:setChangeEventListener(handler(self, FriendRoomCreate.onSelectedRadioChanged3))
    group3:setSelectedRadioButton(1)

    --玩法:
    self.m_wanfa_itemList = Util.analyzeString_2(tmpData.wanfa);
    if(not self.m_wanfa_itemList) then
        return;
    end

    -- 规则列表
    self.ruleChexkBoxs = {}
    -- 七对加番
    local checkBoxLa = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule5);
    checkBoxLa:addTouchEventListener(handler(self, self.onCheckBoxBtn));
    checkBoxLa:setSelected(true)
    table.insert(self.ruleChexkBoxs, checkBoxLa)
    -- 十三不靠加番
    local checkPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "rule_select_6");
    checkPanel:setVisible(false)
    local checkBoxPao = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule6);
    checkBoxPao:addTouchEventListener(handler(self, self.onCheckBoxBtn));
    table.insert(self.ruleChexkBoxs, checkBoxPao)
    checkBoxPao:setSelected(false)
    -- 拉跑坐
    local checkBoxZuo = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagRule7);
    checkBoxZuo:addTouchEventListener(handler(self, self.onCheckBoxBtn));
    table.insert(self.ruleChexkBoxs, checkBoxZuo)
end

--[[
-- @brief  复选框按钮
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onCheckBoxBtn(obj, event)

    if event == ccui.CheckBoxEventType.selected then
        
    end

    -- for i=1, #self.ruleChexkBoxs do
    --     if obj == self.ruleChexkBoxs[i] then
    --         self.ruleChexkBoxs[i]:setTouchEnabled(true)
    --     else
    --         self.ruleChexkBoxs[i]:setTouchEnabled(false)
    --     end
    -- end
    -- if event == ccui.CheckBoxEventType.selected then
    --     for i=1,#self.ruleChexkBoxs do
    --         if obj == self.ruleChexkBoxs[i] then
            
    --         else
    --             self.ruleChexkBoxs[i]:setSelected(false)      
    --         end
    --     end
    -- end
    -- for i=1, #self.ruleChexkBoxs do
    --     self.ruleChexkBoxs[i]:setTouchEnabled(true)
    -- end
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:wanFaFactory()
    -- 拼装字符串
    local stringInfo = ""
    for i=1,#self.groups do
        local index = self.groups[i]:getSelectedIndex()
        local str = kWanFa[i][index]
        if stringInfo == "" then
            stringInfo = str
        else
            stringInfo = string.format("%s|%s", stringInfo, str)
        end
    end

    for i=1,#self.ruleChexkBoxs do
        local str = ""
        if self.ruleChexkBoxs[i]:isSelected() then
            str = kWanFaLaPao[i]
            if stringInfo == "" then
                stringInfo = str
            else
                stringInfo = string.format("%s|%s", stringInfo, str)
            end
        else
            -- str = kWanFaLaPao[i][2]
            -- stringInfo = string.format("%s|%s", stringInfo, str)
        end
    end
    self.m_setData.wa = stringInfo
end


function FriendRoomCreate:recvRoomSceneInfo(packetInfo)
   	Log.i("获取邀请房信息")
   	LoadingView.getInstance():hide();
   	UIManager:getInstance():popWnd(FriendRoomCreate);
   	UIManager:getInstance():pushWnd(FriendRoomScene);
end


function FriendRoomCreate:recvRoomCreate(packetInfo)
    ------##  re  int  结果（-1 =房卡不足，-2 = 无可用房间，1 成功）
   	local tmpData= packetInfo
   	if(-1 == tmpData.re) then
      	Toast.getInstance():show("您的钻石不足,请充值!");
   	elseif(-2 == tmpData.re) then
      	Toast.getInstance():show("无可用房间!");
   	elseif(1==tmpData.re) then
       	Log.i("等待获取房间信息才能进入房间。。。。。")
   	end
end   
  
  
FriendRoomCreate.s_socketCmdFuncMap = {
  	[HallSocketCmd.CODE_FRIEND_ROOM_CREATE] = FriendRoomCreate.recvRoomCreate; 	--InviteRoomCreate	 创建邀请房结果
  	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomCreate.recvRoomSceneInfo; --InviteRoomInfo	 邀请房信息
};