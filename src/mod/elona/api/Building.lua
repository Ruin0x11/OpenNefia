local Chara = require("api.Chara")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Feat = require("api.Feat")
local Input = require("api.Input")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")

local Building = {}

function Building.iter(map)
   return Area.iter(map):filter(function(_, a) return a.metadata.is_player_owned end)
end

function Building.query_build(deed)
   local player = Chara.player()
   local x = player.x
   local y = player.y
   local map = player:current_map()
   if not Map.is_world_map(map) then
      Gui.mes("building.can_only_use_in_world_map")
      return "player_turn_query"
   end

   if Feat.at(x, y, map):length() > 0 then
      Gui.mes("building.cannot_build_it_here")
      return "player_turn_query"
   end

   if Building.iter(map):length() > 300 then
      Gui.mes("building.cannot_build_anymore")
      return "player_turn_query"
   end

   Gui.mes("building.really_build_it_here")
   if not Input.yes_no() then
      return "player_turn_query"
   end

   deed:emit("elona.on_deed_use", {x = x, y = y, map = map})
   deed.amount = deed.amount - 1
   return "turn_end"
end

function Building.build_area(area_archetype_id, name, x, y, map)
   local area = InstancedArea:new(area_archetype_id)
   area.metadata.is_player_owned = true
   Area.register(area, { parent = Area.for_map(map) })
   Area.create_entrance(area, 1, x, y, {}, map)
   Gui.play_sound("base.build1", x, y)
   Gui.mes_c("building.built_new", "Yellow", name)

   local metadata = {
      area_archetype_id = area._archetype,
      area_uid = area.uid,
      name = area.name,
      tax_cost = area.metadata.tax_cost or 0
   }

   table.insert(save.elona.player_owned_buildings, metadata)
end

return Building
