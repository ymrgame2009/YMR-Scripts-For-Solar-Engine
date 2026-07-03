-- ╔══════════════════════════════════════════════════════╗
-- ║   Note Splashes (Player) — RGB + Pixel Support       ║
-- ║   Psych Engine 0.6.3  [v5]                           ║
-- ║   Universe Engine 0.5.5	                          ║
-- ║   By Mr YMR (@ymrgame2009)				              ║
-- ╚══════════════════════════════════════════════════════╝

local splashAnims = {
    [0] = 'note splash purple',
    [1] = 'note splash blue',
    [2] = 'note splash green',
    [3] = 'note splash red'
}

local useRGB       = false
local isPixelStage = false
local pixelSplashSize = 3
local forcePixelSplash = false
local usePixelTextureFallback = true

-- نخزن كل الـ splashes النشطة عشان نتحقق من animation.finished
local activeSplashes = {}
local pixelStages = {
    school = true,
    idk = true,
    block = true,
    missingblock = true,
    undertale = true
}

function detectPixelStage()
    local pixel = getPropertyFromClass('states.PlayState', 'isPixelStage')
    if pixel == nil then pixel = getPropertyFromClass('PlayState', 'isPixelStage') end
    if pixel == nil then pixel = getPropertyFromClass('states.PlayState', 'stageData.isPixelStage') end
    if pixel == nil then pixel = getPropertyFromClass('PlayState', 'stageData.isPixelStage') end
    if pixel == nil then pixel = getProperty('isPixelStage') end
    if pixel == nil then pixel = getProperty('stageData.isPixelStage') end

    if forcePixelSplash or pixel == true or pixel == 'true' then
        return true
    end

    local stage = getPropertyFromClass('states.PlayState', 'curStage')
    if stage == nil then stage = getPropertyFromClass('PlayState', 'curStage') end
    if stage == nil then stage = getProperty('curStage') end
    if stage == nil then stage = getProperty('SONG.stage') end

    if stage ~= nil then
        return pixelStages[string.lower(tostring(stage))] == true
    end

    return false
end

function onCreatePost()
    isPixelStage = detectPixelStage()
    if isPixelStage and initLuaShader ~= nil and not usePixelTextureFallback then
        pcall(initLuaShader, 'pixelateSplash')
    end

    useRGB = getPropertyFromClass('backend.ClientPrefs', 'data.noteRGB')
    if useRGB == nil then useRGB = getPropertyFromClass('ClientPrefs', 'data.noteRGB') end
    if useRGB == nil then useRGB = getPropertyFromClass('backend.ClientPrefs', 'noteRGB') end
    if useRGB == nil then useRGB = true end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if getPropertyFromGroup('notes', id, 'rating') == 'sick' and not isSustainNote then
        spawnSplash(direction)
    end
end

function spawnSplash(dir)
    isPixelStage = detectPixelStage()

    -- اختيار السبرايت حسب RGB + Pixel
    local splashTexture = useRGB and 'noteSplashes' or 'noteSplashes-nRGB'
    if isPixelStage and usePixelTextureFallback then
        splashTexture = useRGB and 'noteSplashes-pixel' or 'noteSplashes-nRGB-pixel'
    end

    local tag = 'splash' .. getRandomInt(0, 100000)
    local x   = getPropertyFromGroup('playerStrums', dir, 'x') - 120
    local y   = getPropertyFromGroup('playerStrums', dir, 'y') - 120

    makeAnimatedLuaSprite(tag, splashTexture, x, y)

    local variant = getRandomInt(1, 2)
    addAnimationByPrefix(tag, 'splash', splashAnims[dir] .. ' ' .. variant, 24, false)

    setObjectCamera(tag, 'camHUD')
    setProperty(tag..'.visible',      getPropertyFromGroup('playerStrums', dir, 'visible'))
    setProperty(tag..'.alpha',        getPropertyFromGroup('playerStrums', dir, 'alpha'))
    if isPixelStage then
        setProperty(tag..'.antialiasing', false)
    else
        setProperty(tag..'.antialiasing', getPropertyFromGroup('playerStrums', dir, 'antialiasing'))
    end

    addLuaSprite(tag, true)

    if isPixelStage then
        setProperty(tag..'.antialiasing', false)

        if setSpriteShader ~= nil and not usePixelTextureFallback then
            pcall(setSpriteShader, tag, 'pixelateSplash')
        end

        if setShaderFloat ~= nil and not usePixelTextureFallback then
            pcall(setShaderFloat, tag, 'pixelSize', pixelSplashSize)
        end

        runHaxeCode(
            'var spr = game.modchartSprites.get("' .. tag .. '");'
         .. 'if (spr != null) {'
         ..     'spr.antialiasing = false;'
         ..     'if (spr.graphic != null && spr.graphic.bitmap != null)'
         ..         'spr.graphic.bitmap.smoothing = false;'
         .. '}'
        )
    end

    objectPlayAnimation(tag, 'splash', true)

    -- RGB
    if useRGB then
        local ids = tostring(dir)
        runHaxeCode(
            'var spr = game.modchartSprites.get("' .. tag .. '");'
         .. 'var strum = game.playerStrums.members[' .. ids .. '];'
         .. 'if (spr != null && strum != null) {'
         ..     'try {'
         ..         'var rgb:Dynamic = Reflect.field(strum, "rgbShader");'
         ..         'if (rgb != null) {'
         ..             'try { Reflect.setField(spr, "rgbShader", rgb); } catch(e:Dynamic) {}'
         ..             'var rgbShader:Dynamic = Reflect.field(rgb, "shader");'
         ..             'if (rgbShader != null) spr.shader = rgbShader;'
         ..             'else if (strum.shader != null) spr.shader = strum.shader;'
         ..         '} else if (strum.shader != null) {'
         ..             'spr.shader = strum.shader;'
         ..         '}'
         ..     '} catch(e:Dynamic) {'
         ..         'if (strum.shader != null) spr.shader = strum.shader;'
         ..     '}'
         ..     'if (spr.shader == null) spr.color = strum.color;'
         ..     'if (' .. tostring(isPixelStage) .. ') {'
         ..         'spr.antialiasing = false;'
         ..         'if (spr.graphic != null && spr.graphic.bitmap != null) spr.graphic.bitmap.smoothing = false;'
         ..     '}'
         .. '}'
        )
    end

    -- نضيف للقائمة عشان نراقبه في update
    activeSplashes[tag] = true
end

function onUpdatePost(elapsed)
    for tag, _ in pairs(activeSplashes) do
        -- لما الأنيميشن يخلص نحذف السبرايت
        if getProperty(tag .. '.animation.finished') then
            removeLuaSprite(tag, true)
            activeSplashes[tag] = nil
        end
    end
end
