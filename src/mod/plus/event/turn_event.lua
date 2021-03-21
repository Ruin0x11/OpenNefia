local Const = require("api.Const")
local Gui = require("api.Gui")
local Event = require("api.Event")

local function play_hunger_sound(chara, params, result)
   if not chara:is_player() then
      return result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < Const.HUNGER_THRESHOLD_HUNGRY then
      if nutrition < Const.HUNGER_THRESHOLD_STARVING then
         if not chara:has_activity("elona.eating") then
            -- >>>>>>>> custom-1.90.4/source-utf8.hsp:186010 					snd SOUNDLIST_FIZZLE ...
            Gui.play_sound("base.fizzle")
            -- <<<<<<<< custom-1.90.4/source-utf8.hsp:186010 					snd SOUNDLIST_FIZZLE ..
         end
      end
   end
end
Event.register("base.on_chara_turn_end", "Play hunger warning sound", play_hunger_sound)
