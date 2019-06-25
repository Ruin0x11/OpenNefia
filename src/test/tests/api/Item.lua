local Item = require("api.Item")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local uid_tracker = require("internal.uid_tracker")

test("item - gc", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local i = Item.create("test.sword", 10, 10, {}, map)

        local t = setmetatable({i}, { __mode = "v" })

        i:remove_ownership()
        i = nil
        collectgarbage()

        ok(t[1] == nil)
end)

test("item - stack", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local a = Item.create("test.sword", 10, 10, {amount=1}, map)
        local b = Item.create("test.sword", 10, 10, {amount=2,no_stack=true}, map)

        a.curse_state = "none"
        b.curse_state = "none"

        ok(t.are_same(1, a.amount))
        ok(t.are_same(a.location, b.location))
        ok(t.are_same(2, b.amount))

        a:stack()

        ok(t.are_same(3, a.amount))
        ok(b.location == nil)
        ok(t.are_same(0, b.amount))
end)

test("item - stack different tile", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local a = Item.create("test.sword", 10, 10, {amount=1}, map)
        local b = Item.create("test.sword", 10, 11, {amount=2,no_stack=true}, map)

        a.curse_state = "none"
        b.curse_state = "none"

        ok(t.are_same(1, a.amount))
        ok(t.are_same(a.location, b.location))
        ok(t.are_same(2, b.amount))

        a:stack()

        ok(t.are_same(1, a.amount))
        ok(t.are_same(a.location, b.location))
        ok(t.are_same(2, b.amount))
end)

test("item - stack different fields", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local a = Item.create("test.sword", 10, 10, {amount=1}, map)
        local b = Item.create("test.sword", 10, 10, {amount=2,no_stack=true}, map)

        a.curse_state = "none"
        b.curse_state = "blessed"

        ok(t.are_same(1, a.amount))
        ok(t.are_same(a.location, b.location))
        ok(t.are_same(2, b.amount))

        a:stack()

        ok(t.are_same(1, a.amount))
        ok(t.are_same(a.location, b.location))
        ok(t.are_same(2, b.amount))
end)

test("item - activate shortcut", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local c = Chara.create("test.chara", 5, 5, {}, map)
        local i = Item.create("test.sword", 10, 10, {}, c)

        ok(c:has_item(i))
        ok(t.are_same(c, i:get_owning_chara()))
        ok(t.are_same(map, i:current_map()))

        local result, err = Item.activate_shortcut(i, "inv_drop")

        ok(t.are_same("turn_end", result))
        ok(err == nil)
        ok(i:get_owning_chara() == nil)
        ok(t.are_same(map, i:current_map()))
        ok(t.are_same(5, i.x))
        ok(t.are_same(5, i.y))
end)
