local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local IOwned = require("api.IOwned")

local function stripped_chara(id)
   local chara = Chara.create(id, nil, nil, {ownerless=true})
   chara:iter_items():each(IOwned.remove_ownership)
   return chara
end

function test_ICharaSkills_init__prototype_default_resistances()
   local chara = stripped_chara("elona.red_putit")

   Assert.eq(500, chara:resist_level("elona.acid"))
end

function test_ICharaSkills_mod_resist_level()
   local chara = stripped_chara("elona.putit")

   Assert.eq(100, chara:resist_level("elona.fire"))

   chara:mod_resist_level("elona.fire", 100, "add")
   Assert.eq(200, chara:resist_level("elona.fire"))

   chara:mod_resist_level("elona.fire", 300, "set")
   Assert.eq(300, chara:resist_level("elona.fire"))

   chara:refresh()
   Assert.eq(100, chara:resist_level("elona.fire"))
end

function test_ICharaSkills_mod_base_resist_level()
   local chara = stripped_chara("elona.putit")

   Assert.eq(100, chara:resist_level("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 100, "add")
   Assert.eq(200, chara:resist_level("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 300, "set")
   Assert.eq(300, chara:resist_level("elona.fire"))

   chara:refresh()
   Assert.eq(300, chara:resist_level("elona.fire"))
end
