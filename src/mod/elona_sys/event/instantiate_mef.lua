local Event = require("api.Event")
local Mef = require("api.Mef")

Event.register("base.on_mef_instantiated", "Connect mef events",
               function(mef)
                  if mef.proto.on_stepped_on then
                     mef:connect_self("elona_sys.on_mef_stepped_on",
                                      "Mef prototype on_stepped_on handler",
                                      mef.proto.on_stepped_on)
                  end
                  if mef.proto.on_stepped_off then
                     mef:connect_self("elona_sys.on_mef_stepped_off",
                                      "Mef prototype on_stepped_off handler",
                                      mef.proto.on_stepped_off)
                  end
                  if mef.proto.on_updated then
                     mef:connect_self("base.on_mef_updated",
                                      "Mef prototype on_update handler",
                                      mef.proto.on_updated)
                  end
                  if mef.proto.on_removed then
                     mef:connect_self("base.on_object_removed",
                                      "Mef prototype on_removed handler",
                                      mef.proto.on_removed)
                  end
               end,
               {priority = 10000})

local function mef_stepped_on_handler(chara, p, result)
   -- >>>>>>>> shade2/main.hsp:747 	if map(cX(tc),cY(tc),8)!0{ ..
   local mef = Mef.at(chara.x, chara.y, chara:current_map())
   if mef then
      mef:emit("elona_sys.on_mef_stepped_on", {chara=chara})
   end

   return result
   -- <<<<<<<< shade2/main.hsp:770 		} ..
end
Event.register("base.on_chara_pass_turn", "Mef stepped on behavior", mef_stepped_on_handler)

local function mef_stepped_off_handler(chara, p, result)
   local mef = Mef.at(chara.x, chara.y, chara:current_map())
   if mef then
      local inner_result = mef:emit("elona_sys.on_mef_stepped_off", {chara=chara})
      if inner_result and inner_result.blocked then
         return inner_result
      end
   end

   return result
end
Event.register("base.before_chara_moved", "Mef stepped off behavior", mef_stepped_off_handler)
