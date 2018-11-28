--
AdvertViewDialog = class("AdvertViewDialog", UIWndBase);

function AdvertViewDialog:ctor(...)
    self.super.ctor(self, "hall/redPacket.csb", ...);
    self.m_data=...;
	Log.i("url:" ..self.m_data.url .. "       " .. "imageFileName:" .. self.m_data.imageFileName )
end

function AdvertViewDialog:onClose()
end

function AdvertViewDialog:onInit()
   
   self:addShowder()
   
   self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn");
   self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));

    self.bg =  ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
    self.bg:loadTexture(_gameRedpacketAdPath);
    if IS_YINGYONGBAO == false then
        local imgName = self.m_data.imageFileName;
        if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
            local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(imgFile) then
                self.bg:loadTexture(imgFile);
            else
                HttpManager.getNetworkImage(self.m_data.url .. imgName, imgName);
            end
        end
    end
end

--增加阴影
function AdvertViewDialog:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end
--返回网络图片
function AdvertViewDialog:onResponseNetImg(fileName)
    Log.i("------AdvertViewDialog:onResponseNetImg fileName", fileName);
    if kServerInfo:getMainAdUrl2() == fileName then
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        if io.exists(imgFile) then
            self.bg:loadTexture(imgFile);
        end 
    end
end

function AdvertViewDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.closeBtn then
		   UIManager:getInstance():popWnd(AdvertViewDialog);
        end
    end
end

AdvertViewDialog.s_socketCmdFuncMap = {

};