SoundManager = {};

--大厅音效
local sound_config ={
    ["btn"] = "btn_click",--按钮音效
    ["dialog_pop"] = "dialog_pop",--对话框弹出
    ["gift_get"] = "gift_get",--礼包领取
    ["gold_rain"] = "gold_rain",--金币雨
    ["magic_face_1"] = "magic_face_1",--魔法表情1
    ["magic_face_2"] = "magic_face_2",--魔法表情2
    ["magic_face_40"] = "magic_face_40",--魔法表情4男
    ["magic_face_41"] = "magic_face_41",--魔法表情4女
    ["magic_face_3"] = "magic_face_3",--魔法表情3
    ["magic_face_5"] = "magic_face_5",--魔法表情5
}

--大厅配音
local dub_config ={
    ["chat_txt10"] = "chat_txt10",--聊天语1男
    ["chat_txt20"] = "chat_txt20",--聊天语2男
    ["chat_txt30"] = "chat_txt30",--聊天语3男
    ["chat_txt40"] = "chat_txt40",--聊天语4男
    ["chat_txt50"] = "chat_txt50",--聊天语5男

    ["chat_txt11"] = "chat_txt11",--聊天语1女
    ["chat_txt21"] = "chat_txt21",--聊天语2女
    ["chat_txt31"] = "chat_txt31",--聊天语3女
    ["chat_txt41"] = "chat_txt41",--聊天语4女
    ["chat_txt51"] = "chat_txt51",--聊天语5女
}

--游戏音效
_gameAudioEffectCfg ={};
_gameAudioEffectPath = "ddz";

--音效句柄
SoundManager.handles = {};
SoundManager.isStartGame = false;

--暂停一下自动恢复（用于游戏从后台回到前台）
SoundManager.pauseMoment = function(time)
    if SoundManager.m_pauseScheduler then
        scheduler.unscheduleGlobal(SoundManager.m_pauseScheduler);
        SoundManager.m_pauseScheduler = nil;
    end
    SoundManager.m_isPause = true
    Log.i("------SoundManager.pauseMoment1", SoundManager.m_isPause);
    SoundManager.m_pauseScheduler = scheduler.performWithDelayGlobal(function ()
        Log.i("------SoundManager.pauseMoment2", SoundManager.m_isPause);
        SoundManager.m_isPause = false;
    end, time or 1);
end

--播放音效
SoundManager.playEffect = function(effectName, gamePath, isLoop)
    if SoundManager.m_isPause then
        return;
    end
    local fileName = nil;
    -- 由于声音控制是整个游戏的所以在这里判断如果状态是禁止直接返回
    if not kSettingInfo:getSoundStatus() then
        return;
    end
	Log.i("播放音效" .. effectName)
    if sound_config[effectName] then
        if gamePath == "hall" then
            
        else
            if not kSettingInfo:getGameSoundStatus(_gameAudioEffectPath) then
                return;
            end
        end
        -- if device.platform == "android" then
        --     fileName = "hall/audio/ogg/effect/" .. sound_config[effectName] .. ".ogg";
        -- else
            fileName = "hall/audio/mp3/effect/" .. sound_config[effectName] .. ".mp3";
        --end
    end

    if not fileName and dub_config[effectName] then
       
        if not kSettingInfo:getGameDubStatus(_gameAudioEffectPath) then
            return;
        end
        
        -- if device.platform == "android" then
        --     fileName = "hall/audio/ogg/effect/" .. sound_config[effectName] .. ".ogg";
        -- else
            fileName = "hall/audio/mp3/effect/" .. dub_config[effectName] .. ".mp3";
        --end
    end

    if not fileName and _gameAudioEffectCfg[effectName] then
        -- if device.platform == "android" then
        --     fileName = "games/" .. _gameAudioEffectPath .. "/audio/ogg/effect/" .. _gameAudioEffectCfg[effectName] .. ".ogg";
        -- else
            fileName = "games/" .. _gameAudioEffectPath .. "/audio/mp3/effect/" .. _gameAudioEffectCfg[effectName] .. ".mp3";
        --end
    elseif not fileName and _gameCommonAudioEffectCfg and _gameCommonAudioEffectCfg[effectName] then
        -- if device.platform == "android" then
        --     fileName = "games/" .. _gameCommonAudioEffectPath .. "/audio/ogg/effect/" .. _gameAudioEffectCfg[effectName] .. ".ogg";
        -- else
            fileName = "games/" .. _gameCommonAudioEffectPath .. "/audio/mp3/effect/" .. _gameCommonAudioEffectCfg[effectName] .. ".mp3";
        --end
    end
    Log.i("------SoundManager.playEffect fileName", fileName);
    if fileName then
        if isLoop then
            return audio.playSound(fileName, true);
        else
            audio.playSound(fileName, false);
        end
    end
end

--循环播放音效
SoundManager.playEffectLoop = function (effectName)
    if not kSettingInfo:getSoundStatus() then
        return;
    end
    SoundManager.handles[effectName] = SoundManager.playEffect(effectName, nil, true);
    
end

--关闭循环播放的音效
SoundManager.stopEffect = function (effectName)
    Log.i("------stopEffect", effectName);
    if SoundManager.handles[effectName] then
        Log.i("------stopEffect", effectName);
        audio.stopSound(SoundManager.handles[effectName]);
        SoundManager.handles[effectName] = nil;
    end
end