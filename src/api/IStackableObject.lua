--- @classmod IStackableObject
local Gui = require("api.Gui")

local IOwned = require("api.IOwned")
local IMapObject = require("api.IMapObject")

local IStackableObject = class.interface("IStackableObject",
                                 {
                                    amount = "number",
                                    can_stack_with = "function",
                                 },
                                 {IOwned, IMapObject}
)

--- Separates some of this object from its stack. If `owned` is true,
--- also attempts to move the object into the original object's
--- location. If this fails, return nil. If unsuccessful, no state is
--- changed. Returns the separated item.
-- @tparam int amount Default 1
-- @tparam bool owned Default true
-- @treturn IItem
-- @retval_ownership[owned=false] nil
-- @retval_ownership[owned=true] self.location
function IStackableObject:separate(amount, owned)
   amount = math.clamp(amount or 1, 0, self.amount)
   owned = owned or true

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

--- Stacks this object with `other`. Afterwards, deletes `other`.
---
--- @tparam IStackableObject other
function IStackableObject:stack_with(other)
   assert(self._type == other._type)

   self.amount = self.amount + other.amount
   other.amount = 0
   other:remove_ownership()
end

--- Returns true if this object can be stacked with `other`.
---
--- @tparam IStackableObject other
--- @treturn bool
function IStackableObject:can_stack_with(other)
   if not class.is_an(IStackableObject, other) then
      return false
   end
   return self._type == other._type
      and self.uid ~= other.uid
      and self.location == other.location
end

--- Stacks this object with other objects in the same location that
--- can be stacked with. The logic to determine if one object can be
--- stacked with another is controlled by
--- IStackableObject:can_stack_with().
-- @treturn bool
function IStackableObject:stack(show_message)
   local iter
   local did_stack = false

   local location = self:get_location()
   if not location then
      return false
   end

   if location:is_positional() then
      -- HACK: really needs a uniform interface. type may need to be a
      -- required parameter.
      iter = location:iter_type_at_pos(self._type, self.x, self.y)
   else
      iter = location:iter()
   end

   for _, other in iter:unwrap() do
      local can_stack, err = self:can_stack_with(other)
      if can_stack then
         self:stack_with(other)
         did_stack = true
      end
   end

   if did_stack and show_message then
      Gui.mes("item.stacked", self:build_name(1), self.amount)
   end

   return did_stack
end

--- Tries to move a given amount of this object to another location,
--- accounting for stacking unless `no_stack` is true. Returns the
--- stacked object if successful, nil otherwise. If unsuccessful, no
--- state is changed.
-- @tparam int amount
-- @tparam ILocation where
-- @tparam[opt] int x
-- @tparam[opt] int y
-- @tparam[opt] bool no_stack
-- @treturn[1] IItem
-- @treturn[2] nil
-- @retval_ownership self where
function IStackableObject:move_some(amount, where, x, y)
   amount = amount or self.amount
   local separated = self:separate(amount, false)

   if separated == nil then
      return nil
   end

   if not where:can_take_object(separated, x, y) then
      self:stack_with(separated)
      return nil
   end

   assert(where:take_object(separated, x, y))

   return separated
end

return IStackableObject
