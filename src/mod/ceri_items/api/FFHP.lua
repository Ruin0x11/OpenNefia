local FFHP = {}

local cache

local function gen_cache()
   cache = data["ceri_items.ffhp_mapping"]:iter():map(function(c) return c.item_id, c end):to_map()
end

function FFHP.clear_cache()
   cache = nil
end

function FFHP.mapping_for(item_id)
   if cache == nil then
      gen_cache()
   end

   return cache[item_id]
end

return FFHP
