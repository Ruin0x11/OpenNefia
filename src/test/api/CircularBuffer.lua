local CircularBuffer = require("api.CircularBuffer")
local Assert = require("api.test.Assert")

function test_CircularBuffer_iter()
   local buf = CircularBuffer:new(3)

   Assert.same({}, fun.wrap(buf:iter()):to_list())
   buf:push(1)
   Assert.same({1}, fun.wrap(buf:iter()):to_list())
   buf:push(2)
   Assert.same({2, 1}, fun.wrap(buf:iter()):to_list())
   buf:push(3)
   Assert.same({3, 2, 1}, fun.wrap(buf:iter()):to_list())
   buf:push(4)
   Assert.same({4, 3, 2}, fun.wrap(buf:iter()):to_list())
end

function test_CircularBuffer_iter__init()
   local buf = CircularBuffer:new(3, 0)

   Assert.same({0, 0, 0}, fun.wrap(buf:iter()):to_list())
   buf:push(1)
   Assert.same({1, 0, 0}, fun.wrap(buf:iter()):to_list())
   buf:push(2)
   Assert.same({2, 1, 0}, fun.wrap(buf:iter()):to_list())
   buf:push(3)
   Assert.same({3, 2, 1}, fun.wrap(buf:iter()):to_list())
   buf:push(4)
   Assert.same({4, 3, 2}, fun.wrap(buf:iter()):to_list())
end

function test_CircularBuffer_iter_nil()
   local buf = CircularBuffer:new(3)

   for _, i in buf:iter() do
      Assert.not_eq(nil, i)
   end
end

function test_CircularBuffer_iter_reverse()
   local buf = CircularBuffer:new(3)

   Assert.same({}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(1)
   Assert.same({1}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(2)
   Assert.same({1, 2}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(3)
   Assert.same({1, 2, 3}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(4)
   Assert.same({2, 3, 4}, fun.wrap(buf:iter_reverse()):to_list())
end

function test_CircularBuffer_iter_reverse__init()
   local buf = CircularBuffer:new(3, 0)

   Assert.same({0, 0, 0}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(1)
   Assert.same({0, 0, 1}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(2)
   Assert.same({0, 1, 2}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(3)
   Assert.same({1, 2, 3}, fun.wrap(buf:iter_reverse()):to_list())
   buf:push(4)
   Assert.same({2, 3, 4}, fun.wrap(buf:iter_reverse()):to_list())
end

function test_CircularBuffer_iter_reverse__nil()
   local buf = CircularBuffer:new(3)

   for _, i in buf:iter_reverse() do
      Assert.not_eq(nil, i)
   end
end
