--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.huaibeimj.mediator.game.Define"
PlayerHeadActions = class("PlayerHeadActions")
local kHeadPanel = {
    [Define.site_self] =  "Panel_head_my",
    [Define.site_right] =  "Panel_head_right",
    [Define.site_other] =  "Panel_head_other",
    [Define.site_left] =  "Panel_head_left",
}
-- 头像显示模式类型
local kModePng = {
    [Define.action_xiaPao] = "games/huaibeimj/game/friendRoom/icon_pao.png",
    [Define.action_laZhuang] = "games/huaibeimj/game/friendRoom/icon_la.png",
    [Define.action_zuo] = "games/huaibeimj/game/friendRoom/icon_zuo.png",
}
-- 最大下跑或者拉庄数
local maxNum = 2
function PlayerHeadActions:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/huaibeimj/game/playerActions.csb");
    self.m_data = data
    self.actionPanels   = {} -- 所有头像加注容器
end
function PlayerHeadActions:setDelegate(delegate)
    self.m_delegate = delegate;
end
--获取子控件时赋予特殊属性(支持Label,TextField)
function PlayerHeadActions:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
    if(widget == nil) then 
        return; 
    end
    
    return widget;
end
function PlayerHeadActions:onInit()
--    self.site = self.m_data.site
    --自己的头像
    self.panel_head_my = self:getWidget(self.m_pWidget,"Panel_head_my_action")
    self:updateHead(self.panel_head_my, Define.site_self)
    --右家的头像
    self.panel_head_right = self:getWidget(self.m_pWidget,"Panel_head_right_action")
    self:updateHead(self.panel_head_right, Define.site_right)
    --对家的头像
    self.panel_head_other = self:getWidget(self.m_pWidget,"Panel_head_other_action")
    self:updateHead(self.panel_head_other, Define.site_other)
    --左家的头像
    self.panel_head_left = self:getWidget(self.m_pWidget,"Panel_head_left_action")
    self:updateHead(self.panel_head_left, Define.site_left)
    -- 重设位置
    self:initPosition()
end

function PlayerHeadActions:updateHead(panel_head, site)
    --跑1容器
    local actionPanel1 = self:getWidget(panel_head, "Panel_action_1")
    actionPanel1:setVisible(false)
    if self.actionPanels[site] == nil then
        self.actionPanels[site] = {}
    end
    -- 容器对象内容
    local panelContent = {
        obj     = actionPanel1,
        status  = false,
    }
    table.insert(self.actionPanels[site], panelContent)
    --跑2容器
    local actionPanel2 = self:getWidget(panel_head, "Panel_action_2")
    actionPanel2:setVisible(false)
    -- 容器对象内容
    local panelContent = {
        obj     = actionPanel2,
        status  = false,
    }
    table.insert(self.actionPanels[site], panelContent)
end

function PlayerHeadActions:setGameLayer()
    self.panel_head_my:getLayoutParameter():setMargin({ left = 35, right = 0, top = 0, bottom = 179})
    self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 35, top = 0, bottom = 418})
    self.panel_head_other:getLayoutParameter():setMargin({ left = 0, right = 265, top = 35, bottom = 0})
    self.panel_head_left:getLayoutParameter():setMargin({ left = 35, right = 0, top = 251, bottom = 0})
    self.panel_head_left:getParent():requestDoLayout()
end

--[[
-- @brief  初始化准备精灵函数
-- @param  void
-- @return void
--]]
function PlayerHeadActions:initPosition()
    self.panel_head_my:getLayoutParameter():setMargin({ left = 590, right = 0, top = 0, bottom = 60})
    self.panel_head_right:getLayoutParameter():setMargin({ left = 0, right = 60, top = 0, bottom = 360})
    self.panel_head_other:getLayoutParameter():setMargin({ left = 0, right = 590, top = 60, bottom = 0})
    self.panel_head_left:getLayoutParameter():setMargin({ left = 60, right = 0, top = 360, bottom = 0})
end

function PlayerHeadActions:getHead(site)
    local head = nil
    if site == 1 then
        head = self.panel_head_my
    elseif site == 2 then
        head = self.panel_head_right
    elseif site == 3 then
        head = self.panel_head_other
    elseif site == 4 then
        head = self.panel_head_left
    end
    return head
end
--[[
-- @brief  更新下跑或者拉庄个数函数
-- @param  void
-- @return void
--]]
function PlayerHeadActions:upDateXiaOrLaNum(site, actType, num)
    --跑1图片
    if num <= 0 
        or num > maxNum then
        print("PlayerHeadActions:upDateXiaOrLaNum 输入的数量是0或者过大"..num)
        return
    end
    --容器
    local actionPanel = nil
    if self.actionPanels[site][1].status then
        actionPanel = self.actionPanels[site][2].obj
        actionPanel = self.actionPanels[site][2].obj:setVisible(true)
        self.actionPanels[site][2].status = true
    else
        actionPanel = self.actionPanels[site][1].obj
        self.actionPanels[site][1].status = true
        actionPanel = self.actionPanels[site][1].obj:setVisible(true)
    end
    for i=1, maxNum do
        local str = string.format("Image_pao_%d", i)
        local image_pao = self:getWidget(actionPanel, str)
        
        if i <= num then
            image_pao:setVisible(true)
            -- 修改图片
            image_pao:loadTexture(kModePng[actType], ccui.TextureResType.localType)
        else
            image_pao:setVisible(false)
        end
    end
end
