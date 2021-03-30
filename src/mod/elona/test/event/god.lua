local InstancedMap = require("api.InstancedMap")
local TestUtil = require("api.test.TestUtil")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")
local Assert = require("api.test.Assert")
local Skill = require("mod.elona_sys.api.Skill")
local Action = require("api.Action")
local Enum = require("api.Enum")
local God = require("mod.elona.api.God")

function test_god_bless_water_on_altar()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")
   local player = TestUtil.set_player(map, 5, 5)

   local altar = Item.create("elona.altar", 5, 5, {}, map)

   local water = Item.create("elona.bottle_of_water", nil, nil, {amount=2}, player)
   water.curse_state = Enum.CurseState.Normal

   altar.params.altar_god_id = "elona.jure"
   player.god = nil
   local sep = Action.drop(player, water, 1)
   Assert.eq(true, Item.is_alive(sep))
   Assert.eq(Enum.CurseState.Normal, sep.curse_state)

   player.god = "elona.jure"
   sep = Action.drop(player, water, 1)
   Assert.eq(true, Item.is_alive(sep))
   Assert.eq(Enum.CurseState.Blessed, sep.curse_state)
end

function test_god_join_leave_faith_spacts()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")
   local player = TestUtil.set_player(map, 5, 5)

   Assert.eq(false, player:has_skill("elona.action_prayer_of_jure"))
   Assert.eq(false, player:has_skill("elona.action_absorb_magic"))
   Assert.eq(false, player:has_skill("elona.buff_lulwys_trick"))

   God.switch_religion(player, "elona.jure")
   Assert.eq(true, player:has_skill("elona.action_prayer_of_jure"))
   Assert.eq(false, player:has_skill("elona.action_absorb_magic"))
   Assert.eq(false, player:has_skill("elona.buff_lulwys_trick"))

   God.switch_religion(player, "elona.itzpalt")
   Assert.eq(false, player:has_skill("elona.action_prayer_of_jure"))
   Assert.eq(true, player:has_skill("elona.action_absorb_magic"))
   Assert.eq(false, player:has_skill("elona.buff_lulwys_trick"))

   God.switch_religion(player, "elona.lulwy")
   Assert.eq(false, player:has_skill("elona.action_prayer_of_jure"))
   Assert.eq(false, player:has_skill("elona.action_absorb_magic"))
   Assert.eq(true, player:has_skill("elona.buff_lulwys_trick"))

   God.switch_religion(player, nil)
   Assert.eq(false, player:has_skill("elona.action_prayer_of_jure"))
   Assert.eq(false, player:has_skill("elona.action_absorb_magic"))
   Assert.eq(false, player:has_skill("elona.buff_lulwys_trick"))
end

function test_god_kumiromi_harvest_seeds()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")
   local player = TestUtil.set_player(map)
   player.god = "elona.kumiromi"

   local corpse = Item.create("elona.corpse", 5, 5, {amount=5}, player)

   local items = player:iter_inventory()
   Assert.eq(1, items:length())

   Rand.set_seed(8)
   corpse.spoilage_date = 1
   Effect.spoil_items(map)

   items = player:iter_inventory()
   Assert.eq(2, items:length())
   local seed = items:nth(2)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq(1, corpse.amount)
   Assert.eq("elona.fruit_seed", seed._id)
   Assert.eq(4, seed.amount)
   Assert.eq(true, seed:has_category("elona.crop_seed"))
end

function test_god_ehekatl_spell_mp_cost()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")
   local player = TestUtil.set_player(map)

   Rand.set_seed(1)

   Assert.eq(40, Skill.calc_spell_mp_cost("elona.spell_magic_storm", player))
   Assert.eq(40, Skill.calc_actual_spell_mp_cost("elona.spell_magic_storm", player))
   Assert.eq(40, Skill.calc_actual_spell_mp_cost("elona.spell_magic_storm", player))

   player.god = "elona.ehekatl"
   Assert.eq(40, Skill.calc_spell_mp_cost("elona.spell_magic_storm", player))
   Assert.eq(19, Skill.calc_actual_spell_mp_cost("elona.spell_magic_storm", player))
   Assert.eq(1, Skill.calc_actual_spell_mp_cost("elona.spell_magic_storm", player))
end
