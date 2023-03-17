lighting_monoids = {}

local SET_BASE_SHADOW = minetest.settings:get_bool("lighting_monoids.set_base_shadow", true)
local BASE_SHADOW_INTENSITY = tonumber(minetest.settings:get("lighting_monoids.base_shadow_intensity") or 0.33)

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
        player:set_lighting(lighting)
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
        player:set_lighting(lighting)
    end
})

-- Hook into MTG weather mod for compatibility (requires PR #3020)
if minetest.get_modpath("weather") and weather and weather.on_update then
    weather.on_update = function(player, overrides)
        if overrides == nil then
            return
        end
        if overrides.shadows and overrides.shadows.intensity then
            local intensity = overrides.shadows.intensity
            lighting_monoids.shadows:add_change(player, intensity, "weather:cloud_shadows")
        end
        overrides.lighting = nil
        return overrides
    end

-- set base shadow intensity according to mod config
-- only basic integration, doesn't update when command is used
elseif minetest.get_modpath("enable_shadows") then
    local intensity = tonumber(minetest.settings:get("enable_shadows_default_intensity") or 0.33)
    minetest.register_on_joinplayer(function(player)
        lighting_monoids.shadows:add_change(player, intensity, "enable_shadows:base_value")
    end)

-- set base shadow
elseif SET_BASE_SHADOW then
    minetest.register_on_joinplayer(function(player)
        lighting_monoids.shadows:add_change(player, BASE_SHADOW_INTENSITY, "lighting_monoids:base_value")
    end)
end
