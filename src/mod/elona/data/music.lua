data:add {
   _type = "base.data_ext",
   _id = "music_disc",

   fields = {
      {
         name = "can_randomly_generate",
         type = types.boolean,
         default = true
      },
      {
         name = "music_number",
         type = types.optional(types.uint),
         default = nil
      }
   }
}

data:add_multi(
   "base.music",
   {
      {
         _id = "reset",
         file = "mod/elona/sound/gm_on.mid",
         elona_id = 50,

         _ext = {
            ["elona.music_disc"] = {
               can_randomly_generate = false
            }
         }
      },
      {
         _id = "town1",
         file = "mod/elona/sound/pop01.mid",
         elona_id = 51,
      },
      {
         _id = "town2",
         file = "mod/elona/sound/morning_breeze.mid",
         elona_id = 52,
      },
      {
         _id = "town3",
         file = "mod/elona/sound/happymarch.mid",
         elona_id = 53,
      },
      {
         _id = "town4",
         file = "mod/elona/sound/xp_field7.mid",
         elona_id = 54,
      },
      {
         _id = "dungeon1",
         file = "mod/elona/sound/pop03.mid",
         elona_id = 55,
      },
      {
         _id = "dungeon2",
         file = "mod/elona/sound/PSML522.MID",
         elona_id = 56,
      },
      {
         _id = "dungeon3",
         file = "mod/elona/sound/PSML514.MID",
         elona_id = 57,
      },
      {
         _id = "dungeon4",
         file = "mod/elona/sound/PSML507.MID",
         elona_id = 58,
      },
      {
         _id = "dungeon5",
         file = "mod/elona/sound/fantasy04.mid",
         elona_id = 59,
      },
      {
         _id = "dungeon6",
         file = "mod/elona/sound/fantasy03.mid",
         elona_id = 60,
      },
      {
         _id = "puti",
         file = "mod/elona/sound/dwarf.mid",
         elona_id = 61,
      },
      {
         _id = "boss",
         file = "mod/elona/sound/battle1.mid",
         elona_id = 62,
      },
      {
         _id = "boss2",
         file = "mod/elona/sound/climax.mid",
         elona_id = 63,
      },
      {
         _id = "victory",
         file = "mod/elona/sound/orc05.mid",
         elona_id = 64,
      },
      {
         _id = "opening",
         file = "mod/elona/sound/orc01.mid",
         elona_id = 65,
      },
      {
         _id = "last_boss",
         file = "mod/elona/sound/orc03.mid",
         elona_id = 66,
      },
      {
         _id = "home",
         file = "mod/elona/sound/PSML516.MID",
         elona_id = 67,
      },
      {
         _id = "lonely",
         file = "mod/elona/sound/PSML060.MID",
         elona_id = 68,
      },
      {
         _id = "chaos",
         file = "mod/elona/sound/fantasy01.mid",
         elona_id = 69,
      },
      {
         _id = "march1",
         file = "mod/elona/sound/orc06.mid",
         elona_id = 70,
      },
      {
         _id = "march2",
         file = "mod/elona/sound/orc02.mid",
         elona_id = 71,
      },
      {
         _id = "march3",
         file = "mod/elona/sound/orc04.mid",
         elona_id = 72,
      },
      {
         _id = "arena",
         file = "mod/elona/sound/victory.mid",
         elona_id = 73,
      },
      {
         _id = "fanfare",
         file = "mod/elona/sound/fanfare.mid",
         elona_id = 74,
      },
      {
         _id = "village1",
         file = "mod/elona/sound/cobalt.mid",
         elona_id = 75,
      },
      {
         _id = "battle1",
         file = "mod/elona/sound/battle3.mid",
         elona_id = 76,
      },
      {
         _id = "casino",
         file = "mod/elona/sound/town2l.mid",
         elona_id = 77,
      },
      {
         _id = "coda",
         file = "mod/elona/sound/epi1coda.mid",
         elona_id = 78,
      },
      {
         _id = "ruin",
         file = "mod/elona/sound/ruins1.mid",
         elona_id = 79,
      },
      {
         _id = "wedding",
         file = "mod/elona/sound/PSML052.MID",
         elona_id = 80,
      },
      {
         _id = "pet_arena",
         file = "mod/elona/sound/main2.mid",
         elona_id = 81,
      },
      {
         _id = "unrest",
         file = "mod/elona/sound/PSML514.MID",
         elona_id = 82,
      },
      {
         _id = "town5",
         file = "mod/elona/sound/PSML047.MID",
         elona_id = 83,
      },
      {
         _id = "unrest2",
         file = "mod/elona/sound/xp_shrine2.mid",
         elona_id = 84,
      },
      {
         _id = "town6",
         file = "mod/elona/sound/morning_breeze.mid",
         elona_id = 85,
      },
      {
         _id = "field1",
         file = "mod/elona/sound/orc04.mid",
         elona_id = 86,
      },
      {
         _id = "field2",
         file = "mod/elona/sound/xp_field2.mid",
         elona_id = 87,
      },
      {
         _id = "field3",
         file = "mod/elona/sound/xp_field4.mid",
         elona_id = 88,
      },
      {
         _id = "memory",
         file = "mod/elona/sound/memory.mid",
         elona_id = 89,
      },
      {
         _id = "intro",
         file = "mod/elona/sound/field1_d.mid",
         elona_id = 90,
      },

      ---  These songs are only played during cutscenes.

      {
         _id = "soraochi",
         file = "mod/elona/sound/soraochi.mid",
         elona_id = 91,
      },
      {
         _id = "psml515",
         file = "mod/elona/sound/PSML515.MID",
         elona_id = 92,
      },
      {
         _id = "psml035",
         file = "mod/elona/sound/PSML035.MID",
         elona_id = 93,
      },
      {
         _id = "pinch2",
         file = "mod/elona/sound/pinch2.mid",
         elona_id = 94,
      },
      {
         _id = "memory2",
         file = "mod/elona/sound/memory2.mid",
         elona_id = 95,
      },
      {
         _id = "ano_sora",
         file = "mod/elona/sound/AnoSora.mid",
         elona_id = 96,
      },
      {
         _id = "epilogue",
         file = "mod/elona/sound/xp_epilogue1.mid",
         elona_id = 97,
      },
})
