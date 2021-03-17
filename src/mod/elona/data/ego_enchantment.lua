local ElonaItem = require("mod.elona.api.ElonaItem")

local function filter_armor(item)
   -- >>>>>>>> shade2/item_data.hsp:239 	if f=fltEncArmor 	: if range_fltArmor(a)=false:re ...
   return ElonaItem.is_armor(item)
   -- <<<<<<<< shade2/item_data.hsp:239 	if f=fltEncArmor 	: if range_fltArmor(a)=false:re ..
end

local function filter_accessory(item)
-- >>>>>>>> shade2/item_data.hsp:240 	if f=fltEncAccessory	: if range_fltAccessory(a)=f ...
   return ElonaItem.is_accessory(item)
-- <<<<<<<< shade2/item_data.hsp:240 	if f=fltEncAccessory	: if range_fltAccessory(a)=f ..
end

local function filter_general(item)
   -- >>>>>>>> shade2/item_data.hsp:241 	if f=fltEncGeneral	: if (range_fltArmor(a)=true)o ...
   return ElonaItem.is_equipment(item)
   -- <<<<<<<< shade2/item_data.hsp:241 	if f=fltEncGeneral	: if (range_fltArmor(a)=true)o ..
end

local function filter_specific_category(cat)
   -- >>>>>>>> shade2/item_data.hsp:242 	if a=f : return true : else: return false ...
   return function(item)
      return item:has_category(cat)
   end
   -- <<<<<<<< shade2/item_data.hsp:242 	if a=f : return true : else: return false ..
end

-- >>>>>>>> shade2/item_data.hsp:674 *item_egoInit ...
data:add {
   _type = "base.ego_enchantment",
   _id = "silence",

   level = 0,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.modify_skill", power = 100, params = { skill_id = "elona.stealth" } },
      { _id = "elona.prevent_tele", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "res_blind",

   level = 1,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.res_blind", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "res_confuse",

   level = 1,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.res_confuse", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "fire",

   level = 1,
   filter = filter_general,

   enchantments = {
      { _id = "elona.modify_resistance", power = 150, params = { element_id = "elona.fire" } },
      { _id = "elona.elemental_damage", power = 150, params = { element_id = "elona.fire" } }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "cold",

   level = 1,
   filter = filter_general,

   enchantments = {
      { _id = "elona.modify_resistance", power = 150, params = { element_id = "elona.cold" } },
      { _id = "elona.elemental_damage", power = 150, params = { element_id = "elona.cold" } }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "lightning",

   level = 1,
   filter = filter_general,

   enchantments = {
      { _id = "elona.modify_resistance", power = 150, params = { element_id = "elona.lightning" } },
      { _id = "elona.elemental_damage", power = 150, params = { element_id = "elona.lightning" } }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "healer",

   level = 1,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.modify_skill", power = 100, params = { skill_id = "elona.healing" } },
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "res_paralyze",

   level = 2,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.res_paralyze", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "res_fear",

   level = 0,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.res_fear", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "res_sleep",

   level = 0,
   filter = filter_accessory,

   enchantments = {
      { _id = "elona.res_sleep", power = 100 }
   }
}

data:add {
   _type = "base.ego_enchantment",
   _id = "defender",

   level = 3,
   filter = filter_specific_category("elona.equip_melee"),

   enchantments = {
      { _id = "elona.res_fire", power = 100 },
      { _id = "elona.res_cold", power = 100 },
      { _id = "elona.res_lightning", power = 100 }
   }
}

-- <<<<<<<< shade2/item_data.hsp:711 	egoEf=encRes(rsResFire),100,encRes(rsResCold),100 ..
