local LootDrops = require("mod.elona.api.LootDrops")

local function loot(chara, drops, chance, category)
   local map = chara:current_map()
   local filter = LootDrops.make_loot(chance, category, chara, map)
   if filter then
      drops[#drops+1] = { filter = filter }
   end
end

data:add {
   _type = "base.equipment_type",
   _id = "warrior",
   elona_id = 1,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:208 	case eqWarrior ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:210 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "mage",
   elona_id = 2,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:220 	case eqMage ...
      loot(chara, drops, 20, "elona.scroll")
      loot(chara, drops, 40, "elona.spellbook")
      -- <<<<<<<< shade2/item.hsp:223 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "archer",
   elona_id = 3,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:216 	case eqArcher ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:218 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "gunner",
   elona_id = 4,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:225 	case eqGunner ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:227 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "war_mage",
   elona_id = 5,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:229 	case eqWarMage ...
      loot(chara, drops, 50, "elona.spellbook")
      -- <<<<<<<< shade2/item.hsp:231 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "priest",
   elona_id = 6,

   on_drop_loot = function(chara, _, drops)
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "thief",
   elona_id = 7,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:212 	case eqThief ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:214 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "claymore",
   elona_id = 8,

   on_drop_loot = function(chara, _, drops)
   end
}
