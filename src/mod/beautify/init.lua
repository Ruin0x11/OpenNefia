data:add {
   _type = "base.theme",
   _id = "beautify",

   root = "mod/beautify/graphic",
   assets = {
      elona = {
         minimap = "asset/hud_minimap.png",
         map_name_icon = "asset/map_name_icon.png",
         bar = "asset/hud_bar.png",
         skill_icons = {
            image = "asset/hud_skill_icons.png",
            count_x = 10
         },
         message_window = "asset/message_window.png",
         gold_coin = "asset/gold_coin.png",
         platinum_coin = "asset/platinum_coin.png",
         character_level_icon = "asset/character_level_icon.png",
         hp_bar_frame = "asset/hp_bar_frame.png",
         hud_hp_bar = "asset/hud_hp_bar.png",
         hud_mp_bar = "asset/hud_mp_bar.png",
         clock = "asset/clock.png",
         clock_hand = "asset/clock_hand.png",
         date_label_frame = "asset/date_label_frame.png",
         book = "asset/book.png",
         deco_inv_a = "asset/deco_inv_a.png",
         deco_inv_b = "asset/deco_inv_b.png",
         deco_inv_c = "asset/deco_inv_c.png",
         deco_inv_d = "asset/deco_inv_d.png",
         inventory_icons = {
            image = "asset/inventory_icons.png",
            count_x = 22
         },
         equipped_icon = "asset/equipped_icon.png",
         label_input = "asset/label_input.png",
         arrows = {
            image = "asset/arrows.png",
            count_x = 2
         },
         enchantment_icons = {
            image = "asset/enchantment_icons.png",
            count_x = 9
         },
         inheritance_icon = "asset/inheritance_icon.png",
         body_part_icons = {
            image = "asset/body_part_icons.png",
            count_x = 11
         },
         tip_icons = {
            image = "asset/tip_icons.png",
            count_x = 8
         },
         deco_wear_a = "asset/deco_wear_a.png",
         deco_wear_b = "asset/deco_wear_b.png",
         radar_deco = "asset/radar_deco.png",
         status_effect_bar = "asset/status_effect_bar.png",
         ie_chat = "asset/ie_chat.png",
         window = {
            image = "asset/window.png",

            -- HACK combining assets should follow some sort of
            -- convention, with awareness of path root (?)
            regions = data["base.theme"]["elona_sys.default"].assets.elona.window.regions
         },
         -- title = "asset/title.png",
         void = "asset/void.png",
      }
   }
}

local Event = require("api.Event")
local UiTheme = require("api.gui.UiTheme")

Event.register("base.on_game_startup", "add beautify",
               function()
                  UiTheme.add_theme("beautify.beautify")
               end)
