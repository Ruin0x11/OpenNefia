--- @module Save

local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Log = require("api.Log")
local SaveFs = require("api.SaveFs")
local Env = require("api.Env")
local IEventEmitter = require("api.IEventEmitter")

local fs = require("util.fs")
local config = require("internal.config")
local field = require("game.field")
local save_store = require("internal.save_store")
local field_logic_state = require("internal.global.field_logic_state")
local object = require("internal.object")

local Save = {}

--- Saves the game.
function Save.save_game(save_id)
   save_id = save_id or config.base._save_id
   save_id = fs.sanitize(save_id, "_")
   assert(type(save_id) == "string")
   config.base._save_id = save_id

   local map = Map.current()

   do
      local global = save_store.for_mod("base")
      global.map = map.uid
      global.player = field.player.uid
      global.play_time = Env.update_play_time(global.play_time)

      global.api_version = Env.api_version()
      global.commit = Env.commit_hash()

      Log.info("Saving game '%s'.", save_id)
      Log.trace("save map: %d  player %d", global.map, global.player)
   end

   assert(Map.save(map))

   assert(save_store.save())

   local player = Chara.player()
   local player_header = ("%s Lv:%d %s"):format(player.name, player.level, map.name)
   SaveFs.write("header", { header = player_header }, "temp")

   -- This will commit all the changes to the save.
   -- Everything that writes files using SaveFs should finish above.
   SaveFs.save_game(save_id)

   Gui.play_sound("base.write1")
   Gui.mes("action.quicksave")

   if field.is_active and config.base.debug_load_after_save then
      Save.load_game(save_id)
   end
end

--- Loads the current save.
function Save.load_game(save_id)
   save_id = save_id or config.base._save_id
   save_id = fs.sanitize(save_id, "_")
   assert(type(save_id) == "string")
   config.base._save_id = save_id

   Log.info("Loading game '%s'.", save_id)

   local success, map, err

   success, err = SaveFs.load_game(save_id)
   if not success then
      error(err)
   end

   object.clear_last_deserialized_objects()

   assert(save_store.load())

   -- Instantiate every object that was loaded by the deserializer, to ensure
   -- things like event handlers that get loaded from the prototype are
   -- restored. It's hard to do this in the general case, because the objects
   -- could be lying anywhere in the serialized data, like some container nested
   -- inside a mod's `save` table that would not otherwise be touched by the
   -- engine.
   local deserialized = object.get_last_deserialized_objects()
   for _, obj in ipairs(deserialized) do
      obj:instantiate()
   end

   local base = save_store.for_mod("base")
   local map_uid = base.map
   local player_uid = base.player
   Env.update_play_time()

   Log.trace("load map: %d  player %d", map_uid, player_uid)

    success, map = Map.load(map_uid)
   if not success then
      error("Load error: " .. map)
   end

   Map.set_map(map, "continue")
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

function Save.queue_autosave()
   -- TODO show house
   if config.base.autosave then
      -- More than one place could call `Save.queue_autosave()` before the
      -- player's turn is reached, but we want to make sure we only save one
      -- time. The save will actually get executed right before control is
      -- restored to the player in field_logic.player_turn_query().
      field_logic_state.about_to_autosave = true
   end
end

return Save
