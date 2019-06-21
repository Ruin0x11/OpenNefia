local Inventory = require("api.Inventory")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")

test("Inventory", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.chara") -- HACK no items yet
        local c = Chara.create("base.player", 0, 0, {}, map)

        ok(not i:contains(c))

        i:take_object(c)
        ok(i:contains(c))

        i:put_into(map, c, 5, 6)
        ok(not i:contains(c))
        ok(c.x == 5)
        ok(c.y == 6)
end)

test("Inventory 2", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.chara")
        local c = Chara.create("base.player", 0, 0, {}, map)

        ok(not pcall(function() i:drop(c, 0, 0, map) end))

        i:take_object(c, map)
        ok(not pcall(function() i:take_object(c) end))

        i:put_into(map, c, 0, 0)
        ok(not pcall(function() i:drop(c, 0, 0, map) end))
end)

test("Inventory 3", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.chara")
        local c = Chara.create("base.player", 0, 0, {}, map)

        -- out of global map (succeeds)
        ok(pcall(function() i:take_object(c) end))
end)

test("Inventory drop position", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.chara")
        local c = Chara.create("base.player", 0, 0, {}, map)

        i:take_object(c)
        i:put_into(map, c, 4, 5)

        ok(c.x == 4)
        ok(c.y == 5)
end)

test("Inventory iter", function()
        local map = InstancedMap:new(20, 20)
        local i = Inventory:new(200, "base.chara")
        local a = Chara.create("base.player", 1, 0, {}, map)
        local b = Chara.create("base.player", 0, 0, {}, map)

        ok(i:len() == 0)

        i:take_object(a)
        i:take_object(b)
        ok(i:len() == 2)

        local found = {}

        for _, c in i:iter() do
           found[c.uid] = true
        end

        ok(found[a.uid])
        ok(found[b.uid])

        i:put_into(map, a, 0, 0)
        found = {}

        for _, c in i:iter() do
           found[c.uid] = true
        end

        ok(not found[a.uid])
        ok(found[b.uid])
end)

-- test("Inventory sort", function()
--         local map = InstancedMap:new(20, 20)
--         local i = Inventory:new(200, "base.chara", 4, 5)
--         local a = Chara.create("base.player", 0, 0, {}, map)
--         local b = Chara.create("base.player", 1, 0, {}, map)
--         local c = Chara.create("base.player", 2, 0, {}, map)
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
