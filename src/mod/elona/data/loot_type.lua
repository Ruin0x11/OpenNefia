local Filters = require("mod.elona.api.Filters")
local LootDrops = require("mod.elona.api.LootDrops")

local loot = function(chara, drops, chance, category, on_create_cb)
   local map = chara:current_map()
   local filter = LootDrops.make_loot(chance, category, chara, map)
   if filter then
      local drop = { filter = filter }
      if on_create_cb then
         drop.on_create = on_create_cb
      end
      drops[#drops+1] = drop
   end
end

data:add {
   _type = "base.loot_type",
   _id = "animal",
   elona_id = 1,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:244 	case lootAnimal ...
      loot(chara, drops, 40, "elona.remains", LootDrops.make_remains)
      -- <<<<<<<< shade2/item.hsp:246 	swbreak ..
   end,
}

data:add {
   _type = "base.loot_type",
   _id = "insect",
   elona_id = 2,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:248 	case lootInsect ...
      loot(chara, drops, 40, "elona.remains", LootDrops.make_remains)
      -- <<<<<<<< shade2/item.hsp:250 	swbreak ..
   end,
}

data:add {
   _type = "base.loot_type",
   _id = "humanoid",
   elona_id = 3,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:236 	case lootHumanoid ...
      loot(chara, drops, 40, "elona.drink")
      loot(chara, drops, 40, "elona.scroll")
      loot(chara, drops, 40, Filters.fsetwear)
      loot(chara, drops, 40, Filters.fsetweapon)
      loot(chara, drops, 40, "elona.gold")
      -- <<<<<<<< shade2/item.hsp:242 	swbreak ..
   end,
}

data:add {
   _type = "base.loot_type",
   _id = "drake",
   elona_id = 4,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:263 	case lootDrake ...
      loot(chara, drops, 5, Filters.fsetwear)
      loot(chara, drops, 5, Filters.fsetweapon)
      loot(chara, drops, 20, "elona.container")
      loot(chara, drops, 4, "elona.gold")
      -- <<<<<<<< shade2/item.hsp:268 	swbreak ..
   end,
}

data:add {
   _type = "base.loot_type",
   _id = "dragon",
   elona_id = 5,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:270 	case lootDragon ...
      loot(chara, drops, 5, Filters.fsetwear)
      loot(chara, drops, 5, Filters.fsetweapon)
      loot(chara, drops, 15, "elona.spellbook")
      loot(chara, drops, 5, "elona.drink")
      loot(chara, drops, 5, "elona.scroll")
      loot(chara, drops, 10, "elona.container")
      loot(chara, drops, 4, "elona.gold")
      loot(chara, drops, 4, "elona.ore")
      -- <<<<<<<< shade2/item.hsp:279 	swbreak ..
   end
}

data:add {
   _type = "base.loot_type",
   _id = "lich",
   elona_id = 6,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:252 	case lootLich ...
      loot(chara, drops, 10, "elona.equip_ring")
      loot(chara, drops, 10, "elona.equip_neck")
      loot(chara, drops, 20, "elona.spellbook")
      loot(chara, drops, 10, "elona.drink")
      loot(chara, drops, 10, "elona.scroll")
      loot(chara, drops, 20, "elona.container")
      loot(chara, drops, 10, "elona.gold")
      loot(chara, drops, 10, "elona.ore")
      -- <<<<<<<< shade2/item.hsp:261 	swbreak ..
   end,
}
