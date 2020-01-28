local Log = require("api.Log")

local center = data["base.map_entrance"]:ensure("base.center").pos

local function stair_up(map, chara, prev)
   local search = function(f) return f._id == "elona.stairs_up" end

   local feat = map:iter_feats():filter(search):nth(1)
   if not feat then
      Log.warn("No stairs up on were found in map.")
      return center(map, chara, prev)
   end

   return feat.x, feat.y
end

data:add(
   {
      _id = "stair_up",
      _type = "base.map_entrance",

      pos = stair_up
   }
)

local function stair_down(map, chara, prev)
   local search = function(f) return f._id == "elona.stairs_down" end
   local feat = map:iter_feats():filter(search):nth(1)
   if not feat then
      Log.warn("No stairs down were found in map.")
      return center(map, chara, prev)
   end

   return feat.x, feat.y
end

data:add(
   {
      _id = "stair_down",
      _type = "base.map_entrance",

      pos = stair_down
   }
)
