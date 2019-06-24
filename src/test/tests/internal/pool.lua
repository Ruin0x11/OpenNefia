local IMapObject = require("api.IMapObject")
local uid_tracker = require("internal.uid_tracker")
local pool = require("internal.pool")
local MockObject = require("test.support.MockObject")

test("pool - generation", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)

        ok(t.are_same("hoge", o.thing))
        ok(t.are_same(1, o.uid))

        o.thing = "zxc"
        ok(t.are_same("zxc", o.thing))

        o.thing = nil
        ok(t.are_same("hoge", o.thing))

        -- o.uid = 2
        -- ok(t.are_same(1, o.uid))

        -- o.uid = nil
        -- ok(t.are_same(1, o.uid))
end)

test("pool - uid increment", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)

        local a = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)
        local b = p:create_object(MockObject:new({thing = "fuga"}), 5, 5)

        ok(t.are_same(1, a.uid))
        ok(t.are_same(2, b.uid))

        ok(p:remove_object(b))
        local c = p:create_object(MockObject:new({thing = "piyo"}), 5, 5)

        ok(t.are_same(1, a.uid))
        ok(t.are_same(2, b.uid))
        ok(t.are_same(3, c.uid))
end)

test("pool - removal", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)
        local uid = o.uid

        ok(p:get_object(uid) ~= nil)
        ok(o ~= nil)

        o = nil
        collectgarbage()
        ok(p:get_object(uid) ~= nil)

        p:remove_object(uid)
        ok(p:get_object(uid) == nil)
end)

test("pool - ref removal", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)
        local uid = o.uid

        ok(p:get_object(uid) ~= nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        ok(p:remove_object(o))
        collectgarbage()

        ok(p:get_object(uid) == nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == false)

        o.is_valid = true
        -- ok(o.is_valid == false)
end)

test("pool - transfer", function()
        local u = uid_tracker:new()
        local from = pool:new("test", u, 10, 10)
        local to = pool:new("test", u, 10, 10)
        local o = from:create_object(MockObject:new({thing = "hoge"}), 5, 5)
        local uid = o.uid

        ok(from:get_object(uid).uid == o.uid)
        ok(to:get_object(uid) == nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        ok(from:put_into(to, o, 5, 5))

        ok(from:get_object(uid) == nil)
        ok(to:get_object(uid).uid == o.uid)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        o = to:get_object(uid)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)
end)

test("pool - positional", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local a = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), { a }))

        local b = p:create_object(MockObject:new({thing = "fuga"}), 5, 5)

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), { a, b }))

        ok(p:remove_object(a))

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), { b }))
end)

test("pool - positional move", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local a = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), { a }))
        ok(t.are_same(p:objects_at_pos(4, 5):to_list(), {}))

        ok(p:move_object(a, 4, 5))

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), {}))
        ok(t.are_same(p:objects_at_pos(4, 5):to_list(), { a }))

        ok(p:move_object(a, 4, 5))

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), {}))
        ok(t.are_same(p:objects_at_pos(4, 5):to_list(), { a }))

        ok(not pcall(function() p:move_object(a, 1000, 5) end))
        ok(not pcall(function() p:move_object(a, -1, 5) end))

        ok(p:remove_object(a))

        ok(t.are_same(p:objects_at_pos(5, 5):to_list(), {}))
        ok(t.are_same(p:objects_at_pos(4, 5):to_list(), {}))

        ok(not pcall(function() p:move_object(a, 5, 5) end))
end)

test("pool - gc", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local a = p:create_object(MockObject:new({thing = "hoge"}), 5, 5)

        local t = setmetatable({a}, { __mode = "v" })

        ok(p:remove_object(a))
        a = nil
        collectgarbage()

        ok(t[1] == nil)
end)
