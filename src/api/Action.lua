local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Pos = require("api.Pos")

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

   chara.last_move_direction = Pos.pack_direction(Pos.direction_in(chara.x, chara.y, x, y))

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

function Action.get(chara, item)
   if item == nil then
      local items = Item.at(chara.x, chara.y)
      if #items == 0 then
         Gui.mes(chara.uid .. " grasps at air.")
         return "turn_end"
      end
      item = items[#items]
   end

   local picked_up = Chara.receive_item(chara, item)
   if picked_up then
      Gui.mes(chara.uid .. " picks up " .. item.uid)
      return "turn_end"
   end

   return "turn_end"
end

function Action.melee(chara, target)
   Chara.damage_hp(target, 1, chara, { damage_text_type = "damage" })
   return "turn_end"
end

return Action
