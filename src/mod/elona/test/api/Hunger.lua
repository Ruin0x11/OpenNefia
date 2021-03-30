local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Hunger = require("mod.elona.api.Hunger")
local IOwned = require("api.IOwned")
local test_util = require("api.test.test_util")
local IItem = require("api.item.IItem")

function test_Hunger_apply_general_eating_effect__sustain_attribute()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.putitoro", map)

   chara:remove_all_buffs()
   Assert.eq(0, chara:iter_buffs():length())

   food:add_enchantment("elona.sustain_attribute", 100, { skill_id = "elona.stat_strength" })
   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(1, chara:iter_buffs():length())
   local buff = chara:get_buff("elona.food_str")
   Assert.is_truthy(buff)
   Assert.eq(30, buff.power)
   Assert.eq(2000, buff.duration)
end

function test_Hunger_apply_general_eating_effect__modify_attribute()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.putitoro", map)

   chara:mod_base_skill_level("elona.stat_strength", 10, "set")
   chara:mod_skill_potential("elona.stat_strength", 100, "set")
   Assert.eq(10, chara:base_skill_level("elona.stat_strength"))
   Assert.eq(0, chara:skill_experience("elona.stat_strength"))

   food:add_enchantment("elona.modify_attribute", 100, { skill_id = "elona.stat_strength" })
   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(10, chara:base_skill_level("elona.stat_strength"))
   Assert.eq(600, chara:skill_experience("elona.stat_strength"))
end

function test_Hunger_apply_general_eating_effect__cute_fairy()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.cute_fairy", map)
   local food = test_util.stripped_item("elona.putitoro", map)
   Item.iter(map):each(IItem.remove_ownership)

   Assert.eq(0, Item.iter(map):length())

   chara.nutrition = 0
   food.nutrition = 3000
   Hunger.apply_general_eating_effect(chara, food)

   local items = Item.iter(map)
   Assert.eq(1, items:length())
   Assert.eq(true, items:nth(1):has_category("elona.crop_seed"))
end

function test_Hunger_apply_general_eating_effect__exp_gains_fixed()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.morgia", map)

   chara:mod_base_skill_level("elona.stat_strength", 10, "set")
   chara:mod_skill_potential("elona.stat_strength", 100, "set")
   Assert.eq(10, chara:base_skill_level("elona.stat_strength"))
   Assert.eq(0, chara:skill_experience("elona.stat_strength"))

   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(15, chara:base_skill_level("elona.stat_strength"))
   Assert.eq(508, chara:skill_experience("elona.stat_strength"))
end

function test_Hunger_apply_general_eating_effect__food_type()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.raw_noodle", map)

   food.params.food_quality = 0
   chara.nutrition = 0
   chara:mod_base_skill_level("elona.stat_constitution", 10, "set")
   chara:mod_skill_potential("elona.stat_constitution", 100, "set")
   Assert.eq("elona.pasta", food.params.food_type)
   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(0, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(0, chara.nutrition)

   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(180, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(3500, chara.nutrition)
end

function test_Hunger_apply_general_eating_effect__food_type_cooked()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.raw_noodle", map)

   food.params.food_quality = 9
   chara.nutrition = 0
   chara:mod_base_skill_level("elona.stat_constitution", 10, "set")
   Assert.eq("elona.pasta", food.params.food_type)
   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(0, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(0, chara.nutrition)

   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(42, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(724, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(8225, chara.nutrition)
end

function test_Hunger_apply_general_eating_effect___player_eats_rotten()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.corpse", map)

   Chara.set_player(chara)
   food.spoilage_date = -1
   chara.nutrition = 5000
   chara:mod_base_skill_level("elona.stat_constitution", 10, "set")
   chara:mod_skill_experience("elona.stat_constitution", 500, "set")
   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(500, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(5000, chara.nutrition)
   Assert.eq(true, chara:is_player())

   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(400, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(6000, chara.nutrition)
end

function test_Hunger_apply_general_eating_effect___nonplayer_eats_rotten()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)
   local food = test_util.stripped_item("elona.corpse", map)

   food.spoilage_date = -1
   chara.nutrition = 5000
   chara:mod_base_skill_level("elona.stat_constitution", 10, "set")
   chara:mod_skill_experience("elona.stat_constitution", 500, "set")
   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(500, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(5000, chara.nutrition)
   Assert.eq(false, chara:is_player())

   Hunger.apply_general_eating_effect(chara, food)

   Assert.eq(10, chara:base_skill_level("elona.stat_constitution"))
   Assert.eq(540, chara:skill_experience("elona.stat_constitution"))
   Assert.eq(8500, chara.nutrition)
end

function test_Hunger_apply_general_eating_effect__corpse_effects()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = test_util.stripped_chara("elona.putit", map)

   do
      local food = test_util.stripped_item("elona.corpse", map)

      food.params.chara_id = nil
      chara.nutrition = 5000
      chara:mod_base_skill_level("elona.healing", 10, "set")
      chara:mod_skill_experience("elona.healing", 500, "set")
      Assert.eq(10, chara:base_skill_level("elona.healing"))
      Assert.eq(500, chara:skill_experience("elona.healing"))
      Assert.eq(5000, chara.nutrition)

      Hunger.apply_general_eating_effect(chara, food)

      Assert.eq(10, chara:base_skill_level("elona.healing"))
      Assert.eq(500, chara:skill_experience("elona.healing"))
      Assert.eq(8500, chara.nutrition)
   end

   do
      local food = test_util.stripped_item("elona.corpse", map)

      food.params.chara_id = "elona.troll"
      chara.nutrition = 5000
      chara:mod_base_skill_level("elona.healing", 10, "set")
      chara:mod_skill_experience("elona.healing", 500, "set")
      Assert.eq(10, chara:base_skill_level("elona.healing"))
      Assert.eq(500, chara:skill_experience("elona.healing"))
      Assert.eq(5000, chara.nutrition)

      Hunger.apply_general_eating_effect(chara, food)

      Assert.eq(10, chara:base_skill_level("elona.healing"))
      Assert.eq(556, chara:skill_experience("elona.healing"))
      Assert.eq(8500, chara.nutrition)
   end
end
