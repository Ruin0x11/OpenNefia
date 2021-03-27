local Item = require("api.Item")
local global = require("mod.smithing.internal.global")
local Smithing = require("mod.smithing.api.Smithing")

data:add {
   _type = "simple_indicators.indicator",
   _id = "hammer_level",

   ordering = 1000000,

   render = function(player)
      -- >>>>>>>> oomSEST/src/net.hsp:896 			if (hammerNoPlus@st > 0) { ...
      if not Item.is_alive(global.tracked_hammer)
         or not player:has_item(global.tracked_hammer)
      then
         global.tracked_hammer = nil
      end

      if global.tracked_hammer == nil then
         global.tracked_hammer = player:find_item("smithing.blacksmith_hammer")
      end

      if Item.is_alive(global.tracked_hammer) then
         local hammer = global.tracked_hammer
         local level = hammer.params.hammer_level
         local exp = hammer.params.hammer_experience
         local req_exp = Smithing.calc_hammer_required_exp(hammer)
         local exp_perc = (exp * 100.0) / req_exp
         return ("HLv:%d/%3.3f%%"):format(level, exp_perc)
      end
      -- <<<<<<<< oomSEST/src/net.hsp:911 			} ..
   end
}

data:add {
   _type = "simple_indicators.indicator",
   _id = "sps",

   ordering = 1001000,

   render = function(player)
      -- >>>>>>>> oomSEST/src/net.hsp:914 			if (length(spsIntervals) == 0) { ...
      local skin_sum = fun.wrap(global.sps_intervals:iter()):sum()
      if skin_sum > 0 then
         local sps = 100.0 / skin_sum
         return ("SPS:%.03f"):format(sps)
      end
      -- <<<<<<<< oomSEST/src/net.hsp:926 			} ..
   end
}
