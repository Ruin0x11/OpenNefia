local TestUtil = require("api.test.TestUtil")
local IItemPotion = require("mod.elona.api.aspect.IItemPotion")
local Assert = require("api.test.Assert")

function test_IObject_change_prototype__replace_aspects()
   local potion = TestUtil.stripped_item("elona.potion_of_hero")

   local aspect = potion:get_aspect(IItemPotion)
   Assert.is_truthy(aspect)
   Assert.same({{_id = "elona.buff_hero", power = 250}}, aspect.effects)

   potion:change_prototype("elona.poison", { replace_aspects = true })

   aspect = potion:get_aspect(IItemPotion)
   Assert.is_truthy(aspect)
   Assert.same({{_id = "elona.effect_poison", power = 200}}, aspect.effects)
end

function test_IObject_change_prototype__replace_aspects_false()
   local potion = TestUtil.stripped_item("elona.potion_of_hero")

   local aspect = potion:get_aspect(IItemPotion)
   Assert.is_truthy(aspect)
   Assert.same({{_id = "elona.buff_hero", power = 250}}, aspect.effects)

   potion:change_prototype("elona.poison")

   aspect = potion:get_aspect(IItemPotion)
   Assert.is_truthy(aspect)
   Assert.same({{_id = "elona.buff_hero", power = 250}}, aspect.effects)
end
