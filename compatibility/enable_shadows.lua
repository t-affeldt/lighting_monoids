--[[
    This code is mostly taken from the original enable_shadows mod
    and tweaked to work with the new monoids.
    enable_shadows is licensed under MIT, respective Copyright (c) 2022 ROllerozxa
]]

local S = minetest.get_translator("enable_shadows")
local storage = minetest.get_mod_storage()

local default_intensity = tonumber(minetest.settings:get("enable_shadows_default_intensity") or 0.33)
local intensity = tonumber(storage:get("intensity") or default_intensity)

minetest.register_on_joinplayer(function(player)
    lighting_monoids.shadows:add_change(player, intensity, "enable_shadows:base_value")
end)

minetest.override_chatcommand("shadow_intensity", {
	func = function(name, param)
		local new_intensity
		if param ~= "" then
			new_intensity = tonumber(param) or nil
		else
			new_intensity = tonumber(default_intensity) or nil
		end

		if new_intensity < 0 or new_intensity > 1 or new_intensity == nil then
			minetest.chat_send_player(name, minetest.colorize("#ff0000", S("Invalid intensity.")))
			return true
		end

		if new_intensity ~= default_intensity then
			minetest.chat_send_player(name, S("Set intensity to @1.", new_intensity))
			storage:set_float("intensity", new_intensity)
		else
			minetest.chat_send_player(name, S("Set intensity to default value (@1).", default_intensity))
			storage:set_string("intensity", "")
		end

		intensity = new_intensity
		for _,player in pairs(minetest.get_connected_players()) do
            lighting_monoids.shadows:add_change(player, new_intensity, "enable_shadows:base_value")
		end
	end
})