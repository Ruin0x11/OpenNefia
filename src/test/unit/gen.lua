local QuickCheck = require("api.test.QuickCheck")
local IntGen = require("api.test.gen.IntGen")
local StringGen = require("api.test.gen.StringGen")
local ItemGen = require("api.test.gen.ItemGen")

function test_StringGen_fixed_length()
   local function prop_fixed_length(len, iterations)
      local str = StringGen:new(len):pick(iterations)
      return str:len() == len
   end

   QuickCheck.assert(prop_fixed_length, {IntGen:new(1, 100), IntGen:new(1, 100)})
end

function test_ItemGen_ignores_amount()
   local function prop_ignores_amount(amount, iterations)
      return ItemGen:new({amount = amount}):pick(iterations).amount == amount
   end

   QuickCheck.assert(prop_ignores_amount, {IntGen:new(1, 100), IntGen:new(1, 30)})
end
