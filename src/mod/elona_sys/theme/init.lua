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

   root = "graphic",
   assets = {
      hud_minimap = {
         source = "interface.bmp",
         x = 120,
         y = 504,
         width = 136,
         height = 88
      },
      map_name_icon = {
         source = "interface.bmp",
         x = 208,
         y = 376,
         width = 16,
         height = 16
      },
      hud_bar = {
         source = "interface.bmp",
         x = 0,
         y = 440,
         width = 192,
         height = 24,
      },
      skill_icons = {
         source = "item.bmp",
         x = 0,
         y = 672,
         width = 48 * 8,
         height = 48,
         count_x = 8
      },
      hud_skill_icons = {
         source = "interface.bmp",
         x = 0,
         y = 376,
         width = 16 * 10,
         height = 16,
         count_x = 10
      },
      message_window = {
         source = "interface.bmp",
         x = 496,
         y = 528,
         width = 192,
         height = 72
      },
      gold_coin = {
         source = "interface.bmp",
         x = 0,
         y = 392,
         width = 24,
         height = 24
      },
      platinum_coin = {
         source = "interface.bmp",
         x = 24,
         y = 392,
         width = 24,
         height = 24
      },
      character_level_icon = {
         source = "interface.bmp",
         x = 48,
         y = 392,
         width = 24,
         height = 24
      },
      hp_bar_frame = {
         source = "interface.bmp",
         x = 312,
         y = 504,
         width = 104,
         height = 15
      },
      hud_hp_bar = {
         source = "interface.bmp",
         x = 312,
         y = 520,
         width = 100,
         height = 6
      },
      hud_mp_bar = {
         source = "interface.bmp",
         x = 432,
         y = 520,
         width = 100,
         height = 6
      },
      clock = {
         source = "interface.bmp",
         x = 448,
         y = 408,
         width = 120,
         height = 96
      },
      clock_hand = {
         source = "interface.bmp",
         x = 0,
         y = 288,
         width = 48,
         height = 48
      },
      date_label_frame = {
         source = "interface.bmp",
         x = 448,
         y = 376,
         width = 128,
         height = 24
      },
      book = {
         image = "book.bmp",
      },
      deco_inv_a = {
         source = "deco_inv.bmp",
         x = 0,
         y = 0,
         width = 144,
         height = 48
      },
      deco_inv_b = {
         source = "deco_inv.bmp",
         x = 0,
         y = 48,
         width = 48,
         height = 72
      },
      deco_inv_c = {
         source = "deco_inv.bmp",
         x = 48,
         y = 48,
         width = 48,
         height = 72
      },
      deco_inv_d = {
         source = "deco_inv.bmp",
         x = 0,
         y = 120,
         width = 48,
         height = 72
      },
      deco_mirror_a = {
         source = "deco_mirror.bmp",
         x = 0,
         y = 0,
         width = 48,
         height = 120
      },
      deco_feat_a = {
         source = "deco_feat.bmp",
         x = 0,
         y = 0,
         width = 48,
         height = 192
      },
      deco_feat_b = {
         source = "deco_feat.bmp",
         x = 48,
         y = 0,
         width = 48,
         height = 144
      },
      deco_feat_c = {
         source = "deco_feat.bmp",
         x = 0,
         y = 192,
         width = 96,
         height = 72
      },
      deco_feat_d = {
         source = "deco_feat.bmp",
         x = 48,
         y = 144,
         width = 96,
         height = 48
      },
      deco_board_a = {
         source = "deco_board.bmp",
         x = 0,
         y = 0,
         width = 128,
         height = 128
      },
      deco_board_b = {
         source = "deco_board.bmp",
         x = 0,
         y = 144,
         width = 48,
         height = 84
      },
      inventory_icons = {
         source = "interface.bmp",
         x = 288,
         y = 48,
         width = 48 * 22,
         height = 48,
         count_x = 22
      },
      trait_icons = {
         source = "interface.bmp",
         x = 384,
         y = 336,
         width = 24 * 6,
         height = 24,
         count_x = 6
      },
      equipped_icon = {
         source = "interface.bmp",
         x = 12,
         y = 348,
         width = 12,
         height = 12
      },
      label_input = {
         source = "interface.bmp",
         x = 128,
         y = 288,
         width = 128,
         height = 32
      },
      input_caret = {
         source = "interface.bmp",
         x = 0,
         y = 336,
         width = 12,
         height = 24
      },
      buff_icon = {
         source = "character.bmp",
         x = 0,
         y = 1120,
         width = 32 * 19,
         height = 32,
         count_x = 19
      },
      buff_icon_none = {
         source = "interface.bmp",
         x = 320,
         y = 160,
         width = 32,
         height = 32
      },
      arrow_left = {
         source = "interface.bmp",
         x = 312,
         y = 336,
         width = 24,
         height = 24
      },
      arrow_right = {
         source = "interface.bmp",
         x = 336,
         y = 336,
         width = 24,
         height = 24
      },
      direction_arrow = {
         source = "interface.bmp",
         x = 212,
         y = 432,
         width = 28,
         height = 28
      },
      caption = {
         source = "interface.bmp",
         x = 672,
         y = 477,
         width = 128,
         height = 25,
         regions = function(width, height)
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
         source = "interface.bmp",
         x = 72,
         y = 336,
         width = 24 * 9,
         height = 24,
         count_x = 9
      },
      inheritance_icon = {
         source = "interface.bmp",
         x = 384,
         y = 360,
         width = 24,
         height = 24
      },
      body_part_icons = {
         source = "interface.bmp",
         x = 600,
         y = 336,
         width = 24 * 11,
         height = 24,
         count_x = 11
      },
      tip_icons = {
         source = "interface.bmp",
         x = 96,
         y = 360,
         width = 24 * 8,
         height = 16,
         count_x = 8
      },
      deco_wear_a = {
         source = "deco_wear.bmp",
         x = 0,
         y = 0,
         width = 96,
         height = 120
      },
      deco_wear_b = {
         source = "deco_wear.bmp",
         x = 0,
         y = 120,
         width = 72,
         height = 144
      },
      radar_deco = {
         source = "interface.bmp",
         x = 64,
         y = 288,
         width = 50,
         height = 32
      },
      status_effect_bar = {
         source = "interface.bmp",
         x = 0,
         y = 416,
         width = 80,
         height = 15
      },
      ie_chat = {
         image = "ie_chat.bmp"
      },
      ie_sheet = {
         image = "ie_sheet.bmp",
      },
      ime_status_english = {
         source = "interface.bmp",
         x = 24,
         y = 336,
         width = 24,
         height = 24
      },
      ime_status_japanese = {
         source = "interface.bmp",
         x = 48,
         y = 336,
         width = 24,
         height = 24
      },
      ime_status_none = {
         source = "interface.bmp",
         x = 72,
         y = 336,
         width = 24,
         height = 24
      },
      window = {
         source = "interface.bmp",
         x = 0,
         y = 48,
         width = 264,
         height = 192,
         regions = gen_window_regions() -- ()
      },
      window_0 = {
         source = "interface.bmp",
         x = 0,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      window_1 = {
         source = "interface.bmp",
         x = 48,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      window_2 = {
         source = "interface.bmp",
         x = 96,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      window_3 = {
         source = "interface.bmp",
         x = 144,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      window_4 = {
         source = "interface.bmp",
         x = 192,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      window_5 = {
         source = "interface.bmp",
         x = 240,
         y = 240,
         width = 48,
         height = 48,
         regions = topic_window_regions
      },
      title = {
         image = "title.bmp",
         key_color = "none"
      },
      void = {
         image = "void.bmp",
         key_color = "none"
      },
      bg_night = {
         image = "bg_night.bmp"
      },
      g1 = {
         image = "g1.bmp",
      },
      g2 = {
         image = "g2.bmp",
      },
      g3 = {
         image = "g3.bmp",
      },
      g4 = {
         image = "g4.bmp",
      },
      select_key = {
         source = "interface.bmp",
         x = 0,
         y = 30,
         width = 24,
         height = 18,
      },
      list_bullet = {
         source = "interface.bmp",
         x = 48,
         y = 360,
         width = 16,
         height = 16
      },
      hp_bar_ally = {
         source = "interface.bmp",
         x = 432,
         y = 517,
         width = 48,
         height = 3
      },
      hp_bar_other = {
         source = "interface.bmp",
         x = 432,
         y = 513,
         width = 48,
         height = 3
      },
      shadow = {
         source = "interface.bmp",
         x = 0,
         y = 656,
         width = 24 * 8,
         height = 24 * 6,
         count_x = 8,
         count_y = 6,
         key_color = "none",
      },
      shadow_edges = {
         source = "interface.bmp",
         x = 192,
         y = 752,
         width = 48 * 17,
         height = 48,
         count_x = 17,
         key_color = "none",
      },
      character_shadow = {
         source = "interface.bmp",
         x = 240,
         y = 384,
         width = 32,
         height = 16
      },
      player_light = {
         source = "interface.bmp",
         x = 800,
         y = 112,
         width = 144,
         height = 144
      },
      failure_to_cast_effect = {
         source = "interface.bmp",
         x = 480,
         y = 0,
         width = 48,
         height = 48
      },
      swarm_effect = {
         source = "interface.bmp",
         x = 816,
         y = 0,
         width = 48,
         height = 48
      },
      breaking_effect = {
         source = "interface.bmp",
         x = 864,
         y = 0,
         width = 48,
         height = 48
      },
      melee_attack_debris = {
         source = "interface.bmp",
         x = 1104,
         y = 0,
         width = 48,
         height = 48
      },
      melee_attack_blood = {
         source = "interface.bmp",
         x = 720,
         y = 0,
         width = 48,
         height = 48
      },

      anim_slash = {
         source = "interface.bmp",
         x = 1008,
         y = 432,
         width = 48 * 4,
         height = 48,
         count_x = 4
      },

      anim_bash = {
         source = "interface.bmp",
         x = 816,
         y = 432,
         width = 48 * 4,
         height = 48,
         count_x = 4
      },

      anim_miracle = {
         image = "anime12.bmp",
         count_x = 10,
         count_y = 2,
         regions = {
            beam_1 = {0, 0, 96, 55},
            beam_2 = {96, 0, 96, 55},
            beam_3 = {288, 0, 96, 40}
         }
      },

      anim_spot_mine = {
         image = "anime1.bmp",
         count_x = 5
      },
      anim_spot_fish = {
         image = "anime2.bmp",
         count_x = 3
      },
      anim_spot_harvest = {
         image = "anime3.bmp",
         count_x = 3
      },
      anim_spot_dig = {
         image = "anime4.bmp",
         count_x = 4
      },
      anim_shock = {
         image = "anime6.bmp",
         count_x = 10
      },
      anim_breath = {
         image = "anime7.bmp",
         count_x = 10
      },
      anim_smoke = {
         image = "anime8.bmp",
         count_x = 5
      },
      anim_sparkle = {
         image = "anime10.bmp",
         count_x = 10
      },
      anim_buff = {
         image = "anime11.bmp",
         count_x = 5
      },
      anim_gene = {
         image = "anime13.bmp",
         count_x = 5,
         count_y = 2
      },
      anim_critical = {
         image = "anime28.bmp",
         count_x = 6
      },
      anim_curse = {
         image = "anime14.bmp",
         count_x = 5
      },
      anim_elec = {
         image = "anime15.bmp",
         count_x = 6
      },
      anim_flame = {
         image = "anime16.bmp",
         count_x = 10
      },
      anim_elem_lightning = {
         image = "anime18.bmp",
         count_x = 5
      },
      anim_elem_cold = {
         image = "anime19.bmp",
         count_x = 6
      },
      anim_elem_fire = {
         image = "anime20.bmp",
         count_x = 6
      },
      anim_elem_nether = {
         image = "anime21.bmp",
         count_x = 6
      },
      anim_elem_darkness = {
         image = "anime22.bmp",
         count_x = 6
      },
      anim_elem_mind = {
         image = "anime23.bmp",
         count_x = 6
      },
      anim_elem_sound = {
         image = "anime24.bmp",
         count_x = 6
      },
      anim_elem_chaos = {
         image = "anime25.bmp",
         count_x = 6
      },
      anim_elem_nerve = {
         image = "anime26.bmp",
         count_x = 6
      },
      anim_elem_poison = {
         image = "anime27.bmp",
         count_x = 6
      },

      light_port_light = {
         source = "interface.bmp",
         x = 192,
         y = 704,
         width = 48,
         height = 48
      },
      light_torch = {
         source = "interface.bmp",
         x = 240,
         y = 704,
         width = 48 * 2,
         height = 48,
         count_x = 2
      },
      light_lantern = {
         source = "interface.bmp",
         x = 336,
         y = 704,
         width = 48,
         height = 48
      },
      light_candle = {
         source = "interface.bmp",
         x = 384,
         y = 704,
         width = 48,
         height = 48
      },
      light_stove = {
         source = "interface.bmp",
         x = 432,
         y = 704,
         width = 48 * 2,
         height = 48,
         count_x = 2
      },
      light_item = {
         source = "interface.bmp",
         x = 528,
         y = 704,
         width = 48,
         height = 48
      },
      light_town = {
         source = "interface.bmp",
         x = 576,
         y = 704,
         width = 48,
         height = 48
      },
      light_crystal = {
         source = "interface.bmp",
         x = 624,
         y = 704,
         width = 48 * 2,
         height = 48,
         count_x = 2
      },
      light_town_light = {
         source = "interface.bmp",
         x = 720,
         y = 704,
         width = 48,
         height = 48
      },
      light_window = {
         source = "interface.bmp",
         x = 768,
         y = 704,
         width = 48,
         height = 48
      },
      light_window_red = {
         source = "interface.bmp",
         x = 816,
         y = 704,
         width = 48,
         height = 48
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

      repl_bg_color = {
         type = "color",
         color = {17, 17, 65, 192}
      },
      repl_error_color = {
         type = "color",
         color = {255, 0, 0}
      },
      repl_result_color = {
         type = "color",
         color = {150, 200, 200}
      },
      repl_completion_color = {
         type = "color",
         color = {255, 240, 130}
      },
      repl_search_color = {
         type = "color",
         color = {130, 240, 130}
      },
      repl_match_color = {
         type = "color",
         color = {17, 17, 200}
      }
   }
}
