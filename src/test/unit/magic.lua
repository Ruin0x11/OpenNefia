local Chara = require("api.Chara")
local Item = require("api.Item")
local Env = require("api.Env")
local Magic = require("mod.elona.api.Magic")
local InstancedMap = require("api.InstancedMap")

function test_zap_wand_mutating_wand_itself()
   local map = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.putit", nil, nil, {ownerless = true})
   map:take_object(chara, 5, 5)
   Chara.set_player(chara)
   local rod = Item.create("elona.rod_of_alchemy", nil, nil, {}, chara)
   rod.charges = 10
   local target = Item.create("elona.putitoro", nil, nil, {ownerless = true})
   local params = {}

   Env.push_ui_result({result = target})

   local result = Magic.zap_wand(rod, "elona.effect_alchemy", 100, params)
end
