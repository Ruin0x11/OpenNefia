local Inventory = require("api.Inventory")
local Item = require("api.Item")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")

test("Inventory - take and remove", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.item")
        local c = Item.create("test.sword", 0, 0, {}, map)

        ok(not i:contains(c))

        ok(i:take_object(c))
        ok(i:contains(c))

        map:take_object(c, 5, 6)
        ok(not i:contains(c))
        ok(c.x == 5)
        ok(c.y == 6)
end)

test("Inventory - out of global map", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.item")
        local c = Item.create("test.sword", 0, 0, {}, map)

        -- out of global map (succeeds)
        ok(pcall(function() i:take_object(c) end))
end)

test("Inventory - drop position", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.item")
        local c = Item.create("test.sword", 0, 0, {}, map)

        ok(i:take_object(c))
        ok(map:take_object(c, 4, 5))

        ok(c.x == 4)
        ok(c.y == 5)
end)

test("Inventory - take fails if full", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(1, "base.item")
        local a = Item.create("test.sword", 0, 0, {}, map)
        local b = Item.create("test.sword", 0, 1, {}, map)

        ok(i:take_object(a))
        ok(not i:take_object(b))

        ok(a.location == i)
        ok(b.location == map)
end)

test("Inventory - take fails if wrong type", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(1, "base.item")
        local c = Chara.create("test.chara", 0, 0, {}, map)

        ok(not i:take_object(c))

        ok(c.location == map)
end)

test("Inventory - iter", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.item")
        local a = Item.create("test.sword", 1, 0, {}, map)
        local b = Item.create("test.sword", 0, 0, {}, map)

        ok(i:len() == 0)

        ok(i:take_object(a))
        ok(i:take_object(b))
        ok(i:len() == 2)

        local found = {}

        for _, c in i:iter() do
           found[c.uid] = true
        end

        ok(found[a.uid])
        ok(found[b.uid])

        ok(map:take_object(a, 0, 0))
        found = {}

        for _, c in i:iter() do
           found[c.uid] = true
        end

        ok(not found[a.uid])
        ok(found[b.uid])
end)

-- test("Inventory sort", function()
--         local map = InstancedMap:new(20, 20)
--         local i = Inventory:new(200, "base.item", 4, 5)
--         local a = Item.create("test.sword", 0, 0, {}, map)
--         local b = Item.create("test.sword", 1, 0, {}, map)
--         local c = Item.create("test.sword", 2, 0, {}, map)
--
--         a.experience = 300
--         b.experience = 10
--         c.experience = 30
--
--         i:take_object(a)
--         i:take_object(b)
--         i:take_object(c)
--
--         ok(i:at(1).uid == a.uid)
--         ok(i:at(2).uid == b.uid)
--         ok(i:at(3).uid == c.uid)
--         ok(i:at(4) == nil)
--
--         local s = i:sorted_by(function(i, j) return i.experience < j.experience end)
--
--         ok(s[1].uid == b.uid)
--         ok(s[2].uid == c.uid)
--         ok(s[3].uid == a.uid)
--         ok(s[4] == nil)
--
--         i:drop(b.uid, 0, 0, map)
--
--         ok(s[1].uid == b.uid)
--         ok(s[2].uid == c.uid)
--         ok(s[3].uid == a.uid)
--         ok(s[4] == nil)
--
--         map:remove_object(b)
--
--         ok(s[1].uid == b.uid)
--         ok(s[2].uid == c.uid)
--         ok(s[3].uid == a.uid)
--         ok(s[4] == nil)
--
--         s = i:sorted_by(function(i, j) return i.experience < j.experience end)
--
--         ok(s[1].uid == c.uid)
--         ok(s[2].uid == a.uid)
--         ok(s[3] == nil)
-- end)
