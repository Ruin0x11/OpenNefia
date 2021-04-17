local Enum = require("api.Enum")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

data:add_type {
   name = "predicate"
}

data:add {
   _type = "autopickup.predicate",
   _id = "all",

   match = function(item)
      return true
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "unknown",

   match = function(item)
      return item:calc("identify_state") == Enum.IdentifyState.None
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "identify_stage_1",

   match = function(item)
      return item:calc("identify_state") == Enum.IdentifyState.Name
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "identify_stage_2",

   match = function(item)
      return item:calc("identify_state") == Enum.IdentifyState.Quality
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "identify_stage_3",

   match = function(item)
      return item:calc("identify_state") == Enum.IdentifyState.Full
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "worthless",

   match = function(item)
      return item:calc("value") <= 10
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "rotten",

   match = function(item)
      local food = item:get_aspect(IItemFood)
      return food and food:is_rotten(item)
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "zombie",

   match = function(item)
      local chara_id = item.params.chara_id
      if chara_id == nil then
         return
      end
      local chara = data["base.chara"][chara_id]
      if chara == nil then
         return
      end

      return table.index_of(chara.tags, "undead")
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "dragon",

   match = function(item)
      local chara_id = item.params.chara_id
      if chara_id == nil then
         return
      end
      local chara = data["base.chara"][chara_id]
      if chara == nil then
         return
      end

      return table.index_of(chara.tags, "dragon")
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "empty",

   match = function(item)
      return item:has_category("elona.container")
         and item.params.chest_item_level
         and item.params.chest_item_level == 0
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "bad",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.Bad
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "good",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.Normal
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "great",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.Good
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "miracle",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.Great
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "godly",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.God
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "special",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("quality") == Enum.Quality.Unique
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "precious",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("is_precious")
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "blessed",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("curse_state") == Enum.CurseState.Blessed
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "cursed",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("curse_state") == Enum.CurseState.Cursed
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "doomed",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("curse_state") == Enum.CurseState.Doomed
   end
}

data:add {
   _type = "autopickup.predicate",
   _id = "alive",

   match = function(item)
      return item:calc("identify_state") >= Enum.IdentifyState.Quality
         and item:calc("is_living")
   end
}
