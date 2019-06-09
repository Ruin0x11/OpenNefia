data:add_type {
   name = "chara",
   schema = schema.Record {
      name = schema.String,
      image = schema.Number,
      max_hp = schema.Number,
      on_death = schema.Optional(schema.Function),
   },
   index_on = "name"
}

data:add_type {
   name = "map_tile",
   schema = schema.Record {
      image = schema.Number,
      is_solid = schema.Boolean,
   },
}

data:add_type {
   name = "event",
   schema = schema.Record {
   },
}

data:add_type {
   name = "ui_theme",
   schema = schema.Record {
      target = schema.String,
   },
}

data:add_type {
   name = "asset",
   schema = schema.Record {
      target = schema.String,
   }
}
data:add_type {
   name = "element",
   schema = schema.Record {
      can_resist = schema.Boolean,
      can_be_immune_to = schema.Boolean,
      on_damage_hp = schema.Optional(schema.Function),
      on_kill = schema.Optional(schema.Function),
      kill_animation = schema.Optional(schema.String),
      sound = schema.Optional(schema.String),
   }
}

data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   image = 4,
   max_hp = 5,
   max_mp = 1
}

data:add {
   _type = "base.map_tile",
   _id = "floor",

   image = 451,
   is_solid = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = 300,
   is_solid = true
}

data:add_multi(
   "base.event",
   {
      _id = "before_ai_decide_action"
   },
   {
      _id = "after_apply_damage"
   },
   {
      _id = "on_calc_damage"
   },
   {
      _id = "after_damage_hp"
   },
   {
      _id = "on_player_bumped_into_nonhostile_chara"
   },
   {
      _id = "before_player_map_leave"
   },
   {
      _id = "on_player_bumped_into_object"
   },
   {
      _id = "on_chara_hostile_action"
   },
   {
      _id = "on_chara_killed"
   },
   {
      _id = "on_calc_kill_exp"
   }
)

function register_enum()
end

register_enum {
   _id = "relation",

   values = {
      "friendly",
      "neutral",
      "citizen",
      "enemy",
   }
}

data:add_multi(
   "base.ui_theme",

   {
      _id = "default",

      base = {
         text_color = {
            type = "color",
            value = {0, 0, 0}
         },
         text_color_light = {
            type = "color",
            value = {255, 255, 255}
         },
         text_color_light_shadow = {
            type = "color",
            value = {0, 0, 0}
         },
      },

      items = {
         ["api.gui.hud.MainHud"] = {
            minimap = "graphic/temp/hud_minimap.bmp",
            map_name_icon = "graphic/temp/map_name_icon.bmp",
            bar = "graphic/temp/hud_bar.bmp",
            skill_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/hud_skill_icons.bmp",
                  count_x = 10
               }
            },
            attribute_font = {
               type = "font",
               value = 13
            },
            map_name_font = {
               type = "font",
               value = 12
            }
         },
         ["api.gui.hud.UiMessageWindow"] = {
            message_window = "graphic/temp/message_window.bmp",
         },
         ["api.gui.hud.UiGoldPlatinum"] = {
            gold_coin = "graphic/temp/gold_coin.bmp",
            platinum_coin = "graphic/temp/platinum_coin.bmp",
         },
         ["api.gui.hud.UiLevel"] = {
            character_level_icon = "graphic/temp/character_level_icon.bmp",
         },
         ["api.gui.hud.UiBar"] = {
            hp_bar_frame = "graphic/temp/hp_bar_frame.bmp",
            hud_hp_bar = "graphic/temp/hud_hp_bar.bmp",
            hud_mp_bar = "graphic/temp/hud_mp_bar.bmp",
         },
         ["api.gui.hud.UiClock"] = {
            clock = "graphic/temp/clock.bmp",
            clock_hand = "graphic/temp/clock_hand.bmp",
            date_label_frame = "graphic/temp/date_label_frame.bmp",
         },
      }
   }
)

data:add_multi(
   "base.asset",

   {
      _id = "skill_icons",
      image = "graphic/temp/skill_icons.bmp",
      count_x = 10
   }
)

local Event = require("api.Event")
-- Event.register(
-- "base.before_ai_decide_action",
-- "nope",
-- function(params)
--    params.action = "turn_end"
--    return true
-- end)

-- TODO: if set, prevent hooks with 'name' being run:
--   params.blocked = { "other_hook" }
