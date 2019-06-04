local Input = require("api.Input")
local Chara = require("api.Chara")

local Pos = require("api.Pos")
local Chara = require("api.Chara")

-- General-purpose logic that is meant to be shared by the PC and all
-- NPCs.
local Action = {}

function Action.move(chara, x, y)
   if type(x) == "string" then
      x, y = Pos.add_direction(x, chara.x, chara.y)
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

   return "ContinueTurn"
end

return Action
