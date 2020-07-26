local QuickCheck = require("api.test.QuickCheck")
local ItemGen = require("api.test.gen.ItemGen")

function test_clone_events()
   local function prop_clone_events(item)
      local new = item:clone()
      return new._events == item._events
   end

   QuickCheck.assert(prop_clone_events, {ItemGen:new()})
end

function test_separate()
   local function prop_can_stack_with(item)
      local new = item:separate()
      return new:can_stack_with(item)
   end

   QuickCheck.assert(prop_can_stack_with, {ItemGen:new({amount = 2})})
end

function test_separate_self()
   local function prop_separate_self(item)
      local new = item:separate()
      return new == item
   end

   QuickCheck.assert(prop_separate_self, {ItemGen:new({amount = 1})})
end

function test_separate_self_2()
   local function prop_separate_self(item)
      local new = item:separate()
      return not new:can_stack_with(item)
   end

   QuickCheck.assert(prop_separate_self, {ItemGen:new({amount = 1})})
end
