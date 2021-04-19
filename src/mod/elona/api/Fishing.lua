local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Log = require("api.Log")
local Item = require("api.Item")
local IItemFishingPole = require("mod.elona.api.aspect.IItemFishingPole")

local Fishing = {}

function Fishing.random_fish_level(fishing_pole)
   local bait = data["elona.bait"]:ensure(fishing_pole:calc_aspect(IItemFishingPole, "bait_type", "base"))
   local rank = bait.rank or 0

   local level = Rand.rnd(rank)
   if Rand.one_in(5) then
      level = level + 1
   end
   if Rand.one_in(5) then
      level = level - 1
   end
   return level
end

function Fishing.random_fish_id(fishing_pole)
   -- >>>>>>>> shade2/proc.hsp:855 *choose_fish ...
   local filter = function(fish)
      if fish.rarity <= 0 then
         return false
      end

      return Fishing.random_fish_level(fishing_pole) == fish.level
   end

   local sampler = WeightedSampler:new()

   local function sample(acc, fish)
      sampler:add(fish._id, fish.rarity)
   end

   data["elona.fish"]:iter():filter(filter):foldl(sample, sampler)

   if sampler:len() == 0 then
      Log.warn("No fish generation candidates found for bait '%s'", fishing_pole:calc_aspect(IItemFishingPole, "bait_type", "base"))
   end

   return sampler:sample()
   -- <<<<<<<< shade2/proc.hsp:875 	return ..
end

function Fishing.create_fish(fish_id, where, x, y)
   -- >>>>>>>> shade2/proc.hsp:878 	flt :item_create 0,fishId(fish):iSubName(ci)=fish ...
   local fish = data["elona.fish"]:ensure(fish_id)
   local item = Item.create(fish.item_id, x, y, {}, where)
   if item then
      item.params.fish_id = fish_id
      item.value = fish.value
      item.weight = fish.weight
   end
   return item
   -- <<<<<<<< shade2/proc.hsp:880 	iWeight(ci)=fishWeight(fish) ..
end

return Fishing
