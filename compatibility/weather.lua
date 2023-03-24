-- Hook into MTG weather mod for compatibility (requires PR #3020)
if weather ~= nil and weather.on_update ~= nil then
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
end