--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
PlayerPosInfoWnd = class("PlayerPosInfoWnd",UIWndBase)

function PlayerPosInfoWnd:ctor(data)
    self.super.ctor(self, "hall/player_position_info.csb", data);
    for i=1,#data.site do
        if data.site[i] == nil or data.site[i] == "" then
            table.remove(data.site,i)
        end
    end
    Log.i("PlayerPosInfoWnd:ctor....",data)
    self.m_data = data
    self.m_wndType = data.type;
end
function PlayerPosInfoWnd:onInit()
--    if self.m_wndType == 2 then
--        local panel_content_box = self:getWidget(self.m_pWidget,"panel_content_box");
--        self.m_pWidget:setPosition(cc.p(300,-200));
--    end
    self:setPlayerTitle()
    self:setPostionContent()
    
    self.button_close = self:getWidget(self.m_pWidget,"Button_close")
    self.button_close:addTouchEventListener(handler(self,self.onClickButton))
end
function PlayerPosInfoWnd:onClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.button_close then
--            kUserInfo:setUpdateHead(kUserInfo:getOtherDelegateHead())
            self:removeMoRneHead()
            UIManager:getInstance():popWnd(PlayerPosInfoWnd);
        end
    end
end
function PlayerPosInfoWnd:setPlayerTitle()
    Log.i("PlayerPosInfoWnd:setPlayerTitle....")
    local panel_title = self:getWidget(self.m_pWidget,"panel_title");
    local image_head_bg = self:getWidget(panel_title,"Image_head_bg");
    image_head_bg:loadTexture(self.m_data.playerHeadImage);
    local createTime = self.m_data.crT or 0
    local updateTime = tonumber(os.time()) - (tonumber(createTime)/1000)
    if createTime ~= 0 and updateTime < GAME_HEAD_UPDATE_TIME then
--        kUserInfo:setOtherDelegateHead()
        if self.moren_head then
            self.moren_head:removeFromParent()
            self.moren_head = nil
        end

        local moren_head_img = "hall/Common/moren_woman_head.png"
        if self.m_data.panel == "PlayerHead"  then
            if self.m_data.sex == 0 then
                moren_head_img = "hall/Common/moren_man_head.png"
            end
        else
             moren_head_img = "hall/Common/moren_man_head.png"
            if kUserInfo:getUserSex() == 2 then
                moren_head_img = "hall/Common/moren_woman_head.png"
            end
        end
        self.moren_head = display.newSprite(moren_head_img)
        local frameSize = image_head_bg:getContentSize()
        self.moren_head:setName("moren_head")
        self.moren_head:setScale(0.7)
        self.moren_head:addTo(image_head_bg,1)
        self.moren_head:setPosition(cc.p(frameSize.width/2,frameSize.height/2))
        self.setMorenHeadThread = scheduler.performWithDelayGlobal(function ()
            self:removeMoRneHead();
        end, GAME_HEAD_UPDATE_TIME-updateTime);
    end
    local label_name = self:getWidget(panel_title,"Label_name");
    local nameStr = ToolKit.subUtfStrByCn(self.m_data.playerName,0,5,"")
    label_name:setString(nameStr);
    local label_player_ip = self:getWidget(panel_title,"Label_player_ip");
    label_player_ip:setString(self.m_data.playerIP);

    local label_ip_name = self:getWidget(panel_title,"Label_ip_name")
    label_player_ip:setFontName("hall/font/bold.ttf")
    label_player_ip:setFontSize(30)
    label_player_ip:setPositionY(label_ip_name:getPositionY()-15)
    label_ip_name:setFontSize(30)
    label_ip_name:setPositionY(label_ip_name:getPositionY()-15)
    label_ip_name:setFontName("hall/font/bold.ttf")
    
    local testHeight = ccui.Text:create();
    testHeight:setTextAreaSize(cc.size(480, 0));
    testHeight:setString(string.format( "id:%s",self.m_data.userid ) or "提示");
    testHeight:setFontSize(30);
    testHeight:addTo(panel_title)
    testHeight:setAnchorPoint(cc.p(0,0.5))
    testHeight:setFontName("hall/font/bold.ttf")
    testHeight:setColor(cc.c3b(0,0,0))
    testHeight:setPosition(cc.p(10,label_ip_name:getPositionY()+35))
--    label_player_ip:setString(self.m_data.lo.."  "..self.m_data.la)
end
function PlayerPosInfoWnd:removeMoRneHead()
    if self.moren_head then
        self.moren_head:removeFromParent()
        self.moren_head = nil
    end
    if self.setMorenHeadThread then
        scheduler.unscheduleGlobal(self.setMorenHeadThread);
    end
end
function PlayerPosInfoWnd:setPostionContent()
    local panel_content = self:getWidget(self.m_pWidget,"Panel_content");
    local panel_position_4 = self:getWidget(panel_content,"Panel_position_4");
    local index = 0
    for i=1,3 do
        local textSize = 50
        local panel_position = self:getWidget(panel_content,"Panel_position_"..i);
        local dataLog = tonumber(self.m_data.lo)
        if (self.m_data.lo == nil or self.m_data.la == nil) or (self.m_data.lo == 0 and self.m_data.la == 0) or dataLog == nil then
            panel_position:setVisible(false)
            panel_position_4:setVisible(true)
            local nameStr = ToolKit.subUtfStrByCn(self.m_data.playerName,0,5,"")
            Log.i("nameStr....",nameStr)
            local label_wufa = self:getWidget(panel_position_4,"Label_wufa")
            label_wufa:setFontSize(40)
            label_wufa:setString( string.format("无法获取玩家%s的位置",nameStr))
        else
            panel_position:setVisible(true)
            panel_position_4:setVisible(false)
            local pos = self.m_data.site[i];
--            Log.i(self.m_data.lo.."  "..self.m_data.la.."  "..pos.lo.."  "..pos.la.."  ")
--            Toast.getInstance():show("位置:"..self.m_data.lo.."  "..self.m_data.la.."  "..pos.lo.."  "..pos.la.."  ")
            local label_yu = self:getWidget(panel_position,"Label_yu")
            local label_name = self:getWidget(panel_position,"Label_name");
            local label_juli = self:getWidget(panel_position,"Label_juli");
            if pos ~= nil then
                local nameStr = ToolKit.subUtfStrByCn(pos.name,0,5,"")
                label_name:setString(nameStr);
                local nameSize = ((self:getlen(nameStr)+1)/3)*textSize
                Log.i("nameSize...",nameSize)
                local lo = tonumber(pos.lo)
                if pos.lo ~=nil and pos.lo ~= 0 and lo ~= nil then
                    label_name:setPosition(cc.p(label_yu:getPositionX()+40,label_yu:getPositionY()))
                    label_juli:setPosition(cc.p(label_name:getPositionX()+nameSize,label_name:getPositionY()));
                    local distance = self:getDistance(self.m_data.lo,self.m_data.la,pos.lo,pos.la);
                    local juli = string.format("相距%s",ToolKit.formatDistance(distance));
                    label_juli:setString(juli);
                else
                    label_yu:setString("无法获取");
                    label_name:setPosition(cc.p(label_yu:getPositionX()+160,label_yu:getPositionY()))
                    label_juli:setPosition(cc.p(label_name:getPositionX()+nameSize+15,label_name:getPositionY()));
                    label_juli:setString("的位置");
                end
            else
                local name = string.format("玩家%d",i)
                local nameSize = 105
                label_yu:setString("无法获取");
                label_name:setString(name);
                label_name:setPosition(cc.p(180,label_name:getPositionY()))
                label_juli:setPosition(cc.p(label_name:getPositionX()+nameSize,label_name:getPositionY()));
                label_juli:setString("的位置");
                label_yu:setVisible(false)
                label_name:setVisible(false)
                label_juli:setVisible(false)
                index = index + 1
            end
        end
        if index == 3 then
            panel_position:setVisible(false)
            panel_position_4:setVisible(true)
            local label_wufa = self:getWidget(panel_position_4,"Label_wufa")
            label_wufa:setFontSize(40)
            label_wufa:setVisible(true)
            label_wufa:setString( string.format("还没有其他玩家进入！"))
        end
    end
end

function PlayerPosInfoWnd:getlen(str)
    local byteSize = 0
    for i = 1 , #str do
        local byteCount = 0
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            byteCount = 1.3
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        byteSize = byteSize + byteCount
    end
    return byteSize
end
function PlayerPosInfoWnd:getDistance(LonA, LatA, LonB, LatB)

        -- 东西经，南北纬处理，只在国内可以不处理(假设都是北半球，南半球只有澳洲具有应用意义)
    local EARTH_RADIUS = 6378137;--赤道半径(单位m)  
    local radLat1 = math.angle2radian(LonA);
    local radLat2 = math.angle2radian(LonB);
    local a = radLat1 - radLat2;
    local b = math.angle2radian(LatA) - math.angle2radian(LatB);

    local s = 2*math.asin(math.sqrt(math.pow(math.sin(a/2),2)+math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)))
    s = s * EARTH_RADIUS;
    s = math.round(s * 10000) / 10000;
    return s;
end


--endregion
