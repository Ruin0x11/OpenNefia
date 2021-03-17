local Encounter = require("mod.elona.api.Encounter")
local Chara = require("api.Chara")
local Weather = require("mod.elona.api.Weather")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Input = require("api.Input")
local Rand = require("api.Rand")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")

data:add {
   _type = "elona.encounter",
   _id = "enemy",

   encounter_level = function(outer_map, outer_x, outer_y)
      -- >>>>>>>> shade2/action.hsp:690 			p=dist_town() ...
      local town_dist = Encounter.distance_from_nearest_town(outer_map)
      local level = town_dist * 3 / 2 - 10
      if Chara.player():calc("level") <= 5 then
         level = level / 2
      end

      local tile = outer_map:tile(outer_x, outer_y)
      if tile.is_road then
         level = level / 2
      elseif Weather.is("elona.etherwind") then
         level = level * 3 / 2 + 10
      end

      return math.max(level, 1)
      -- <<<<<<<< shade2/action.hsp:698 			if encounterLv<0:encounterLv=1 ..
   end,

   before_encounter_start = function(level, outer_map, outer_x, outer_y)
      -- >>>>>>>> shade2/action.hsp:690 			p=dist_town() ...
      local town_dist = Encounter.distance_from_nearest_town()
      -- <<<<<<<< shade2/action.hsp:690 			p=dist_town() ..

      -- >>>>>>>> shade2/action.hsp:699 			valn=lang(" (最も近い街までの距離:"+p+" 敵勢力:"," (Distance ...
      local rank_text
      if level < 5 then
         rank_text = "action.move.global.ambush.rank.putit"
      elseif level < 10 then
         rank_text = "action.move.global.ambush.rank.orc"
      elseif level < 20 then
         rank_text = "action.move.global.ambush.rank.grizzly_bear"
      elseif level < 30 then
         rank_text = "action.move.global.ambush.rank.drake"
      elseif level < 40 then
         rank_text = "action.move.global.ambush.rank.lich"
      else
         rank_text = "action.move.global.ambush.rank.dragon"
      end

      Gui.mes(I18N.get("action.move.global.ambush.message", town_dist, rank_text))
      Input.query_more()
      -- <<<<<<<< shade2/action.hsp:711 			txt lang("襲撃だ！","Ambush!")+valn:msg_halt ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1640 			p=rnd(9):if cLevel(pc)<=5:p=rnd(3) ...
      local enemy_count = Rand.rnd(9)
      if player:calc("level") <= 5 then
         enemy_count = Rand.rnd(3)
      end

      local tile = outer_map:tile(outer_x, outer_y)

      for i = 1, enemy_count + 2 do
         local filter = {
            level = Calc.calc_object_level(level, map),
            quality  = Calc.calc_object_quality(Enum.Quality.Normal)
         }

         if Weather.is("elona.etherwind") and not tile.is_road then
            if Rand.one_in(3) then
               filter.quality = Enum.Quality.God
            end
         end

         local x, y
         if i < 4 then
            x, y = player.x, player.y
         else
            x, y = nil, nil
         end

         local chara = Charagen.create(x, y, filter, map)
         if chara then
            chara:set_target(player, 30)
         end
      end
      -- <<<<<<<< shade2/map.hsp:1647 			loop ..
   end
}
