local Input = require("api.Input")
local Chara = require("api.Chara")

local Pos = require("api.Pos")
local Map = require("api.Map")

-- General-purpose logic that is meant to be shared by the PC and all
-- NPCs.
local Action = {}

function Action.move(chara, x, y)
   if not Map.can_access(x, y) then
      return "turn_end"
   end

   -- EVENT: before_character_movement
   -- ally direction
   -- solid feats (doors, jail cell)
   -- proc currently standing mef
   -- proc world map weather events

   Chara.set_pos(chara, x, y)

   -- EVENT: on_character_movement
   -- mount update
   -- proc trap
   -- proc teleport trap
   --   The original code jumps back before Chara.set_pos and
   --   re-procs everything including traps on the newly
   --   teleported-to position.

   -- EVENT: after_character_movement
   -- proc water
   -- sense feats
   -- proc world map encounters
   --   how to handle entering a new map here? defer it?

   return "turn_end"
end

return Action
