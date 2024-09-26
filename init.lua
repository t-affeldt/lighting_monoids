local BASE_SHADOW_INTENSITY = tonumber(minetest.settings:get("lighting_monoids.base_shadow_intensity") or 0.33)
local MODPATH = minetest.get_modpath(minetest.get_current_modname())

local monoid_definition = {
    shadows = {
        intensity = "multiply",
    },
    tint = {
        r = "max_255",
        g = "max_255",
        b = "max_255"
    },
    saturation = "multiply",
    exposure = {
        luminance_min = "add",
        luminance_max = "add",
        exposure_correction = "add",
        speed_dark_bright = "multiply",
        speed_bright_dark = "multiply",
        center_weight_power = "multiply"
    },
    volumetric_light = {
        strength = "max_1"
    }
}

-- neutral values
local lighting_defaults = {
    shadows = {
        intensity = 1,
    },
    tint = {
        r = 0,
        g = 0,
        b = 0
    },
    saturation = 1,
    exposure = {
        luminance_min = -3,
        luminance_max = -3,
        speed_dark_bright = 1000,
        speed_bright_dark = 1000,
    },
    volumetric_light = {
        strength = 0
    }
}

local methods = {}

function methods.add(a, b)
    return a + b
end

function methods.multiply(a, b)
    return a * b
end

function methods.max_1(a, b)
    return math.min(math.max(math.max(a, b), 0), 1)
end

function methods.max_255(a, b)
    return math.min(math.max(math.max(a, b), 0), 255)
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
        for _, val in pairs(values) do
            total = combine(monoid_definition, total, val)
        end
        return total
    end,
    apply = function(value, player)
        if player.set_lighting ~= nil then
            -- incorporate default offsets
            value = combine(monoid_definition, lighting_defaults, value)
            -- restrict shadow intensity to valid range
            if value ~= nil and value.shadows ~= nil and value.shadows.intensity ~= nil then
                value.shadows.intensity = math.max(math.min(value.shadows.intensity, 1), 0)
            end
            player:set_lighting(value)
        end
    end
})

if minetest.get_modpath("weather") and minetest.settings:get_bool("enable_weather") ~= false then
    dofile(MODPATH ..  DIR_DELIM .. "compatibility" .. DIR_DELIM .. "weather.lua")
end

if minetest.get_modpath("enable_shadows") then
    dofile(MODPATH .. DIR_DELIM .. "compatibility" .. DIR_DELIM .. "enable_shadows.lua")
else
    -- set base shadow
    minetest.register_on_joinplayer(function(player)
        local lighting = { shadows = { intensity = BASE_SHADOW_INTENSITY } }
        lighting_monoid:add_change(player, lighting, "lighting_monoid:base_shadow")
    end)
end