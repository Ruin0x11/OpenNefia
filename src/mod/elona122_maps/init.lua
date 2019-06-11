-- Map chips which are exactly the same in image and parameters between atlases 1 and 2.

local same = {
   0, 6, 10, 11, 19, 45, 47, 48, 49, 50,
   66, 67, 68, 69, 70, 71, 72, 73, 74, 75,
   76, 77, 78, 79, 80, 81, 99, 100, 101, 102,
   103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
   113, 114, 115, 116, 117, 118, 132, 133, 134, 135,
   136, 137, 138, 139, 140, 141, 142, 143, 144, 145,
   146, 147, 148, 149, 150, 151, 165, 166, 167, 168,
   169, 170, 171, 172, 173, 198, 199, 200, 201, 202,
   203, 204, 205, 206, 207, 208, 209, 211, 212, 213,
   214, 215, 216, 217, 264, 266, 267, 268, 269, 270,
   271, 272, 273, 274, 276, 277, 278, 279, 280, 281,
   282, 283, 302, 303, 304, 305, 306, 307, 308, 309,
   310, 311, 312, 313, 314, 315, 316, 330, 331, 332,
   336, 340, 341, 343, 344, 345, 346, 363, 364, 365,
   366, 367, 368, 369, 370, 371, 372, 373, 374, 375,
   376, 377, 378, 379, 380, 381, 382, 396, 397, 398,
   414, 415, 416, 417, 418, 419, 420, 421, 422, 423,
   424, 425, 426, 427, 428, 429, 430, 431, 447, 448,
   449, 450, 451, 452, 453, 454, 455, 456, 457, 458,
   459, 460, 461, 462, 463, 465, 466, 467, 468, 469,
   470, 471, 472, 473, 474, 475, 477, 478, 479, 480,
   481, 482, 483, 484, 485, 486, 487, 488, 489, 490,
   491, 492, 495, 496, 497, 498, 499, 500, 501, 502,
   503, 504, 505, 506, 507, 508, 510, 511, 512, 513,
   514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
   524, 525, 528, 529, 530, 532, 533, 534, 535, 536,
   537, 538, 539, 540, 541, 542, 545, 546, 547, 548,
   549, 550, 551, 552, 553, 554, 555, 556, 557, 558,
   561, 562, 563, 570, 571, 573, 578, 579, 580, 581,
   582, 583, 584, 585, 586, 587, 588, 589, 590, 591,
   592, 593, 594, 595, 596, 597, 598, 599, 600, 601,
   602, 603, 604, 605, 606, 607, 608, 609, 610, 611,
   612, 613, 614, 615, 616, 617, 618, 619, 620, 621,
   622, 623, 624, 625, 626, 631, 632, 633, 634, 639,
   640, 642, 643, 644, 645, 646, 647, 648, 649, 650,
   651, 652, 653, 654, 655, 656, 657, 658, 659, 660,
   661, 662, 663, 664, 665, 666, 670, 671, 672, 673,
   674, 675, 676, 677, 678, 679, 680, 681, 682, 683,
   684, 685, 686, 687, 688, 689, 690, 691, 693, 694,
   695, 696, 697, 698, 699, 700, 701, 702, 703, 704,
   705, 706, 707, 708, 709, 710, 711, 712, 713, 714,
   715, 716, 717, 718, 719, 720, 721, 722, 757, 758,
   759, 760, 761, 762, 763, 764, 765, 767, 768, 769,
   770, 771, 772, 773, 774, 775, 776, 777, 778, 779,
   780, 781, 782, 783, 784, 785, 786, 787, 788, 789,
   790, 791, 792, 793, 794, 795, 796, 797, 798, 799,
   800, 801, 802, 803, 804, 805, 806, 807, 808, 809,
   810, 811, 812, 813, 814, 815, 816, 817, 818, 819,
   820, 821, 822, 823, 824
}

local feat_chips  = {
   {
      _id = "1_231",
      id = "1_231",
      image = "graphic/temp/map_tile/1_231.png",
      is_feat = true
   },
   {
      _id = "1_232",
      id = "1_232",
      image = "graphic/temp/map_tile/1_232.png",
      is_feat = true
   },
   {
      _id = "1_233",
      id = "1_233",
      image = "graphic/temp/map_tile/1_233.png",
      is_feat = true,
      offset_bottom = 48,
      offset_top = 56
   },
   {
      _id = "1_234",
      id = "1_234",
      image = "graphic/temp/map_tile/1_234.png",
      is_feat = true
   },
   {
      _id = "1_235",
      id = "1_235",
      image = "graphic/temp/map_tile/1_235.png",
      is_feat = true
   },
   {
      _id = "1_236",
      id = "1_236",
      image = "graphic/temp/map_tile/1_236.png",
      is_feat = true
   },
   {
      _id = "1_237",
      id = "1_237",
      image = "graphic/temp/map_tile/1_237.png",
      is_feat = true
   },
   {
      _id = "1_238",
      id = "1_238",
      image = "graphic/temp/map_tile/1_238.png",
      is_feat = true
   },
   {
      _id = "1_239",
      id = "1_239",
      image = "graphic/temp/map_tile/1_239.png",
      is_feat = true
   },
   {
      _id = "1_240",
      id = "1_240",
      image = "graphic/temp/map_tile/1_240.png",
      is_feat = true
   },
   {
      _id = "1_241",
      id = "1_241",
      image = "graphic/temp/map_tile/1_241.png",
      is_feat = true
   },
   {
      _id = "1_242",
      id = "1_242",
      image = "graphic/temp/map_tile/1_242.png",
      is_feat = true
   },
   {
      _id = "1_243",
      id = "1_243",
      image = "graphic/temp/map_tile/1_243.png",
      is_feat = true
   },
   {
      _id = "1_244",
      id = "1_244",
      image = "graphic/temp/map_tile/1_244.png",
      is_feat = true
   },
   {
      _id = "1_245",
      id = "1_245",
      image = "graphic/temp/map_tile/1_245.png",
      is_feat = true
   },
   {
      _id = "1_246",
      id = "1_246",
      image = "graphic/temp/map_tile/1_246.png",
      is_feat = true
   },
   {
      _id = "1_247",
      id = "1_247",
      image = "graphic/temp/map_tile/1_247.png",
      is_feat = true
   },
   {
      _id = "1_248",
      id = "1_248",
      image = "graphic/temp/map_tile/1_248.png",
      is_feat = true
   },
   {
      _id = "1_249",
      id = "1_249",
      image = "graphic/temp/map_tile/1_249.png",
      is_feat = true
   },
   {
      _id = "1_250",
      id = "1_250",
      image = "graphic/temp/map_tile/1_250.png",
      is_feat = true
   },
   {
      _id = "1_251",
      id = "1_251",
      image = "graphic/temp/map_tile/1_251.png",
      is_feat = true
   },
   {
      _id = "1_252",
      id = "1_252",
      image = "graphic/temp/map_tile/1_252.png",
      is_feat = true
   },

   -- ...

   {
      _id = "1_264",
      id = "1_264",
      image = "graphic/temp/map_tile/1_264.png"
   },
   {
      _id = "1_265",
      id = "1_265",
      image = "graphic/temp/map_tile/1_265.png"
   },

   -- ...

   {
      _id = "1_284",
      id = "1_284",
      image = "graphic/temp/map_tile/1_284.png"
   },
   {
      _id = "1_285",
      id = "1_285",
      image = "graphic/temp/map_tile/1_285.png"
   },
}

local area_chips = {
   {
      _id = "0_132",
      id = "0_132",
      image = "graphic/temp/map_tile/0_132.png"
   },
   {
      _id = "0_133",
      id = "0_133",
      image = "graphic/temp/map_tile/0_133.png"
   },
   {
      _id = "0_134",
      id = "0_134",
      image = "graphic/temp/map_tile/0_134.png"
   },
   {
      _id = "0_135",
      id = "0_135",
      image = "graphic/temp/map_tile/0_135.png",
      offset_top = 8
   },
   {
      _id = "0_136",
      id = "0_136",
      image = "graphic/temp/map_tile/0_136.png"
   },
   {
      _id = "0_137",
      id = "0_137",
      image = "graphic/temp/map_tile/0_137.png",
      offset_top = 16
   },
   {
      _id = "0_138",
      id = "0_138",
      image = "graphic/temp/map_tile/0_138.png"
   },
   {
      _id = "0_139",
      id = "0_139",
      image = "graphic/temp/map_tile/0_139.png"
   },
   {
      _id = "0_140",
      id = "0_140",
      image = "graphic/temp/map_tile/0_140.png",
      offset_top = 6
   },
   {
      _id = "0_141",
      id = "0_141",
      image = "graphic/temp/map_tile/0_141.png"
   },
   {
      _id = "0_142",
      id = "0_142",
      image = "graphic/temp/map_tile/0_142.png"
   },
   {
      _id = "0_143",
      id = "0_143",
      image = "graphic/temp/map_tile/0_143.png"
   },
   {
      _id = "0_144",
      id = "0_144",
      image = "graphic/temp/map_tile/0_144.png"
   },
   {
      _id = "0_145",
      id = "0_145",
      image = "graphic/temp/map_tile/0_145.png",
      offset_top = 16
   },
   {
      _id = "0_146",
      id = "0_146",
      image = "graphic/temp/map_tile/0_146.png"
   },
   {
      _id = "0_147",
      id = "0_147",
      image = "graphic/temp/map_tile/0_147.png"
   },
   {
      _id = "0_148",
      id = "0_148",
      image = "graphic/temp/map_tile/0_148.png"
   },
   {
      _id = "0_149",
      id = "0_149",
      image = "graphic/temp/map_tile/0_149.png",
      offset_top = 16
   },
   {
      _id = "0_150",
      id = "0_150",
      image = "graphic/temp/map_tile/0_150.png"
   },
   {
      _id = "0_151",
      id = "0_151",
      image = "graphic/temp/map_tile/0_151.png"
   },
   {
      _id = "0_152",
      id = "0_152",
      image = "graphic/temp/map_tile/0_152.png"
   },
   {
      _id = "0_153",
      id = "0_153",
      image = "graphic/temp/map_tile/0_153.png"
   },
   {
      _id = "0_154",
      id = "0_154",
      image = "graphic/temp/map_tile/0_154.png"
   },
   {
      _id = "0_155",
      id = "0_155",
      image = "graphic/temp/map_tile/0_155.png"
   },
   {
      _id = "0_156",
      id = "0_156",
      image = "graphic/temp/map_tile/0_156.png"
   },
   {
      _id = "0_157",
      id = "0_157",
      image = "graphic/temp/map_tile/0_157.png"
   },
   {
      _id = "0_158",
      id = "0_158",
      image = "graphic/temp/map_tile/0_158.png"
   },
   {
      _id = "0_159",
      id = "0_159",
      image = "graphic/temp/map_tile/0_159.png"
   },
   {
      _id = "0_160",
      id = "0_160",
      image = "graphic/temp/map_tile/0_160.png"
   },
   {
      _id = "0_161",
      id = "0_161",
      image = "graphic/temp/map_tile/0_161.png"
   },

   -- ...

   {
      _id = "0_363",
      id = "0_363",
      image = "graphic/temp/map_tile/0_363.png"
   },
   {
      _id = "0_364",
      id = "0_364",
      image = "graphic/temp/map_tile/0_364.png"
   },
   {
      _id = "0_365",
      id = "0_365",
      image = "graphic/temp/map_tile/0_365.png"
   },
   {
      _id = "0_366",
      id = "0_366",
      image = "graphic/temp/map_tile/0_366.png"
   },
   {
      _id = "0_367",
      id = "0_367",
      image = "graphic/temp/map_tile/0_367.png"
   },
   {
      _id = "0_368",
      id = "0_368",
      image = "graphic/temp/map_tile/0_368.png"
   },
}


local tiles = {
   {
      _id = "world_grass",
      id = "0_0",
      image = "graphic/temp/map_tile/0_0.png"
   },
   {
      _id = "world_small_trees_1",
      id = "0_1",
      image = "graphic/temp/map_tile/0_1.png"
   },
   {
      _id = "world_small_trees_2",
      id = "0_2",
      image = "graphic/temp/map_tile/0_2.png"
   },
   {
      _id = "world_small_trees_3",
      id = "0_3",
      image = "graphic/temp/map_tile/0_3.png"
   },
   {
      _id = "world_trees_1",
      id = "0_4",
      image = "graphic/temp/map_tile/0_4.png"
   },
   {
      _id = "world_trees_2",
      id = "0_5",
      image = "graphic/temp/map_tile/0_5.png"
   },
   {
      _id = "world_trees_3",
      id = "0_6",
      image = "graphic/temp/map_tile/0_6.png"
   },
   {
      _id = "world_trees_4",
      id = "0_7",
      image = "graphic/temp/map_tile/0_7.png"
   },
   {
      _id = "world_trees_5",
      id = "0_8",
      image = "graphic/temp/map_tile/0_8.png"
   },
   {
      _id = "world_trees_6",
      id = "0_9",
      image = "graphic/temp/map_tile/0_9.png"
   },
   {
      _id = "world_plants_1",
      id = "0_10",
      image = "graphic/temp/map_tile/0_10.png"
   },
   {
      _id = "world_plants_2",
      id = "0_11",
      image = "graphic/temp/map_tile/0_11.png"
   },
   {
      _id = "world_plants_3",
      id = "0_12",
      image = "graphic/temp/map_tile/0_12.png"
   },
   {
      _id = "world_dirt_1",
      id = "0_13",
      image = "graphic/temp/map_tile/0_13.png"
   },
   {
      _id = "world_dirt_2",
      id = "0_14",
      image = "graphic/temp/map_tile/0_14.png"
   },
   {
      _id = "world_dirt_3",
      id = "0_15",
      image = "graphic/temp/map_tile/0_15.png"
   },
   {
      _id = "world_dirt_4",
      id = "0_16",
      image = "graphic/temp/map_tile/0_16.png"
   },
   {
      _id = "blank",
      id = "0_17",
      image = "graphic/temp/map_tile/0_17.png"
   },
   {
      _id = "blank",
      id = "0_18",
      image = "graphic/temp/map_tile/0_18.png"
   },
   {
      _id = "blank",
      id = "0_19",
      image = "graphic/temp/map_tile/0_19.png"
   },
   {
      _id = "blank",
      id = "0_20",
      image = "graphic/temp/map_tile/0_20.png"
   },
   {
      _id = "blank",
      id = "0_21",
      image = "graphic/temp/map_tile/0_21.png"
   },
   {
      _id = "blank",
      id = "0_22",
      image = "graphic/temp/map_tile/0_22.png"
   },
   {
      _id = "blank",
      id = "0_23",
      image = "graphic/temp/map_tile/0_23.png"
   },
   {
      _id = "blank",
      id = "0_24",
      image = "graphic/temp/map_tile/0_24.png"
   },
   {
      _id = "blank",
      id = "0_25",
      image = "graphic/temp/map_tile/0_25.png"
   },
   {
      _id = "world_snow_cross",
      id = "0_26",
      image = "graphic/temp/map_tile/0_26.png",
      kind = 4
   },
   {
      _id = "world_snow",
      id = "0_27",
      image = "graphic/temp/map_tile/0_27.png",
      kind = 4
   },
   {
      _id = "world_snow_grass",
      id = "0_28",
      image = "graphic/temp/map_tile/0_28.png",
      kind = 4
   },
   {
      _id = "world_snow_trees_1",
      id = "0_29",
      image = "graphic/temp/map_tile/0_29.png",
      kind = 4
   },
   {
      _id = "world_snow_trees_2",
      id = "0_30",
      image = "graphic/temp/map_tile/0_30.png",
      kind = 4
   },
   {
      _id = "world_snow_crater",
      id = "0_31",
      image = "graphic/temp/map_tile/0_31.png",
      kind = 4
   },
   {
      _id = "world_snow_mounds",
      id = "0_32",
      image = "graphic/temp/map_tile/0_32.png",
      kind = 4
   },
   {
      _id = "world_dirt_patch",
      id = "0_33",
      image = "graphic/temp/map_tile/0_33.png"
   },
   {
      _id = "world_road_ns",
      id = "0_34",
      image = "graphic/temp/map_tile/0_34.png",
      is_road = true
   },
   {
      _id = "world_road_we",
      id = "0_35",
      image = "graphic/temp/map_tile/0_35.png",
      is_road = true
   },
   {
      _id = "world_road_sw",
      id = "0_36",
      image = "graphic/temp/map_tile/0_36.png",
      is_road = true
   },
   {
      _id = "world_road_se",
      id = "0_37",
      image = "graphic/temp/map_tile/0_37.png",
      is_road = true
   },
   {
      _id = "world_road_nw",
      id = "0_38",
      image = "graphic/temp/map_tile/0_38.png",
      is_road = true
   },
   {
      _id = "world_road_ne",
      id = "0_39",
      image = "graphic/temp/map_tile/0_39.png",
      is_road = true
   },
   {
      _id = "world_road_swe",
      id = "0_40",
      image = "graphic/temp/map_tile/0_40.png",
      is_road = true
   },
   {
      _id = "world_road_nsw",
      id = "0_41",
      image = "graphic/temp/map_tile/0_41.png",
      is_road = true
   },
   {
      _id = "world_road_nwe",
      id = "0_42",
      image = "graphic/temp/map_tile/0_42.png",
      is_road = true
   },
   {
      _id = "world_road_nse",
      id = "0_43",
      image = "graphic/temp/map_tile/0_43.png",
      is_road = true
   },
   {
      _id = "blank",
      id = "0_44",
      image = "graphic/temp/map_tile/0_44.png"
   },
   {
      _id = "blank",
      id = "0_45",
      image = "graphic/temp/map_tile/0_45.png"
   },
   {
      _id = "blank",
      id = "0_46",
      image = "graphic/temp/map_tile/0_46.png"
   },
   {
      _id = "blank",
      id = "0_47",
      image = "graphic/temp/map_tile/0_47.png"
   },
   {
      _id = "world_desert_road_ns",
      id = "0_48",
      image = "graphic/temp/map_tile/0_48.png",
      is_road = true
   },
   {
      _id = "world_desert_road_we",
      id = "0_49",
      image = "graphic/temp/map_tile/0_49.png"
   },
   {
      _id = "world_desert_road_sw",
      id = "0_50",
      image = "graphic/temp/map_tile/0_50.png"
   },
   {
      _id = "world_desert_road_se",
      id = "0_51",
      image = "graphic/temp/map_tile/0_51.png"
   },
   {
      _id = "world_desert_road_nw",
      id = "0_52",
      image = "graphic/temp/map_tile/0_52.png"
   },
   {
      _id = "world_desert_road_ne",
      id = "0_53",
      image = "graphic/temp/map_tile/0_53.png"
   },
   {
      _id = "world_desert_road_swe",
      id = "0_54",
      image = "graphic/temp/map_tile/0_54.png"
   },
   {
      _id = "world_desert_road_nsw",
      id = "0_55",
      image = "graphic/temp/map_tile/0_55.png"
   },
   {
      _id = "world_desert_road_nwe",
      id = "0_56",
      image = "graphic/temp/map_tile/0_56.png"
   },
   {
      _id = "world_desert_road_nse",
      id = "0_57",
      image = "graphic/temp/map_tile/0_57.png"
   },
   {
      _id = "blank",
      id = "0_58",
      image = "graphic/temp/map_tile/0_58.png"
   },
   {
      _id = "blank",
      id = "0_59",
      image = "graphic/temp/map_tile/0_59.png"
   },
   {
      _id = "blank",
      id = "0_60",
      image = "graphic/temp/map_tile/0_60.png"
   },
   {
      _id = "blank",
      id = "0_61",
      image = "graphic/temp/map_tile/0_61.png"
   },
   {
      _id = "blank",
      id = "0_62",
      image = "graphic/temp/map_tile/0_62.png"
   },
   {
      _id = "blank",
      id = "0_63",
      image = "graphic/temp/map_tile/0_63.png"
   },
   {
      _id = "blank",
      id = "0_64",
      image = "graphic/temp/map_tile/0_64.png"
   },
   {
      _id = "blank",
      id = "0_65",
      image = "graphic/temp/map_tile/0_65.png"
   },
   {
      _id = "world_flower_1",
      id = "0_66",
      image = "graphic/temp/map_tile/0_66.png"
   },
   {
      _id = "world_flower_2",
      id = "0_67",
      image = "graphic/temp/map_tile/0_67.png"
   },
   {
      _id = "world_flower_3",
      id = "0_68",
      image = "graphic/temp/map_tile/0_68.png"
   },
   {
      _id = "world_flower_4",
      id = "0_69",
      image = "graphic/temp/map_tile/0_69.png"
   },
   {
      _id = "world_flower_5",
      id = "0_70",
      image = "graphic/temp/map_tile/0_70.png"
   },
   {
      _id = "world_flower_6",
      id = "0_71",
      image = "graphic/temp/map_tile/0_71.png"
   },
   {
      _id = "world_flower_7",
      id = "0_72",
      image = "graphic/temp/map_tile/0_72.png"
   },
   {
      _id = "world_mounds_1",
      id = "0_73",
      image = "graphic/temp/map_tile/0_73.png"
   },
   {
      _id = "world_mounds_2",
      id = "0_74",
      image = "graphic/temp/map_tile/0_74.png"
   },
   {
      _id = "world_grass_2",
      id = "0_75",
      image = "graphic/temp/map_tile/0_75.png"
   },
   {
      _id = "world_grass_3",
      id = "0_76",
      image = "graphic/temp/map_tile/0_76.png"
   },
   {
      _id = "world_bridge_left",
      id = "0_77",
      image = "graphic/temp/map_tile/0_77.png"
   },
   {
      _id = "world_bridge_middle",
      id = "0_78",
      image = "graphic/temp/map_tile/0_78.png"
   },
   {
      _id = "world_bridge_right",
      id = "0_79",
      image = "graphic/temp/map_tile/0_79.png"
   },
   {
      _id = "world_tall_grass",
      id = "0_80",
      image = "graphic/temp/map_tile/0_80.png"
   },
   {
      _id = "blank",
      id = "0_81",
      image = "graphic/temp/map_tile/0_81.png"
   },
   {
      _id = "blank",
      id = "0_82",
      image = "graphic/temp/map_tile/0_82.png"
   },
   {
      _id = "blank",
      id = "0_83",
      image = "graphic/temp/map_tile/0_83.png"
   },
   {
      _id = "blank",
      id = "0_84",
      image = "graphic/temp/map_tile/0_84.png"
   },
   {
      _id = "blank",
      id = "0_85",
      image = "graphic/temp/map_tile/0_85.png"
   },
   {
      _id = "blank",
      id = "0_86",
      image = "graphic/temp/map_tile/0_86.png"
   },
   {
      _id = "blank",
      id = "0_87",
      image = "graphic/temp/map_tile/0_87.png"
   },
   {
      _id = "blank",
      id = "0_88",
      image = "graphic/temp/map_tile/0_88.png"
   },
   {
      _id = "blank",
      id = "0_89",
      image = "graphic/temp/map_tile/0_89.png"
   },
   {
      _id = "blank",
      id = "0_90",
      image = "graphic/temp/map_tile/0_90.png"
   },
   {
      _id = "blank",
      id = "0_91",
      image = "graphic/temp/map_tile/0_91.png"
   },
   {
      _id = "blank",
      id = "0_92",
      image = "graphic/temp/map_tile/0_92.png"
   },
   {
      _id = "blank",
      id = "0_93",
      image = "graphic/temp/map_tile/0_93.png"
   },
   {
      _id = "blank",
      id = "0_94",
      image = "graphic/temp/map_tile/0_94.png"
   },
   {
      _id = "blank",
      id = "0_95",
      image = "graphic/temp/map_tile/0_95.png"
   },
   {
      _id = "blank",
      id = "0_96",
      image = "graphic/temp/map_tile/0_96.png"
   },
   {
      _id = "blank",
      id = "0_97",
      image = "graphic/temp/map_tile/0_97.png"
   },
   {
      _id = "blank",
      id = "0_98",
      image = "graphic/temp/map_tile/0_98.png"
   },
   {
      _id = "world_desert",
      id = "0_99",
      image = "graphic/temp/map_tile/0_99.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_trees_1",
      id = "0_100",
      image = "graphic/temp/map_tile/0_100.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_trees_2",
      id = "0_101",
      image = "graphic/temp/map_tile/0_101.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_trees_3",
      id = "0_102",
      image = "graphic/temp/map_tile/0_102.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_trees_4",
      id = "0_103",
      image = "graphic/temp/map_tile/0_103.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_dead_trees_1",
      id = "0_104",
      image = "graphic/temp/map_tile/0_104.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_dead_trees_2",
      id = "0_105",
      image = "graphic/temp/map_tile/0_105.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_dead_trees_3",
      id = "0_106",
      image = "graphic/temp/map_tile/0_106.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_border_w",
      id = "0_107",
      image = "graphic/temp/map_tile/0_107.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_e",
      id = "0_108",
      image = "graphic/temp/map_tile/0_108.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_n",
      id = "0_109",
      image = "graphic/temp/map_tile/0_109.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_s",
      id = "0_110",
      image = "graphic/temp/map_tile/0_110.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_ne",
      id = "0_111",
      image = "graphic/temp/map_tile/0_111.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_nw",
      id = "0_112",
      image = "graphic/temp/map_tile/0_112.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_se",
      id = "0_113",
      image = "graphic/temp/map_tile/0_113.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_sw",
      id = "0_114",
      image = "graphic/temp/map_tile/0_114.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_corner_ne",
      id = "0_115",
      image = "graphic/temp/map_tile/0_115.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_corner_nw",
      id = "0_116",
      image = "graphic/temp/map_tile/0_116.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_corner_se",
      id = "0_117",
      image = "graphic/temp/map_tile/0_117.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_border_corner_sw",
      id = "0_118",
      image = "graphic/temp/map_tile/0_118.png",
      is_feat = true,
      kind = 7,
      kind2 = 9
   },
   {
      _id = "world_desert_bones",
      id = "0_119",
      image = "graphic/temp/map_tile/0_119.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_rocks_1",
      id = "0_120",
      image = "graphic/temp/map_tile/0_120.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_rocks_2",
      id = "0_121",
      image = "graphic/temp/map_tile/0_121.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_rocks_3",
      id = "0_122",
      image = "graphic/temp/map_tile/0_122.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_rocks_4",
      id = "0_123",
      image = "graphic/temp/map_tile/0_123.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_plants_1",
      id = "0_124",
      image = "graphic/temp/map_tile/0_124.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_plants_2",
      id = "0_125",
      image = "graphic/temp/map_tile/0_125.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_plants_3",
      id = "0_126",
      image = "graphic/temp/map_tile/0_126.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_2",
      id = "0_127",
      image = "graphic/temp/map_tile/0_127.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_3",
      id = "0_128",
      image = "graphic/temp/map_tile/0_128.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_4",
      id = "0_129",
      image = "graphic/temp/map_tile/0_129.png",
      is_feat = true,
      kind = 7
   },
   {
      _id = "world_desert_5",
      id = "0_130",
      image = "graphic/temp/map_tile/0_130.png",
      kind = 7
   },
   {
      _id = "world_desert_6",
      id = "0_131",
      image = "graphic/temp/map_tile/0_131.png",
      kind = 7
   },

   -- ...

   {
      _id = "blank",
      id = "0_162",
      image = "graphic/temp/map_tile/0_162.png"
   },
   {
      _id = "blank",
      id = "0_163",
      image = "graphic/temp/map_tile/0_163.png"
   },
   {
      _id = "blank",
      id = "0_164",
      image = "graphic/temp/map_tile/0_164.png"
   },
   {
      _id = "world_dirt",
      id = "0_165",
      image = "graphic/temp/map_tile/0_165.png",
      kind = 8
   },
   {
      _id = "world_dirt_crater",
      id = "0_166",
      image = "graphic/temp/map_tile/0_166.png",
      kind = 8
   },
   {
      _id = "world_dirt_rocks_1",
      id = "0_167",
      image = "graphic/temp/map_tile/0_167.png",
      kind = 8
   },
   {
      _id = "world_dirt_rocks_2",
      id = "0_168",
      image = "graphic/temp/map_tile/0_168.png",
      kind = 8
   },
   {
      _id = "world_dirt_rocks_3",
      id = "0_169",
      image = "graphic/temp/map_tile/0_169.png",
      kind = 8
   },
   {
      _id = "world_dirt_dead_trees_1",
      id = "0_170",
      image = "graphic/temp/map_tile/0_170.png",
      kind = 8
   },
   {
      _id = "world_dirt_dead_trees_2",
      id = "0_171",
      image = "graphic/temp/map_tile/0_171.png",
      kind = 8
   },
   {
      _id = "world_dirt_dead_trees_3",
      id = "0_172",
      image = "graphic/temp/map_tile/0_172.png",
      kind = 8
   },
   {
      _id = "world_dirt_border_w",
      id = "0_173",
      image = "graphic/temp/map_tile/0_173.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_e",
      id = "0_174",
      image = "graphic/temp/map_tile/0_174.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_n",
      id = "0_175",
      image = "graphic/temp/map_tile/0_175.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_s",
      id = "0_176",
      image = "graphic/temp/map_tile/0_176.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_corner_ne",
      id = "0_177",
      image = "graphic/temp/map_tile/0_177.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_corner_nw",
      id = "0_178",
      image = "graphic/temp/map_tile/0_178.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_corner_se",
      id = "0_179",
      image = "graphic/temp/map_tile/0_179.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_corner_sw",
      id = "0_180",
      image = "graphic/temp/map_tile/0_180.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_ne",
      id = "0_181",
      image = "graphic/temp/map_tile/0_181.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_nw",
      id = "0_182",
      image = "graphic/temp/map_tile/0_182.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_se",
      id = "0_183",
      image = "graphic/temp/map_tile/0_183.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "world_dirt_border_sw",
      id = "0_184",
      image = "graphic/temp/map_tile/0_184.png",
      kind = 8,
      kind2 = 9
   },
   {
      _id = "blank",
      id = "0_185",
      image = "graphic/temp/map_tile/0_185.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_186",
      image = "graphic/temp/map_tile/0_186.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_187",
      image = "graphic/temp/map_tile/0_187.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_188",
      image = "graphic/temp/map_tile/0_188.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_189",
      image = "graphic/temp/map_tile/0_189.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_190",
      image = "graphic/temp/map_tile/0_190.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_191",
      image = "graphic/temp/map_tile/0_191.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_192",
      image = "graphic/temp/map_tile/0_192.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_193",
      image = "graphic/temp/map_tile/0_193.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_194",
      image = "graphic/temp/map_tile/0_194.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_195",
      image = "graphic/temp/map_tile/0_195.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_196",
      image = "graphic/temp/map_tile/0_196.png",
      kind = 8
   },
   {
      _id = "blank",
      id = "0_197",
      image = "graphic/temp/map_tile/0_197.png",
      kind = 8
   },
   {
      _id = "world_snow_2",
      id = "0_198",
      image = "graphic/temp/map_tile/0_198.png",
      kind = 4
   },
   {
      _id = "world_snow_dead_tree",
      id = "0_199",
      image = "graphic/temp/map_tile/0_199.png",
      kind = 4
   },
   {
      _id = "world_snow_trees_3",
      id = "0_200",
      image = "graphic/temp/map_tile/0_200.png",
      kind = 4
   },
   {
      _id = "world_snow_trees_4",
      id = "0_201",
      image = "graphic/temp/map_tile/0_201.png",
      kind = 4
   },
   {
      _id = "world_snow_trees_5",
      id = "0_202",
      image = "graphic/temp/map_tile/0_202.png",
      kind = 4
   },
   {
      _id = "world_snow_3",
      id = "0_203",
      image = "graphic/temp/map_tile/0_203.png",
      kind = 4
   },
   {
      _id = "world_snow_4",
      id = "0_204",
      image = "graphic/temp/map_tile/0_204.png",
      kind = 4
   },
   {
      _id = "world_snow_5",
      id = "0_205",
      image = "graphic/temp/map_tile/0_205.png",
      kind = 4
   },
   {
      _id = "world_snow_border_w",
      id = "0_206",
      image = "graphic/temp/map_tile/0_206.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_e",
      id = "0_207",
      image = "graphic/temp/map_tile/0_207.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_n",
      id = "0_208",
      image = "graphic/temp/map_tile/0_208.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_s",
      id = "0_209",
      image = "graphic/temp/map_tile/0_209.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_corner_ne",
      id = "0_210",
      image = "graphic/temp/map_tile/0_210.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_corner_nw",
      id = "0_211",
      image = "graphic/temp/map_tile/0_211.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_corner_se",
      id = "0_212",
      image = "graphic/temp/map_tile/0_212.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_corner_sw",
      id = "0_213",
      image = "graphic/temp/map_tile/0_213.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_ne",
      id = "0_214",
      image = "graphic/temp/map_tile/0_214.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_nw",
      id = "0_215",
      image = "graphic/temp/map_tile/0_215.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_se",
      id = "0_216",
      image = "graphic/temp/map_tile/0_216.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "world_snow_border_sw",
      id = "0_217",
      image = "graphic/temp/map_tile/0_217.png",
      kind = 4,
      kind2 = 9
   },
   {
      _id = "blank",
      id = "0_218",
      image = "graphic/temp/map_tile/0_218.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_219",
      image = "graphic/temp/map_tile/0_219.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_220",
      image = "graphic/temp/map_tile/0_220.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_221",
      image = "graphic/temp/map_tile/0_221.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_222",
      image = "graphic/temp/map_tile/0_222.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_223",
      image = "graphic/temp/map_tile/0_223.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_224",
      image = "graphic/temp/map_tile/0_224.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_225",
      image = "graphic/temp/map_tile/0_225.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_226",
      image = "graphic/temp/map_tile/0_226.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_227",
      image = "graphic/temp/map_tile/0_227.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_228",
      image = "graphic/temp/map_tile/0_228.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_229",
      image = "graphic/temp/map_tile/0_229.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_230",
      image = "graphic/temp/map_tile/0_230.png",
      kind = 4
   },
   {
      _id = "blank",
      id = "0_231",
      image = "graphic/temp/map_tile/0_231.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_232",
      image = "graphic/temp/map_tile/0_232.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_233",
      image = "graphic/temp/map_tile/0_233.png",
      is_feat = true,
      offset_bottom = 0,
      offset_top = 0
   },
   {
      _id = "blank",
      id = "0_234",
      image = "graphic/temp/map_tile/0_234.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_235",
      image = "graphic/temp/map_tile/0_235.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_236",
      image = "graphic/temp/map_tile/0_236.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_237",
      image = "graphic/temp/map_tile/0_237.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_238",
      image = "graphic/temp/map_tile/0_238.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_239",
      image = "graphic/temp/map_tile/0_239.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_240",
      image = "graphic/temp/map_tile/0_240.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_241",
      image = "graphic/temp/map_tile/0_241.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_242",
      image = "graphic/temp/map_tile/0_242.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_243",
      image = "graphic/temp/map_tile/0_243.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_244",
      image = "graphic/temp/map_tile/0_244.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_245",
      image = "graphic/temp/map_tile/0_245.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_246",
      image = "graphic/temp/map_tile/0_246.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_247",
      image = "graphic/temp/map_tile/0_247.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_248",
      image = "graphic/temp/map_tile/0_248.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_249",
      image = "graphic/temp/map_tile/0_249.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_250",
      image = "graphic/temp/map_tile/0_250.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_251",
      image = "graphic/temp/map_tile/0_251.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_252",
      image = "graphic/temp/map_tile/0_252.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_253",
      image = "graphic/temp/map_tile/0_253.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_254",
      image = "graphic/temp/map_tile/0_254.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_255",
      image = "graphic/temp/map_tile/0_255.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_256",
      image = "graphic/temp/map_tile/0_256.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_257",
      image = "graphic/temp/map_tile/0_257.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_258",
      image = "graphic/temp/map_tile/0_258.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_259",
      image = "graphic/temp/map_tile/0_259.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_260",
      image = "graphic/temp/map_tile/0_260.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_261",
      image = "graphic/temp/map_tile/0_261.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "0_262",
      image = "graphic/temp/map_tile/0_262.png"
   },
   {
      _id = "blank",
      id = "0_263",
      image = "graphic/temp/map_tile/0_263.png"
   },
   {
      _id = "world_water",
      effect = 4,
      id = "0_264",
      image = "graphic/temp/map_tile/0_264.png"
   },
   {
      _id = "world_water_rocks",
      effect = 4,
      id = "0_265",
      image = "graphic/temp/map_tile/0_265.png"
   },
   {
      _id = "world_water_2",
      effect = 4,
      id = "0_266",
      image = "graphic/temp/map_tile/0_266.png"
   },
   {
      _id = "world_water_pole",
      effect = 4,
      id = "0_267",
      image = "graphic/temp/map_tile/0_267.png"
   },
   {
      _id = "world_water_iceberg",
      effect = 4,
      id = "0_268",
      image = "graphic/temp/map_tile/0_268.png"
   },
   {
      _id = "world_water_rock",
      effect = 4,
      id = "0_269",
      image = "graphic/temp/map_tile/0_269.png"
   },
   {
      _id = "world_water_shadow",
      effect = 4,
      id = "0_270",
      image = "graphic/temp/map_tile/0_270.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_271",
      image = "graphic/temp/map_tile/0_271.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_272",
      image = "graphic/temp/map_tile/0_272.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_273",
      image = "graphic/temp/map_tile/0_273.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_274",
      image = "graphic/temp/map_tile/0_274.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_275",
      image = "graphic/temp/map_tile/0_275.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_276",
      image = "graphic/temp/map_tile/0_276.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_277",
      image = "graphic/temp/map_tile/0_277.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_278",
      image = "graphic/temp/map_tile/0_278.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_279",
      image = "graphic/temp/map_tile/0_279.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_280",
      image = "graphic/temp/map_tile/0_280.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_281",
      image = "graphic/temp/map_tile/0_281.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_282",
      image = "graphic/temp/map_tile/0_282.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_283",
      image = "graphic/temp/map_tile/0_283.png"
   },
   {
      _id = "blank",
      effect = 4,
      id = "0_284",
      image = "graphic/temp/map_tile/0_284.png"
   },
   {
      _id = "world_grass_water_border_w",
      effect = 4,
      id = "0_285",
      image = "graphic/temp/map_tile/0_285.png"
   },
   {
      _id = "world_grass_water_border_e",
      effect = 4,
      id = "0_286",
      image = "graphic/temp/map_tile/0_286.png"
   },
   {
      _id = "world_grass_water_border_n",
      effect = 4,
      id = "0_287",
      image = "graphic/temp/map_tile/0_287.png"
   },
   {
      _id = "world_grass_water_border_s",
      effect = 4,
      id = "0_288",
      image = "graphic/temp/map_tile/0_288.png"
   },
   {
      _id = "world_grass_water_border_corner_ne",
      effect = 4,
      id = "0_289",
      image = "graphic/temp/map_tile/0_289.png"
   },
   {
      _id = "world_grass_water_border_corner_nw",
      effect = 4,
      id = "0_290",
      image = "graphic/temp/map_tile/0_290.png"
   },
   {
      _id = "world_grass_water_border_corner_se",
      effect = 4,
      id = "0_291",
      image = "graphic/temp/map_tile/0_291.png"
   },
   {
      _id = "world_grass_water_border_corner_sw",
      effect = 4,
      id = "0_292",
      image = "graphic/temp/map_tile/0_292.png"
   },
   {
      _id = "world_grass_water_border_ne",
      effect = 4,
      id = "0_293",
      image = "graphic/temp/map_tile/0_293.png"
   },
   {
      _id = "world_grass_water_border_nw",
      effect = 4,
      id = "0_294",
      image = "graphic/temp/map_tile/0_294.png"
   },
   {
      _id = "world_grass_water_border_se",
      effect = 4,
      id = "0_295",
      image = "graphic/temp/map_tile/0_295.png"
   },
   {
      _id = "world_grass_water_border_sw",
      effect = 4,
      id = "0_296",
      image = "graphic/temp/map_tile/0_296.png"
   },
   {
      _id = "world_snow_water_border_w",
      id = "0_297",
      image = "graphic/temp/map_tile/0_297.png"
   },
   {
      _id = "world_snow_water_border_e",
      id = "0_298",
      image = "graphic/temp/map_tile/0_298.png"
   },
   {
      _id = "world_snow_water_border_n",
      id = "0_299",
      image = "graphic/temp/map_tile/0_299.png"
   },
   {
      _id = "world_snow_water_border_s",
      id = "0_300",
      image = "graphic/temp/map_tile/0_300.png"
   },
   {
      _id = "world_snow_water_border_corner_ne",
      id = "0_301",
      image = "graphic/temp/map_tile/0_301.png"
   },
   {
      _id = "world_snow_water_border_corner_nw",
      id = "0_302",
      image = "graphic/temp/map_tile/0_302.png"
   },
   {
      _id = "world_snow_water_border_corner_se",
      id = "0_303",
      image = "graphic/temp/map_tile/0_303.png"
   },
   {
      _id = "world_snow_water_border_corner_sw",
      id = "0_304",
      image = "graphic/temp/map_tile/0_304.png"
   },
   {
      _id = "world_snow_water_border_ne",
      id = "0_305",
      image = "graphic/temp/map_tile/0_305.png"
   },
   {
      _id = "world_snow_water_border_nw",
      id = "0_306",
      image = "graphic/temp/map_tile/0_306.png"
   },
   {
      _id = "world_snow_water_border_se",
      id = "0_307",
      image = "graphic/temp/map_tile/0_307.png"
   },
   {
      _id = "world_snow_water_border_sw",
      id = "0_308",
      image = "graphic/temp/map_tile/0_308.png"
   },
   {
      _id = "world_desert_water_border_w",
      id = "0_309",
      image = "graphic/temp/map_tile/0_309.png"
   },
   {
      _id = "world_desert_water_border_e",
      id = "0_310",
      image = "graphic/temp/map_tile/0_310.png"
   },
   {
      _id = "world_desert_water_border_n",
      id = "0_311",
      image = "graphic/temp/map_tile/0_311.png"
   },
   {
      _id = "world_desert_water_border_s",
      id = "0_312",
      image = "graphic/temp/map_tile/0_312.png"
   },
   {
      _id = "world_desert_water_border_corner_ne",
      id = "0_313",
      image = "graphic/temp/map_tile/0_313.png"
   },
   {
      _id = "world_desert_water_border_corner_nw",
      id = "0_314",
      image = "graphic/temp/map_tile/0_314.png"
   },
   {
      _id = "world_desert_water_border_corner_se",
      id = "0_315",
      image = "graphic/temp/map_tile/0_315.png"
   },
   {
      _id = "world_desert_water_border_corner_sw",
      id = "0_316",
      image = "graphic/temp/map_tile/0_316.png"
   },
   {
      _id = "world_desert_water_border_ne",
      id = "0_317",
      image = "graphic/temp/map_tile/0_317.png"
   },
   {
      _id = "world_desert_water_border_nw",
      id = "0_318",
      image = "graphic/temp/map_tile/0_318.png"
   },
   {
      _id = "world_desert_water_border_se",
      id = "0_319",
      image = "graphic/temp/map_tile/0_319.png"
   },
   {
      _id = "world_desert_water_border_sw",
      id = "0_320",
      image = "graphic/temp/map_tile/0_320.png"
   },
   {
      _id = "blank",
      id = "0_321",
      image = "graphic/temp/map_tile/0_321.png"
   },
   {
      _id = "blank",
      id = "0_322",
      image = "graphic/temp/map_tile/0_322.png"
   },
   {
      _id = "blank",
      id = "0_323",
      image = "graphic/temp/map_tile/0_323.png"
   },
   {
      _id = "blank",
      id = "0_324",
      image = "graphic/temp/map_tile/0_324.png"
   },
   {
      _id = "blank",
      id = "0_325",
      image = "graphic/temp/map_tile/0_325.png"
   },
   {
      _id = "blank",
      id = "0_326",
      image = "graphic/temp/map_tile/0_326.png"
   },
   {
      _id = "blank",
      id = "0_327",
      image = "graphic/temp/map_tile/0_327.png"
   },
   {
      _id = "blank",
      id = "0_328",
      image = "graphic/temp/map_tile/0_328.png"
   },
   {
      _id = "blank",
      id = "0_329",
      image = "graphic/temp/map_tile/0_329.png"
   },
   {
      _id = "blank",
      id = "0_330",
      image = "graphic/temp/map_tile/0_330.png"
   },
   {
      _id = "blank",
      id = "0_331",
      image = "graphic/temp/map_tile/0_331.png"
   },
   {
      _id = "blank",
      id = "0_332",
      image = "graphic/temp/map_tile/0_332.png"
   },
   {
      _id = "blank",
      id = "0_333",
      image = "graphic/temp/map_tile/0_333.png"
   },
   {
      _id = "blank",
      id = "0_334",
      image = "graphic/temp/map_tile/0_334.png"
   },
   {
      _id = "blank",
      id = "0_335",
      image = "graphic/temp/map_tile/0_335.png"
   },
   {
      _id = "blank",
      id = "0_336",
      image = "graphic/temp/map_tile/0_336.png"
   },
   {
      _id = "blank",
      id = "0_337",
      image = "graphic/temp/map_tile/0_337.png"
   },
   {
      _id = "blank",
      id = "0_338",
      image = "graphic/temp/map_tile/0_338.png"
   },
   {
      _id = "blank",
      id = "0_339",
      image = "graphic/temp/map_tile/0_339.png"
   },
   {
      _id = "blank",
      id = "0_340",
      image = "graphic/temp/map_tile/0_340.png"
   },
   {
      _id = "blank",
      id = "0_341",
      image = "graphic/temp/map_tile/0_341.png"
   },
   {
      _id = "blank",
      id = "0_342",
      image = "graphic/temp/map_tile/0_342.png"
   },
   {
      _id = "blank",
      id = "0_343",
      image = "graphic/temp/map_tile/0_343.png"
   },
   {
      _id = "blank",
      id = "0_344",
      image = "graphic/temp/map_tile/0_344.png"
   },
   {
      _id = "blank",
      id = "0_345",
      image = "graphic/temp/map_tile/0_345.png"
   },
   {
      _id = "blank",
      id = "0_346",
      image = "graphic/temp/map_tile/0_346.png"
   },
   {
      _id = "blank",
      id = "0_347",
      image = "graphic/temp/map_tile/0_347.png"
   },
   {
      _id = "blank",
      id = "0_348",
      image = "graphic/temp/map_tile/0_348.png"
   },
   {
      _id = "blank",
      id = "0_349",
      image = "graphic/temp/map_tile/0_349.png"
   },
   {
      _id = "blank",
      id = "0_350",
      image = "graphic/temp/map_tile/0_350.png"
   },
   {
      _id = "blank",
      id = "0_351",
      image = "graphic/temp/map_tile/0_351.png"
   },
   {
      _id = "blank",
      id = "0_352",
      image = "graphic/temp/map_tile/0_352.png"
   },
   {
      _id = "blank",
      id = "0_353",
      image = "graphic/temp/map_tile/0_353.png"
   },
   {
      _id = "blank",
      id = "0_354",
      image = "graphic/temp/map_tile/0_354.png"
   },
   {
      _id = "blank",
      id = "0_355",
      image = "graphic/temp/map_tile/0_355.png"
   },
   {
      _id = "blank",
      id = "0_356",
      image = "graphic/temp/map_tile/0_356.png"
   },
   {
      _id = "blank",
      id = "0_357",
      image = "graphic/temp/map_tile/0_357.png"
   },
   {
      _id = "blank",
      id = "0_358",
      image = "graphic/temp/map_tile/0_358.png"
   },
   {
      _id = "blank",
      id = "0_359",
      image = "graphic/temp/map_tile/0_359.png"
   },
   {
      _id = "blank",
      id = "0_360",
      image = "graphic/temp/map_tile/0_360.png"
   },
   {
      _id = "blank",
      id = "0_361",
      image = "graphic/temp/map_tile/0_361.png"
   },
   {
      _id = "blank",
      id = "0_362",
      image = "graphic/temp/map_tile/0_362.png"
   },

   -- ...

   {
      _id = "blank",
      id = "0_369",
      image = "graphic/temp/map_tile/0_369.png"
   },
   {
      _id = "blank",
      id = "0_370",
      image = "graphic/temp/map_tile/0_370.png"
   },
   {
      _id = "blank",
      id = "0_371",
      image = "graphic/temp/map_tile/0_371.png"
   },
   {
      _id = "blank",
      id = "0_372",
      image = "graphic/temp/map_tile/0_372.png"
   },
   {
      _id = "blank",
      id = "0_373",
      image = "graphic/temp/map_tile/0_373.png"
   },
   {
      _id = "blank",
      id = "0_374",
      image = "graphic/temp/map_tile/0_374.png"
   },
   {
      _id = "blank",
      id = "0_375",
      image = "graphic/temp/map_tile/0_375.png"
   },
   {
      _id = "blank",
      id = "0_376",
      image = "graphic/temp/map_tile/0_376.png"
   },
   {
      _id = "blank",
      id = "0_377",
      image = "graphic/temp/map_tile/0_377.png"
   },
   {
      _id = "blank",
      id = "0_378",
      image = "graphic/temp/map_tile/0_378.png"
   },
   {
      _id = "blank",
      id = "0_379",
      image = "graphic/temp/map_tile/0_379.png"
   },
   {
      _id = "blank",
      id = "0_380",
      image = "graphic/temp/map_tile/0_380.png"
   },
   {
      _id = "blank",
      id = "0_381",
      image = "graphic/temp/map_tile/0_381.png"
   },
   {
      _id = "blank",
      id = "0_382",
      image = "graphic/temp/map_tile/0_382.png"
   },
   {
      _id = "blank",
      id = "0_383",
      image = "graphic/temp/map_tile/0_383.png"
   },
   {
      _id = "blank",
      id = "0_384",
      image = "graphic/temp/map_tile/0_384.png"
   },
   {
      _id = "blank",
      id = "0_385",
      image = "graphic/temp/map_tile/0_385.png"
   },
   {
      _id = "blank",
      id = "0_386",
      image = "graphic/temp/map_tile/0_386.png"
   },
   {
      _id = "blank",
      id = "0_387",
      image = "graphic/temp/map_tile/0_387.png"
   },
   {
      _id = "blank",
      id = "0_388",
      image = "graphic/temp/map_tile/0_388.png"
   },
   {
      _id = "blank",
      id = "0_389",
      image = "graphic/temp/map_tile/0_389.png"
   },
   {
      _id = "blank",
      id = "0_390",
      image = "graphic/temp/map_tile/0_390.png"
   },
   {
      _id = "blank",
      id = "0_391",
      image = "graphic/temp/map_tile/0_391.png"
   },
   {
      _id = "blank",
      id = "0_392",
      image = "graphic/temp/map_tile/0_392.png"
   },
   {
      _id = "blank",
      id = "0_393",
      image = "graphic/temp/map_tile/0_393.png"
   },
   {
      _id = "blank",
      id = "0_394",
      image = "graphic/temp/map_tile/0_394.png"
   },
   {
      _id = "blank",
      id = "0_395",
      image = "graphic/temp/map_tile/0_395.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_396",
      image = "graphic/temp/map_tile/0_396.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_397",
      image = "graphic/temp/map_tile/0_397.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_398",
      image = "graphic/temp/map_tile/0_398.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_399",
      image = "graphic/temp/map_tile/0_399.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_400",
      image = "graphic/temp/map_tile/0_400.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_401",
      image = "graphic/temp/map_tile/0_401.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_402",
      image = "graphic/temp/map_tile/0_402.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_403",
      image = "graphic/temp/map_tile/0_403.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_404",
      image = "graphic/temp/map_tile/0_404.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_405",
      image = "graphic/temp/map_tile/0_405.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_406",
      image = "graphic/temp/map_tile/0_406.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_407",
      image = "graphic/temp/map_tile/0_407.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_408",
      image = "graphic/temp/map_tile/0_408.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_409",
      image = "graphic/temp/map_tile/0_409.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_410",
      image = "graphic/temp/map_tile/0_410.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_411",
      image = "graphic/temp/map_tile/0_411.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_412",
      image = "graphic/temp/map_tile/0_412.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_413",
      image = "graphic/temp/map_tile/0_413.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_414",
      image = "graphic/temp/map_tile/0_414.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_415",
      image = "graphic/temp/map_tile/0_415.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_416",
      image = "graphic/temp/map_tile/0_416.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_417",
      image = "graphic/temp/map_tile/0_417.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_418",
      image = "graphic/temp/map_tile/0_418.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_419",
      image = "graphic/temp/map_tile/0_419.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_420",
      image = "graphic/temp/map_tile/0_420.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_421",
      image = "graphic/temp/map_tile/0_421.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_422",
      image = "graphic/temp/map_tile/0_422.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_423",
      image = "graphic/temp/map_tile/0_423.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_424",
      image = "graphic/temp/map_tile/0_424.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_425",
      image = "graphic/temp/map_tile/0_425.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_426",
      image = "graphic/temp/map_tile/0_426.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_427",
      image = "graphic/temp/map_tile/0_427.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_428",
      image = "graphic/temp/map_tile/0_428.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_429",
      image = "graphic/temp/map_tile/0_429.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_430",
      image = "graphic/temp/map_tile/0_430.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_431",
      image = "graphic/temp/map_tile/0_431.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_432",
      image = "graphic/temp/map_tile/0_432.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_433",
      image = "graphic/temp/map_tile/0_433.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_434",
      image = "graphic/temp/map_tile/0_434.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_435",
      image = "graphic/temp/map_tile/0_435.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_436",
      image = "graphic/temp/map_tile/0_436.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_437",
      image = "graphic/temp/map_tile/0_437.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_438",
      image = "graphic/temp/map_tile/0_438.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_439",
      image = "graphic/temp/map_tile/0_439.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_440",
      image = "graphic/temp/map_tile/0_440.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_441",
      image = "graphic/temp/map_tile/0_441.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_442",
      image = "graphic/temp/map_tile/0_442.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_443",
      image = "graphic/temp/map_tile/0_443.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_444",
      image = "graphic/temp/map_tile/0_444.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_445",
      image = "graphic/temp/map_tile/0_445.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_446",
      image = "graphic/temp/map_tile/0_446.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_447",
      image = "graphic/temp/map_tile/0_447.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_448",
      image = "graphic/temp/map_tile/0_448.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_449",
      image = "graphic/temp/map_tile/0_449.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_450",
      image = "graphic/temp/map_tile/0_450.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_451",
      image = "graphic/temp/map_tile/0_451.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_452",
      image = "graphic/temp/map_tile/0_452.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_453",
      image = "graphic/temp/map_tile/0_453.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_454",
      image = "graphic/temp/map_tile/0_454.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_455",
      image = "graphic/temp/map_tile/0_455.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_456",
      image = "graphic/temp/map_tile/0_456.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_457",
      image = "graphic/temp/map_tile/0_457.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_458",
      image = "graphic/temp/map_tile/0_458.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_459",
      image = "graphic/temp/map_tile/0_459.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_460",
      image = "graphic/temp/map_tile/0_460.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_461",
      image = "graphic/temp/map_tile/0_461.png"
   },
   {
      _id = "world_cliff_nw",
      effect = 5,
      id = "0_462",
      image = "graphic/temp/map_tile/0_462.png"
   },
   {
      _id = "world_cliff_n",
      effect = 5,
      id = "0_463",
      image = "graphic/temp/map_tile/0_463.png"
   },
   {
      _id = "world_cliff_ne",
      effect = 5,
      id = "0_464",
      image = "graphic/temp/map_tile/0_464.png"
   },
   {
      _id = "world_cliff_top_1",
      effect = 5,
      id = "0_465",
      image = "graphic/temp/map_tile/0_465.png"
   },
   {
      _id = "world_cliff_top_2",
      effect = 5,
      id = "0_466",
      image = "graphic/temp/map_tile/0_466.png"
   },
   {
      _id = "world_cliff_top_3",
      effect = 5,
      id = "0_467",
      image = "graphic/temp/map_tile/0_467.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_468",
      image = "graphic/temp/map_tile/0_468.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_469",
      image = "graphic/temp/map_tile/0_469.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_470",
      image = "graphic/temp/map_tile/0_470.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_471",
      image = "graphic/temp/map_tile/0_471.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_472",
      image = "graphic/temp/map_tile/0_472.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_473",
      image = "graphic/temp/map_tile/0_473.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_474",
      image = "graphic/temp/map_tile/0_474.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_475",
      image = "graphic/temp/map_tile/0_475.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_476",
      image = "graphic/temp/map_tile/0_476.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_477",
      image = "graphic/temp/map_tile/0_477.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_478",
      image = "graphic/temp/map_tile/0_478.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_479",
      image = "graphic/temp/map_tile/0_479.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_480",
      image = "graphic/temp/map_tile/0_480.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_481",
      image = "graphic/temp/map_tile/0_481.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_482",
      image = "graphic/temp/map_tile/0_482.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_483",
      image = "graphic/temp/map_tile/0_483.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_484",
      image = "graphic/temp/map_tile/0_484.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_485",
      image = "graphic/temp/map_tile/0_485.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_486",
      image = "graphic/temp/map_tile/0_486.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_487",
      image = "graphic/temp/map_tile/0_487.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_488",
      image = "graphic/temp/map_tile/0_488.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_489",
      image = "graphic/temp/map_tile/0_489.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_490",
      image = "graphic/temp/map_tile/0_490.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_491",
      image = "graphic/temp/map_tile/0_491.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_492",
      image = "graphic/temp/map_tile/0_492.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_493",
      image = "graphic/temp/map_tile/0_493.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_494",
      image = "graphic/temp/map_tile/0_494.png"
   },
   {
      _id = "world_cliff_w",
      effect = 5,
      id = "0_495",
      image = "graphic/temp/map_tile/0_495.png"
   },
   {
      _id = "world_cliff_c",
      effect = 5,
      id = "0_496",
      image = "graphic/temp/map_tile/0_496.png"
   },
   {
      _id = "world_cliff_e",
      effect = 5,
      id = "0_497",
      image = "graphic/temp/map_tile/0_497.png"
   },
   {
      _id = "world_cliff_inner_sw",
      effect = 5,
      id = "0_498",
      image = "graphic/temp/map_tile/0_498.png"
   },
   {
      _id = "world_cliff_top_4",
      effect = 5,
      id = "0_499",
      image = "graphic/temp/map_tile/0_499.png"
   },
   {
      _id = "world_cliff_inner_se",
      effect = 5,
      id = "0_500",
      image = "graphic/temp/map_tile/0_500.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_501",
      image = "graphic/temp/map_tile/0_501.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_502",
      image = "graphic/temp/map_tile/0_502.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_503",
      image = "graphic/temp/map_tile/0_503.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_504",
      image = "graphic/temp/map_tile/0_504.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_505",
      image = "graphic/temp/map_tile/0_505.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_506",
      image = "graphic/temp/map_tile/0_506.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_507",
      image = "graphic/temp/map_tile/0_507.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_508",
      image = "graphic/temp/map_tile/0_508.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_509",
      image = "graphic/temp/map_tile/0_509.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_510",
      image = "graphic/temp/map_tile/0_510.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_511",
      image = "graphic/temp/map_tile/0_511.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_512",
      image = "graphic/temp/map_tile/0_512.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_513",
      image = "graphic/temp/map_tile/0_513.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_514",
      image = "graphic/temp/map_tile/0_514.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_515",
      image = "graphic/temp/map_tile/0_515.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_516",
      image = "graphic/temp/map_tile/0_516.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_517",
      image = "graphic/temp/map_tile/0_517.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_518",
      image = "graphic/temp/map_tile/0_518.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_519",
      image = "graphic/temp/map_tile/0_519.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_520",
      image = "graphic/temp/map_tile/0_520.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_521",
      image = "graphic/temp/map_tile/0_521.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_522",
      image = "graphic/temp/map_tile/0_522.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_523",
      image = "graphic/temp/map_tile/0_523.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_524",
      image = "graphic/temp/map_tile/0_524.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_525",
      image = "graphic/temp/map_tile/0_525.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_526",
      image = "graphic/temp/map_tile/0_526.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_527",
      image = "graphic/temp/map_tile/0_527.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_528",
      image = "graphic/temp/map_tile/0_528.png"
   },
   {
      _id = "world_cliff_sw",
      effect = 5,
      id = "0_529",
      image = "graphic/temp/map_tile/0_529.png"
   },
   {
      _id = "world_cliff_s",
      effect = 5,
      id = "0_530",
      image = "graphic/temp/map_tile/0_530.png"
   },
   {
      _id = "world_cliff_se",
      effect = 5,
      id = "0_531",
      image = "graphic/temp/map_tile/0_531.png"
   },
   {
      _id = "world_cliff_inner_nw",
      effect = 5,
      id = "0_532",
      image = "graphic/temp/map_tile/0_532.png"
   },
   {
      _id = "world_cliff_top_5",
      effect = 5,
      id = "0_533",
      image = "graphic/temp/map_tile/0_533.png"
   },
   {
      _id = "world_cliff_inner_ne",
      effect = 5,
      id = "0_534",
      image = "graphic/temp/map_tile/0_534.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_535",
      image = "graphic/temp/map_tile/0_535.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_536",
      image = "graphic/temp/map_tile/0_536.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_537",
      image = "graphic/temp/map_tile/0_537.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_538",
      image = "graphic/temp/map_tile/0_538.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_539",
      image = "graphic/temp/map_tile/0_539.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_540",
      image = "graphic/temp/map_tile/0_540.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_541",
      image = "graphic/temp/map_tile/0_541.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_542",
      image = "graphic/temp/map_tile/0_542.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_543",
      image = "graphic/temp/map_tile/0_543.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_544",
      image = "graphic/temp/map_tile/0_544.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_545",
      image = "graphic/temp/map_tile/0_545.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_546",
      image = "graphic/temp/map_tile/0_546.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_547",
      image = "graphic/temp/map_tile/0_547.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_548",
      image = "graphic/temp/map_tile/0_548.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_549",
      image = "graphic/temp/map_tile/0_549.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_550",
      image = "graphic/temp/map_tile/0_550.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_551",
      image = "graphic/temp/map_tile/0_551.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_552",
      image = "graphic/temp/map_tile/0_552.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_553",
      image = "graphic/temp/map_tile/0_553.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_554",
      image = "graphic/temp/map_tile/0_554.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_555",
      image = "graphic/temp/map_tile/0_555.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_556",
      image = "graphic/temp/map_tile/0_556.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_557",
      image = "graphic/temp/map_tile/0_557.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_558",
      image = "graphic/temp/map_tile/0_558.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_559",
      image = "graphic/temp/map_tile/0_559.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_560",
      image = "graphic/temp/map_tile/0_560.png"
   },
   {
      _id = "world_grass_mountain_1",
      effect = 5,
      id = "0_561",
      image = "graphic/temp/map_tile/0_561.png"
   },
   {
      _id = "world_grass_mountain_2",
      effect = 5,
      id = "0_562",
      image = "graphic/temp/map_tile/0_562.png"
   },
   {
      _id = "world_mountain",
      effect = 5,
      id = "0_563",
      image = "graphic/temp/map_tile/0_563.png"
   },
   {
      _id = "world_grass_mountain_3",
      effect = 5,
      id = "0_564",
      image = "graphic/temp/map_tile/0_564.png"
   },
   {
      _id = "world_grass_mountain_4",
      effect = 5,
      id = "0_565",
      image = "graphic/temp/map_tile/0_565.png"
   },
   {
      _id = "world_grass_mountain_5",
      effect = 5,
      id = "0_566",
      image = "graphic/temp/map_tile/0_566.png"
   },
   {
      _id = "world_grass_mountain_6",
      effect = 5,
      id = "0_567",
      image = "graphic/temp/map_tile/0_567.png"
   },
   {
      _id = "world_snow_mountain_1",
      effect = 5,
      id = "0_568",
      image = "graphic/temp/map_tile/0_568.png",
      kind = 4
   },
   {
      _id = "world_snow_mountain_2",
      effect = 5,
      id = "0_569",
      image = "graphic/temp/map_tile/0_569.png",
      kind = 4
   },
   {
      _id = "world_snow_mountain_3",
      effect = 5,
      id = "0_570",
      image = "graphic/temp/map_tile/0_570.png",
      kind = 4
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_571",
      image = "graphic/temp/map_tile/0_571.png"
   },
   {
      _id = "world_grass_4",
      effect = 5,
      id = "0_572",
      image = "graphic/temp/map_tile/0_572.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_573",
      image = "graphic/temp/map_tile/0_573.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_574",
      image = "graphic/temp/map_tile/0_574.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_575",
      image = "graphic/temp/map_tile/0_575.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_576",
      image = "graphic/temp/map_tile/0_576.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_577",
      image = "graphic/temp/map_tile/0_577.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_578",
      image = "graphic/temp/map_tile/0_578.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_579",
      image = "graphic/temp/map_tile/0_579.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_580",
      image = "graphic/temp/map_tile/0_580.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_581",
      image = "graphic/temp/map_tile/0_581.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_582",
      image = "graphic/temp/map_tile/0_582.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_583",
      image = "graphic/temp/map_tile/0_583.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_584",
      image = "graphic/temp/map_tile/0_584.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_585",
      image = "graphic/temp/map_tile/0_585.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_586",
      image = "graphic/temp/map_tile/0_586.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_587",
      image = "graphic/temp/map_tile/0_587.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_588",
      image = "graphic/temp/map_tile/0_588.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_589",
      image = "graphic/temp/map_tile/0_589.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_590",
      image = "graphic/temp/map_tile/0_590.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_591",
      image = "graphic/temp/map_tile/0_591.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_592",
      image = "graphic/temp/map_tile/0_592.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_593",
      image = "graphic/temp/map_tile/0_593.png"
   },
   {
      _id = "world_desert_mountain_1",
      effect = 5,
      id = "0_594",
      image = "graphic/temp/map_tile/0_594.png",
      kind = 7
   },
   {
      _id = "world_desert_mountain_2",
      effect = 5,
      id = "0_595",
      image = "graphic/temp/map_tile/0_595.png",
      kind = 7
   },
   {
      _id = "world_desert_mountain_3",
      effect = 5,
      id = "0_596",
      image = "graphic/temp/map_tile/0_596.png",
      kind = 7
   },
   {
      _id = "world_desert_mountain_4",
      effect = 5,
      id = "0_597",
      image = "graphic/temp/map_tile/0_597.png",
      kind = 7
   },
   {
      _id = "world_desert_mountain_5",
      effect = 5,
      id = "0_598",
      image = "graphic/temp/map_tile/0_598.png",
      kind = 7
   },
   {
      _id = "world_dirt_mountain_1",
      effect = 5,
      id = "0_599",
      image = "graphic/temp/map_tile/0_599.png",
      kind = 8
   },
   {
      _id = "world_dirt_mountain_2",
      effect = 5,
      id = "0_600",
      image = "graphic/temp/map_tile/0_600.png",
      kind = 8
   },
   {
      _id = "world_dirt_5",
      effect = 5,
      id = "0_601",
      image = "graphic/temp/map_tile/0_601.png",
      kind = 8
   },
   {
      _id = "world_dirt_6",
      effect = 5,
      id = "0_602",
      image = "graphic/temp/map_tile/0_602.png",
      kind = 8
   },
   {
      _id = "world_dirt_8",
      effect = 5,
      id = "0_603",
      image = "graphic/temp/map_tile/0_603.png",
      kind = 8
   },
   {
      _id = "world_oasis_c",
      effect = 5,
      id = "0_604",
      image = "graphic/temp/map_tile/0_604.png",
      kind = 10
   },
   {
      _id = "world_oasis_e",
      effect = 5,
      id = "0_605",
      image = "graphic/temp/map_tile/0_605.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_w",
      effect = 5,
      id = "0_606",
      image = "graphic/temp/map_tile/0_606.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_s",
      effect = 5,
      id = "0_607",
      image = "graphic/temp/map_tile/0_607.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_n",
      effect = 5,
      id = "0_608",
      image = "graphic/temp/map_tile/0_608.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_corner_sw",
      effect = 5,
      id = "0_609",
      image = "graphic/temp/map_tile/0_609.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_corner_se",
      effect = 5,
      id = "0_610",
      image = "graphic/temp/map_tile/0_610.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_corner_ne",
      effect = 5,
      id = "0_611",
      image = "graphic/temp/map_tile/0_611.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_corner_nw",
      effect = 5,
      id = "0_612",
      image = "graphic/temp/map_tile/0_612.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_ne",
      effect = 5,
      id = "0_613",
      image = "graphic/temp/map_tile/0_613.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_nw",
      effect = 5,
      id = "0_614",
      image = "graphic/temp/map_tile/0_614.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_se",
      effect = 5,
      id = "0_615",
      image = "graphic/temp/map_tile/0_615.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "world_oasis_sw",
      effect = 5,
      id = "0_616",
      image = "graphic/temp/map_tile/0_616.png",
      kind = 10,
      kind2 = 9
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_617",
      image = "graphic/temp/map_tile/0_617.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_618",
      image = "graphic/temp/map_tile/0_618.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_619",
      image = "graphic/temp/map_tile/0_619.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_620",
      image = "graphic/temp/map_tile/0_620.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_621",
      image = "graphic/temp/map_tile/0_621.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_622",
      image = "graphic/temp/map_tile/0_622.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_623",
      image = "graphic/temp/map_tile/0_623.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_624",
      image = "graphic/temp/map_tile/0_624.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_625",
      image = "graphic/temp/map_tile/0_625.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_626",
      image = "graphic/temp/map_tile/0_626.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_627",
      image = "graphic/temp/map_tile/0_627.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_628",
      image = "graphic/temp/map_tile/0_628.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_629",
      image = "graphic/temp/map_tile/0_629.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_630",
      image = "graphic/temp/map_tile/0_630.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_631",
      image = "graphic/temp/map_tile/0_631.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_632",
      image = "graphic/temp/map_tile/0_632.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_633",
      image = "graphic/temp/map_tile/0_633.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_634",
      image = "graphic/temp/map_tile/0_634.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_635",
      image = "graphic/temp/map_tile/0_635.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_636",
      image = "graphic/temp/map_tile/0_636.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_637",
      image = "graphic/temp/map_tile/0_637.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_638",
      image = "graphic/temp/map_tile/0_638.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_639",
      image = "graphic/temp/map_tile/0_639.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_640",
      image = "graphic/temp/map_tile/0_640.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_641",
      image = "graphic/temp/map_tile/0_641.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_642",
      image = "graphic/temp/map_tile/0_642.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_643",
      image = "graphic/temp/map_tile/0_643.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_644",
      image = "graphic/temp/map_tile/0_644.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_645",
      image = "graphic/temp/map_tile/0_645.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_646",
      image = "graphic/temp/map_tile/0_646.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_647",
      image = "graphic/temp/map_tile/0_647.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_648",
      image = "graphic/temp/map_tile/0_648.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_649",
      image = "graphic/temp/map_tile/0_649.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_650",
      image = "graphic/temp/map_tile/0_650.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_651",
      image = "graphic/temp/map_tile/0_651.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_652",
      image = "graphic/temp/map_tile/0_652.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_653",
      image = "graphic/temp/map_tile/0_653.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_654",
      image = "graphic/temp/map_tile/0_654.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_655",
      image = "graphic/temp/map_tile/0_655.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_656",
      image = "graphic/temp/map_tile/0_656.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_657",
      image = "graphic/temp/map_tile/0_657.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_658",
      image = "graphic/temp/map_tile/0_658.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_659",
      image = "graphic/temp/map_tile/0_659.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_660",
      image = "graphic/temp/map_tile/0_660.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_661",
      image = "graphic/temp/map_tile/0_661.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_662",
      image = "graphic/temp/map_tile/0_662.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_663",
      image = "graphic/temp/map_tile/0_663.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_664",
      image = "graphic/temp/map_tile/0_664.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_665",
      image = "graphic/temp/map_tile/0_665.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_666",
      image = "graphic/temp/map_tile/0_666.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_667",
      image = "graphic/temp/map_tile/0_667.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_668",
      image = "graphic/temp/map_tile/0_668.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_669",
      image = "graphic/temp/map_tile/0_669.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_670",
      image = "graphic/temp/map_tile/0_670.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_671",
      image = "graphic/temp/map_tile/0_671.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_672",
      image = "graphic/temp/map_tile/0_672.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_673",
      image = "graphic/temp/map_tile/0_673.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_674",
      image = "graphic/temp/map_tile/0_674.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_675",
      image = "graphic/temp/map_tile/0_675.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_676",
      image = "graphic/temp/map_tile/0_676.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_677",
      image = "graphic/temp/map_tile/0_677.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_678",
      image = "graphic/temp/map_tile/0_678.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_679",
      image = "graphic/temp/map_tile/0_679.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_680",
      image = "graphic/temp/map_tile/0_680.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_681",
      image = "graphic/temp/map_tile/0_681.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_682",
      image = "graphic/temp/map_tile/0_682.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_683",
      image = "graphic/temp/map_tile/0_683.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_684",
      image = "graphic/temp/map_tile/0_684.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_685",
      image = "graphic/temp/map_tile/0_685.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_686",
      image = "graphic/temp/map_tile/0_686.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_687",
      image = "graphic/temp/map_tile/0_687.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_688",
      image = "graphic/temp/map_tile/0_688.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_689",
      image = "graphic/temp/map_tile/0_689.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_690",
      image = "graphic/temp/map_tile/0_690.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_691",
      image = "graphic/temp/map_tile/0_691.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_692",
      image = "graphic/temp/map_tile/0_692.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_693",
      image = "graphic/temp/map_tile/0_693.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_694",
      image = "graphic/temp/map_tile/0_694.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_695",
      image = "graphic/temp/map_tile/0_695.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_696",
      image = "graphic/temp/map_tile/0_696.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_697",
      image = "graphic/temp/map_tile/0_697.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_698",
      image = "graphic/temp/map_tile/0_698.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_699",
      image = "graphic/temp/map_tile/0_699.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_700",
      image = "graphic/temp/map_tile/0_700.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_701",
      image = "graphic/temp/map_tile/0_701.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_702",
      image = "graphic/temp/map_tile/0_702.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_703",
      image = "graphic/temp/map_tile/0_703.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_704",
      image = "graphic/temp/map_tile/0_704.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_705",
      image = "graphic/temp/map_tile/0_705.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_706",
      image = "graphic/temp/map_tile/0_706.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_707",
      image = "graphic/temp/map_tile/0_707.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_708",
      image = "graphic/temp/map_tile/0_708.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_709",
      image = "graphic/temp/map_tile/0_709.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_710",
      image = "graphic/temp/map_tile/0_710.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_711",
      image = "graphic/temp/map_tile/0_711.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_712",
      image = "graphic/temp/map_tile/0_712.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_713",
      image = "graphic/temp/map_tile/0_713.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_714",
      image = "graphic/temp/map_tile/0_714.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_715",
      image = "graphic/temp/map_tile/0_715.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_716",
      image = "graphic/temp/map_tile/0_716.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_717",
      image = "graphic/temp/map_tile/0_717.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_718",
      image = "graphic/temp/map_tile/0_718.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_719",
      image = "graphic/temp/map_tile/0_719.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_720",
      image = "graphic/temp/map_tile/0_720.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_721",
      image = "graphic/temp/map_tile/0_721.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_722",
      image = "graphic/temp/map_tile/0_722.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_723",
      image = "graphic/temp/map_tile/0_723.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_724",
      image = "graphic/temp/map_tile/0_724.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_725",
      image = "graphic/temp/map_tile/0_725.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_726",
      image = "graphic/temp/map_tile/0_726.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_727",
      image = "graphic/temp/map_tile/0_727.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_728",
      image = "graphic/temp/map_tile/0_728.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_729",
      image = "graphic/temp/map_tile/0_729.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_730",
      image = "graphic/temp/map_tile/0_730.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_731",
      image = "graphic/temp/map_tile/0_731.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_732",
      image = "graphic/temp/map_tile/0_732.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_733",
      image = "graphic/temp/map_tile/0_733.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_734",
      image = "graphic/temp/map_tile/0_734.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_735",
      image = "graphic/temp/map_tile/0_735.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_736",
      image = "graphic/temp/map_tile/0_736.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_737",
      image = "graphic/temp/map_tile/0_737.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_738",
      image = "graphic/temp/map_tile/0_738.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_739",
      image = "graphic/temp/map_tile/0_739.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_740",
      image = "graphic/temp/map_tile/0_740.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_741",
      image = "graphic/temp/map_tile/0_741.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_742",
      image = "graphic/temp/map_tile/0_742.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_743",
      image = "graphic/temp/map_tile/0_743.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_744",
      image = "graphic/temp/map_tile/0_744.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_745",
      image = "graphic/temp/map_tile/0_745.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_746",
      image = "graphic/temp/map_tile/0_746.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_747",
      image = "graphic/temp/map_tile/0_747.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_748",
      image = "graphic/temp/map_tile/0_748.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_749",
      image = "graphic/temp/map_tile/0_749.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_750",
      image = "graphic/temp/map_tile/0_750.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_751",
      image = "graphic/temp/map_tile/0_751.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_752",
      image = "graphic/temp/map_tile/0_752.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_753",
      image = "graphic/temp/map_tile/0_753.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_754",
      image = "graphic/temp/map_tile/0_754.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_755",
      image = "graphic/temp/map_tile/0_755.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_756",
      image = "graphic/temp/map_tile/0_756.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_757",
      image = "graphic/temp/map_tile/0_757.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_758",
      image = "graphic/temp/map_tile/0_758.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_759",
      image = "graphic/temp/map_tile/0_759.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_760",
      image = "graphic/temp/map_tile/0_760.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_761",
      image = "graphic/temp/map_tile/0_761.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_762",
      image = "graphic/temp/map_tile/0_762.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_763",
      image = "graphic/temp/map_tile/0_763.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_764",
      image = "graphic/temp/map_tile/0_764.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_765",
      image = "graphic/temp/map_tile/0_765.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_766",
      image = "graphic/temp/map_tile/0_766.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_767",
      image = "graphic/temp/map_tile/0_767.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_768",
      image = "graphic/temp/map_tile/0_768.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_769",
      image = "graphic/temp/map_tile/0_769.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_770",
      image = "graphic/temp/map_tile/0_770.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_771",
      image = "graphic/temp/map_tile/0_771.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_772",
      image = "graphic/temp/map_tile/0_772.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_773",
      image = "graphic/temp/map_tile/0_773.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_774",
      image = "graphic/temp/map_tile/0_774.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_775",
      image = "graphic/temp/map_tile/0_775.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_776",
      image = "graphic/temp/map_tile/0_776.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_777",
      image = "graphic/temp/map_tile/0_777.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_778",
      image = "graphic/temp/map_tile/0_778.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_779",
      image = "graphic/temp/map_tile/0_779.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_780",
      image = "graphic/temp/map_tile/0_780.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_781",
      image = "graphic/temp/map_tile/0_781.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_782",
      image = "graphic/temp/map_tile/0_782.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_783",
      image = "graphic/temp/map_tile/0_783.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_784",
      image = "graphic/temp/map_tile/0_784.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_785",
      image = "graphic/temp/map_tile/0_785.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_786",
      image = "graphic/temp/map_tile/0_786.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_787",
      image = "graphic/temp/map_tile/0_787.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_788",
      image = "graphic/temp/map_tile/0_788.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_789",
      image = "graphic/temp/map_tile/0_789.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_790",
      image = "graphic/temp/map_tile/0_790.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_791",
      image = "graphic/temp/map_tile/0_791.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_792",
      image = "graphic/temp/map_tile/0_792.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_793",
      image = "graphic/temp/map_tile/0_793.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_794",
      image = "graphic/temp/map_tile/0_794.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_795",
      image = "graphic/temp/map_tile/0_795.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_796",
      image = "graphic/temp/map_tile/0_796.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_797",
      image = "graphic/temp/map_tile/0_797.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_798",
      image = "graphic/temp/map_tile/0_798.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_799",
      image = "graphic/temp/map_tile/0_799.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_800",
      image = "graphic/temp/map_tile/0_800.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_801",
      image = "graphic/temp/map_tile/0_801.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_802",
      image = "graphic/temp/map_tile/0_802.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_803",
      image = "graphic/temp/map_tile/0_803.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_804",
      image = "graphic/temp/map_tile/0_804.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_805",
      image = "graphic/temp/map_tile/0_805.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_806",
      image = "graphic/temp/map_tile/0_806.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_807",
      image = "graphic/temp/map_tile/0_807.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_808",
      image = "graphic/temp/map_tile/0_808.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_809",
      image = "graphic/temp/map_tile/0_809.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_810",
      image = "graphic/temp/map_tile/0_810.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_811",
      image = "graphic/temp/map_tile/0_811.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_812",
      image = "graphic/temp/map_tile/0_812.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_813",
      image = "graphic/temp/map_tile/0_813.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_814",
      image = "graphic/temp/map_tile/0_814.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_815",
      image = "graphic/temp/map_tile/0_815.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_816",
      image = "graphic/temp/map_tile/0_816.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_817",
      image = "graphic/temp/map_tile/0_817.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_818",
      image = "graphic/temp/map_tile/0_818.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_819",
      image = "graphic/temp/map_tile/0_819.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_820",
      image = "graphic/temp/map_tile/0_820.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_821",
      image = "graphic/temp/map_tile/0_821.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_822",
      image = "graphic/temp/map_tile/0_822.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_823",
      image = "graphic/temp/map_tile/0_823.png"
   },
   {
      _id = "blank",
      effect = 5,
      id = "0_824",
      image = "graphic/temp/map_tile/0_824.png"
   },
   {
      _id = "grass",
      id = "1_0",
      image = "graphic/temp/map_tile/1_0.png"
   },
   {
      _id = "grass_violets",
      id = "1_1",
      image = "graphic/temp/map_tile/1_1.png"
   },
   {
      _id = "grass_rocks",
      id = "1_2",
      image = "graphic/temp/map_tile/1_2.png"
   },
   {
      _id = "grass_tall_1",
      id = "1_3",
      image = "graphic/temp/map_tile/1_3.png"
   },
   {
      _id = "grass_tall_2",
      id = "1_4",
      image = "graphic/temp/map_tile/1_4.png"
   },
   {
      _id = "grass_patch_1",
      id = "1_5",
      image = "graphic/temp/map_tile/1_5.png"
   },
   {
      _id = "grass_patch_2",
      id = "1_6",
      image = "graphic/temp/map_tile/1_6.png"
   },
   {
      _id = "grass_bush_1",
      id = "1_7",
      image = "graphic/temp/map_tile/1_7.png"
   },
   {
      _id = "grass_bush_2",
      id = "1_8",
      image = "graphic/temp/map_tile/1_8.png"
   },
   {
      _id = "grass_bush_3",
      id = "1_9",
      image = "graphic/temp/map_tile/1_9.png"
   },
   {
      _id = "grass_patch_3",
      id = "1_10",
      image = "graphic/temp/map_tile/1_10.png"
   },
   {
      _id = "grass_rocks_2",
      id = "1_11",
      image = "graphic/temp/map_tile/1_11.png"
   },
   {
      _id = "crater",
      id = "1_12",
      image = "graphic/temp/map_tile/1_12.png"
   },
   {
      _id = "cracks",
      id = "1_13",
      image = "graphic/temp/map_tile/1_13.png"
   },
   {
      _id = "blank",
      id = "1_14",
      image = "graphic/temp/map_tile/1_14.png"
   },
   {
      _id = "blank",
      id = "1_15",
      image = "graphic/temp/map_tile/1_15.png"
   },
   {
      _id = "desert_rocks_1",
      id = "1_16",
      image = "graphic/temp/map_tile/1_16.png"
   },
   {
      _id = "desert_rocks_2",
      id = "1_17",
      image = "graphic/temp/map_tile/1_17.png"
   },
   {
      _id = "desert_rocks_3",
      id = "1_18",
      image = "graphic/temp/map_tile/1_18.png"
   },
   {
      _id = "desert",
      id = "1_19",
      image = "graphic/temp/map_tile/1_19.png"
   },
   {
      _id = "desert_flowers_1",
      id = "1_20",
      image = "graphic/temp/map_tile/1_20.png"
   },
   {
      _id = "desert_flowers_2",
      id = "1_21",
      image = "graphic/temp/map_tile/1_21.png"
   },
   {
      _id = "desert_flowers_3",
      id = "1_22",
      image = "graphic/temp/map_tile/1_22.png"
   },
   {
      _id = "blank",
      id = "1_23",
      image = "graphic/temp/map_tile/1_23.png"
   },
   {
      _id = "blank",
      id = "1_24",
      image = "graphic/temp/map_tile/1_24.png"
   },
   {
      _id = "blank",
      id = "1_25",
      image = "graphic/temp/map_tile/1_25.png"
   },
   {
      _id = "blank",
      id = "1_26",
      image = "graphic/temp/map_tile/1_26.png"
   },
   {
      _id = "blank",
      id = "1_27",
      image = "graphic/temp/map_tile/1_27.png"
   },
   {
      _id = "blank",
      id = "1_28",
      image = "graphic/temp/map_tile/1_28.png"
   },
   {
      _id = "grass_rock",
      id = "1_29",
      image = "graphic/temp/map_tile/1_29.png",
      kind = 1
   },
   {
      _id = "field_1",
      id = "1_30",
      image = "graphic/temp/map_tile/1_30.png",
      kind = 2
   },
   {
      _id = "field_2",
      id = "1_31",
      image = "graphic/temp/map_tile/1_31.png",
      kind = 2
   },
   {
      _id = "blank",
      id = "1_32",
      image = "graphic/temp/map_tile/1_32.png"
   },
   {
      _id = "dark_dirt_1",
      id = "1_33",
      image = "graphic/temp/map_tile/1_33.png"
   },
   {
      _id = "dark_dirt_2",
      id = "1_34",
      image = "graphic/temp/map_tile/1_34.png"
   },
   {
      _id = "dark_dirt_3",
      id = "1_35",
      image = "graphic/temp/map_tile/1_35.png"
   },
   {
      _id = "dark_dirt_4",
      id = "1_36",
      image = "graphic/temp/map_tile/1_36.png"
   },
   {
      _id = "destroyed",
      id = "1_37",
      image = "graphic/temp/map_tile/1_37.png"
   },
   {
      _id = "dirt_patch",
      id = "1_38",
      image = "graphic/temp/map_tile/1_38.png"
   },
   {
      _id = "dirt_grass",
      id = "1_39",
      image = "graphic/temp/map_tile/1_39.png"
   },
   {
      _id = "dirt_rocks",
      id = "1_40",
      image = "graphic/temp/map_tile/1_40.png"
   },
   {
      _id = "dirt",
      id = "1_41",
      image = "graphic/temp/map_tile/1_41.png"
   },
   {
      _id = "dirt_2",
      id = "1_42",
      image = "graphic/temp/map_tile/1_42.png"
   },
   {
      _id = "metal_plating",
      id = "1_43",
      image = "graphic/temp/map_tile/1_43.png"
   },
   {
      _id = "vines",
      id = "1_44",
      image = "graphic/temp/map_tile/1_44.png"
   },
   {
      _id = "snow",
      id = "1_45",
      image = "graphic/temp/map_tile/1_45.png",
      kind = 4
   },
   {
      _id = "snow_mound",
      id = "1_46",
      image = "graphic/temp/map_tile/1_46.png",
      kind = 4
   },
   {
      _id = "snow_plants",
      id = "1_47",
      image = "graphic/temp/map_tile/1_47.png",
      kind = 4
   },
   {
      _id = "snow_rock",
      id = "1_48",
      image = "graphic/temp/map_tile/1_48.png",
      kind = 4
   },
   {
      _id = "snow_stump",
      id = "1_49",
      image = "graphic/temp/map_tile/1_49.png",
      kind = 4
   },
   {
      _id = "snow_flowers_1",
      id = "1_50",
      image = "graphic/temp/map_tile/1_50.png",
      kind = 4
   },
   {
      _id = "snow_flowers_2",
      id = "1_51",
      image = "graphic/temp/map_tile/1_51.png",
      kind = 4
   },
   {
      _id = "snow_flowers_3",
      id = "1_52",
      image = "graphic/temp/map_tile/1_52.png",
      kind = 4
   },
   {
      _id = "snow_field_1",
      id = "1_53",
      image = "graphic/temp/map_tile/1_53.png",
      kind = 4
   },
   {
      _id = "snow_field_2",
      id = "1_54",
      image = "graphic/temp/map_tile/1_54.png",
      kind = 4
   },
   {
      _id = "snow_ice",
      id = "1_55",
      image = "graphic/temp/map_tile/1_55.png",
      kind = 4
   },
   {
      _id = "snow_clumps_1",
      id = "1_56",
      image = "graphic/temp/map_tile/1_56.png",
      kind = 4
   },
   {
      _id = "snow_clumps_2",
      id = "1_57",
      image = "graphic/temp/map_tile/1_57.png",
      kind = 4
   },
   {
      _id = "snow_stalks",
      id = "1_58",
      image = "graphic/temp/map_tile/1_58.png",
      kind = 4
   },
   {
      _id = "snow_grass",
      id = "1_59",
      image = "graphic/temp/map_tile/1_59.png",
      kind = 4
   },
   {
      _id = "snow_blue_tile",
      id = "1_60",
      image = "graphic/temp/map_tile/1_60.png",
      kind = 4
   },
   {
      _id = "snow_cobble_1",
      id = "1_61",
      image = "graphic/temp/map_tile/1_61.png"
   },
   {
      _id = "snow_cobble_2",
      id = "1_62",
      image = "graphic/temp/map_tile/1_62.png"
   },
   {
      _id = "snow_cobble_3",
      id = "1_63",
      image = "graphic/temp/map_tile/1_63.png"
   },
   {
      _id = "snow_cobble_4",
      id = "1_64",
      image = "graphic/temp/map_tile/1_64.png"
   },
   {
      _id = "snow_stairs",
      id = "1_65",
      image = "graphic/temp/map_tile/1_65.png"
   },
   {
      _id = "tower_of_fire_tile_1",
      id = "1_66",
      image = "graphic/temp/map_tile/1_66.png"
   },
   {
      _id = "tower_of_fire_tile_2",
      id = "1_67",
      image = "graphic/temp/map_tile/1_67.png"
   },
   {
      _id = "tower_of_fire_tile_3",
      id = "1_68",
      image = "graphic/temp/map_tile/1_68.png"
   },
   {
      _id = "raised_platform",
      id = "1_69",
      image = "graphic/temp/map_tile/1_69.png"
   },
   {
      _id = "hardwood_floor_1",
      id = "1_70",
      image = "graphic/temp/map_tile/1_70.png"
   },
   {
      _id = "hardwood_floor_2",
      id = "1_71",
      image = "graphic/temp/map_tile/1_71.png"
   },
   {
      _id = "hardwood_floor_3",
      id = "1_72",
      image = "graphic/temp/map_tile/1_72.png"
   },
   {
      _id = "hardwood_floor_4",
      id = "1_73",
      image = "graphic/temp/map_tile/1_73.png"
   },
   {
      _id = "hardwood_floor_5",
      id = "1_74",
      image = "graphic/temp/map_tile/1_74.png"
   },
   {
      _id = "hardwood_floor_6",
      id = "1_75",
      image = "graphic/temp/map_tile/1_75.png"
   },
   {
      _id = "metal_plating_rusted",
      id = "1_76",
      image = "graphic/temp/map_tile/1_76.png"
   },
   {
      _id = "thatching",
      id = "1_77",
      image = "graphic/temp/map_tile/1_77.png"
   },
   {
      _id = "cobble",
      id = "1_78",
      image = "graphic/temp/map_tile/1_78.png"
   },
   {
      _id = "concrete",
      id = "1_79",
      image = "graphic/temp/map_tile/1_79.png"
   },
   {
      _id = "crystal",
      id = "1_80",
      image = "graphic/temp/map_tile/1_80.png"
   },
   {
      _id = "cobble_2",
      id = "1_81",
      image = "graphic/temp/map_tile/1_81.png"
   },
   {
      _id = "snow_flowers_4",
      id = "1_82",
      image = "graphic/temp/map_tile/1_82.png",
      kind = 4
   },
   {
      _id = "snow_flowers_5",
      id = "1_83",
      image = "graphic/temp/map_tile/1_83.png",
      kind = 4
   },
   {
      _id = "snow_flowers_6",
      id = "1_84",
      image = "graphic/temp/map_tile/1_84.png",
      kind = 4
   },
   {
      _id = "snow_bushes_1",
      id = "1_85",
      image = "graphic/temp/map_tile/1_85.png"
   },
   {
      _id = "snow_bushes_2",
      id = "1_86",
      image = "graphic/temp/map_tile/1_86.png"
   },
   {
      _id = "snow_bushes_3",
      id = "1_87",
      image = "graphic/temp/map_tile/1_87.png"
   },
   {
      _id = "snow_bush",
      id = "1_88",
      image = "graphic/temp/map_tile/1_88.png"
   },
   {
      _id = "snow_boulder",
      id = "1_89",
      image = "graphic/temp/map_tile/1_89.png"
   },
   {
      _id = "snow_railroad_tracks",
      id = "1_90",
      image = "graphic/temp/map_tile/1_90.png"
   },
   {
      _id = "snow_2",
      id = "1_91",
      image = "graphic/temp/map_tile/1_91.png"
   },
   {
      _id = "snow_3",
      id = "1_92",
      image = "graphic/temp/map_tile/1_92.png"
   },
   {
      _id = "snow_4",
      id = "1_93",
      image = "graphic/temp/map_tile/1_93.png"
   },
   {
      _id = "blank",
      id = "1_94",
      image = "graphic/temp/map_tile/1_94.png"
   },
   {
      _id = "blank",
      id = "1_95",
      image = "graphic/temp/map_tile/1_95.png"
   },
   {
      _id = "blank",
      id = "1_96",
      image = "graphic/temp/map_tile/1_96.png"
   },
   {
      _id = "blank",
      id = "1_97",
      image = "graphic/temp/map_tile/1_97.png"
   },
   {
      _id = "snow_pillar",
      id = "1_98",
      image = "graphic/temp/map_tile/1_98.png"
   },
   {
      _id = "cobble_3",
      id = "1_99",
      image = "graphic/temp/map_tile/1_99.png"
   },
   {
      _id = "concrete_2",
      id = "1_100",
      image = "graphic/temp/map_tile/1_100.png"
   },
   {
      _id = "flooring_1",
      id = "1_101",
      image = "graphic/temp/map_tile/1_101.png"
   },
   {
      _id = "flooring_2",
      id = "1_102",
      image = "graphic/temp/map_tile/1_102.png"
   },
   {
      _id = "cobble_4",
      id = "1_103",
      image = "graphic/temp/map_tile/1_103.png"
   },
   {
      _id = "cobble_5",
      id = "1_104",
      image = "graphic/temp/map_tile/1_104.png"
   },
   {
      _id = "cobble_6",
      id = "1_105",
      image = "graphic/temp/map_tile/1_105.png"
   },
   {
      _id = "cobble_7",
      id = "1_106",
      image = "graphic/temp/map_tile/1_106.png"
   },
   {
      _id = "concrete_3",
      id = "1_107",
      image = "graphic/temp/map_tile/1_107.png"
   },
   {
      _id = "cobble_8",
      id = "1_108",
      image = "graphic/temp/map_tile/1_108.png"
   },
   {
      _id = "cobble_9",
      id = "1_109",
      image = "graphic/temp/map_tile/1_109.png"
   },
   {
      _id = "cobble_10",
      id = "1_110",
      image = "graphic/temp/map_tile/1_110.png"
   },
   {
      _id = "cobble_11",
      id = "1_111",
      image = "graphic/temp/map_tile/1_111.png"
   },
   {
      _id = "cobble_12",
      id = "1_112",
      image = "graphic/temp/map_tile/1_112.png"
   },
   {
      _id = "cobble_diagonal",
      id = "1_113",
      image = "graphic/temp/map_tile/1_113.png"
   },
   {
      _id = "cobble_diagonal_round",
      id = "1_114",
      image = "graphic/temp/map_tile/1_114.png"
   },
   {
      _id = "cobble_diagonal_raised",
      id = "1_115",
      image = "graphic/temp/map_tile/1_115.png"
   },
   {
      _id = "tiling_1",
      id = "1_116",
      image = "graphic/temp/map_tile/1_116.png"
   },
   {
      _id = "tiling_2",
      id = "1_117",
      image = "graphic/temp/map_tile/1_117.png"
   },
   {
      _id = "hardwood_floor_7",
      id = "1_118",
      image = "graphic/temp/map_tile/1_118.png"
   },
   {
      _id = "cobble_dark_1",
      id = "1_119",
      image = "graphic/temp/map_tile/1_119.png"
   },
   {
      _id = "cobble_dark_2",
      id = "1_120",
      image = "graphic/temp/map_tile/1_120.png"
   },
   {
      _id = "cobble_dark_3",
      id = "1_121",
      image = "graphic/temp/map_tile/1_121.png"
   },
   {
      _id = "cobble_dark_4",
      id = "1_122",
      image = "graphic/temp/map_tile/1_122.png"
   },
   {
      _id = "rough_1",
      id = "1_123",
      image = "graphic/temp/map_tile/1_123.png"
   },
   {
      _id = "rough_2",
      id = "1_124",
      image = "graphic/temp/map_tile/1_124.png"
   },
   {
      _id = "rough_3",
      id = "1_125",
      image = "graphic/temp/map_tile/1_125.png"
   },
   {
      _id = "rough_4",
      id = "1_126",
      image = "graphic/temp/map_tile/1_126.png"
   },
   {
      _id = "rough_5",
      id = "1_127",
      image = "graphic/temp/map_tile/1_127.png"
   },
   {
      _id = "rough_6",
      id = "1_128",
      image = "graphic/temp/map_tile/1_128.png"
   },
   {
      _id = "rough_7",
      id = "1_129",
      image = "graphic/temp/map_tile/1_129.png"
   },
   {
      _id = "rough_8",
      id = "1_130",
      image = "graphic/temp/map_tile/1_130.png"
   },
   {
      _id = "rough_9",
      id = "1_131",
      image = "graphic/temp/map_tile/1_131.png"
   },
   {
      _id = "tile_1",
      id = "1_132",
      image = "graphic/temp/map_tile/1_132.png"
   },
   {
      _id = "tile_2",
      id = "1_133",
      image = "graphic/temp/map_tile/1_133.png"
   },
   {
      _id = "tile_3",
      id = "1_134",
      image = "graphic/temp/map_tile/1_134.png"
   },
   {
      _id = "brick_1",
      id = "1_135",
      image = "graphic/temp/map_tile/1_135.png"
   },
   {
      _id = "brick_2",
      id = "1_136",
      image = "graphic/temp/map_tile/1_136.png"
   },
   {
      _id = "cobble_caution",
      id = "1_137",
      image = "graphic/temp/map_tile/1_137.png"
   },
   {
      _id = "concrete_4",
      id = "1_138",
      image = "graphic/temp/map_tile/1_138.png"
   },
   {
      _id = "concrete_tiled",
      id = "1_139",
      image = "graphic/temp/map_tile/1_139.png"
   },
   {
      _id = "shop_platform",
      id = "1_140",
      image = "graphic/temp/map_tile/1_140.png"
   },
   {
      _id = "metal_dark",
      id = "1_141",
      image = "graphic/temp/map_tile/1_141.png"
   },
   {
      _id = "metal_raised",
      id = "1_142",
      image = "graphic/temp/map_tile/1_142.png"
   },
   {
      _id = "blank",
      id = "1_143",
      image = "graphic/temp/map_tile/1_143.png"
   },
   {
      _id = "cobble_wall_roof",
      id = "1_144",
      image = "graphic/temp/map_tile/1_144.png"
   },
   {
      _id = "conrete_bordered",
      id = "1_145",
      image = "graphic/temp/map_tile/1_145.png"
   },
   {
      _id = "carpet_1",
      id = "1_146",
      image = "graphic/temp/map_tile/1_146.png"
   },
   {
      _id = "hardwood_bordered",
      id = "1_147",
      image = "graphic/temp/map_tile/1_147.png"
   },
   {
      _id = "tatami_1",
      id = "1_148",
      image = "graphic/temp/map_tile/1_148.png"
   },
   {
      _id = "tatami_2",
      id = "1_149",
      image = "graphic/temp/map_tile/1_149.png"
   },
   {
      _id = "cyber_1",
      id = "1_150",
      image = "graphic/temp/map_tile/1_150.png"
   },
   {
      _id = "cyber_2",
      id = "1_151",
      image = "graphic/temp/map_tile/1_151.png"
   },
   {
      _id = "cyber_3",
      id = "1_152",
      image = "graphic/temp/map_tile/1_152.png"
   },
   {
      _id = "cyber_4",
      id = "1_153",
      image = "graphic/temp/map_tile/1_153.png"
   },
   {
      _id = "cyber_bordered",
      id = "1_154",
      image = "graphic/temp/map_tile/1_154.png"
   },
   {
      _id = "cyber_grid",
      id = "1_155",
      image = "graphic/temp/map_tile/1_155.png"
   },
   {
      _id = "carpet_nw",
      id = "1_156",
      image = "graphic/temp/map_tile/1_156.png"
   },
   {
      _id = "carpet_n",
      id = "1_157",
      image = "graphic/temp/map_tile/1_157.png"
   },
   {
      _id = "carpet_ne",
      id = "1_158",
      image = "graphic/temp/map_tile/1_158.png"
   },
   {
      _id = "carpet_sw",
      id = "1_159",
      image = "graphic/temp/map_tile/1_159.png"
   },
   {
      _id = "carpet_s",
      id = "1_160",
      image = "graphic/temp/map_tile/1_160.png"
   },
   {
      _id = "carpet_se",
      id = "1_161",
      image = "graphic/temp/map_tile/1_161.png"
   },
   {
      _id = "rough_10",
      id = "1_162",
      image = "graphic/temp/map_tile/1_162.png"
   },
   {
      _id = "rough_11",
      id = "1_163",
      image = "graphic/temp/map_tile/1_163.png"
   },
   {
      _id = "rough_12",
      id = "1_164",
      image = "graphic/temp/map_tile/1_164.png"
   },
   {
      _id = "anime_water_shallow",
      id = "1_165",
      image = {
         "graphic/temp/map_tile/1_165.png",
         "graphic/temp/map_tile/1_166.png",
         "graphic/temp/map_tile/1_167.png",
      },
      kind = 3
   },
   {
      _id = "anime_water_sea",
      anime_frame = 3,
      id = "1_168",
      image = {
         "graphic/temp/map_tile/1_168.png",
         "graphic/temp/map_tile/1_169.png",
         "graphic/temp/map_tile/1_170.png",
      },
      kind = 3
   },
   {
      _id = "anime_water_hot_spring",
      anime_frame = 3,
      id = "1_171",
      image = {
         "graphic/temp/map_tile/1_171.png",
         "graphic/temp/map_tile/1_172.png",
         "graphic/temp/map_tile/1_173.png",
      },
      kind = 3,
      kind2 = 5
   },
   {
      _id = "cobble_wall_top",
      id = "1_177",
      image = "graphic/temp/map_tile/1_177.png"
   },
   {
      _id = "ice_cobble",
      id = "1_178",
      image = "graphic/temp/map_tile/1_178.png"
   },
   {
      _id = "ice_tiled_1",
      id = "1_179",
      image = "graphic/temp/map_tile/1_179.png"
   },
   {
      _id = "ice_tiled_2",
      id = "1_180",
      image = "graphic/temp/map_tile/1_180.png"
   },
   {
      _id = "ice_tiled_3",
      id = "1_181",
      image = "graphic/temp/map_tile/1_181.png"
   },
   {
      _id = "ice",
      id = "1_182",
      image = "graphic/temp/map_tile/1_182.png"
   },
   {
      _id = "ice_tiled_4",
      id = "1_183",
      image = "graphic/temp/map_tile/1_183.png"
   },
   {
      _id = "ice_stairs_1",
      id = "1_184",
      image = "graphic/temp/map_tile/1_184.png"
   },
   {
      _id = "blank",
      id = "1_185",
      image = "graphic/temp/map_tile/1_185.png"
   },
   {
      _id = "ice_stairs_2",
      id = "1_186",
      image = "graphic/temp/map_tile/1_186.png"
   },
   {
      _id = "blank",
      id = "1_187",
      image = "graphic/temp/map_tile/1_187.png"
   },
   {
      _id = "bridge_we",
      id = "1_188",
      image = "graphic/temp/map_tile/1_188.png"
   },
   {
      _id = "red_stairs",
      id = "1_189",
      image = "graphic/temp/map_tile/1_189.png"
   },
   {
      _id = "cobble_stairs",
      id = "1_190",
      image = "graphic/temp/map_tile/1_190.png"
   },
   {
      _id = "cobble_raised",
      id = "1_191",
      image = "graphic/temp/map_tile/1_191.png"
   },
   {
      _id = "bridge_ns",
      id = "1_192",
      image = "graphic/temp/map_tile/1_192.png"
   },
   {
      _id = "cobble_raised_2",
      id = "1_193",
      image = "graphic/temp/map_tile/1_193.png"
   },
   {
      _id = "cobble_pedestal",
      id = "1_194",
      image = "graphic/temp/map_tile/1_194.png"
   },
   {
      _id = "concrete_indented",
      id = "1_195",
      image = "graphic/temp/map_tile/1_195.png"
   },
   {
      _id = "cobble_raised_3",
      id = "1_196",
      image = "graphic/temp/map_tile/1_196.png"
   },
   {
      _id = "blank",
      id = "1_197",
      image = "graphic/temp/map_tile/1_197.png"
   },
   {
      _id = "church_floor",
      id = "1_198",
      image = "graphic/temp/map_tile/1_198.png"
   },
   {
      _id = "church_symbol",
      id = "1_199",
      image = "graphic/temp/map_tile/1_199.png"
   },
   {
      _id = "tiled_diagonal",
      id = "1_200",
      image = "graphic/temp/map_tile/1_200.png"
   },
   {
      _id = "carpet_red",
      id = "1_201",
      image = "graphic/temp/map_tile/1_201.png"
   },
   {
      _id = "tiled",
      id = "1_202",
      image = "graphic/temp/map_tile/1_202.png"
   },
   {
      _id = "carpet_green",
      id = "1_203",
      image = "graphic/temp/map_tile/1_203.png"
   },
   {
      _id = "carpet_blue",
      id = "1_204",
      image = "graphic/temp/map_tile/1_204.png"
   },
   {
      _id = "wood_floor_1",
      id = "1_205",
      image = "graphic/temp/map_tile/1_205.png"
   },
   {
      _id = "wood_floor_2",
      id = "1_206",
      image = "graphic/temp/map_tile/1_206.png"
   },
   {
      _id = "wood_floor_3",
      id = "1_207",
      image = "graphic/temp/map_tile/1_207.png"
   },
   {
      _id = "wood_floor_4",
      id = "1_208",
      image = "graphic/temp/map_tile/1_208.png"
   },
   {
      _id = "wood_stair",
      id = "1_209",
      image = "graphic/temp/map_tile/1_209.png"
   },
   {
      _id = "cobble_wall_bottom",
      id = "1_210",
      image = "graphic/temp/map_tile/1_210.png"
   },
   {
      _id = "marble",
      id = "1_211",
      image = "graphic/temp/map_tile/1_211.png"
   },
   {
      _id = "tiled_2",
      id = "1_212",
      image = "graphic/temp/map_tile/1_212.png"
   },
   {
      _id = "grey_floor",
      id = "1_213",
      image = "graphic/temp/map_tile/1_213.png"
   },
   {
      _id = "stair",
      id = "1_214",
      image = "graphic/temp/map_tile/1_214.png"
   },
   {
      _id = "tiled_red",
      id = "1_215",
      image = "graphic/temp/map_tile/1_215.png"
   },
   {
      _id = "cobble_stairs_2",
      id = "1_216",
      image = "graphic/temp/map_tile/1_216.png"
   },
   {
      _id = "tiled_red_2",
      id = "1_217",
      image = "graphic/temp/map_tile/1_217.png"
   },
   {
      _id = "wood_floor_5",
      id = "1_218",
      image = "graphic/temp/map_tile/1_218.png"
   },
   {
      _id = "wood_floor_6",
      id = "1_219",
      image = "graphic/temp/map_tile/1_219.png"
   },
   {
      _id = "wood_floor_7",
      id = "1_220",
      image = "graphic/temp/map_tile/1_220.png"
   },
   {
      _id = "wood_floor_8",
      id = "1_221",
      image = "graphic/temp/map_tile/1_221.png"
   },
   {
      _id = "red_floor",
      id = "1_222",
      image = "graphic/temp/map_tile/1_222.png"
   },
   {
      _id = "black_floor",
      id = "1_223",
      image = "graphic/temp/map_tile/1_223.png"
   },
   {
      _id = "wood_floor_9",
      id = "1_224",
      image = "graphic/temp/map_tile/1_224.png"
   },
   {
      _id = "carpet_1",
      id = "1_225",
      image = "graphic/temp/map_tile/1_225.png"
   },
   {
      _id = "carpet_2",
      id = "1_226",
      image = "graphic/temp/map_tile/1_226.png"
   },
   {
      _id = "tiled_3",
      id = "1_227",
      image = "graphic/temp/map_tile/1_227.png"
   },
   {
      _id = "carpet_4",
      id = "1_228",
      image = "graphic/temp/map_tile/1_228.png"
   },
   {
      _id = "carpet_5",
      id = "1_229",
      image = "graphic/temp/map_tile/1_229.png"
   },
   {
      _id = "green_floor",
      id = "1_230",
      image = "graphic/temp/map_tile/1_230.png"
   },

   -- ...
   --
   {
      _id = "blank",
      id = "1_253",
      image = "graphic/temp/map_tile/1_253.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_254",
      image = "graphic/temp/map_tile/1_254.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_255",
      image = "graphic/temp/map_tile/1_255.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_256",
      image = "graphic/temp/map_tile/1_256.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_257",
      image = "graphic/temp/map_tile/1_257.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_258",
      image = "graphic/temp/map_tile/1_258.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_259",
      image = "graphic/temp/map_tile/1_259.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_260",
      image = "graphic/temp/map_tile/1_260.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_261",
      image = "graphic/temp/map_tile/1_261.png",
      is_feat = true
   },
   {
      _id = "blank",
      id = "1_262",
      image = "graphic/temp/map_tile/1_262.png"
   },
   {
      _id = "blank",
      id = "1_263",
      image = "graphic/temp/map_tile/1_263.png"
   },

   -- ...

   {
      _id = "blank",
      id = "1_266",
      image = "graphic/temp/map_tile/1_266.png"
   },
   {
      _id = "blank",
      id = "1_267",
      image = "graphic/temp/map_tile/1_267.png"
   },
   {
      _id = "blank",
      id = "1_268",
      image = "graphic/temp/map_tile/1_268.png"
   },
   {
      _id = "blank",
      id = "1_269",
      image = "graphic/temp/map_tile/1_269.png"
   },
   {
      _id = "blank",
      id = "1_270",
      image = "graphic/temp/map_tile/1_270.png"
   },
   {
      _id = "blank",
      id = "1_271",
      image = "graphic/temp/map_tile/1_271.png"
   },
   {
      _id = "blank",
      id = "1_272",
      image = "graphic/temp/map_tile/1_272.png"
   },
   {
      _id = "blank",
      id = "1_273",
      image = "graphic/temp/map_tile/1_273.png"
   },
   {
      _id = "blank",
      id = "1_274",
      image = "graphic/temp/map_tile/1_274.png"
   },
   {
      _id = "blank",
      id = "1_275",
      image = "graphic/temp/map_tile/1_275.png"
   },
   {
      _id = "blank",
      id = "1_276",
      image = "graphic/temp/map_tile/1_276.png"
   },
   {
      _id = "blank",
      id = "1_277",
      image = "graphic/temp/map_tile/1_277.png"
   },
   {
      _id = "blank",
      id = "1_278",
      image = "graphic/temp/map_tile/1_278.png"
   },
   {
      _id = "blank",
      id = "1_279",
      image = "graphic/temp/map_tile/1_279.png"
   },
   {
      _id = "blank",
      id = "1_280",
      image = "graphic/temp/map_tile/1_280.png"
   },
   {
      _id = "blank",
      id = "1_281",
      image = "graphic/temp/map_tile/1_281.png"
   },
   {
      _id = "blank",
      id = "1_282",
      image = "graphic/temp/map_tile/1_282.png"
   },
   {
      _id = "blank",
      id = "1_283",
      image = "graphic/temp/map_tile/1_283.png"
   },

   -- ...

   {
      _id = "blank",
      id = "1_286",
      image = "graphic/temp/map_tile/1_286.png"
   },
   {
      _id = "blank",
      id = "1_287",
      image = "graphic/temp/map_tile/1_287.png"
   },
   {
      _id = "blank",
      id = "1_288",
      image = "graphic/temp/map_tile/1_288.png"
   },
   {
      _id = "blank",
      id = "1_289",
      image = "graphic/temp/map_tile/1_289.png"
   },
   {
      _id = "blank",
      id = "1_290",
      image = "graphic/temp/map_tile/1_290.png"
   },
   {
      _id = "blank",
      id = "1_291",
      image = "graphic/temp/map_tile/1_291.png"
   },
   {
      _id = "blank",
      id = "1_292",
      image = "graphic/temp/map_tile/1_292.png"
   },
   {
      _id = "blank",
      id = "1_293",
      image = "graphic/temp/map_tile/1_293.png"
   },
   {
      _id = "blank",
      id = "1_294",
      image = "graphic/temp/map_tile/1_294.png"
   },
   {
      _id = "blank",
      id = "1_295",
      image = "graphic/temp/map_tile/1_295.png"
   },
   {
      _id = "blank",
      id = "1_296",
      image = "graphic/temp/map_tile/1_296.png"
   },
   {
      _id = "grass_2",
      id = "1_297",
      image = "graphic/temp/map_tile/1_297.png"
   },
   {
      _id = "grass_3",
      id = "1_298",
      image = "graphic/temp/map_tile/1_298.png"
   },
   {
      _id = "grass_4",
      id = "1_299",
      image = "graphic/temp/map_tile/1_299.png"
   },
   {
      _id = "grass_5",
      id = "1_300",
      image = "graphic/temp/map_tile/1_300.png"
   },
   {
      _id = "grass_6",
      id = "1_301",
      image = "graphic/temp/map_tile/1_301.png"
   },
   {
      _id = "blank",
      id = "1_302",
      image = "graphic/temp/map_tile/1_302.png"
   },
   {
      _id = "blank",
      id = "1_303",
      image = "graphic/temp/map_tile/1_303.png"
   },
   {
      _id = "blank",
      id = "1_304",
      image = "graphic/temp/map_tile/1_304.png"
   },
   {
      _id = "blank",
      id = "1_305",
      image = "graphic/temp/map_tile/1_305.png"
   },
   {
      _id = "blank",
      id = "1_306",
      image = "graphic/temp/map_tile/1_306.png"
   },
   {
      _id = "blank",
      id = "1_307",
      image = "graphic/temp/map_tile/1_307.png"
   },
   {
      _id = "blank",
      id = "1_308",
      image = "graphic/temp/map_tile/1_308.png"
   },
   {
      _id = "blank",
      id = "1_309",
      image = "graphic/temp/map_tile/1_309.png"
   },
   {
      _id = "blank",
      id = "1_310",
      image = "graphic/temp/map_tile/1_310.png"
   },
   {
      _id = "blank",
      id = "1_311",
      image = "graphic/temp/map_tile/1_311.png"
   },
   {
      _id = "blank",
      id = "1_312",
      image = "graphic/temp/map_tile/1_312.png"
   },
   {
      _id = "blank",
      id = "1_313",
      image = "graphic/temp/map_tile/1_313.png"
   },
   {
      _id = "blank",
      id = "1_314",
      image = "graphic/temp/map_tile/1_314.png"
   },
   {
      _id = "blank",
      id = "1_315",
      image = "graphic/temp/map_tile/1_315.png"
   },
   {
      _id = "blank",
      id = "1_316",
      image = "graphic/temp/map_tile/1_316.png"
   },
   {
      _id = "blank",
      id = "1_317",
      image = "graphic/temp/map_tile/1_317.png"
   },
   {
      _id = "blank",
      id = "1_318",
      image = "graphic/temp/map_tile/1_318.png"
   },
   {
      _id = "blank",
      id = "1_319",
      image = "graphic/temp/map_tile/1_319.png"
   },
   {
      _id = "blank",
      id = "1_320",
      image = "graphic/temp/map_tile/1_320.png"
   },
   {
      _id = "blank",
      id = "1_321",
      image = "graphic/temp/map_tile/1_321.png"
   },
   {
      _id = "blank",
      id = "1_322",
      image = "graphic/temp/map_tile/1_322.png"
   },
   {
      _id = "dark_1",
      id = "1_323",
      image = "graphic/temp/map_tile/1_323.png"
   },
   {
      _id = "dark_2",
      id = "1_324",
      image = "graphic/temp/map_tile/1_324.png"
   },
   {
      _id = "dark_3",
      id = "1_325",
      image = "graphic/temp/map_tile/1_325.png"
   },
   {
      _id = "dark_4",
      id = "1_326",
      image = "graphic/temp/map_tile/1_326.png"
   },
   {
      _id = "dark_5",
      id = "1_327",
      image = "graphic/temp/map_tile/1_327.png"
   },
   {
      _id = "dark_6",
      id = "1_328",
      image = "graphic/temp/map_tile/1_328.png"
   },
   {
      _id = "dark_7",
      id = "1_329",
      image = "graphic/temp/map_tile/1_329.png"
   },
   {
      _id = "light_grass_1",
      id = "1_330",
      image = "graphic/temp/map_tile/1_330.png"
   },
   {
      _id = "light_grass_2",
      id = "1_331",
      image = "graphic/temp/map_tile/1_331.png"
   },
   {
      _id = "light_grass_3",
      id = "1_332",
      image = "graphic/temp/map_tile/1_332.png"
   },
   {
      _id = "light_grass_bush_1",
      id = "1_333",
      image = "graphic/temp/map_tile/1_333.png"
   },
   {
      _id = "light_grass_bush_2",
      id = "1_334",
      image = "graphic/temp/map_tile/1_334.png"
   },
   {
      _id = "light_grass_plants",
      id = "1_335",
      image = "graphic/temp/map_tile/1_335.png"
   },
   {
      _id = "light_grass_patch",
      id = "1_336",
      image = "graphic/temp/map_tile/1_336.png"
   },
   {
      _id = "light_grass_shrubs",
      id = "1_337",
      image = "graphic/temp/map_tile/1_337.png"
   },
   {
      _id = "light_grass_bushes",
      id = "1_338",
      image = "graphic/temp/map_tile/1_338.png"
   },
   {
      _id = "light_grass_cliff_sw",
      id = "1_339",
      image = "graphic/temp/map_tile/1_339.png"
   },
   {
      _id = "light_grass_cliff_s",
      id = "1_340",
      image = "graphic/temp/map_tile/1_340.png"
   },
   {
      _id = "light_grass_cliff_se",
      id = "1_341",
      image = "graphic/temp/map_tile/1_341.png"
   },
   {
      _id = "light_grass_flowers",
      id = "1_342",
      image = "graphic/temp/map_tile/1_342.png"
   },
   {
      _id = "light_grass_dirt",
      id = "1_343",
      image = "graphic/temp/map_tile/1_343.png"
   },
   {
      _id = "blank",
      id = "1_344",
      image = "graphic/temp/map_tile/1_344.png"
   },
   {
      _id = "blank",
      id = "1_345",
      image = "graphic/temp/map_tile/1_345.png"
   },
   {
      _id = "light_grass_cobble_1",
      id = "1_346",
      image = "graphic/temp/map_tile/1_346.png"
   },
   {
      _id = "light_grass_cobble_2",
      id = "1_347",
      image = "graphic/temp/map_tile/1_347.png"
   },
   {
      _id = "light_grass_cobble_3",
      id = "1_348",
      image = "graphic/temp/map_tile/1_348.png"
   },
   {
      _id = "light_grass_cobble_4",
      id = "1_349",
      image = "graphic/temp/map_tile/1_349.png"
   },
   {
      _id = "blank",
      id = "1_350",
      image = "graphic/temp/map_tile/1_350.png"
   },
   {
      _id = "blank",
      id = "1_351",
      image = "graphic/temp/map_tile/1_351.png"
   },
   {
      _id = "blank",
      id = "1_352",
      image = "graphic/temp/map_tile/1_352.png"
   },
   {
      _id = "blank",
      id = "1_353",
      image = "graphic/temp/map_tile/1_353.png"
   },
   {
      _id = "blank",
      id = "1_354",
      image = "graphic/temp/map_tile/1_354.png"
   },
   {
      _id = "blank",
      id = "1_355",
      image = "graphic/temp/map_tile/1_355.png"
   },
   {
      _id = "blank",
      id = "1_356",
      image = "graphic/temp/map_tile/1_356.png"
   },
   {
      _id = "blank",
      id = "1_357",
      image = "graphic/temp/map_tile/1_357.png"
   },
   {
      _id = "blank",
      id = "1_358",
      image = "graphic/temp/map_tile/1_358.png"
   },
   {
      _id = "light_grass_wheel",
      id = "1_359",
      image = "graphic/temp/map_tile/1_359.png"
   },
   {
      _id = "light_grass_railroad_tracks_ns",
      id = "1_360",
      image = "graphic/temp/map_tile/1_360.png"
   },
   {
      _id = "light_grass_railroad_tracks_we",
      id = "1_361",
      image = "graphic/temp/map_tile/1_361.png"
   },
   {
      _id = "light_grass_boulder",
      id = "1_362",
      image = "graphic/temp/map_tile/1_362.png"
   },
   {
      _id = "blank",
      id = "1_363",
      image = "graphic/temp/map_tile/1_363.png"
   },
   {
      _id = "blank",
      id = "1_364",
      image = "graphic/temp/map_tile/1_364.png"
   },
   {
      _id = "blank",
      id = "1_365",
      image = "graphic/temp/map_tile/1_365.png"
   },
   {
      _id = "blank",
      id = "1_366",
      image = "graphic/temp/map_tile/1_366.png"
   },
   {
      _id = "blank",
      id = "1_367",
      image = "graphic/temp/map_tile/1_367.png"
   },
   {
      _id = "blank",
      id = "1_368",
      image = "graphic/temp/map_tile/1_368.png"
   },
   {
      _id = "blank",
      id = "1_369",
      image = "graphic/temp/map_tile/1_369.png"
   },
   {
      _id = "blank",
      id = "1_370",
      image = "graphic/temp/map_tile/1_370.png"
   },
   {
      _id = "blank",
      id = "1_371",
      image = "graphic/temp/map_tile/1_371.png"
   },
   {
      _id = "blank",
      id = "1_372",
      image = "graphic/temp/map_tile/1_372.png"
   },
   {
      _id = "blank",
      id = "1_373",
      image = "graphic/temp/map_tile/1_373.png"
   },
   {
      _id = "blank",
      id = "1_374",
      image = "graphic/temp/map_tile/1_374.png"
   },
   {
      _id = "blank",
      id = "1_375",
      image = "graphic/temp/map_tile/1_375.png"
   },
   {
      _id = "blank",
      id = "1_376",
      image = "graphic/temp/map_tile/1_376.png"
   },
   {
      _id = "blank",
      id = "1_377",
      image = "graphic/temp/map_tile/1_377.png"
   },
   {
      _id = "blank",
      id = "1_378",
      image = "graphic/temp/map_tile/1_378.png"
   },
   {
      _id = "blank",
      id = "1_379",
      image = "graphic/temp/map_tile/1_379.png"
   },
   {
      _id = "blank",
      id = "1_380",
      image = "graphic/temp/map_tile/1_380.png"
   },
   {
      _id = "blank",
      id = "1_381",
      image = "graphic/temp/map_tile/1_381.png"
   },
   {
      _id = "blank",
      id = "1_382",
      image = "graphic/temp/map_tile/1_382.png"
   },
   {
      _id = "blank",
      id = "1_383",
      image = "graphic/temp/map_tile/1_383.png"
   },
   {
      _id = "blank",
      id = "1_384",
      image = "graphic/temp/map_tile/1_384.png"
   },
   {
      _id = "blank",
      id = "1_385",
      image = "graphic/temp/map_tile/1_385.png"
   },
   {
      _id = "blank",
      id = "1_386",
      image = "graphic/temp/map_tile/1_386.png"
   },
   {
      _id = "blank",
      id = "1_387",
      image = "graphic/temp/map_tile/1_387.png"
   },
   {
      _id = "blank",
      id = "1_388",
      image = "graphic/temp/map_tile/1_388.png"
   },
   {
      _id = "blank",
      id = "1_389",
      image = "graphic/temp/map_tile/1_389.png"
   },
   {
      _id = "blank",
      id = "1_390",
      image = "graphic/temp/map_tile/1_390.png"
   },
   {
      _id = "blank",
      id = "1_391",
      image = "graphic/temp/map_tile/1_391.png"
   },
   {
      _id = "blank",
      id = "1_392",
      image = "graphic/temp/map_tile/1_392.png"
   },
   {
      _id = "blank",
      id = "1_393",
      image = "graphic/temp/map_tile/1_393.png"
   },
   {
      _id = "blank",
      id = "1_394",
      image = "graphic/temp/map_tile/1_394.png"
   },
   {
      _id = "blank",
      id = "1_395",
      image = "graphic/temp/map_tile/1_395.png"
   },
   {
      _id = "wall_oriental_top",
      effect = 5,
      id = "1_396",
      image = "graphic/temp/map_tile/1_396.png",
      wall = "base.1_429",
      wall_kind = 2
   },
   {
      _id = "wall_brick_top",
      effect = 5,
      id = "1_397",
      image = "graphic/temp/map_tile/1_397.png",
      wall = "base.1_430",
      wall_kind = 2
   },
   {
      _id = "wall_regal_top",
      effect = 5,
      id = "1_398",
      image = "graphic/temp/map_tile/1_398.png",
      wall = "base.1_431",
      wall_kind = 2
   },
   {
      _id = "wall_pillar_top",
      effect = 5,
      id = "1_399",
      image = "graphic/temp/map_tile/1_399.png",
      wall = "base.1_432",
      wall_kind = 2
   },
   {
      _id = "wall_log_top",
      effect = 5,
      id = "1_400",
      image = "graphic/temp/map_tile/1_400.png",
      wall = "base.1_433",
      wall_kind = 2
   },
   {
      _id = "wall_wood_top",
      effect = 5,
      id = "1_401",
      image = "graphic/temp/map_tile/1_401.png",
      wall = "base.1_434",
      wall_kind = 2
   },
   {
      _id = "wall_plank_top",
      effect = 5,
      id = "1_402",
      image = "graphic/temp/map_tile/1_402.png",
      wall = "base.1_435",
      wall_kind = 2
   },
   {
      _id = "wall_shingle_top",
      effect = 5,
      id = "1_403",
      image = "graphic/temp/map_tile/1_403.png",
      wall = "base.1_436",
      wall_kind = 2
   },
   {
      _id = "wall_smooth_top",
      effect = 5,
      id = "1_404",
      image = "graphic/temp/map_tile/1_404.png",
      wall = "base.1_437",
      wall_kind = 2
   },
   {
      _id = "wall_curtain_top",
      effect = 5,
      id = "1_405",
      image = "graphic/temp/map_tile/1_405.png",
      wall = "base.1_438",
      wall_kind = 2
   },
   {
      _id = "wall_moss_top",
      effect = 5,
      id = "1_406",
      image = "graphic/temp/map_tile/1_406.png",
      wall = "base.1_439",
      wall_kind = 2
   },
   {
      _id = "wall_crypt_top",
      effect = 5,
      id = "1_407",
      image = "graphic/temp/map_tile/1_407.png",
      wall = "base.1_440",
      wall_kind = 2
   },
   {
      _id = "wall_ice_1_top",
      effect = 5,
      id = "1_408",
      image = "graphic/temp/map_tile/1_408.png",
      wall = "base.1_441",
      wall_kind = 2
   },
   {
      _id = "wall_ice_2_top",
      effect = 5,
      id = "1_409",
      image = "graphic/temp/map_tile/1_409.png",
      wall = "base.1_442",
      wall_kind = 2
   },
   {
      _id = "wall_ice_3_top",
      effect = 5,
      id = "1_410",
      image = "graphic/temp/map_tile/1_410.png",
      wall = "base.1_443",
      wall_kind = 2
   },
   {
      _id = "wall_snow_1_top",
      effect = 5,
      id = "1_411",
      image = "graphic/temp/map_tile/1_411.png",
      wall = "base.1_444",
      wall_kind = 2
   },
   {
      _id = "wall_snow_2_top",
      effect = 5,
      id = "1_412",
      image = "graphic/temp/map_tile/1_412.png",
      wall = "base.1_445",
      wall_kind = 2
   },
   {
      _id = "wall_snow_3_top",
      effect = 5,
      id = "1_413",
      image = "graphic/temp/map_tile/1_413.png",
      wall = "base.1_446",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_414",
      image = "graphic/temp/map_tile/1_414.png",
      wall = "base.1_447",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_415",
      image = "graphic/temp/map_tile/1_415.png",
      wall = "base.1_448",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_416",
      image = "graphic/temp/map_tile/1_416.png",
      wall = "base.1_449",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_417",
      image = "graphic/temp/map_tile/1_417.png",
      wall = "base.1_450",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_418",
      image = "graphic/temp/map_tile/1_418.png",
      wall = "base.1_451",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_419",
      image = "graphic/temp/map_tile/1_419.png",
      wall = "base.1_452",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_420",
      image = "graphic/temp/map_tile/1_420.png",
      wall = "base.1_453",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_421",
      image = "graphic/temp/map_tile/1_421.png",
      wall = "base.1_454",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_422",
      image = "graphic/temp/map_tile/1_422.png",
      wall = "base.1_455",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_423",
      image = "graphic/temp/map_tile/1_423.png",
      wall = "base.1_456",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_424",
      image = "graphic/temp/map_tile/1_424.png",
      wall = "base.1_457",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_425",
      image = "graphic/temp/map_tile/1_425.png",
      wall = "base.1_458",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_426",
      image = "graphic/temp/map_tile/1_426.png",
      wall = "base.1_459",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_427",
      image = "graphic/temp/map_tile/1_427.png",
      wall = "base.1_460",
      wall_kind = 2
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_428",
      image = "graphic/temp/map_tile/1_428.png",
      wall = "base.1_461",
      wall_kind = 2
   },
   {
      _id = "wall_oriental_bottom",
      effect = 5,
      id = "1_429",
      image = "graphic/temp/map_tile/1_429.png",
      wall_kind = 1
   },
   {
      _id = "wall_brick_bottom",
      effect = 5,
      id = "1_430",
      image = "graphic/temp/map_tile/1_430.png",
      wall_kind = 1
   },
   {
      _id = "wall_regal_bottom",
      effect = 5,
      id = "1_431",
      image = "graphic/temp/map_tile/1_431.png",
      wall_kind = 1
   },
   {
      _id = "wall_pillar_bottom",
      effect = 5,
      id = "1_432",
      image = "graphic/temp/map_tile/1_432.png",
      wall_kind = 1
   },
   {
      _id = "wall_log_bottom",
      effect = 5,
      id = "1_433",
      image = "graphic/temp/map_tile/1_433.png",
      wall_kind = 1
   },
   {
      _id = "wall_wood_bottom",
      effect = 5,
      id = "1_434",
      image = "graphic/temp/map_tile/1_434.png",
      wall_kind = 1
   },
   {
      _id = "wall_plank_bottom",
      effect = 5,
      id = "1_435",
      image = "graphic/temp/map_tile/1_435.png",
      wall_kind = 1
   },
   {
      _id = "wall_shingle_bottom",
      effect = 5,
      id = "1_436",
      image = "graphic/temp/map_tile/1_436.png",
      wall_kind = 1
   },
   {
      _id = "wall_smooth_bottom",
      effect = 5,
      id = "1_437",
      image = "graphic/temp/map_tile/1_437.png",
      wall_kind = 1
   },
   {
      _id = "wall_curtain_bottom",
      effect = 5,
      id = "1_438",
      image = "graphic/temp/map_tile/1_438.png",
      wall_kind = 1
   },
   {
      _id = "wall_moss_bottom",
      effect = 5,
      id = "1_439",
      image = "graphic/temp/map_tile/1_439.png",
      wall_kind = 1
   },
   {
      _id = "wall_crypt_bottom",
      effect = 5,
      id = "1_440",
      image = "graphic/temp/map_tile/1_440.png",
      wall_kind = 1
   },
   {
      _id = "wall_ice_1_bottom",
      effect = 5,
      id = "1_441",
      image = "graphic/temp/map_tile/1_441.png",
      wall_kind = 1
   },
   {
      _id = "wall_ice_2_bottom",
      effect = 5,
      id = "1_442",
      image = "graphic/temp/map_tile/1_442.png",
      wall_kind = 1
   },
   {
      _id = "wall_ice_3_bottom",
      effect = 5,
      id = "1_443",
      image = "graphic/temp/map_tile/1_443.png",
      wall_kind = 1
   },
   {
      _id = "wall_snow_1_bottom",
      effect = 5,
      id = "1_444",
      image = "graphic/temp/map_tile/1_444.png",
      wall_kind = 1
   },
   {
      _id = "wall_snow_2_bottom",
      effect = 5,
      id = "1_445",
      image = "graphic/temp/map_tile/1_445.png",
      wall_kind = 1
   },
   {
      _id = "wall_snow_3_bottom",
      effect = 5,
      id = "1_446",
      image = "graphic/temp/map_tile/1_446.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_447",
      image = "graphic/temp/map_tile/1_447.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_448",
      image = "graphic/temp/map_tile/1_448.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_449",
      image = "graphic/temp/map_tile/1_449.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_450",
      image = "graphic/temp/map_tile/1_450.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_451",
      image = "graphic/temp/map_tile/1_451.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_452",
      image = "graphic/temp/map_tile/1_452.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_453",
      image = "graphic/temp/map_tile/1_453.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_454",
      image = "graphic/temp/map_tile/1_454.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_455",
      image = "graphic/temp/map_tile/1_455.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_456",
      image = "graphic/temp/map_tile/1_456.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_457",
      image = "graphic/temp/map_tile/1_457.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_458",
      image = "graphic/temp/map_tile/1_458.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_459",
      image = "graphic/temp/map_tile/1_459.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_460",
      image = "graphic/temp/map_tile/1_460.png",
      wall_kind = 1
   },
   {
      _id = "blank",
      effect = 5,
      id = "1_461",
      image = "graphic/temp/map_tile/1_461.png",
      wall_kind = 1
   },
   {
      _id = "1_462",
      effect = 5,
      id = "1_462",
      image = "graphic/temp/map_tile/1_462.png",
      wall = "base.1_495",
      wall_kind = 2
   },
   {
      _id = "1_463",
      effect = 5,
      id = "1_463",
      image = "graphic/temp/map_tile/1_463.png",
      wall = "base.1_496",
      wall_kind = 2
   },
   {
      _id = "1_464",
      effect = 5,
      id = "1_464",
      image = "graphic/temp/map_tile/1_464.png",
      kind = 6,
      wall = "base.1_497",
      wall_kind = 2
   },
   {
      _id = "1_465",
      effect = 5,
      id = "1_465",
      image = "graphic/temp/map_tile/1_465.png",
      wall = "base.1_498",
      wall_kind = 2
   },
   {
      _id = "1_466",
      effect = 5,
      id = "1_466",
      image = "graphic/temp/map_tile/1_466.png",
      wall = "base.1_499",
      wall_kind = 2
   },
   {
      _id = "1_467",
      effect = 5,
      id = "1_467",
      image = "graphic/temp/map_tile/1_467.png",
      wall = "base.1_500",
      wall_kind = 2
   },
   {
      _id = "1_468",
      effect = 5,
      id = "1_468",
      image = "graphic/temp/map_tile/1_468.png",
      wall = "base.1_501",
      wall_kind = 2
   },
   {
      _id = "1_469",
      effect = 5,
      id = "1_469",
      image = "graphic/temp/map_tile/1_469.png",
      wall = "base.1_502",
      wall_kind = 2
   },
   {
      _id = "1_470",
      effect = 5,
      id = "1_470",
      image = "graphic/temp/map_tile/1_470.png",
      wall = "base.1_503",
      wall_kind = 2
   },
   {
      _id = "1_471",
      effect = 5,
      id = "1_471",
      image = "graphic/temp/map_tile/1_471.png",
      wall = "base.1_504",
      wall_kind = 2
   },
   {
      _id = "1_472",
      effect = 5,
      id = "1_472",
      image = "graphic/temp/map_tile/1_472.png",
      wall = "base.1_505",
      wall_kind = 2
   },
   {
      _id = "1_473",
      effect = 5,
      id = "1_473",
      image = "graphic/temp/map_tile/1_473.png",
      wall = "base.1_506",
      wall_kind = 2
   },
   {
      _id = "1_474",
      effect = 5,
      id = "1_474",
      image = "graphic/temp/map_tile/1_474.png",
      wall = "base.1_507",
      wall_kind = 2
   },
   {
      _id = "1_475",
      effect = 5,
      id = "1_475",
      image = "graphic/temp/map_tile/1_475.png",
      wall = "base.1_508",
      wall_kind = 2
   },
   {
      _id = "1_476",
      effect = 5,
      id = "1_476",
      image = "graphic/temp/map_tile/1_476.png",
      wall = "base.1_509",
      wall_kind = 2
   },
   {
      _id = "1_477",
      effect = 5,
      id = "1_477",
      image = "graphic/temp/map_tile/1_477.png",
      wall = "base.1_510",
      wall_kind = 2
   },
   {
      _id = "1_478",
      effect = 5,
      id = "1_478",
      image = "graphic/temp/map_tile/1_478.png",
      wall = "base.1_511",
      wall_kind = 2
   },
   {
      _id = "1_479",
      effect = 5,
      id = "1_479",
      image = "graphic/temp/map_tile/1_479.png",
      wall = "base.1_512",
      wall_kind = 2
   },
   {
      _id = "1_480",
      effect = 5,
      id = "1_480",
      image = "graphic/temp/map_tile/1_480.png",
      wall = "base.1_513",
      wall_kind = 2
   },
   {
      _id = "1_481",
      effect = 5,
      id = "1_481",
      image = "graphic/temp/map_tile/1_481.png",
      wall = "base.1_514",
      wall_kind = 2
   },
   {
      _id = "1_482",
      effect = 5,
      id = "1_482",
      image = "graphic/temp/map_tile/1_482.png",
      wall = "base.1_515",
      wall_kind = 2
   },
   {
      _id = "1_483",
      effect = 5,
      id = "1_483",
      image = "graphic/temp/map_tile/1_483.png",
      wall = "base.1_516",
      wall_kind = 2
   },
   {
      _id = "1_484",
      effect = 5,
      id = "1_484",
      image = "graphic/temp/map_tile/1_484.png",
      wall = "base.1_517",
      wall_kind = 2
   },
   {
      _id = "1_485",
      effect = 5,
      id = "1_485",
      image = "graphic/temp/map_tile/1_485.png",
      wall = "base.1_518",
      wall_kind = 2
   },
   {
      _id = "1_486",
      effect = 5,
      id = "1_486",
      image = "graphic/temp/map_tile/1_486.png",
      wall = "base.1_519",
      wall_kind = 2
   },
   {
      _id = "1_487",
      effect = 5,
      id = "1_487",
      image = "graphic/temp/map_tile/1_487.png",
      wall = "base.1_520",
      wall_kind = 2
   },
   {
      _id = "1_488",
      effect = 5,
      id = "1_488",
      image = "graphic/temp/map_tile/1_488.png",
      wall = "base.1_521",
      wall_kind = 2
   },
   {
      _id = "1_489",
      effect = 5,
      id = "1_489",
      image = "graphic/temp/map_tile/1_489.png",
      wall = "base.1_522",
      wall_kind = 2
   },
   {
      _id = "1_490",
      effect = 5,
      id = "1_490",
      image = "graphic/temp/map_tile/1_490.png",
      wall = "base.1_523",
      wall_kind = 2
   },
   {
      _id = "1_491",
      effect = 5,
      id = "1_491",
      image = "graphic/temp/map_tile/1_491.png",
      wall = "base.1_524",
      wall_kind = 2
   },
   {
      _id = "1_492",
      effect = 5,
      id = "1_492",
      image = "graphic/temp/map_tile/1_492.png",
      wall = "base.1_525",
      wall_kind = 2
   },
   {
      _id = "1_493",
      effect = 5,
      id = "1_493",
      image = "graphic/temp/map_tile/1_493.png",
      wall = "base.1_526",
      wall_kind = 2
   },
   {
      _id = "1_494",
      effect = 5,
      id = "1_494",
      image = "graphic/temp/map_tile/1_494.png",
      wall = "base.1_527",
      wall_kind = 2
   },
   {
      _id = "1_495",
      effect = 5,
      id = "1_495",
      image = "graphic/temp/map_tile/1_495.png",
      wall_kind = 1
   },
   {
      _id = "1_496",
      effect = 5,
      id = "1_496",
      image = "graphic/temp/map_tile/1_496.png",
      wall_kind = 1
   },
   {
      _id = "1_497",
      effect = 5,
      id = "1_497",
      image = "graphic/temp/map_tile/1_497.png",
      wall_kind = 1
   },
   {
      _id = "1_498",
      effect = 5,
      id = "1_498",
      image = "graphic/temp/map_tile/1_498.png",
      wall_kind = 1
   },
   {
      _id = "1_499",
      effect = 5,
      id = "1_499",
      image = "graphic/temp/map_tile/1_499.png",
      wall_kind = 1
   },
   {
      _id = "1_500",
      effect = 5,
      id = "1_500",
      image = "graphic/temp/map_tile/1_500.png",
      wall_kind = 1
   },
   {
      _id = "1_501",
      effect = 5,
      id = "1_501",
      image = "graphic/temp/map_tile/1_501.png",
      wall_kind = 1
   },
   {
      _id = "1_502",
      effect = 5,
      id = "1_502",
      image = "graphic/temp/map_tile/1_502.png",
      wall_kind = 1
   },
   {
      _id = "1_503",
      effect = 5,
      id = "1_503",
      image = "graphic/temp/map_tile/1_503.png",
      wall_kind = 1
   },
   {
      _id = "1_504",
      effect = 5,
      id = "1_504",
      image = "graphic/temp/map_tile/1_504.png",
      wall_kind = 1
   },
   {
      _id = "1_505",
      effect = 5,
      id = "1_505",
      image = "graphic/temp/map_tile/1_505.png",
      wall_kind = 1
   },
   {
      _id = "1_506",
      effect = 5,
      id = "1_506",
      image = "graphic/temp/map_tile/1_506.png",
      wall_kind = 1
   },
   {
      _id = "1_507",
      effect = 5,
      id = "1_507",
      image = "graphic/temp/map_tile/1_507.png",
      wall_kind = 1
   },
   {
      _id = "1_508",
      effect = 5,
      id = "1_508",
      image = "graphic/temp/map_tile/1_508.png",
      wall_kind = 1
   },
   {
      _id = "1_509",
      effect = 5,
      id = "1_509",
      image = "graphic/temp/map_tile/1_509.png",
      wall_kind = 1
   },
   {
      _id = "1_510",
      effect = 5,
      id = "1_510",
      image = "graphic/temp/map_tile/1_510.png",
      wall_kind = 1
   },
   {
      _id = "1_511",
      effect = 5,
      id = "1_511",
      image = "graphic/temp/map_tile/1_511.png",
      wall_kind = 1
   },
   {
      _id = "1_512",
      effect = 5,
      id = "1_512",
      image = "graphic/temp/map_tile/1_512.png",
      wall_kind = 1
   },
   {
      _id = "1_513",
      effect = 5,
      id = "1_513",
      image = "graphic/temp/map_tile/1_513.png",
      wall_kind = 1
   },
   {
      _id = "1_514",
      effect = 5,
      id = "1_514",
      image = "graphic/temp/map_tile/1_514.png",
      wall_kind = 1
   },
   {
      _id = "1_515",
      effect = 5,
      id = "1_515",
      image = "graphic/temp/map_tile/1_515.png",
      wall_kind = 1
   },
   {
      _id = "1_516",
      effect = 5,
      id = "1_516",
      image = "graphic/temp/map_tile/1_516.png",
      wall_kind = 1
   },
   {
      _id = "1_517",
      effect = 5,
      id = "1_517",
      image = "graphic/temp/map_tile/1_517.png",
      wall_kind = 1
   },
   {
      _id = "1_518",
      effect = 5,
      id = "1_518",
      image = "graphic/temp/map_tile/1_518.png",
      wall_kind = 1
   },
   {
      _id = "1_519",
      effect = 5,
      id = "1_519",
      image = "graphic/temp/map_tile/1_519.png",
      wall_kind = 1
   },
   {
      _id = "1_520",
      effect = 5,
      id = "1_520",
      image = "graphic/temp/map_tile/1_520.png",
      wall_kind = 1
   },
   {
      _id = "1_521",
      effect = 5,
      id = "1_521",
      image = "graphic/temp/map_tile/1_521.png",
      wall_kind = 1
   },
   {
      _id = "1_522",
      effect = 5,
      id = "1_522",
      image = "graphic/temp/map_tile/1_522.png",
      wall_kind = 1
   },
   {
      _id = "1_523",
      effect = 5,
      id = "1_523",
      image = "graphic/temp/map_tile/1_523.png",
      wall_kind = 1
   },
   {
      _id = "1_524",
      effect = 5,
      id = "1_524",
      image = "graphic/temp/map_tile/1_524.png",
      wall_kind = 1
   },
   {
      _id = "1_525",
      effect = 5,
      id = "1_525",
      image = "graphic/temp/map_tile/1_525.png",
      wall_kind = 1
   },
   {
      _id = "1_526",
      effect = 5,
      id = "1_526",
      image = "graphic/temp/map_tile/1_526.png",
      wall_kind = 1
   },
   {
      _id = "1_527",
      effect = 5,
      id = "1_527",
      image = "graphic/temp/map_tile/1_527.png",
      wall_kind = 1
   },
   {
      _id = "1_528",
      effect = 5,
      id = "1_528",
      image = "graphic/temp/map_tile/1_528.png"
   },
   {
      _id = "1_529",
      effect = 5,
      id = "1_529",
      image = "graphic/temp/map_tile/1_529.png"
   },
   {
      _id = "1_530",
      effect = 5,
      id = "1_530",
      image = "graphic/temp/map_tile/1_530.png"
   },
   {
      _id = "1_531",
      effect = 5,
      id = "1_531",
      image = "graphic/temp/map_tile/1_531.png"
   },
   {
      _id = "1_532",
      effect = 5,
      id = "1_532",
      image = "graphic/temp/map_tile/1_532.png"
   },
   {
      _id = "1_533",
      effect = 5,
      id = "1_533",
      image = "graphic/temp/map_tile/1_533.png"
   },
   {
      _id = "1_534",
      effect = 5,
      id = "1_534",
      image = "graphic/temp/map_tile/1_534.png"
   },
   {
      _id = "1_535",
      effect = 5,
      id = "1_535",
      image = "graphic/temp/map_tile/1_535.png"
   },
   {
      _id = "1_536",
      effect = 5,
      id = "1_536",
      image = "graphic/temp/map_tile/1_536.png"
   },
   {
      _id = "1_537",
      effect = 5,
      id = "1_537",
      image = "graphic/temp/map_tile/1_537.png"
   },
   {
      _id = "1_538",
      effect = 5,
      id = "1_538",
      image = "graphic/temp/map_tile/1_538.png"
   },
   {
      _id = "1_539",
      effect = 5,
      id = "1_539",
      image = "graphic/temp/map_tile/1_539.png"
   },
   {
      _id = "1_540",
      effect = 5,
      id = "1_540",
      image = "graphic/temp/map_tile/1_540.png"
   },
   {
      _id = "1_541",
      effect = 5,
      id = "1_541",
      image = "graphic/temp/map_tile/1_541.png"
   },
   {
      _id = "1_542",
      effect = 5,
      id = "1_542",
      image = "graphic/temp/map_tile/1_542.png"
   },
   {
      _id = "1_543",
      effect = 5,
      id = "1_543",
      image = "graphic/temp/map_tile/1_543.png"
   },
   {
      _id = "1_544",
      effect = 5,
      id = "1_544",
      image = "graphic/temp/map_tile/1_544.png"
   },
   {
      _id = "1_545",
      effect = 5,
      id = "1_545",
      image = "graphic/temp/map_tile/1_545.png"
   },
   {
      _id = "1_546",
      effect = 5,
      id = "1_546",
      image = "graphic/temp/map_tile/1_546.png"
   },
   {
      _id = "1_547",
      effect = 5,
      id = "1_547",
      image = "graphic/temp/map_tile/1_547.png"
   },
   {
      _id = "1_548",
      effect = 5,
      id = "1_548",
      image = "graphic/temp/map_tile/1_548.png"
   },
   {
      _id = "1_549",
      effect = 5,
      id = "1_549",
      image = "graphic/temp/map_tile/1_549.png"
   },
   {
      _id = "1_550",
      anime_frame = 2,
      effect = 5,
      id = "1_550",
      image = "graphic/temp/map_tile/1_550.png",
      wall_kind = 1
   },
   {
      _id = "1_551",
      effect = 5,
      id = "1_551",
      image = "graphic/temp/map_tile/1_551.png"
   },
   {
      _id = "1_552",
      effect = 5,
      id = "1_552",
      image = "graphic/temp/map_tile/1_552.png"
   },
   {
      _id = "1_553",
      effect = 5,
      id = "1_553",
      image = "graphic/temp/map_tile/1_553.png"
   },
   {
      _id = "1_554",
      effect = 5,
      id = "1_554",
      image = "graphic/temp/map_tile/1_554.png"
   },
   {
      _id = "1_555",
      effect = 5,
      id = "1_555",
      image = "graphic/temp/map_tile/1_555.png"
   },
   {
      _id = "1_556",
      effect = 5,
      id = "1_556",
      image = "graphic/temp/map_tile/1_556.png"
   },
   {
      _id = "1_557",
      effect = 5,
      id = "1_557",
      image = "graphic/temp/map_tile/1_557.png"
   },
   {
      _id = "1_558",
      effect = 5,
      id = "1_558",
      image = "graphic/temp/map_tile/1_558.png"
   },
   {
      _id = "1_559",
      effect = 5,
      id = "1_559",
      image = "graphic/temp/map_tile/1_559.png"
   },
   {
      _id = "1_560",
      effect = 5,
      id = "1_560",
      image = "graphic/temp/map_tile/1_560.png"
   },
   {
      _id = "1_561",
      effect = 5,
      id = "1_561",
      image = "graphic/temp/map_tile/1_561.png"
   },
   {
      _id = "1_562",
      effect = 5,
      id = "1_562",
      image = "graphic/temp/map_tile/1_562.png"
   },
   {
      _id = "1_563",
      effect = 5,
      id = "1_563",
      image = "graphic/temp/map_tile/1_563.png"
   },
   {
      _id = "1_564",
      effect = 5,
      id = "1_564",
      image = "graphic/temp/map_tile/1_564.png"
   },
   {
      _id = "1_565",
      effect = 5,
      id = "1_565",
      image = "graphic/temp/map_tile/1_565.png"
   },
   {
      _id = "1_566",
      effect = 5,
      id = "1_566",
      image = "graphic/temp/map_tile/1_566.png"
   },
   {
      _id = "1_567",
      effect = 5,
      id = "1_567",
      image = "graphic/temp/map_tile/1_567.png"
   },
   {
      _id = "1_568",
      effect = 5,
      id = "1_568",
      image = "graphic/temp/map_tile/1_568.png"
   },
   {
      _id = "1_569",
      effect = 5,
      id = "1_569",
      image = "graphic/temp/map_tile/1_569.png"
   },
   {
      _id = "1_570",
      effect = 5,
      id = "1_570",
      image = "graphic/temp/map_tile/1_570.png"
   },
   {
      _id = "1_571",
      effect = 5,
      id = "1_571",
      image = "graphic/temp/map_tile/1_571.png"
   },
   {
      _id = "1_572",
      effect = 5,
      id = "1_572",
      image = "graphic/temp/map_tile/1_572.png"
   },
   {
      _id = "1_573",
      effect = 5,
      id = "1_573",
      image = "graphic/temp/map_tile/1_573.png"
   },
   {
      _id = "1_574",
      effect = 5,
      id = "1_574",
      image = "graphic/temp/map_tile/1_574.png"
   },
   {
      _id = "1_575",
      effect = 5,
      id = "1_575",
      image = "graphic/temp/map_tile/1_575.png"
   },
   {
      _id = "1_576",
      effect = 5,
      id = "1_576",
      image = "graphic/temp/map_tile/1_576.png"
   },
   {
      _id = "1_577",
      effect = 5,
      id = "1_577",
      image = "graphic/temp/map_tile/1_577.png"
   },
   {
      _id = "1_578",
      effect = 5,
      id = "1_578",
      image = "graphic/temp/map_tile/1_578.png"
   },
   {
      _id = "1_579",
      effect = 5,
      id = "1_579",
      image = "graphic/temp/map_tile/1_579.png"
   },
   {
      _id = "1_580",
      effect = 5,
      id = "1_580",
      image = "graphic/temp/map_tile/1_580.png"
   },
   {
      _id = "1_581",
      effect = 5,
      id = "1_581",
      image = "graphic/temp/map_tile/1_581.png"
   },
   {
      _id = "1_582",
      effect = 5,
      id = "1_582",
      image = "graphic/temp/map_tile/1_582.png"
   },
   {
      _id = "1_583",
      effect = 5,
      id = "1_583",
      image = "graphic/temp/map_tile/1_583.png"
   },
   {
      _id = "1_584",
      effect = 5,
      id = "1_584",
      image = "graphic/temp/map_tile/1_584.png"
   },
   {
      _id = "1_585",
      effect = 5,
      id = "1_585",
      image = "graphic/temp/map_tile/1_585.png"
   },
   {
      _id = "1_586",
      effect = 5,
      id = "1_586",
      image = "graphic/temp/map_tile/1_586.png"
   },
   {
      _id = "1_587",
      effect = 5,
      id = "1_587",
      image = "graphic/temp/map_tile/1_587.png"
   },
   {
      _id = "1_588",
      effect = 5,
      id = "1_588",
      image = "graphic/temp/map_tile/1_588.png"
   },
   {
      _id = "1_589",
      effect = 5,
      id = "1_589",
      image = "graphic/temp/map_tile/1_589.png"
   },
   {
      _id = "1_590",
      effect = 5,
      id = "1_590",
      image = "graphic/temp/map_tile/1_590.png"
   },
   {
      _id = "1_591",
      effect = 5,
      id = "1_591",
      image = "graphic/temp/map_tile/1_591.png"
   },
   {
      _id = "1_592",
      effect = 5,
      id = "1_592",
      image = "graphic/temp/map_tile/1_592.png"
   },
   {
      _id = "1_593",
      effect = 5,
      id = "1_593",
      image = "graphic/temp/map_tile/1_593.png"
   },
   {
      _id = "1_594",
      anime_frame = 3,
      effect = 4,
      id = "1_594",
      image = "graphic/temp/map_tile/1_594.png",
      kind = 3
   },
   {
      _id = "1_595",
      effect = 5,
      id = "1_595",
      image = "graphic/temp/map_tile/1_595.png"
   },
   {
      _id = "1_596",
      effect = 5,
      id = "1_596",
      image = "graphic/temp/map_tile/1_596.png"
   },
   {
      _id = "1_597",
      effect = 5,
      id = "1_597",
      image = "graphic/temp/map_tile/1_597.png"
   },
   {
      _id = "1_598",
      effect = 5,
      id = "1_598",
      image = "graphic/temp/map_tile/1_598.png"
   },
   {
      _id = "1_599",
      effect = 5,
      id = "1_599",
      image = "graphic/temp/map_tile/1_599.png"
   },
   {
      _id = "1_600",
      effect = 5,
      id = "1_600",
      image = "graphic/temp/map_tile/1_600.png"
   },
   {
      _id = "1_601",
      effect = 5,
      id = "1_601",
      image = "graphic/temp/map_tile/1_601.png"
   },
   {
      _id = "1_602",
      effect = 5,
      id = "1_602",
      image = "graphic/temp/map_tile/1_602.png"
   },
   {
      _id = "1_603",
      effect = 5,
      id = "1_603",
      image = "graphic/temp/map_tile/1_603.png"
   },
   {
      _id = "1_604",
      effect = 5,
      id = "1_604",
      image = "graphic/temp/map_tile/1_604.png"
   },
   {
      _id = "1_605",
      effect = 5,
      id = "1_605",
      image = "graphic/temp/map_tile/1_605.png"
   },
   {
      _id = "1_606",
      effect = 5,
      id = "1_606",
      image = "graphic/temp/map_tile/1_606.png"
   },
   {
      _id = "1_607",
      effect = 5,
      id = "1_607",
      image = "graphic/temp/map_tile/1_607.png"
   },
   {
      _id = "1_608",
      effect = 5,
      id = "1_608",
      image = "graphic/temp/map_tile/1_608.png"
   },
   {
      _id = "1_609",
      effect = 5,
      id = "1_609",
      image = "graphic/temp/map_tile/1_609.png"
   },
   {
      _id = "1_610",
      effect = 5,
      id = "1_610",
      image = "graphic/temp/map_tile/1_610.png"
   },
   {
      _id = "1_611",
      effect = 5,
      id = "1_611",
      image = "graphic/temp/map_tile/1_611.png"
   },
   {
      _id = "1_612",
      effect = 5,
      id = "1_612",
      image = "graphic/temp/map_tile/1_612.png"
   },
   {
      _id = "1_613",
      effect = 5,
      id = "1_613",
      image = "graphic/temp/map_tile/1_613.png"
   },
   {
      _id = "1_614",
      effect = 5,
      id = "1_614",
      image = "graphic/temp/map_tile/1_614.png"
   },
   {
      _id = "1_615",
      effect = 5,
      id = "1_615",
      image = "graphic/temp/map_tile/1_615.png"
   },
   {
      _id = "1_616",
      effect = 5,
      id = "1_616",
      image = "graphic/temp/map_tile/1_616.png"
   },
   {
      _id = "1_617",
      effect = 5,
      id = "1_617",
      image = "graphic/temp/map_tile/1_617.png"
   },
   {
      _id = "1_618",
      effect = 5,
      id = "1_618",
      image = "graphic/temp/map_tile/1_618.png"
   },
   {
      _id = "1_619",
      effect = 5,
      id = "1_619",
      image = "graphic/temp/map_tile/1_619.png"
   },
   {
      _id = "1_620",
      effect = 5,
      id = "1_620",
      image = "graphic/temp/map_tile/1_620.png"
   },
   {
      _id = "1_621",
      effect = 5,
      id = "1_621",
      image = "graphic/temp/map_tile/1_621.png"
   },
   {
      _id = "1_622",
      effect = 5,
      id = "1_622",
      image = "graphic/temp/map_tile/1_622.png"
   },
   {
      _id = "1_623",
      effect = 5,
      id = "1_623",
      image = "graphic/temp/map_tile/1_623.png"
   },
   {
      _id = "1_624",
      effect = 5,
      id = "1_624",
      image = "graphic/temp/map_tile/1_624.png"
   },
   {
      _id = "1_625",
      effect = 5,
      id = "1_625",
      image = "graphic/temp/map_tile/1_625.png"
   },
   {
      _id = "1_626",
      effect = 5,
      id = "1_626",
      image = "graphic/temp/map_tile/1_626.png"
   },
   {
      _id = "1_627",
      effect = 5,
      id = "1_627",
      image = "graphic/temp/map_tile/1_627.png"
   },
   {
      _id = "1_628",
      effect = 4,
      id = "1_628",
      image = "graphic/temp/map_tile/1_628.png"
   },
   {
      _id = "1_629",
      effect = 5,
      id = "1_629",
      image = "graphic/temp/map_tile/1_629.png"
   },
   {
      _id = "1_630",
      effect = 5,
      id = "1_630",
      image = "graphic/temp/map_tile/1_630.png"
   },
   {
      _id = "1_631",
      effect = 5,
      id = "1_631",
      image = "graphic/temp/map_tile/1_631.png"
   },
   {
      _id = "1_632",
      effect = 5,
      id = "1_632",
      image = "graphic/temp/map_tile/1_632.png"
   },
   {
      _id = "1_633",
      effect = 5,
      id = "1_633",
      image = "graphic/temp/map_tile/1_633.png"
   },
   {
      _id = "1_634",
      effect = 5,
      id = "1_634",
      image = "graphic/temp/map_tile/1_634.png"
   },
   {
      _id = "1_635",
      effect = 5,
      id = "1_635",
      image = "graphic/temp/map_tile/1_635.png"
   },
   {
      _id = "1_636",
      effect = 5,
      id = "1_636",
      image = "graphic/temp/map_tile/1_636.png"
   },
   {
      _id = "1_637",
      effect = 4,
      id = "1_637",
      image = "graphic/temp/map_tile/1_637.png"
   },
   {
      _id = "1_638",
      effect = 5,
      id = "1_638",
      image = "graphic/temp/map_tile/1_638.png"
   },
   {
      _id = "1_639",
      effect = 5,
      id = "1_639",
      image = "graphic/temp/map_tile/1_639.png"
   },
   {
      _id = "1_640",
      effect = 5,
      id = "1_640",
      image = "graphic/temp/map_tile/1_640.png"
   },
   {
      _id = "1_641",
      effect = 4,
      id = "1_641",
      image = "graphic/temp/map_tile/1_641.png"
   },
   {
      _id = "1_642",
      effect = 5,
      id = "1_642",
      image = "graphic/temp/map_tile/1_642.png"
   },
   {
      _id = "1_643",
      effect = 5,
      id = "1_643",
      image = "graphic/temp/map_tile/1_643.png"
   },
   {
      _id = "1_644",
      effect = 5,
      id = "1_644",
      image = "graphic/temp/map_tile/1_644.png"
   },
   {
      _id = "1_645",
      effect = 5,
      id = "1_645",
      image = "graphic/temp/map_tile/1_645.png"
   },
   {
      _id = "1_646",
      effect = 5,
      id = "1_646",
      image = "graphic/temp/map_tile/1_646.png"
   },
   {
      _id = "1_647",
      effect = 5,
      id = "1_647",
      image = "graphic/temp/map_tile/1_647.png"
   },
   {
      _id = "1_648",
      effect = 5,
      id = "1_648",
      image = "graphic/temp/map_tile/1_648.png"
   },
   {
      _id = "1_649",
      effect = 5,
      id = "1_649",
      image = "graphic/temp/map_tile/1_649.png"
   },
   {
      _id = "1_650",
      effect = 5,
      id = "1_650",
      image = "graphic/temp/map_tile/1_650.png"
   },
   {
      _id = "1_651",
      effect = 5,
      id = "1_651",
      image = "graphic/temp/map_tile/1_651.png"
   },
   {
      _id = "1_652",
      effect = 5,
      id = "1_652",
      image = "graphic/temp/map_tile/1_652.png"
   },
   {
      _id = "1_653",
      effect = 5,
      id = "1_653",
      image = "graphic/temp/map_tile/1_653.png"
   },
   {
      _id = "1_654",
      effect = 5,
      id = "1_654",
      image = "graphic/temp/map_tile/1_654.png"
   },
   {
      _id = "1_655",
      effect = 5,
      id = "1_655",
      image = "graphic/temp/map_tile/1_655.png"
   },
   {
      _id = "1_656",
      effect = 5,
      id = "1_656",
      image = "graphic/temp/map_tile/1_656.png"
   },
   {
      _id = "1_657",
      effect = 5,
      id = "1_657",
      image = "graphic/temp/map_tile/1_657.png"
   },
   {
      _id = "1_658",
      effect = 5,
      id = "1_658",
      image = "graphic/temp/map_tile/1_658.png"
   },
   {
      _id = "1_659",
      effect = 5,
      id = "1_659",
      image = "graphic/temp/map_tile/1_659.png"
   },
   {
      _id = "1_660",
      effect = 5,
      id = "1_660",
      image = "graphic/temp/map_tile/1_660.png"
   },
   {
      _id = "1_661",
      effect = 5,
      id = "1_661",
      image = "graphic/temp/map_tile/1_661.png"
   },
   {
      _id = "1_662",
      effect = 5,
      id = "1_662",
      image = "graphic/temp/map_tile/1_662.png"
   },
   {
      _id = "1_663",
      effect = 5,
      id = "1_663",
      image = "graphic/temp/map_tile/1_663.png"
   },
   {
      _id = "1_664",
      effect = 5,
      id = "1_664",
      image = "graphic/temp/map_tile/1_664.png"
   },
   {
      _id = "1_665",
      effect = 5,
      id = "1_665",
      image = "graphic/temp/map_tile/1_665.png"
   },
   {
      _id = "1_666",
      effect = 5,
      id = "1_666",
      image = "graphic/temp/map_tile/1_666.png"
   },
   {
      _id = "1_667",
      effect = 5,
      id = "1_667",
      image = "graphic/temp/map_tile/1_667.png"
   },
   {
      _id = "1_668",
      effect = 5,
      id = "1_668",
      image = "graphic/temp/map_tile/1_668.png"
   },
   {
      _id = "1_669",
      effect = 5,
      id = "1_669",
      image = "graphic/temp/map_tile/1_669.png"
   },
   {
      _id = "1_670",
      effect = 5,
      id = "1_670",
      image = "graphic/temp/map_tile/1_670.png"
   },
   {
      _id = "1_671",
      effect = 5,
      id = "1_671",
      image = "graphic/temp/map_tile/1_671.png"
   },
   {
      _id = "1_672",
      effect = 5,
      id = "1_672",
      image = "graphic/temp/map_tile/1_672.png"
   },
   {
      _id = "1_673",
      effect = 5,
      id = "1_673",
      image = "graphic/temp/map_tile/1_673.png"
   },
   {
      _id = "1_674",
      effect = 5,
      id = "1_674",
      image = "graphic/temp/map_tile/1_674.png"
   },
   {
      _id = "1_675",
      effect = 5,
      id = "1_675",
      image = "graphic/temp/map_tile/1_675.png"
   },
   {
      _id = "1_676",
      effect = 5,
      id = "1_676",
      image = "graphic/temp/map_tile/1_676.png"
   },
   {
      _id = "1_677",
      effect = 5,
      id = "1_677",
      image = "graphic/temp/map_tile/1_677.png"
   },
   {
      _id = "1_678",
      effect = 5,
      id = "1_678",
      image = "graphic/temp/map_tile/1_678.png"
   },
   {
      _id = "1_679",
      effect = 5,
      id = "1_679",
      image = "graphic/temp/map_tile/1_679.png"
   },
   {
      _id = "1_680",
      effect = 5,
      id = "1_680",
      image = "graphic/temp/map_tile/1_680.png"
   },
   {
      _id = "1_681",
      effect = 5,
      id = "1_681",
      image = "graphic/temp/map_tile/1_681.png"
   },
   {
      _id = "1_682",
      effect = 5,
      id = "1_682",
      image = "graphic/temp/map_tile/1_682.png"
   },
   {
      _id = "1_683",
      effect = 5,
      id = "1_683",
      image = "graphic/temp/map_tile/1_683.png"
   },
   {
      _id = "1_684",
      effect = 5,
      id = "1_684",
      image = "graphic/temp/map_tile/1_684.png"
   },
   {
      _id = "1_685",
      effect = 5,
      id = "1_685",
      image = "graphic/temp/map_tile/1_685.png"
   },
   {
      _id = "1_686",
      effect = 5,
      id = "1_686",
      image = "graphic/temp/map_tile/1_686.png"
   },
   {
      _id = "1_687",
      effect = 5,
      id = "1_687",
      image = "graphic/temp/map_tile/1_687.png"
   },
   {
      _id = "1_688",
      effect = 5,
      id = "1_688",
      image = "graphic/temp/map_tile/1_688.png"
   },
   {
      _id = "1_689",
      effect = 5,
      id = "1_689",
      image = "graphic/temp/map_tile/1_689.png"
   },
   {
      _id = "1_690",
      effect = 5,
      id = "1_690",
      image = "graphic/temp/map_tile/1_690.png"
   },
   {
      _id = "1_691",
      effect = 5,
      id = "1_691",
      image = "graphic/temp/map_tile/1_691.png"
   },
   {
      _id = "1_692",
      effect = 5,
      id = "1_692",
      image = "graphic/temp/map_tile/1_692.png"
   },
   {
      _id = "1_693",
      effect = 5,
      id = "1_693",
      image = "graphic/temp/map_tile/1_693.png"
   },
   {
      _id = "1_694",
      effect = 5,
      id = "1_694",
      image = "graphic/temp/map_tile/1_694.png"
   },
   {
      _id = "1_695",
      effect = 5,
      id = "1_695",
      image = "graphic/temp/map_tile/1_695.png"
   },
   {
      _id = "1_696",
      effect = 5,
      id = "1_696",
      image = "graphic/temp/map_tile/1_696.png"
   },
   {
      _id = "1_697",
      effect = 5,
      id = "1_697",
      image = "graphic/temp/map_tile/1_697.png"
   },
   {
      _id = "1_698",
      effect = 5,
      id = "1_698",
      image = "graphic/temp/map_tile/1_698.png"
   },
   {
      _id = "1_699",
      effect = 5,
      id = "1_699",
      image = "graphic/temp/map_tile/1_699.png"
   },
   {
      _id = "1_700",
      effect = 5,
      id = "1_700",
      image = "graphic/temp/map_tile/1_700.png"
   },
   {
      _id = "1_701",
      effect = 5,
      id = "1_701",
      image = "graphic/temp/map_tile/1_701.png"
   },
   {
      _id = "1_702",
      effect = 5,
      id = "1_702",
      image = "graphic/temp/map_tile/1_702.png"
   },
   {
      _id = "1_703",
      effect = 5,
      id = "1_703",
      image = "graphic/temp/map_tile/1_703.png"
   },
   {
      _id = "1_704",
      effect = 5,
      id = "1_704",
      image = "graphic/temp/map_tile/1_704.png"
   },
   {
      _id = "1_705",
      effect = 5,
      id = "1_705",
      image = "graphic/temp/map_tile/1_705.png"
   },
   {
      _id = "1_706",
      effect = 5,
      id = "1_706",
      image = "graphic/temp/map_tile/1_706.png"
   },
   {
      _id = "1_707",
      effect = 5,
      id = "1_707",
      image = "graphic/temp/map_tile/1_707.png"
   },
   {
      _id = "1_708",
      effect = 5,
      id = "1_708",
      image = "graphic/temp/map_tile/1_708.png"
   },
   {
      _id = "1_709",
      effect = 5,
      id = "1_709",
      image = "graphic/temp/map_tile/1_709.png"
   },
   {
      _id = "1_710",
      effect = 5,
      id = "1_710",
      image = "graphic/temp/map_tile/1_710.png"
   },
   {
      _id = "1_711",
      effect = 5,
      id = "1_711",
      image = "graphic/temp/map_tile/1_711.png"
   },
   {
      _id = "1_712",
      effect = 5,
      id = "1_712",
      image = "graphic/temp/map_tile/1_712.png"
   },
   {
      _id = "1_713",
      effect = 5,
      id = "1_713",
      image = "graphic/temp/map_tile/1_713.png"
   },
   {
      _id = "1_714",
      effect = 5,
      id = "1_714",
      image = "graphic/temp/map_tile/1_714.png"
   },
   {
      _id = "1_715",
      effect = 5,
      id = "1_715",
      image = "graphic/temp/map_tile/1_715.png"
   },
   {
      _id = "1_716",
      effect = 5,
      id = "1_716",
      image = "graphic/temp/map_tile/1_716.png"
   },
   {
      _id = "1_717",
      effect = 5,
      id = "1_717",
      image = "graphic/temp/map_tile/1_717.png"
   },
   {
      _id = "1_718",
      effect = 5,
      id = "1_718",
      image = "graphic/temp/map_tile/1_718.png"
   },
   {
      _id = "1_719",
      effect = 5,
      id = "1_719",
      image = "graphic/temp/map_tile/1_719.png"
   },
   {
      _id = "1_720",
      effect = 5,
      id = "1_720",
      image = "graphic/temp/map_tile/1_720.png"
   },
   {
      _id = "1_721",
      effect = 5,
      id = "1_721",
      image = "graphic/temp/map_tile/1_721.png"
   },
   {
      _id = "1_722",
      effect = 5,
      id = "1_722",
      image = "graphic/temp/map_tile/1_722.png"
   },
   {
      _id = "1_723",
      effect = 5,
      id = "1_723",
      image = "graphic/temp/map_tile/1_723.png"
   },
   {
      _id = "1_724",
      effect = 5,
      id = "1_724",
      image = "graphic/temp/map_tile/1_724.png"
   },
   {
      _id = "1_725",
      effect = 5,
      id = "1_725",
      image = "graphic/temp/map_tile/1_725.png"
   },
   {
      _id = "1_726",
      effect = 5,
      id = "1_726",
      image = "graphic/temp/map_tile/1_726.png",
      is_feat = true
   },
   {
      _id = "1_727",
      effect = 5,
      id = "1_727",
      image = "graphic/temp/map_tile/1_727.png",
      is_feat = true
   },
   {
      _id = "1_728",
      effect = 5,
      id = "1_728",
      image = "graphic/temp/map_tile/1_728.png",
      is_feat = true
   },
   {
      _id = "1_729",
      effect = 5,
      id = "1_729",
      image = "graphic/temp/map_tile/1_729.png",
      is_feat = true
   },
   {
      _id = "1_730",
      effect = 5,
      id = "1_730",
      image = "graphic/temp/map_tile/1_730.png",
      is_feat = true
   },
   {
      _id = "1_731",
      effect = 5,
      id = "1_731",
      image = "graphic/temp/map_tile/1_731.png",
      is_feat = true
   },
   {
      _id = "1_732",
      effect = 5,
      id = "1_732",
      image = "graphic/temp/map_tile/1_732.png",
      is_feat = true
   },
   {
      _id = "1_733",
      effect = 4,
      id = "1_733",
      image = "graphic/temp/map_tile/1_733.png",
      is_feat = true
   },
   {
      _id = "1_734",
      effect = 5,
      id = "1_734",
      image = "graphic/temp/map_tile/1_734.png",
      is_feat = true
   },
   {
      _id = "1_735",
      effect = 5,
      id = "1_735",
      image = "graphic/temp/map_tile/1_735.png",
      is_feat = true
   },
   {
      _id = "1_736",
      effect = 5,
      id = "1_736",
      image = "graphic/temp/map_tile/1_736.png",
      is_feat = true
   },
   {
      _id = "1_737",
      effect = 5,
      id = "1_737",
      image = "graphic/temp/map_tile/1_737.png",
      is_feat = true
   },
   {
      _id = "1_738",
      effect = 5,
      id = "1_738",
      image = "graphic/temp/map_tile/1_738.png",
      is_feat = true
   },
   {
      _id = "1_739",
      effect = 5,
      id = "1_739",
      image = "graphic/temp/map_tile/1_739.png",
      is_feat = true
   },
   {
      _id = "1_740",
      effect = 5,
      id = "1_740",
      image = "graphic/temp/map_tile/1_740.png",
      is_feat = true
   },
   {
      _id = "1_741",
      effect = 5,
      id = "1_741",
      image = "graphic/temp/map_tile/1_741.png",
      is_feat = true
   },
   {
      _id = "1_742",
      effect = 5,
      id = "1_742",
      image = "graphic/temp/map_tile/1_742.png",
      is_feat = true
   },
   {
      _id = "1_743",
      effect = 5,
      id = "1_743",
      image = "graphic/temp/map_tile/1_743.png",
      is_feat = true
   },
   {
      _id = "1_744",
      effect = 5,
      id = "1_744",
      image = "graphic/temp/map_tile/1_744.png",
      is_feat = true
   },
   {
      _id = "1_745",
      effect = 5,
      id = "1_745",
      image = "graphic/temp/map_tile/1_745.png",
      is_feat = true
   },
   {
      _id = "1_746",
      effect = 5,
      id = "1_746",
      image = "graphic/temp/map_tile/1_746.png",
      is_feat = true
   },
   {
      _id = "1_747",
      effect = 5,
      id = "1_747",
      image = "graphic/temp/map_tile/1_747.png",
      is_feat = true
   },
   {
      _id = "1_748",
      effect = 5,
      id = "1_748",
      image = "graphic/temp/map_tile/1_748.png",
      is_feat = true
   },
   {
      _id = "1_749",
      effect = 5,
      id = "1_749",
      image = "graphic/temp/map_tile/1_749.png",
      is_feat = true
   },
   {
      _id = "1_750",
      effect = 5,
      id = "1_750",
      image = "graphic/temp/map_tile/1_750.png",
      is_feat = true
   },
   {
      _id = "1_751",
      effect = 5,
      id = "1_751",
      image = "graphic/temp/map_tile/1_751.png",
      is_feat = true
   },
   {
      _id = "1_752",
      effect = 5,
      id = "1_752",
      image = "graphic/temp/map_tile/1_752.png",
      is_feat = true
   },
   {
      _id = "1_753",
      effect = 5,
      id = "1_753",
      image = "graphic/temp/map_tile/1_753.png",
      is_feat = true
   },
   {
      _id = "1_754",
      effect = 5,
      id = "1_754",
      image = "graphic/temp/map_tile/1_754.png",
      is_feat = true
   },
   {
      _id = "1_755",
      effect = 5,
      id = "1_755",
      image = "graphic/temp/map_tile/1_755.png",
      is_feat = true
   },
   {
      _id = "1_756",
      effect = 5,
      id = "1_756",
      image = "graphic/temp/map_tile/1_756.png",
      is_feat = true
   },
   {
      _id = "1_757",
      effect = 5,
      id = "1_757",
      image = "graphic/temp/map_tile/1_757.png"
   },
   {
      _id = "1_758",
      effect = 5,
      id = "1_758",
      image = "graphic/temp/map_tile/1_758.png"
   },
   {
      _id = "1_759",
      effect = 5,
      id = "1_759",
      image = "graphic/temp/map_tile/1_759.png"
   },
   {
      _id = "1_760",
      effect = 5,
      id = "1_760",
      image = "graphic/temp/map_tile/1_760.png"
   },
   {
      _id = "1_761",
      effect = 5,
      id = "1_761",
      image = "graphic/temp/map_tile/1_761.png"
   },
   {
      _id = "1_762",
      effect = 5,
      id = "1_762",
      image = "graphic/temp/map_tile/1_762.png"
   },
   {
      _id = "1_763",
      effect = 5,
      id = "1_763",
      image = "graphic/temp/map_tile/1_763.png"
   },
   {
      _id = "1_764",
      effect = 5,
      id = "1_764",
      image = "graphic/temp/map_tile/1_764.png"
   },
   {
      _id = "1_765",
      effect = 5,
      id = "1_765",
      image = "graphic/temp/map_tile/1_765.png"
   },
   {
      _id = "1_766",
      effect = 5,
      id = "1_766",
      image = "graphic/temp/map_tile/1_766.png"
   },
   {
      _id = "1_767",
      effect = 5,
      id = "1_767",
      image = "graphic/temp/map_tile/1_767.png"
   },
   {
      _id = "1_768",
      effect = 5,
      id = "1_768",
      image = "graphic/temp/map_tile/1_768.png"
   },
   {
      _id = "1_769",
      effect = 5,
      id = "1_769",
      image = "graphic/temp/map_tile/1_769.png"
   },
   {
      _id = "1_770",
      effect = 5,
      id = "1_770",
      image = "graphic/temp/map_tile/1_770.png"
   },
   {
      _id = "1_771",
      effect = 5,
      id = "1_771",
      image = "graphic/temp/map_tile/1_771.png"
   },
   {
      _id = "1_772",
      effect = 5,
      id = "1_772",
      image = "graphic/temp/map_tile/1_772.png"
   },
   {
      _id = "1_773",
      effect = 5,
      id = "1_773",
      image = "graphic/temp/map_tile/1_773.png"
   },
   {
      _id = "1_774",
      effect = 5,
      id = "1_774",
      image = "graphic/temp/map_tile/1_774.png"
   },
   {
      _id = "1_775",
      effect = 5,
      id = "1_775",
      image = "graphic/temp/map_tile/1_775.png"
   },
   {
      _id = "1_776",
      effect = 5,
      id = "1_776",
      image = "graphic/temp/map_tile/1_776.png"
   },
   {
      _id = "1_777",
      effect = 5,
      id = "1_777",
      image = "graphic/temp/map_tile/1_777.png"
   },
   {
      _id = "1_778",
      effect = 5,
      id = "1_778",
      image = "graphic/temp/map_tile/1_778.png"
   },
   {
      _id = "1_779",
      effect = 5,
      id = "1_779",
      image = "graphic/temp/map_tile/1_779.png"
   },
   {
      _id = "1_780",
      effect = 5,
      id = "1_780",
      image = "graphic/temp/map_tile/1_780.png"
   },
   {
      _id = "1_781",
      effect = 5,
      id = "1_781",
      image = "graphic/temp/map_tile/1_781.png"
   },
   {
      _id = "1_782",
      effect = 5,
      id = "1_782",
      image = "graphic/temp/map_tile/1_782.png"
   },
   {
      _id = "1_783",
      effect = 5,
      id = "1_783",
      image = "graphic/temp/map_tile/1_783.png"
   },
   {
      _id = "1_784",
      effect = 5,
      id = "1_784",
      image = "graphic/temp/map_tile/1_784.png"
   },
   {
      _id = "1_785",
      effect = 5,
      id = "1_785",
      image = "graphic/temp/map_tile/1_785.png"
   },
   {
      _id = "1_786",
      effect = 5,
      id = "1_786",
      image = "graphic/temp/map_tile/1_786.png"
   },
   {
      _id = "1_787",
      effect = 5,
      id = "1_787",
      image = "graphic/temp/map_tile/1_787.png"
   },
   {
      _id = "1_788",
      effect = 5,
      id = "1_788",
      image = "graphic/temp/map_tile/1_788.png"
   },
   {
      _id = "1_789",
      effect = 5,
      id = "1_789",
      image = "graphic/temp/map_tile/1_789.png"
   },
   {
      _id = "1_790",
      effect = 5,
      id = "1_790",
      image = "graphic/temp/map_tile/1_790.png"
   },
   {
      _id = "1_791",
      effect = 5,
      id = "1_791",
      image = "graphic/temp/map_tile/1_791.png"
   },
   {
      _id = "1_792",
      effect = 5,
      id = "1_792",
      image = "graphic/temp/map_tile/1_792.png"
   },
   {
      _id = "1_793",
      effect = 5,
      id = "1_793",
      image = "graphic/temp/map_tile/1_793.png"
   },
   {
      _id = "1_794",
      effect = 5,
      id = "1_794",
      image = "graphic/temp/map_tile/1_794.png"
   },
   {
      _id = "1_795",
      effect = 5,
      id = "1_795",
      image = "graphic/temp/map_tile/1_795.png"
   },
   {
      _id = "1_796",
      effect = 5,
      id = "1_796",
      image = "graphic/temp/map_tile/1_796.png"
   },
   {
      _id = "1_797",
      effect = 5,
      id = "1_797",
      image = "graphic/temp/map_tile/1_797.png"
   },
   {
      _id = "1_798",
      effect = 5,
      id = "1_798",
      image = "graphic/temp/map_tile/1_798.png"
   },
   {
      _id = "1_799",
      effect = 5,
      id = "1_799",
      image = "graphic/temp/map_tile/1_799.png"
   },
   {
      _id = "1_800",
      effect = 5,
      id = "1_800",
      image = "graphic/temp/map_tile/1_800.png"
   },
   {
      _id = "1_801",
      effect = 5,
      id = "1_801",
      image = "graphic/temp/map_tile/1_801.png"
   },
   {
      _id = "1_802",
      effect = 5,
      id = "1_802",
      image = "graphic/temp/map_tile/1_802.png"
   },
   {
      _id = "1_803",
      effect = 5,
      id = "1_803",
      image = "graphic/temp/map_tile/1_803.png"
   },
   {
      _id = "1_804",
      effect = 5,
      id = "1_804",
      image = "graphic/temp/map_tile/1_804.png"
   },
   {
      _id = "1_805",
      effect = 5,
      id = "1_805",
      image = "graphic/temp/map_tile/1_805.png"
   },
   {
      _id = "1_806",
      effect = 5,
      id = "1_806",
      image = "graphic/temp/map_tile/1_806.png"
   },
   {
      _id = "1_807",
      effect = 5,
      id = "1_807",
      image = "graphic/temp/map_tile/1_807.png"
   },
   {
      _id = "1_808",
      effect = 5,
      id = "1_808",
      image = "graphic/temp/map_tile/1_808.png"
   },
   {
      _id = "1_809",
      effect = 5,
      id = "1_809",
      image = "graphic/temp/map_tile/1_809.png"
   },
   {
      _id = "1_810",
      effect = 5,
      id = "1_810",
      image = "graphic/temp/map_tile/1_810.png"
   },
   {
      _id = "1_811",
      effect = 5,
      id = "1_811",
      image = "graphic/temp/map_tile/1_811.png"
   },
   {
      _id = "1_812",
      effect = 5,
      id = "1_812",
      image = "graphic/temp/map_tile/1_812.png"
   },
   {
      _id = "1_813",
      effect = 5,
      id = "1_813",
      image = "graphic/temp/map_tile/1_813.png"
   },
   {
      _id = "1_814",
      effect = 5,
      id = "1_814",
      image = "graphic/temp/map_tile/1_814.png"
   },
   {
      _id = "1_815",
      effect = 5,
      id = "1_815",
      image = "graphic/temp/map_tile/1_815.png"
   },
   {
      _id = "1_816",
      effect = 5,
      id = "1_816",
      image = "graphic/temp/map_tile/1_816.png"
   },
   {
      _id = "1_817",
      effect = 5,
      id = "1_817",
      image = "graphic/temp/map_tile/1_817.png"
   },
   {
      _id = "1_818",
      effect = 5,
      id = "1_818",
      image = "graphic/temp/map_tile/1_818.png"
   },
   {
      _id = "1_819",
      effect = 5,
      id = "1_819",
      image = "graphic/temp/map_tile/1_819.png"
   },
   {
      _id = "1_820",
      effect = 5,
      id = "1_820",
      image = "graphic/temp/map_tile/1_820.png"
   },
   {
      _id = "1_821",
      effect = 5,
      id = "1_821",
      image = "graphic/temp/map_tile/1_821.png"
   },
   {
      _id = "1_822",
      effect = 5,
      id = "1_822",
      image = "graphic/temp/map_tile/1_822.png"
   },
   {
      _id = "1_823",
      effect = 5,
      id = "1_823",
      image = "graphic/temp/map_tile/1_823.png"
   },
   {
      _id = "1_824",
      effect = 5,
      id = "1_824",
      image = "graphic/temp/map_tile/1_824.png"
   },
   {
      _id = "2_1",
      id = "2_1",
      image = "graphic/temp/map_tile/2_1.png"
   },
   {
      _id = "2_2",
      id = "2_2",
      image = "graphic/temp/map_tile/2_2.png"
   },
   {
      _id = "2_3",
      id = "2_3",
      image = "graphic/temp/map_tile/2_3.png"
   },
   {
      _id = "2_4",
      id = "2_4",
      image = "graphic/temp/map_tile/2_4.png"
   },
   {
      _id = "2_5",
      id = "2_5",
      image = "graphic/temp/map_tile/2_5.png"
   },
   {
      _id = "2_7",
      id = "2_7",
      image = "graphic/temp/map_tile/2_7.png"
   },
   {
      _id = "2_8",
      id = "2_8",
      image = "graphic/temp/map_tile/2_8.png"
   },
   {
      _id = "2_9",
      id = "2_9",
      image = "graphic/temp/map_tile/2_9.png"
   },
   {
      _id = "2_12",
      id = "2_12",
      image = "graphic/temp/map_tile/2_12.png"
   },
   {
      _id = "2_13",
      id = "2_13",
      image = "graphic/temp/map_tile/2_13.png"
   },
   {
      _id = "2_14",
      id = "2_14",
      image = "graphic/temp/map_tile/2_14.png"
   },
   {
      _id = "2_15",
      id = "2_15",
      image = "graphic/temp/map_tile/2_15.png"
   },
   {
      _id = "2_16",
      id = "2_16",
      image = "graphic/temp/map_tile/2_16.png"
   },
   {
      _id = "2_17",
      id = "2_17",
      image = "graphic/temp/map_tile/2_17.png"
   },
   {
      _id = "2_18",
      id = "2_18",
      image = "graphic/temp/map_tile/2_18.png"
   },
   {
      _id = "2_20",
      id = "2_20",
      image = "graphic/temp/map_tile/2_20.png",
      kind = 4
   },
   {
      _id = "2_21",
      id = "2_21",
      image = "graphic/temp/map_tile/2_21.png",
      kind = 4
   },
   {
      _id = "2_22",
      id = "2_22",
      image = "graphic/temp/map_tile/2_22.png",
      kind = 4
   },
   {
      _id = "2_23",
      id = "2_23",
      image = "graphic/temp/map_tile/2_23.png",
      kind = 4
   },
   {
      _id = "2_24",
      id = "2_24",
      image = "graphic/temp/map_tile/2_24.png",
      kind = 4
   },
   {
      _id = "2_25",
      id = "2_25",
      image = "graphic/temp/map_tile/2_25.png",
      kind = 4
   },
   {
      _id = "2_26",
      id = "2_26",
      image = "graphic/temp/map_tile/2_26.png",
      kind = 4
   },
   {
      _id = "2_27",
      id = "2_27",
      image = "graphic/temp/map_tile/2_27.png",
      kind = 4
   },
   {
      _id = "2_28",
      id = "2_28",
      image = "graphic/temp/map_tile/2_28.png",
      kind = 4
   },
   {
      _id = "2_29",
      id = "2_29",
      image = "graphic/temp/map_tile/2_29.png",
      kind = 4
   },
   {
      _id = "2_30",
      id = "2_30",
      image = "graphic/temp/map_tile/2_30.png",
      kind = 4
   },
   {
      _id = "2_31",
      id = "2_31",
      image = "graphic/temp/map_tile/2_31.png",
      kind = 4
   },
   {
      _id = "2_32",
      id = "2_32",
      image = "graphic/temp/map_tile/2_32.png",
      kind = 4
   },
   {
      _id = "2_33",
      id = "2_33",
      image = "graphic/temp/map_tile/2_33.png",
      kind = 4
   },
   {
      _id = "2_34",
      id = "2_34",
      image = "graphic/temp/map_tile/2_34.png",
      kind = 4
   },
   {
      _id = "2_35",
      id = "2_35",
      image = "graphic/temp/map_tile/2_35.png",
      kind = 4
   },
   {
      _id = "2_36",
      id = "2_36",
      image = "graphic/temp/map_tile/2_36.png",
      kind = 4
   },
   {
      _id = "2_37",
      id = "2_37",
      image = "graphic/temp/map_tile/2_37.png",
      kind = 4
   },
   {
      _id = "2_38",
      id = "2_38",
      image = "graphic/temp/map_tile/2_38.png",
      kind = 4
   },
   {
      _id = "2_39",
      id = "2_39",
      image = "graphic/temp/map_tile/2_39.png",
      kind = 4
   },
   {
      _id = "2_40",
      id = "2_40",
      image = "graphic/temp/map_tile/2_40.png",
      kind = 4
   },
   {
      _id = "2_41",
      id = "2_41",
      image = "graphic/temp/map_tile/2_41.png",
      kind = 4
   },
   {
      _id = "2_42",
      id = "2_42",
      image = "graphic/temp/map_tile/2_42.png",
      kind = 4
   },
   {
      _id = "2_43",
      id = "2_43",
      image = "graphic/temp/map_tile/2_43.png",
      kind = 4
   },
   {
      _id = "2_44",
      id = "2_44",
      image = "graphic/temp/map_tile/2_44.png",
      kind = 4
   },
   {
      _id = "2_46",
      id = "2_46",
      image = "graphic/temp/map_tile/2_46.png",
      kind = 4
   },
   {
      _id = "2_51",
      id = "2_51",
      image = "graphic/temp/map_tile/2_51.png",
      kind = 4
   },
   {
      _id = "2_52",
      id = "2_52",
      image = "graphic/temp/map_tile/2_52.png",
      kind = 4
   },
   {
      _id = "2_53",
      id = "2_53",
      image = "graphic/temp/map_tile/2_53.png",
      kind = 4
   },
   {
      _id = "2_54",
      id = "2_54",
      image = "graphic/temp/map_tile/2_54.png",
      kind = 4
   },
   {
      _id = "2_55",
      id = "2_55",
      image = "graphic/temp/map_tile/2_55.png",
      kind = 4
   },
   {
      _id = "2_56",
      id = "2_56",
      image = "graphic/temp/map_tile/2_56.png",
      kind = 4
   },
   {
      _id = "2_57",
      id = "2_57",
      image = "graphic/temp/map_tile/2_57.png",
      kind = 4
   },
   {
      _id = "2_58",
      id = "2_58",
      image = "graphic/temp/map_tile/2_58.png",
      kind = 4
   },
   {
      _id = "2_59",
      id = "2_59",
      image = "graphic/temp/map_tile/2_59.png",
      kind = 4
   },
   {
      _id = "2_60",
      id = "2_60",
      image = "graphic/temp/map_tile/2_60.png",
      kind = 4
   },
   {
      _id = "2_61",
      id = "2_61",
      image = "graphic/temp/map_tile/2_61.png",
      kind = 4
   },
   {
      _id = "2_62",
      id = "2_62",
      image = "graphic/temp/map_tile/2_62.png",
      kind = 4
   },
   {
      _id = "2_63",
      id = "2_63",
      image = "graphic/temp/map_tile/2_63.png",
      kind = 4
   },
   {
      _id = "2_64",
      id = "2_64",
      image = "graphic/temp/map_tile/2_64.png",
      kind = 4
   },
   {
      _id = "2_65",
      id = "2_65",
      image = "graphic/temp/map_tile/2_65.png",
      kind = 4
   },
   {
      _id = "2_82",
      id = "2_82",
      image = "graphic/temp/map_tile/2_82.png"
   },
   {
      _id = "2_83",
      id = "2_83",
      image = "graphic/temp/map_tile/2_83.png"
   },
   {
      _id = "2_84",
      id = "2_84",
      image = "graphic/temp/map_tile/2_84.png"
   },
   {
      _id = "2_85",
      id = "2_85",
      image = "graphic/temp/map_tile/2_85.png"
   },
   {
      _id = "2_86",
      id = "2_86",
      image = "graphic/temp/map_tile/2_86.png",
      kind = 4
   },
   {
      _id = "2_87",
      id = "2_87",
      image = "graphic/temp/map_tile/2_87.png",
      kind = 4
   },
   {
      _id = "2_88",
      id = "2_88",
      image = "graphic/temp/map_tile/2_88.png",
      kind = 4
   },
   {
      _id = "2_89",
      id = "2_89",
      image = "graphic/temp/map_tile/2_89.png",
      kind = 4
   },
   {
      _id = "2_90",
      id = "2_90",
      image = "graphic/temp/map_tile/2_90.png",
      kind = 4
   },
   {
      _id = "2_91",
      id = "2_91",
      image = "graphic/temp/map_tile/2_91.png",
      kind = 4
   },
   {
      _id = "2_92",
      id = "2_92",
      image = "graphic/temp/map_tile/2_92.png",
      kind = 4
   },
   {
      _id = "2_93",
      id = "2_93",
      image = "graphic/temp/map_tile/2_93.png",
      kind = 4
   },
   {
      _id = "2_94",
      id = "2_94",
      image = "graphic/temp/map_tile/2_94.png",
      kind = 4
   },
   {
      _id = "2_95",
      id = "2_95",
      image = "graphic/temp/map_tile/2_95.png",
      kind = 4
   },
   {
      _id = "2_96",
      id = "2_96",
      image = "graphic/temp/map_tile/2_96.png",
      kind = 4
   },
   {
      _id = "2_97",
      id = "2_97",
      image = "graphic/temp/map_tile/2_97.png",
      kind = 4
   },
   {
      _id = "2_98",
      id = "2_98",
      image = "graphic/temp/map_tile/2_98.png",
      kind = 4
   },
   {
      _id = "2_119",
      id = "2_119",
      image = "graphic/temp/map_tile/2_119.png",
      kind = 4
   },
   {
      _id = "2_120",
      id = "2_120",
      image = "graphic/temp/map_tile/2_120.png",
      kind = 4
   },
   {
      _id = "2_121",
      id = "2_121",
      image = "graphic/temp/map_tile/2_121.png",
      kind = 4
   },
   {
      _id = "2_122",
      id = "2_122",
      image = "graphic/temp/map_tile/2_122.png",
      kind = 4
   },
   {
      _id = "2_123",
      id = "2_123",
      image = "graphic/temp/map_tile/2_123.png",
      kind = 4
   },
   {
      _id = "2_124",
      id = "2_124",
      image = "graphic/temp/map_tile/2_124.png",
      kind = 4
   },
   {
      _id = "2_125",
      id = "2_125",
      image = "graphic/temp/map_tile/2_125.png",
      kind = 4
   },
   {
      _id = "2_126",
      id = "2_126",
      image = "graphic/temp/map_tile/2_126.png",
      kind = 4
   },
   {
      _id = "2_127",
      id = "2_127",
      image = "graphic/temp/map_tile/2_127.png",
      kind = 4
   },
   {
      _id = "2_128",
      id = "2_128",
      image = "graphic/temp/map_tile/2_128.png",
      kind = 4
   },
   {
      _id = "2_129",
      id = "2_129",
      image = "graphic/temp/map_tile/2_129.png",
      kind = 4
   },
   {
      _id = "2_130",
      id = "2_130",
      image = "graphic/temp/map_tile/2_130.png",
      kind = 4
   },
   {
      _id = "2_131",
      id = "2_131",
      image = "graphic/temp/map_tile/2_131.png",
      kind = 4
   },
   {
      _id = "2_152",
      id = "2_152",
      image = "graphic/temp/map_tile/2_152.png",
      kind = 4
   },
   {
      _id = "2_153",
      id = "2_153",
      image = "graphic/temp/map_tile/2_153.png",
      kind = 4
   },
   {
      _id = "2_154",
      id = "2_154",
      image = "graphic/temp/map_tile/2_154.png",
      kind = 4
   },
   {
      _id = "2_155",
      id = "2_155",
      image = "graphic/temp/map_tile/2_155.png",
      kind = 4
   },
   {
      _id = "2_156",
      id = "2_156",
      image = "graphic/temp/map_tile/2_156.png",
      kind = 4
   },
   {
      _id = "2_157",
      id = "2_157",
      image = "graphic/temp/map_tile/2_157.png",
      kind = 4
   },
   {
      _id = "2_158",
      id = "2_158",
      image = "graphic/temp/map_tile/2_158.png",
      kind = 4
   },
   {
      _id = "2_159",
      id = "2_159",
      image = "graphic/temp/map_tile/2_159.png",
      kind = 4
   },
   {
      _id = "2_160",
      id = "2_160",
      image = "graphic/temp/map_tile/2_160.png",
      kind = 4
   },
   {
      _id = "2_161",
      id = "2_161",
      image = "graphic/temp/map_tile/2_161.png",
      kind = 4
   },
   {
      _id = "2_162",
      id = "2_162",
      image = "graphic/temp/map_tile/2_162.png",
      kind = 4
   },
   {
      _id = "2_163",
      id = "2_163",
      image = "graphic/temp/map_tile/2_163.png",
      kind = 4
   },
   {
      _id = "2_164",
      id = "2_164",
      image = "graphic/temp/map_tile/2_164.png",
      kind = 4
   },
   {
      _id = "2_174",
      id = "2_174",
      image = "graphic/temp/map_tile/2_174.png"
   },
   {
      _id = "2_175",
      id = "2_175",
      image = "graphic/temp/map_tile/2_175.png"
   },
   {
      _id = "2_176",
      id = "2_176",
      image = "graphic/temp/map_tile/2_176.png"
   },
   {
      _id = "2_177",
      id = "2_177",
      image = "graphic/temp/map_tile/2_177.png"
   },
   {
      _id = "2_178",
      id = "2_178",
      image = "graphic/temp/map_tile/2_178.png"
   },
   {
      _id = "2_179",
      id = "2_179",
      image = "graphic/temp/map_tile/2_179.png"
   },
   {
      _id = "2_180",
      id = "2_180",
      image = "graphic/temp/map_tile/2_180.png"
   },
   {
      _id = "2_181",
      id = "2_181",
      image = "graphic/temp/map_tile/2_181.png"
   },
   {
      _id = "2_182",
      id = "2_182",
      image = "graphic/temp/map_tile/2_182.png"
   },
   {
      _id = "2_183",
      id = "2_183",
      image = "graphic/temp/map_tile/2_183.png"
   },
   {
      _id = "2_184",
      id = "2_184",
      image = "graphic/temp/map_tile/2_184.png"
   },
   {
      _id = "2_185",
      id = "2_185",
      image = "graphic/temp/map_tile/2_185.png",
      kind = 4
   },
   {
      _id = "2_186",
      id = "2_186",
      image = "graphic/temp/map_tile/2_186.png",
      kind = 4
   },
   {
      _id = "2_187",
      id = "2_187",
      image = "graphic/temp/map_tile/2_187.png",
      kind = 4
   },
   {
      _id = "2_188",
      id = "2_188",
      image = "graphic/temp/map_tile/2_188.png",
      kind = 4
   },
   {
      _id = "2_189",
      id = "2_189",
      image = "graphic/temp/map_tile/2_189.png",
      kind = 4
   },
   {
      _id = "2_190",
      id = "2_190",
      image = "graphic/temp/map_tile/2_190.png",
      kind = 4
   },
   {
      _id = "2_191",
      id = "2_191",
      image = "graphic/temp/map_tile/2_191.png",
      kind = 4
   },
   {
      _id = "2_192",
      id = "2_192",
      image = "graphic/temp/map_tile/2_192.png",
      kind = 4
   },
   {
      _id = "2_193",
      id = "2_193",
      image = "graphic/temp/map_tile/2_193.png",
      kind = 4
   },
   {
      _id = "2_194",
      id = "2_194",
      image = "graphic/temp/map_tile/2_194.png",
      kind = 4
   },
   {
      _id = "2_195",
      id = "2_195",
      image = "graphic/temp/map_tile/2_195.png",
      kind = 4
   },
   {
      _id = "2_196",
      id = "2_196",
      image = "graphic/temp/map_tile/2_196.png",
      kind = 4
   },
   {
      _id = "2_197",
      id = "2_197",
      image = "graphic/temp/map_tile/2_197.png",
      kind = 4
   },
   {
      _id = "2_210",
      id = "2_210",
      image = "graphic/temp/map_tile/2_210.png"
   },
   {
      _id = "2_218",
      id = "2_218",
      image = "graphic/temp/map_tile/2_218.png",
      kind = 4
   },
   {
      _id = "2_219",
      id = "2_219",
      image = "graphic/temp/map_tile/2_219.png",
      kind = 4
   },
   {
      _id = "2_220",
      id = "2_220",
      image = "graphic/temp/map_tile/2_220.png",
      kind = 4
   },
   {
      _id = "2_221",
      id = "2_221",
      image = "graphic/temp/map_tile/2_221.png",
      kind = 4
   },
   {
      _id = "2_222",
      id = "2_222",
      image = "graphic/temp/map_tile/2_222.png",
      kind = 4
   },
   {
      _id = "2_223",
      id = "2_223",
      image = "graphic/temp/map_tile/2_223.png",
      kind = 4
   },
   {
      _id = "2_224",
      id = "2_224",
      image = "graphic/temp/map_tile/2_224.png",
      kind = 4
   },
   {
      _id = "2_225",
      id = "2_225",
      image = "graphic/temp/map_tile/2_225.png",
      kind = 4
   },
   {
      _id = "2_226",
      id = "2_226",
      image = "graphic/temp/map_tile/2_226.png",
      kind = 4
   },
   {
      _id = "2_227",
      id = "2_227",
      image = "graphic/temp/map_tile/2_227.png",
      kind = 4
   },
   {
      _id = "2_228",
      id = "2_228",
      image = "graphic/temp/map_tile/2_228.png",
      kind = 4
   },
   {
      _id = "2_229",
      id = "2_229",
      image = "graphic/temp/map_tile/2_229.png",
      kind = 4
   },
   {
      _id = "2_230",
      id = "2_230",
      image = "graphic/temp/map_tile/2_230.png",
      kind = 4
   },
   {
      _id = "2_231",
      id = "2_231",
      image = "graphic/temp/map_tile/2_231.png"
   },
   {
      _id = "2_232",
      id = "2_232",
      image = "graphic/temp/map_tile/2_232.png"
   },
   {
      _id = "2_233",
      id = "2_233",
      image = "graphic/temp/map_tile/2_233.png",
      offset_bottom = 48,
      offset_top = 56
   },
   {
      _id = "2_234",
      id = "2_234",
      image = "graphic/temp/map_tile/2_234.png"
   },
   {
      _id = "2_235",
      id = "2_235",
      image = "graphic/temp/map_tile/2_235.png"
   },
   {
      _id = "2_236",
      id = "2_236",
      image = "graphic/temp/map_tile/2_236.png"
   },
   {
      _id = "2_237",
      id = "2_237",
      image = "graphic/temp/map_tile/2_237.png"
   },
   {
      _id = "2_238",
      id = "2_238",
      image = "graphic/temp/map_tile/2_238.png"
   },
   {
      _id = "2_239",
      id = "2_239",
      image = "graphic/temp/map_tile/2_239.png"
   },
   {
      _id = "2_240",
      id = "2_240",
      image = "graphic/temp/map_tile/2_240.png"
   },
   {
      _id = "2_241",
      id = "2_241",
      image = "graphic/temp/map_tile/2_241.png"
   },
   {
      _id = "2_242",
      id = "2_242",
      image = "graphic/temp/map_tile/2_242.png"
   },
   {
      _id = "2_243",
      id = "2_243",
      image = "graphic/temp/map_tile/2_243.png"
   },
   {
      _id = "2_244",
      id = "2_244",
      image = "graphic/temp/map_tile/2_244.png"
   },
   {
      _id = "2_245",
      id = "2_245",
      image = "graphic/temp/map_tile/2_245.png"
   },
   {
      _id = "2_246",
      id = "2_246",
      image = "graphic/temp/map_tile/2_246.png"
   },
   {
      _id = "2_247",
      id = "2_247",
      image = "graphic/temp/map_tile/2_247.png"
   },
   {
      _id = "2_248",
      id = "2_248",
      image = "graphic/temp/map_tile/2_248.png"
   },
   {
      _id = "2_249",
      id = "2_249",
      image = "graphic/temp/map_tile/2_249.png"
   },
   {
      _id = "2_250",
      id = "2_250",
      image = "graphic/temp/map_tile/2_250.png"
   },
   {
      _id = "2_251",
      id = "2_251",
      image = "graphic/temp/map_tile/2_251.png",
      kind = 4
   },
   {
      _id = "2_252",
      id = "2_252",
      image = "graphic/temp/map_tile/2_252.png",
      kind = 4
   },
   {
      _id = "2_253",
      id = "2_253",
      image = "graphic/temp/map_tile/2_253.png",
      kind = 4
   },
   {
      _id = "2_254",
      id = "2_254",
      image = "graphic/temp/map_tile/2_254.png",
      kind = 4
   },
   {
      _id = "2_255",
      id = "2_255",
      image = "graphic/temp/map_tile/2_255.png",
      kind = 4
   },
   {
      _id = "2_256",
      id = "2_256",
      image = "graphic/temp/map_tile/2_256.png",
      kind = 4
   },
   {
      _id = "2_257",
      id = "2_257",
      image = "graphic/temp/map_tile/2_257.png",
      kind = 4
   },
   {
      _id = "2_258",
      id = "2_258",
      image = "graphic/temp/map_tile/2_258.png",
      kind = 4
   },
   {
      _id = "2_259",
      id = "2_259",
      image = "graphic/temp/map_tile/2_259.png",
      kind = 4
   },
   {
      _id = "2_260",
      id = "2_260",
      image = "graphic/temp/map_tile/2_260.png",
      kind = 4
   },
   {
      _id = "2_261",
      id = "2_261",
      image = "graphic/temp/map_tile/2_261.png",
      kind = 4
   },
   {
      _id = "2_262",
      id = "2_262",
      image = "graphic/temp/map_tile/2_262.png",
      kind = 4
   },
   {
      _id = "2_263",
      id = "2_263",
      image = "graphic/temp/map_tile/2_263.png",
      kind = 4
   },
   {
      _id = "2_265",
      id = "2_265",
      image = "graphic/temp/map_tile/2_265.png"
   },
   {
      _id = "2_275",
      id = "2_275",
      image = "graphic/temp/map_tile/2_275.png"
   },
   {
      _id = "2_284",
      id = "2_284",
      image = "graphic/temp/map_tile/2_284.png",
      kind = 4
   },
   {
      _id = "2_285",
      id = "2_285",
      image = "graphic/temp/map_tile/2_285.png",
      kind = 4
   },
   {
      _id = "2_286",
      id = "2_286",
      image = "graphic/temp/map_tile/2_286.png",
      kind = 4
   },
   {
      _id = "2_287",
      id = "2_287",
      image = "graphic/temp/map_tile/2_287.png",
      kind = 4
   },
   {
      _id = "2_288",
      id = "2_288",
      image = "graphic/temp/map_tile/2_288.png",
      kind = 4
   },
   {
      _id = "2_289",
      id = "2_289",
      image = "graphic/temp/map_tile/2_289.png",
      kind = 4
   },
   {
      _id = "2_290",
      id = "2_290",
      image = "graphic/temp/map_tile/2_290.png",
      kind = 4
   },
   {
      _id = "2_291",
      id = "2_291",
      image = "graphic/temp/map_tile/2_291.png",
      kind = 4
   },
   {
      _id = "2_292",
      id = "2_292",
      image = "graphic/temp/map_tile/2_292.png",
      kind = 4
   },
   {
      _id = "2_293",
      id = "2_293",
      image = "graphic/temp/map_tile/2_293.png",
      kind = 4
   },
   {
      _id = "2_294",
      id = "2_294",
      image = "graphic/temp/map_tile/2_294.png",
      kind = 4
   },
   {
      _id = "2_295",
      id = "2_295",
      image = "graphic/temp/map_tile/2_295.png",
      kind = 4
   },
   {
      _id = "2_296",
      id = "2_296",
      image = "graphic/temp/map_tile/2_296.png",
      kind = 4
   },
   {
      _id = "2_297",
      id = "2_297",
      image = "graphic/temp/map_tile/2_297.png"
   },
   {
      _id = "2_298",
      id = "2_298",
      image = "graphic/temp/map_tile/2_298.png"
   },
   {
      _id = "2_299",
      id = "2_299",
      image = "graphic/temp/map_tile/2_299.png"
   },
   {
      _id = "2_300",
      id = "2_300",
      image = "graphic/temp/map_tile/2_300.png"
   },
   {
      _id = "2_301",
      id = "2_301",
      image = "graphic/temp/map_tile/2_301.png"
   },
   {
      _id = "2_317",
      id = "2_317",
      image = "graphic/temp/map_tile/2_317.png",
      kind = 4
   },
   {
      _id = "2_318",
      id = "2_318",
      image = "graphic/temp/map_tile/2_318.png",
      kind = 4
   },
   {
      _id = "2_319",
      id = "2_319",
      image = "graphic/temp/map_tile/2_319.png",
      kind = 4
   },
   {
      _id = "2_320",
      id = "2_320",
      image = "graphic/temp/map_tile/2_320.png",
      kind = 4
   },
   {
      _id = "2_321",
      id = "2_321",
      image = "graphic/temp/map_tile/2_321.png",
      kind = 4
   },
   {
      _id = "2_322",
      id = "2_322",
      image = "graphic/temp/map_tile/2_322.png",
      kind = 4
   },
   {
      _id = "2_323",
      id = "2_323",
      image = "graphic/temp/map_tile/2_323.png",
      kind = 4
   },
   {
      _id = "2_324",
      id = "2_324",
      image = "graphic/temp/map_tile/2_324.png",
      kind = 4
   },
   {
      _id = "2_325",
      id = "2_325",
      image = "graphic/temp/map_tile/2_325.png",
      kind = 4
   },
   {
      _id = "2_326",
      id = "2_326",
      image = "graphic/temp/map_tile/2_326.png",
      kind = 4
   },
   {
      _id = "2_327",
      id = "2_327",
      image = "graphic/temp/map_tile/2_327.png",
      kind = 4
   },
   {
      _id = "2_328",
      id = "2_328",
      image = "graphic/temp/map_tile/2_328.png",
      kind = 4
   },
   {
      _id = "2_329",
      id = "2_329",
      image = "graphic/temp/map_tile/2_329.png",
      kind = 4
   },
   {
      _id = "2_333",
      id = "2_333",
      image = "graphic/temp/map_tile/2_333.png"
   },
   {
      _id = "2_334",
      id = "2_334",
      image = "graphic/temp/map_tile/2_334.png"
   },
   {
      _id = "2_335",
      id = "2_335",
      image = "graphic/temp/map_tile/2_335.png"
   },
   {
      _id = "2_337",
      id = "2_337",
      image = "graphic/temp/map_tile/2_337.png"
   },
   {
      _id = "2_338",
      id = "2_338",
      image = "graphic/temp/map_tile/2_338.png"
   },
   {
      _id = "2_339",
      id = "2_339",
      image = "graphic/temp/map_tile/2_339.png"
   },
   {
      _id = "2_342",
      id = "2_342",
      image = "graphic/temp/map_tile/2_342.png"
   },
   {
      _id = "2_347",
      id = "2_347",
      image = "graphic/temp/map_tile/2_347.png"
   },
   {
      _id = "2_348",
      id = "2_348",
      image = "graphic/temp/map_tile/2_348.png"
   },
   {
      _id = "2_349",
      id = "2_349",
      image = "graphic/temp/map_tile/2_349.png"
   },
   {
      _id = "2_350",
      id = "2_350",
      image = "graphic/temp/map_tile/2_350.png",
      kind = 4
   },
   {
      _id = "2_351",
      id = "2_351",
      image = "graphic/temp/map_tile/2_351.png",
      kind = 4
   },
   {
      _id = "2_352",
      id = "2_352",
      image = "graphic/temp/map_tile/2_352.png",
      kind = 4
   },
   {
      _id = "2_353",
      id = "2_353",
      image = "graphic/temp/map_tile/2_353.png",
      kind = 4
   },
   {
      _id = "2_354",
      id = "2_354",
      image = "graphic/temp/map_tile/2_354.png",
      kind = 4
   },
   {
      _id = "2_355",
      id = "2_355",
      image = "graphic/temp/map_tile/2_355.png",
      kind = 4
   },
   {
      _id = "2_356",
      id = "2_356",
      image = "graphic/temp/map_tile/2_356.png",
      kind = 4
   },
   {
      _id = "2_357",
      id = "2_357",
      image = "graphic/temp/map_tile/2_357.png",
      kind = 4
   },
   {
      _id = "2_358",
      id = "2_358",
      image = "graphic/temp/map_tile/2_358.png",
      kind = 4
   },
   {
      _id = "2_359",
      id = "2_359",
      image = "graphic/temp/map_tile/2_359.png",
      kind = 4
   },
   {
      _id = "2_360",
      id = "2_360",
      image = "graphic/temp/map_tile/2_360.png",
      kind = 4
   },
   {
      _id = "2_361",
      id = "2_361",
      image = "graphic/temp/map_tile/2_361.png",
      kind = 4
   },
   {
      _id = "2_362",
      id = "2_362",
      image = "graphic/temp/map_tile/2_362.png",
      kind = 4
   },
   {
      _id = "2_383",
      id = "2_383",
      image = "graphic/temp/map_tile/2_383.png"
   },
   {
      _id = "2_384",
      id = "2_384",
      image = "graphic/temp/map_tile/2_384.png"
   },
   {
      _id = "2_385",
      id = "2_385",
      image = "graphic/temp/map_tile/2_385.png"
   },
   {
      _id = "2_386",
      id = "2_386",
      image = "graphic/temp/map_tile/2_386.png"
   },
   {
      _id = "2_387",
      id = "2_387",
      image = "graphic/temp/map_tile/2_387.png"
   },
   {
      _id = "2_388",
      id = "2_388",
      image = "graphic/temp/map_tile/2_388.png"
   },
   {
      _id = "2_389",
      id = "2_389",
      image = "graphic/temp/map_tile/2_389.png"
   },
   {
      _id = "2_390",
      id = "2_390",
      image = "graphic/temp/map_tile/2_390.png"
   },
   {
      _id = "2_391",
      id = "2_391",
      image = "graphic/temp/map_tile/2_391.png"
   },
   {
      _id = "2_392",
      id = "2_392",
      image = "graphic/temp/map_tile/2_392.png"
   },
   {
      _id = "2_393",
      id = "2_393",
      image = "graphic/temp/map_tile/2_393.png"
   },
   {
      _id = "2_394",
      id = "2_394",
      image = "graphic/temp/map_tile/2_394.png"
   },
   {
      _id = "2_395",
      id = "2_395",
      image = "graphic/temp/map_tile/2_395.png"
   },
   {
      _id = "2_399",
      effect = 5,
      id = "2_399",
      image = "graphic/temp/map_tile/2_399.png",
      wall = "base.2_432",
      wall_kind = 2
   },
   {
      _id = "2_400",
      effect = 5,
      id = "2_400",
      image = "graphic/temp/map_tile/2_400.png",
      wall = "base.2_433",
      wall_kind = 2
   },
   {
      _id = "2_401",
      effect = 5,
      id = "2_401",
      image = "graphic/temp/map_tile/2_401.png",
      wall = "base.2_434",
      wall_kind = 2
   },
   {
      _id = "2_402",
      effect = 5,
      id = "2_402",
      image = "graphic/temp/map_tile/2_402.png",
      wall = "base.2_435",
      wall_kind = 2
   },
   {
      _id = "2_403",
      effect = 5,
      id = "2_403",
      image = "graphic/temp/map_tile/2_403.png",
      wall = "base.2_436",
      wall_kind = 2
   },
   {
      _id = "2_404",
      effect = 5,
      id = "2_404",
      image = "graphic/temp/map_tile/2_404.png",
      wall = "base.2_437",
      wall_kind = 2
   },
   {
      _id = "2_405",
      effect = 5,
      id = "2_405",
      image = "graphic/temp/map_tile/2_405.png",
      wall = "base.2_438",
      wall_kind = 2
   },
   {
      _id = "2_406",
      effect = 5,
      id = "2_406",
      image = "graphic/temp/map_tile/2_406.png",
      wall = "base.2_439",
      wall_kind = 2
   },
   {
      _id = "2_407",
      effect = 5,
      id = "2_407",
      image = "graphic/temp/map_tile/2_407.png",
      wall = "base.2_440",
      wall_kind = 2
   },
   {
      _id = "2_408",
      effect = 5,
      id = "2_408",
      image = "graphic/temp/map_tile/2_408.png",
      wall = "base.2_441",
      wall_kind = 2
   },
   {
      _id = "2_409",
      effect = 5,
      id = "2_409",
      image = "graphic/temp/map_tile/2_409.png",
      wall = "base.2_442",
      wall_kind = 2
   },
   {
      _id = "2_410",
      effect = 5,
      id = "2_410",
      image = "graphic/temp/map_tile/2_410.png",
      wall = "base.2_443",
      wall_kind = 2
   },
   {
      _id = "2_411",
      effect = 5,
      id = "2_411",
      image = "graphic/temp/map_tile/2_411.png",
      wall = "base.2_444",
      wall_kind = 2
   },
   {
      _id = "2_412",
      effect = 5,
      id = "2_412",
      image = "graphic/temp/map_tile/2_412.png",
      wall = "base.2_445",
      wall_kind = 2
   },
   {
      _id = "2_413",
      effect = 5,
      id = "2_413",
      image = "graphic/temp/map_tile/2_413.png",
      wall = "base.2_446",
      wall_kind = 2
   },
   {
      _id = "2_432",
      effect = 5,
      id = "2_432",
      image = "graphic/temp/map_tile/2_432.png",
      wall_kind = 1
   },
   {
      _id = "2_433",
      effect = 5,
      id = "2_433",
      image = "graphic/temp/map_tile/2_433.png",
      wall_kind = 1
   },
   {
      _id = "2_434",
      effect = 5,
      id = "2_434",
      image = "graphic/temp/map_tile/2_434.png",
      wall_kind = 1
   },
   {
      _id = "2_435",
      effect = 5,
      id = "2_435",
      image = "graphic/temp/map_tile/2_435.png",
      wall_kind = 1
   },
   {
      _id = "2_436",
      effect = 5,
      id = "2_436",
      image = "graphic/temp/map_tile/2_436.png",
      wall_kind = 1
   },
   {
      _id = "2_437",
      effect = 5,
      id = "2_437",
      image = "graphic/temp/map_tile/2_437.png",
      wall_kind = 1
   },
   {
      _id = "2_438",
      effect = 5,
      id = "2_438",
      image = "graphic/temp/map_tile/2_438.png",
      wall_kind = 1
   },
   {
      _id = "2_439",
      effect = 5,
      id = "2_439",
      image = "graphic/temp/map_tile/2_439.png",
      wall_kind = 1
   },
   {
      _id = "2_440",
      effect = 5,
      id = "2_440",
      image = "graphic/temp/map_tile/2_440.png",
      wall_kind = 1
   },
   {
      _id = "2_441",
      effect = 5,
      id = "2_441",
      image = "graphic/temp/map_tile/2_441.png",
      wall_kind = 1
   },
   {
      _id = "2_442",
      effect = 5,
      id = "2_442",
      image = "graphic/temp/map_tile/2_442.png",
      wall_kind = 1
   },
   {
      _id = "2_443",
      effect = 5,
      id = "2_443",
      image = "graphic/temp/map_tile/2_443.png",
      wall_kind = 1
   },
   {
      _id = "2_444",
      effect = 5,
      id = "2_444",
      image = "graphic/temp/map_tile/2_444.png",
      wall_kind = 1
   },
   {
      _id = "2_445",
      effect = 5,
      id = "2_445",
      image = "graphic/temp/map_tile/2_445.png",
      wall_kind = 1
   },
   {
      _id = "2_446",
      effect = 5,
      id = "2_446",
      image = "graphic/temp/map_tile/2_446.png",
      wall_kind = 1
   },
   {
      _id = "2_464",
      effect = 5,
      id = "2_464",
      image = "graphic/temp/map_tile/2_464.png",
      wall = "base.2_497",
      wall_kind = 2
   },
   {
      _id = "2_476",
      effect = 5,
      id = "2_476",
      image = "graphic/temp/map_tile/2_476.png",
      wall_kind = 0
   },
   {
      _id = "2_493",
      effect = 5,
      id = "2_493",
      image = "graphic/temp/map_tile/2_493.png",
      wall = "base.2_526",
      wall_kind = 2
   },
   {
      _id = "2_494",
      effect = 5,
      id = "2_494",
      image = "graphic/temp/map_tile/2_494.png",
      wall = "base.2_527",
      wall_kind = 2
   },
   {
      _id = "2_509",
      effect = 5,
      id = "2_509",
      image = "graphic/temp/map_tile/2_509.png",
      wall_kind = 0
   },
   {
      _id = "2_526",
      effect = 5,
      id = "2_526",
      image = "graphic/temp/map_tile/2_526.png",
      wall_kind = 1
   },
   {
      _id = "2_527",
      effect = 5,
      id = "2_527",
      image = "graphic/temp/map_tile/2_527.png",
      wall_kind = 1
   },
   {
      _id = "2_531",
      effect = 5,
      id = "2_531",
      image = "graphic/temp/map_tile/2_531.png"
   },
   {
      _id = "2_543",
      effect = 5,
      id = "2_543",
      image = "graphic/temp/map_tile/2_543.png"
   },
   {
      _id = "2_544",
      effect = 5,
      id = "2_544",
      image = "graphic/temp/map_tile/2_544.png"
   },
   {
      _id = "2_559",
      effect = 5,
      id = "2_559",
      image = "graphic/temp/map_tile/2_559.png"
   },
   {
      _id = "2_560",
      effect = 5,
      id = "2_560",
      image = "graphic/temp/map_tile/2_560.png"
   },
   {
      _id = "2_564",
      effect = 5,
      id = "2_564",
      image = "graphic/temp/map_tile/2_564.png"
   },
   {
      _id = "2_565",
      effect = 5,
      id = "2_565",
      image = "graphic/temp/map_tile/2_565.png"
   },
   {
      _id = "2_566",
      effect = 5,
      id = "2_566",
      image = "graphic/temp/map_tile/2_566.png"
   },
   {
      _id = "2_567",
      effect = 5,
      id = "2_567",
      image = "graphic/temp/map_tile/2_567.png"
   },
   {
      _id = "2_568",
      effect = 5,
      id = "2_568",
      image = "graphic/temp/map_tile/2_568.png"
   },
   {
      _id = "2_569",
      effect = 5,
      id = "2_569",
      image = "graphic/temp/map_tile/2_569.png"
   },
   {
      _id = "2_572",
      effect = 5,
      id = "2_572",
      image = "graphic/temp/map_tile/2_572.png"
   },
   {
      _id = "2_574",
      effect = 5,
      id = "2_574",
      image = "graphic/temp/map_tile/2_574.png"
   },
   {
      _id = "2_575",
      effect = 5,
      id = "2_575",
      image = "graphic/temp/map_tile/2_575.png"
   },
   {
      _id = "2_576",
      effect = 5,
      id = "2_576",
      image = "graphic/temp/map_tile/2_576.png"
   },
   {
      _id = "2_577",
      effect = 5,
      id = "2_577",
      image = "graphic/temp/map_tile/2_577.png"
   },
   {
      _id = "2_627",
      effect = 5,
      id = "2_627",
      image = "graphic/temp/map_tile/2_627.png"
   },
   {
      _id = "2_628",
      effect = 5,
      id = "2_628",
      image = "graphic/temp/map_tile/2_628.png"
   },
   {
      _id = "2_629",
      effect = 5,
      id = "2_629",
      image = "graphic/temp/map_tile/2_629.png"
   },
   {
      _id = "2_630",
      effect = 5,
      id = "2_630",
      image = "graphic/temp/map_tile/2_630.png"
   },
   {
      _id = "2_635",
      effect = 5,
      id = "2_635",
      image = "graphic/temp/map_tile/2_635.png"
   },
   {
      _id = "2_636",
      effect = 5,
      id = "2_636",
      image = "graphic/temp/map_tile/2_636.png"
   },
   {
      _id = "2_637",
      effect = 5,
      id = "2_637",
      image = "graphic/temp/map_tile/2_637.png"
   },
   {
      _id = "2_638",
      effect = 5,
      id = "2_638",
      image = "graphic/temp/map_tile/2_638.png"
   },
   {
      _id = "2_641",
      effect = 5,
      id = "2_641",
      image = "graphic/temp/map_tile/2_641.png"
   },
   {
      _id = "2_667",
      effect = 5,
      id = "2_667",
      image = "graphic/temp/map_tile/2_667.png"
   },
   {
      _id = "2_668",
      effect = 5,
      id = "2_668",
      image = "graphic/temp/map_tile/2_668.png"
   },
   {
      _id = "2_669",
      effect = 5,
      id = "2_669",
      image = "graphic/temp/map_tile/2_669.png"
   },
   {
      _id = "2_692",
      effect = 5,
      id = "2_692",
      image = "graphic/temp/map_tile/2_692.png"
   },
   {
      _id = "2_723",
      effect = 5,
      id = "2_723",
      image = "graphic/temp/map_tile/2_723.png"
   },
   {
      _id = "2_724",
      effect = 5,
      id = "2_724",
      image = "graphic/temp/map_tile/2_724.png"
   },
   {
      _id = "2_725",
      effect = 5,
      id = "2_725",
      image = "graphic/temp/map_tile/2_725.png"
   },
   {
      _id = "2_726",
      effect = 5,
      id = "2_726",
      image = "graphic/temp/map_tile/2_726.png"
   },
   {
      _id = "2_727",
      effect = 5,
      id = "2_727",
      image = "graphic/temp/map_tile/2_727.png"
   },
   {
      _id = "2_728",
      effect = 5,
      id = "2_728",
      image = "graphic/temp/map_tile/2_728.png"
   },
   {
      _id = "2_729",
      effect = 5,
      id = "2_729",
      image = "graphic/temp/map_tile/2_729.png"
   },
   {
      _id = "2_730",
      effect = 5,
      id = "2_730",
      image = "graphic/temp/map_tile/2_730.png"
   },
   {
      _id = "2_731",
      effect = 5,
      id = "2_731",
      image = "graphic/temp/map_tile/2_731.png"
   },
   {
      _id = "2_732",
      effect = 5,
      id = "2_732",
      image = "graphic/temp/map_tile/2_732.png"
   },
   {
      _id = "2_733",
      effect = 5,
      id = "2_733",
      image = "graphic/temp/map_tile/2_733.png"
   },
   {
      _id = "2_734",
      effect = 5,
      id = "2_734",
      image = "graphic/temp/map_tile/2_734.png"
   },
   {
      _id = "2_735",
      effect = 5,
      id = "2_735",
      image = "graphic/temp/map_tile/2_735.png"
   },
   {
      _id = "2_736",
      effect = 5,
      id = "2_736",
      image = "graphic/temp/map_tile/2_736.png"
   },
   {
      _id = "2_737",
      effect = 5,
      id = "2_737",
      image = "graphic/temp/map_tile/2_737.png"
   },
   {
      _id = "2_738",
      effect = 5,
      id = "2_738",
      image = "graphic/temp/map_tile/2_738.png"
   },
   {
      _id = "2_739",
      effect = 5,
      id = "2_739",
      image = "graphic/temp/map_tile/2_739.png"
   },
   {
      _id = "2_740",
      effect = 5,
      id = "2_740",
      image = "graphic/temp/map_tile/2_740.png"
   },
   {
      _id = "2_741",
      effect = 5,
      id = "2_741",
      image = "graphic/temp/map_tile/2_741.png"
   },
   {
      _id = "2_742",
      effect = 5,
      id = "2_742",
      image = "graphic/temp/map_tile/2_742.png"
   },
   {
      _id = "2_743",
      effect = 5,
      id = "2_743",
      image = "graphic/temp/map_tile/2_743.png"
   },
   {
      _id = "2_744",
      effect = 5,
      id = "2_744",
      image = "graphic/temp/map_tile/2_744.png"
   },
   {
      _id = "2_745",
      effect = 5,
      id = "2_745",
      image = "graphic/temp/map_tile/2_745.png"
   },
   {
      _id = "2_746",
      effect = 5,
      id = "2_746",
      image = "graphic/temp/map_tile/2_746.png"
   },
   {
      _id = "2_747",
      effect = 5,
      id = "2_747",
      image = "graphic/temp/map_tile/2_747.png"
   },
   {
      _id = "2_748",
      effect = 5,
      id = "2_748",
      image = "graphic/temp/map_tile/2_748.png"
   },
   {
      _id = "2_749",
      effect = 5,
      id = "2_749",
      image = "graphic/temp/map_tile/2_749.png"
   },
   {
      _id = "2_750",
      effect = 5,
      id = "2_750",
      image = "graphic/temp/map_tile/2_750.png"
   },
   {
      _id = "2_751",
      effect = 5,
      id = "2_751",
      image = "graphic/temp/map_tile/2_751.png"
   },
   {
      _id = "2_752",
      effect = 5,
      id = "2_752",
      image = "graphic/temp/map_tile/2_752.png"
   },
   {
      _id = "2_753",
      effect = 5,
      id = "2_753",
      image = "graphic/temp/map_tile/2_753.png"
   },
   {
      _id = "2_754",
      effect = 5,
      id = "2_754",
      image = "graphic/temp/map_tile/2_754.png"
   },
   {
      _id = "2_755",
      effect = 5,
      id = "2_755",
      image = "graphic/temp/map_tile/2_755.png"
   },
   {
      _id = "2_756",
      effect = 5,
      id = "2_756",
      image = "graphic/temp/map_tile/2_756.png"
   },
   {
      _id = "2_766",
      effect = 5,
      id = "2_766",
      image = "graphic/temp/map_tile/2_766.png"
   }
}

--- Converts an array to a set, with all keys set to "true".
-- @tparam array arr
-- @treturn table
function table.set(arr)
   local tbl = {}
   for _, k in ipairs(arr) do
      tbl[k] = true
   end
   return tbl
end

local unused = table.set {
"0_17",
"0_18",
"0_19",
"0_20",
"0_21",
"0_22",
"0_23",
"0_24",
"0_25",
"0_28",
"0_33",
"0_44",
"0_45",
"0_46",
"0_47",
"0_48",
"0_49",
"0_50",
"0_51",
"0_52",
"0_53",
"0_54",
"0_55",
"0_56",
"0_57",
"0_58",
"0_59",
"0_60",
"0_61",
"0_62",
"0_63",
"0_64",
"0_65",
"0_75",
"0_76",
"0_80",
"0_81",
"0_82",
"0_83",
"0_84",
"0_85",
"0_86",
"0_87",
"0_88",
"0_89",
"0_90",
"0_91",
"0_92",
"0_93",
"0_94",
"0_95",
"0_96",
"0_97",
"0_98",
"0_108",
"0_109",
"0_111",
"0_112",
"0_113",
"0_116",
"0_117",
"0_118",
"0_122",
"0_125",
"0_127",
"0_128",
"0_129",
"0_130",
"0_131",
"0_133",
"0_134",
"0_135",
"0_137",
"0_138",
"0_139",
"0_140",
"0_141",
"0_143",
"0_144",
"0_145",
"0_146",
"0_147",
"0_148",
"0_149",
"0_151",
"0_152",
"0_153",
"0_154",
"0_156",
"0_157",
"0_158",
"0_159",
"0_160",
"0_161",
"0_162",
"0_163",
"0_164",
"0_165",
"0_169",
"0_177",
"0_185",
"0_186",
"0_187",
"0_188",
"0_189",
"0_190",
"0_191",
"0_192",
"0_193",
"0_194",
"0_195",
"0_196",
"0_197",
"0_198",
"0_203",
"0_204",
"0_205",
"0_218",
"0_219",
"0_220",
"0_221",
"0_222",
"0_223",
"0_224",
"0_225",
"0_226",
"0_227",
"0_228",
"0_229",
"0_230",
"0_231",
"0_232",
"0_233",
"0_234",
"0_235",
"0_236",
"0_237",
"0_238",
"0_239",
"0_240",
"0_241",
"0_242",
"0_243",
"0_244",
"0_245",
"0_246",
"0_247",
"0_248",
"0_249",
"0_250",
"0_251",
"0_252",
"0_253",
"0_254",
"0_255",
"0_256",
"0_257",
"0_258",
"0_259",
"0_260",
"0_261",
"0_262",
"0_263",
"0_271",
"0_272",
"0_273",
"0_274",
"0_275",
"0_276",
"0_277",
"0_278",
"0_279",
"0_280",
"0_281",
"0_282",
"0_283",
"0_284",
"0_321",
"0_322",
"0_323",
"0_324",
"0_325",
"0_326",
"0_327",
"0_328",
"0_329",
"0_330",
"0_331",
"0_332",
"0_333",
"0_334",
"0_335",
"0_336",
"0_337",
"0_338",
"0_339",
"0_340",
"0_341",
"0_342",
"0_343",
"0_344",
"0_345",
"0_346",
"0_347",
"0_348",
"0_349",
"0_350",
"0_351",
"0_352",
"0_353",
"0_354",
"0_355",
"0_356",
"0_357",
"0_358",
"0_359",
"0_360",
"0_361",
"0_362",
"0_363",
"0_364",
"0_365",
"0_366",
"0_367",
"0_368",
"0_369",
"0_370",
"0_371",
"0_372",
"0_373",
"0_374",
"0_375",
"0_376",
"0_377",
"0_378",
"0_379",
"0_380",
"0_381",
"0_382",
"0_383",
"0_384",
"0_385",
"0_386",
"0_387",
"0_388",
"0_389",
"0_390",
"0_391",
"0_392",
"0_393",
"0_394",
"0_395",
"0_396",
"0_397",
"0_398",
"0_399",
"0_400",
"0_401",
"0_402",
"0_403",
"0_404",
"0_405",
"0_406",
"0_407",
"0_408",
"0_409",
"0_410",
"0_411",
"0_412",
"0_413",
"0_414",
"0_415",
"0_416",
"0_417",
"0_418",
"0_419",
"0_420",
"0_421",
"0_422",
"0_423",
"0_424",
"0_425",
"0_426",
"0_427",
"0_428",
"0_429",
"0_430",
"0_431",
"0_432",
"0_433",
"0_434",
"0_435",
"0_436",
"0_437",
"0_438",
"0_439",
"0_440",
"0_441",
"0_442",
"0_443",
"0_444",
"0_445",
"0_446",
"0_447",
"0_448",
"0_449",
"0_450",
"0_451",
"0_452",
"0_453",
"0_454",
"0_455",
"0_456",
"0_457",
"0_458",
"0_459",
"0_460",
"0_461",
"0_465",
"0_466",
"0_467",
"0_468",
"0_469",
"0_470",
"0_471",
"0_472",
"0_473",
"0_474",
"0_475",
"0_476",
"0_477",
"0_478",
"0_479",
"0_480",
"0_481",
"0_482",
"0_483",
"0_484",
"0_485",
"0_486",
"0_487",
"0_488",
"0_489",
"0_490",
"0_491",
"0_492",
"0_493",
"0_494",
"0_496",
"0_499",
"0_501",
"0_502",
"0_503",
"0_504",
"0_505",
"0_506",
"0_507",
"0_508",
"0_509",
"0_510",
"0_511",
"0_512",
"0_513",
"0_514",
"0_515",
"0_516",
"0_517",
"0_518",
"0_519",
"0_520",
"0_521",
"0_522",
"0_523",
"0_524",
"0_525",
"0_526",
"0_527",
"0_532",
"0_534",
"0_535",
"0_536",
"0_537",
"0_538",
"0_539",
"0_540",
"0_541",
"0_542",
"0_543",
"0_544",
"0_545",
"0_546",
"0_547",
"0_548",
"0_549",
"0_550",
"0_551",
"0_552",
"0_553",
"0_554",
"0_555",
"0_556",
"0_557",
"0_558",
"0_559",
"0_560",
"0_563",
"0_571",
"0_572",
"0_573",
"0_574",
"0_575",
"0_576",
"0_577",
"0_578",
"0_579",
"0_580",
"0_581",
"0_582",
"0_583",
"0_584",
"0_585",
"0_586",
"0_587",
"0_588",
"0_589",
"0_590",
"0_591",
"0_592",
"0_593",
"0_601",
"0_602",
"0_603",
"0_617",
"0_618",
"0_619",
"0_620",
"0_621",
"0_622",
"0_623",
"0_624",
"0_625",
"0_626",
"0_627",
"0_628",
"0_629",
"0_630",
"0_631",
"0_632",
"0_633",
"0_634",
"0_635",
"0_636",
"0_637",
"0_638",
"0_639",
"0_640",
"0_641",
"0_642",
"0_643",
"0_644",
"0_645",
"0_646",
"0_647",
"0_648",
"0_649",
"0_650",
"0_651",
"0_652",
"0_653",
"0_654",
"0_655",
"0_656",
"0_657",
"0_658",
"0_659",
"0_660",
"0_661",
"0_662",
"0_663",
"0_664",
"0_665",
"0_666",
"0_667",
"0_668",
"0_669",
"0_670",
"0_671",
"0_672",
"0_673",
"0_674",
"0_675",
"0_676",
"0_677",
"0_678",
"0_679",
"0_680",
"0_681",
"0_682",
"0_683",
"0_684",
"0_685",
"0_686",
"0_687",
"0_688",
"0_689",
"0_690",
"0_691",
"0_692",
"0_693",
"0_694",
"0_695",
"0_696",
"0_697",
"0_698",
"0_699",
"0_700",
"0_701",
"0_702",
"0_703",
"0_704",
"0_705",
"0_706",
"0_707",
"0_708",
"0_709",
"0_710",
"0_711",
"0_712",
"0_713",
"0_714",
"0_715",
"0_716",
"0_717",
"0_718",
"0_719",
"0_720",
"0_721",
"0_722",
"0_723",
"0_724",
"0_725",
"0_726",
"0_727",
"0_728",
"0_729",
"0_730",
"0_731",
"0_732",
"0_733",
"0_734",
"0_735",
"0_736",
"0_737",
"0_738",
"0_739",
"0_740",
"0_741",
"0_742",
"0_743",
"0_744",
"0_745",
"0_746",
"0_747",
"0_748",
"0_749",
"0_750",
"0_751",
"0_752",
"0_753",
"0_754",
"0_755",
"0_756",
"0_757",
"0_758",
"0_759",
"0_760",
"0_761",
"0_762",
"0_763",
"0_764",
"0_765",
"0_766",
"0_767",
"0_768",
"0_769",
"0_770",
"0_771",
"0_772",
"0_773",
"0_774",
"0_775",
"0_776",
"0_777",
"0_778",
"0_779",
"0_780",
"0_781",
"0_782",
"0_783",
"0_784",
"0_785",
"0_786",
"0_787",
"0_788",
"0_789",
"0_790",
"0_791",
"0_792",
"0_793",
"0_794",
"0_795",
"0_796",
"0_797",
"0_798",
"0_799",
"0_800",
"0_801",
"0_802",
"0_803",
"0_804",
"0_805",
"0_806",
"0_807",
"0_808",
"0_809",
"0_810",
"0_811",
"0_812",
"0_813",
"0_814",
"0_815",
"0_816",
"0_817",
"0_818",
"0_819",
"0_820",
"0_821",
"0_822",
"0_823",
"0_824",
"0_825",
"1_12",
"1_13",
"1_14",
"1_15",
"1_22",
"1_23",
"1_24",
"1_25",
"1_26",
"1_27",
"1_28",
"1_32",
"1_36",
"1_42",
"1_43",
"1_44",
"1_67",
"1_68",
"1_69",
"1_79",
"1_80",
"1_90",
"1_91",
"1_92",
"1_93",
"1_94",
"1_95",
"1_96",
"1_97",
"1_104",
"1_106",
"1_107",
"1_108",
"1_116",
"1_117",
"1_124",
"1_125",
"1_127",
"1_142",
"1_143",
"1_145",
"1_154",
"1_155",
"1_162",
"1_166",
"1_167",
"1_169",
"1_170",
"1_172",
"1_173",
"1_174",
"1_175",
"1_176",
"1_178",
"1_181",
"1_182",
"1_184",
"1_185",
"1_187",
"1_191",
"1_194",
"1_195",
"1_197",
"1_200",
"1_207",
"1_215",
"1_217",
"1_220",
"1_226",
"1_227",
"1_231",
"1_232",
"1_233",
"1_234",
"1_235",
"1_236",
"1_237",
"1_238",
"1_239",
"1_240",
"1_241",
"1_242",
"1_243",
"1_244",
"1_245",
"1_246",
"1_247",
"1_248",
"1_249",
"1_250",
"1_251",
"1_252",
"1_253",
"1_254",
"1_255",
"1_256",
"1_257",
"1_258",
"1_259",
"1_260",
"1_261",
"1_262",
"1_263",
"1_264",
"1_265",
"1_266",
"1_267",
"1_268",
"1_269",
"1_270",
"1_271",
"1_272",
"1_273",
"1_274",
"1_275",
"1_276",
"1_277",
"1_278",
"1_279",
"1_280",
"1_281",
"1_282",
"1_283",
"1_284",
"1_285",
"1_286",
"1_287",
"1_288",
"1_289",
"1_290",
"1_291",
"1_292",
"1_293",
"1_294",
"1_295",
"1_296",
"1_297",
"1_298",
"1_299",
"1_300",
"1_301",
"1_302",
"1_303",
"1_304",
"1_305",
"1_306",
"1_307",
"1_308",
"1_309",
"1_310",
"1_311",
"1_312",
"1_313",
"1_314",
"1_315",
"1_316",
"1_317",
"1_318",
"1_319",
"1_320",
"1_321",
"1_322",
"1_323",
"1_324",
"1_325",
"1_326",
"1_327",
"1_328",
"1_329",
"1_344",
"1_345",
"1_350",
"1_351",
"1_352",
"1_353",
"1_354",
"1_355",
"1_356",
"1_357",
"1_358",
"1_363",
"1_364",
"1_365",
"1_366",
"1_367",
"1_368",
"1_369",
"1_370",
"1_371",
"1_372",
"1_373",
"1_374",
"1_375",
"1_376",
"1_377",
"1_378",
"1_379",
"1_380",
"1_381",
"1_382",
"1_383",
"1_384",
"1_385",
"1_386",
"1_387",
"1_388",
"1_389",
"1_390",
"1_391",
"1_392",
"1_393",
"1_394",
"1_395",
"1_401",
"1_402",
"1_403",
"1_404",
"1_405",
"1_406",
"1_407",
"1_409",
"1_414",
"1_415",
"1_416",
"1_417",
"1_418",
"1_419",
"1_420",
"1_421",
"1_422",
"1_423",
"1_424",
"1_425",
"1_426",
"1_427",
"1_428",
"1_429",
"1_430",
"1_431",
"1_432",
"1_433",
"1_434",
"1_435",
"1_436",
"1_437",
"1_438",
"1_439",
"1_440",
"1_441",
"1_442",
"1_443",
"1_444",
"1_445",
"1_446",
"1_447",
"1_448",
"1_449",
"1_450",
"1_451",
"1_452",
"1_453",
"1_454",
"1_455",
"1_456",
"1_457",
"1_458",
"1_459",
"1_460",
"1_461",
"1_476",
"1_493",
"1_494",
"1_495",
"1_496",
"1_497",
"1_498",
"1_499",
"1_500",
"1_501",
"1_502",
"1_503",
"1_504",
"1_505",
"1_506",
"1_507",
"1_508",
"1_509",
"1_510",
"1_511",
"1_512",
"1_513",
"1_514",
"1_515",
"1_516",
"1_517",
"1_518",
"1_519",
"1_520",
"1_521",
"1_522",
"1_523",
"1_524",
"1_525",
"1_526",
"1_527",
"1_528",
"1_529",
"1_530",
"1_531",
"1_532",
"1_533",
"1_534",
"1_535",
"1_536",
"1_537",
"1_538",
"1_539",
"1_540",
"1_541",
"1_542",
"1_544",
"1_545",
"1_546",
"1_547",
"1_548",
"1_549",
"1_551",
"1_552",
"1_553",
"1_554",
"1_555",
"1_556",
"1_557",
"1_558",
"1_559",
"1_560",
"1_561",
"1_562",
"1_563",
"1_569",
"1_570",
"1_571",
"1_578",
"1_579",
"1_580",
"1_581",
"1_582",
"1_583",
"1_584",
"1_585",
"1_586",
"1_587",
"1_588",
"1_589",
"1_590",
"1_591",
"1_592",
"1_593",
"1_595",
"1_596",
"1_597",
"1_598",
"1_599",
"1_600",
"1_601",
"1_602",
"1_603",
"1_604",
"1_605",
"1_606",
"1_607",
"1_608",
"1_609",
"1_610",
"1_611",
"1_612",
"1_613",
"1_614",
"1_615",
"1_616",
"1_617",
"1_618",
"1_619",
"1_620",
"1_621",
"1_622",
"1_623",
"1_624",
"1_625",
"1_626",
"1_640",
"1_642",
"1_643",
"1_644",
"1_645",
"1_649",
"1_650",
"1_653",
"1_660",
"1_661",
"1_670",
"1_671",
"1_672",
"1_673",
"1_674",
"1_675",
"1_676",
"1_677",
"1_678",
"1_679",
"1_680",
"1_681",
"1_682",
"1_683",
"1_684",
"1_685",
"1_686",
"1_687",
"1_688",
"1_689",
"1_692",
"1_693",
"1_694",
"1_695",
"1_696",
"1_697",
"1_698",
"1_699",
"1_700",
"1_701",
"1_702",
"1_703",
"1_704",
"1_705",
"1_706",
"1_707",
"1_708",
"1_709",
"1_710",
"1_711",
"1_712",
"1_713",
"1_714",
"1_715",
"1_716",
"1_717",
"1_718",
"1_719",
"1_720",
"1_721",
"1_722",
"1_723",
"1_724",
"1_725",
"1_726",
"1_727",
"1_728",
"1_729",
"1_730",
"1_731",
"1_732",
"1_733",
"1_734",
"1_735",
"1_736",
"1_737",
"1_738",
"1_739",
"1_740",
"1_741",
"1_742",
"1_743",
"1_744",
"1_745",
"1_746",
"1_747",
"1_748",
"1_749",
"1_750",
"1_751",
"1_752",
"1_753",
"1_754",
"1_755",
"1_756",
"1_757",
"1_758",
"1_759",
"1_760",
"1_761",
"1_762",
"1_763",
"1_764",
"1_765",
"1_766",
"1_767",
"1_768",
"1_769",
"1_770",
"1_771",
"1_772",
"1_773",
"1_774",
"1_775",
"1_776",
"1_777",
"1_778",
"1_779",
"1_780",
"1_781",
"1_782",
"1_783",
"1_784",
"1_785",
"1_786",
"1_787",
"1_788",
"1_789",
"1_790",
"1_791",
"1_792",
"1_793",
"1_794",
"1_795",
"1_796",
"1_797",
"1_798",
"1_799",
"1_800",
"1_801",
"1_802",
"1_803",
"1_804",
"1_805",
"1_806",
"1_807",
"1_808",
"1_809",
"1_810",
"1_811",
"1_812",
"1_813",
"1_814",
"1_815",
"1_816",
"1_817",
"1_818",
"1_819",
"1_820",
"1_821",
"1_822",
"1_823",
"1_824",
"1_825",
"2_0",
"2_1",
"2_2",
"2_3",
"2_4",
"2_5",
"2_6",
"2_7",
"2_8",
"2_9",
"2_10",
"2_11",
"2_12",
"2_13",
"2_14",
"2_15",
"2_16",
"2_17",
"2_18",
"2_19",
"2_20",
"2_21",
"2_25",
"2_32",
"2_33",
"2_35",
"2_37",
"2_38",
"2_39",
"2_40",
"2_41",
"2_42",
"2_43",
"2_46",
"2_47",
"2_48",
"2_50",
"2_52",
"2_59",
"2_66",
"2_67",
"2_68",
"2_69",
"2_70",
"2_73",
"2_74",
"2_75",
"2_76",
"2_77",
"2_78",
"2_79",
"2_80",
"2_81",
"2_82",
"2_83",
"2_84",
"2_85",
"2_99",
"2_100",
"2_101",
"2_102",
"2_103",
"2_104",
"2_105",
"2_106",
"2_107",
"2_108",
"2_109",
"2_110",
"2_111",
"2_112",
"2_113",
"2_114",
"2_115",
"2_116",
"2_117",
"2_118",
"2_132",
"2_133",
"2_134",
"2_135",
"2_136",
"2_137",
"2_138",
"2_139",
"2_140",
"2_141",
"2_142",
"2_143",
"2_144",
"2_145",
"2_147",
"2_148",
"2_149",
"2_150",
"2_151",
"2_158",
"2_165",
"2_166",
"2_167",
"2_168",
"2_169",
"2_170",
"2_171",
"2_172",
"2_173",
"2_174",
"2_175",
"2_176",
"2_177",
"2_178",
"2_179",
"2_180",
"2_181",
"2_182",
"2_183",
"2_184",
"2_191",
"2_197",
"2_198",
"2_199",
"2_200",
"2_201",
"2_202",
"2_203",
"2_204",
"2_205",
"2_207",
"2_208",
"2_209",
"2_210",
"2_211",
"2_212",
"2_213",
"2_214",
"2_215",
"2_216",
"2_217",
"2_224",
"2_225",
"2_226",
"2_227",
"2_228",
"2_229",
"2_230",
"2_231",
"2_232",
"2_233",
"2_234",
"2_235",
"2_236",
"2_237",
"2_238",
"2_239",
"2_240",
"2_241",
"2_242",
"2_243",
"2_244",
"2_245",
"2_246",
"2_247",
"2_248",
"2_249",
"2_250",
"2_251",
"2_257",
"2_258",
"2_259",
"2_260",
"2_261",
"2_262",
"2_263",
"2_264",
"2_265",
"2_266",
"2_267",
"2_268",
"2_269",
"2_270",
"2_271",
"2_272",
"2_273",
"2_274",
"2_275",
"2_276",
"2_277",
"2_278",
"2_279",
"2_280",
"2_281",
"2_282",
"2_283",
"2_284",
"2_290",
"2_291",
"2_292",
"2_293",
"2_294",
"2_295",
"2_296",
"2_297",
"2_298",
"2_299",
"2_300",
"2_301",
"2_302",
"2_303",
"2_304",
"2_305",
"2_306",
"2_307",
"2_308",
"2_309",
"2_310",
"2_311",
"2_312",
"2_313",
"2_314",
"2_315",
"2_316",
"2_323",
"2_324",
"2_325",
"2_326",
"2_327",
"2_328",
"2_329",
"2_330",
"2_331",
"2_332",
"2_333",
"2_334",
"2_335",
"2_336",
"2_337",
"2_338",
"2_339",
"2_340",
"2_341",
"2_342",
"2_343",
"2_344",
"2_345",
"2_346",
"2_347",
"2_348",
"2_349",
"2_360",
"2_361",
"2_362",
"2_363",
"2_364",
"2_365",
"2_366",
"2_367",
"2_368",
"2_369",
"2_370",
"2_371",
"2_372",
"2_373",
"2_374",
"2_375",
"2_376",
"2_377",
"2_378",
"2_379",
"2_380",
"2_381",
"2_382",
"2_383",
"2_384",
"2_385",
"2_386",
"2_387",
"2_388",
"2_389",
"2_390",
"2_391",
"2_392",
"2_393",
"2_394",
"2_395",
"2_396",
"2_397",
"2_399",
"2_400",
"2_401",
"2_402",
"2_403",
"2_404",
"2_405",
"2_406",
"2_407",
"2_408",
"2_409",
"2_410",
"2_411",
"2_412",
"2_413",
"2_414",
"2_415",
"2_416",
"2_417",
"2_418",
"2_419",
"2_420",
"2_421",
"2_422",
"2_423",
"2_424",
"2_425",
"2_426",
"2_427",
"2_428",
"2_429",
"2_430",
"2_431",
"2_432",
"2_433",
"2_434",
"2_435",
"2_436",
"2_437",
"2_438",
"2_439",
"2_440",
"2_441",
"2_442",
"2_443",
"2_444",
"2_445",
"2_446",
"2_447",
"2_448",
"2_449",
"2_450",
"2_451",
"2_452",
"2_453",
"2_454",
"2_455",
"2_456",
"2_457",
"2_458",
"2_459",
"2_460",
"2_461",
"2_462",
"2_463",
"2_464",
"2_465",
"2_466",
"2_467",
"2_468",
"2_469",
"2_470",
"2_471",
"2_472",
"2_473",
"2_474",
"2_475",
"2_476",
"2_477",
"2_478",
"2_479",
"2_480",
"2_481",
"2_482",
"2_483",
"2_484",
"2_485",
"2_486",
"2_487",
"2_488",
"2_489",
"2_490",
"2_491",
"2_492",
"2_493",
"2_494",
"2_495",
"2_496",
"2_497",
"2_498",
"2_499",
"2_500",
"2_501",
"2_502",
"2_503",
"2_504",
"2_505",
"2_506",
"2_507",
"2_508",
"2_509",
"2_510",
"2_511",
"2_512",
"2_513",
"2_514",
"2_515",
"2_516",
"2_517",
"2_518",
"2_519",
"2_520",
"2_521",
"2_522",
"2_523",
"2_524",
"2_525",
"2_526",
"2_527",
"2_528",
"2_529",
"2_530",
"2_531",
"2_532",
"2_533",
"2_534",
"2_535",
"2_536",
"2_537",
"2_538",
"2_539",
"2_540",
"2_541",
"2_542",
"2_543",
"2_544",
"2_545",
"2_546",
"2_547",
"2_548",
"2_549",
"2_550",
"2_551",
"2_552",
"2_553",
"2_554",
"2_555",
"2_556",
"2_557",
"2_558",
"2_559",
"2_560",
"2_561",
"2_562",
"2_563",
"2_564",
"2_565",
"2_566",
"2_567",
"2_568",
"2_569",
"2_570",
"2_571",
"2_572",
"2_573",
"2_574",
"2_575",
"2_576",
"2_577",
"2_578",
"2_579",
"2_580",
"2_581",
"2_582",
"2_583",
"2_584",
"2_585",
"2_586",
"2_587",
"2_588",
"2_589",
"2_590",
"2_591",
"2_592",
"2_593",
"2_594",
"2_595",
"2_596",
"2_597",
"2_598",
"2_599",
"2_600",
"2_601",
"2_602",
"2_603",
"2_604",
"2_605",
"2_606",
"2_607",
"2_608",
"2_609",
"2_610",
"2_611",
"2_612",
"2_613",
"2_614",
"2_615",
"2_616",
"2_617",
"2_618",
"2_619",
"2_620",
"2_621",
"2_622",
"2_623",
"2_624",
"2_625",
"2_626",
"2_627",
"2_628",
"2_629",
"2_630",
"2_631",
"2_632",
"2_633",
"2_634",
"2_635",
"2_636",
"2_637",
"2_638",
"2_639",
"2_640",
"2_641",
"2_642",
"2_643",
"2_644",
"2_645",
"2_646",
"2_647",
"2_648",
"2_649",
"2_650",
"2_651",
"2_652",
"2_653",
"2_654",
"2_655",
"2_656",
"2_657",
"2_658",
"2_659",
"2_660",
"2_661",
"2_662",
"2_663",
"2_664",
"2_665",
"2_666",
"2_667",
"2_668",
"2_669",
"2_670",
"2_671",
"2_672",
"2_673",
"2_674",
"2_675",
"2_676",
"2_677",
"2_678",
"2_679",
"2_680",
"2_681",
"2_682",
"2_683",
"2_684",
"2_685",
"2_686",
"2_687",
"2_688",
"2_689",
"2_690",
"2_691",
"2_692",
"2_693",
"2_694",
"2_695",
"2_696",
"2_697",
"2_698",
"2_699",
"2_700",
"2_701",
"2_702",
"2_703",
"2_704",
"2_705",
"2_706",
"2_707",
"2_708",
"2_709",
"2_710",
"2_711",
"2_712",
"2_713",
"2_714",
"2_715",
"2_716",
"2_717",
"2_718",
"2_719",
"2_720",
"2_721",
"2_722",
"2_723",
"2_724",
"2_725",
"2_726",
"2_727",
"2_728",
"2_729",
"2_730",
"2_731",
"2_732",
"2_733",
"2_734",
"2_735",
"2_736",
"2_737",
"2_738",
"2_739",
"2_740",
"2_741",
"2_742",
"2_743",
"2_744",
"2_745",
"2_746",
"2_747",
"2_748",
"2_749",
"2_750",
"2_751",
"2_752",
"2_753",
"2_754",
"2_755",
"2_756",
"2_757",
"2_758",
"2_759",
"2_760",
"2_761",
"2_762",
"2_763",
"2_764",
"2_765",
"2_766",
"2_767",
"2_768",
"2_769",
"2_770",
"2_771",
"2_772",
"2_773",
"2_774",
"2_775",
"2_776",
"2_777",
"2_778",
"2_779",
"2_780",
"2_781",
"2_782",
"2_783",
"2_784",
"2_785",
"2_786",
"2_787",
"2_788",
"2_789",
"2_790",
"2_791",
"2_792",
"2_793",
"2_794",
"2_795",
"2_796",
"2_797",
"2_798",
"2_799",
"2_800",
"2_801",
"2_802",
"2_803",
"2_804",
"2_805",
"2_806",
"2_807",
"2_808",
"2_809",
"2_810",
"2_811",
"2_812",
"2_813",
"2_814",
"2_815",
"2_816",
"2_817",
"2_818",
"2_819",
"2_820",
"2_821",
"2_822",
"2_823",
"2_824",
"2_825",
}

local new = {}
local none = {}

for i, v in ipairs(tiles) do
   if not unused[v.id] then
      table.insert(new, v)
   else
      table.insert(none, v)
   end
end

print(require"inspect"(new))
print(require"inspect"(none))
