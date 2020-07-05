--- @interface IMapObject

local IOwned = require("api.IOwned")
local IObject = require("api.IObject")
local Log = require("api.Log")

-- An IObject that can be displayed on a tilemap.
local IMapObject  = class.interface("IMapObject",
                             {
                                x = "number",
                                y = "number",
                                produce_memory = "function"
                             },
                             {IOwned, IObject})

function IMapObject:init()
   IObject.init(self)

   self.x = 0
   self.y = 0
end

--- Refreshes this map object.
function IMapObject:on_refresh()
   local map = self:current_map()
   if map then
      map:refresh_tile(self.x, self.y)
   end
end

--- Sets the position of this map object.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] bool force
--- @treturn bool true if succeeded
function IMapObject:set_pos(x, y, force)
   local location = self.location

   assert(location:has_object(self))

   if not location:is_in_bounds(x, y) then
      return false
   end

   local old_x, old_y = self.x, self.y

   location:move_object(self, x, y)

   if location.refresh_tile then
      location:refresh_tile(old_x, old_y)
      location:refresh_tile(x, y)
   end

   return true
end

--- @tparam int dx
--- @tparam int dy
function IMapObject:move(dx, dy)
   return self:set_pos(self.x + dx, self.y + dy)
end

--- Returns the current map this object is contained in, if any.
---
--- @treturn[opt] InstancedMap
function IMapObject:current_map()
   local InstancedMap = require("api.InstancedMap")
   if class.is_an(InstancedMap, self.location) then
      return self.location
   end

   return nil
end

--- @treturn bool
function IMapObject:is_in_fov()
   local map = self:current_map()
   if not map then
      return false
   end

   return map:is_in_fov(self.x, self.y)
end

--- @treturn bool
function IMapObject:has_los(from_x, from_y)
   local map = self:current_map()
   if not map then
      return false
   end

   return map:has_los(from_x, from_y, self.x, self.y)
end

--- Produces the data used to display this object in a draw layer.
--- Each draw layer is intended to interpret this data differently
--- depending on what drawing logic is needed.
---
--- @treturn[opt] table
function IMapObject:produce_memory()
   return nil
end

--- @function IMapObject.refresh
--- @inherits IObject.refresh

return IMapObject
