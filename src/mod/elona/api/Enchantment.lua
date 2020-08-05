local I18N = require("api.I18N")

local Enchantment = {}

function Enchantment.create(_id, power, item, opts)
   -- >>>>>>>> shade2/item_data.hsp:538 	#deffunc encAdd int id,int EncOrg,int EncPorg,int ..
   opts = opts or {}
   local enc_data = data["base.enchantment"]:ensure(_id)

   local enc = {
      _id = _id,
      power = power,
      params = {}
   }

   if not opts.force then
      if enc.data_categories and #enc_data.categories > 0 then
         local found
         for _, cat in ipairs(enc_data.categories or {}) do
            if item:has_category(cat) then
               found = true
               break
            end
         end
         if not found then
            return nil
         end
      end
      if item:has_category("elona.equip_ammo") then
         if not opts.is_from_material then
            return nil
         end
      end
   end

   if enc_data.on_generate then
      local result = enc_data.on_generate(enc, item, { curse_power = opts.curse_power or 0 })
      if result and result.skip then
         return nil
      end
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
