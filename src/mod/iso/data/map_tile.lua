local iso = {}

iso["elona.grass"] = { 0, 0 }
iso["elona.grass_violets"] = { 2, 0 }
iso["elona.grass_rocks"] = { 3, 0 }
iso["elona.grass_tall_1"] = { 4, 0 }
iso["elona.grass_tall_2"] = { 5, 0 }
iso["elona.grass_patch_1"] = { 6, 0 }
iso["elona.grass_patch_2"] = { 7, 0 }
iso["elona.grass_patch_2"] = { 7, 0 }
iso["elona.grass_bush_1"] = { 8, 0 }
iso["elona.grass_bush_2"] = { 9, 0 }
iso["elona.grass_bush_3"] = { 10, 0 }
iso["elona.grass_patch_3"] = { 11, 0 }
iso["elona.grass_rocks_2"] = { 12, 0 }
iso["elona.cracked_dirt_1"] = { 12, 0 }
iso["elona.cracked_dirt_2"] = { 13, 0 }
iso["elona.desert_rocks_1"] = { 0, 1 }
iso["elona.desert_rocks_2"] = { 1, 1 }
iso["elona.desert_rocks_3"] = { 2, 1 }
iso["elona.desert_flowers_1"] = { 3, 1 }
iso["elona.desert_flowers_2"] = { 4, 1 }
iso["elona.grass_rock"] = { 5, 1 }
iso["elona.field_1"] = { 6, 1 }
iso["elona.field_2"] = { 7, 1 }
iso["elona.dark_dirt_1"] = { 0, 2 }
iso["elona.dark_dirt_2"] = { 1, 2 }
iso["elona.dark_dirt_3"] = { 2, 2 }
iso["elona.dark_dirt_4"] = { 3, 2 }
iso["elona.destroyed"] = { 4, 2 }
iso["elona.dirt_patch"] = { 5, 2 }
iso["elona.dirt_grass"] = { 6, 2 }
iso["elona.dirt_rocks"] = { 7, 2 }
iso["elona.dirt"] = { 8, 2 }
iso["elona.snow"] = { 0, 3 }
iso["elona.snow_mound"] = { 1, 3 }
iso["elona.snow_plants"] = { 2, 3 }
iso["elona.snow_rock"] = { 3, 3 }
iso["elona.snow_stump"] = { 4, 3 }
iso["elona.snow_flowers_1"] = { 5, 3 }
iso["elona.snow_flowers_2"] = { 6, 3 }
iso["elona.snow_flowers_3"] = { 7, 3 }
iso["elona.snow_field_1"] = { 8, 3 }
iso["elona.snow_field_2"] = { 9, 3 }
iso["elona.snow_ice"] = { 10, 3 }
iso["elona.snow_clumps_1"] = { 0, 4 }
iso["elona.snow_clumps_2"] = { 1, 4 }
iso["elona.snow_stalks"] = { 2, 4 }
iso["elona.snow_grass"] = { 3, 4 }
iso["elona.snow_blue_tile"] = { 4, 4 }
iso["elona.snow_cobble_1"] = { 5, 4 }
iso["elona.snow_cobble_2"] = { 5, 4 }
iso["elona.snow_cobble_3"] = { 6, 4 }
iso["elona.snow_cobble_4"] = { 7, 4 }
iso["elona.snow_stairs"] = { 8, 4 }
iso["elona.tower_of_fire_tile_1"] = { 0, 5 }
iso["elona.tower_of_fire_tile_2"] = { 1, 5 }
iso["elona.tower_of_fire_tile_3"] = { 2, 5 }
iso["elona.ballroom_room_floor"] = { 3, 5 }
iso["elona.hardwood_floor_1"] = { 4, 5 }
iso["elona.hardwood_floor_2"] = { 5, 5 }
iso["elona.hardwood_floor_3"] = { 6, 5 }
iso["elona.hardwood_floor_4"] = { 0, 6 }
iso["elona.hardwood_floor_5"] = { 1, 6 }
iso["elona.hardwood_floor_6"] = { 2, 6 }
iso["elona.metal_plating_rusted"] = { 3, 6 }
iso["elona.thatching"] = { 4, 6 }
iso["elona.cobble"] = { 1, 7 }
iso["elona.snow_flowers_4"] = { 2, 7 }
iso["elona.snow_flowers_5"] = { 3, 7 }
iso["elona.snow_flowers_6"] = { 4, 7 }
iso["elona.snow_bushes_1"] = { 0, 8 }
iso["elona.snow_bushes_2"] = { 1, 8 }
iso["elona.snow_bushes_3"] = { 2, 8 }
iso["elona.snow_bush"] = { 3, 8 }
iso["elona.snow_boulder"] = { 4, 8 }
iso["elona.snow_pillar"] = { 0, 9 }
iso["elona.cobble_3"] = { 1, 9 }
iso["elona.concrete_2"] = { 2, 9 }
iso["elona.flooring_1"] = { 3, 9 }
iso["elona.flooring_2"] = { 4, 9 }
iso["elona.cobble_4"] = { 5, 9 }
iso["elona.cobble_6"] = { 6, 9 }
-- iso["elona.cobble_7"] = { 7, 9 }
-- iso["elona.cobble_8"] = { 0, 10 }
-- iso["elona.cobble_9"] = { 1, 10 }
iso["elona.cobble_9"] = { 2, 10 }
iso["elona.cobble_10"] = { 3, 10 }
iso["elona.cobble_11"] = { 4, 10 }
iso["elona.cobble_dark_1"] = { 5, 10 }

iso["elona.wall_dirt_dark_fog"] = iso["elona.dark_dirt_1"]
iso["elona.wall_dirt_fog"] = iso["elona.dirt"]
iso["elona.wall_stone_2_fog"] = iso["elona.dirt"]

local outside = {}

outside["elona.wall_dirt_top"] = { 4, 3 }
outside["elona.wall_dirt_dark_top"] = { 4, 3 }
outside["elona.wall_dirt_bottom"] = { 4, 3 }
outside["elona.wall_dirt_dark_bottom"] = { 4, 3 }

local function each(entry)
   if type(entry.image) == "table" then
      if iso[entry._id] then
         entry.image.source = "mod/iso/graphic/tiles.png"
         entry.image.x = iso[entry._id][1] * 64
         entry.image.y = iso[entry._id][2] * 64
      elseif outside[entry._id] then
         entry.image.source = "mod/iso/graphic/outside.png"
         entry.image.x = outside[entry._id][1] * 64
         entry.image.y = outside[entry._id][2] * 64
      elseif entry.wall_kind then
         entry.image.source = "mod/iso/graphic/building.png"
         entry.image.x = 0 * 64
         entry.image.y = 0 * 64
      else
         entry.image.source = "mod/iso/graphic/tiles.png"
         entry.image.x = 0 * 64
         entry.image.y = 0 * 64
      end

      entry.image.width = 64
      entry.image.height = 64
   end
end

data["base.map_tile"]:iter():each(each)
