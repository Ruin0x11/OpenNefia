--- @module ObjectContainer

local ILocation = require("api.ILocation")
local pool = require("internal.pool")

local ObjectContainer = class.class("ObjectContainer", ILocation)

--- @tparam string ty
function ObjectContainer:init(ty)
   self.pool = pool:new(ty, 1, 1)
end

--
-- ILocation impl
--

ObjectContainer:delegate("pool",
                   {
                      "move_object",
                      "objects_at_pos",
                      "get_object",
                      "has_object",
                      "remove_object",
                      "iter"
                   })

function ObjectContainer:is_positional()
   return false
end

function ObjectContainer:is_in_bounds(x, y)
   return true
end

function ObjectContainer:remove_object(obj)
   return self.pool:remove_object(obj)
end

function ObjectContainer:can_take_object(obj)
   return true
end

function ObjectContainer:take_object(obj)
   if not self.pool:take_object(obj) then
      return nil, "cannot_own"
   end

   return obj, nil
end

return ObjectContainer
