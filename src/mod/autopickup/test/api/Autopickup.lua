local Autopickup = require("mod.autopickup.api.Autopickup")
local Enum = require("api.Enum")
local Assert = require("api.test.Assert")
local TestUtil = require("api.test.TestUtil")

local function run_rule(rule, item)
   return Autopickup.compile_rule(rule)(item, TestUtil.stripped_chara("elona.putit"))
end

local function matches(rule, item)
   return select(1, run_rule(rule, item))
end

local function ops(rule, item)
   return select(2, run_rule(rule, item))
end

function test_Autopickup__predicates()
   local item = TestUtil.stripped_item("elona.rod_of_identify")
   item.curse_state = Enum.CurseState.Blessed
   item.identify_state = Enum.IdentifyState.Full -- otherwise we won't know if it's blessed

   Assert.eq(true, matches("all item", item))
   Assert.eq(true, matches("all all item", item))
   Assert.eq(true, matches("blessed item", item))
   Assert.eq(true, matches("all blessed item", item))
   Assert.eq(true, matches("all blessed blessed item", item))
   Assert.eq(true, matches("all blessed identify stage 3 item", item))
   Assert.eq(false, matches("all blessed unknown item", item))
   Assert.eq(false, matches("all cursed item", item))
   Assert.eq(false, matches("all blessed cursed item", item))
end

function test_Autopickup__targets()
   local item = TestUtil.stripped_item("elona.rod_of_identify")
   item.curse_state = Enum.CurseState.Blessed
   item.identify_state = Enum.IdentifyState.Full

   Assert.eq(true, matches("rod of identify", item))
   Assert.eq(true, matches("all rod of identify", item))
   Assert.eq(true, matches("all rod", item))
   Assert.eq(false, matches("all potion", item))
   Assert.eq(false, matches("all equipment", item))
end

function test_Autopickup__ops()
   local item = TestUtil.stripped_item("elona.rod_of_identify")
   item.curse_state = Enum.CurseState.Blessed
   item.identify_state = Enum.IdentifyState.Full -- otherwise we won't know if it's blessed

   Assert.same({}, ops("all item", item))
   Assert.same({Autopickup.OP.DESTROY}, ops("!all item", item))
   Assert.same({Autopickup.OP.DESTROY, Autopickup.OP.DESTROY}, ops("!!all item", item))
   Assert.same({Autopickup.OP.DESTROY_PROMPT}, ops("!?all item", item))
   Assert.same({Autopickup.OP.DESTROY_PROMPT, Autopickup.OP.DESTROY}, ops("!?!all item", item))
   Assert.same({Autopickup.OP.PROMPT, Autopickup.OP.DESTROY}, ops("?!all item", item))
   Assert.same({Autopickup.OP.NEGATION}, ops("~all item", item))
   Assert.same({Autopickup.OP.AUTOSAVE}, ops("%all item", item))
   Assert.same({Autopickup.OP.SET_NO_DROP}, ops("=all item", item))
   Assert.same(nil, ops("all cursed item", item))
end
