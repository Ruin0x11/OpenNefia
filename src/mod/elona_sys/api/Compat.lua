local Compat = {}

function Compat.convert_122_id(elona_id, _type)
   return data[_type]:find_by("elona_id", elona_id)
end

return Compat
