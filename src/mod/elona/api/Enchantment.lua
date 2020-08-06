local InstancedEnchantment = require("api.item.InstancedEnchantment")
local I18N = require("api.I18N")

local Enchantment = {}

function Enchantment.create(_id, power, item, opts)
   -- >>>>>>>> shade2/item_data.hsp:538 	#deffunc encAdd int id,int EncOrg,int EncPorg,int ..
   opts = opts or {}

   local enc = InstancedEnchantment:new(_id, power, {})

   if not opts.force then
      if enc.proto.categories and #enc.proto.categories > 0 then
         local found
         for _, cat in ipairs(enc.proto.categories or {}) do
            if item:has_category(cat) then
               found = true
               break
            end
         end
         if not found then
            return nil, "wrong_category"
         end
      end
      if item:has_category("elona.equip_ammo") then
         if not opts.is_from_material then
            return nil, "ammo_enchantment_not_from_material"
         end
      end
   end

   local result = enc:on_generate(item, { curse_power = opts.curse_power or 0 })
   if result and result.skip then
      return nil, "skipped_by_on_generate_callback"
   end
   -- <<<<<<<< shade2/item_data.hsp:554 	if enc<encHeadNormal{ ..

   return enc
end

function Enchantment.power_text(grade)
   grade = math.abs(grade)
   local grade_str = I18N.get("enchantment.level")
   local s = ""
   for i = 1, grade + 1 do
      if i > 4 then
         s = s .. "+"
         break
      end
      s = s .. grade_str
   end
   return s
end

return Enchantment
