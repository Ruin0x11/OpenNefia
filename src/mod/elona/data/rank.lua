data:add_type {
   name = "rank",
   fields = {}
}

local function order(elona_id)
   return 100000 + elona_id * 10000
end

data:add {
   _type = "elona.rank",
   _id = "arena",
   elona_id = 0,

   ordering = order(0),

   -- >>>>>>>> shade2/init.hsp:1924 	rankNorma(rankArena) 	=20 ...
   decay_period_days = 20,
   -- <<<<<<<< shade2/init.hsp:1924 	rankNorma(rankArena) 	=20 ..

   provides_salary_items = true,

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:414 	if r=rankArena		:p=p*80/100 ...
      return income * 80 / 100
      -- <<<<<<<< shade2/event.hsp:414 	if r=rankArena		:p=p*80/100 ..
   end
}

data:add {
   _type = "elona.rank",
   _id = "pet_arena",
   elona_id = 1,

   ordering = order(1),

   -- >>>>>>>> shade2/init.hsp:1925 	rankNorma(rankPetArena)	=60 ...
   decay_period_days = 60,
   -- <<<<<<<< shade2/init.hsp:1925 	rankNorma(rankPetArena)	=60 ..

   provides_salary_items = true,

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:415 	if r=rankPetArena	:p=p*70/100 ...
      return income * 70 / 100
      -- <<<<<<<< shade2/event.hsp:415 	if r=rankPetArena	:p=p*70/100 ..
   end
}

data:add {
   _type = "elona.rank",
   _id = "crawler",
   elona_id = 2,

   ordering = order(2),

   -- >>>>>>>> shade2/init.hsp:1926 	rankNorma(rankCrawler)	=45 ...
   decay_period_days = 45,
   -- <<<<<<<< shade2/init.hsp:1926 	rankNorma(rankCrawler)	=45 ..

   provides_salary_items = true,

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:412 	if r=rankCrawler	:p=p*120/100 ...
      return income * 120 / 100
      -- <<<<<<<< shade2/event.hsp:412 	if r=rankCrawler	:p=p*120/100 ..
   end
}

data:add {
   _type = "elona.rank",
   _id = "museum",
   elona_id = 3,

   ordering = order(3),

   -- >>>>>>>> shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ...
   provides_salary_items = false,
   -- <<<<<<<< shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ..
}

data:add {
   _type = "elona.rank",
   _id = "home",
   elona_id = 4,

   ordering = order(4),

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:413 	if r=rankHome		:p=p*60/100 ...
      return income * 60 / 100
      -- <<<<<<<< shade2/event.hsp:413 	if r=rankHome		:p=p*60/100 ..
   end,

   provides_salary_items = true,
}

data:add {
   _type = "elona.rank",
   _id = "shop",
   elona_id = 5,

   ordering = order(5),

   -- >>>>>>>> shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ...
   provides_salary_items = false,
   -- <<<<<<<< shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ..

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:417 	if r=rankShop		:p=p*20/100 ...
      return income * 20 / 100
      -- <<<<<<<< shade2/event.hsp:417 	if r=rankShop		:p=p*20/100 ..
   end
}

data:add {
   _type = "elona.rank",
   _id = "vote",
   elona_id = 6,

   ordering = order(6),

   -- >>>>>>>> shade2/init.hsp:1927 	rankNorma(rankVote)	=30 ...
   decay_period_days = 30,
   -- <<<<<<<< shade2/init.hsp:1927 	rankNorma(rankVote)	=30 ..

   -- >>>>>>>> shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ...
   provides_salary_items = false,
   -- <<<<<<<< shade2/event.hsp:447 	if (cnt=rankShop)or(cnt=rankVote)or(cnt=rankMuseu ..

   calc_income = function(income)
      -- >>>>>>>> shade2/event.hsp:416 	if r=rankVote		:p=p*25/100 ...
      return income * 25 / 100
      -- <<<<<<<< shade2/event.hsp:416 	if r=rankVote		:p=p*25/100 ..
   end
}

data:add {
   _type = "elona.rank",
   _id = "fishing",
   elona_id = 7,

   provides_salary_items = true,

   ordering = order(7),
}

data:add {
   _type = "elona.rank",
   _id = "guild",
   elona_id = 8,

   provides_salary_items = true,

   ordering = order(8),
}
