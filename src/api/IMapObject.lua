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

function IMapObject:on_refresh()
   local map = self:current_map()
   if map then
      map:refresh_tile(self.x, self.y)
   end
end

function IMapObject:set_pos(x, y, force)
   local location = self.location

   assert(location:has_object(self))

   if not location:is_in_bounds(x, y) and not force then
      Log.warn("IMapObject.set_pos: Not setting position of %s to %d,%d\n\t%s", tostring(self), x, y, debug.traceback(""))
      return false
   end

   location:move_object(self, x, y)

   return true
end
function IMapObject:move(dx, dy)
   return self:set_pos(self.x + dx, self.y + dy)
end

function IMapObject:current_map()
   local InstancedMap = require("api.InstancedMap")
   if class.is_an(InstancedMap, self.location) then
      return self.location
   end

   return nil
end

--- Produces the data used to display this object in a draw layer.
--- Each draw layer is intended to interpret this data differently
--- depending on what drawing logic is needed.
function IMapObject:produce_memory()
   return nil
end

return IMapObject
