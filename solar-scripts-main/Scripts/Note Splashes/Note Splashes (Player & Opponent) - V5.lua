-- ╔══════════════════════════════════════════════════════╗
-- ║   Note Splashes (Player & Opponent) — RGB + Pixel    ║
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
local forcePixelSplash = false
local usePixelTextureFallback = true

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

    useRGB = getPropertyFromClass('backend.ClientPrefs', 'data.noteRGB')
    if useRGB == nil then useRGB = getPropertyFromClass('ClientPrefs', 'data.noteRGB') end
    if useRGB == nil then useRGB = getPropertyFromClass('backend.ClientPrefs', 'noteRGB') end
    if useRGB == nil then useRGB = true end
end

-- ===================== NOTE HIT =====================

function goodNoteHit(id, direction, noteType, isSustainNote)
    if getPropertyFromGroup('notes', id, 'rating') == 'sick' and not isSustainNote then
        spawnSplash(direction, true)
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if not isSustainNote then
        spawnSplash(direction, false)
    end
end

-- ===================== SPAWN =====================

function spawnSplash(dir, isPlayer)
    isPixelStage = detectPixelStage()

    -- اختيار السبرايت حسب RGB + Pixel
    local splashTexture = useRGB and 'noteSplashes' or 'noteSplashes-nRGB'
    if isPixelStage and usePixelTextureFallback then
        splashTexture = useRGB and 'noteSplashes-pixel' or 'noteSplashes-nRGB-pixel'
    end

    local strumGroup = isPlayer and 'playerStrums' or 'opponentStrums'
    local tag        = (isPlayer and 'psplash' or 'osplash') .. getRandomInt(0, 100000)

    local x = getPropertyFromGroup(strumGroup, dir, 'x') - 120
    local y = getPropertyFromGroup(strumGroup, dir, 'y') - 120

    makeAnimatedLuaSprite(tag, splashTexture, x, y)

    local variant = getRandomInt(1, 2)
    addAnimationByPrefix(tag, 'splash', splashAnims[dir] .. ' ' .. variant, 24, false)

    setObjectCamera(tag, 'camHUD')
    setProperty(tag..'.visible',      getPropertyFromGroup(strumGroup, dir, 'visible'))
    setProperty(tag..'.alpha',        getPropertyFromGroup(strumGroup, dir, 'alpha'))
    if isPixelStage then
        setProperty(tag..'.antialiasing', false)
    else
        setProperty(tag..'.antialiasing', getPropertyFromGroup(strumGroup, dir, 'antialiasing'))
    end

    addLuaSprite(tag, true)

    if isPixelStage then
        setProperty(tag..'.antialiasing', false)
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
        local p   = isPlayer and 'true' or 'false'
        runHaxeCode(
            'var spr = game.modchartSprites.get("' .. tag .. '");'
         .. 'var strum = ' .. p
         ..     ' ? game.playerStrums.members['   .. ids .. ']'
         ..     ' : game.opponentStrums.members[' .. ids .. '];'
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

    activeSplashes[tag] = true
end

-- ===================== UPDATE =====================

function onUpdatePost(elapsed)
    for tag, _ in pairs(activeSplashes) do
        if getProperty(tag .. '.animation.finished') then
            removeLuaSprite(tag, true)
            activeSplashes[tag] = nil
        end
    end
end
