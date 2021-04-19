data:add_type {
   name = "item_ex_mapping",
   fields = {
      {
         name = "item_id",
         template = true,
         default = "",
         type = "id:base.item"
      },
      {
         name = "chip_id",
         template = true,
         type = "integer?"
      },
      {
         name = "chip_on_identify",
         template = true,
         type = "id:base.chip?"
      },
      {
         name = "color_on_identify",
         template = true,
         type = "color?|string?"
      }
   }
}

data:add {
   _type = "base.theme_transform",
   _id = "item_ex_mapping",

   applies_to = "ffhp.item_ex_mapping",
   transform = function(t, override)
      t.chip_on_identify = override.chip_on_identify
      t.color_on_identify = override.color_on_identify
      return t
   end
}

local mappings = {
   {
      _id = "ex_potion_540",
      chip_id = 540,
      item_id = "elona.potion_of_blindness",
   },
   {
      _id = "ex_potion_548",
      chip_id = 548,
      item_id = "elona.potion_of_troll_blood",
   },
   {
      _id = "ex_spellbook_615",
      chip_id = 615,
      item_id = "elona.spellbook_of_contingency",
   },
   {
      _id = "ex_scroll_674",
      chip_id = 674,
      item_id = "elona.flying_scroll",
   },
   {
      _id = "ex_potion_552",
      chip_id = 552,
      item_id = "elona.potion_of_resistance",
   },
   {
      _id = "ex_spellbook_639",
      chip_id = 639,
      item_id = "elona.spellbook_of_elemental_scar",
   },
   {
      _id = "ex_rod_586",
      chip_id = 586,
      item_id = "elona.rod_of_slow",
   },
   {
      _id = "ex_scroll_666",
      chip_id = 666,
      item_id = "elona.scroll_of_holy_light",
   },
   {
      _id = "ex_potion_533",
      chip_id = 533,
      item_id = "elona.potion_of_cure_major_wound",
   },
   {
      _id = "ex_potion_529",
      chip_id = 529,
      item_id = "elona.potion_of_evolution",
   },
   {
      _id = "ex_spellbook_612",
      chip_id = 612,
      item_id = "elona.spellbook_of_speed",
   },
   {
      _id = "ex_ffhp_686",
      chip_id = 686,
      item_id = "elona.treasure_map",
   },
   {
      _id = "ex_spellbook_614",
      chip_id = 614,
      item_id = "elona.spellbook_of_holy_veil",
   },
   {
      _id = "ex_potion_547",
      chip_id = 547,
      item_id = "elona.potion_of_speed",
   },
   {
      _id = "ex_scroll_657",
      chip_id = 657,
      item_id = "elona.scroll_of_identify",
   },
   {
      _id = "ex_potion_551",
      chip_id = 551,
      item_id = "elona.potion_of_restore_spirit",
   },
   {
      _id = "ex_spellbook_606",
      chip_id = 606,
      item_id = "elona.spellbook_of_holy_light",
   },
   {
      _id = "ex_scroll_649",
      chip_id = 649,
      item_id = "elona.scroll_of_curse",
   },
   {
      _id = "ex_spellbook_646",
      chip_id = 646,
      item_id = "elona.spellbook_of_harvest",
   },
   {
      _id = "ex_potion_520",
      chip_id = 520,
      item_id = "elona.bottle_of_water",
   },
   {
      _id = "ex_spellbook_623",
      chip_id = 623,
      item_id = "elona.spellbook_of_darkness_arrow",
   },
   {
      _id = "ex_potion_528",
      chip_id = 528,
      item_id = "elona.potion_of_potential",
   },
   {
      _id = "ex_ffhp_685",
      chip_id = 685,
      item_id = "elona.bejeweled_chest",
   },
   {
      _id = "ex_potion_532",
      chip_id = 532,
      item_id = "elona.potion_of_cure_minor_wound",
   },
   {
      _id = "ex_spellbook_609",
      chip_id = 609,
      item_id = "elona.spellbook_of_holy_shield",
   },
   {
      _id = "ex_scroll_668",
      chip_id = 668,
      item_id = "elona.scroll_of_faith",
   },
   {
      _id = "ex_spellbook_625",
      chip_id = 625,
      item_id = "elona.spellbook_of_fire_bolt",
   },
   {
      _id = "ex_scroll_676",
      chip_id = 676,
      item_id = "elona.scroll_of_change_material",
   },
   {
      _id = "ex_scroll_652",
      chip_id = 652,
      item_id = "elona.scroll_of_return",
   },
   {
      _id = "ex_ffhp_688",
      chip_id = 688,
      item_id = "elona.happy_bed",
   },
   {
      _id = "ex_spellbook_595",
      chip_id = 595,
      item_id = "elona.spellbook_of_nightmare",
   },
   {
      _id = "ex_rod_577",
      chip_id = 577,
      item_id = "elona.rod_of_web",
   },
   {
      _id = "ex_ffhp_684",
      chip_id = 684,
      item_id = "elona.chest",
   },
   {
      _id = "ex_scroll_681",
      chip_id = 681,
      item_id = "elona.scroll_of_greater_enchant_armor",
   },
   {
      _id = "ex_scroll_689",
      chip_id = 689,
      item_id = "elona.scroll_of_uncurse",
   },
   {
      _id = "ex_rod_565",
      chip_id = 565,
      item_id = "elona.rod_of_change_creature",
   },
   {
      _id = "ex_spellbook_592",
      chip_id = 592,
      item_id = "elona.spellbook_of_magic_mapping",
   },
   {
      _id = "ex_spellbook_624",
      chip_id = 624,
      item_id = "elona.spellbook_of_ice_bolt",
   },
   {
      _id = "ex_scroll_675",
      chip_id = 675,
      item_id = "elona.scroll_of_inferior_material",
   },
   {
      _id = "ex_spellbook_600",
      chip_id = 600,
      item_id = "elona.spellbook_of_cure_minor_wound",
   },
   {
      _id = "ex_scroll_659",
      chip_id = 659,
      item_id = "elona.scroll_of_mana",
   },
   {
      _id = "ex_spellbook_640",
      chip_id = 640,
      item_id = "elona.spellbook_of_acid_ground",
   },
   {
      _id = "ex_spellbook_641",
      chip_id = 641,
      item_id = "elona.spellbook_of_fire_wall",
   },
   {
      _id = "ex_rod_570",
      chip_id = 570,
      item_id = "elona.rod_of_cure_minor_wound",
   },
   {
      _id = "ex_rod_582",
      chip_id = 582,
      item_id = "elona.rod_of_lightning_bolt",
   },
   {
      _id = "ex_scroll_680",
      chip_id = 680,
      item_id = "elona.scroll_of_enchant_armor",
   },
   {
      _id = "ex_spellbook_619",
      chip_id = 619,
      item_id = "elona.spellbook_of_magic_arrow",
   },
   {
      _id = "ex_scroll_670",
      chip_id = 670,
      item_id = "elona.scroll_of_recharge",
   },
   {
      _id = "ex_potion_544",
      chip_id = 544,
      item_id = "elona.potion_of_weakness",
   },
   {
      _id = "ex_rod_576",
      chip_id = 576,
      item_id = "elona.rod_of_uncurse",
   },
   {
      _id = "ex_potion_556",
      chip_id = 556,
      item_id = "elona.fireproof_liquid",
   },
   {
      _id = "ex_scroll_654",
      chip_id = 654,
      item_id = "elona.scroll_of_healing_rain",
   },
   {
      _id = "ex_scroll_662",
      chip_id = 662,
      item_id = "elona.scroll_of_gain_attribute",
   },
   {
      _id = "ex_spellbook_635",
      chip_id = 635,
      item_id = "elona.spellbook_of_wall_creation",
   },
   {
      _id = "ex_rod_573",
      chip_id = 573,
      item_id = "elona.rod_of_heal",
   },
   {
      _id = "ex_potion_537",
      chip_id = 537,
      item_id = "elona.potion_of_healer_eris",
   },
   {
      _id = "ex_rod_569",
      chip_id = 569,
      item_id = "elona.rod_of_fire_wall",
   },
   {
      _id = "ex_spellbook_597",
      chip_id = 597,
      item_id = "elona.spellbook_of_incognito",
   },
   {
      _id = "ex_potion_525",
      chip_id = 525,
      item_id = "elona.potion_of_cure_corruption",
   },
   {
      _id = "ex_rod_571",
      chip_id = 571,
      item_id = "elona.rod_of_cure",
   },
   {
      _id = "ex_rod_567",
      chip_id = 567,
      item_id = "elona.rod_of_wall_creation",
   },
   {
      _id = "ex_spellbook_632",
      chip_id = 632,
      item_id = "elona.spellbook_of_chaos_ball",
   },
   {
      _id = "ex_rod_578",
      chip_id = 578,
      item_id = "elona.rod_of_summon_monsters",
   },
   {
      _id = "ex_ffhp_692",
      chip_id = 692,
      item_id = "elona.raw_noodle",
   },
   {
      _id = "ex_scroll_653",
      chip_id = 653,
      item_id = "elona.scroll_of_escape",
   },
   {
      _id = "ex_scroll_661",
      chip_id = 661,
      item_id = "elona.scroll_of_growth",
   },
   {
      _id = "ex_scroll_669",
      chip_id = 669,
      item_id = "elona.scroll_of_ally",
   },
   {
      _id = "ex_potion_555",
      chip_id = 555,
      item_id = "elona.acidproof_liquid",
   },
   {
      _id = "ex_spellbook_610",
      chip_id = 610,
      item_id = "elona.spellbook_of_regeneration",
   },
   {
      _id = "ex_spellbook_626",
      chip_id = 626,
      item_id = "elona.spellbook_of_lightning_bolt",
   },
   {
      _id = "ex_spellbook_603",
      chip_id = 603,
      item_id = "elona.spellbook_of_cure_jure",
   },
   {
      _id = "ex_spellbook_611",
      chip_id = 611,
      item_id = "elona.spellbook_of_resistance",
   },
   {
      _id = "ex_rod_572",
      chip_id = 572,
      item_id = "elona.rod_of_healing_hands",
   },
   {
      _id = "ex_spellbook_596",
      chip_id = 596,
      item_id = "elona.spellbook_of_mutation",
   },
   {
      _id = "ex_potion_524",
      chip_id = 524,
      item_id = "elona.love_potion",
   },
   {
      _id = "ex_spellbook_643",
      chip_id = 643,
      item_id = "elona.spellbook_of_magic_laser",
   },
   {
      _id = "ex_potion_536",
      chip_id = 536,
      item_id = "elona.potion_of_healer_odina",
   },
   {
      _id = "ex_spellbook_638",
      chip_id = 638,
      item_id = "elona.spellbook_of_weakness",
   },
   {
      _id = "ex_spellbook_637",
      chip_id = 637,
      item_id = "elona.spellbook_of_slow",
   },
   {
      _id = "ex_spellbook_636",
      chip_id = 636,
      item_id = "elona.spellbook_of_wishing",
   },
   {
      _id = "ex_spellbook_634",
      chip_id = 634,
      item_id = "elona.spellbook_of_web",
   },
   {
      _id = "ex_spellbook_633",
      chip_id = 633,
      item_id = "elona.spellbook_of_sound_ball",
   },
   {
      _id = "ex_spellbook_631",
      chip_id = 631,
      item_id = "elona.spellbook_of_fire_ball",
   },
   {
      _id = "ex_spellbook_630",
      chip_id = 630,
      item_id = "elona.spellbook_of_ice_ball",
   },
   {
      _id = "ex_spellbook_629",
      chip_id = 629,
      item_id = "elona.spellbook_of_summon_monsters",
   },
   {
      _id = "ex_spellbook_627",
      chip_id = 627,
      item_id = "elona.spellbook_of_darkness_beam",
   },
   {
      _id = "ex_spellbook_622",
      chip_id = 622,
      item_id = "elona.spellbook_of_chaos_eye",
   },
   {
      _id = "ex_spellbook_621",
      chip_id = 621,
      item_id = "elona.spellbook_of_nerve_eye",
   },
   {
      _id = "ex_spellbook_618",
      chip_id = 618,
      item_id = "elona.spellbook_of_oracle",
   },
   {
      _id = "ex_spellbook_617",
      chip_id = 617,
      item_id = "elona.spellbook_of_minor_teleportation",
   },
   {
      _id = "ex_spellbook_616",
      chip_id = 616,
      item_id = "elona.spellbook_of_teleportation",
   },
   {
      _id = "ex_spellbook_613",
      chip_id = 613,
      item_id = "elona.spellbook_of_hero",
   },
   {
      _id = "ex_spellbook_608",
      chip_id = 608,
      item_id = "elona.spellbook_of_uncurse",
   },
   {
      _id = "ex_spellbook_607",
      chip_id = 607,
      item_id = "elona.spellbook_of_holy_rain",
   },
   {
      _id = "ex_spellbook_601",
      chip_id = 601,
      item_id = "elona.spellbook_of_cure_critical_wound",
   },
   {
      _id = "ex_spellbook_598",
      chip_id = 598,
      item_id = "elona.spellbook_of_4_dimensional_pocket",
   },
   {
      _id = "ex_spellbook_594",
      chip_id = 594,
      item_id = "elona.spellbook_of_silence",
   },
   {
      _id = "ex_potion_550",
      chip_id = 550,
      item_id = "elona.potion_of_restore_body",
   },
   {
      _id = "ex_spellbook_593",
      chip_id = 593,
      item_id = "elona.spellbook_of_detect_objects",
   },
   {
      _id = "ex_spellbook_589",
      chip_id = 589,
      item_id = "elona.ancient_book",
   },
   {
      _id = "ex_scroll_682",
      chip_id = 682,
      item_id = "elona.book_of_resurrection",
   },
   {
      _id = "ex_rod_584",
      chip_id = 584,
      item_id = "elona.rod_of_acid_ground",
   },
   {
      _id = "ex_scroll_679",
      chip_id = 679,
      item_id = "elona.scroll_of_greater_enchant_weapon",
   },
   {
      _id = "ex_scroll_678",
      chip_id = 678,
      item_id = "elona.scroll_of_enchant_weapon",
   },
   {
      _id = "ex_scroll_677",
      chip_id = 677,
      item_id = "elona.scroll_of_superior_material",
   },
   {
      _id = "ex_scroll_673",
      chip_id = 673,
      item_id = "elona.scroll_of_name",
   },
   {
      _id = "ex_scroll_672",
      chip_id = 672,
      item_id = "elona.scroll_of_contingency",
   },
   {
      _id = "ex_scroll_667",
      chip_id = 667,
      item_id = "elona.scroll_of_holy_rain",
   },
   {
      _id = "ex_scroll_665",
      chip_id = 665,
      item_id = "elona.scroll_of_holy_veil",
   },
   {
      _id = "ex_spellbook_605",
      chip_id = 605,
      item_id = "elona.spellbook_of_healing_hands",
   },
   {
      _id = "ex_scroll_663",
      chip_id = 663,
      item_id = "elona.scroll_of_wonder",
   },
   {
      _id = "ex_scroll_660",
      chip_id = 660,
      item_id = "elona.scroll_of_knowledge",
   },
   {
      _id = "ex_scroll_658",
      chip_id = 658,
      item_id = "elona.scroll_of_greater_identify",
   },
   {
      _id = "ex_scroll_651",
      chip_id = 651,
      item_id = "elona.scroll_of_teleportation",
   },
   {
      _id = "ex_scroll_650",
      chip_id = 650,
      item_id = "elona.scroll_of_minor_teleportation",
   },
   {
      _id = "ex_potion_539",
      chip_id = 539,
      item_id = "elona.potion_of_healing",
   },
   {
      _id = "ex_rod_585",
      chip_id = 585,
      item_id = "elona.rod_of_speed",
   },
   {
      _id = "ex_rod_583",
      chip_id = 583,
      item_id = "elona.rod_of_magic_missile",
   },
   {
      _id = "ex_rod_581",
      chip_id = 581,
      item_id = "elona.rod_of_fire_bolt",
   },
   {
      _id = "ex_rod_580",
      chip_id = 580,
      item_id = "elona.rod_of_ice_bolt",
   },
   {
      _id = "ex_rod_579",
      chip_id = 579,
      item_id = "elona.rod_of_silence",
   },
   {
      _id = "ex_rod_575",
      chip_id = 575,
      item_id = "elona.rod_of_holy_light",
   },
   {
      _id = "ex_rod_574",
      chip_id = 574,
      item_id = "elona.rod_of_mana",
   },
   {
      _id = "ex_scroll_664",
      chip_id = 664,
      item_id = "elona.scroll_of_gain_material",
   },
   {
      _id = "ex_rod_564",
      chip_id = 564,
      item_id = "elona.rod_of_domination",
   },
   {
      _id = "ex_rod_566",
      chip_id = 566,
      item_id = "elona.rod_of_alchemy",
   },
   {
      _id = "ex_rod_562",
      chip_id = 562,
      item_id = "elona.rod_of_teleportation",
   },
   {
      _id = "ex_rod_560",
      chip_id = 560,
      item_id = "elona.rod_of_identify",
   },
   {
      _id = "ex_potion_554",
      chip_id = 554,
      item_id = "elona.potion_of_hero",
   },
   {
      _id = "ex_potion_553",
      chip_id = 553,
      item_id = "elona.potion_of_defender",
   },
   {
      _id = "ex_potion_549",
      chip_id = 549,
      item_id = "elona.bottle_of_hermes_blood",
   },
   {
      _id = "ex_potion_543",
      chip_id = 543,
      item_id = "elona.potion_of_silence",
   },
   {
      _id = "ex_potion_542",
      chip_id = 542,
      item_id = "elona.potion_of_paralysis",
   },
   {
      _id = "ex_potion_541",
      chip_id = 541,
      item_id = "elona.potion_of_confusion",
   },
   {
      _id = "ex_scroll_648",
      chip_id = 648,
      item_id = "elona.scroll_of_vanish_curse",
   },
   {
      _id = "ex_potion_546",
      chip_id = 546,
      item_id = "elona.potion_of_slow",
   },
   {
      _id = "ex_spellbook_645",
      chip_id = 645,
      item_id = "elona.spellbook_of_domination",
   },
   {
      _id = "ex_potion_535",
      chip_id = 535,
      item_id = "elona.potion_of_healer",
   },
   {
      _id = "ex_potion_534",
      chip_id = 534,
      item_id = "elona.potion_of_cure_critical_wound",
   },
   {
      _id = "ex_potion_531",
      chip_id = 531,
      item_id = "elona.poison",
   },
   {
      _id = "ex_potion_527",
      chip_id = 527,
      item_id = "elona.potion_of_cure_mutation",
   },
   {
      _id = "ex_potion_523",
      chip_id = 523,
      item_id = "elona.bottle_of_dye",
   },
   {
      _id = "ex_potion_522",
      chip_id = 522,
      item_id = "elona.empty_bottle",
   },
   {
      _id = "ex_potion_521",
      chip_id = 521,
      item_id = "elona.bottle_of_dirty_water",
   },
   {
      _id = "ex_ffhp_693",
      chip_id = 693,
      item_id = "elona.heir_trunk",
   },
   {
      _id = "ex_ffhp_691",
      chip_id = 691,
      item_id = "elona.ration",
   },
   {
      _id = "ex_ffhp_690",
      chip_id = 690,
      item_id = "elona.music_ticket",
   },
   {
      _id = "ex_ffhp_687",
      chip_id = 687,
      item_id = "elona.sisters_love_fueled_lunch",
   },
   {
      _id = "ex_ffhp_587",
      chip_id = 587,
      item_id = "elona.cat_sisters_diary",
   },
   {
      _id = "ex_ffhp_558",
      chip_id = 558,
      item_id = "elona.little_sisters_diary",
   },
   {
      _id = "ex_scroll_656",
      chip_id = 656,
      item_id = "elona.scroll_of_detect_objects",
   },
   {
      _id = "ex_spellbook_599",
      chip_id = 599,
      item_id = "elona.spellbook_of_knowledge",
   },
   {
      _id = "ex_ffhp_559",
      chip_id = 559,
      item_id = "elona.girls_diary",
   },
   {
      _id = "ex_rod_563",
      chip_id = 563,
      item_id = "elona.rod_of_wishing",
   },
   {
      _id = "ex_spellbook_602",
      chip_id = 602,
      item_id = "elona.spellbook_of_cure_eris",
   },
   {
      _id = "ex_rod_561",
      chip_id = 561,
      item_id = "elona.rod_of_magic_mapping",
   },
   {
      _id = "ex_spellbook_642",
      chip_id = 642,
      item_id = "elona.spellbook_of_make_door",
   },
   {
      _id = "ex_spellbook_604",
      chip_id = 604,
      item_id = "elona.spellbook_of_healing_rain",
   },
   {
      _id = "ex_potion_557",
      chip_id = 557,
      item_id = "elona.potion_of_descent",
   },
   {
      _id = "ex_spellbook_628",
      chip_id = 628,
      item_id = "elona.spellbook_of_illusion_beam",
   },
   {
      _id = "ex_rod_568",
      chip_id = 568,
      item_id = "elona.rod_of_make_door",
   },
   {
      _id = "ex_scroll_671",
      chip_id = 671,
      item_id = "elona.scroll_of_incognito",
   },
   {
      _id = "ex_scroll_647",
      chip_id = 647,
      item_id = "elona.scroll_of_oracle",
   },
   {
      _id = "ex_spellbook_644",
      chip_id = 644,
      item_id = "elona.spellbook_of_magic_ball",
   },
   {
      _id = "ex_potion_545",
      chip_id = 545,
      item_id = "elona.potion_of_weaken_resistance",
   },
   {
      _id = "ex_scroll_655",
      chip_id = 655,
      item_id = "elona.scroll_of_magical_map",
   },
   {
      _id = "ex_spellbook_620",
      chip_id = 620,
      item_id = "elona.spellbook_of_nether_eye",
   },
   {
      _id = "ex_potion_530",
      chip_id = 530,
      item_id = "elona.sleeping_drug",
   },
   {
      _id = "ex_potion_538",
      chip_id = 538,
      item_id = "elona.potion_of_healer_jure",
   },
   {
      _id = "ex_spellbook_590",
      chip_id = 590,
      item_id = "elona.spellbook_of_identify",
   },
   {
      _id = "ex_potion_526",
      chip_id = 526,
      item_id = "elona.potion_of_mutation",
   },
   {
      _id = "ex_ffhp_683",
      chip_id = 683,
      item_id = "elona.dead_fish",
   },
   {
      _id = "ex_spellbook_591",
      chip_id = 591,
      item_id = "elona.spellbook_of_return",
   }
}
data:add_multi("ffhp.item_ex_mapping", mappings)
