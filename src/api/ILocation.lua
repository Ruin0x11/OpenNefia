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
                    iter_objects = "function",
                 })

function ILocation:object_list(ordering)
   local list = {}
   for _, o in self:iter_objects(ordering) do
      list[#list+1] = o
   end
   return list
end

return ILocation
