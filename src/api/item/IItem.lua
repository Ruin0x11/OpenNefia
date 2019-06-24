local field = require("game.field")
local IMapObject = require("api.IMapObject")

-- TODO: move out of api
local IItem = interface("IItem",
                         {},
                         {
                            IMapObject,
                         })

function IItem:build()
   -- TODO remove and place in schema as defaults

   self.amount = self.amount or 1
   self.location = nil
   self.ownership = "none"

   local Rand = require("api.Rand")
   self.curse_state = Rand.choice({"cursed", "blessed", "none", "doomed"})
   self.identify_state = "completely"

   self.flags = {}

   self.name = self._id
   self.weight = 10

   self.types = {}

   -- item:send("base.on_item_create")
end

function IItem:build_name()
   if self.amount == 1 then
      return self.name
   end

   return string.format("%d %s", self.amount, self.name)
end

function IItem:refresh()
   self.temp = {}
end

function IItem:get_equip_slots()
   local base = self:calc("equip_slots") or {}

   return base
end

function IItem:copy_image()
   local _, _, item_atlas = require("internal.global.atlases").get()
   return item_atlas:copy_tile_image(self.image)
end

function IItem:has_type(_type)
   return self.types[_type] == true
end

--- Separates some of this item from its stack. If `owned` is true,
--- also attempts to move the item into the original item's location.
--- If this fails, return nil. If unsuccessful, no state is changed.
-- @tparam int amount
-- @tparam bool owned
-- @treturn IItem
-- @retval_ownership[owned=false] nil
-- @retval_ownership[owned=true] self.location
function IItem:separate(amount, owned)
   amount = math.clamp(amount or 1, 0, self.amount)
   owned = owned or false

   if amount == 0 then
      return nil
   end

   if self.amount <= 1 or amount >= self.amount then
      return self
   end

   local separated = self:clone(owned)

   if separated == nil then
      return nil
   end

   separated.amount = amount
   self.amount = self.amount - amount
   assert(self.amount >= 1)

   return separated
end

--- Tries to move a given amount of this item to another location,
--- accounting for item stacking. Returns the stacked item if
--- successful, nil otherwise. If unsuccessful, no state is changed.
-- @tparam int amount
-- @tparam ILocation where
-- @tparam[opt] int x
-- @tparam[opt] int y
-- @treturn[1] IItem
-- @treturn[2] nil
-- @retval_ownership self where
function IItem:move_some(amount, where, x, y)
   local separated = self:separate(amount)

   if not where:can_take_object(separated, x, y) then
      separated:remove_ownership()
      return nil
   end

   assert(where:take_object(separated, x ,y))

   return separated
end

return IItem
