local CodeGenerator = require("api.CodeGenerator")
local Chara = require("api.Chara")
local global = require("mod.elona.internal.global")
local Quest = require("mod.elona_sys.api.Quest")
local Log = require("api.Log")
local Input = require("api.Input")
local Gui = require("api.Gui")
local Encounter = require("mod.elona.api.Encounter")
local Weather = require("mod.elona.api.Weather")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local Effect = require("mod.elona.api.Effect")
local Skill = require("mod.elona_sys.api.Skill")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Map = require("api.Map")
local Text = require("mod.elona.api.Text")

data:add_type {
   name = "encounter",
   fields = {
      {
         name = "encounter_level",
         default = CodeGenerator.gen_literal [[
function(outer_map, outer_x, outer_y)
   return 10
end]],
         template = true,
         doc = [[
Controls the level of the encounter.
]]
      },
      {
         name = "before_encounter_start",
         default = CodeGenerator.gen_literal [[
function(level, outer_map, outer_x, outer_y)
    Gui.mes("Ambush!")
    Input.query_more()
end]],
         template = true,
         doc = [[
This is run before the player is transported to the encounter map.
]]
      },
      {
         name = "on_map_entered",
         default = CodeGenerator.gen_literal [[
function(map, level, outer_map, outer_x, outer_y)
    for i = 1, 10 do
        Chara.create("elona.putit", nil, nil, nil, map)
    end
end]],
         template = true,
         doc = [[
Generates the encounter. This function receives map that the encounter will take
place in, like the open fields. Create any enemies you want here, and maybe add
a deferred event to trigger a scripted dialog.
]]
      }
   }
}

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

data:add {
   _type = "elona.encounter",
   _id = "merchant",

   encounter_level = function()
      -- >>>>>>>> shade2/action.hsp:685 			encounterLv=10+rnd(100) ...
      return 10 + Rand.rnd(100)
      -- <<<<<<<< shade2/action.hsp:685 			encounterLv=10+rnd(100) ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1623 			flt  ...
      local merchant = Chara.create("elona.shopkeeper", 10, 11, nil, map)
      merchant:add_role("elona.shopkeeper", { inventory_id = "elona.wandering_merchant" })
      merchant.shop_rank = level
      merchant.name = I18N.get("chara.job.wandering_vendor", merchant.name)
      Effect.generate_money(merchant)
      for _ = 1, level / 2 + 1 do
         Skill.gain_level(merchant)
      end

      for _ = 1, 6 + Rand.rnd(6) do
         local filter = {
            level = level + Rand.rnd(6),
            tag_filters = { "shopguard" }
         }
         local guard = Charagen.create(14, 11, filter, map)
         if guard then
            guard:add_role("elona.shop_guard") -- Prevents incognito from having an effect
            guard.name = ("%s Lv%d"):format(guard.name, guard.level)
         end
      end

      local event = function()
         -- >>>>>>>> shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ...
         local map_ = player:current_map()
         if map_.uid == map.uid then
            local merchant_ = Chara.find("elona.shopkeeper", "all", map_)
            Dialog.start(merchant_)
         end
         -- <<<<<<<< shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ..
      end

      DeferredEvent.add(event)
      -- <<<<<<<< shade2/map.hsp:1636 	 ..
   end
}

data:add {
   _type = "elona.encounter",
   _id = "assassin",

   encounter_level = function()
      -- >>>>>>>> shade2/map.hsp:1615 			flt qLevel(rq),fixGood ...
      local quest
      if global.encounter_quest_uid then
         quest = Quest.get(global.encounter_quest_uid)
      end
      if quest == nil then
         Log.error("Missing encounter quest for assassin encounter %s", global.encounter_quest_uid)
         return 1
      end
      return quest.difficulty
      -- <<<<<<<< shade2/map.hsp:1615 			flt qLevel(rq),fixGood ..
   end,

   before_encounter_start = function()
      -- >>>>>>>> shade2/action.hsp:678 			txt lang("暗殺者につかまった。あなたはクライアントを守らなければならない。","Yo ...
      Gui.mes("misc.caught_by_assassins")
      Input.query_more()
      -- <<<<<<<< shade2/action.hsp:679 			msg_halt ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1608 		if encounter=encounterAssassin{ ...
      local quest
      if global.encounter_quest_uid then
         quest = Quest.get(global.encounter_quest_uid)
      end
      if quest == nil then
         Log.error("Missing encounter quest for assassin encounter %s", global.encounter_quest_uid)
      else
         quest.state = "accepted"
         Quest.set_immediate_quest(quest)
      end

      map.max_crowd_density = 0
      table.insert(map.types, "quest")

      for _ = 1, Rand.rnd(3) + 5 do
         local filter = {
            level = level,
            quality = Enum.Quality.Good
         }
         local assassin = Charagen.create(player.x, player.y, filter, map)
         if assassin then
            assassin:set_target(player, 30)
            assassin.relation = Enum.Relation.Enemy
         end
      end
      -- <<<<<<<< shade2/map.hsp:1620 			} ...   end
   end
}

data:add {
   _type = "elona.encounter",
   _id = "rogue",

   encounter_level = function()
      -- >>>>>>>> shade2/action.hsp:673 			encounterLv=cFame(pc)/1000 ...
      return Chara.player():calc("fame") / 1000
      -- <<<<<<<< shade2/action.hsp:673 			encounterLv=cFame(pc)/1000 ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1594 			mModerateCrowd =0  ...
      map.max_crowd_density = 0
      Chara.create("elona.rogue_boss", player.x, player.y, { level = level }, map)

      for _ = 1, 6 + Rand.rnd(6) do
         local filter = {
            level = level + Rand.rnd(10),
            tag_filters = { "rogue_guard" }
         }
         local rogue = Charagen.create(14, 11, filter, map)
         if rogue then
            rogue.name = ("%s Lv %d"):format(rogue.name, rogue.level)
         end

         global.rogue_party_name = Text.random_title("party")
      end

      local event = function()
         -- >>>>>>>> shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ...
         local map_ = player:current_map()
         if map_.uid == map.uid then
            local rogue_boss = Chara.find("elona.rogue_boss", "all", map_)
            Dialog.start(rogue_boss)
         end
         -- <<<<<<<< shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ..
      end

      DeferredEvent.add(event)
      -- <<<<<<<< shade2/map.hsp:1604 			evAdd evRogue  ..
   end
}
