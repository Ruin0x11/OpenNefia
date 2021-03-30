local Save = require("api.Save")
local Assert = require("api.test.Assert")
local config = require("internal.config")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local TestUtil = require("api.test.TestUtil")

function test_Save_save_game__sanitizes_save_id()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)
   TestUtil.register_map(map)

   Save.save_game("<Gwen> the innocent")
   Assert.eq("_Gwen_ the innocent", config.base._save_id)

   Save.load_game("<Gwen> the innocent")
   Assert.eq("_Gwen_ the innocent", config.base._save_id)
end
