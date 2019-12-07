local socket = require("socket")
local profile = require("thirdparty.profile")
local env = require("internal.env")
local Event = require("api.Event")

local Profile = {}

function Profile.hook_all()
   if true then
      return
   end
   profile.hookall()

   local apis = env.require_all_apis("api", true, true)
   apis = table.merge(apis, env.require_all_apis("internal", true, true))
   apis = table.merge(apis, env.require_all_apis("game"), true, true)
   apis = table.merge(apis, env.require_all_apis("mod/elona", true, true))
   apis = table.merge(apis, env.require_all_apis("mod/elona_sys", true, true))

   local no_hook = {
      "add_interface",
      "__tostring",
      "delegate"
   }
   local no_hook_apis = {
      "api.Draw",
      "api.gui.MouseHandler",
      "api.gui.KeyHandler",
      "api.gui.ReplLayer"
   }

   for name, tbl in pairs(apis) do
      if type(tbl) == "table" then
         for varname, var in pairs(tbl) do
            if type(var) == "function"
               and not no_hook[varname]
            then
               local name = ("%s.%s"):format(name, varname)
               profile.hook(var, name)
            end
         end
      end
   end

   for event_id, h in pairs(Event.global().hooks) do
      for _, cb in pairs(h.cbs) do
         local name = ("event:%s:%s"):format(event_id, cb.name)
         profile.hook(cb.cb, name)
      end
   end

   for _, name in ipairs(no_hook_apis) do
      local tbl = apis[name]
      if type(tbl) == "table" then
         for _, var in pairs(tbl) do
            if type(var) == "function" then
               profile.unhook(var)
            end
         end
      end
   end
end

function Profile.reset()
   profile.setclock(socket.gettime)
   profile.reset()
end

function Profile.start()
   profile.start()
end

function Profile.stop()
   profile.stop()
end

function Profile.report(kind)
   return profile.report(kind)
end

function Profile.run(cb, times, ...)
   Profile.start()

   for _ = 1, times or 1 do
      cb(...)
   end

   Profile.stop()

   return Profile.report(100)
end

return Profile
