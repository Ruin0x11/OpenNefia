local uid_tracker = require("internal.uid_tracker")
local pool = require("internal.pool")

test("pool - generation", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object({thing = "hoge"}, 5, 5)

        ok(assert.are_same("hoge", o.thing))
        ok(assert.are_same(1, o.uid))

        o.thing = "zxc"
        ok(assert.are_same("zxc", o.thing))

        o.thing = nil
        ok(assert.are_same("hoge", o.thing))

        o.uid = 2
        ok(assert.are_same(1, o.uid))

        o.uid = nil
        ok(assert.are_same(1, o.uid))
end)

test("pool - uid increment", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)

        local a = p:create_object({thing = "hoge"}, 5, 5)
        local b = p:create_object({thing = "fuga"}, 5, 5)

        ok(assert.are_same(1, a.uid))
        ok(assert.are_same(2, b.uid))

        p:remove(b.uid)
        local c = p:create_object({thing = "piyo"}, 5, 5)

        ok(assert.are_same(1, a.uid))
        ok(assert.are_same(2, b.uid))
        ok(assert.are_same(3, c.uid))
end)

test("pool - removal", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object({thing = "hoge"}, 5, 5)
        local uid = o.uid

        ok(p:get(uid) ~= nil)
        ok(o ~= nil)

        o = nil
        collectgarbage()
        ok(p:get(uid) ~= nil)

        p:remove(uid)
        ok(p:get(uid) == nil)

end)

test("pool - ref removal", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local o = p:create_object({thing = "hoge"}, 5, 5)
        local uid = o.uid

        ok(p:get(uid) ~= nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        p:remove(uid)
        collectgarbage()

        ok(p:get(uid) == nil)
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
        local o = from:create_object({thing = "hoge"}, 5, 5)
        local uid = o.uid

        ok(from:get(uid).uid == o.uid)
        ok(to:get(uid) == nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        from:transfer_to_with_pos(to, uid, 5, 5)

        ok(from:get(uid) == nil)
        ok(to:get(uid).uid == o.uid)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)

        o = to:get(uid)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        -- ok(o.is_valid == true)
end)

test("pool - positional", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local a = p:create_object({thing = "hoge"}, 5, 5)

        ok(assert.are_same(p:objects_at(5, 5), { a.uid }))

        local b = p:create_object({thing = "fuga"}, 5, 5)

        ok(assert.are_same(p:objects_at(5, 5), { a.uid, b.uid }))

        p:remove(a.uid)

        ok(assert.are_same(p:objects_at(5, 5), { b.uid }))
end)

test("pool - positional move", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u, 10, 10)
        local a = p:create_object({thing = "hoge"}, 5, 5)

        ok(assert.are_same(p:objects_at(5, 5), { a.uid }))
        ok(assert.are_same(p:objects_at(4, 5), {}))

        p:move_object(a, 4, 5)

        ok(assert.are_same(p:objects_at(5, 5), {}))
        ok(assert.are_same(p:objects_at(4, 5), { a.uid }))

        p:move_object(a, 4, 5)

        ok(assert.are_same(p:objects_at(5, 5), {}))
        ok(assert.are_same(p:objects_at(4, 5), { a.uid }))

        ok(not pcall(function() p:move_object(a, 1000, 5) end))
        ok(not pcall(function() p:move_object(a, -1, 5) end))

        p:remove(a.uid)

        ok(assert.are_same(p:objects_at(5, 5), {}))
        ok(assert.are_same(p:objects_at(4, 5), {}))

        ok(not pcall(function() p:move_object(a, 5, 5) end))
end)
