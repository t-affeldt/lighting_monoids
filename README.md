# Monoid for Player Lighting

## How to use
This mod provides a single object named `lighting_monoid`.

It is an extension for player_monoids and uses the same methods as the monoids there.
See the [player_monoids API documentation](https://github.com/minetest-mods/player_monoids/blob/master/API.md) for general information.

The lighting monoid expects the same lighting definition as `player:set_lighting()`. See [Minetest API docs](https://minetest.gitlab.io/minetest/class-reference/#player-only-no-op-for-other-objects).
However, this allows to create separated update layers that will be aggregated before being applied. This allows for changes from multiple mods.

Each property of the lighting definition will be aggregated with the respective property of each other update layer. You can leave properties undefined to not change them at all.

### Property aggregation

Properties will be aggregated in different ways. Here is the full list:

- `exposure`
  - `luminance_min` will be __added__
  - `luminance_max` will be __added__
  - `speed_dark_bright` will be __multiplied__
  - `speed_bright_dark` will be __multiplied__
  - `center_weight_power` will be __multiplied__
- `saturation` will be __multiplied__
- `shadows`
  - `intensity` will be __multiplied__
- `tint` values will be __maxed__
- `volumetric_light` will be __maxed__

### Example

This example creates an update layer that doubles the current shadow intensity:
```lua
local lighting = {
    shadows = { intensity = 2 }
}
lighting_monoid:add_change(player, lighting, "mymod:some_name")
```

In order to revert that change, you can remove the layer like so:
```lua
lighting_monoid:del_change(player, "mymod:some_name")
```

In order to modify a layer, simply call `add_change` again using the same name as before.
This will completely replace a layer, including properties that are left `nil` in the new definition.

### Additional Notes
This mod aims to resolve conflicts between mods that use the lighting API.
Mods that don't use this compatibility layer will still conflict as before.
A compatibility patch for the *enable_shadows* mod is included.

This mod will set a reasonable shadow intensity by default rather than leaving the value at zero or one.
If you wish to revert it to one, simply delete the layer:
```lua
lighting_monoid.del_change(player, "lighting_monoid:base_shadow")
```

The applied effects also depend on the game version.
- Shadows are only available in MT v5.6.0+.
- Saturation and exposure settings require v5.7.0+ to have an effect but can safely be set in v5.6.0.

## License
Code licensed under MIT, no media assets used.