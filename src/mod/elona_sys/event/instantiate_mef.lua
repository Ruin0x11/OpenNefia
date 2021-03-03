local Event = require("api.Event")
local Mef = require("api.Mef")

local actions = {
   "stepped_on",  -- on_stepped_on,  elona_sys.on_mef_stepped_on
   "stepped_off", -- on_stepped_off, elona_sys.on_mef_stepped_off
   { action_name = "updated", event_id = "base.on_mef_updated" },
   { action_name = "removed", event_id = "base.on_object_removed" }
}

local function connect_mef_events(obj)
   if obj._type ~= "base.mef" then
      return
   end

   local mef = obj

   for _, action in ipairs(actions) do
      local event_id
      local action_name
      if type(action) == "table" then
         action_name = assert(action.action_name)
         event_id = assert(action.event_id)
      else
         assert(type(action) == "string")
         action_name = action
         event_id = ("elona_sys.on_mef_%s"):format(action)
      end

      local callback_name = ("on_%s"):format(action_name)
      local event_name = ("Mef prototype %s handler"):format(callback_name)

      -- If a handler is left over from previous instantiation
      if mef:has_event_handler(event_id, event_name) then
         mef:disconnect_self(event_id, event_name)
      end

      if mef.proto[callback_name] then
         mef:connect_self(event_id, event_name, mef.proto[callback_name])
      end
   end
end
Event.register("base.on_object_prototype_changed", "Connect mef events", connect_mef_events)

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
