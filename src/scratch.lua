local Map = require("api.Map")
local Chara = require("api.Chara")

for k, ch in Map.iter_charas() do
   print(k,Chara.player():reaction_towards(ch))
end
