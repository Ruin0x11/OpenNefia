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

return DeferredEvents
