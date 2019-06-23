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
      return false
   end

   -- EVENT: before_character_movement
   -- ally direction
   -- solid feats (doors, jail cell)
   -- proc currently standing mef
   -- proc world map weather events

   chara.last_move_direction = Pos.pack_direction(Pos.direction_in(chara.x, chara.y, x, y))

   chara:set_pos(x, y)

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

   return true
end

function Action.get(chara, item)
   if item == nil then
      local items = Item.at(chara.x, chara.y):to_list()
      if #items == 0 then
         Gui.mes(chara.uid .. " grasps at air.")
         return false
      end
      item = items[#items]
   end

   local picked_up = chara:take_item(item)
   if picked_up then
      Gui.mes(chara.uid .. " picks up " .. item.uid)
      return true
   end

   return false
end

function Action.melee(chara, target)
   target:damage_hp(1, chara, { damage_text_type = "damage" })
   return true
end

return Action
