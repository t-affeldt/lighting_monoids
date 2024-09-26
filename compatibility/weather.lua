local CYCLE = 8
local BASE_SHADOW = 0.33

-- weather API not supported, no patch possible
if weather == nil or weather.get == nil then
    minetest.log("warning", "[Lighting_Monoid] 'weather' mod does not support patching via API. If you are playing Minetest Game, update to the latest version")
    return
end

-- prevent mod from triggering lighting updates itself
local old_get = weather.get
weather.get = function(player)
    local params = old_get(player)
    params.lighting = nil
    return params
end

local function do_update()
    for _, player in ipairs(minetest.get_connected_players()) do
        local params = old_get(player)
        local lighting = params.lighting
        if lighting ~= nil and lighting.shadows ~= nil and lighting.shadows.intensity ~= nil then
            -- normalize in relation to default intensity
            lighting.shadows.intensity = lighting.shadows.intensity / BASE_SHADOW
        end
        lighting_monoid:add_change(player, lighting, "weather:lighting")
    end
    minetest.after(CYCLE, do_update)
end
minetest.after(0, do_update)