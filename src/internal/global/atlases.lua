local _atlases = {}

local atlases = {}

function atlases.set(tile, tile_overhang, chara, item, item_shadow, feat, chip, portrait)
   _atlases = {
      tile = tile,
      tile_overhang = tile_overhang,
      chara = chara,
      item = item,
      item_shadow = item_shadow,
      feat = feat,
      chip = chip,
      portrait = portrait,
   }
end

function atlases.get()
   return _atlases
end

return atlases
