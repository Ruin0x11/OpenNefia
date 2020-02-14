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

data:add_multi(
"base.asset",
{
    {
        _id = "hud_minimap",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 120,
            y = 504,
            width = 136,
            height = 88
        }
    },
    {
        _id = "map_name_icon",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 208,
            y = 376,
            width = 16,
            height = 16
        }
    },
    {
        _id = "hud_bar",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 0,
            width = 0,
            height = 0
        }
    },
    {
        _id = "skill_icons",
        image = {
            source = "mod/elona/graphic/item.bmp",
            x = 0,
            y = 672,
            width = 48 * 8,
            height = 48
        },
        count_x = 8
    },
    {
        _id = "hud_skill_icons",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 376,
            width = 16 * 10,
            height = 16
        },
        count_x = 10
    },
    {
        _id = "message_window",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 496,
            y = 528,
            width = 192,
            height = 72
        }
    },
    {
        _id = "gold_coin",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 392,
            width = 24,
            height = 24
        }
    },
    {
        _id = "platinum_coin",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 24,
            y = 392,
            width = 24,
            height = 24
        }
    },
    {
        _id = "character_level_icon",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 48,
            y = 392,
            width = 24,
            height = 24
        }
    },
    {
        _id = "hp_bar_frame",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 312,
            y = 504,
            width = 104,
            height = 15
        }
    },
    {
        _id = "hud_hp_bar",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 312,
            y = 520,
            width = 100,
            height = 6
        }
    },
    {
        _id = "hud_mp_bar",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 432,
            y = 520,
            width = 100,
            height = 6
        }
    },
    {
        _id = "clock",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 448,
            y = 408,
            width = 120,
            height = 96
        }
    },
    {
        _id = "clock_hand",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 288,
            width = 48,
            height = 48
        }
    },
    {
        _id = "date_label_frame",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 448,
            y = 376,
            width = 128,
            height = 24
        }
    },
    {
        _id = "book",
        image = "mod/elona/graphic/book.bmp",
    },
    {
        _id = "deco_inv_a",
        image = {
            source = "mod/elona/graphic/deco_inv.bmp",
            x = 0,
            y = 0,
            width = 144,
            height = 48
        }
    },
    {
        _id = "deco_inv_b",
        image = {
            source = "mod/elona/graphic/deco_inv.bmp",
            x = 0,
            y = 48,
            width = 48,
            height = 72
        }
    },
    {
        _id = "deco_inv_c",
        image = {
            source = "mod/elona/graphic/deco_inv.bmp",
            x = 48,
            y = 48,
            width = 48,
            height = 72
        }
    },
    {
        _id = "deco_inv_d",
        image = {
            source = "mod/elona/graphic/deco_inv.bmp",
            x = 0,
            y = 120,
            width = 48,
            height = 72
        }
    },
    {
        _id = "deco_mirror_a",
        image = {
            source = "mod/elona/graphic/deco_mirror.bmp",
            x = 0,
            y = 0,
            width = 48,
            height = 120
        }
    },
    {
        _id = "deco_feat_a",
        image = {
            source = "mod/elona/graphic/deco_feat.bmp",
            x = 0,
            y = 0,
            width = 48,
            height = 192
        }
    },
    {
        _id = "deco_feat_b",
        image = {
            source = "mod/elona/graphic/deco_feat.bmp",
            x = 48,
            y = 0,
            width = 48,
            height = 144
        }
    },
    {
        _id = "deco_feat_c",
        image = {
            source = "mod/elona/graphic/deco_feat.bmp",
            x = 0,
            y = 192,
            width = 96,
            height = 72
        }
    },
    {
        _id = "deco_feat_d",
        image = {
            source = "mod/elona/graphic/deco_feat.bmp",
            x = 48,
            y = 144,
            width = 96,
            height = 48
        }
    },
    {
        _id = "deco_board_a",
        image = {
            source = "mod/elona/graphic/deco_board.bmp",
            x = 0,
            y = 0,
            width = 128,
            height = 128
        }
    },
    {
        _id = "deco_board_b",
        image = {
            source = "mod/elona/graphic/deco_board.bmp",
            x = 0,
            y = 144,
            width = 48,
            height = 84
        }
    },
    {
        _id = "inventory_icons",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 288,
            y = 48,
            width = 48 * 22,
            height = 48
        },
        count_x = 22
    },
    {
        _id = "trait_icons",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 384,
            y = 336,
            width = 24 * 6,
            height = 24
        },
        count_x = 6
    },
    {
        _id = "equipped_icon",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 12,
            y = 348,
            width = 12,
            height = 12
        }
    },
    {
        _id = "label_input",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 128,
            y = 288,
            width = 128,
            height = 32
        }
    },
    {
        _id = "input_caret",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 336,
            width = 12,
            height = 24
        }
    },
    {
        _id = "buff_icon",
        image = {
            source = "mod/elona/graphic/character.bmp",
            x = 0,
            y = 1120,
            width = 32 * 19,
            height = 32
        },
        count_x = 19
    },
    {
        _id = "buff_icon_none",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 320,
            y = 160,
            width = 32,
            height = 32
        }
    },
    {
        _id = "arrow_left",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 312,
            y = 336,
            width = 24,
            height = 24
        }
    },
    {
        _id = "arrow_right",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 336,
            y = 336,
            width = 24,
            height = 24
        }
    },
    {
        _id = "direction_arrow",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 212,
            y = 432,
            width = 28,
            height = 28
        }
    },
    {
        _id = "caption",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 672,
            y = 477,
            width = 128,
            height = 25
        },
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
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 72,
            y = 336,
            width = 24 * 9,
            height = 24
        },
        count_x = 9
    },
    {
        _id = "inheritance_icon",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 384,
            y = 360,
            width = 24,
            height = 24
        }
    },
    {
        _id = "body_part_icons",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 600,
            y = 336,
            width = 24 * 11,
            height = 24
        },
        count_x = 11
    },
    {
        _id = "tip_icons",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 96,
            y = 360,
            width = 24 * 8,
            height = 16
        },
        count_x = 8
    },
    {
        _id = "deco_wear_a",
        image = {
            source = "mod/elona/graphic/deco_wear.bmp",
            x = 0,
            y = 0,
            width = 96,
            height = 120
        }
    },
    {
        _id = "deco_wear_b",
        image = {
            source = "mod/elona/graphic/deco_wear.bmp",
            x = 0,
            y = 120,
            width = 72,
            height = 144
        }
    },
    {
        _id = "radar_deco",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 64,
            y = 288,
            width = 50,
            height = 32
        }
    },
    {
        _id = "status_effect_bar",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 416,
            width = 80,
            height = 15
        }
    },
    {
        _id = "ie_chat",
        image = "mod/elona/graphic/ie_chat.bmp"
    },
    {
        _id = "ie_sheet",
        image = "mod/elona/graphic/ie_sheet.bmp",
    },
    {
        _id = "ime_status_english",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 24,
            y = 336,
            width = 24,
            height = 24
        }
    },
    {
        _id = "ime_status_japanese",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 48,
            y = 336,
            width = 24,
            height = 24
        }
    },
    {
        _id = "ime_status_none",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 72,
            y = 336,
            width = 24,
            height = 24
        }
    },
    {
        _id = "window",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 48,
            width = 264,
            height = 192
        },
        regions = gen_window_regions() -- ()
    },
    {
        _id = "window_0",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "window_1",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 48,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "window_2",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 96,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "window_3",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 144,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "window_4",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 192,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "window_5",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 240,
            y = 240,
            width = 48,
            height = 48
        },
        regions = topic_window_regions
    },
    {
        _id = "topic_window",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 0,
            width = 0,
            height = 0
        },
        regions = {
            fill = { 24, 24, 228, 144 }
        }
    },
    {
        _id = "title",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 0,
            width = 0,
            height = 0
        }
    },
    {
        _id = "void",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 0,
            width = 0,
            height = 0
        }
    },
    {
        _id = "bg_night",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 0,
            width = 0,
            height = 0
        }
    },
    {
        _id = "g1",
        image = "mod/elona/graphic/mod/elona/graphic/asset/g1.png",
    },
    {
        _id = "g2",
        image = "mod/elona/graphic/mod/elona/graphic/asset/g2.png",
    },
    {
        _id = "g3",
        image = "mod/elona/graphic/mod/elona/graphic/asset/g3.png",
    },
    {
        _id = "g4",
        image = "mod/elona/graphic/mod/elona/graphic/asset/g4.png",
    },
    {
        _id = "select_key",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 1000,
            y = 1000,
            width = 24,
            height = 18
        }
    },
    {
        _id = "list_bullet",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 48,
            y = 360,
            width = 16,
            height = 16
        }
    },
    {
        _id = "hp_bar_ally",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 432,
            y = 517,
            width = 48,
            height = 3
        }
    },
    {
        _id = "hp_bar_other",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 432,
            y = 513,
            width = 48,
            height = 3
        }
    },
    {
        _id = "shadow",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 0,
            y = 656,
            width = 24,
            height = 24
        }
    },
    {
        _id = "shadow_edges",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 192,
            y = 752,
            width = 48,
            height = 48
        }
    },
    {
        _id = "character_shadow",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 240,
            y = 384,
            width = 32,
            height = 16
        }
    },
    {
        _id = "player_light",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 800,
            y = 112,
            width = 144,
            height = 144
        }
    },
    {
        _id = "failure_to_cast_effect",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 480,
            y = 0,
            width = 48,
            height = 48
        }
    },
    {
        _id = "swarm_effect",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 816,
            y = 0,
            width = 48,
            height = 48
        }
    },
    {
        _id = "breaking_effect",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 864,
            y = 0,
            width = 48,
            height = 48
        }
    },
    {
        _id = "melee_attack_debris",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 1104,
            y = 0,
            width = 48,
            height = 48
        }
    },
    {
        _id = "melee_attack_blood",
        image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 720,
            y = 0,
            width = 48,
            height = 48
        }
    },

      {
         _id = "anim_slash",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 1008,
            y = 432,
            width = 48 * 4,
            height = 48
         },
         count_x = 4
      },

      {
         _id = "anim_bash",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 816,
            y = 432,
            width = 48 * 4,
            height = 48
         },
         count_x = 4
      },

      {
         _id = "anim_miracle",
         image = "mod/elona/graphic/anime12.bmp",
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
         image = "mod/elona/graphic/anime1.bmp",
         count_x = 5
      },
      {
         _id = "anim_spot_fish",
         image = "mod/elona/graphic/anime2.bmp",
         count_x = 3
      },
      {
         _id = "anim_spot_harvest",
         image = "mod/elona/graphic/anime3.bmp",
         count_x = 3
      },
      {
         _id = "anim_spot_dig",
         image = "mod/elona/graphic/anime4.bmp",
         count_x = 4
      },
      {
         _id = "anim_shock",
         image = "mod/elona/graphic/anime6.bmp",
         count_x = 10
      },
      {
         _id = "anim_breath",
         image = "mod/elona/graphic/anime7.bmp",
         count_x = 10
      },
      {
         _id = "anim_smoke",
         image = "mod/elona/graphic/anime8.bmp",
         count_x = 5
      },
      {
         _id = "anim_sparkle",
         image = "mod/elona/graphic/anime10.bmp",
         count_x = 10
      },
      {
         _id = "anim_buff",
         image = "mod/elona/graphic/anime11.bmp",
         count_x = 5
      },
      {
         _id = "anim_gene",
         image = "mod/elona/graphic/anime13.bmp",
         count_x = 5,
         count_y = 2
      },
      {
         _id = "anim_critical",
         image = "mod/elona/graphic/anime28.bmp",
         count_x = 6
      },
      {
         _id = "anim_curse",
         image = "mod/elona/graphic/anime14.bmp",
         count_x = 5
      },
      {
         _id = "anim_elec",
         image = "mod/elona/graphic/anime15.bmp",
         count_x = 6
      },
      {
         _id = "anim_flame",
         image = "mod/elona/graphic/anime16.bmp",
         count_x = 10
      },
      {
         _id = "anim_elem_lightning",
         image = "mod/elona/graphic/anime18.bmp",
         count_x = 5
      },
      {
         _id = "anim_elem_cold",
         image = "mod/elona/graphic/anime19.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_fire",
         image = "mod/elona/graphic/anime20.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_nether",
         image = "mod/elona/graphic/anime21.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_darkness",
         image = "mod/elona/graphic/anime22.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_mind",
         image = "mod/elona/graphic/anime23.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_sound",
         image = "mod/elona/graphic/anime24.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_chaos",
         image = "mod/elona/graphic/anime25.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_nerve",
         image = "mod/elona/graphic/anime26.bmp",
         count_x = 6
      },
      {
         _id = "anim_elem_poison",
         image = "mod/elona/graphic/anime27.bmp",
         count_x = 6
      },

      {
         _id = "light_port_light",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 192,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_torch",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 240,
            y = 704,
            width = 48 * 2,
            height = 48
         },
         count_x = 2
      },
      {
         _id = "light_lantern",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 336,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_candle",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 384,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_stove",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 432,
            y = 704,
            width = 48 * 2,
            height = 48
         },
         count_x = 2
      },
      {
         _id = "light_item",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 528,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_town",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 576,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_crystal",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 624,
            y = 704,
            width = 48 * 2,
            height = 48
         },
         count_x = 2
      },
      {
         _id = "light_town_light",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 720,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_window",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 768,
            y = 704,
            width = 48,
            height = 48
         }
      },
      {
         _id = "light_window_red",
         image = {
            source = "mod/elona/graphic/interface.bmp",
            x = 816,
            y = 704,
            width = 48,
            height = 48
         }
      },
   }
)

data:add_multi(
   "base.asset",
   {
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
)

data:add {
   _type = "base.theme",
   _id = "default",

   root = "mod/elona/graphic",
   assets = {
      elona = {
      }
   }
}
