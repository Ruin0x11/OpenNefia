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

data:add_type {
   name = "status_effect",
   schema = schema.Record {
      related_element = schema.Optional(schema.String),
      before_apply = schema.Optional(schema.Function),
      power_reduction_factor = schema.Optional(schema.Number),
      additive_power = schema.Optional(schema.Function),
      on_turn_end = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_boolean",
   schema = schema.Record {
      default = schema.Boolean,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_choice",
   schema = schema.Record {
      choices = schema.Table,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_number",
   schema = schema.Record {
      max = schema.Number,
      min = schema.Number,
      default = schema.Number,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_string",
   schema = schema.Record {
      max_length = schema.Number,
      min_length = schema.Number,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_file",
   schema = schema.Record {
      default = schema.Optional(schema.String),
      on_generate = schema.Optional(schema.Function),
      on_validate_file = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_menu",
   schema = schema.Record {
      options = schema.Table,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_custom_menu",
   schema = schema.Record {
      require_path = schema.String,
      options = schema.Table
   }
}

data:add {
   _type = "config_option_boolean",
   _id = "exchange_crawl_up_and_buried",
}

data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   image = 4,
   max_hp = 50,
   max_mp = 10
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
   },
   {
      _id = "on_turn_end"
   }
)

-- TODO: emotion icon as field
data:add_multi(
   "base.status_effect",
   {
      _id = "blindness",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.blindness", 1)
         if StatusEffect.get_turns(p.victim, "base.blindness" > 1) then
            -- emotion icon
         end
      end
   },
   {
      _id = "confusion",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.confusion", 1)
         if StatusEffect.get_turns(p.victim, "base.confusion" > 1) then
            -- emotion icon
         end
      end
   },
   {
      _id = "paralysis",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.paralysis", 1)
         if StatusEffect.get_turns(p.victim, "base.paralysis" > 1) then
            -- emotion icon
         end
         p.regeneration = false
      end
   },
   {
      _id = "poison",

      related_element = "base.poison",
      before_apply = nil,
      power_reduction_factor = 5,
      additive_power = function(p) return p.turns / 3 + 3 end,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")
         local StatusEffect = require("api.StatusEffect")
         local constitution = 100
         -- TODO: acts as damage source (self?)
         Chara.damage_hp(p.victim, Rand.rnd(2 + math.floor(constitution / 10)), { kind = -4 })
         StatusEffect.heal(p.victim, "base.poison", 1)
         if StatusEffect.get_turns(p.victim, "base.poison") > 1 then
            -- emotion icon
         end

         p.regeneration = false
      end
   },
   {
      _id = "choked",

      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         local Gui = require("api.Gui")
         local StatusEffect = require("api.StatusEffect")
         if p.turns % 3 == 0 then
            if Map.is_in_fov(p.victim.x, p.victim.y) then
               Gui.mes(p.victim.uid .. ": Being choked.")
            end
         end
         StatusEffect.apply(p.victim, "base.choked", 1)
         if StatusEffect.get_turns(p.victim, "base.choked") > 15 then
            Chara.damage_hp(p.victim, 500, { kind = -21 })
         end

         p.regeneration = false
      end
   },
   {
      _id = "sleep",

      related_element = "base.nerve",
      before_apply = nil,
      power_reduction_factor = 4,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.sleep", 1)
         if StatusEffect.get_turns(p.victim, "base.sleep") > 1 then
            -- emotion icon
         end
         Chara.heal_hp(p.victim, 1)
         Chara.heal_mp(p.victim, 1)
      end
   },
   {
      _id = "gravity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.gravity", 1)
      end
   },
   {
      _id = "furious",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.furious", 1)
      end
   },
   {
      _id = "fear",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = 0,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.fear", 1)
         -- emotion icon
      end
   },
   {
      _id = "dimming",

      related_element = "base.sound",
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.dimming", 1)
         -- emotion icon
      end
   },
   {
      _id = "bleeding",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 25,
      additive_power = function(p) return p.turns end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")

         Chara.damage_hp(p.victim, Rand.rnd(math.floor(p.victim.hp * (1 + p.turns / 4) / 100 + 3) + 1), { kind = -13 })
         StatusEffect.heal(p.victim, "base.bleeding", 1)
         -- emotion icon
         p.regeneration = false
      end
   },
   {
      _id = "wetness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.wetness", 1)
      end
   },
   {
      _id = "drunkeness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 10,
      additive_power = function(p) return p.turns end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.drunkenness", 1)
         -- emotion icon
      end
   },
   {
      _id = "insanity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Gui = require("api.Gui")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         if Map.is_in_fov(p.victim.x, p.victim.y) then
            if Rand.one_in(3) then
               Gui.txt("Insane.")
            end
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.confusion", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.dimming", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.sleep", Rand.rnd(5))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.fear", Rand.rnd(10))
         end
         StatusEffect.heal(p.victim, "base.insanity", 1)
         -- emotion icon
      end
   },
   {
      _id = "sickness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 10,
      additive_power = function(p) return p.turns / 10 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Rand = require("api.Rand")
         local Chara = require("api.Chara")
         if Rand.one_in(80) then
            -- local random_stat = ...
            -- Chara.debuff()
         end
         if Rand.one_in(5) then
            p.regeneration = false
         end
         if not Chara.is_ally(p.victim) then
            -- if p.victim.quality >= "miracle"
            if Rand.one_in(200) then
               StatusEffect.heal(p.victim, "base.sickness")
            end
         end
      end
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
      "angered",
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

Event.register(
"base.on_player_bumped_into_chara",
"nande POISON nan dayo",
function(params)
   local StatusEffect = require("api.StatusEffect")
   StatusEffect.apply(params.on_cell, "base.poison", 100)
   return true
end)
