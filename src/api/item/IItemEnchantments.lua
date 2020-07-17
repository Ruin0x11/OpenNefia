local IObject = require("api.IObject")
local OEnchantment = require("api.OEnchantment")

local IItemEnchantments = class.interface("IItemEnchantments", {}, IObject)

function IItemEnchantments:init()
   local enchantments = {}

   -- for _, enc in ipairs(self.enchantments or {}) do
   --    enchantments[#enchantments+1] = OEnchantment:create(enc)
   -- end

   self.enchantments = enchantments
end

local function apply_enchantment(item, enc)
   enc:on_apply(item)

   local delta = enc:calc("item")
   if delta then
      local method = enc:calc("item_method") or "add"
      for k, v in pairs(delta) do
         item:mod(k, v, method)
      end
   end
end

function IItemEnchantments:on_refresh()
   for _, enc in ipairs(self.enchantments) do
      enc:refresh()

      apply_enchantment(self, enc)
   end
end

function IItemEnchantments:has_enchantment(id)
   -- TODO enchantment
   return false
end

function IItemEnchantments:apply_enchantments_to_wielder(wielder)
   for _, enc in ipairs(self.enchantments) do
      enc:when_wielding(wielder)

      local delta = enc:calc("wielder")
      if delta then
         local method = enc:calc("wielder_method") or "add"
         for k, v in pairs(delta) do
            wielder:mod(k, v, method)
         end
      end
   end
end

function IItemEnchantments:add_enchantment(enc, no_merge)
   if type(enc) == "string" then
      enc = OEnchantment:create(enc)
   end

   if not no_merge then
      for _, other in ipairs(self.enchantments) do
         if other:can_merge(enc) then
            other:on_merge(enc)
            return
         end
      end
   end

   table.insert(self.enchantments, enc)
   enc:on_add(self)
   enc:refresh()
   self:refresh()

   return self
end

function IItemEnchantments:remove_enchantment(enc)
   table.iremove_value(self.enchantments, enc)
   enc:on_remove(self)
   self:refresh()
end

return IItemEnchantments
