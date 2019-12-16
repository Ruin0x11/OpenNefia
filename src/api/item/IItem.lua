local EquipSlots = require("api.EquipSlots")
local Event = require("api.Event")
local IItemEnchantments = require("api.item.IItemEnchantments")
local IMapObject = require("api.IMapObject")
local IObject = require("api.IObject")
local IOwned = require("api.IOwned")
local IModdable = require("api.IModdable")
local IEventEmitter = require("api.IEventEmitter")
local IStackableObject = require("api.IStackableObject")
local ILocalizable = require("api.ILocalizable")
local I18N = require("api.I18N")
local Log = require("api.Log")
local data = require("internal.data")

local IItem = class.interface("IItem",
                         {},
                         {IStackableObject, IModdable, IItemEnchantments, IEventEmitter, ILocalizable})

-- TODO: schema
local fallbacks = {
   amount = 1,
   dice_x = 0,
   dice_y = 0,
   ownership = "none",
   curse_state = "none",
   identify_state = "completely",
   weight = 0,
   dv = 0,
   pv = 0,
   hit_bonus = 0,
   damage_bonus = 0,
   bonus = 0,
   flags = {},
   name = "item",
   pierce_rate = 0,
   effective_range = {100, 20, 20, 20, 20, 20, 20, 20, 20, 20},
   ammo_type = "",
   value = 1,
   params = {},
   categories = {},

   cargo_weight = 0,

   rarity = 1000000
}

function IItem:pre_build()
   IModdable.init(self)
   IMapObject.init(self)
   IEventEmitter.init(self)
   IItemEnchantments.init(self)
end

function IItem:normal_build()
   self.location = nil

   self.name = self._id

   self:set_image()
end

function IItem:build()
   self:mod_base_with(fallbacks, "merge")

   self.name = I18N.get("item." .. self._id .. ".name")

   self:emit("base.on_build_item")

   self:refresh()
end

function IItem:instantiate()
   IObject.instantiate(self)
   self:emit("base.on_item_instantiated")
end

function IItem:set_image(image)
   if image then
      self.image = image
      local chip = data["base.chip"][self.image]
      self.y_offset = chip.y_offset
   else
      self.image = self.proto.image
      local chip = data["base.chip"][self.proto.image]
      if chip then
         self.y_offset = chip.y_offset
      end
   end
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

local function is_melee_weapon(item)
   return item:is_equipped()
      and not item:is_equipped_at("elona.ranged")
      and not item:is_equipped_at("elona.ammo")
      and item:calc("dice_x") > 0
end

local function is_ranged_weapon(item)
   return item:is_equipped()
      and item:is_equipped_at("elona.ranged")
end

local function is_ammo(item)
   return item:is_equipped()
      and item:is_equipped_at("elona.ammo")
end

function IItem:refresh()
   IModdable.on_refresh(self)
   IMapObject.on_refresh(self)
   IItemEnchantments.on_refresh(self)

   self:mod("is_melee_weapon", is_melee_weapon(self))
   self:mod("is_ranged_weapon", is_ranged_weapon(self))
   self:mod("is_ammo", is_ammo(self))
   self:mod("is_armor", self:calc("dice_x") == 0)
end

function IItem:on_refresh()
end

function IItem:get_owning_chara()
   local IChara = require("api.chara.IChara")

   if class.is_an(IChara, self.location) then
      if self.location:has_item(self) then
         return self.location
      end
   end

   return nil
end

function IItem:produce_memory()
   local shadow
   local is_tall = false
   local image = data["base.chip"][self.image]
   if image then
      shadow = image.shadow or shadow
   end

   return {
      uid = self.uid,
      show = require("api.Item").is_alive(self),
      image = (self.image or "") .. "#1",
      color = {0, 0, 0},
      x_offset = self:calc("x_offset") or 0,
      y_offset = self:calc("y_offset") or 0,
      shadow = shadow
   }
end

function IItem:produce_locale_data()
   return {
      name = self:build_name(),
      basename = self:calc("name"),
      amount = self.amount,
      is_visible = self:is_in_fov(),
   }
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
   if chara and chara.state == "alive" then
      return chara:current_map()
   end

   return IMapObject.current_map(self)
end

function IItem:can_equip_at(body_part_type)
   local equip_slots = self:calc("equip_slots") or {}
   if #equip_slots == 0 then
      return nil
   end

   local can_equip = table.set(equip_slots)

   return can_equip[body_part_type] == true
end

function IItem:is_equipped()
   return class.is_an(EquipSlots, self.location)
end

function IItem:is_equipped_at(body_part_type)
   if not self:is_equipped() then
      return false
   end

   local slot = self.location:equip_slot_of(self)

   return slot and slot.type == body_part_type
end

function IItem:remove_activity()
   if not self.chara_using then
      return
   end

   self.chara_using:remove_activity()
   self.chara_using = nil
end

function IItem:copy_image()
   local item_atlas = require("internal.global.atlases").get().item
   return item_atlas:copy_tile_image(self:calc("image") .. "#1")
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
      "amount",
      "temp",

      -- TODO: Compare event tables by event name, since those are
      -- uniquely idenfying.
      "_events",
      "global_events",
   }

   local ok, err = IEventEmitter.compare_events(self, other)
   if not ok then
      return err
   end

   for field, my_val in pairs(self) do
      if not ignored_fields[field] then
         local their_val = other[field]

         -- TODO: is_class, is_object
         local do_deepcompare = type(my_val) == "table"
            and type(their_val) == "table"
            and my_val.__class == nil
            and my_val.uid == nil

         if do_deepcompare then
            if not #my_val == #their_val then
               return false, field
            end
            Log.trace("Stack: deepcomparing %s", field)
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

function IItem:has_type(_type)
   for _, v in ipairs(self:calc("types")) do
      if v == _type then
         return true
      end
   end
   return false
end

function IItem:calc_effective_range(dist)
   dist = math.max(math.floor(dist), 0)
   local result
   local effective_range = self:calc("effective_range")
   if type(effective_range) == "function" then
      result = effective_range(self, dist)
      assert(type(result) == "number", "effective_range must return a number")
   elseif type(effective_range) == "table" then
      result = effective_range[dist]
      if not result then
         -- vanilla compat
         result = effective_range[math.min(dist, 9)]
      end
   elseif type(effective_range) == "number" then
      result = effective_range
   end
   return result or 100
end

function IItem:calc_ui_color()
   local color = self:calc("ui_color")
   if color then return color end

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

--- @overrides IOwned.remove_ownership
function IItem:remove()
   self.amount = 0

   local map = self:current_map()
   if map then
      map:refresh_tile(self.x, self.y)
   end
end

function IItem:has_category(cat)
   if type(cat) == "table" then
      for _, t in ipairs(cat) do
         assert(type(t) == "string")
         if self:has_type(t) then
            return true
         end
      end
   else
      for _, v in ipairs(self.categories) do
         if v == cat then
            return true
         end
      end
   end

   return false
end

return IItem
