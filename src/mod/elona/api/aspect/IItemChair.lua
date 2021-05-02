local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Gui = require("api.Gui")
local Prompt = require("api.gui.Prompt")

local IItemChair = class.interface("IItemChair",
                                  {
                                     chair_type = "string"
                                  },
                                  {
                                     IAspect,
                                     IItemUseable
                                  })

IItemChair.default_impl = "mod.elona.api.aspect.ItemChairAspect"

function IItemChair:localize_action()
   return "base:aspect._.elona.IItemChair.action_name"
end

function IItemChair:on_use(item, params)
   -- >>>>>>>> shade2/action.hsp:1793 	case effChair ...
   if item:current_map() == nil then
      Gui.mes("action.use.chair.needs_place_on_ground")
      return "player_turn_query"
   end

   local choices = {
      { text = "action.use.chair.choices.relax", index = 1 }
   }

   if self.chair_type ~= "my" then
      choices[#choices+1] = { text = "action.use.chair.choices.my_chair", index = 2 }
   end
   if self.chair_type ~= "guest" then
      choices[#choices+1] = { text = "action.use.chair.choices.guest_chair", index = 3 }
   end
   if self.chair_type ~= "ally" then
      choices[#choices+1] = { text = "action.use.chair.choices.ally_chair", index = 4 }
   end
   if self.chair_type ~= "free" then
      choices[#choices+1] = { text = "action.use.chair.choices.free_chair", index = 5 }
   end

   local result, canceled = Prompt:new(choices):query()

   if result and not canceled then
      if result.index == 1 then
         Gui.mes("action.use.chair.relax")
      elseif result.index == 2 then
         Gui.mes("action.use.chair.my_chair", item:build_name(1))
         self.chair_type = "my"
      elseif result.index == 3 then
         Gui.mes("action.use.chair.guest_chair", item:build_name(1))
         self.chair_type = "guest"
      elseif result.index == 4 then
         Gui.mes("action.use.chair.ally_chair", item:build_name(1))
         self.chair_type = "ally"
      elseif result.index == 5 then
         Gui.mes("action.use.chair.free_chair", item:build_name(1))
         self.chair_type = "free"
      end
   end
   -- <<<<<<<< shade2/action.hsp:1806 	swbreak ..
end

return IItemChair
