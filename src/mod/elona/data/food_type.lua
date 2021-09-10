data:add_type {
   name = "food_type",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "uses_chara_name",
         type = types.boolean,
         default = false
      },
      {
         name = "exp_gains",
         type = types.list(types.fields { _id = types.data_id("base.skill"), amount = types.number }),
         default = {}
      },
      {
         name = "base_nutrition",
         type = types.number,
      },
      {
         name = "item_chips",
         type = types.map(types.uint, types.data_id("base.chip")),
         default = {}
      },
      {
         name = "quest_reward_category",
         type = types.optional(types.data_id("elona_sys.quest_reward")),
      },
   }
}

data:add {
   _type = "elona.food_type",
   _id = "meat",
   elona_id = 1,

   -- >>>>>>>> shade2/text.hsp:535 		if sub=0 : n=lang("動物","beast") : else: n=cnOrgN ...
   uses_chara_name = true,
   -- <<<<<<<< shade2/text.hsp:535 		if sub=0 : n=lang("動物","beast") : else: n=cnOrgN ..

   -- >>>>>>>> shade2/item.hsp:844 	if i=headFdMeat{ ...
   exp_gains = {
      { _id = "elona.stat_strength", amount = 30 },
      { _id = "elona.stat_constitution", amount = 40 },
      { _id = "elona.stat_charisma", amount = 10 },
   },

   base_nutrition = 3500,
   -- <<<<<<<< shade2/item.hsp:849 		} ..

   -- >>>>>>>> shade2/text.hsp:648 	picFood(0,headFdMeat) =230,230,230,195,227,167,16 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_3",
      [4] = "elona.item_dish_meat_4",
      [5] = "elona.item_dish_meat_5",
      [6] = "elona.item_dish_meat_5",
      [7] = "elona.item_dish_meat_7",
      [8] = "elona.item_dish_meat_8",
      [9] = "elona.item_dish_meat_4"
   },
   -- <<<<<<<< shade2/text.hsp:648 	picFood(0,headFdMeat) =230,230,230,195,227,167,16 ..

   -- >>>>>>>> shade2/quest.hsp:273 		if qParam1(rq)=headFdMeat	:qRewardItem(rq)=fltAm ...
   quest_reward_category = "elona.equip_ammo"
   -- <<<<<<<< shade2/quest.hsp:273 		if qParam1(rq)=headFdMeat	:qRewardItem(rq)=fltAm ..
}

data:add {
   _type = "elona.food_type",
   _id = "vegetable",
   elona_id = 2,

   -- >>>>>>>> shade2/item.hsp:857 	if i=headFdVege{ ...
   exp_gains = {
      { _id = "elona.stat_will", amount = 50 },
      { _id = "elona.stat_learning", amount = 50 },
   },

   base_nutrition = 2000,
   -- <<<<<<<< shade2/item.hsp:861 		} ..

   -- >>>>>>>> shade2/text.hsp:649 	picFood(0,headFdVege) =230,230,230,229,342,194,22 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_8",
      [4] = "elona.item_dish_vegetable_4",
      [5] = "elona.item_dish_meat_7",
      [6] = "elona.item_dish_meat_8",
      [7] = "elona.item_dish_vegetable_4",
      [8] = "elona.item_dish_meat_8",
      [9] = "elona.item_dish_meat_7"
   },
   -- <<<<<<<< shade2/text.hsp:649 	picFood(0,headFdVege) =230,230,230,229,342,194,22 ..

   -- >>>>>>>> shade2/quest.hsp:276 		if qParam1(rq)=headFdVege	:qRewardItem(rq)=fltSt ...
   quest_reward_category = "elona.rod"
   -- <<<<<<<< shade2/quest.hsp:276 		if qParam1(rq)=headFdVege	:qRewardItem(rq)=fltSt ..
}

data:add {
   _type = "elona.food_type",
   _id = "fruit",
   elona_id = 3,

   -- >>>>>>>> shade2/item.hsp:863 	if i=headFdFruit{ ...
   exp_gains = {
      { _id = "elona.stat_will", amount = 50 },
      { _id = "elona.stat_learning", amount = 50 },
   },

   base_nutrition = 1500,
   -- <<<<<<<< shade2/item.hsp:868 		} ..

   -- >>>>>>>> shade2/text.hsp:650 	picFood(0,headFdFruit)=230,230,230,229,346,346,34 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_8",
      [4] = "elona.item_dish_fruit_4",
      [5] = "elona.item_dish_fruit_4",
      [6] = "elona.item_dish_fruit_6",
      [7] = "elona.item_dish_fruit_6",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_fruit_4"
   },
   -- <<<<<<<< shade2/text.hsp:650 	picFood(0,headFdFruit)=230,230,230,229,346,346,34 ..

   -- >>>>>>>> shade2/quest.hsp:277 		if qParam1(rq)=headFdFruit	:qRewardItem(rq)=fltS ...
   quest_reward_category = "elona.scroll"
   -- <<<<<<<< shade2/quest.hsp:277 		if qParam1(rq)=headFdFruit	:qRewardItem(rq)=fltS ..
}

data:add {
   _type = "elona.food_type",
   _id = "sweet",
   elona_id = 4,

   -- >>>>>>>> shade2/item.hsp:878 	if i=headFdSweet{ ...
   exp_gains = {
      { _id = "elona.stat_magic", amount = 40 },
      { _id = "elona.stat_dexterity", amount = 30 },
      { _id = "elona.stat_learning", amount = 30 },
   },

   base_nutrition = 1500,
   -- <<<<<<<< shade2/item.hsp:883 		} ..

   -- >>>>>>>> shade2/text.hsp:651 	picFood(0,headFdSweet)=230,230,230,108,346,110,34 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_sweet_3",
      [4] = "elona.item_dish_fruit_4",
      [5] = "elona.item_dish_sweet_5",
      [6] = "elona.item_dish_fruit_4",
      [7] = "elona.item_dish_egg_8",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_egg_8"
   },
   -- <<<<<<<< shade2/text.hsp:651 	picFood(0,headFdSweet)=230,230,230,108,346,110,34 ..

   -- >>>>>>>> shade2/quest.hsp:271 		if qParam1(rq)=headFdSweet	:qRewardItem(rq)=fltP ...
   quest_reward_category = "elona.drink"
   -- <<<<<<<< shade2/quest.hsp:271 		if qParam1(rq)=headFdSweet	:qRewardItem(rq)=fltP ..
}

data:add {
   _type = "elona.food_type",
   _id = "pasta",
   elona_id = 5,

   -- >>>>>>>> shade2/item.hsp:892 	if i=headFdPasta{ ...
   exp_gains = {
      { _id = "elona.stat_constitution", amount = 60 },
      { _id = "elona.stat_dexterity", amount = 40 },
   },

   base_nutrition = 3500,
   -- <<<<<<<< shade2/item.hsp:896 		} ..

   -- >>>>>>>> shade2/text.hsp:652 	picFood(0,headFdPasta)=230,230,229,343,344,344,34 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_meat_8",
      [3] = "elona.item_dish_pasta_3",
      [4] = "elona.item_dish_pasta_4",
      [5] = "elona.item_dish_pasta_4",
      [6] = "elona.item_dish_pasta_3",
      [7] = "elona.item_dish_pasta_3",
      [8] = "elona.item_dish_pasta_4",
      [9] = "elona.item_dish_pasta_3"
   },
   -- <<<<<<<< shade2/text.hsp:652 	picFood(0,headFdPasta)=230,230,229,343,344,344,34 ..

   -- >>>>>>>> shade2/quest.hsp:274 		if qParam1(rq)=headFdPasta	:qRewardItem(rq)=fltP ...
   quest_reward_category = "elona.drink"
   -- <<<<<<<< shade2/quest.hsp:274 		if qParam1(rq)=headFdPasta	:qRewardItem(rq)=fltP ..
}

data:add {
   _type = "elona.food_type",
   _id = "fish",
   elona_id = 6,

   -- >>>>>>>> shade2/item.hsp:885 	if i=headFdFish{ ...
   exp_gains = {
      { _id = "elona.stat_learning", amount = 40 },
      { _id = "elona.stat_dexterity", amount = 40 },
      { _id = "elona.stat_perception", amount = 20 },
   },

   base_nutrition = 3000,
   -- <<<<<<<< shade2/item.hsp:890 		} ..

   -- >>>>>>>> shade2/text.hsp:653 	picFood(0,headFdFish) =230,230,230,228,342,342,22 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_fish_3",
      [4] = "elona.item_dish_vegetable_4",
      [5] = "elona.item_dish_vegetable_4",
      [6] = "elona.item_dish_fish_3",
      [7] = "elona.item_dish_fish_7",
      [8] = "elona.item_dish_fish_3",
      [9] = "elona.item_dish_fish_3"
   },
   -- <<<<<<<< shade2/text.hsp:653 	picFood(0,headFdFish) =230,230,230,228,342,342,22 ..

   -- >>>>>>>> shade2/quest.hsp:272 		if qParam1(rq)=headFdFish	:qRewardItem(rq)=fltAm ...
   quest_reward_category = "elona.equip_ammo"
   -- <<<<<<<< shade2/quest.hsp:272 		if qParam1(rq)=headFdFish	:qRewardItem(rq)=fltAm ..
}

data:add {
   _type = "elona.food_type",
   _id = "bread",
   elona_id = 7,

   -- >>>>>>>> shade2/item.hsp:870 	if i=headFdBread{ ...
   exp_gains = {
      { _id = "elona.stat_strength", amount = 25 },
      { _id = "elona.stat_dexterity", amount = 25 },
      { _id = "elona.stat_learning", amount = 25 },
      { _id = "elona.stat_constitution", amount = 25 },
   },

   base_nutrition = 2800,
   -- <<<<<<<< shade2/item.hsp:876 		} ..

   -- >>>>>>>> shade2/text.hsp:654 	picFood(0,headFdBread)=230,230,110,108,110,112,11 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_sweet_5",
      [3] = "elona.item_dish_sweet_3",
      [4] = "elona.item_dish_sweet_5",
      [5] = "elona.item_dish_bread_5",
      [6] = "elona.item_dish_bread_6",
      [7] = "elona.item_dish_bread_7",
      [8] = "elona.item_dish_bread_8",
      [9] = "elona.item_dish_bread_9"
   },
   -- <<<<<<<< shade2/text.hsp:654 	picFood(0,headFdBread)=230,230,110,108,110,112,11 ..

   -- >>>>>>>> shade2/quest.hsp:275 		if qParam1(rq)=headFdBread	:qRewardItem(rq)=fltO ...
   quest_reward_category = "elona.ore"
   -- <<<<<<<< shade2/quest.hsp:275 		if qParam1(rq)=headFdBread	:qRewardItem(rq)=fltO ..
}

data:add {
   _type = "elona.food_type",
   _id = "egg",
   elona_id = 8,

   -- >>>>>>>> shade2/text.hsp:629 		if sub=0 : n=lang("鳥","animal") : else: n=cnOrgN ...
   uses_chara_name = true,
   -- <<<<<<<< shade2/text.hsp:629 		if sub=0 : n=lang("鳥","animal") : else: n=cnOrgN ...

   -- >>>>>>>> shade2/item.hsp:850 	if i=headFdEgg{ ...
   exp_gains = {
      { _id = "elona.stat_charisma", amount = 20 },
      { _id = "elona.stat_perception", amount = 20 },
      { _id = "elona.stat_will", amount = 20 },
   },

   base_nutrition = 2000,
   -- <<<<<<<< shade2/item.hsp:855 		} ..

   -- >>>>>>>> shade2/text.hsp:647 	picFood(0,headFdEgg)  =230,230,230,190,229,190,34 ...
   item_chips = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_egg_3",
      [4] = "elona.item_dish_meat_8",
      [5] = "elona.item_dish_egg_3",
      [6] = "elona.item_dish_vegetable_4",
      [7] = "elona.item_hero_cheese",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_meat_7"
   },
   -- <<<<<<<< shade2/text.hsp:647 	picFood(0,headFdEgg)  =230,230,230,190,229,190,34 ..

   quest_reward_category = nil
}
