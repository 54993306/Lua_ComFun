--region *.lua

-- btnNum 按钮数量
-- titleStr 标题文字
-- tipStr 提示文字
-- confirmStr 确认按钮文字（左边按钮）
-- confirmCallBack 左边按钮点击回调
-- cancelStr 取消按钮文字（右边按钮）
-- cancelCallBack 右边按钮点击回调

MJCommonDialog = class("MJCommonDialog", function ()
    return display.newLayer()
end)

function MJCommonDialog:ctor(dialogData)
    self:onEnter()
    self.m_dialogData = dialogData or {}
    self.m_dialogData.btnNum = dialogData.btnNum or 2 --默认两个按钮

    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:setSwallowTouches(true)
    touchListener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self)

    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    self:addChild(layer, -1)
   
    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height
    -- 背景
    local bgSprite = display.newSprite("games/common/mj/games/tip_bg.png")
    bgSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight / 2))
    self:addChild(bgSprite)

    -- 标题
    -- local titleLabel = cc.Label:create()
    -- titleLabel:setString(self.m_dialogData.titleStr or "提示")
    -- titleLabel:setSystemFontSize(30)
    -- titleLabel:setColor(display.COLOR_WHITE)
    -- titleLabel:setPosition(cc.p(bgSprite:getContentSize().width / 2, 328))
    -- titleLabel:addTo(bgSprite)

    -- 提示语
    local tipLabel = cc.Label:create()
    tipLabel:setString(self.m_dialogData.tipStr or "提示")
    tipLabel:setSystemFontSize(35)
    tipLabel:setColor(display.COLOR_WHITE)
    tipLabel:setPosition(cc.p(bgSprite:getContentSize().width / 2, 183))
    tipLabel:addTo(bgSprite)
    tipLabel:setSystemFontName ("hall/font/bold.ttf")

    if self.m_dialogData.btnNum == 1 then --一个按钮
         -- -- 确定
        local confirmSprite = display.newSprite("games/common/mj/common/btn_dilog.png")
        local confirmLabel = cc.Label:create()
        confirmLabel:setString(self.m_dialogData.confirmStr or "确 定")
        confirmLabel:setSystemFontSize(35)
        confirmLabel:setSystemFontName ("hall/font/bold.ttf")
        confirmLabel:setPosition(cc.p(confirmSprite:getContentSize().width/2, confirmSprite:getContentSize().height/2))
        confirmLabel:addTo(confirmSprite)
        confirmLabel:setColor(display.COLOR_WHITE)
        local confirmItem = cc.MenuItemSprite:create(confirmSprite, confirmSprite)
        confirmItem:setPosition(cc.p(bgSprite:getContentSize().width / 2, confirmSprite:getContentSize().height/2 + 10))
        confirmItem:registerScriptTapHandler(handler(self, function ()
            if self.m_dialogData.confirmCallBack then
                self.m_dialogData.confirmCallBack()
                self:removeFromParent()
            end
        end))       
        local menu = cc.Menu:create(confirmItem)
        menu:setPosition(cc.p(0, 0))
        menu:addTo(bgSprite)

    elseif self.m_dialogData.btnNum == 2 then --两个按钮
        -- -- 确定
        local confirmSprite = display.newSprite("games/common/mj/common/btn_dilog.png")
        local confirmLabel = cc.Label:create()
        confirmLabel:setString(self.m_dialogData.confirmStr or "确 定")
        confirmLabel:setSystemFontSize(35)
        confirmLabel:setSystemFontName ("hall/font/bold.ttf")
        confirmLabel:setPosition(cc.p(confirmSprite:getContentSize().width/2, confirmSprite:getContentSize().height/2))
        confirmLabel:addTo(confirmSprite)
        confirmLabel:setColor(display.COLOR_WHITE)
        local confirmItem = cc.MenuItemSprite:create(confirmSprite, confirmSprite)
        confirmItem:setPosition(cc.p(127, confirmSprite:getContentSize().height/2 + 10))
        confirmItem:registerScriptTapHandler(handler(self, function ()
            if self.m_dialogData.confirmCallBack then
                self.m_dialogData.confirmCallBack()
                self:removeFromParent()
            end
        end)) 

        -- 取消
        local cancelSprite = display.newSprite("games/common/mj/common/btn_dilog.png")
        local cancelLabel = cc.Label:create()
        cancelLabel:setString(self.m_dialogData.cancelStr or "取 消")
        cancelLabel:setSystemFontSize(35)
        cancelLabel:setSystemFontName ("hall/font/bold.ttf")
        cancelLabel:setPosition(cc.p(cancelSprite:getContentSize().width/2, cancelSprite:getContentSize().height/2))
        cancelLabel:addTo(cancelSprite)
        cancelLabel:setColor(display.COLOR_WHITE)
        local cancelItem = cc.MenuItemSprite:create(cancelSprite, cancelSprite)
        cancelItem:setPosition(cc.p(372, cancelSprite:getContentSize().height/2 + 10))
        cancelItem:registerScriptTapHandler(handler(self, function ()
            if self.m_dialogData.cancelCallBack then
                self.m_dialogData.cancelCallBack()
                self:removeFromParent()
            end
        end))  
          
       local menu = cc.Menu:create(confirmItem, cancelItem)
        menu:setPosition(cc.p(0, 0))
        menu:addTo(bgSprite)
    end

end
function MJCommonDialog:onTouchBegan(touch, event)
   self:removeFromParent()
end

function MJCommonDialog:onEnter()
	Log.i("PlayLayer:onEnter#######################")
	self._m_pListener = cc.EventListenerTouchOneByOne:create()
	self._m_pListener:registerScriptHandler( function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(self._m_pListener, self)

	self._m_pListener:setEnabled(true)
end

