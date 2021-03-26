local Event = require("api.Event")
local Autopickup = require("mod.autopickup.api.Autopickup")
local Gui = require("api.Gui")

local function proc_autopickup(chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:67707 		if (map(x, y, 4) != 0) { ...
   if not config.autopickup.enabled then
      return
   end

   if not chara:is_player() then
      return
   end

   if not chara:has_effect("elona.blindness") then
      local map = chara:current_map()
      -- TODO data extension, prevent autopickup in certain map archetypes
      if not map:has_type("player_owned") and map._archetype ~= "elona.shelter" then
         if not Gui.is_modifier_held("ctrl") then
            Autopickup.run(chara)
         end
      end
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:67722 		} ..
end
Event.register("base.on_chara_moved", "Proc autopickup", proc_autopickup)
