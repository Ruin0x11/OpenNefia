local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")

data:add_multi(
   "base.map_tile", {
      { _id = "builder_empty", image = "graphic/default/floor.png", is_solid = false },
      { _id = "builder_floor", image = "graphic/default/floor.png", is_solid = false },
      { _id = "builder_rock_wall", image = "graphic/default/floor.png", is_solid = true },
      { _id = "builder_stone_wall", image = "graphic/default/floor.png", is_solid = true },
      { _id = "builder_metal_wall", image = "graphic/default/floor.png", is_solid = true },
      { _id = "builder_crystal_wall", image = "graphic/default/floor.png", is_solid = true },
      { _id = "builder_deep_water", image = "graphic/default/floor.png", is_solid = true },
      { _id = "builder_shallow_water", image = "graphic/default/floor.png", is_solid = false },
})

data:add {
   _type = "elona_sys.map_tileset",
   _id = "default",

   tiles = {
      ["vaults.builder_empty"] = "elona.grass",
      ["vaults.builder_floor"] = MapTileset.pick({"elona.tile_1", "elona.tile_2", "elona.tile_3"}, 2),
      ["vaults.builder_rock_wall"] = "elona.wall_concrete_top",
      ["vaults.builder_stone_wall"] = "elona.wall_concrete_light_top",
      ["vaults.builder_metal_wall"] = "elona.wall_concrete_light_top",
      ["vaults.builder_crystal_wall"] = "elona.wall_stone_6_top",
      ["vaults.builder_deep_water"] = "elona.anime_water_sea",
      ["vaults.builder_shallow_water"] = "elona.anime_water_shallow",
   },

   fog = "elona.wall_stone_4_fog"
}
