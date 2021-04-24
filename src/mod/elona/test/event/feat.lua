local Area = require("api.Area")
local TestUtil = require("api.test.TestUtil")
local Map = require("api.Map")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Assert = require("api.test.Assert")
local Feat = require("api.Feat")
local IFeat = require("api.feat.IFeat")

disable("Flaky due to items blocking stairs, so the player is not placed directly on them (#297)")
function test_map_entrance_sets_child_area_position()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local _, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local tower_of_fire_area = Area.create_unique("elona.tower_of_fire", north_tyris_area)

   Feat.iter(north_tyris_map):each(IFeat.remove_ownership)
   Area.create_entrance(tower_of_fire_area, 1, 43, 4, {}, north_tyris_map)

   local x, y, floor = Area.parent(tower_of_fire_area):child_area_position(tower_of_fire_area)
   Assert.eq(43, x)
   Assert.eq(4, y)
   Assert.eq(1, floor)

   local player = TestUtil.set_player(north_tyris_map, 43, 4)
   Map.set_map(north_tyris_map)

   ElonaCommand.descend(player)
   Assert.eq(tower_of_fire_area, Area.current())

   x, y, floor = Area.parent(tower_of_fire_area):child_area_position(tower_of_fire_area)
   Assert.eq(43, x)
   Assert.eq(4, y)
   Assert.eq(1, floor)

   ElonaCommand.ascend(player)
   Assert.eq(north_tyris_area, Area.current())
   Assert.eq(43, player.x)
   Assert.eq(4, player.y)
   Assert.eq(1, Map.floor_number(player:current_map()))

   north_tyris_map = player:current_map()
   local feat = Area.create_entrance(tower_of_fire_area, 1, 50, 20, {}, north_tyris_map)
   Assert.is_truthy(feat)
   Assert.eq(50, feat.x)
   Assert.eq(20, feat.y)
   Assert.eq(tower_of_fire_area.uid, feat.params.area_uid)
   Assert.eq(1, feat.params.area_floor)

   x, y, floor = Area.parent(tower_of_fire_area):child_area_position(tower_of_fire_area)
   Assert.eq(43, x)
   Assert.eq(4, y)
   Assert.eq(1, floor)

   Map.save(north_tyris_map)

   player:set_pos(50, 20)
   ElonaCommand.descend(player)
   Assert.eq(tower_of_fire_area, Area.current())

   x, y, floor = Area.parent(tower_of_fire_area):child_area_position(tower_of_fire_area)
   Assert.eq(50, x)
   Assert.eq(20, y)
   Assert.eq(1, floor)

   ElonaCommand.ascend(player)
   Assert.eq(north_tyris_area, Area.current())
   Assert.eq(50, player.x)
   Assert.eq(20, player.y)
   Assert.eq(1, Map.floor_number(player:current_map()))

   x, y, floor = Area.parent(tower_of_fire_area):child_area_position(tower_of_fire_area)
   Assert.eq(50, x)
   Assert.eq(20, y)
   Assert.eq(1, floor)
end

function test_material_spot_finalized_events()
   local spring = Feat.create("elona.material_spot", nil, nil, {params={material_spot_info="elona.spring"},ownerless=true})
   local bush = Feat.create("elona.material_spot", nil, nil, {params={material_spot_info="elona.bush"},ownerless=true})

   Assert.eq("elona.feat_material_fish", spring.image)
   Assert.eq("elona.feat_material_plant", bush.image)
end
