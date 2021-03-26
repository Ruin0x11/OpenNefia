local Item = require("api.Item")
local global = require("mod.smithing.internal.global")
local Smithing = require("mod.smithing.api.Smithing")

local function find_hammer(player)
   return player:iter_items():filter(function(i) return i._id == "smithing.blacksmith_hammer" end):nth(1)
end

data:add {
   _type = "simple_indicators.indicator",
   _id = "hammer_level",

   render = function(player)
      -- >>>>>>>> oomSEST/src/net.hsp:896 			if (hammerNoPlus@st > 0) { ...
      if not Item.is_alive(global.tracked_hammer)
         or not player:has_item(global.tracked_hammer)
      then
         global.tracked_hammer = nil
      end

      if global.tracked_hammer == nil then
         global.tracked_hammer = find_hammer(player)
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

   render = function(player)
      -- >>>>>>>> oomSEST/src/net.hsp:914 			if (length(spsIntervals) == 0) { ...
      local skin_sum = fun.wrap(global.sps_intervals:iter()):sum()
      if skin_sum > 0 then
         local sps = skin_sum / 1000.0
         return ("SPS:%.03f"):format(sps)
      end
      -- <<<<<<<< oomSEST/src/net.hsp:926 			} ..
   end
}
