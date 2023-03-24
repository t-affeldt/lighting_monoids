
std = "luajit+minetest+monoids"
ignore = { "212" }

files[".luacheckrc"].std = "min+luacheck"

stds.luacheck = {}
stds.luacheck.globals = {
    "files",
    "ignore",
    "std",
    "stds"
}

stds.minetest = {}
stds.minetest.read_globals = {
    "DIR_DELIM",
    "minetest",
    "dump",
    "vector",
    "VoxelManip",
    "VoxelArea",
    "PseudoRandom",
    "PcgRandom",
    "ItemStack",
    "Settings",
    "unpack",
    "assert",
    "S",
    table = { fields = { "copy", "indexof" } },
    math = { fields = { "sign" } }
}

stds.monoids = {}
stds.monoids.globals = {
    "lighting_monoid",
    "weather"
}
stds.monoids.read_globals = {
    "player_monoids"
}
