local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local uid_tracker = require("internal.uid_tracker")

test("item - gc", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local i = Item.create("test.sword", 10, 10, 1, {}, map)

        local t = setmetatable({i}, { __mode = "v" })

        i:remove_ownership()
        i = nil
        collectgarbage()

        ok(t[1] == nil)
end)
