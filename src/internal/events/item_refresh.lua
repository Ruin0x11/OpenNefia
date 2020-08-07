local Event = require("api.Event")

local function update_ammo(item)
   -- >>>>>>>> elona122/shade2/item_data.hsp:758 	if refType=fltAmmo : iAmmo(ci)=falseM ..
   if item:can_equip_at("elona.ammo") then
      item.params.ammo_loaded = nil
   end
   -- <<<<<<<< elona122/shade2/item_data.hsp:758 	if refType=fltAmmo : iAmmo(ci)=falseM ..
end

Event.register("base.on_item_add_enchantment", "Update ammo after add enchantment", update_ammo)
Event.register("base.on_item_remove_enchantment", "Update ammo after remove enchantment", update_ammo)
