local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local Rand = require("api.Rand")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local RandomEventPrompt = require("api.gui.RandomEventPrompt")
local Weather = require("mod.elona.api.Weather")
local Servant = require("mod.elona.api.Servant")
local StayingCharas = require("api.StayingCharas")
local Area = require("api.Area")
local Nefia = require("mod.elona.api.Nefia")
local Rank = require("mod.elona.api.Rank")

local DeferredEvents = {}

function DeferredEvents.ragnarok(chara)
   -- >>>>>>>> shade2/action.hsp:1413 	if enc=encRagnarok{ ..
   chara = chara or Chara.player()

   local tx, ty, tdx, tdy = Gui.visible_tile_bounds()

   local map = chara:current_map()
   if Map.is_world_map(map) then
      return
   end

   Weather.change_to("elona.etherwind")
   Gui.mes("event.ragnarok")
   Gui.update_screen()
   Input.query_more()

   local cb = Anim.ragnarok()
   Gui.start_draw_callback(cb)

   for i = 1, 200 do
      for _ = 1, 2 do
         local x = Rand.rnd(map:width())
         local y = Rand.rnd(map:height())
         map:set_tile(x, y, "elona.destroyed")
      end

      local x = Rand.between(tx, tdx)
      local y = Rand.between(ty, tdy)
      if x < 0 or y < 0 or x >= map:width() or y >= map:height() or Rand.one_in(5) then
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
      end

      Mef.create("elona.fire", x, y, { duration = Rand.rnd(15) + 20, power = 50, origin = chara }, map)
      Effect.damage_map_fire(x, y, chara, map)

      if (i - 1) % 4 == 0 then
         local level = 100
         local quality = Calc.calc_object_quality(Enum.Quality.Good)
         local tag_filters
         if Rand.one_in(4) then
            tag_filters = { "giant" }
         else
            tag_filters = { "dragon" }
         end

         local spawned = Charagen.create(x, y, { level = level, quality = quality, tag_filters = tag_filters })
         if spawned then
            spawned.is_summoned = true
         end
      end

      if (i - 1) % 7 == 0 then
         if Rand.one_in(7) then
            Gui.play_sound("base.crush1", x, y)
         else
            Gui.play_sound("base.fire1", x, y)
         end
         Gui.wait(25)
      end
   end
   -- <<<<<<<< shade2/action.hsp:1416 		} ..
end

function DeferredEvents.sleep_ambush()
   -- >>>>>>>> shade2/main.hsp:2047 	case evSleepAmbush ...
   local player = Chara.player()
   local map = player:current_map()
   if not map:has_type("world_map") then
      Gui.mes("event.beggars")
      for _ = 1, 3 do
         Chara.create("elona.robber", player.x, player.y, { level = player.level }, map)
      end
   end
   -- <<<<<<<< shade2/main.hsp:2054 	swbreak ..
end

function DeferredEvents.first_ally()
   -- >>>>>>>> shade2/main.hsp:1689 	case evFirstAlly ..
   local prompt = RandomEventPrompt:new(
      "random_event._.elona.reunion_with_pet.title",
      "random_event._.elona.reunion_with_pet.text",
      "base.bg_re13",
      {
        "random_event._.elona.reunion_with_pet.choices._1",
        "random_event._.elona.reunion_with_pet.choices._2",
        "random_event._.elona.reunion_with_pet.choices._3",
        "random_event._.elona.reunion_with_pet.choices._4"
      })

   local index = prompt:query()

   local ALLIES = {
      [1] = "elona.dog",
      [2] = "elona.cat",
      [3] = "elona.brown_bear",
      [4] = "elona.little_girl",
   }
   -- <<<<<<<< shade2/main.hsp:1709 	swbreak ..
   local id = ALLIES[index]

   local player = Chara.player()
   local ally = Chara.create(id, player.x, player.y, { level = player:calc("level") * 2 / 3 + 1 }, player:current_map())
   player:recruit_as_ally(ally)
end

function DeferredEvents.welcome_home(map)
   -- >>>>>>>> shade2/main.hsp:1910 	case evWelcome ...
   local can_welcome = function(chara)
      return Chara.is_alive(chara)
         and not chara:find_role("elona.special")
         and not chara:find_role("elona.adventurer")
         and (Servant.is_servant(chara)
                 or chara:relation_towards(Chara.player()) == Enum.Relation.Neutral
                 or StayingCharas.is_staying_in_map_global(chara, map))
   end

   local extra_talks = 0

   local welcome = function(chara)
      chara:set_emotion_icon("elona.happy", 20)
      -- TODO custom talk
      local has_talk = false
      if not has_talk then
         extra_talks = extra_talks + 1
      end
   end

   Chara.iter_all(map):filter(can_welcome):each(welcome)

   for _ = 1, extra_talks do
      Gui.mes_c("event.okaeri", "SkyBlue")
   end

   -- TODO maid guests
   -- <<<<<<<< shade2/main.hsp:1932 	swbreak ..
end

function DeferredEvents.nefia_boss(map, boss_uid)
   local area = Area.for_map(map)
   if area == nil then
      return
   end

   local boss
   if boss_uid and boss_uid >= 0 then
      boss = map:get_object_of_type("base.chara", map)
   end

   if boss == nil then
      boss = Nefia.spawn_boss(map)
      Nefia.set_boss_uid(area, boss.uid)
   end

   -- >>>>>>>> shade2/main.hsp:1747 	txt lang("どうやら最深層まで辿り着いたらしい…","It seems you have  ...
   Gui.mes("event.reached_deepest_level")
   Gui.mes_c("event.guarded_by_lord", "Red", map.name, boss)
   -- <<<<<<<< shade2/main.hsp:1748 	txtEf coRed : txtMore:txt lang("気をつけろ！この階は"+mapNa ..
end

function DeferredEvents.nefia_boss_defeated(map)
   local area = Area.for_map(map)
   if area == nil then
      return
   end

   Gui.play_sound("base.complete1")

   local player = Chara.player()
   local uid = Nefia.get_boss_uid(area)
   local boss
   if math.type(uid) == "integer" and uid >= 0 then
      boss = map:get_object_of_type("base.chara", uid)
   end

   Nefia.create_boss_rewards(player, boss)

   -- >>>>>>>> shade2/main.hsp:1762 	txtEf coGreen:txtQuestComplete:txtMore:txtQuestIt ...
   Gui.mes_c("quest.completed", "Green")
   Gui.mes("common.something_is_put_on_the_ground")
   Rank.modify("elona.crawler", 300, 8)

   local fame_gained = Nefia.calc_boss_fame_gained(player)
   Gui.mes_c("quest.gain_fame", "Green", fame_gained)
   player.fame = player.fame + fame_gained
   -- <<<<<<<< shade2/main.hsp:1765 	cFame(pc)+=gQuestFame ..

   -- >>>>>>>> shade2/main.hsp:1771 	}else{ ...
   Nefia.set_boss_uid(area, -1) -- No more bosses in this map.
   -- <<<<<<<< shade2/main.hsp:1773 	} ..
end

return DeferredEvents
