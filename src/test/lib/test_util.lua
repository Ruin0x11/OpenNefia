local Save = require("api.Save")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Map = require("api.Map")
local Chara = require("api.Chara")
local field = require("game.field")
local IOwned = require("api.IOwned")
local Item = require("api.Item")
local Enum = require("api.Enum")

local test_util = {}

function test_util.set_player(map, x, y)
   if map == nil then
      field.player = assert(Chara.create("base.player", x, y, {ownerless=true}))
      return field.player
   else
      local player = assert(Chara.create("base.player", x, y, {}, map))
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

function test_util.stripped_chara(id, map, x, y)
   local chara
   if map then
      chara = Chara.create(id, x, y, {}, map)
   else
      chara = Chara.create(id, nil, nil, {ownerless=true})
   end
   chara:iter_items():each(IOwned.remove_ownership)
   return chara
end

function test_util.stripped_item(id, map, x, y)
   local item
   if map == nil then
      item = Item.create(id, x, y, {amount=1}, map)
   else
      item = Item.create(id, x, y, {ownerless=true,amount=1})
   end
   item.curse_state = Enum.CurseState.Normal
   item.spoilage_date = nil
   return item
end

return test_util
