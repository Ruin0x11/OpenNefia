local Compat = {}

function Compat.convert_122_id(_type, elona_id)
   local it = data[_type]:find_by("elona_id", elona_id)
   if it then
      return it._id
   end

   return nil
end

return Compat
