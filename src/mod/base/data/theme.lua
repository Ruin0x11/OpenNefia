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

local assets = {
   {
      _id = "hud_minimap",
      source = "graphic/interface.bmp",
      x = 120,
      y = 504,
      width = 136,
      height = 88
   },
   {
      _id = "map_name_icon",
      source = "graphic/interface.bmp",
      x = 208,
      y = 376,
      width = 16,
      height = 16
   },
   {
      _id = "hud_bar",
      source = "graphic/interface.bmp",
      x = 0,
      y = 440,
      width = 192,
      height = 24,
   },
   {
      _id = "skill_icons",
      source = "graphic/item.bmp",
      x = 0,
      y = 672,
      width = 48 * 8,
      height = 48,
      count_x = 8
   },
   {
      _id = "hud_skill_icons",
      source = "graphic/interface.bmp",
      x = 0,
      y = 376,
      width = 16 * 10,
      height = 16,
      count_x = 10
   },
   {
      _id = "message_window",
      source = "graphic/interface.bmp",
      x = 496,
      y = 528,
      width = 192,
      height = 72,
      regions = {
         window_title = { 0, 53, 192, 18 }
      }
   },
   {
      _id = "gold_coin",
      source = "graphic/interface.bmp",
      x = 0,
      y = 392,
      width = 24,
      height = 24
   },
   {
      _id = "platinum_coin",
      source = "graphic/interface.bmp",
      x = 24,
      y = 392,
      width = 24,
      height = 24
   },
   {
      _id = "character_level_icon",
      source = "graphic/interface.bmp",
      x = 48,
      y = 392,
      width = 24,
      height = 24
   },
   {
      _id = "hp_bar_frame",
      source = "graphic/interface.bmp",
      x = 312,
      y = 504,
      width = 104,
      height = 15
   },
   {
      _id = "hud_hp_bar",
      source = "graphic/interface.bmp",
      x = 312,
      y = 520,
      width = 100,
      height = 6
   },
   {
      _id = "hud_mp_bar",
      source = "graphic/interface.bmp",
      x = 432,
      y = 520,
      width = 100,
      height = 6
   },
   {
      _id = "clock",
      source = "graphic/interface.bmp",
      x = 448,
      y = 408,
      width = 120,
      height = 96
   },
   {
      _id = "clock_hand",
      source = "graphic/interface.bmp",
      x = 0,
      y = 288,
      width = 48,
      height = 48
   },
   {
      _id = "date_label_frame",
      source = "graphic/interface.bmp",
      x = 448,
      y = 376,
      width = 128,
      height = 24
   },
   {
      _id = "book",
      image = "graphic/book.bmp",
   },
   {
      _id = "deco_inv_a",
      source = "graphic/deco_inv.bmp",
      x = 0,
      y = 0,
      width = 144,
      height = 48
   },
   {
      _id = "deco_inv_b",
      source = "graphic/deco_inv.bmp",
      x = 0,
      y = 48,
      width = 48,
      height = 72
   },
   {
      _id = "deco_inv_c",
      source = "graphic/deco_inv.bmp",
      x = 48,
      y = 48,
      width = 48,
      height = 72
   },
   {
      _id = "deco_inv_d",
      source = "graphic/deco_inv.bmp",
      x = 0,
      y = 120,
      width = 48,
      height = 72
   },
   {
      _id = "deco_mirror_a",
      source = "graphic/deco_mirror.bmp",
      x = 0,
      y = 0,
      width = 48,
      height = 120
   },
   {
      _id = "deco_feat_a",
      source = "graphic/deco_feat.bmp",
      x = 0,
      y = 0,
      width = 48,
      height = 192
   },
   {
      _id = "deco_feat_b",
      source = "graphic/deco_feat.bmp",
      x = 48,
      y = 0,
      width = 48,
      height = 144
   },
   {
      _id = "deco_feat_c",
      source = "graphic/deco_feat.bmp",
      x = 0,
      y = 192,
      width = 96,
      height = 72
   },
   {
      _id = "deco_feat_d",
      source = "graphic/deco_feat.bmp",
      x = 48,
      y = 144,
      width = 96,
      height = 48
   },
   {
      _id = "deco_board_a",
      source = "graphic/deco_board.bmp",
      x = 0,
      y = 0,
      width = 128,
      height = 128
   },
   {
      _id = "deco_board_b",
      source = "graphic/deco_board.bmp",
      x = 0,
      y = 144,
      width = 48,
      height = 84
   },
   {
      _id = "deco_spell_a",
      source = "graphic/deco_spell.bmp",
      x = 0,
      y = 0,
      width = 72,
      height = 144
   },
   {
      _id = "deco_spell_b",
      source = "graphic/deco_spell.bmp",
      x = 72,
      y = 0,
      width = 72,
      height = 96
   },
   {
      _id = "deco_skill_a",
      source = "graphic/deco_skill.bmp",
      x = 0,
      y = 0,
      width = 72,
      height = 144
   },
   {
      _id = "deco_skill_b",
      source = "graphic/deco_skill.bmp",
      x = 72,
      y = 0,
      width = 102,
      height = 48
   },
   {
      _id = "inventory_icons",
      source = "graphic/interface.bmp",
      x = 288,
      y = 48,
      width = 48 * 22,
      height = 48,
      count_x = 22
   },
   {
      _id = "trait_icons",
      source = "graphic/interface.bmp",
      x = 384,
      y = 336,
      width = 24 * 6,
      height = 24,
      count_x = 6
   },
   {
      _id = "equipped_icon",
      source = "graphic/interface.bmp",
      x = 12,
      y = 348,
      width = 12,
      height = 12
   },
   {
      _id = "label_input",
      source = "graphic/interface.bmp",
      x = 128,
      y = 288,
      width = 128,
      height = 32
   },
   {
      _id = "input_caret",
      source = "graphic/interface.bmp",
      x = 0,
      y = 336,
      width = 12,
      height = 24
   },
   {
      _id = "buff_icon",
      source = "graphic/character.bmp",
      x = 0,
      y = 1120,
      width = 32 * 19,
      height = 32,
      count_x = 19
   },
   {
      _id = "buff_icon_none",
      source = "graphic/interface.bmp",
      x = 320,
      y = 160,
      width = 32,
      height = 32
   },
   {
      _id = "arrow_left",
      source = "graphic/interface.bmp",
      x = 312,
      y = 336,
      width = 24,
      height = 24
   },
   {
      _id = "arrow_right",
      source = "graphic/interface.bmp",
      x = 336,
      y = 336,
      width = 24,
      height = 24
   },
   {
      _id = "direction_arrow",
      source = "graphic/interface.bmp",
      x = 212,
      y = 432,
      width = 28,
      height = 28
   },
   {
      _id = "caption",
      source = "graphic/interface.bmp",
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
   {
      _id = "enchantment_icons",
      source = "graphic/interface.bmp",
      x = 72,
      y = 336,
      width = 24 * 9,
      height = 24,
      count_x = 9
   },
   {
      _id = "inheritance_icon",
      source = "graphic/interface.bmp",
      x = 384,
      y = 360,
      width = 24,
      height = 24
   },
   {
      _id = "body_part_icons",
      source = "graphic/interface.bmp",
      x = 600,
      y = 336,
      width = 24 * 11,
      height = 24,
      count_x = 11
   },
   {
      _id = "tip_icons",
      source = "graphic/interface.bmp",
      x = 96,
      y = 360,
      width = 24 * 8,
      height = 16,
      count_x = 8
   },
   {
      _id = "deco_wear_a",
      source = "graphic/deco_wear.bmp",
      x = 0,
      y = 0,
      width = 96,
      height = 120
   },
   {
      _id = "deco_wear_b",
      source = "graphic/deco_wear.bmp",
      x = 0,
      y = 120,
      width = 72,
      height = 144
   },
   {
      _id = "radar_deco",
      source = "graphic/interface.bmp",
      x = 64,
      y = 288,
      width = 50,
      height = 32
   },
   {
      _id = "status_effect_bar",
      source = "graphic/interface.bmp",
      x = 0,
      y = 416,
      width = 80,
      height = 15
   },
   {
      _id = "ie_chat",
      image = "graphic/ie_chat.bmp"
   },
   {
      _id = "ie_sheet",
      image = "graphic/ie_sheet.bmp",
   },
   {
      _id = "ime_status_english",
      source = "graphic/interface.bmp",
      x = 24,
      y = 336,
      width = 24,
      height = 24
   },
   {
      _id = "ime_status_japanese",
      source = "graphic/interface.bmp",
      x = 48,
      y = 336,
      width = 24,
      height = 24
   },
   {
      _id = "ime_status_none",
      source = "graphic/interface.bmp",
      x = 72,
      y = 336,
      width = 24,
      height = 24
   },
   {
      _id = "more_prompt",
      source = "graphic/interface.bmp",
      x = 552,
      y = 504,
      width = 120,
      height = 22
   },
   {
      _id = "window",
      source = "graphic/interface.bmp",
      x = 0,
      y = 48,
      width = 264,
      height = 192,
      regions = gen_window_regions() -- ()
   },
   {
      _id = "window_0",
      source = "graphic/interface.bmp",
      x = 0,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "window_1",
      source = "graphic/interface.bmp",
      x = 48,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "window_2",
      source = "graphic/interface.bmp",
      x = 96,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "window_3",
      source = "graphic/interface.bmp",
      x = 144,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "window_4",
      source = "graphic/interface.bmp",
      x = 192,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "window_5",
      source = "graphic/interface.bmp",
      x = 240,
      y = 240,
      width = 48,
      height = 48,
      regions = topic_window_regions
   },
   {
      _id = "title",
      image = "graphic/title.bmp",
      key_color = "none"
   },
   {
      _id = "void",
      image = "graphic/void.bmp",
      key_color = "none"
   },
   {
      _id = "bg_night",
      image = "graphic/bg_night.bmp"
   },
   {
      _id = "g1",
      image = "graphic/g1.bmp",
   },
   {
      _id = "g2",
      image = "graphic/g2.bmp",
   },
   {
      _id = "g3",
      image = "graphic/g3.bmp",
   },
   {
      _id = "g4",
      image = "graphic/g4.bmp",
   },
   {
      _id = "bg1",
      image = "graphic/bg1.bmp",
      key_color = "none"
   },
   {
      _id = "bg2",
      image = "graphic/bg2.bmp",
      key_color = "none"
   },
   {
      _id = "bg3",
      image = "graphic/bg3.bmp",
      key_color = "none"
   },
   {
      _id = "bg4",
      image = "graphic/bg4.bmp",
      key_color = "none"
   },
   {
      _id = "bg5",
      image = "graphic/bg5.bmp",
      key_color = "none"
   },
   {
      _id = "bg6",
      image = "graphic/bg6.bmp",
      key_color = "none"
   },
   {
      _id = "bg7",
      image = "graphic/bg7.bmp",
      key_color = "none"
   },
   {
      _id = "bg8",
      image = "graphic/bg8.bmp",
      key_color = "none"
   },
   {
      _id = "bg9",
      image = "graphic/bg9.bmp",
      key_color = "none"
   },
   {
      _id = "bg10",
      image = "graphic/bg10.bmp",
      key_color = "none"
   },
   {
      _id = "bg11",
      image = "graphic/bg11.bmp",
      key_color = "none"
   },
   {
      _id = "bg12",
      image = "graphic/bg12.bmp",
      key_color = "none"
   },
   {
      _id = "bg13",
      image = "graphic/bg13.bmp",
      key_color = "none"
   },
   {
      _id = "select_key",
      source = "graphic/interface.bmp",
      x = 0,
      y = 30,
      width = 24,
      height = 18,
   },
   {
      _id = "list_bullet",
      source = "graphic/interface.bmp",
      x = 48,
      y = 360,
      width = 16,
      height = 16
   },
   {
      _id = "hp_bar_ally",
      source = "graphic/interface.bmp",
      x = 432,
      y = 517,
      width = 48,
      height = 3
   },
   {
      _id = "hp_bar_other",
      source = "graphic/interface.bmp",
      x = 432,
      y = 513,
      width = 48,
      height = 3
   },
   {
      _id = "shadow",
      source = "graphic/interface.bmp",
      x = 0,
      y = 656,
      width = 24 * 8,
      height = 24 * 6,
      count_x = 8,
      count_y = 6,
      key_color = "none",
   },
   {
      _id = "shadow_edges",
      source = "graphic/interface.bmp",
      x = 192,
      y = 752,
      width = 48 * 17,
      height = 48,
      count_x = 17,
      key_color = "none",
   },
   {
      _id = "character_shadow",
      source = "graphic/interface.bmp",
      x = 240,
      y = 384,
      width = 32,
      height = 16
   },
   {
      _id = "player_light",
      source = "graphic/interface.bmp",
      x = 800,
      y = 112,
      width = 144,
      height = 144
   },
   {
      _id = "scene_text_shadow",
      source = "graphic/interface.bmp",
      x = 456,
      y = 144,
      width = 344,
      height = 72
   },
   {
      _id = "failure_to_cast_effect",
      source = "graphic/item.bmp",
      x = 480,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "swarm_effect",
      source = "graphic/item.bmp",
      x = 816,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "heal_effect",
      source = "graphic/item.bmp",
      x = 48 * 7,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "curse_effect",
      source = "graphic/item.bmp",
      x = 48 * 8,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "offer_effect",
      source = "graphic/item.bmp",
      x = 48 * 9,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "breaking_effect",
      source = "graphic/item.bmp",
      x = 864,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "melee_attack_debris",
      source = "graphic/item.bmp",
      x = 1104,
      y = 0,
      width = 48,
      height = 48
   },
   {
      _id = "melee_attack_blood",
      source = "graphic/item.bmp",
      x = 720,
      y = 0,
      width = 48,
      height = 48
   },

   {
      _id = "anim_slash",
      source = "graphic/interface.bmp",
      x = 1008,
      y = 432,
      width = 48 * 4,
      height = 48,
      count_x = 4
   },

   {
      _id = "anim_bash",
      source = "graphic/interface.bmp",
      x = 816,
      y = 432,
      width = 48 * 4,
      height = 48,
      count_x = 4
   },

   {
      _id = "anim_miracle",
      image = "graphic/anime12.bmp",
      count_x = 10,
      count_y = 2,
      regions = {
         beam_1 = {0, 0, 96, 55},
         beam_2 = {96, 0, 96, 55},
         beam_3 = {288, 0, 96, 40}
      }
   },

   {
      _id = "anim_spot_mine",
      image = "graphic/anime1.bmp",
      count_x = 5
   },
   {
      _id = "anim_spot_fish",
      image = "graphic/anime2.bmp",
      count_x = 3
   },
   {
      _id = "anim_spot_harvest",
      image = "graphic/anime3.bmp",
      count_x = 3
   },
   {
      _id = "anim_spot_dig",
      image = "graphic/anime4.bmp",
      count_x = 4
   },
   {
      _id = "anim_ball",
      source = "graphic/anime5.bmp",
      count_x = 10,
      x = 0,
      y = 0,
      width = 96 * 10,
      height = 96,
   },
   {
      _id = "anim_ball_2",
      source = "graphic/anime5.bmp",
      count_x = 10,
      x = 0,
      y = 96,
      width = 48 * 10,
      height = 96,
   },
   {
      _id = "anim_shock",
      image = "graphic/anime6.bmp",
      count_x = 10
   },
   {
      _id = "anim_breath",
      image = "graphic/anime7.bmp",
      count_x = 10
   },
   {
      _id = "anim_smoke",
      image = "graphic/anime8.bmp",
      count_x = 5
   },
   {
      _id = "anim_sparkle",
      image = "graphic/anime10.bmp",
      count_x = 10
   },
   {
      _id = "anim_buff",
      image = "graphic/anime11.bmp",
      count_x = 5
   },
   {
      _id = "anim_gene",
      image = "graphic/anime13.bmp",
      count_x = 5,
      count_y = 2
   },
   {
      _id = "anim_critical",
      image = "graphic/anime28.bmp",
      count_x = 6
   },
   {
      _id = "anim_curse",
      image = "graphic/anime14.bmp",
      count_x = 5
   },
   {
      _id = "anim_elec",
      image = "graphic/anime15.bmp",
      count_x = 6
   },
   {
      _id = "anim_flame",
      image = "graphic/anime16.bmp",
      count_x = 10
   },
   {
      _id = "anim_elem_lightning",
      image = "graphic/anime18.bmp",
      count_x = 5
   },
   {
      _id = "anim_elem_cold",
      image = "graphic/anime19.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_fire",
      image = "graphic/anime20.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_nether",
      image = "graphic/anime21.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_darkness",
      image = "graphic/anime22.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_mind",
      image = "graphic/anime23.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_sound",
      image = "graphic/anime24.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_chaos",
      image = "graphic/anime25.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_nerve",
      image = "graphic/anime26.bmp",
      count_x = 6
   },
   {
      _id = "anim_elem_poison",
      image = "graphic/anime27.bmp",
      count_x = 6
   },

   {
      _id = "light_port_light",
      source = "graphic/interface.bmp",
      x = 192,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_torch",
      source = "graphic/interface.bmp",
      x = 240,
      y = 704,
      width = 48 * 2,
      height = 48,
      count_x = 2
   },
   {
      _id = "light_lantern",
      source = "graphic/interface.bmp",
      x = 336,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_candle",
      source = "graphic/interface.bmp",
      x = 384,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_stove",
      source = "graphic/interface.bmp",
      x = 432,
      y = 704,
      width = 48 * 2,
      height = 48,
      count_x = 2
   },
   {
      _id = "light_item",
      source = "graphic/interface.bmp",
      x = 528,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_town",
      source = "graphic/interface.bmp",
      x = 576,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_crystal",
      source = "graphic/interface.bmp",
      x = 624,
      y = 704,
      width = 48 * 2,
      height = 48,
      count_x = 2
   },
   {
      _id = "light_town_light",
      source = "graphic/interface.bmp",
      x = 720,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_window",
      source = "graphic/interface.bmp",
      x = 768,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "light_window_red",
      source = "graphic/interface.bmp",
      x = 816,
      y = 704,
      width = 48,
      height = 48
   },
   {
      _id = "attribute_font",
      type = "font",
      size = 13
   },
   {
      _id = "map_name_font",
      type = "font",
      size = 12
   },
   {
      _id = "gold_count_font",
      type = "font",
      size = 13
   },
   {
      _id = "status_indicator_font",
      type = "font",
      size = 13 -- 13 - en * 2
   },

   {
      _id = "text_color",
      type = "color",
      color = {0, 0, 0}
   },
   {
      _id = "text_color_light",
      type = "color",
      color = {255, 255, 255}
   },
   {
      _id = "text_color_light_shadow",
      type = "color",
      color = {0, 0, 0}
   },

   {
      _id = "stat_penalty_color",
      type = "color",
      color = {200, 0, 0}
   },
   {
      _id = "stat_bonus_color",
      type = "color",
      color = {0, 120, 0}
   },

   {
      _id = "repl_bg_color",
      type = "color",
      color = {17, 17, 65, 192}
   },
   {
      _id = "repl_error_color",
      type = "color",
      color = {255, 0, 0}
   },
   {
      _id = "repl_result_color",
      type = "color",
      color = {150, 200, 200}
   },
   {
      _id = "repl_preview_color",
      type = "color",
      color = {100, 150, 150}
   },
   {
      _id = "repl_completion_color",
      type = "color",
      color = {255, 240, 130}
   },
   {
      _id = "repl_search_color",
      type = "color",
      color = {130, 240, 130}
   },
   {
      _id = "repl_match_color",
      type = "color",
      color = {17, 17, 200}
   }
}
data:add_multi("base.asset", assets)

data:add {
   _type = "base.theme",
   _id = "default",

   assets = {}
}
