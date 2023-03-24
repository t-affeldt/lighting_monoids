lighting_monoids = {}

local SET_BASE_SHADOW = minetest.settings:get_bool("lighting_monoids.set_base_shadow", true)
local BASE_SHADOW_INTENSITY = tonumber(minetest.settings:get("lighting_monoids.base_shadow_intensity") or 0.33)

local MODPATH = minetest.get_modpath(minetest.get_current_modname())

local function multiply(a, b)
    if a == nil then a = 1 end
    if b == nil then b = 1 end
    return a * b
end

local function fold_multiply(values)
    local total = 1
    for _, val in pairs(values) do
        if val ~= nil then
            total = total * val
        end
    end
    return total
end

-- Define monoid for shadow intensity
lighting_monoids.shadows = player_monoids.make_monoid({
    identity = 1,
    combine = multiply,
    fold = fold_multiply,
    apply = function(multiplier, player)
        local lighting = player:get_lighting()
        lighting.shadows = lighting.shadows or {}
        lighting.shadows.intensity = multiplier
        if player.set_lighting ~= nil then
            player:set_lighting(lighting)
        end
    end
})

-- Define monoid for color saturation
lighting_monoids.saturation = player_monoids.make_monoid({
    identity = 1,
    combine = multiply,
    fold = fold_multiply,
    apply = function(multiplier, player)
        local lighting = player:get_lighting()
        lighting.saturation = multiplier
        if player.set_lighting ~= nil then
            player:set_lighting(lighting)
        end
    end
})

if minetest.get_modpath("weather") then
    dofile(MODPATH ..  DIR_DELIM .. "compatibility" .. DIR_DELIM .. "weather.lua")
end

if minetest.get_modpath("enable_shadows") then
    dofile(MODPATH .. DIR_DELIM .. "compatibility" .. DIR_DELIM .. "enable_shadows.lua")

-- set base shadow
elseif SET_BASE_SHADOW then
    minetest.register_on_joinplayer(function(player)
        lighting_monoids.shadows:add_change(player, BASE_SHADOW_INTENSITY, "lighting_monoids:base_value")
    end)
end
