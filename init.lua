local SET_BASE_SHADOW = minetest.settings:get_bool("lighting_monoids.set_base_shadow", true)
local BASE_SHADOW_INTENSITY = tonumber(minetest.settings:get("lighting_monoids.base_shadow_intensity") or 0.33)

local MODPATH = minetest.get_modpath(minetest.get_current_modname())

local monoid_definition = {
    shadows = {
        intensity = "multiply_minmax",
    },
    saturation = "multiply",
    exposure = {
        luminance_min = "add",
        luminance_max = "add",
        exposure_correction = "add",
        speed_dark_bright = "multiply",
        speed_bright_dark = "multiply",
        center_weight_power = "multiply"
    }
}

-- default values that don't reflect neutral operations
local lighting_defaults = {
    exposure = {
        luminance_min = -3,
        luminance_max = -3,
        speed_dark_bright = 1000,
        speed_bright_dark = 1000,
    }
}

local methods = {}

function methods.add(a, b)
    return a + b
end

function methods.multiply(a, b)
    return a * b
end

function methods.multiply_minmax(a, b)
    return math.max(math.min(a * b, 1), 0)
end

-- combine tables using specified methods
local function combine(definition, tabA, tabB)
    -- at least one table has undefined value
    if tabA ~= nil and tabB == nil then return tabA end
    if tabB ~= nil and tabA == nil then return tabB end
    if tabA == nil and tabB == nil then return nil end
    -- both tables define value
    if type(definition) == "table" then
        -- not reached leaf node yet
        local combined = {}
        for property, subdefinition in pairs(definition) do
            combined[property] = combine(subdefinition, tabA[property], tabB[property])
        end
        return combined
    else
        -- combine values
        return methods[definition](tabA, tabB)
    end
end

lighting_monoid = player_monoids.make_monoid({
    identity = {},
    combine = function(a, b)
        return combine(monoid_definition, a, b)
    end,
    fold = function(values)
        local total = {}
        for _, val in ipairs(values) do
            total = combine(monoid_definition, total, val)
        end
        return total
    end,
    apply = function(value, player)
        if player.set_lighting ~= nil then
            -- incorporate default offsets
            value = combine(monoid_definition, lighting_defaults, value)
            player:set_lighting(value)
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
        local lighting = { shadows = { intensity = BASE_SHADOW_INTENSITY } }
        lighting_monoid:add_change(player, lighting, "lighting_monoid:base_shadow")
    end)
end
