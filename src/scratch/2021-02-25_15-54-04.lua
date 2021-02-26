local nbt = require("thirdparty.nbt")
local Chara = require("api.Chara")
local pool = require("internal.pool")
local Item = require("api.Item")
local nbt_serializer = require("internal.nbt_serializer")

-- Don't worry, Mr. Putit. This won't hurt a bit.
local putit = Chara.create("elona.putit", nil, nil, {ownerless=true})
putit:mod("max_hp", 123, "add")
putit:add_effect_turns("elona.poison", 42)

local p = pool:new("base.item")
local item = Item.create("elona.putitoro", nil, nil, {}, p)
putit.item_to_use = p

print(putit.x)
print(putit.y)
print(putit.uid)
print(putit.hp)
print(putit:calc("max_hp"))
print(putit:effect_turns("elona.poison"))

local ser = nbt_serializer:new()

local t = {}

t.pool = p:serialize_nbt(ser)
t.putit = putit:serialize_nbt(ser)

local compound = ser:serialize_compound(t, "compound")

print("==========")

local putit_deser = compound:getValue()["pool"]

print(putit_deser.x)
print(putit_deser.y)
print(putit_deser.uid)
print(putit_deser.hp)
print(putit_deser:calc("max_hp"))
print(putit_deser:effect_turns("elona.poison"))
