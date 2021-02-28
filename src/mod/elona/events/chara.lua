local Event = require("api.Event")
local LootDrops = require("mod.elona.api.LootDrops")

local function proc_on_drop_loot(chara, params, drops)
   if chara.proto.on_drop_loot then
      chara.proto.on_drop_loot(chara, params, drops)
   end
end
Event.register("elona.on_chara_generate_loot_drops", "Run on_drop_loot callback", proc_on_drop_loot)

local function generate_loot(chara, params)
   LootDrops.drop_loot(chara, params.attacker)
end
Event.register("base.on_kill_chara", "Generate loot and drop held items", generate_loot)
