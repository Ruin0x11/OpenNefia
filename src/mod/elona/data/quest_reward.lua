local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Filters = require("mod.elona.api.Filters")
local I18N = require("api.I18N")

local function mkgenerate(categories)
   return function(self, quest)
      local quality = 2
      if Rand.one_in(2) then
         quality = 3
         if Rand.one_in(12) then
            quality = 4
         end
      end

      local category = Rand.choice(categories)

      return {
         level = math.floor(quest.difficulty + Chara.player():calc("level") / 2 + 1),
         quality = Calc.calc_object_quality(quality),
         categories = {category}
      }
   end
end

data:add {
   _id = "wear",
   _type = "elona_sys.quest_reward",
   elona_id = 1,
   generate = mkgenerate(Filters.fsetwear)
}

data:add {
   _id = "magic",
   _type = "elona_sys.quest_reward",
   elona_id = 2,
   generate = mkgenerate(Filters.fsetmagic)
}

data:add {
   _id = "armor",
   _type = "elona_sys.quest_reward",
   elona_id = 3,
   generate = mkgenerate(Filters.fsetarmor)
}

data:add {
   _id = "weapon",
   _type = "elona_sys.quest_reward",
   elona_id = 4,
   generate = mkgenerate(Filters.fsetweapon)
}

data:add {
   _id = "supply",
   _type = "elona_sys.quest_reward",
   elona_id = 5,
   generate = mkgenerate(Filters.fsetrewardsupply)
}

data:add {
   _id = "by_category",
   _type = "elona_sys.quest_reward",
   params = { category = "string" },
   generate = function(self, quest)
      return mkgenerate({self.category})(self, quest)
   end,

   localize = function(self)
      return I18N.get("item.filter_name." .. self.category)
   end
}
