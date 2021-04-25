local Event = require("api.Event")
local Log = require("api.Log")
local AquesTalk = require("mod.aquestalk.api.AquesTalk")
local MeCab = require("mod.aquestalk.api.MeCab")

require("mod.aquestalk.data.init")
require("mod.aquestalk.event.init")

local function aquestalk_init()
   local ok, err = MeCab.init()

   if ok then
      Log.info("Initialized MeCab.")
   else
      Log.warn("MeCab failed to initialize, so AquesTalk.speak() will be disabled.")
      Log.debug("%s", err)
   end

   ok, err = AquesTalk.init()

   if ok then
      Log.info("Initialized AquesTalk.")
   else
      Log.warn("AquesTalk failed to initialize, so it will be disabled.")
      Log.debug("%s", err)
   end
end
Event.register("base.on_engine_init", "Aquestalk initialize", aquestalk_init)
