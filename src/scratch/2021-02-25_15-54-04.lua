local nbt = require("thirdparty.nbt")
local Chara = require("api.Chara")

-- Don't worry, Mr. Putit. This won't hurt a bit.
local putit = Chara.create("elona.putit", nil, nil, {ownerless=true})
putit:mod("max_hp", 123, "add")
putit:add_effect_turns("elona.poison", 42)

print(putit.x)
print(putit.y)
print(putit.uid)
print(putit.hp)
print(putit:calc("max_hp"))
print(putit:effect_turns("elona.poison"))

local compound = nbt.newMapObjectCompound(putit)

print("==========")

local putit_deser = compound:getMapObjectCompound()

print(putit_deser.x)
print(putit_deser.y)
print(putit_deser.uid)
print(putit_deser.hp)
print(putit_deser:calc("max_hp"))
print(putit_deser:effect_turns("elona.poison"))
