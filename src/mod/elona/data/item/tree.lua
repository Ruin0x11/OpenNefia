local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Item = require("api.Item")
local light = require("mod.elona.data.item.light")
local Enum = require("api.Enum")

--
-- Tree
--

data:add {
   _type = "base.item",
   _id = "tree_of_beech",
   elona_id = 523,
   image = "elona.item_tree_of_beech",
   value = 700,
   weight = 45000,
   category = 80000,
   rarity = 3000000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_cedar",
   elona_id = 524,
   image = "elona.item_tree_of_cedar",
   value = 500,
   weight = 38000,
   category = 80000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_fruitless",
   elona_id = 525,
   image = "elona.item_tree_of_fruitless",
   value = 500,
   weight = 35000,
   fltselect = Enum.FltSelect.Sp,
   category = 80000,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree",
      "elona.no_generate"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_fruits",
   elona_id = 526,
   image = "elona.item_tree_of_fruits",
   value = 2000,
   weight = 42000,
   category = 80000,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "tree",

   params = {
      fruit_tree_amount = 0,
      fruit_tree_item_id = "elona.apple"
   },
   on_init_params = function(self)
      local FRUITS = {
         "elona.apple",
         "elona.grape",
         "elona.orange",
         "elona.lemon",
         "elona.strawberry",
         "elona.cherry"
      }
      self.params.fruit_tree_amount = Rand.rnd(2) + 3
      self.params.fruit_tree_item_id = Rand.choice(FRUITS)
   end,

   events = {
      {
         id = "elona_sys.on_item_bash",
         name = "Fruit tree bash behavior",

         callback = function(self)
            self = self:separate()
            Gui.play_sound("base.bash1")
            Gui.mes("action.bash.tree.execute", self:build_name(1))
            local fruits = self.params.fruit_tree_amount
            if self:calc("own_state") == "unobtainable" or fruits <= 0 then
               Gui.mes("action.bash.tree.no_fruits")
               return "turn_end"
            end
            self.params.fruit_tree_amount = fruits - 1
            if self.params.fruit_tree_amount <= 0 then
               self.image = "elona.item_tree_of_fruitless"
            end

            local x = self.x
            local y = self.y
            local map = self:current_map()
            if y + 1 < map:height() and map:can_access(x, y + 1) then
               y = y + 1
            end
            local item = Item.create(self.params.fruit_tree_item_id, x, y, {}, map)
            Gui.mes("action.bash.tree.falls_down", item:build_name(1))

            return "turn_end"
         end
      },
      {
         id = "base.on_item_renew_major",
         name = "Fruit tree restock",

         callback = function(self)
            if self.params.fruit_tree_amount < 10 then
               self.params.fruit_tree_amount = self.params.fruit_tree_amount + 1
               self.image = "elona.item_tree_of_fruits"
            end
         end
      }
   },

   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "dead_tree",
   elona_id = 527,
   image = "elona.item_dead_tree",
   value = 500,
   weight = 20000,
   category = 80000,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_zelkova",
   elona_id = 528,
   image = "elona.item_tree_of_zelkova",
   value = 800,
   weight = 28000,
   category = 80000,
   rarity = 1500000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_palm",
   elona_id = 529,
   image = "elona.item_tree_of_palm",
   value = 1000,
   weight = 39000,
   category = 80000,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_ash",
   elona_id = 530,
   image = "elona.item_tree_of_ash",
   value = 900,
   weight = 28000,
   category = 80000,
   rarity = 500000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree"
   }
}

--
-- Snow Tree
--

data:add {
   _type = "base.item",
   _id = "tree_of_naked",
   elona_id = 588,
   image = "elona.item_tree_of_naked",
   value = 500,
   weight = 14000,
   fltselect = Enum.FltSelect.Snow,
   category = 80000,
   rarity = 250000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree",
      "elona.snow_tree"
   }
}

data:add {
   _type = "base.item",
   _id = "tree_of_fir",
   elona_id = 589,
   image = "elona.item_tree_of_fir",
   value = 1800,
   weight = 28000,
   fltselect = Enum.FltSelect.Snow,
   category = 80000,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "tree",
   categories = {
      "elona.tree",
      "elona.snow_tree"
   }
}

data:add {
   _type = "base.item",
   _id = "christmas_tree",
   elona_id = 599,
   image = "elona.item_christmas_tree",
   value = 4800,
   weight = 35000,
   level = 30,
   fltselect = Enum.FltSelect.Snow,
   category = 80000,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.tree",
      "elona.snow_tree"
   },
   light = light.crystal_high
}
