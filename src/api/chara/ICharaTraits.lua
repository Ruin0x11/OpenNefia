local Gui = require("api.Gui")
local ICharaTraits = class.interface("ICharaTraits")

function ICharaTraits:init()
   self.traits = self.traits or {}
end

function ICharaTraits:has_trait(trait_id)
   data["base.trait"]:ensure(trait_id)
   return self.traits[trait_id]
end

function ICharaTraits:on_refresh()
   local remove = {}
   for trait_id, _ in pairs(self.traits) do
      local trait = data["base.trait"][trait_id]
      if not trait then
         Gui.report_error("No trait with ID " .. trait_id)
         remove[#remove+1] = trait_id
      end
   end

   for _, trait_id in ipairs(remove) do
      self.traits[trait_id] = nil
   end

   for trait_id, entry in pairs(self.traits) do
      local trait = data["base.trait"]:ensure(trait_id)
      if entry.level ~= 0 and trait.on_refresh then
         trait.on_refresh(self, entry.level)
      end
   end
end

return ICharaTraits
