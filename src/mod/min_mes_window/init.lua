local Event = require("api.Event")
local Gui = require("api.Gui")

config["min_mes_window.enabled"] = true
config["min_mes_window.max_width"] = 400
config["min_mes_window.max_height"] = 72 * 2

local function mes_window_position(self, x, y, width, height)
   local w = config["min_mes_window.max_width"]
   local h = config["min_mes_window.max_height"]
   return x + 124, height - (h + 16), math.min(width - 124, w), h
end

local function setup_min_mes_window()
   local holder = Gui.hud_widget("hud_message_window")
   if config["min_mes_window.enabled"] then
      holder:set_position(mes_window_position)
   else
      holder:set_position(nil)
   end
end

Event.register("base.on_game_initialize", "Setup min_mes_window", setup_min_mes_window)
