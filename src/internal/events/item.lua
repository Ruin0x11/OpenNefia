local Event = require("api.Event")

local function update_container_weight(item)
   if item.proto.container_params and item.proto.container_params.combine_weight and item:is_item_container() then
      -- >>>>>>>> shade2/action.hsp:937 		if refWeight=falseM{ ...
      local get_weight = function(i) return i:calc("weight") end
      item.weight = item.proto.weight + item.inv:iter():map(get_weight):sum()
      local owner = item:get_owning_chara()
      if owner then
         owner:refresh_weight()
      end
      -- <<<<<<<< shade2/action.hsp:939 			} ..
   end
end

Event.register("base.after_container_receive_item", "Update container weight for combine_weight", update_container_weight)
Event.register("base.after_container_provide_item", "Update container weight for combine_weight", update_container_weight)
