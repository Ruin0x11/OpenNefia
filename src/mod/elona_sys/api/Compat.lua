local Compat = {}

function Compat.convert_122_id(_type, elona_id)
   local it = data[_type]:find_by("elona_id", elona_id)
   if it then
      return it._id
   end

   return nil
end

function Compat.convert_122_chara_chip(elona_id)
   local pred = function(c) return c.group == "chara" and c.elona_id == elona_id end
   local it = data["base.chip"]:iter():filter(pred):nth(1)
   if it then
      return it._id
   end

   return nil
end

return Compat
