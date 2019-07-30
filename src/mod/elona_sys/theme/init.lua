local function window_regions()
   local quad = {}

   quad["top_left"] = { 0, 0, 64, 48 }
   quad["top_right"] = { 208, 0, 56, 48 }
   quad["bottom_left"] = { 0, 144, 64, 48 }
   quad["bottom_right"] = { 208, 144, 56, 48 }
   for i=0,18 do
      quad["top_mid_" .. i] = { i * 8 + 36, 0, 8, 48 }
      quad["bottom_mid_" .. i] = { i * 8 + 54, 144, 8, 48 }
   end

   for j=0,12 do
      quad["mid_left_" .. j] = { 0, j * 8 + 48, 64, 8 }

      for i=0,18 do
         quad["mid_mid_" .. j .. "_" .. i] = { i * 8 + 64, j * 8 + 48, 8, 8 }
      end

      quad["mid_right_" .. j] = { 208, j * 8 + 48, 56, 8 }
   end

   return quad
end

local function topic_window_regions(width, height)
   local quad = {}

   quad["top_mid"] = { 16, 0, 16, 16 }
   quad["bottom_mid"] = { 16, 32, 16, 16 }
   quad["top_mid2"] = { 16, 0, width % 16, 16 }
   quad["bottom_mid2"] = { 16, 32, width % 16, 16 }
   quad["left_mid"] = { 0, 16, 16, 16 }
   quad["right_mid"] = { 32, 16, 16, 16 }
   quad["left_mid2"] = { 0, 16, 16, height % 16 }
   quad["right_mid2"] = { 32, 16, 16, height % 16 }
   quad["top_left"] = { 0, 0, 16, 16 }
   quad["bottom_left"] = { 0, 32, 16, 16 }
   quad["top_right"] = { 32, 0, 16, 16 }
   quad["bottom_right"] = { 32, 32, 16, 16 }

   return quad
end

data:add {
   _type = "base.theme",
   _id = "default",

   root = "mod/elona/graphic",
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
         arrow_left = "asset/arrow_left.png",
         arrow_right = "asset/arrow_right.png",
         direction_arrow = "asset/direction_arrow.png",
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
            regions = window_regions() -- ()
         },
         -- window_1 = {
         --    image = "asset/window_1.png",
         --    regions = topic_window_regions
         -- },
         -- window_2 = {
         --    image = "asset/window_2.png",
         --    regions = topic_window_regions
         -- },
         -- window_3 = {
         --    image = "asset/window_3.png",
         --    regions = topic_window_regions
         -- },
         -- window_4 = {
         --    image = "asset/window_4.png",
         --    regions = topic_window_regions
         -- },
         -- window_5 = {
         --    image = "asset/window_5.png",
         --    regions = topic_window_regions
         -- },
         -- window_6 = {
         --    image = "asset/window_6.png",
         --    regions = topic_window_regions
         -- },
         topic_window = {
            image = "asset/window.png",
            regions = {
               fill = { 24, 24, 228, 144 }
            }
         },
         title = "asset/title.png",
         void = "asset/void.png",
         bg_night = "asset/bg_night.png",

         attribute_font = {
            type = "font",
            size = 13
         },
         map_name_font = {
            type = "font",
            size = 12
         },
         gold_count_font = {
            type = "font",
            size = 13
         },
         status_indicator_font = {
            type = "font",
            size = 13 -- 13 - en * 2
         },

         text_color = {
            type = "color",
            color = {0, 0, 0}
         },
         text_color_light = {
            type = "color",
            color = {255, 255, 255}
         },
         text_color_light_shadow = {
            type = "color",
            color = {0, 0, 0}
         },
      }
   }
}
