local _atlases = {}

local atlases = {}

function atlases.set(tile, chara, item, feat)
   _atlases = {
      tile = tile,
      chara = chara,
      item = item,
      feat = feat,
   }
end

function atlases.get()
   return _atlases
end

return atlases
