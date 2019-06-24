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

--- Separates one copy of this item from the stack. The new item will
--- have no owner, so it is the caller's responsibility to give it
--- one.
-- @treturn IItem
-- @retval_ownership nil
function IItem:separate_one()
   if self.amount <= 1 then
      return self
   end

   local separated = self:clone()
   separated.amount = 1
   self.amount = self.amount - 1

   return separated
end

--- Tries to move a given amount of this item to another location.
--- Returns the object if successful, nil otherwise. If unsuccessful,
--- no state is changed.
-- @tparam int amount
-- @tparam ILocation where
-- @tparam[opt] int x
-- @tparam[opt] int y
-- @treturn[1] IItem
-- @treturn[2] nil
-- @ownership self where
function IItem:move_some(amount, where, x, y)
   amount = math.clamp(amount, 0, self.amount)

   if amount == 0 then
      return self
   end

   if amount == self.amount then
      return where:take_object(self, x, y)
   end

   if not where:can_take_object(self, x, y) then
      return nil
   end

   local separated = self:separate_one()

   assert(where:take_object(separated, x ,y))

   return separated
end

return IItem
