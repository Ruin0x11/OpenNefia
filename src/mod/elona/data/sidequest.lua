local function order(elona_id)
   return 100000 + elona_id * 10000
end

data:add {
   _type = "elona_sys.sidequest",
   _id = "tutorial",
   elona_id = 0,
   ordering = order(0),

   progress = {
      [1] = "",
      [2] = "",
      [3] = "",
      [4] = "",
      [5] = "",
      [6] = "",
      [7] = "",
      [8] = "",
      [99] = "",
      [-1] = "",
   }
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "main_quest",
   elona_id = 2,
   ordering = order(2),

   is_main_quest = true,

   -- >>>>>>>> shade2/text.hsp:1005 	if (flagMain>=0 )&(flagMain<30)	 : s1=lang("ヴェルニー ...
   progress = {
      [0] = "quest.journal.main.progress._0",
      [30] = "quest.journal.main.progress._1",
      [50] = "quest.journal.main.progress._2",
      [60] = "quest.journal.main.progress._3",
      [100] = "quest.journal.main.progress._4",
      [110] = "quest.journal.main.progress._5",
      [125] = "quest.journal.main.progress._6",
      [180] = "quest.journal.main.progress._7",
   }
   -- <<<<<<<< shade2/text.hsp:1012 	if (flagMain>=180)&(flagMain<1000): s1=lang("第一部メ ..
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "putit_attacks",
   elona_id = 200,
   ordering = order(200),

   progress = {
      [1] = "sidequest._.elona.putit_attacks.progress._0",
      [2] = "sidequest._.elona.putit_attacks.progress._1",
      [1000] = "",
   },
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "nightmare",
   elona_id = 202,
   ordering = order(202),

   progress = {
      [1] = "sidequest._.elona.nightmare.progress._0",
      [2] = "sidequest._.elona.nightmare.progress._1",
      [1000] = "",
   },
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "puppys_cave",
   elona_id = 205,
   ordering = order(205),

   progress = {
      [1] = "sidequest._.elona.puppys_cave.progress._0",
      [2] = "sidequest._.elona.puppys_cave.progress._1",
      [1000] = "",
   },
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "mias_dream",
   elona_id = 206,
   ordering = order(206),

   progress = {
      [1] = "sidequest._.elona.mias_dream.progress._0",
      [1000] = "",
   },
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "novice_knight",
   elona_id = 208,
   ordering = order(208),

   progress = {
      [1] = "sidequest._.elona.novice_knight.progress._0",
      [2] = "sidequest._.elona.novice_knight.progress._1",
      [1000] = "",
   },
}

data:add {
   _type = "elona_sys.sidequest",
   _id = "sewer_sweeping",
   elona_id = 215,
   ordering = order(215),

   progress = {
      [1] = "sidequest._.elona.sewer_sweeping.progress._0",
      [2] = "sidequest._.elona.sewer_sweeping.progress._1",
      [1000] = "",
   },
}
