-- >>>>>>>> shade2/item_data.hsp:714 	egoMinorN(0)	=lang("唄う","singing"),lang("召使の","se ...
local EGO_MINOR = {
   "singing",
   "servants",
   "followers",
   "howling",
   "glowing",
   "conspicuous",
   "magical",
   "enchanted",
   "mighty",
   "trustworthy",
}

for _, ego_minor_id in ipairs(EGO_MINOR) do
   data:add {
      _type = "base.ego_minor_enchantment",
      _id = ego_minor_id
   }
end
-- <<<<<<<< shade2/item_data.hsp:716 	maxEgoMinorN=length(egoMinorN) ..
