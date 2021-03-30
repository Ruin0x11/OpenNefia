local Autopickup = require("mod.autopickup.api.Autopickup")
local Enum = require("api.Enum")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")

local function matches(rule, item)
   return select(1, Autopickup.compile_rule(rule)(item, test_util.stripped_chara("elona.putit")))
end

function test_Autopickup__predicates()
   local item = test_util.stripped_item("elona.rod_of_identify")
   item.curse_state = Enum.CurseState.Blessed

   Assert.eq(true, matches("all item", item))
   Assert.eq(true, matches("all blessed item", item))
   Assert.eq(true, matches("all blessed blessed item", item))
   Assert.eq(true, matches("all blessed unknown item", item))
   Assert.eq(false, matches("all cursed item", item))
   Assert.eq(false, matches("all blessed cursed item", item))
end

function test_Autopickup__targets()
   local item = test_util.stripped_item("elona.rod_of_identify")
   item.curse_state = Enum.CurseState.Blessed

   Assert.eq(true, matches("rod of identify", item))
   Assert.eq(true, matches("all rod of identify", item))
   Assert.eq(true, matches("all rod", item))
   Assert.eq(false, matches("all potion", item))
   Assert.eq(false, matches("all equipment", item))
end
