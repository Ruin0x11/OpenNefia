local IItemSeed = require("mod.elona.api.aspect.IItemSeed")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Gardening = require("mod.elona.api.Gardening")

local ItemSeedAspect = class.class("ItemSeedAspect", { IItemSeed, IItemUseable })

function ItemSeedAspect:init(item, params)
   self.plant_id = params.plant_id
end

function ItemSeedAspect:on_use(item, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..
   if Gardening.plant_seed(item, params.chara) then
      return "turn_end"
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..
end

return ItemSeedAspect
