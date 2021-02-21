local Compat = {}

function Compat.convert_122_id(_type, elona_id)
   local it = data[_type]:find_by("elona_id", elona_id)
   if it then
      return it._id
   end

   return nil, ("Cannot find entry of type '%s' with elona_id '%s'"):format(_type, elona_id)
end

local function gen_chip_convert(group)
   return function(elona_id)
      local pred = function(c) return c.group == group and c.elona_id == elona_id end
      local it = data["base.chip"]:iter():filter(pred):nth(1)
      if it then
         return it._id
      end

      return nil
   end
end

Compat.convert_122_chara_chip = gen_chip_convert("chara")
Compat.convert_122_item_chip = gen_chip_convert("item")
Compat.convert_122_feat_chip = gen_chip_convert("feat")

function Compat.convert_122_map_chip(elona_atlas, elona_id)
   assert(elona_atlas, "need atlas number")
   assert(elona_id, "need ID")
   local pred = function(c) return c.elona_atlas == elona_atlas and c.elona_id == elona_id end
   local it = data["base.map_tile"]:iter():filter(pred):nth(1)
   if it then
      return it._id
   end

   return nil
end

function Compat.convert_122_item_category(category)
   assert(category)
   return data["base.item_type"]:iter():filter(function(i) return i.ordering == category end):extract("_id"):nth(1)
end

return Compat
