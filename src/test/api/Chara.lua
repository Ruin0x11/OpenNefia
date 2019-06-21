local MapObject = require("api.MapObject")
local Chara = require("api.Chara")
local Event = require("api.Event")
local EventHolder = require("api.EventHolder")
local InstancedMap = require("api.InstancedMap")
local uid_tracker = require("internal.uid_tracker")

test("mapobject - gc", function()
        local u = uid_tracker:new()
        local o = MapObject.generate({}, u)

        local t = setmetatable({o}, { __mode = "v" })

        o = nil
        collectgarbage()

        ok(t[1] == nil)
end)

test("chara - gc", function()
        local u = uid_tracker:new()
        local map = InstancedMap:new(20, 20, u)
        local c = Chara.create("base.player", 12, 10, {}, map)

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
        local a = Chara.create("base.player", 10, 10, {}, map)
        local b = Chara.create("base.player", 11, 10, {}, map)
        local c = Chara.create("base.player", 12, 10, {}, map)

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
        local a = Chara.create("base.player", 10, 10, {}, map)
        local b = Chara.create("base.player", 10, 11, {}, map)

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
        local c = Chara.create("base.player", 12, 10, {}, map)

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
