local field = require("game.field")
local field_logic = require("game.field_logic")
local Gui = require("api.Gui")
local Log = require("api.Log")

local util = {}

function util.load_game()
   Log.info("Attempting to start the game headlessly.")

   field.is_active = false
   field_logic.quickstart()
   field_logic.setup()
   field.is_active = true
   Gui.update_screen() -- refresh shadows/FOV
end

function util.pass_turn(turns)
   if not field.player then
      error("field not active")
   end

   turns = turns or 1
   local ev = "turn_begin"
   local target_chara, going

   local cb = function()
      for i=1,turns do
         Gui.mes(string.format("==== turn %d ====", i))
         repeat
            going, ev, target_chara = field_logic.run_one_event(ev, target_chara)
         until ev == "player_turn_query"

         ev = "turn_end"

         repeat
            going, ev, target_chara = field_logic.run_one_event(ev, target_chara)
         until ev == "turn_begin"
      end

      return going, ev, target_chara
   end

   local co = coroutine.create(cb)
   local ok, err = coroutine.resume(co, 0)
   if not ok or err ~= nil then
      if type(err) == "string" then
         error("\n\t" .. (err or "Unknown error."))
      end
   end
end

return util
