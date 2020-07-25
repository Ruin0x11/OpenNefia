local QuickCheck = require("api.test.QuickCheck")
local IntGen = require("api.test.gen.IntGen")
local StringGen = require("api.test.gen.StringGen")
local ItemGen = require("api.test.gen.ItemGen")

function test_StringGen_fixed_length()
   local function prop_fixed_length(len)
      local str = StringGen:new(len):pick(1)
      return str:len() == len
   end

   QuickCheck.assert(prop_fixed_length, {IntGen:new(1, 100)})
end

function test_ItemGen_ignores_amount()
   local function prop_ignores_amount(amount)
      return ItemGen:new({amount = amount}):pick(1).amount == amount
   end

   QuickCheck.assert(prop_ignores_amount, {IntGen:new(1, 100)})
end
