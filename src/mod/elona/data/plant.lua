local Gui = require("api.Gui")
local Itemgen = require("mod.elona.api.Itemgen")
local Rand = require("api.Rand")
local Filters = require("mod.elona.api.Filters")
local Save = require("api.Save")
local Enum = require("api.Enum")

data:add_type {
   name = "plant"
}

local function generate_item(cb)
   if type(cb) == "table" then
      local filter = cb
      cb = function() return table.deepcopy(filter) end
   end
   return function(plant, params)
      local filter = cb(plant, params)

      filter.level = filter.level or params.chara:skill_level("elona.gardening") / 2 + 15
      filter.quality = filter.quality or Enum.Quality.Normal
      filter.no_stack = true

      local item = Itemgen.create(plant.x, plant.y, filter, params.chara)
      Gui.mes("action.plant.harvest", item:build_name())
      item:stack(true)
   end
end

data:add {
   _type = "elona.plant",
   _id = "vegetable",
   growth_difficulty = 10,
   regrowth_difficulty = 15,
   on_harvest = generate_item { categories = "elona.food_vegetable" }
}

data:add {
   _type = "elona.plant",
   _id = "fruit",
   growth_difficulty = 10,
   regrowth_difficulty = 15,
   on_harvest = generate_item { categories = "elona.food_fruit" }
}

data:add {
   _type = "elona.plant",
   _id = "herb",
   growth_difficulty = 30,
   regrowth_difficulty = 40,
   on_harvest = generate_item { categories = "elona.crop_herb" }
}

data:add {
   _type = "elona.plant",
   _id = "gem",
   growth_difficulty = 15,
   regrowth_difficulty = 25,
   on_harvest = generate_item { categories = "elona.ore_valuable" }
}

data:add {
   _type = "elona.plant",
   _id = "magical_plant",
   growth_difficulty = 25,
   regrowth_difficulty = 30,
   on_harvest = generate_item { categories = "elona.rod" }
}

local function generate_artifact()
   return {
      categories = Rand.choice(Filters.fsetplantartifact),
      quality = Enum.Quality.Great
   }
end

data:add {
   _type = "elona.plant",
   _id = "unknown_plant",
   growth_difficulty = 25,
   regrowth_difficulty = 35,
   on_harvest = generate_item(function(plant, params)
         local filter = {
            categories = Rand.choice(Filters.fsetplantunknown)
         }
         if Rand.one_in(100) then
            filter = {
               id = "elona.potion_of_cure_corruption"
            }
         end
         if Rand.one_in(50) then
            filter = generate_artifact()
            Save.queue_autosave()
         end
         return filter
   end)
}

data:add {
   _type = "elona.plant",
   _id = "artifact",
   growth_difficulty = 40,
   regrowth_difficulty = math.huge,
   on_harvest = generate_item(function(plant, params)
         local filter = {}
         if Rand.one_in(50) then
            filter = generate_artifact()
            Save.queue_autosave()
         end
         return filter
   end)
}
