-- ╔══════════════════════════════════════════════════════╗
-- ║   Note Splashes Offsets                              ║
-- ║   Psych Engine 0.6.3  [v1 HOTFIX]                    ║
-- ║   Solar Engine 0.6.X                                 ║
-- ║   By Mr YMR (@ymrgame2009)				              ║
-- ╚══════════════════════════════════════════════════════╝

local offsets = {}

function onCreatePost()
    local splashName = "noteSplashes"
    if getProperty('unspawnNotes.length') > 0 then
        local customTex = getPropertyFromGroup('unspawnNotes', 0, 'noteSplashTexture') or getPropertyFromGroup('unspawnNotes', 0, 'noteSplashData.texture')
        if customTex ~= nil and customTex ~= "" and customTex ~= "noteSplashTexture" then
            splashName = customTex
        end
    end

    local modDir = getPropertyFromClass('Paths', 'currentModDirectory')
    if modDir == nil then modDir = "" end

    local searchPaths = {
        "mods/images/" .. splashName .. ".txt",
        "assets/images/" .. splashName .. ".txt",
        "assets/shared/images/" .. splashName .. ".txt",
        "images/" .. splashName .. ".txt"
    }
    
    if modDir ~= "" then
        table.insert(searchPaths, "mods/" .. modDir .. "/images/" .. splashName .. ".txt")
    end

    for i = 1, #searchPaths do
        local file = io.open(searchPaths[i], "r")
        if file then
            for line in file:lines() do
                local x, y = string.match(line, "^([%-%d]+)%s+([%-%d]+)$")
                if x and y then
                    table.insert(offsets, {x = tonumber(x), y = tonumber(y)})
                end
            end
            file:close()
            break
        end
    end
    
    while #offsets < 8 do
        table.insert(offsets, {x = 0, y = 0})
    end
end

function onUpdatePost()
    local len = getProperty('grpNoteSplashes.length')
    
    for i = 0, len - 1 do
        local animName = getPropertyFromGroup('grpNoteSplashes', i, 'animation.name')
        
        if animName ~= nil and animName ~= "" then
            local ox, oy = nil, nil
            
            if string.find(animName, "note0%-1") then ox, oy = offsets[1].x, offsets[1].y
            elseif string.find(animName, "note0%-2") then ox, oy = offsets[2].x, offsets[2].y
            elseif string.find(animName, "note1%-1") then ox, oy = offsets[3].x, offsets[3].y
            elseif string.find(animName, "note1%-2") then ox, oy = offsets[4].x, offsets[4].y
            elseif string.find(animName, "note2%-1") then ox, oy = offsets[5].x, offsets[5].y
            elseif string.find(animName, "note2%-2") then ox, oy = offsets[6].x, offsets[6].y
            elseif string.find(animName, "note3%-1") then ox, oy = offsets[7].x, offsets[7].y
            elseif string.find(animName, "note3%-2") then ox, oy = offsets[8].x, offsets[8].y
            end
            
            if ox ~= nil then
                setPropertyFromGroup('grpNoteSplashes', i, 'offset.x', ox + 10)
                setPropertyFromGroup('grpNoteSplashes', i, 'offset.y', oy + 10)
            end
        end
    end
end
