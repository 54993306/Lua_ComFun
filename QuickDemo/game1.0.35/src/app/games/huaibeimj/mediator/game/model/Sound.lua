-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Define = require "app.games.huaibeimj.mediator.game.Define"


-- endregion

local Sound = { }
function Sound.loadEffectTable()
    _gameAudioEffectCfg = {
        ["cardClick"]                                       = "card_click",                         --点牌音效
        --普通话
        ["putong_man_duanyu_chi_1"]                        = "putong/man/duanyu/chi/1",                   --吃
        ["putong_man_duanyu_buhua_1"]                      = "putong/man/duanyu/buhua/1",                 --哎哟，花，杠（打牌过程中补花用）
        ["putong_man_duanyu_hu_1"]                         = "putong/man/duanyu/hu/1",                    --胡大胡小都是钱啊_R30%
        ["putong_man_duanyu_hu_2"]                         = "putong/man/duanyu/hu/2",                    --糊了_R70%
        ["putong_man_duanyu_peng_1"]                       = "putong/man/duanyu/peng/1",                  --别摸，我碰%
        ["putong_man_duanyu_gang"]                         = "putong/man/duanyu/gang",                    --杠_R
        ["putong_man_liaotianyongyu_1"]                    = "putong/man/liaotianyongyu/1",               --你这呆子！快点快点啊！
        ["putong_man_liaotianyongyu_2"]                    = "putong/man/liaotianyongyu/2",               --搏一搏，单车变摩托！
        ["putong_man_liaotianyongyu_3"]                    = "putong/man/liaotianyongyu/3",               --不打的你满脸桃花开，你就不知道花儿为什么这样红！
        ["putong_man_liaotianyongyu_4"]                    = "putong/man/liaotianyongyu/4",               --没了吧？用不用给你留点盘缠回家啊？
        ["putong_man_liaotianyongyu_5"]                    = "putong/man/liaotianyongyu/5",               --哇！土豪，咱们做朋友吧!
        ["putong_man_liaotianyongyu_6"]                    = "putong/man/liaotianyongyu/6",               --不是吧这样都能赢
        ["putong_man_wan_1"]                               = "putong/man/wan/1",                          --一万_R
        ["putong_man_wan_2"]                               = "putong/man/wan/2",                          --贰万_R
        ["putong_man_wan_3"]                               = "putong/man/wan/3",                          --三万_R
        ["putong_man_wan_4"]                               = "putong/man/wan/4",                          --四万_R
        ["putong_man_wan_5"]                               = "putong/man/wan/5",                          --五万_R
        ["putong_man_wan_6"]                               = "putong/man/wan/6",                          --六万_R
        ["putong_man_wan_7"]                               = "putong/man/wan/7",                          --七万_R
        ["putong_man_wan_8"]                               = "putong/man/wan/8",                          --八万_R
        ["putong_man_wan_9"]                               = "putong/man/wan/9",                          --九万_R
        ["putong_man_tiao_1"]                              = "putong/man/tiao/1",                         --小鸡_R
        ["putong_man_tiao_2"]                              = "putong/man/tiao/2",                         --二条_R
        ["putong_man_tiao_3"]                              = "putong/man/tiao/3",                         --三条_R
        ["putong_man_tiao_4"]                              = "putong/man/tiao/4",                         --四条_R
        ["putong_man_tiao_5"]                              = "putong/man/tiao/5",                         --五条_R
        ["putong_man_tiao_6"]                              = "putong/man/tiao/6",                         --六条_R
        ["putong_man_tiao_7"]                              = "putong/man/tiao/7",                         --七条_R
        ["putong_man_tiao_8"]                              = "putong/man/tiao/8",                         --八条_R
        ["putong_man_tiao_9"]                              = "putong/man/tiao/9",                         --九条_R
        ["putong_man_bing_1"]                              = "putong/man/bing/1",                         --一筒_R
        ["putong_man_bing_2"]                              = "putong/man/bing/2",                         --二筒_R
        ["putong_man_bing_3"]                              = "putong/man/bing/3",                         --三筒_R
        ["putong_man_bing_4"]                              = "putong/man/bing/4",                         --四筒_R
        ["putong_man_bing_5"]                              = "putong/man/bing/5",                         --五筒_R
        ["putong_man_bing_6"]                              = "putong/man/bing/6",                         --六筒_R
        ["putong_man_bing_7"]                              = "putong/man/bing/7",                         --七筒_R
        ["putong_man_bing_8"]                              = "putong/man/bing/8",                         --八筒_R
        ["putong_man_bing_9"]                              = "putong/man/bing/9",                         --九筒_R
        ["putong_man_feng_dongfeng"]                       = "putong/man/feng/dongfeng",                  --东风_R
        ["putong_man_feng_nanfeng"]                        = "putong/man/feng/nanfeng",                   --南风_R
        ["putong_man_feng_xifeng"]                         = "putong/man/feng/xifeng",                    --西风_R
        ["putong_man_feng_beifeng"]                        = "putong/man/feng/beifeng",                   --北风_R
        ["putong_man_feng_hongzhong"]                      = "putong/man/feng/hongzhong",                 --红中_R
        ["putong_man_feng_facai"]                          = "putong/man/feng/facai",                     --发财_R
        ["putong_man_feng_baiban"]                         = "putong/man/feng/baiban",                    --白皮_R
        ["putong_woman_duanyu_buhua_1"]                    = "putong/woman/duanyu/buhua/1",               --哎哟花40%
        ["putong_woman_duanyu_chi_1"]                      = "putong/woman/duanyu/chi/1",                 --吃_R20%
        ["putong_woman_duanyu_hu_1"]                       = "putong/woman/duanyu/hu/1",                  --哎哟糊了糊了糊了_R30%
        ["putong_woman_duanyu_hu_2"]                       = "putong/woman/duanyu/hu/2",                  --哎哟糊了糊了糊了_R30%
        ["putong_woman_duanyu_peng_1"]                     = "putong/woman/duanyu/peng/1",                --慢！我要碰_R20%
        ["putong_woman_duanyu_gang"]                       = "putong/woman/duanyu/gang",                  --杠_R
        ["putong_woman_liaotianyongyu_1"]                  = "putong/woman/liaotianyongyu/1",             --你这呆子！快点快点啊！
        ["putong_woman_liaotianyongyu_2"]                  = "putong/woman/liaotianyongyu/2",             --搏一搏，单车变摩托！
        ["putong_woman_liaotianyongyu_3"]                  = "putong/woman/liaotianyongyu/3",             --不打的你满脸桃花开，你就不知道花儿为什么这样红！
        ["putong_woman_liaotianyongyu_4"]                  = "putong/woman/liaotianyongyu/4",             --没了吧？用不用给你留点盘缠回家啊？
        ["putong_woman_liaotianyongyu_5"]                  = "putong/woman/liaotianyongyu/5",             --哇！土豪，咱们做朋友吧!
        ["putong_woman_liaotianyongyu_6"]                  = "putong/woman/liaotianyongyu/6",             --不是吧这样都能赢
        ["putong_woman_wan_1"]                             = "putong/woman/wan/1",                        --一万_R
        ["putong_woman_wan_2"]                             = "putong/woman/wan/2",                        --贰万_R
        ["putong_woman_wan_3"]                             = "putong/woman/wan/3",                        --三万_R
        ["putong_woman_wan_4"]                             = "putong/woman/wan/4",                        --四万_R
        ["putong_woman_wan_5"]                             = "putong/woman/wan/5",                        --五万_R
        ["putong_woman_wan_6"]                             = "putong/woman/wan/6",                        --六万_R
        ["putong_woman_wan_7"]                             = "putong/woman/wan/7",                        --七万_R
        ["putong_woman_wan_8"]                             = "putong/woman/wan/8",                        --八万_R
        ["putong_woman_wan_9"]                             = "putong/woman/wan/9",                        --九万_R8
        ["putong_woman_tiao_1"]                            = "putong/woman/tiao/1",                       --小鸡_R
        ["putong_woman_tiao_2"]                            = "putong/woman/tiao/2",                       --二条_R
        ["putong_woman_tiao_3"]                            = "putong/woman/tiao/3",                       --三条_R
        ["putong_woman_tiao_4"]                            = "putong/woman/tiao/4",                       --四条_R
        ["putong_woman_tiao_5"]                            = "putong/woman/tiao/5",                       --五条_R
        ["putong_woman_tiao_6"]                            = "putong/woman/tiao/6",                       --六条_R
        ["putong_woman_tiao_7"]                            = "putong/woman/tiao/7",                       --七条_R
        ["putong_woman_tiao_8"]                            = "putong/woman/tiao/8",                       --八条_R
        ["putong_woman_tiao_9"]                            = "putong/woman/tiao/9",                       --九条_R
        ["putong_woman_bing_1"]                            = "putong/woman/bing/1",                       --一筒_R
        ["putong_woman_bing_2"]                            = "putong/woman/bing/2",                       --二筒_R
        ["putong_woman_bing_3"]                            = "putong/woman/bing/3",                       --三筒_R
        ["putong_woman_bing_4"]                            = "putong/woman/bing/4",                       --四筒_R
        ["putong_woman_bing_5"]                            = "putong/woman/bing/5",                       --五筒_R
        ["putong_woman_bing_6"]                            = "putong/woman/bing/6",                       --六筒_R
        ["putong_woman_bing_7"]                            = "putong/woman/bing/7",                       --七筒_R
        ["putong_woman_bing_8"]                            = "putong/woman/bing/8",                       --八筒_R
        ["putong_woman_bing_9"]                            = "putong/woman/bing/9",                       --九筒_R
        ["putong_woman_feng_dongfeng"]                     = "putong/woman/feng/dongfeng",                --东风_R
        ["putong_woman_feng_nanfeng"]                      = "putong/woman/feng/nanfeng",                 --南风_R
        ["putong_woman_feng_xifeng"]                       = "putong/woman/feng/xifeng",                  --西风_R
        ["putong_woman_feng_beifeng"]                      = "putong/woman/feng/beifeng",                 --北风_R
        ["putong_woman_feng_hongzhong"]                    = "putong/woman/feng/hongzhong",               --红中2_R70%
        ["putong_woman_feng_facai"]                        = "putong/woman/feng/facai",                   --发财_R80%
        ["putong_woman_feng_baiban"]                       = "putong/woman/feng/baiban",                  --白皮_R
    }
    _gameAudioEffectPath = "huaibeimj";
    Log.i("_gameAudioEffectPath=", _gameAudioEffectPath)
    SoundManager.pauseMoment();
end
--吃
function Sound.effect_chi(sex)
    if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        SoundManager.playEffect(yuyan.."man_duanyu_chi_1",false)
    elseif sex == 1 then
        SoundManager.playEffect(yuyan.."woman_duanyu_chi_1",false)
    end
end
--补花
function Sound.effect_buhua(sex,must)
    if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
   
    if sex == 0 then
        SoundManager.playEffect(yuyan.."man_duanyu_buhua_1",false)
    elseif sex == 1 then
        SoundManager.playEffect(yuyan.."woman_duanyu_buhua_1",false)
    end

end
--胡
function Sound.effect_hu(actionType, sex)
    if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        if random > 0 and random < 3 then
            SoundManager.playEffect(yuyan.."man_duanyu_hu_1",false)
        else
            SoundManager.playEffect(yuyan.."man_duanyu_hu_2",false)
        end
    elseif sex == 1 then
        if random > 0 and random < 3 then
            SoundManager.playEffect(yuyan.."woman_duanyu_hu_1",false)
        else
            SoundManager.playEffect(yuyan.."woman_duanyu_hu_2",false)
        end
    end
end
--碰
function Sound.effect_peng(sex)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        SoundManager.playEffect(yuyan.."man_duanyu_peng_1",false)
    elseif sex == 1 then
        SoundManager.playEffect(yuyan.."woman_duanyu_peng_1",false)
    end
end
--杠
function Sound.effect_gang(sex)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        SoundManager.playEffect(yuyan.."man_duanyu_gang",false)
    elseif sex == 1 then
        SoundManager.playEffect(yuyan.."woman_duanyu_gang",false)
    end
end

--听
function Sound.effect_ting(sex)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        SoundManager.playEffect(yuyan.."xz_man_duanyu_ting",false)
    elseif sex == 1 then
        SoundManager.playEffect(yuyan.."xz_woman_duanyu_ting",false)
    end
end

--聊天用语
function Sound.effect_yongyu(sex, type)
    if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then -- 男
        if type == 1 then
            SoundManager.playEffect("putong_man_liaotianyongyu_1",false)
        elseif type == 2 then
            SoundManager.playEffect("putong_man_liaotianyongyu_2",false)
        elseif type == 3 then
            SoundManager.playEffect("putong_man_liaotianyongyu_3",false)
        elseif type == 4 then
            SoundManager.playEffect("putong_man_liaotianyongyu_4",false)
        elseif type == 5 then
            SoundManager.playEffect("putong_man_liaotianyongyu_5",false)
        elseif type == 6 then
            SoundManager.playEffect("putong_man_liaotianyongyu_6",false)
        elseif type == 7 then
            SoundManager.playEffect("putong_man_liaotianyongyu_1",false)
        elseif type == 8 then
            SoundManager.playEffect("putong_man_liaotianyongyu_2",false)
        elseif type == 9 then
            SoundManager.playEffect("putong_man_liaotianyongyu_3",false)
        elseif type == 10 then
            SoundManager.playEffect("putong_man_liaotianyongyu_4",false)
        elseif type == 11 then
            SoundManager.playEffect("putong_man_liaotianyongyu_5",false)
        else
            SoundManager.playEffect("putong_man_liaotianyongyu_1",false)
        end
    elseif sex == 1 then --  女
        if type == 1 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_1",false)
        elseif type == 2 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_2",false)
        elseif type == 3 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_3",false)
        elseif type == 4 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_4",false)
        elseif type == 5 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_5",false)
        elseif type == 6 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_6",false)
        elseif type == 7 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_1",false)
        elseif type == 8 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_2",false)
        elseif type == 9 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_3",false)
        elseif type == 10 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_4",false)
        elseif type == 11 then
            SoundManager.playEffect("putong_woman_liaotianyongyu_5",false)
        else
            SoundManager.playEffect("putong_woman_liaotianyongyu_1",false)
        end
    end
    
end
--万
function Sound.effect_wan(sex,type)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."man_wan_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."man_wan_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."man_wan_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."man_wan_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."man_wan_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."man_wan_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."man_wan_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."man_wan_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."man_wan_9",false)
        else
            SoundManager.playEffect(yuyan.."man_wan_1",false)
        end
    elseif sex == 1 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."woman_wan_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."woman_wan_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."woman_wan_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."woman_wan_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."woman_wan_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."woman_wan_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."woman_wan_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."woman_wan_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."woman_wan_9",false)
        else
            SoundManager.playEffect(yuyan.."woman_wan_1",false)
        end
    end
end
--条
function Sound.effect_tiao(sex,type)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."man_tiao_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."man_tiao_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."man_tiao_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."man_tiao_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."man_tiao_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."man_tiao_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."man_tiao_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."man_tiao_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."man_tiao_9",false)
        else
            SoundManager.playEffect(yuyan.."man_tiao_1",false)
        end
    elseif sex == 1 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."woman_tiao_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."woman_tiao_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."woman_tiao_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."woman_tiao_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."woman_tiao_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."woman_tiao_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."woman_tiao_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."woman_tiao_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."woman_tiao_9",false)
        else
            SoundManager.playEffect(yuyan.."woman_tiao_1",false)
        end
    end
end
--筒
function Sound.effect_tong(sex,type)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    if sex == 0 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."man_bing_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."man_bing_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."man_bing_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."man_bing_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."man_bing_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."man_bing_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."man_bing_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."man_bing_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."man_bing_9",false)
        else
            SoundManager.playEffect(yuyan.."man_bing_1",false)
        end
    elseif sex == 1 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."woman_bing_1",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."woman_bing_2",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."woman_bing_3",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."woman_bing_4",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."woman_bing_5",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."woman_bing_6",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."woman_bing_7",false)
        elseif type == 8 then
            SoundManager.playEffect(yuyan.."woman_bing_8",false)
        elseif type == 9 then
            SoundManager.playEffect(yuyan.."woman_bing_9",false)
        else
            SoundManager.playEffect(yuyan.."woman_bing_1",false)
        end
    end
end
--风
function Sound.effect_feng(sex,type)
     if MjProxy:getInstance():getSoundPlaying() == false then
        return
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    local random = math.random(10)
    local yuyan = "putong_"
    
    if sex == 0 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."man_feng_dongfeng",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."man_feng_nanfeng",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."man_feng_xifeng",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."man_feng_beifeng",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."man_feng_hongzhong",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."man_feng_facai",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."man_feng_baiban",false)
        else
            SoundManager.playEffect(yuyan.."man_feng_dongfeng",false)
        end
    elseif sex == 1 then
        if type == 1 then
            SoundManager.playEffect(yuyan.."woman_feng_dongfeng",false)
        elseif type == 2 then
            SoundManager.playEffect(yuyan.."woman_feng_nanfeng",false)
        elseif type == 3 then
            SoundManager.playEffect(yuyan.."woman_feng_xifeng",false)
        elseif type == 4 then
            SoundManager.playEffect(yuyan.."woman_feng_beifeng",false)
        elseif type == 5 then
            SoundManager.playEffect(yuyan.."woman_feng_hongzhong",false)
        elseif type == 6 then
            SoundManager.playEffect(yuyan.."woman_feng_facai",false)
        elseif type == 7 then
            SoundManager.playEffect(yuyan.."woman_feng_baiban",false)
        else
            SoundManager.playEffect(yuyan.."man_feng_dongfeng",false)
        end
    end
end


function Sound.effect(file)
    -- if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
    --  local key = string.format("MJ_USER_DEFAULT_SET_KEY_IS_EFFECT_%s", tostring(MjProxy:getInstance():getMyUserId()))
    --  local isMusic = cc.UserDefault:getInstance():getBoolForKey(key, true)
    --  if not isMusic then
    --      return
    --  end
    --  audio.playEffect(Sound.t[file])
    -- end
end

function Sound.effectXiaZui(num, sex)
    local yuyan = "putong_"
    if sex == 0 then
        if num == 1 then
            SoundManager.playEffect(yuyan.."xz_man_duanyu_zui_1",false)
        elseif num == 2 then
            SoundManager.playEffect(yuyan.."xz_man_duanyu_zui_2",false)
        end
    elseif sex == 1 then
        if num == 1 then
            SoundManager.playEffect(yuyan.."xz_woman_duanyu_zui_1",false)
        elseif num == 2 then
            SoundManager.playEffect(yuyan.."xz_woman_duanyu_zui_2",false)
        end
    end
        
end

return Sound
