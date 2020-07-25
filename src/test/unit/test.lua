local QuickCheck = require("api.test.QuickCheck")
local UnicodeGen = require("api.test.gen.UnicodeGen")
local IntGen = require("api.test.gen.IntGen")

function test_wide_sub()
   local function prop_cutname(str, len)
      return utf8.wide_len(utf8.wide_sub(str, 0, len)) <= len
   end

   QuickCheck.assert(prop_cutname, {UnicodeGen:new_kana(), IntGen:new(1, 1000)})
end
