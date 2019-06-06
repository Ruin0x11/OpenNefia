local chara = {}

local player

function chara.set_player(p)
   player = p
end

function chara.player()
   return player
end

return chara
