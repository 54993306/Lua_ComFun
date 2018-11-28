--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CommonSound = {}
function CommonSound.loadEffectName()
    _gameCommonAudioEffectPath = "common/mj"
    _gameCommonAudioEffectCfg = {
        ["anniu"]               = "anniu",              --点击各按钮的声音
        ["buhua"]               = "buhua",              --补花
        ["daojishi"]            = "daojishi",           --倒计时音效
        ["dapai"]               = "dapai",              --打牌声音，牌落到牌桌上的声音
        ["dasezi"]              = "dasezi",             --打色子声音
        ["duihuakuang"]         = "duihuakuang",        --弹出对话框的声音
        ["fangpao"]             = "fangpao",            --放炮的音效 08-10 完整版
        ["fapai"]               = "fapai",              --麻将发牌2（比1多一下发牌声）
        ["gang"]                = "gang",               --杠牌的声音
        ["hupai"]               = "hupai",              --胡牌的音效 08-10 完整版
        ["koupai"]              = "koupai",             --扣牌的声音
        ["lianglaizi"]          = "lianglaizi",         --亮癞子牌音效
        ["liuju"]               = "liuju",              --流局的音效 08-10 完整版
        ["peng"]                = "peng",               --碰牌的声音
        ["tuipai"]              = "koupai",             --推牌声音
    }
end
function CommonSound.music()
	-- if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
	 	if kSettingInfo:getMusicStatus() == true then
	 	    audio.playMusic(_gameBgMusicPath, true)
        end
	-- end
--    audio.playMusic("games/common/mj/mjsound/bgMusic.mp3")
end
function CommonSound.playSound(effectName)
    if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    SoundManager.playEffect(effectName,false)
end
return CommonSound
--endregion
