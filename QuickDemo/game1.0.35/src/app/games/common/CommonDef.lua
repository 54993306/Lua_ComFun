-------------------------------------------------------------
--  @file   CommonDef.lua
--  @brief  lua 类定义
--  @author ZCQ
--  @DateTime:2016-11-15 15:34:20
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
-- 比赛结果 
enResult =
{
    DEFAULT = 0, -- 默认
    WIN 	= 1, -- 赢
    FAILED 	= 2, -- 输
    BUREAU  = 3, -- 流局
};

-- 结算类型 wi
enGameOverType =
{
    ZI_MO 		= 1, -- 自摸
    FANG_PAO 	= 2, -- 放炮
    BUREAU  	= 3, -- 流局
    ERROR  	    = 4, -- 出错
};

enRadioButtonMode =
{
    TEXTURE = 1,  -- 图片模式
    FRAME   = 2,  -- 模板模式
    TEXT    = 3,  -- 文字模式
    CHANGE  = 4,  -- 替换底图模式
};
-- 手牌对3求余的结果
enHandCardRemainder =
{
    PROHIBIT_PLAY   = 1,  -- 禁止打牌
    CAN_PLAY        = 2,  -- 可以打牌
};
