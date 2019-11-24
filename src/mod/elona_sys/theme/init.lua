local function gen_window_regions()
   local quad = {}

   quad["fill"] = { 24, 24, 228, 144 }
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
         deco_mirror_a = "asset/deco_mirror_a.png",
         deco_feat_a = "asset/deco_feat_a.png",
         deco_feat_b = "asset/deco_feat_b.png",
         deco_feat_c = "asset/deco_feat_c.png",
         deco_feat_d = "asset/deco_feat_d.png",
         inventory_icons = {
            image = "asset/inventory_icons.png",
            count_x = 22
         },
         trait_icons = {
            image = "asset/trait_icons.png",
            count_x = 6
         },
         equipped_icon = "asset/equipped_icon.png",
         label_input = "asset/label_input.png",
         input_caret = "asset/input_caret.png",
         buff_icon = {
            image = "asset/buff_icon.png",
            count_x = 19
         },
         buff_icon_none = "asset/buff_icon_none.png",
         arrow_left = "asset/arrow_left.png",
         arrow_right = "asset/arrow_right.png",
         direction_arrow = "asset/direction_arrow.png",
         caption = {
            image = "asset/caption.png",
            regions = function(width, height)
               print"cap"
               local quad = {}
               quad[1] =  { 0, 0, 128, 3 }
               quad[2] =  { 0, 3, 128, 22 }
               quad[3] =  { 0, 0, 128, 2 }
               quad[4] =  { 0, 0, width % 128, 3 }
               quad[5] =  { 0, 3, width % 128, 22 }
               quad[6] =  { 0, 0, width % 128, 2 }
               return quad
            end
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
         ie_sheet = "asset/ie_sheet.png",
         ime_status_english = "asset/ime_status_english.png",
         ime_status_japanese = "asset/ime_status_japanese.png",
         ime_status_none = "asset/ime_status_none.png",
         window = {
            image = "asset/window.png",
            regions = gen_window_regions() -- ()
         },
         window_0 = {
            image = "asset/window_0.png",
            regions = topic_window_regions
         },
         window_1 = {
            image = "asset/window_1.png",
            regions = topic_window_regions
         },
         window_2 = {
            image = "asset/window_2.png",
            regions = topic_window_regions
         },
         window_3 = {
            image = "asset/window_3.png",
            regions = topic_window_regions
         },
         window_4 = {
            image = "asset/window_4.png",
            regions = topic_window_regions
         },
         window_5 = {
            image = "asset/window_5.png",
            regions = topic_window_regions
         },
         topic_window = {
            image = "asset/window.png",
            regions = {
               fill = { 24, 24, 228, 144 }
            }
         },
         title = "asset/title.png",
         void = "asset/void.png",
         bg_night = "asset/bg_night.png",
         g1 = "asset/g1.png",
         g2 = "asset/g2.png",
         g3 = "asset/g3.png",
         g4 = "asset/g4.png",
         select_key = "asset/select_key.png",
         list_bullet = "asset/list_bullet.png",

         shadow = "asset/shadow.png",
         shadow_edges = "asset/shadow_edges.png",
         character_shadow = "asset/character_shadow.png",

         failure_to_cast_effect = "asset/failure_to_cast_effect.png",
         swarm_effect = "asset/swarm_effect.png",
         breaking_effect = "asset/breaking_effect.png",
         melee_attack_debris = "asset/melee_attack_debris.png",
         melee_attack_blood = "asset/melee_attack_blood.png",
         ranged_attack_arrow = "asset/ranged_attack_arrow.png",
         ranged_attack_laser = "asset/ranged_attack_laser.png",
         ranged_attack_bullet = "asset/ranged_attack_bullet.png",
         ranged_attack_magic_arrow = "asset/ranged_attack_magic_arrow.png",

         anim_slash = {
            image = "asset/anim_slash.png",
            count_x = 4
         },

         anim_bash = {
            image = "asset/anim_bash.png",
            count_x = 4
         },

         anim_miracle = {
            image = "asset/anim_miracle.png",
            count_x = 10,
            count_y = 2,
            regions = {
               beam_1 = {0, 0, 96, 55},
               beam_2 = {96, 0, 96, 55},
               beam_3 = {288, 0, 96, 40}
            }
         },

         anim_gene = {
            image = "asset/anim_gene.png",
            count_x = 5,
            count_y = 2
         },

         anim_critical = {
            image = "asset/anim_critical.png",
            count_x = 6
         },

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

         stat_penalty_color = {
            type = "color",
            color = {200, 0, 0}
         },
         stat_bonus_color = {
            type = "color",
            color = {0, 120, 0}
         },
      }
   }
}
