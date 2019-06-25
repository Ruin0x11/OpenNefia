local test_helper = {}

function test_helper.mock_map()
   local global = require("internal.global")
   global.clear()

   local mod = require("internal.mod")

   local startup = require("game.startup")
   startup.load_batches(require("internal.draw").get_coords())
   local mods = { "mod/base/mod.lua", "test/mod/mod.lua" }
   startup.run(mods)

   local Rand = require("api.Rand")
   Rand.set_seed(0)

   local field = require("game.field")
   local uids = require("internal.uid_tracker"):new()
   local map = require("api.InstancedMap"):new(20, 20, uids)
   field:set_map(map)

   local Chara = require("api.Chara")
   local me = Chara.create("test.chara", 10, 10)
   Chara.set_player(me)
end


function test_helper.are_same(expected, actual)
   local res = expected == actual
   if not res then
      res = table.deepcompare(expected, actual, true)
   end
   if not res then
      return false, "expected:\n" .. inspect(expected) .. "\nactual:\n" .. inspect(actual)
   end

   return true, ""
end

function test_helper.fails_with(f, msg)
   local result, err = pcall(f)

   return err ~= nil and string.find(err, msg) ~= nil
end

return test_helper
