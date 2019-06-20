local IOwned = require("api.IOwned")

local IMapObject = interface("IMapObject",
                             {
                                uid = "number",
                                x = "number",
                                y = "number",
                                build = "function",
                                refresh = "function"
                             },
                             IOwned)

--- Obtains a property or calls a function to compute something.
function IMapObject:calc(key, ...)
   if self[key] ~= nil then
      local can_call = type(self[key]) == "function"
      if can_call then
         return self[key](...)
      else
         return self[key]
      end
   else
      return nil
   end
end

function IMapObject:set_pos(x, y)
   local map = self.map

   if not map or not map:exists(self) then
      Log.warn("IMapObject.set_pos: Not setting position of %s to %d,%d\n\t%s", tostring(self), x, y, debug.traceback(""))
      return false
   end

   if not self.map:is_in_bounds(x, y) then
      return false
   end

   self.map:move_object(self, x, y)

   return true
end

function IMapObject:move(dx, dy)
   return self:set_pos(self.x + dx, self.y + dy)
end

return IMapObject
