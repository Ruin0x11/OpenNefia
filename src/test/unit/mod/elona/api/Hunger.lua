local Item = require("api.Item")
local Enum = require("api.Enum")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Hunger = require("mod.elona.api.Hunger")
local IOwned = require("api.IOwned")

local function stripped_item(map, id)
   local food = Item.create(id or "elona.putitoro", nil, nil, {amount=1}, map)
   food.curse_state = Enum.CurseState.Normal
   food.spoilage_date = nil
   return food
end

local function stripped_chara(map, id)
   local chara = Chara.create(id or "elona.putit", nil, nil, {}, map)
   chara:iter_equipment():each(function(i) assert(chara:unequip_item(i)) end)
   chara:refresh()
   return chara
end

function test_Hunger_apply_general_eating_effect__sustain_attribute()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = stripped_chara(map)
   local food = stripped_item(map)

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

   local chara = stripped_chara(map)
   local food = stripped_item(map)

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

   local chara = stripped_chara(map, "elona.cute_fairy")
   local food = stripped_item(map)
   Item.iter(map):each(IOwned.remove_ownership)

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

   local chara = stripped_chara(map)
   local food = stripped_item(map, "elona.morgia")

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

   local chara = stripped_chara(map)
   local food = stripped_item(map, "elona.raw_noodle")

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

   local chara = stripped_chara(map)
   local food = stripped_item(map, "elona.raw_noodle")

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
