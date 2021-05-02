local data = require("internal.data")
local draw = require("internal.draw")
local config = require("internal.config")
local Log = require("api.Log")
local startup = require("game.startup")
local ISoundHolder = require("api.ISoundHolder")
local midi = require("internal.midi")
local global_sound_manager = require("internal.global.global_sound_manager")
local Event = require("api.Event")

data:add_multi(
   "base.config_option",
   {
      {
         _id = "keybinds",

         type = "table",
         default = {}
      },
      {
         _id = "show_charamake_extras",

         type = "boolean",
         default = false
      },
      {
         _id = "quickstart_scenario",

         type = "data_id",
         data_type = "base.scenario",
         default = "test_room.test_room"
      },
      {
         _id = "quickstart_chara_id",

         type = "data_id",
         data_type = "base.chara",
         default = "base.player"
      },
      {
         _id = "default_font",

         type = "string",
         default = "kochi-gothic-subst.ttf"
      },
      {
         _id = "quickstart_on_startup",

         type = "boolean",
         default = false
      },
      {
         _id = "_save_id", -- TODO move to private state

         type = "string",
         optional = true,
         default = nil
      },
      {
         _id = "themes",

         type = "table",
         default = {}
      },
   }
)

--
-- Menu: game
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "story",

         type = "boolean",
         default = true
      },
      {
         _id = "default_save",

         type = "string",
         optional = true,
         default = nil
      },
      {
         _id = "attack_neutral_npcs",

         type = "boolean",
         default = false
      },
      {
         _id = "hide_shop_updates",

         type = "boolean",
         default = false
      },
      {
         _id = "hide_autoidentify",

         type = "boolean",
         default = false
      },
      {
         _id = "extra_help",

         type = "boolean",
         default = true
      },
      {
         _id = "skip_random_event_popups",

         type = "boolean",
         default = false
      },
      {
         _id = "autosave",

         type = "enum",
         choices = { "always", "sometimes", "rarely", "almost_never" },
         default = "always"
      },
      {
         _id = "default_return_to_title",

         type = "boolean",
         default = false
      },
   }
)

data:add {
   _id = "game",
   _type = "base.config_menu",
   items = {
      "base.story",
      "base.attack_neutral_npcs",
      "base.hide_shop_updates",
      "base.hide_autoidentify",
      "base.extra_help",
      "base.skip_random_event_popups",
      "base.autosave",
      "base.default_return_to_title"
   }
}

--
-- Menu: screen
--

local function replay_music()
   local Gui = require("api.Gui")
   local sound_manager = require("internal.global.global_sound_manager")

   local music_id = sound_manager.music_id
   if music_id then
      Gui.stop_music()
      Gui.play_music(music_id)
   end
end

data:add_multi(
   "base.config_option",
   {
      {
         _id = "screen_mode",

         type = "enum",
         choices = { "windowed", "desktop", "exclusive" },
         default = "windowed",

         on_changed = function(v, is_startup)
            if not is_startup then
               draw.reload_window_mode()
            end
         end
      },
      {
         _id = "screen_resolution",

         type = "enum",
         choices = function()
            local modes = love.window.getFullscreenModes()
            local filter = function(m) return m.width >= 800 and m.height >= 600 end
            local map = function(m) return ("%sx%s"):format(m.width, m.height) end
            return fun.iter(modes):filter(filter):map(map):to_list()
         end,

         on_changed = function(v, is_startup)
            if not is_startup and config.base.screen_mode ~= "desktop" then
               draw.reload_window_mode()
            end
         end
      },
      {
         _id = "object_shadows",

         type = "boolean",
         default = true
      },
      {
         _id = "high_quality_shadows",

         type = "boolean",
         default = true
      },
      {
         _id = "heartbeat",

         type = "boolean",
         default = true
      },
      {
         _id = "music",

         type = "boolean",
         default = true,

         on_changed = function(value)
            local Gui = require("api.Gui")

            if not value then
               Gui.stop_music()
            else
               replay_music()
            end
         end
      },
      {
         _id = "midi_driver",

         type = "enum",
         choices = { "generic", "native" },
         default = "generic",

         on_changed = function(value)
            if global_sound_manager:is_playing_midi() then
               replay_music()
            end
         end
      },
      {
         _id = "midi_device",

         type = "enum",
         choices = function()
            if not midi.is_loaded() then
               return { "<none>" }
            end

            local ports = midi.get_ports()
            if #ports == 0 then
               return { "<none>" }
            end

            local function map(port)
               return ("%d: %s"):format(port.index, port.name)
            end

            return fun.iter(ports):map(map):to_list()
         end,

         on_changed = function(value)
            if global_sound_manager:is_playing_midi() then
               replay_music()
            end
         end
      },
      {
         _id = "heartbeat_threshold",

         type = "integer",
         default = 20,
         min_value = 1,
         max_value = 100
      },
      {
         _id = "sound",

         type = "boolean",
         default = true
      },
      {
         _id = "weather_effect",

         type = "boolean",
         default = true
      },
      {
         _id = "positional_audio",

         type = "boolean",
         default = false,

         on_changed = function()
            local field = require("game.field")
            if field.is_active then
               for _, obj in field.map:iter() do
                  ISoundHolder.on_set_location(obj, obj.location)
               end
            end
         end
      }
   }
)

data:add {
   _id = "screen",
   _type = "base.config_menu",
   items = {
      "base.sound",
      "base.music",
      "base.midi_driver",
      "base.midi_device",
      "base.positional_audio",
      "base.screen_mode",
      "base.screen_resolution",
      "base.heartbeat",
      "base.heartbeat_threshold",
      "base.weather_effect",
      "base.high_quality_shadows",
      "base.object_shadows",
   }
}

--
-- Menu: net
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "enable_net",

         type = "boolean",
         default = true
      },
   }
)

data:add {
   _id = "net",
   _type = "base.config_menu",
   items = {
      "base.enable_net",
   }
}

--
-- Menu: anime
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "attack_anime",

         type = "boolean",
         default = true
      },
      {
         _id = "general_wait",
         type = "integer",
         -- >>>>>>>> shade2/help.hsp:1238 			if cs=0:configSelect cfg_runWait,"runWait.",p,2 ...
         default = 2,
         min_value = 2,
         max_value = 5
         -- <<<<<<<< shade2/help.hsp:1238 			if cs=0:configSelect cfg_runWait,"runWait.",p,2 ..
      },
      {
         _id = "title_effect",

         type = "boolean",
         default = true
      },
      {
         _id = "auto_turn_speed",

         type = "enum",
         choices = { "normal", "high", "highest" },
         default = "normal"
      },
      {
         _id = "scroll",

         type = "boolean",
         default = true
      },
      {
         _id = "window_anime",

         type = "boolean",
         default = false
      },
      {
         _id = "always_center",

         type = "boolean",
         default = true
      },
      {
         _id = "alert_wait",

         type = "integer",
         min_value = 0,
         max_value = 100,
         default = 50
      },
      {
         _id = "screen_refresh",

         type = "integer",
         -- >>>>>>>> elona122/shade2/help.hsp:773 	if cfg_scrSync=0	:cfg_scrSync=3 ...
         default = 20,
         -- <<<<<<<< elona122/shade2/help.hsp:773 	if cfg_scrSync=0	:cfg_scrSync=3 ..
         -- >>>>>>>> elona122/shade2/help.hsp:1241 			if cs=3:configSelect cfg_scrSync,"scr_sync.",p, ...
         min_value = 1,
         max_value = 250,
         -- <<<<<<<< elona122/shade2/help.hsp:1241 			if cs=3:configSelect cfg_scrSync,"scr_sync.",p, ..
      },
      {
         _id = "anime_wait",

         type = "integer",
         default = 20,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "anime_wait_type",

         type = "enum",
         choices = { "always_wait", "at_turn_start", "never_wait" },
         default = "always_wait",
      },
      {
         _id = "background_effect_wait",

         type = "integer",
         default = 30,
         min_value = 0,
         max_value = 100,
      },
      {
         _id = "update_unfocused_ui_layers",

         type = "boolean",
         default = false
      },
      {
         _id = "scroll_when_run",

         type = "boolean",
         default = true
      },
      {
         _id = "skip_sleep_animation",

         type = "boolean",
         default = false
      }
   }
)

data:add {
   _id = "anime",
   _type = "base.config_menu",
   items = {
      "base.attack_anime",
      "base.general_wait",
      "base.title_effect",
      "base.auto_turn_speed",
      "base.scroll",
      "base.window_anime",
      "base.always_center",
      "base.alert_wait",
      "base.screen_refresh",
      "base.anime_wait",
      "base.anime_wait_type",
      "base.background_effect_wait",
      "base.update_unfocused_ui_layers",
      "base.scroll_when_run",
      "base.skip_sleep_animation"
   }
}

--
-- Menu: input
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "autodisable_numlock",

         type = "boolean",
         default = true
      },
      {
         _id = "attack_wait",

         type = "integer",
         default = 4,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "key_repeat_wait",

         type = "integer",
         default = 1,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "select_wait",

         type = "integer",
         default = 5,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "run_wait",

         type = "integer",
         default = 2,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "initial_key_repeat_wait",

         type = "integer",
         default = 5,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "walk_wait",

         type = "integer",
         default = 5,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "key_wait",

         type = "integer",
         default = 5,
         min_value = 0,
         max_value = 100
      },
      {
         _id = "start_run_wait",

         type = "integer",
         default = 2,
         min_value = 0,
         max_value = 100
      },
   }
)

data:add {
   _id = "input",
   _type = "base.config_menu",
   items = {
      "base.autodisable_numlock",
      "base.attack_wait",
      "base.key_repeat_wait",
      "base.select_wait",
      "base.run_wait",
      "base.initial_key_repeat_wait",
      "base.walk_wait",
      "base.key_wait",
      "base.start_run_wait",
   }
}

--
-- Menu: keybindings
--

data:add {
   _id = "keybindings",
   _type = "base.config_menu",
   items = {
   }
}

--
-- Menu: message
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "message_timestamps",

         type = "boolean"
      },
      {
         _id = "message_transparency",

         type = "integer",
         -- >>>>>>>> shade2/config.txt:50 msg_trans.	"4" ...
         default = 4,
         -- <<<<<<<< shade2/config.txt:50 msg_trans.	"4" ..
         -- >>>>>>>> shade2/help.hsp:1255 			if cs=1:configSelect cfg_msgTrans,"msg_trans.", ...
         min_value = 0,
         max_value = 5,
         -- <<<<<<<< shade2/help.hsp:1255 			if cs=1:configSelect cfg_msgTrans,"msg_trans.", ..

         on_changed = function()
            Event.trigger("base.on_hud_message", {action="redraw"})
         end
      }
   }
)

data:add {
   _id = "message",
   _type = "base.config_menu",
   items = {
      "base.message_timestamps",
      "base.message_transparency"
   }
}

--
-- Menu: language
--

data:add_multi(
   "base.config_option",
   {
      {
         _id = "language",

         type = "data_id",
         data_type = "base.language",
         default = "base.english",

         on_changed = function(v)
            local I18N = require("api.I18N")
            I18N.switch_language(v)
         end
      },
   }
)

data:add {
   _id = "language",
   _type = "base.config_menu",
   items = {
      "base.language"
   }
}


data:add_multi(
   "base.config_option",
   {
      {
         _id = "log_level",

         type = "enum",
         choices = {"trace", "debug", "info", "warn", "error"},
         default = "info",

         on_changed = function(value)
            Log.set_level(value)
         end
      },
      {
         _id = "development_mode",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_autoidentify",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_no_weight",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_default_seed",

         type = "integer",
         optional = true,
         default = nil
      },
      {
         _id = "debug_show_all_skills",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_infinite_skill_points",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_no_spell_failure",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_hp_always_full",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_show_resist_level",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_skip_random_events",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_always_renew_map",

         type = "enum",
         choices = { "disabled", "minor", "major" },
         default = "disabled",
      },
      {
         _id = "debug_load_after_save",

         type = "boolean",
         default = false,
      },
      {
         _id = "show_perf_widgets",

         type = "boolean",
         default = false,

         on_changed = function(value)
            draw.global_widget("fps_counter"):set_enabled(value)
         end
      },
      {
         _id = "max_inspect_length",

         type = "integer",
         default = 10000
      },
      {
         _id = "gc_pause",

         type = "integer",
         default = 100,
         on_changed = function(v, is_startup)
            if not is_startup then
               startup.set_gc_params()
            end
         end
      },
      {
         _id = "gc_step_multiplier",

         type = "integer",
         default = 800,
         on_changed = function(v, is_startup)
            if not is_startup then
               startup.set_gc_params()
            end
         end
      }
   }
)
