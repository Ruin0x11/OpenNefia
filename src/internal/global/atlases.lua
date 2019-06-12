local tile_atlas, chara_atlas, item_atlas

local atlases = {}

function atlases.set(tile, chara, item)
   tile_atlas = tile
   chara_atlas = chara
   item_atlas = item
end

function atlases.get()
   return tile_atlas, chara_atlas, item_atlas
end

return atlases
