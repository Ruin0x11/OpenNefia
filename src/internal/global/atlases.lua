local tile_atlas, chara_atlas, item_atlas

local atlases = {}

function atlases.set(tile, chara)
   tile_atlas = tile
   chara_atlas = chara
   item_atlas = chara
end

function atlases.get()
   return tile_atlas, chara_atlas, item_atlas
end

return atlases
