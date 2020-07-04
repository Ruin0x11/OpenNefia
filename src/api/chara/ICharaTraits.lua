local Gui = require("api.Gui")
local ICharaTraits = class.interface("ICharaTraits")
local I18N = require("api.I18N")
local data = require("internal.data")

function ICharaTraits:init()
   self.traits = self.traits or {}
end

function ICharaTraits:has_trait(trait_id)
   data["base.trait"]:ensure(trait_id)
   return self.traits[trait_id] and self.traits[trait_id].level ~= 0
end

function ICharaTraits:trait_level(trait_id)
   data["base.trait"]:ensure(trait_id)
   local trait = self.traits[trait_id]
   if trait == nil then
      return 0
   end
   return trait.level
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
         trait.on_refresh(entry, self)
      end
   end
end

function ICharaTraits:increment_trait(trait_id, no_message)
   local trait = data["base.trait"]:ensure(trait_id)

   if self.traits[trait_id] == nil then
      self.traits[trait_id] = { level = 0 }
   elseif self.traits[trait_id].level >= trait.level_max then
      return false
   end

   if self.traits[trait_id].level < trait.level_max then
      self.traits[trait_id].level = self.traits[trait_id].level + 1

      if not no_message then
         if I18N.get_optional("trait." .. trait_id .. ".on_gain_level") then
            Gui.mes_c("trait." .. trait_id .. ".on_gain_level", "Green")
         end
      end

      if self.traits[trait_id].level == 0 then
         self.traits[trait_id] = nil
      end
   end

   return true
end

function ICharaTraits:decrement_trait(trait_id, no_message)
   local trait = data["base.trait"]:ensure(trait_id)

   if self.traits[trait_id] == nil then
      self.traits[trait_id] = { level = 0 }
   elseif self.traits[trait_id].level <= trait.level_min then
      return false
   end

   self.traits[trait_id].level = self.traits[trait_id].level - 1

   if not no_message then
      if I18N.get_optional("trait." .. trait_id .. ".on_lose_level") then
         Gui.mes_c("trait." .. trait_id .. ".on_lose_level", "Red")
      end
   end

   if self.traits[trait_id].level == 0 then
      self.traits[trait_id] = nil
   end

   return true
end

return ICharaTraits
