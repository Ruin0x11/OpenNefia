local Chara = require("api.Chara")
local ElonaAi = require("mod.elona_ai.api.ElonaAi")

test("AI idle", function()
        t.mock_map()

        local c = Chara.create("base.player", 1, 1)
        local ai = ElonaAi:new()

        ok(t.are_same({"base.move", { x = 2, y = 1 }}, ai:decide_action(c)))
        ok(t.are_same({"base.move", { x = 2, y = 2 }}, ai:decide_action(c)))
end)
