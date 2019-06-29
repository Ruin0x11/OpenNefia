data:add_multi(
   "base.event",
   {
      _id = "before_ai_decide_action"
   },
   {
      _id = "after_chara_damaged",
      observer = "chara"
   },
   {
      _id = "on_calc_damage"
   },
   {
      _id = "after_damage_hp",
      observer = "chara"
   },
   {
      _id = "on_player_bumped_into_chara",
      observer = "chara"
   },
   {
      _id = "before_player_map_leave"
   },
   {
      _id = "on_player_bumped_into_object"
   },
   {
      _id = "before_chara_moved"
   },
   {
      _id = "on_chara_moved"
   },
   {
      _id = "on_chara_hostile_action",
      observer = "chara"
   },
   {
      _id = "on_chara_killed",
      observer = "chara"
   },
   {
      _id = "on_calc_kill_exp"
   },
   {
      _id = "on_chara_turn_end"
   },
   {
      _id = "before_chara_turn_start"
   },
   {
      _id = "on_chara_pass_turn"
   },
   {
      _id = "on_game_start"
   },
   {
      _id = "on_proc_status_effect"
   },
   {
      _id = "on_apply_status_effect"
   },
   {
      _id = "on_chara_revived",
      observer = "chara"
   },
   {
      _id = "on_talk",
      observer = "chara"
   },
   {
      _id = "on_calc_chara_equipment_stats",
      observer = "chara" -- { "chara", "item" }
   }
)

data:add_multi(
   "base.talk_event",
   {
      _id = "ai_aggro"
   },
   {
      _id = "ai_calm"
   },
   {
      _id = "ai_melee"
   },
   {
      _id = "ai_ranged"
   }
)

data:add {
   _type = "base.config_option_boolean",
   _id = "exchange_crawl_up_and_buried",
}

data:add_multi(
   "base.faction",
   {
      _id = "friendly",
      reactions = {
         ["base.citizen"] = 100,
         ["base.neutral"] = 50,
         ["base.enemy"] =  -100,
      }
   },
   {
      _id = "citizen",
      reactions = {
         ["base.friendly"] = 100,
         ["base.neutral"] = 50,
         ["base.enemy"] =  -100,
      }
   },
   {
      _id = "neutral",
      reactions = {
         ["base.friendly"] = 50,
         ["base.citizen"] = 50,
         ["base.enemy"] =  -100,
      }
   },
   {
      _id = "enemy",
      reactions = {
         ["base.friendly"] = -100,
         ["base.citizen"] = -100,
         ["base.neutral"] = -100,
      }
   }
)

-- TODO: theming should be supported as follows.
--
-- 1. Data compatible with theming are registered. The data specifies
--    the fallback to use if no theme is available. For UI elements,
--    this would be "base.ui_element_theme" or similar.
-- 2. To add a new theme, a "base.ui_theme" is created. In `items`,
--    the types and IDs of the theme-supported data are put, along
--    with a delta of modifications. Not all themable items have to be
--    supported at once.
-- 3. APIs supporting theming will use an underlying Theme API to
--    resolve the correct resource. This value will be cached. It is
--    essentially a layer of indirection over data[] that allows
--    substituting a constant value at runtime.
--
-- This should allow more than one theme (or no theme at all) to be
-- applied in an atomic manner, and with instant update on switch.
-- Also, this could allow applying temporary theme modifiers, where
-- images/sounds are altered temporarily until the change is
-- reverted/popped off.
--
-- The reason for each type needing specific compatibility for theming
-- is the fact that typical theme resources are not incrementable
-- numbers but instead constant values like paths. This is a different
-- paradigm than allowing a stat to be incremented by a percentage.
-- Since the only operation supported is setting a field to a constant
-- value, it is possible to apply atomically. So, the supported types
-- need to be able to be modified in only this way, which works out
-- for themes.
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
         ["api.gui.menu.BookMenu"] = {
            book = "graphic/book.bmp",
         },
         ["api.gui.menu.InventoryMenu"] = {
            deco_a = "graphic/temp/deco_inv_a.bmp",
            deco_b = "graphic/temp/deco_inv_b.bmp",
            deco_c = "graphic/temp/deco_inv_c.bmp",
            deco_d = "graphic/temp/deco_inv_d.bmp",
            inventory_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/inventory_icons.bmp",
                  count_x = 22
               }
            },
            gold_coin = "graphic/temp/gold_coin.bmp",
            gold_count_font = {
               type = "font",
               value = 13
            },
            equipped_icon = "graphic/temp/equipped_icon.bmp"
         },
         ["api.gui.menu.InventoryWrapper"] = {
            -- TODO dedupe
            inventory_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/inventory_icons.bmp",
                  count_x = 22
               }
            },
         },
         ["api.gui.NumberPrompt"] = {
            label_input = "graphic/temp/label_input.bmp",
            arrows = {
               type = "asset",
               value = {
                  image = "graphic/temp/arrows.bmp",
                  count_x = 2
               }
            }
         },
         ["api.gui.menu.ItemDescriptionMenu"] = {
            enchantment_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/enchantment_icons.bmp",
                  count_x = 9
               }
            },
            inheritance_icon = "graphic/temp/inheritance_icon.bmp"
         },
         ["api.gui.menu.EquipmentMenu"] = {
            body_part_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/body_part_icons.bmp",
                  count_x = 11
               }
            },
            deco_a = "graphic/temp/deco_wear_a.bmp",
            deco_b = "graphic/temp/deco_wear_b.bmp",
            -- TODO dedupe
            inventory_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/inventory_icons.bmp",
                  count_x = 22
               }
            },
         },
         ["api.gui.menu.IconBar"] = {
            radar_deco = "graphic/temp/radar_deco.bmp",
         },
         ["api.gui.hud.UiStatusEffects"] = {
            status_effect_bar = "graphic/temp/status_effect_bar.bmp",
            indicator_font = {
               type = "font",
               value = 13 -- 13 - en * 2
            },
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

require("mod.base.sound")
require("mod.base.resolver")
