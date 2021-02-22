local Save = require("api.Save")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Map = require("api.Map")
local Chara = require("api.Chara")
local field = require("game.field")

local test_util = {}

function test_util.set_player(map, x, y)
   if map == nil then
      field.player = Chara.create("base.player", x, y, {ownerless=true})
      return field.player
   else
      local player = Chara.create("base.player", x, y, {}, map)
      Chara.set_player(player)
      return player
   end
end

function test_util.register_map(map)
   assert(Chara.player(), "player must be set")
   local area = InstancedArea:new()
   Area.register(area, { parent = "root" })
   area:add_floor(map, 1)
   Map.save(map)
   Map.set_map(map)
end

function test_util.save_cycle()
   Save.save_game("__test__")
   Save.load_game("__test__")
end

return test_util
