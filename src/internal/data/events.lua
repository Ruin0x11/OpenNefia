local data = require("internal.data")
local paths = require("internal.paths")
local Event = require("api.Event")
local IEventEmitter = require("api.IEventEmitter")
local Map = require("api.Map")
local UiTheme = require("api.gui.UiTheme")

data:add_multi(
   "base.event",
   {
      { _id = "before_handle_self_event" },
      { _id = "before_ai_decide_action" },
      { _id = "after_chara_damaged", },
      {
         _id = "on_calc_damage",

         params = {
            { name = "test", type = "int", desc = "zxc" }
         },
         returns = {
            { type = "int?" }
         }
      },
      { _id = "after_damage_hp", },
      { _id = "on_damage_chara", },
      { _id = "on_kill_chara", },
      { _id = "before_chara_moved" },
      { _id = "on_chara_moved" },
      { _id = "on_chara_hostile_action", },
      { _id = "on_chara_killed", },
      { _id = "on_calc_kill_exp" },
      { _id = "on_chara_turn_end" },
      { _id = "before_chara_turn_start" },
      { _id = "on_chara_pass_turn" },
      { _id = "on_game_initialize" },
      { _id = "on_map_generated" },
      { _id = "on_map_loaded" },
      { _id = "on_map_loaded_from_entrance" },
      { _id = "on_map_rebuilt" },
      { _id = "on_proc_status_effect" },
      { _id = "on_object_instantiated" },
      { _id = "on_chara_instantiated" },
      { _id = "on_item_instantiated" },
      { _id = "on_feat_instantiated" },
      { _id = "on_chara_revived", },
      { _id = "on_talk", },
      { _id = "on_calc_chara_equipment_stats", },
      { _id = "on_game_startup", },
      { _id = "on_data_add" },
      { _id = "on_build_chara" },
      { _id = "on_build_item" },
      { _id = "on_build_feat" },
      { _id = "on_pre_build" },
      { _id = "on_normal_build" },
      { _id = "calc_status_indicators" },
      { _id = "on_refresh" },
      { _id = "on_second_passed" },
      { _id = "on_minute_passed" },
      { _id = "on_hour_passed" },
      { _id = "on_day_passed" },
      { _id = "on_month_passed" },
      { _id = "on_year_passed" },
      { _id = "on_init_save" },
      { _id = "on_build_map" },
      { _id = "on_activity_start" },
      { _id = "on_activity_pass_turns" },
      { _id = "on_activity_finish" },
      { _id = "on_activity_interrupt" },
      { _id = "on_activity_cleanup" },
      { _id = "on_generate" },
      { _id = "before_hotload_prototype" },
      { _id = "on_hotload_prototype" },
      { _id = "on_chara_generated" },
      { _id = "on_object_cloned" },
      { _id = "on_map_enter" },
      { _id = "on_map_leave" },
      { _id = "on_chara_place_failure" },
      { _id = "before_map_refresh" },
      { _id = "on_chara_refresh_in_map" },
      { _id = "on_refresh_weight" },
      { _id = "on_calc_speed" },
      { _id = "on_regenerate_map" },
      { _id = "on_regenerate" },
      { _id = "on_item_regenerate" },
      { _id = "on_chara_regenerate" },
      { _id = "on_hotload_object" },
      { _id = "on_chara_vanquished" },
      { _id = "on_turn_begin" },
      { _id = "on_new_game" },
      { _id = "generate_chara_name" },
      { _id = "generate_title" },
      { _id = "on_hotload_begin" },
      { _id = "on_hotload_end" },
      { _id = "on_set_player" },
      { _id = "on_startup" },
      { _id = "on_get_item" },
   }
)

-- The following adds support for cleaning up missing events
-- automatically if a chunk is hotloaded. It assumes only one chunk is
-- being loaded at a time, and does not handle hotloading dependencies
-- recursively.

local function on_hotload_begin(_, params)
   -- strip trailing "init" to make the path unique
   local path = paths.convert_to_require_path(params.path_or_class)
   Event.global():_begin_register(path)
end

local function on_hotload_end()
   Event.global():_end_register()
end

Event.register("base.on_hotload_begin", "Clean up events missing in chunk on hotload", on_hotload_begin, {priority = 1})
Event.register("base.on_hotload_end", "Clean up events missing in chunk on hotload", on_hotload_end, {priority = 9999999999})

Event.register("base.on_map_loaded", "init all event callbacks",
               function(map)
                  for _, v in map:iter() do
                     -- Event callbacks will not be serialized since
                     -- they are functions, so they have to be copied
                     -- from the prototype each time.
                     if class.is_an(IEventEmitter, v) then
                        IEventEmitter.init(v)
                     end
                     v:instantiate()
                  end
               end)

-- BUG O(n*m), instead make a list of items hotloaded and pass to
-- on_hotload_end
Event.register("base.on_hotload_prototype", "Notify objects in map of prototype hotload", function(_, params)
                  local map = Map.current()
                  if map then
                     for _, obj in map:iter() do
                        if class.is_an(IEventEmitter, obj)
                           and obj._type == params.new._type
                           and obj._id == params.new._id
                        then
                           obj:emit("base.on_hotload_object", params)
                        end
                     end
                  end
end)

local DateTime = require("api.DateTime")
local area_mapping = require("internal.area_mapping")
local uid_tracker = require("internal.uid_tracker")
local Rand = require("api.Rand")
local save = require("internal.global.save")

local function init_save()
   local s = save.base
   s.date = DateTime:new(517, 8, 12, 16, 10, 0)
   s.play_turns = 0
   s.play_days = 0
   s.area_mapping = area_mapping:new()
   s.player = nil
   s.allies = {}
   s.uids = uid_tracker:new()
   s.map_uids = uid_tracker:new()
   s.random_seed = Rand.rnd(800) + 2
   s.shadow = 70
   s.has_light_source = false
end

Event.register("base.on_init_save", "Init save (base)", init_save, {priority = 0})

Event.register("base.on_hotload_end", "Hotload field renderer",
               function()
                  local field = require("game.field")
                  if field.is_active then
                     field.renderer.screen_updated = true
                     field.renderer:update(0)
                  end
               end)

Event.register("base.on_hotload_prototype", "Hotload UI theme",
               function(_, args)
                  if args.new._type == "base.theme" then
                     UiTheme.clear()
                     local default_theme = "elona_sys.default"
                     UiTheme.add_theme(default_theme)
                  end
               end)
