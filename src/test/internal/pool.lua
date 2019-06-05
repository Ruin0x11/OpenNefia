local uid_tracker = require("internal.uid_tracker")
local pool = require("internal.pool")

test("pool - generation", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u)
        local o = p:generate({thing = "hoge"})

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
        local p = pool:new("test", u)

        local a = p:generate({thing = "hoge"})
        local b = p:generate({thing = "fuga"})

        ok(assert.are_same(1, a.uid))
        ok(assert.are_same(2, b.uid))

        p:remove(b.uid)
        local c = p:generate({thing = "piyo"})

        ok(assert.are_same(1, a.uid))
        ok(assert.are_same(2, b.uid))
        ok(assert.are_same(3, c.uid))
end)

test("pool - removal", function()
        local u = uid_tracker:new()
        local p = pool:new("test", u)
        local o = p:generate({thing = "hoge"})
        local uid = o.uid

        ok(p:get(uid) ~= nil)
        ok(o ~= nil)

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
        local p = pool:new("test", u)
        local o = p:generate({thing = "hoge"})
        local uid = o.uid

        ok(p:get(uid) ~= nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        ok(o.is_valid == true)

        p:remove(uid)
        collectgarbage()

        ok(p:get(uid) == nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        ok(o.is_valid == false)

        o.is_valid = true
        ok(o.is_valid == false)
end)

test("pool - transfer", function()
        local u = uid_tracker:new()
        local from = pool:new("test", u)
        local to = pool:new("test", u)
        local o = from:generate({thing = "hoge"})
        local uid = o.uid

        ok(from:get(uid) ~= nil)
        ok(to:get(uid) == nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        ok(o.is_valid == true)

        from:transfer_to(to, uid)

        ok(from:get(uid) == nil)
        ok(to:get(uid) ~= nil)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        ok(o.is_valid == false)

        o = to:get(uid)
        ok(o ~= nil)
        ok(o.thing == "hoge")
        ok(o.is_valid == true)
end)
