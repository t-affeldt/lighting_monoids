-- Hook into MTG weather mod for compatibility (requires PR #3020)
if weather ~= nil and weather.on_update ~= nil then
    weather.on_update = function(player, overrides)
        if overrides == nil then
            return
        end
        if overrides.shadows then
            lighting_monoid:add_change(player, { shadows = overrides.shadows }, "weather:cloud_shadows")
        end
        overrides.lighting = nil
        return overrides
    end
end