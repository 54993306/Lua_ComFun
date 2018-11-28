
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0;

-- display FPS stats on screen
DEBUG_FPS = false;

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true;

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "portrait"

-- design resolution
CONFIG_SCREEN_WIDTH  = 720;
CONFIG_SCREEN_HEIGHT = 1280;

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT";

-- 是否选择服务器用于测试
--_isChooseServerForTest = true
--tabServerIP = {
--	"192.168.0.6",   --06服务器
--	"121.196.217.142", --142服务器
--	"huaib.dasheng-game.com" --外网服务器
--}

-- outer net serverip
--SERVER_IP = "118.178.156.122";
-- SERVIER_PORT = "19998";

-- SERVER_IP = "123.57.166.73";

  -- SERVER_IP = "192.168.0.6";
--  SERVIER_PORT = "9498";
--安庆地址
--SERVER_IP = "anq.dasheng-game.com"
--SERVIER_PORT = "9798"
--无锡域名
--SERVER_IPS = {
--    "wuxi.dasheng-game.com",
--    "wuxi.dasheng-game.com"
--}
--SERVER_IP = SERVER_IPS[1]
--SERVIER_PORT = "6998"
--SERVER_IP = "101.37.227.222"
--SERVER_IPS = {
--     "bengbu.dasheng-game.com",
--     "qzC34Ow24wOp.dasheng-game.com"
----   "192.168.8.211",
----   "192.168.8.211",
--}
--------蚌埠
--SERVER_IP = SERVER_IPS[1]
-------- ----SERVER_IP = "192.168.1.31"
-- SERVIER_PORT = "9698"
--142
--SERVER_IP= "192.168.1.18"
--SERVIER_PORT = "19698"
--淮北
   SERVER_IPS = {
    "huaib.stevengame.com",
    "huaib.stevengame.com"
    -- "116.62.238.62",
    -- "116.62.238.62",
    -- "192.168.7.6"
   }
   SERVER_IP = SERVER_IPS[1]
 --  SERVER_IP = "121.196.217.142"
  -- SERVIER_PORT = "9478"
  SERVIER_PORT = "9498"
--淮南
--SERVER_IP = "huainan.dasheng-game.com"
--SERVIER_PORT = "9498"
--142
-- SERVIER_PORT = "8350"


IMEI = "100000037";
MAC  = "abcdedfff";
MODEL = "sengle-pc";
OS = 4;-- 操作系统：2:ios, 1:android, 3:mac, 4:windows
SPID = 10000; -- 测试：10000， 应用宝:10001, ios：10002
VERSION = "1.0.36";
NETMODE = 1;


--WX_APP_ID = "wx72b73f58661aca79"; --常州
WX_OPENID = "ouZDGwwrsxjvajAjW7pS6dCpHizU_12";
WX_NAME = "4号";
WX_SEX = 1;
WX_PR = "广东";
WX_CITY = "深圳";
WX_CO = "中国";
WX_HEAD = "";

--提审标志，提审的时候打开，审核通过关闭
IS_YINGYONGBAO = false;
IS_IOS = false;
IS_IOS_PRODUCT = false
--徐州
-- _gameType = "huaibeimj"
-- WX_APP_ID = "wx72b73f58661aca79";

--常州
-- CONFIG_GAEMID = 10008;--游戏ID
-- _gameType = "changzhoumj"
-- WX_APP_ID = "wxbb66358e8d2117bb";

--红中
--_gameType = "hongzhongmj"
--WX_APP_ID = "wx664ab09bd038f675";

--安庆
--_gameType = "anqingmj"
--WX_APP_ID = "wxb7b780e01c4124a6";
--无锡麻将
--_gameType = "wuximj"
--WX_APP_ID = "wx56467c802f92301d"

--蚌埠
--_gameType = "bengbumj"
--CONFIG_GAEMID = 10022;--游戏ID
--WX_APP_ID = "wxb1718e63cc970544";

---- 淮北
   _gameType = "huaibeimj"
     CONFIG_GAEMID = 10020;--游戏ID
   WX_APP_ID = "wx34f4ac12ec59a5eb";
   PRODUCT_ID = 10020

-- 淮南
-- _gameType = "huainanmj"
-- WX_APP_ID = "wxc03b95d364e7b752";
--微信头像测试
--WX_HEAD = "http://wx.qlogo.cn/mmopen/ajNVdqHZLLCZHe0PtY7TzmVTYp94c8sDoyo9WN4FVmVz9iapgMqKjKCLWEdl6PU4ugBgwIu4j1wicKiaTpGdIcMqSpdDjRbF1SGdgPUiaJNWcWc/0";

-- 关注公众号信息(以后请从服务器下发)
GC_OfficalAccount = "lailaibengbu"
GC_OfficalAccountBtn = "games/bengbumj/hall/main/btn_officialAccount.png"
GC_OfficalAccountImg = "games/bengbumj/hall/main/img_exchangeHelp.png"
GC_ShowExchange = true

G_OPEN_CHARGE = true

--白名单URL Root
-- _WhiteListConfigUrlRoot = ""
-- if _is18Server then
    -- _WhiteListConfigUrlRoot = "http://192.168.7.105:8089"
    -- _WeChatSharedBaseUrl = "http://192.168.7.105:8099/Api/getConfig"    -- 请求微信分享数据后台链接
    -- _WeCharSHaredBaseFeedBackUrl = "http://192.168.7.105:8060/Api/shareFeeback"    -- 反馈分享结果链接
    -- _WechatSharedClicksNumberUrl = "http://192.168.7.105:8060/Api/shareLandFeeback"    -- 反馈分享结果链接

-- elseif _isPreReleaseEnv then
--     _WhiteListConfigUrlRoot = "http://pre-client-download-cdn.stevengame.com"
--     _WeChatSharedBaseUrl = "http://pre-app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
--     _WeCharSHaredBaseFeedBackUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
--     _WechatSharedClicksNumberUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareLandFeeback"   ---预发布分享次数统计调用

-- else
    _WhiteListConfigUrlRoot = "http://client-download-cdn.stevengame.com"
    _WeChatSharedBaseUrl = "http://app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
    _WeCharSHaredBaseFeedBackUrl = "http://client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
    _WechatSharedClicksNumberUrl = "http://client-sharedata-upload.stevengame.com/Api/shareLandFeeback"   ---预发布分享次数统计调用
-- end

DEBUG_SHIELD_VALUE = {
    -- "openActivity", -- 是否开启活动 (目前新老淮北，还有江苏，安徽，河南，广东的省包  需要开，其他的市包不需要)
    "openFileLog", -- 是否开启日志上传
}
GC_GameName = "来来淮北麻将"
SCHEME_HOST_NAME = "lailaihuaibei"
DEBUG = 1
DEBUG_MODE = type(DEBUG) == "number" and DEBUG > 0
