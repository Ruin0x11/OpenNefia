local _atlases = {}

local atlases = {}

function atlases.set(tile, chara, item, feat, portrait)
   _atlases = {
      tile = tile,
      chara = chara,
      item = item,
      feat = feat,
      portrait = portrait,
   }
end

function atlases.get()
   return _atlases
end

return atlases
