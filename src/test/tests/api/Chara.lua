local MapObject = require("api.MapObject")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Event = require("api.Event")
local EventHolder = require("api.EventHolder")
local InstancedMap = require("api.InstancedMap")
local uid_tracker = require("internal.uid_tracker")
local MockObject = require("test.support.MockObject")

test("mapobject - gc", function()
        local u = uid_tracker:new()
        local o = MapObject.generate(MockObject:new(), {}, u)

        local t = setmetatable({o}, { __mode = "v" })

        o = nil
        collectgarbage()

        ok(t[1] == nil)
end)

test("chara - gc", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local c = Chara.create("test.chara", 12, 10, {}, map)

        local t = setmetatable({c}, { __mode = "v" })

        c:remove_ownership()
        c = nil
        collectgarbage()

        ok(t[1] == nil)
end)

test("chara - observer", function()
        local u = uid_tracker:new()
        local events = EventHolder:new()
        local map = InstancedMap:new(20, 20, u)
        local a = Chara.create("test.chara", 10, 10, {}, map)
        local b = Chara.create("test.chara", 11, 10, {}, map)
        local c = Chara.create("test.chara", 12, 10, {}, map)

        local tally = 0

        for _, ch in ipairs({a, b, c}) do
           ch:observe_event("base.notify_test", "test", function()
                               tally = tally + 1
           end, nil, events)
        end

        events:trigger("base.notify_test")
        ok(tally == 3)

        tally = 0

        b:unobserve_event("base.notify_test", "test")

        events:trigger("base.notify_test")
        ok(tally == 2)

        tally = 0

        a.events:disable("base.notify_test", "test")

        events:trigger("base.notify_test")
        ok(tally == 1)
end)

test("chara - observer instanced", function()
        local u = uid_tracker:new()
        local events = EventHolder:new()
        local map = InstancedMap:new(20, 20, u)
        local a = Chara.create("test.chara", 10, 10, {}, map)
        local b = Chara.create("test.chara", 10, 11, {}, map)

        local tally = 0

        for _, ch in ipairs({a, b}) do
           ch:observe_event("base.notify_test", "test", function()
                               tally = tally + 1
           end, nil, events)
        end

        events:trigger("base.notify_test", {chara = a}, {observer = "chara"})
        ok(tally == 1)

        tally = 0

        events:trigger("base.notify_test")
        ok(tally == 2)
end)

test("chara - observer gc", function()
        local u = uid_tracker:new()
        local events = EventHolder:new()
        local map = InstancedMap:new(20, 20, u)
        local c = Chara.create("test.chara", 12, 10, {}, map)

        local tally = 0

        c:observe_event("base.notify_test", "test", function()
                           tally = tally + 1
        end, nil, events)

        c:remove_ownership()
        c = nil
        collectgarbage()

        events:trigger("base.notify_test")
        ok(tally == 0)
end)

test("chara - equip", function()
        local map = InstancedMap:new(20, 20)
        local c = Chara.create("test.chara", 12, 10, {}, map)
        local i = Item.create("test.sword", 12, 10, {}, map)

        ok(i.location == map)
        ok(not c:equip_item(i))
        ok(i.location == map)

        ok(c:take_item(i))
        ok(i.location == c)
        ok(not c:take_item(i))

        ok(c:equip_item(i))
        ok(i.location == c.equip)
        ok(not c:equip_item(i))
        ok(c:has_item_equipped(i))

        ok(c:unequip_item(i))
        ok(i.location == c)
        ok(not c:unequip_item(i))
        ok(not c:has_item_equipped(i))
end)

test("chara - equip then drop", function()
        local map = InstancedMap:new(20, 20)
        local c = Chara.create("test.chara", 12, 10, {}, map)
        local i = Item.create("test.sword", 12, 10, {}, map)

        ok(not c:has_item(i))
        ok(not c:has_item_equipped(i))

        ok(c:take_item(i))
        ok(t.are_same(c, i.location))
        ok(c:equip_item(i))
        ok(c:has_item_equipped(i))
        ok(c:has_item(i))

        ok(c:unequip_item(i))
        ok(not c:has_item_equipped(i))
        ok(c:has_item(i))

        ok(c:drop_item(i))
        ok(t.are_same(map, i.location))
        ok(not c:has_item_equipped(i))
        ok(not c:has_item(i))
end)

test("chara - equip gc", function()
        local map = InstancedMap:new(20, 20)
        local c = Chara.create("test.chara", 12, 10, {}, map)
        local i = Item.create("test.sword", 12, 10, {}, map)

        ok(c:take_item(i))
        ok(c:equip_item(i))

        local t = setmetatable({c, i}, { __mode = "v" })

        c:remove_ownership()
        c = nil
        i = nil
        collectgarbage()

        ok(t[1] == nil)
        ok(t[2] == nil)
end)
