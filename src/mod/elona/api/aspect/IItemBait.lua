local IAspect = require("api.IAspect")
local IItemDippable = require("mod.elona.api.aspect.IItemDippable")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local I18N = require("api.I18N")
local IItemInittable = require("mod.elona.api.aspect.IItemInittable")
local Gui = require("api.Gui")
local IItemFishingPole = require("mod.elona.api.aspect.IItemFishingPole")
local Rand = require("api.Rand")

local IItemBait = class.interface("IItemBait", {
                                     bait_type = { type = "string", optional = true }
                                                         },
                                       {
                                          IAspect,
                                          IItemDippable,
                                          IItemInittable,
                                          IItemLocalizableExtra
                                       })

IItemBait.default_impl = "mod.elona.api.aspect.ItemBaitAspect"

function IItemBait:localize_action()
   return "base:aspect._.elona.IItemBait.action_name"
end

function IItemBait:on_init_params(item, params)
   -- >>>>>>>> shade2/item.hsp:638:DONE 	if iId(ci)=idBite{ ..
   self.bait_type = self.bait_type or Rand.choice(data["elona.bait"]:iter())._id

   local proto = data["elona.bait"]:ensure(self.bait_type)
   item.image = proto.image or item.image

   item.value = proto.value or proto.rank * proto.rank * 500 + 200
   -- <<<<<<<< shade2/item.hsp:642 		} ..
end

function IItemBait:can_dip_into(item, target_item)
   return target_item:get_aspect(IItemFishingPole)
end

function IItemBait:calc_bait_amount(item)
   return Rand.rnd(10) + 15
end

function IItemBait:on_dip_into(item, params)
   -- >>>>>>>> shade2/action.hsp:1600 	if iId(ciDip)=idBite{	 ...
   local target_item = params.target_item
   target_item = target_item:separate()
   item:remove(1)
   Gui.play_sound("base.equip1")
   Gui.mes("action.dip.result.bait_attachment", target_item:build_name(), item:build_name(1))

   local pole = target_item:get_aspect(IItemFishingPole)
   local bait_type = assert(self:calc(item, "bait_type"))

   if pole.bait_type == bait_type then
      pole.bait_amount = pole.bait_amount + self:calc_bait_amount(item)
   else
      pole.bait_amount = self:calc_bait_amount(item)
      pole.bait_type = bait_type
   end

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1605 		} ..
end

function IItemBait:localize_extra(s, item)
   local bait_name = I18N.localize("elona.bait", self:calc(item, "bait_type"), "name")
   return I18N.get("base:aspect._.elona.IItemBait.title", s, bait_name)
end

return IItemBait
