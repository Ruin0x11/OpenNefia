--- @module Save

local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Log = require("api.Log")
local SaveFs = require("api.SaveFs")

local config = require("internal.config")
local field = require("game.field")
local save_store = require("internal.save_store")

local Save = {}

--- Saves the game.
function Save.save_game()
   local save_id = config["base._save_id"]
   assert(save_id)

   local map = Map.current()

   do
      local global = save_store.for_mod("base")
      global.map = map.uid
      global.player = field.player.uid

      Log.info("Saving game.")
      Log.trace("save map: %d  player %d", global.map, global.player)
   end

   assert(Map.save(map))

   assert(save_store.save())

   local player = Chara.player()
   local player_header = ("%s Lv:%d %s"):format(player.name, player.level, map.name)
   SaveFs.write("header", { header = player_header })

   -- This will commit all the changes to the save.
   -- Everything that writes files using SaveFs should finish above.
   SaveFs.save_game(save_id)

   Gui.play_sound("base.write1")
   Gui.mes("Game saved.")
end

--- Loads the current save.
function Save.load_game(save_id)
   save_id = save_id or config["base._save_id"]
   assert(save_id)
   config["base._save_id"] = save_id

   local success, map

   SaveFs.load_game(save_id)

   assert(save_store.load())

   local base = save_store.for_mod("base")
   local map_uid = base.map
   local player_uid = base.player

   Log.info("Loading game.")
   Log.trace("load map: %d  player %d", map_uid, player_uid)

   success, map = Map.load(map_uid)
   if not success then
      error("Load error: " .. map)
   end

   Map.set_map(map)
   Chara.set_player(map:get_object(player_uid))

   collectgarbage()

   -- BUG: events registered with Event.register since the game has
   -- started will be left over when a save is reloaded.
   --
   -- TODO: should it be an error to register events outside
   -- on_game_initialize? then on_game_initialize becomes
   -- special-cased to avoid clearing it when a save is loaded. it
   -- might be better to restrict calling of Event.register to the mod
   -- startup stage.
   --
   -- an interface for creating global events that are cleaned up when
   -- a save is loaded could be used. or maybe that could become the
   -- main interface of Event anyway. a flag could be set if a global
   -- event is temporary, and it could be forced to true if mods
   -- aren't loading.
   --
   -- local global_events = require("internal.global.global_events")
   -- global_events:clear()

   Gui.mes_clear()
   Gui.mes("Game loaded.")

   Event.trigger("base.on_game_initialize")
end

return Save
