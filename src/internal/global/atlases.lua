local _atlases = {}

local atlases = {}

function atlases.set(tile, tile_overhang, item_shadow, chip, portrait)
   _atlases = {
      tile = tile,
      tile_overhang = tile_overhang,
      item_shadow = item_shadow,
      chip = chip,
      portrait = portrait,
   }
end

function atlases.get()
   return _atlases
end

return atlases
