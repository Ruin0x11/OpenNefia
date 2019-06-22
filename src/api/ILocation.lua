local ILocation = interface("ILocation",
                 {
                    is_positional = "function",
                    move_object = "function",
                    remove_object = "function",
                    take_object = "function",
                    put_into = "function",
                    objects_at_pos = "function",

                    get_object = "function",
                    has_object = "function",
                    can_take_object = "function",
                    iter_objects = "function",
                 })

function ILocation:object_list(ordering)
   local list = {}
   for _, o in self:iter_objects(ordering) do
      list[#list+1] = o
   end
   return list
end

--- Attempts to take ownership of map object. This function may fail.
--- If it fails, no state in the location is expected to be changed.
--- Returns the map object on success or nil on failure.
-- @function take_object
-- @tparam ILocation self
-- @tparam IMapObject obj
-- @treturn[1] IMapObject obj
-- @treturn[2] nil

return ILocation
