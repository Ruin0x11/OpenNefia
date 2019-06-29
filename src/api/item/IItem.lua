local IMapObject = require("api.IMapObject")
local IStackableObject = require("api.IStackableObject")
local IItemEnchantments = require("api.item.IItemEnchantments")
local field = require("game.field")

-- TODO: move out of api
local IItem = interface("IItem",
                         {},
                         {IStackableObject, IItemEnchantments})

function IItem:build()
   -- TODO remove and place in schema as defaults

   self.amount = self.amount or 1
   self.location = nil
   self.ownership = "none"

   local Rand = require("api.Rand")
   self.curse_state = Rand.choice({"cursed", "blessed", "none", "doomed"})
   self.identify_state = "completely"

   self.name = self._id

   self.weight = self.weight or 10
   self.dv = self.dv or 4
   self.pv = self.pv or 4
   self.hit_bonus = self.hit_bonus or 3
   self.damage_bonus = self.damage_bonus or 2
   self.bonus = self.bonus or 1

   self.flags = self.flags or {}
   self.types = self.types or {}

   -- item:send("base.on_item_create")
   IMapObject.init(self)
   IItemEnchantments.init(self)
end

function IItem:build_name(amount)
   amount = amount or self.amount

   local s = self.name
   if amount ~= 1 then
      s = string.format("%d %s", amount, self.name)
   end

   local b = self:calc("bonus")
   if b > 0 then
      s = s .. " +" .. b
   elseif b < 0 then
      s = s .. " " .. b
   end

   return s
end

function IItem:refresh()
   IMapObject.on_refresh(self)
   IItemEnchantments.on_refresh(self)

   if self:can_equip_at("base.hand") then
      self:mod("is_weapon", true)
   end
   if self:calc("dice_x") == 0 then
      self:mod("is_armor", true)
   end
end

function IItem:on_refresh()
end

function IItem:get_owning_chara()
   local IChara = require("api.chara.IChara")

   if is_an(IChara, self.location) then
      if self.location:has_item(self) then
         return self.location
      end
   end

   return nil
end

function IItem:produce_memory()
   return { image = self.image, color = {0, 0, 0} }
end

function IItem:is_blessed()
   return self:calc("curse_state") == "blessed"
end

function IItem:is_cursed()
   local curse_state = self:calc("curse_state")
   return curse_state == "cursed" or curse_state == "doomed"
end

function IItem:current_map()
   -- BUG: Needs to be generalized to allow nesting.
   local Chara = require("api.Chara")
   local chara = self:get_owning_chara()
   if Chara.is_alive(chara) then
      return chara:current_map()
   end

   return IMapObject.current_map(self)
end

function IItem:get_equip_slots()
   local base = self:calc("equip_slots") or {}

   return base
end

function IItem:can_equip_at(body_part_type)
   local equip_slots = self:get_equip_slots()
   if #equip_slots == 0 then
      return nil
   end

   local can_equip = table.set(equip_slots)

   return can_equip[body_part_type] == true
end

function IItem:copy_image()
   local _, _, item_atlas = require("internal.global.atlases").get()
   return item_atlas:copy_tile_image(self:calc("image"))
end

function IItem:has_type(_type)
   return self.types[_type] == true
end

function IItem:can_stack_with(other)
   -- TODO: this gets super complicated when adding new fields. There
   -- should be a way to specify a field will not have any effect on
   -- the stacking behavior between two objects.
   if not IStackableObject.can_stack_with(self, other) then
      return false
   end

   local ignored_fields = table.set {
      "uid",
      "amount"
   }

   for field, my_val in pairs(self) do
      if not ignored_fields[field] then
         local their_val = other[field]

         -- TODO: is_class, is_object
         local do_deepcompare = type(my_val) == "table"
            and my_val.__class == nil
            and my_val.uid == nil

         if do_deepcompare then
            if not table.deepcompare(my_val, their_val) then
               return false, field
            end
         else
            if my_val ~= their_val then
               return false, field
            end
         end
      end
   end

   return true
end

IItem.ui_color = function(self)
   if self:calc("flags").is_no_drop then
        return {120, 80, 0}
   end

   if self:calc("identify_state") == "completely" then
      local curse_state = self:calc("curse_state")
      if     curse_state == "doomed"  then return {100, 10, 100}
      elseif curse_state == "cursed"  then return {150, 10, 10}
      elseif curse_state == "none"    then return {10, 40, 120}
      elseif curse_state == "blessed" then return {10, 110, 30}
      end
   end

    return {0, 0, 0}
end

return IItem
