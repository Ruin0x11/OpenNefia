local Chara = require("api.Chara")
local binser = require("thirdparty.binser")

test("serial", function()
        local c = Chara.create("test.chara", nil, nil, {ownerless=true})

        ok(c.image == 3)

        local d = binser.d(binser.s(c))[1]

        ok(d.image == 3)
end)
