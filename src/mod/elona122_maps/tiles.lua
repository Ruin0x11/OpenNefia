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

local unseen_tiles = {
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
   }
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

   -- ...

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
   }
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
      _id = "world_desert_border_s",
      id = "0_110",
      image = "graphic/temp/map_tile/0_110.png",
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
      _id = "world_desert_plants_3",
      id = "0_126",
      image = "graphic/temp/map_tile/0_126.png",
      is_feat = true,
      kind = 7
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
      _id = "world_cliff_w",
      effect = 5,
      id = "0_495",
      image = "graphic/temp/map_tile/0_495.png"
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
      _id = "world_cliff_inner_se",
      effect = 5,
      id = "0_500",
      image = "graphic/temp/map_tile/0_500.png"
   },
   {
      _id = "world_blank",
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
      _id = "world_cliff_top_5",
      effect = 5,
      id = "0_533",
      image = "graphic/temp/map_tile/0_533.png"
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
      _id = "cobble_6",
      id = "1_105",
      image = "graphic/temp/map_tile/1_105.png"
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
      _id = "rough_4",
      id = "1_126",
      image = "graphic/temp/map_tile/1_126.png"
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
      _id = "cobble_wall_roof",
      id = "1_144",
      image = "graphic/temp/map_tile/1_144.png"
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
      image = { "graphic/temp/map_tile/1_165.png", "graphic/temp/map_tile/1_166.png", "graphic/temp/map_tile/1_167.png" },
      kind = 3
   },
   {
      _id = "anime_water_sea",
      anime_frame = 3,
      id = "1_168",
      image = { "graphic/temp/map_tile/1_168.png", "graphic/temp/map_tile/1_169.png", "graphic/temp/map_tile/1_170.png" },
      kind = 3
   },
   {
      _id = "anime_water_hot_spring",
      anime_frame = 3,
      id = "1_171",
      image = { "graphic/temp/map_tile/1_171.png", "graphic/temp/map_tile/1_172.png", "graphic/temp/map_tile/1_173.png" },
      kind = 3,
      kind2 = 5
   },
   {
      _id = "cobble_wall_top",
      id = "1_177",
      image = "graphic/temp/map_tile/1_177.png"
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
      _id = "ice_tiled_4",
      id = "1_183",
      image = "graphic/temp/map_tile/1_183.png"
   },
   {
      _id = "ice_stairs_2",
      id = "1_186",
      image = "graphic/temp/map_tile/1_186.png"
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
      _id = "cobble_raised_3",
      id = "1_196",
      image = "graphic/temp/map_tile/1_196.png"
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
      _id = "cobble_stairs_2",
      id = "1_216",
      image = "graphic/temp/map_tile/1_216.png"
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
      _id = "wall_oriental_top",
      effect = 5,
      id = "1_396",
      image = "graphic/temp/map_tile/1_396.png",
      wall = "base.wall_oriental_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_brick_top",
      effect = 5,
      id = "1_397",
      image = "graphic/temp/map_tile/1_397.png",
      wall = "base.wall_brick_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_regal_top",
      effect = 5,
      id = "1_398",
      image = "graphic/temp/map_tile/1_398.png",
      wall = "base.wall_regal_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_pillar_top",
      effect = 5,
      id = "1_399",
      image = "graphic/temp/map_tile/1_399.png",
      wall = "base.wall_pillar_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_log_top",
      effect = 5,
      id = "1_400",
      image = "graphic/temp/map_tile/1_400.png",
      wall = "base.wall_log_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_wood_top",
      effect = 5,
      id = "1_401",
      image = "graphic/temp/map_tile/1_401.png",
      wall = "base.wall_wood_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_plank_top",
      effect = 5,
      id = "1_402",
      image = "graphic/temp/map_tile/1_402.png",
      wall = "base.wall_plank_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_shingle_top",
      effect = 5,
      id = "1_403",
      image = "graphic/temp/map_tile/1_403.png",
      wall = "base.wall_shingle_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_smooth_top",
      effect = 5,
      id = "1_404",
      image = "graphic/temp/map_tile/1_404.png",
      wall = "base.wall_smooth_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_curtain_top",
      effect = 5,
      id = "1_405",
      image = "graphic/temp/map_tile/1_405.png",
      wall = "base.wall_curtain_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_moss_top",
      effect = 5,
      id = "1_406",
      image = "graphic/temp/map_tile/1_406.png",
      wall = "base.wall_moss_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_crypt_top",
      effect = 5,
      id = "1_407",
      image = "graphic/temp/map_tile/1_407.png",
      wall = "base.wall_crypt_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_ice_1_top",
      effect = 5,
      id = "1_408",
      image = "graphic/temp/map_tile/1_408.png",
      wall = "base.wall_ice_1_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_ice_2_top",
      effect = 5,
      id = "1_409",
      image = "graphic/temp/map_tile/1_409.png",
      wall = "base.wall_ice_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_ice_3_top",
      effect = 5,
      id = "1_410",
      image = "graphic/temp/map_tile/1_410.png",
      wall = "base.wall_ice_3_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_snow_1_top",
      effect = 5,
      id = "1_411",
      image = "graphic/temp/map_tile/1_411.png",
      wall = "base.wall_snow_1_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_snow_2_top",
      effect = 5,
      id = "1_412",
      image = "graphic/temp/map_tile/1_412.png",
      wall = "base.wall_snow_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_snow_3_top",
      effect = 5,
      id = "1_413",
      image = "graphic/temp/map_tile/1_413.png",
      wall = "base.wall_snow_3_bottom",
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
      _id = "wall_stone_1_top",
      effect = 5,
      id = "1_462",
      image = "graphic/temp/map_tile/1_462.png",
      wall = "base.wall_stone_1_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_2_top",
      effect = 5,
      id = "1_463",
      image = "graphic/temp/map_tile/1_463.png",
      wall = "base.wall_stone_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_3_top",
      effect = 5,
      id = "1_464",
      image = "graphic/temp/map_tile/1_464.png",
      kind = 6,
      wall = "base.wall_stone_3_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_4_top",
      effect = 5,
      id = "1_465",
      image = "graphic/temp/map_tile/1_465.png",
      wall = "base.wall_stone_4_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_5_top",
      effect = 5,
      id = "1_466",
      image = "graphic/temp/map_tile/1_466.png",
      wall = "base.wall_stone_5_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_wooden_top",
      effect = 5,
      id = "1_467",
      image = "graphic/temp/map_tile/1_467.png",
      wall = "base.wall_wooden_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_dirt_top",
      effect = 5,
      id = "1_468",
      image = "graphic/temp/map_tile/1_468.png",
      wall = "base.wall_dirt_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_dirt_dark_top",
      effect = 5,
      id = "1_469",
      image = "graphic/temp/map_tile/1_469.png",
      wall = "base.wall_dirt_dark_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_pyramid_top",
      effect = 5,
      id = "1_470",
      image = "graphic/temp/map_tile/1_470.png",
      wall = "base.wall_pyramid_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_shingled_top",
      effect = 5,
      id = "1_471",
      image = "graphic/temp/map_tile/1_471.png",
      wall = "base.wall_shingled_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_top",
      effect = 5,
      id = "1_472",
      image = "graphic/temp/map_tile/1_472.png",
      wall = "base.wall_concrete_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_light_top",
      effect = 5,
      id = "1_473",
      image = "graphic/temp/map_tile/1_473.png",
      wall = "base.wall_concrete_light_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_tower_of_fire_top",
      effect = 5,
      id = "1_474",
      image = "graphic/temp/map_tile/1_474.png",
      wall = "base.wall_tower_of_fire_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_forest_top",
      effect = 5,
      id = "1_475",
      image = "graphic/temp/map_tile/1_475.png",
      wall = "base.wall_forest_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_6_top",
      effect = 5,
      id = "1_476",
      image = "graphic/temp/map_tile/1_476.png",
      wall = "base.wall_stone_6_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_7_top",
      effect = 5,
      id = "1_477",
      image = "graphic/temp/map_tile/1_477.png",
      wall = "base.wall_stone_7_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_8_top",
      effect = 5,
      id = "1_478",
      image = "graphic/temp/map_tile/1_478.png",
      wall = "base.wall_stone_8_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_9_top",
      effect = 5,
      id = "1_479",
      image = "graphic/temp/map_tile/1_479.png",
      wall = "base.wall_stone_9_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_10_top",
      effect = 5,
      id = "1_480",
      image = "graphic/temp/map_tile/1_480.png",
      wall = "base.wall_stone_10_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_hay_top",
      effect = 5,
      id = "1_481",
      image = "graphic/temp/map_tile/1_481.png",
      wall = "base.wall_hay_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_decor_top",
      effect = 5,
      id = "1_482",
      image = "graphic/temp/map_tile/1_482.png",
      wall = "base.wall_decor_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_palace_1_top",
      effect = 5,
      id = "1_483",
      image = "graphic/temp/map_tile/1_483.png",
      wall = "base.wall_palace_1_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_palace_2_top",
      effect = 5,
      id = "1_484",
      image = "graphic/temp/map_tile/1_484.png",
      wall = "base.wall_palace_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_palace_3_top",
      effect = 5,
      id = "1_485",
      image = "graphic/temp/map_tile/1_485.png",
      wall = "base.wall_palace_3_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_10_top",
      effect = 5,
      id = "1_486",
      image = "graphic/temp/map_tile/1_486.png",
      wall = "base.wall_stone_10_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_cyber_top",
      effect = 5,
      id = "1_487",
      image = "graphic/temp/map_tile/1_487.png",
      wall = "base.wall_cyber_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_11_top",
      effect = 5,
      id = "1_488",
      image = "graphic/temp/map_tile/1_488.png",
      wall = "base.wall_stone_11_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_white_top",
      effect = 5,
      id = "1_489",
      image = "graphic/temp/map_tile/1_489.png",
      wall = "base.wall_white_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_decor_2_top",
      effect = 5,
      id = "1_490",
      image = "graphic/temp/map_tile/1_490.png",
      wall = "base.wall_decor_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_2_top",
      effect = 5,
      id = "1_491",
      image = "graphic/temp/map_tile/1_491.png",
      wall = "base.wall_concrete_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_3_top",
      effect = 5,
      id = "1_492",
      image = "graphic/temp/map_tile/1_492.png",
      wall = "base.wall_concrete_3_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_dark_1_top",
      effect = 5,
      id = "1_493",
      image = "graphic/temp/map_tile/1_493.png",
      wall = "base.wall_concrete_dark_1_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_concrete_dark_2_top",
      effect = 5,
      id = "1_494",
      image = "graphic/temp/map_tile/1_494.png",
      wall = "base.wall_concrete_dark_2_bottom",
      wall_kind = 2
   },
   {
      _id = "wall_stone_1_bottom",
      effect = 5,
      id = "1_495",
      image = "graphic/temp/map_tile/1_495.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_2_bottom",
      effect = 5,
      id = "1_496",
      image = "graphic/temp/map_tile/1_496.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_3_bottom",
      effect = 5,
      id = "1_497",
      image = "graphic/temp/map_tile/1_497.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_4_bottom",
      effect = 5,
      id = "1_498",
      image = "graphic/temp/map_tile/1_498.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_5_bottom",
      effect = 5,
      id = "1_499",
      image = "graphic/temp/map_tile/1_499.png",
      wall_kind = 1
   },
   {
      _id = "wall_wooden_bottom",
      effect = 5,
      id = "1_500",
      image = "graphic/temp/map_tile/1_500.png",
      wall_kind = 1
   },
   {
      _id = "wall_dirt_bottom",
      effect = 5,
      id = "1_501",
      image = "graphic/temp/map_tile/1_501.png",
      wall_kind = 1
   },
   {
      _id = "wall_dirt_dark_bottom",
      effect = 5,
      id = "1_502",
      image = "graphic/temp/map_tile/1_502.png",
      wall_kind = 1
   },
   {
      _id = "wall_pyramid_bottom",
      effect = 5,
      id = "1_503",
      image = "graphic/temp/map_tile/1_503.png",
      wall_kind = 1
   },
   {
      _id = "wall_shingled_bottom",
      effect = 5,
      id = "1_504",
      image = "graphic/temp/map_tile/1_504.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_bottom",
      effect = 5,
      id = "1_505",
      image = "graphic/temp/map_tile/1_505.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_light_bottom",
      effect = 5,
      id = "1_506",
      image = "graphic/temp/map_tile/1_506.png",
      wall_kind = 1
   },
   {
      _id = "wall_tower_of_fire_bottom",
      effect = 5,
      id = "1_507",
      image = "graphic/temp/map_tile/1_507.png",
      wall_kind = 1
   },
   {
      _id = "wall_forest_bottom",
      effect = 5,
      id = "1_508",
      image = "graphic/temp/map_tile/1_508.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_6_bottom",
      effect = 5,
      id = "1_509",
      image = "graphic/temp/map_tile/1_509.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_7_bottom",
      effect = 5,
      id = "1_510",
      image = "graphic/temp/map_tile/1_510.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_8_bottom",
      effect = 5,
      id = "1_511",
      image = "graphic/temp/map_tile/1_511.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_9_bottom",
      effect = 5,
      id = "1_512",
      image = "graphic/temp/map_tile/1_512.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_10_bottom",
      effect = 5,
      id = "1_513",
      image = "graphic/temp/map_tile/1_513.png",
      wall_kind = 1
   },
   {
      _id = "wall_hay_bottom",
      effect = 5,
      id = "1_514",
      image = "graphic/temp/map_tile/1_514.png",
      wall_kind = 1
   },
   {
      _id = "wall_decor_bottom",
      effect = 5,
      id = "1_515",
      image = "graphic/temp/map_tile/1_515.png",
      wall_kind = 1
   },
   {
      _id = "wall_palace_1_bottom",
      effect = 5,
      id = "1_516",
      image = "graphic/temp/map_tile/1_516.png",
      wall_kind = 1
   },
   {
      _id = "wall_palace_2_bottom",
      effect = 5,
      id = "1_517",
      image = "graphic/temp/map_tile/1_517.png",
      wall_kind = 1
   },
   {
      _id = "wall_palace_3_bottom",
      effect = 5,
      id = "1_518",
      image = "graphic/temp/map_tile/1_518.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_10_bottom",
      effect = 5,
      id = "1_519",
      image = "graphic/temp/map_tile/1_519.png",
      wall_kind = 1
   },
   {
      _id = "wall_cyber_bottom",
      effect = 5,
      id = "1_520",
      image = "graphic/temp/map_tile/1_520.png",
      wall_kind = 1
   },
   {
      _id = "wall_stone_11_bottom",
      effect = 5,
      id = "1_521",
      image = "graphic/temp/map_tile/1_521.png",
      wall_kind = 1
   },
   {
      _id = "wall_white_bottom",
      effect = 5,
      id = "1_522",
      image = "graphic/temp/map_tile/1_522.png",
      wall_kind = 1
   },
   {
      _id = "wall_decor_2_bottom",
      effect = 5,
      id = "1_523",
      image = "graphic/temp/map_tile/1_523.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_2_bottom",
      effect = 5,
      id = "1_524",
      image = "graphic/temp/map_tile/1_524.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_3_bottom",
      effect = 5,
      id = "1_525",
      image = "graphic/temp/map_tile/1_525.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_dark_1_bottom",
      effect = 5,
      id = "1_526",
      image = "graphic/temp/map_tile/1_526.png",
      wall_kind = 1
   },
   {
      _id = "wall_concrete_dark_2_bottom",
      effect = 5,
      id = "1_527",
      image = "graphic/temp/map_tile/1_527.png",
      wall_kind = 1
   },
   {
      _id = "stable_top",
      effect = 5,
      id = "1_543",
      image = "graphic/temp/map_tile/1_543.png"
   },
   {
      _id = "palace_fountain",
      effect = 5,
      id = "1_550",
      image = {
         "graphic/temp/map_tile/1_550.png",
         "graphic/temp/map_tile/1_551.png",
      },
      wall_kind = 1,
   },
   {
      _id = "light_grass_carts",
      effect = 5,
      id = "1_564",
      image = "graphic/temp/map_tile/1_564.png"
   },
   {
      _id = "light_grass_carts_gold",
      effect = 5,
      id = "1_565",
      image = "graphic/temp/map_tile/1_565.png"
   },
   {
      _id = "light_grass_carts_jewels",
      effect = 5,
      id = "1_566",
      image = "graphic/temp/map_tile/1_566.png"
   },
   {
      _id = "light_grass_carts_rocks",
      effect = 5,
      id = "1_567",
      image = "graphic/temp/map_tile/1_567.png"
   },
   {
      _id = "light_grass_rocks",
      effect = 5,
      id = "1_568",
      image = "graphic/temp/map_tile/1_568.png"
   },
   {
      _id = "light_grass_fencing_ns",
      effect = 5,
      id = "1_572",
      image = "graphic/temp/map_tile/1_572.png"
   },
   {
      _id = "light_grass_fencing_we",
      effect = 5,
      id = "1_573",
      image = "graphic/temp/map_tile/1_573.png"
   },
   {
      _id = "grass_fencing_ns",
      effect = 5,
      id = "1_574",
      image = "graphic/temp/map_tile/1_574.png"
   },
   {
      _id = "grass_fencing_we",
      effect = 5,
      id = "1_575",
      image = "graphic/temp/map_tile/1_575.png"
   },
   {
      _id = "stable_bottom",
      effect = 5,
      id = "1_576",
      image = "graphic/temp/map_tile/1_576.png"
   },
   {
      _id = "horse",
      effect = 5,
      id = "1_577",
      image = "graphic/temp/map_tile/1_577.png"
   },
   {
      _id = "water",
      anime_frame = 3,
      effect = 4,
      id = "1_594",
      image = {
         "graphic/temp/map_tile/1_594.png",
         "graphic/temp/map_tile/1_595.png",
         "graphic/temp/map_tile/1_596.png",
      },
      kind = 3
   },
   {
      _id = "light_grass_box",
      effect = 5,
      id = "1_627",
      image = "graphic/temp/map_tile/1_627.png"
   },
   {
      _id = "water_wall_edge",
      effect = 4,
      id = "1_628",
      image = "graphic/temp/map_tile/1_628.png"
   },
   {
      _id = "cobble_diagonal_fish",
      effect = 5,
      id = "1_629",
      image = "graphic/temp/map_tile/1_629.png"
   },
   {
      _id = "cobble_diagonal_posts",
      effect = 5,
      id = "1_630",
      image = "graphic/temp/map_tile/1_630.png"
   },
   {
      _id = "crates_open",
      effect = 5,
      id = "1_631",
      image = "graphic/temp/map_tile/1_631.png"
   },
   {
      _id = "crates",
      effect = 5,
      id = "1_632",
      image = "graphic/temp/map_tile/1_632.png"
   },
   {
      _id = "wharf_crates_1",
      effect = 5,
      id = "1_633",
      image = "graphic/temp/map_tile/1_633.png"
   },
   {
      _id = "wharf_crates_2",
      effect = 5,
      id = "1_634",
      image = "graphic/temp/map_tile/1_634.png"
   },
   {
      _id = "cobble_diagonal_net",
      effect = 5,
      id = "1_635",
      image = "graphic/temp/map_tile/1_635.png"
   },
   {
      _id = "cobble_statue",
      effect = 5,
      id = "1_636",
      image = "graphic/temp/map_tile/1_636.png"
   },
   {
      _id = "water_wall_edge_grass",
      effect = 4,
      id = "1_637",
      image = "graphic/temp/map_tile/1_637.png"
   },
   {
      _id = "cobble_pillar",
      effect = 5,
      id = "1_638",
      image = "graphic/temp/map_tile/1_638.png"
   },
   {
      _id = "carpet_3_fish_boards",
      effect = 5,
      id = "1_639",
      image = "graphic/temp/map_tile/1_639.png"
   },
   {
      _id = "cobble_fence",
      effect = 4,
      id = "1_641",
      image = "graphic/temp/map_tile/1_641.png"
   },
   {
      _id = "sign_magic",
      effect = 5,
      id = "1_646",
      image = "graphic/temp/map_tile/1_646.png"
   },
   {
      _id = "sign_inn",
      effect = 5,
      id = "1_647",
      image = "graphic/temp/map_tile/1_647.png"
   },
   {
      _id = "sign_equip",
      effect = 5,
      id = "1_648",
      image = "graphic/temp/map_tile/1_648.png"
   },
   {
      _id = "sign_blacksmith",
      effect = 5,
      id = "1_651",
      image = "graphic/temp/map_tile/1_651.png"
   },
   {
      _id = "sign_general_vendor",
      effect = 5,
      id = "1_652",
      image = "graphic/temp/map_tile/1_652.png"
   },
   {
      _id = "sign_shield",
      effect = 5,
      id = "1_654",
      image = "graphic/temp/map_tile/1_654.png"
   },
   {
      _id = "sign_potion",
      effect = 5,
      id = "1_655",
      image = "graphic/temp/map_tile/1_655.png"
   },
   {
      _id = "sign_lamp",
      effect = 5,
      id = "1_656",
      image = "graphic/temp/map_tile/1_656.png"
   },
   {
      _id = "sign_bakery",
      effect = 5,
      id = "1_657",
      image = "graphic/temp/map_tile/1_657.png"
   },
   {
      _id = "sign_pub",
      effect = 5,
      id = "1_658",
      image = "graphic/temp/map_tile/1_658.png"
   },
   {
      _id = "sign_casino",
      effect = 5,
      id = "1_659",
      image = "graphic/temp/map_tile/1_659.png"
   },
   {
      _id = "stacked_wood",
      effect = 5,
      id = "1_662",
      image = "graphic/temp/map_tile/1_662.png"
   },
   {
      _id = "stacked_sacks",
      effect = 5,
      id = "1_663",
      image = "graphic/temp/map_tile/1_663.png"
   },
   {
      _id = "stacked_crates_green",
      effect = 5,
      id = "1_664",
      image = "graphic/temp/map_tile/1_664.png"
   },
   {
      _id = "stacked_crates",
      effect = 5,
      id = "1_665",
      image = "graphic/temp/map_tile/1_665.png"
   },
   {
      _id = "snow_large_mound",
      effect = 5,
      id = "1_666",
      image = "graphic/temp/map_tile/1_666.png"
   },
   {
      _id = "cobble_raised_4",
      effect = 5,
      id = "1_667",
      image = "graphic/temp/map_tile/1_667.png"
   },
   {
      _id = "snow_log",
      effect = 5,
      id = "1_668",
      image = "graphic/temp/map_tile/1_668.png"
   },
   {
      _id = "ice_wall_edge",
      effect = 5,
      id = "1_669",
      image = "graphic/temp/map_tile/1_669.png"
   },
   {
      _id = "boat_left",
      effect = 5,
      id = "1_690",
      image = "graphic/temp/map_tile/1_690.png"
   },
   {
      _id = "boat_right",
      effect = 5,
      id = "1_691",
      image = "graphic/temp/map_tile/1_691.png"
   },
   {
      _id = "onii_1",
      id = "2_22",
      image = "graphic/temp/map_tile/2_22.png",
      kind = 4
   },
   {
      _id = "onii_2",
      id = "2_23",
      image = "graphic/temp/map_tile/2_23.png",
      kind = 4
   },
   {
      _id = "onii_3",
      id = "2_24",
      image = "graphic/temp/map_tile/2_24.png",
      kind = 4
   },
   {
      _id = "onii_4",
      id = "2_26",
      image = "graphic/temp/map_tile/2_26.png",
      kind = 4
   },
   {
      _id = "onii_5",
      id = "2_27",
      image = "graphic/temp/map_tile/2_27.png",
      kind = 4
   },
   {
      _id = "onii_6",
      id = "2_28",
      image = "graphic/temp/map_tile/2_28.png",
      kind = 4
   },
   {
      _id = "onii_7",
      id = "2_29",
      image = "graphic/temp/map_tile/2_29.png",
      kind = 4
   },
   {
      _id = "onii_8",
      id = "2_30",
      image = "graphic/temp/map_tile/2_30.png",
      kind = 4
   },
   {
      _id = "onii_9",
      id = "2_31",
      image = "graphic/temp/map_tile/2_31.png",
      kind = 4
   },
   {
      _id = "snow_cracks_atlas2",
      id = "2_34",
      image = "graphic/temp/map_tile/2_34.png",
      kind = 4
   },
   {
      _id = "snow_grass_atlas2",
      id = "2_36",
      image = "graphic/temp/map_tile/2_36.png",
      kind = 4
   },
   {
      _id = "snow_pillar_atlas2",
      id = "2_44",
      image = "graphic/temp/map_tile/2_44.png",
      kind = 4
   },
   {
      _id = "snow_plants_atlas2",
      id = "2_51",
      image = "graphic/temp/map_tile/2_51.png",
      kind = 4
   },
   {
      _id = "onii_10",
      id = "2_53",
      image = "graphic/temp/map_tile/2_53.png",
      kind = 4
   },
   {
      _id = "onii_11",
      id = "2_54",
      image = "graphic/temp/map_tile/2_54.png",
      kind = 4
   },
   {
      _id = "onii_12",
      id = "2_55",
      image = "graphic/temp/map_tile/2_55.png",
      kind = 4
   },
   {
      _id = "onii_13",
      id = "2_56",
      image = "graphic/temp/map_tile/2_56.png",
      kind = 4
   },
   {
      _id = "onii_14",
      id = "2_57",
      image = "graphic/temp/map_tile/2_57.png",
      kind = 4
   },
   {
      _id = "onii_15",
      id = "2_58",
      image = "graphic/temp/map_tile/2_58.png",
      kind = 4
   },
   {
      _id = "onii_16",
      id = "2_60",
      image = "graphic/temp/map_tile/2_60.png",
      kind = 4
   },
   {
      _id = "onii_17",
      id = "2_61",
      image = "graphic/temp/map_tile/2_61.png",
      kind = 4
   },
   {
      _id = "onii_18",
      id = "2_62",
      image = "graphic/temp/map_tile/2_62.png",
      kind = 4
   },
   {
      _id = "onii_19",
      id = "2_63",
      image = "graphic/temp/map_tile/2_63.png",
      kind = 4
   },
   {
      _id = "onii_20",
      id = "2_64",
      image = "graphic/temp/map_tile/2_64.png",
      kind = 4
   },
   {
      _id = "onii_21",
      id = "2_65",
      image = "graphic/temp/map_tile/2_65.png",
      kind = 4
   },
   {
      _id = "onii_22",
      id = "2_86",
      image = "graphic/temp/map_tile/2_86.png",
      kind = 4
   },
   {
      _id = "onii_23",
      id = "2_87",
      image = "graphic/temp/map_tile/2_87.png",
      kind = 4
   },
   {
      _id = "onii_24",
      id = "2_88",
      image = "graphic/temp/map_tile/2_88.png",
      kind = 4
   },
   {
      _id = "onii_25",
      id = "2_89",
      image = "graphic/temp/map_tile/2_89.png",
      kind = 4
   },
   {
      _id = "onii_26",
      id = "2_90",
      image = "graphic/temp/map_tile/2_90.png",
      kind = 4
   },
   {
      _id = "onii_27",
      id = "2_91",
      image = "graphic/temp/map_tile/2_91.png",
      kind = 4
   },
   {
      _id = "onii_28",
      id = "2_92",
      image = "graphic/temp/map_tile/2_92.png",
      kind = 4
   },
   {
      _id = "onii_29",
      id = "2_93",
      image = "graphic/temp/map_tile/2_93.png",
      kind = 4
   },
   {
      _id = "onii_30",
      id = "2_94",
      image = "graphic/temp/map_tile/2_94.png",
      kind = 4
   },
   {
      _id = "onii_31",
      id = "2_95",
      image = "graphic/temp/map_tile/2_95.png",
      kind = 4
   },
   {
      _id = "onii_32",
      id = "2_96",
      image = "graphic/temp/map_tile/2_96.png",
      kind = 4
   },
   {
      _id = "onii_33",
      id = "2_97",
      image = "graphic/temp/map_tile/2_97.png",
      kind = 4
   },
   {
      _id = "onii_34",
      id = "2_98",
      image = "graphic/temp/map_tile/2_98.png",
      kind = 4
   },
   {
      _id = "onii_35",
      id = "2_119",
      image = "graphic/temp/map_tile/2_119.png",
      kind = 4
   },
   {
      _id = "onii_36",
      id = "2_120",
      image = "graphic/temp/map_tile/2_120.png",
      kind = 4
   },
   {
      _id = "onii_37",
      id = "2_121",
      image = "graphic/temp/map_tile/2_121.png",
      kind = 4
   },
   {
      _id = "onii_38",
      id = "2_122",
      image = "graphic/temp/map_tile/2_122.png",
      kind = 4
   },
   {
      _id = "onii_39",
      id = "2_123",
      image = "graphic/temp/map_tile/2_123.png",
      kind = 4
   },
   {
      _id = "onii_40",
      id = "2_124",
      image = "graphic/temp/map_tile/2_124.png",
      kind = 4
   },
   {
      _id = "onii_41",
      id = "2_125",
      image = "graphic/temp/map_tile/2_125.png",
      kind = 4
   },
   {
      _id = "onii_42",
      id = "2_126",
      image = "graphic/temp/map_tile/2_126.png",
      kind = 4
   },
   {
      _id = "onii_43",
      id = "2_127",
      image = "graphic/temp/map_tile/2_127.png",
      kind = 4
   },
   {
      _id = "onii_44",
      id = "2_128",
      image = "graphic/temp/map_tile/2_128.png",
      kind = 4
   },
   {
      _id = "onii_45",
      id = "2_129",
      image = "graphic/temp/map_tile/2_129.png",
      kind = 4
   },
   {
      _id = "onii_46",
      id = "2_130",
      image = "graphic/temp/map_tile/2_130.png",
      kind = 4
   },
   {
      _id = "onii_47",
      id = "2_131",
      image = "graphic/temp/map_tile/2_131.png",
      kind = 4
   },
   {
      _id = "onii_48",
      id = "2_152",
      image = "graphic/temp/map_tile/2_152.png",
      kind = 4
   },
   {
      _id = "onii_49",
      id = "2_153",
      image = "graphic/temp/map_tile/2_153.png",
      kind = 4
   },
   {
      _id = "onii_50",
      id = "2_154",
      image = "graphic/temp/map_tile/2_154.png",
      kind = 4
   },
   {
      _id = "onii_51",
      id = "2_155",
      image = "graphic/temp/map_tile/2_155.png",
      kind = 4
   },
   {
      _id = "onii_52",
      id = "2_156",
      image = "graphic/temp/map_tile/2_156.png",
      kind = 4
   },
   {
      _id = "onii_53",
      id = "2_157",
      image = "graphic/temp/map_tile/2_157.png",
      kind = 4
   },
   {
      _id = "onii_54",
      id = "2_159",
      image = "graphic/temp/map_tile/2_159.png",
      kind = 4
   },
   {
      _id = "onii_55",
      id = "2_160",
      image = "graphic/temp/map_tile/2_160.png",
      kind = 4
   },
   {
      _id = "onii_56",
      id = "2_161",
      image = "graphic/temp/map_tile/2_161.png",
      kind = 4
   },
   {
      _id = "onii_57",
      id = "2_162",
      image = "graphic/temp/map_tile/2_162.png",
      kind = 4
   },
   {
      _id = "onii_58",
      id = "2_163",
      image = "graphic/temp/map_tile/2_163.png",
      kind = 4
   },
   {
      _id = "onii_59",
      id = "2_164",
      image = "graphic/temp/map_tile/2_164.png",
      kind = 4
   },
   {
      _id = "onii_60",
      id = "2_185",
      image = "graphic/temp/map_tile/2_185.png",
      kind = 4
   },
   {
      _id = "onii_61",
      id = "2_186",
      image = "graphic/temp/map_tile/2_186.png",
      kind = 4
   },
   {
      _id = "onii_62",
      id = "2_187",
      image = "graphic/temp/map_tile/2_187.png",
      kind = 4
   },
   {
      _id = "onii_63",
      id = "2_188",
      image = "graphic/temp/map_tile/2_188.png",
      kind = 4
   },
   {
      _id = "onii_64",
      id = "2_189",
      image = "graphic/temp/map_tile/2_189.png",
      kind = 4
   },
   {
      _id = "onii_65",
      id = "2_190",
      image = "graphic/temp/map_tile/2_190.png",
      kind = 4
   },
   {
      _id = "onii_66",
      id = "2_192",
      image = "graphic/temp/map_tile/2_192.png",
      kind = 4
   },
   {
      _id = "onii_67",
      id = "2_193",
      image = "graphic/temp/map_tile/2_193.png",
      kind = 4
   },
   {
      _id = "onii_68",
      id = "2_194",
      image = "graphic/temp/map_tile/2_194.png",
      kind = 4
   },
   {
      _id = "onii_69",
      id = "2_195",
      image = "graphic/temp/map_tile/2_195.png",
      kind = 4
   },
   {
      _id = "onii_70",
      id = "2_196",
      image = "graphic/temp/map_tile/2_196.png",
      kind = 4
   },
   {
      _id = "onii_71",
      id = "2_218",
      image = "graphic/temp/map_tile/2_218.png",
      kind = 4
   },
   {
      _id = "onii_72",
      id = "2_219",
      image = "graphic/temp/map_tile/2_219.png",
      kind = 4
   },
   {
      _id = "onii_73",
      id = "2_220",
      image = "graphic/temp/map_tile/2_220.png",
      kind = 4
   },
   {
      _id = "onii_74",
      id = "2_221",
      image = "graphic/temp/map_tile/2_221.png",
      kind = 4
   },
   {
      _id = "onii_75",
      id = "2_222",
      image = "graphic/temp/map_tile/2_222.png",
      kind = 4
   },
   {
      _id = "onii_76",
      id = "2_223",
      image = "graphic/temp/map_tile/2_223.png",
      kind = 4
   },
   {
      _id = "onii_77",
      id = "2_252",
      image = "graphic/temp/map_tile/2_252.png",
      kind = 4
   },
   {
      _id = "onii_78",
      id = "2_253",
      image = "graphic/temp/map_tile/2_253.png",
      kind = 4
   },
   {
      _id = "onii_79",
      id = "2_254",
      image = "graphic/temp/map_tile/2_254.png",
      kind = 4
   },
   {
      _id = "onii_80",
      id = "2_255",
      image = "graphic/temp/map_tile/2_255.png",
      kind = 4
   },
   {
      _id = "onii_81",
      id = "2_256",
      image = "graphic/temp/map_tile/2_256.png",
      kind = 4
   },
   {
      _id = "onii_82",
      id = "2_285",
      image = "graphic/temp/map_tile/2_285.png",
      kind = 4
   },
   {
      _id = "onii_83",
      id = "2_286",
      image = "graphic/temp/map_tile/2_286.png",
      kind = 4
   },
   {
      _id = "onii_84",
      id = "2_287",
      image = "graphic/temp/map_tile/2_287.png",
      kind = 4
   },
   {
      _id = "onii_85",
      id = "2_288",
      image = "graphic/temp/map_tile/2_288.png",
      kind = 4
   },
   {
      _id = "onii_86",
      id = "2_289",
      image = "graphic/temp/map_tile/2_289.png",
      kind = 4
   },
   {
      _id = "onii_87",
      id = "2_317",
      image = "graphic/temp/map_tile/2_317.png",
      kind = 4
   },
   {
      _id = "onii_88",
      id = "2_318",
      image = "graphic/temp/map_tile/2_318.png",
      kind = 4
   },
   {
      _id = "onii_89",
      id = "2_319",
      image = "graphic/temp/map_tile/2_319.png",
      kind = 4
   },
   {
      _id = "onii_90",
      id = "2_320",
      image = "graphic/temp/map_tile/2_320.png",
      kind = 4
   },
   {
      _id = "onii_91",
      id = "2_321",
      image = "graphic/temp/map_tile/2_321.png",
      kind = 4
   },
   {
      _id = "onii_92",
      id = "2_322",
      image = "graphic/temp/map_tile/2_322.png",
      kind = 4
   },
   {
      _id = "onii_93",
      id = "2_350",
      image = "graphic/temp/map_tile/2_350.png",
      kind = 4
   },
   {
      _id = "onii_94",
      id = "2_351",
      image = "graphic/temp/map_tile/2_351.png",
      kind = 4
   },
   {
      _id = "onii_95",
      id = "2_352",
      image = "graphic/temp/map_tile/2_352.png",
      kind = 4
   },
   {
      _id = "onii_96",
      id = "2_353",
      image = "graphic/temp/map_tile/2_353.png",
      kind = 4
   },
   {
      _id = "onii_97",
      id = "2_354",
      image = "graphic/temp/map_tile/2_354.png",
      kind = 4
   },
   {
      _id = "onii_98",
      id = "2_355",
      image = "graphic/temp/map_tile/2_355.png",
      kind = 4
   },
   {
      _id = "onii_99",
      id = "2_356",
      image = "graphic/temp/map_tile/2_356.png",
      kind = 4
   },
   {
      _id = "onii_100",
      id = "2_357",
      image = "graphic/temp/map_tile/2_357.png",
      kind = 4
   },
   {
      _id = "onii_101",
      id = "2_358",
      image = "graphic/temp/map_tile/2_358.png",
      kind = 4
   },
   {
      _id = "onii_102",
      id = "2_359",
      image = "graphic/temp/map_tile/2_359.png",
      kind = 4
   }
}

local packed = {}
for _, v in ipairs(tiles) do
   print(v.id)
   packed[v.id] = v
end

return { packed, same }
