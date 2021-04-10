local config = require("internal.config")
local Const = require("api.Const")
local Enum = require("api.Enum")
local I18N = require("api.I18N")
local Event = require("api.Event")


-- >>>>>>>> shade2/command.hsp:4108 		if iMaterial(ci)!0		:list(0,p)=7:listN(0,p)=lang ..
local quality_info = {
   {
      pred = function(i)
         return i:calc("material") ~= nil
      end,
      desc = function(i)
         return I18N.get("item.desc.it_is_made_of", "item_material." .. i:calc("material") .. ".name")
      end
   },
   {
      pred = function(i)
         return i:calc("material") == "elona.ether"
      end,
      desc = "item.desc.speeds_up_ether_disease"
   },
   {
      pred = function(i)
         return i:calc("is_acidproof")
      end,
      desc = "item.desc.bit.acidproof"
   },
   {
      pred = function(i)
         return i:calc("is_fireproof")
      end,
      desc = "item.desc.bit.fireproof"
   },
   {
      pred = function(i)
         return i:calc("is_precious")
      end,
      desc = "item.desc.bit.precious"
   },
   {
      pred = function(i)
         return i:calc("is_blessed_by_ehekatl")
      end,
      desc = "item.desc.bit.blessed_by_ehekatl"
   },
   {
      pred = function(i)
         return i:calc("is_stolen")
      end,
      desc = "item.desc.bit.stolen"
   },
   {
      pred = function(i)
         return i:calc("is_living")
      end,
      desc = function(i)
         -- TODO living weapon
         local growth = 0
         local experience = 0
         local s = I18N.get("item.desc.bit.alive") .. " " .. I18N.get("item.desc.living_weapon", growth, experience)
         return s
      end
   },
   {
      pred = function(i)
         return i:calc("is_showroom_only")
      end,
      desc = "item.desc.bit.showroom_only"
   },
   {
      pred = function(i)
         return i:calc("is_handmade")
      end,
      desc = "item.desc.bit.handmade"
   },
   {
      pred = function(i)
         return i:calc("is_living") and config.base.development_mode
      end,
      desc = function(i)
         -- TODO living weapon
         local experience = 0
         local required_experience = 0
         return ("Exp:%d Next:%d"):format(experience, required_experience)
      end
   },
   {
      pred = function(i)
         return i:calc("dice_x") > 0
      end,
      desc = function(i)
         local dice_x = i:calc("dice_x")
         local dice_y = i:calc("dice_y")
         local pierce_rate = i:calc("pierce_rate")
         local s = I18N.get("item.desc.weapon.it_can_be_wielded")
         if i:calc("identify_state") >= Enum.IdentifyState.Full then
            s = s .. I18N.get("item.desc.weapon.dice", dice_x, dice_y, pierce_rate)
         end
         return s
      end
   },
   {
      pred = function(i)
         return i:calc("dice_x") > 0 and i:calc("weight") <= Const.WEAPON_WEIGHT_LIGHT
      end,
      desc = "item.desc.weapon.light",
      icon = 5
   },
   {
      pred = function(i)
         return i:calc("dice_x") > 0 and i:calc("weight") >= Const.WEAPON_WEIGHT_HEAVY
      end,
      desc = "item.desc.weapon.heavy",
      icon = 5
   },
   {
      pred = function(i)
         return i:calc("identify_state") >= Enum.IdentifyState.Full
            and (i:calc("hit_bonus") > 0 or i:calc("damage_bonus") > 0)
      end,
      desc = function(i)
         return I18N.get("item.desc.bonus", i:calc("hit_bonus"), i:calc("damage_bonus"))
      end,
      icon = 5
   },
   {
      pred = function(i)
         return i:calc("identify_state") >= Enum.IdentifyState.Full
            and (i:calc("dv") > 0 or i:calc("pv") > 0)
      end,
      desc = function(i)
         return I18N.get("item.desc.dv_pv", i:calc("dv"), i:calc("pv"))
      end,
      icon = 6
   },
}
-- <<<<<<<< shade2/command.hsp:4131 		if (iPV(ci)!0) or (iDV(ci)!0)	:list(0,p)=6:listN ..

local function build_description(item, _, result)
   result = result or {}

   -- >>>>>>>> shade2/command.hsp:4100 	dbId=iID(ci):dbMode=dbModeRef:gosub *db_item ..
   if item:calc("identify_state") >= Enum.IdentifyState.Full then
      local desc = I18N.localize_optional("base.item", item._id, "desc.main.text")
      if desc then
         result[#result+1] = { text = I18N.capitalize(desc) }
      end
   end
   -- <<<<<<<< shade2/command.hsp:4105 	} ..

   -- >>>>>>>> shade2/command.hsp:4107 	if iKnown(ci)>=knownQuality{ ..
   if item:calc("identify_state") >= Enum.IdentifyState.Quality then
      for _, entry in ipairs(quality_info) do
         if entry.pred(item) then
            local new = {}
            if type(entry.desc) == "string" then
               new.text = I18N.get(entry.desc)
            elseif type(entry.desc) == "function" then
               new.text = entry.desc(item)
            else
               error(type(entry.desc))
            end
            new.icon = entry.icon or 7
            if entry.color then
               new.color = table.deepcopy(entry.color)
            end
            result[#result+1] = new
         end
      end
   else
      result[#result+1] = { text = I18N.get("item.desc.have_to_identify") }
   end
   -- <<<<<<<< shade2/command.hsp:4136 	} ..

   -- >>>>>>>> shade2/command.hsp:4137 	if iKnown(ci)>=knownFull{ ..
   if item:calc("identify_state") >= Enum.IdentifyState.Full then
      for _, merged_enc in item:iter_merged_enchantments() do
         local enc_desc
         if merged_enc.proto.localize then
            enc_desc = merged_enc.proto.localize(merged_enc.total_power, merged_enc.params, item)
         else
            enc_desc = I18N.get("_.base.enchantment." .. merged_enc._id .. ".description")
         end

         local icon = merged_enc.proto.icon or 4
         local color = merged_enc.proto.color or {80, 50, 0}
         local alignment = merged_enc.proto.alignment
         if type(alignment) == "function" then
            alignment = alignment(merged_enc.total_power, merged_enc.params)
         end
         if alignment == "negative" then
            color = {180, 0, 0}
            icon = 9
         end
         result[#result+1] = { text = I18N.get("enchantment.it", enc_desc), icon = icon, color = color, is_inheritable = merged_enc.is_inheritable }
      end

      if item:calc("is_eternal_force") then
         result[#result+1] = { text = I18N.get("item.desc.bit.eternal_force"), icon = 4, color = {80, 50, 0} }
      end
   end
   -- <<<<<<<< elona122/shade2/command.hsp:4148 			} ..

   return result
end

Event.register("base.on_item_build_description", "Build description", build_description, {priority = 50000})

local function add_flavor_text(item, params, result)
   -- >>>>>>>> elona122/shade2/command.hsp:4150 		 ..
   if item:calc("identify_state") < Enum.IdentifyState.Full then
      return result
   end

   -- NOTE: unused in vanilla
   local show_footnote = false
   if show_footnote then
      local footnote = I18N.localize_optional("base.item", item._id, "desc.main.footnote")
      if footnote then
         result[#result+1] = { text = "" }
         result[#result+1] = { text = footnote, type = "flavor_italic" }
      end
   end

   local i = 0
   repeat
      local extra_desc = I18N.localize_optional("base.item", item._id, "desc._" .. i .. ".text")
      if extra_desc then
         result[#result+1] = { text = "" }
         result[#result+1] = { text = extra_desc, type = "flavor" }
      end
      local extra_footnote = I18N.localize_optional("base.item", item._id, "desc._" .. i .. ".footnote")
      if extra_footnote then
         result[#result+1] = { text = extra_footnote, type = "flavor_italic" }
      end
      i = i + 1
   until extra_desc == nil
   -- <<<<<<<< shade2/command.hsp:4199 	} ..
end

Event.register("base.on_item_build_description", "Add flavor text", add_flavor_text, {priority = 150000})
