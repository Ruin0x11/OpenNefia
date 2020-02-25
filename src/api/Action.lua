-- General-purpose logic that is meant to be shared by the PC and all
-- NPCs. These functions obey game rules such as curse state for
-- unequipping items. Each function will return two values, a boolean
-- indicating if the action was successful and a string indicating any
-- errors.
-- @module Action

local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Pos = require("api.Pos")
local save = require("internal.global.save")

local Action = {}

--- @tparam IChara chara
--- @tparam int x
--- @tparam int y
--- @treturn bool success
function Action.move(chara, x, y)
   local params = {
      prev_x = chara.x,
      prev_y = chara.y,
      x = x,
      y = y
   }

   -- EVENT: before_character_movement
   -- ally direction
   -- solid feats (doors, jail cell)
   -- proc currently standing mef
   -- proc world map weather events
   local result = chara:emit("base.before_chara_moved", params, {blocked=false})
   if result.blocked then
      return false
   end

   chara.direction = Pos.pack_direction(Pos.direction_in(chara.x, chara.y, x, y))

   if not Map.can_access(x, y, chara:current_map()) then
      return false
   end

   chara:set_pos(x, y)

   chara:emit("base.on_chara_moved", params)
   -- EVENT: on_character_movement
   -- mount update
   -- proc trap
   -- proc teleport trap
   --   The original code jumps back before Chara.set_pos and
   --   re-procs everything including traps on the newly
   --   teleported-to position.


   -- EVENT: after_character_movement
   local function sense_map_feats_on_move()
      if chara:is_player() then
         save.base.player_pos_on_map_leave = nil
      end
   end
   sense_map_feats_on_move()
   -- proc water
   -- sense feats
   -- proc world map encounters
   --   how to handle entering a new map here? defer it?

   return true
end

Event.register("base.on_get_item", "Pick up item",
               function(item, params, result)
                  if not Item.is_alive(item) then
                     return result
                  end

                  params.amount = params.amount or item.amount
                  local picked_up = params.chara:take_item(item, params.amount)
                  if picked_up then
                     Gui.mes("action.pick_up.execute", params.chara, item:build_name(params.amount))
                     Gui.play_sound(Rand.choice({"base.get1", "base.get2"}), params.chara.x, params.chara.y)
                     return picked_up
                  end

                  if params.chara:is_player() then
                     Gui.mes("action.get.cannot_carry")
                  end

                  return false
               end)

--- @tparam IChara chara
--- @tparam IItem item
--- @tparam[opt] int amount
--- @treturn bool success
function Action.get(chara, item, amount)
   if item == nil then
      local items = Item.at(chara.x, chara.y):to_list()
      if #items == 0 then
         Gui.mes("action.get.air")
         return false
      end
      item = items[#items]
   end

   return item:emit("base.on_get_item", {chara=chara,amount=amount}, false)
end

--- @tparam IChara chara
--- @tparam IItem item
--- @tparam[opt] int amount
--- @treturn bool success
function Action.drop(chara, item, amount)
   if item == nil then
      return false
   end

   local dropped = chara:drop_item(item, amount)
   if dropped then
      Gui.mes("action.drop.execute", item:build_name(amount))
      Gui.play_sound("base.drop1", chara.x, chara.y)
      return true
   end

   return false
end

local hook = function(name, f) return f end

local can_unequip = hook("can_unequip",
                         function(item)
                            if item:is_cursed() then
                               return false, "cursed"
                            end

                            return true
                         end
)

--- @tparam IChara chara
--- @tparam IItem item
--- @treturn bool success
--- @treturn[opt] string error
function Action.unequip(chara, item)
   if not chara:has_item_equipped(item) then
      return false, "not_equipped_by_chara"
   end

   local able, reason = can_unequip(item)
   if not able then
      return able,reason
   end

   chara:unequip_item(item)
   chara:refresh()
   Gui.play_sound("base.equip1");

   return true
end

--- @tparam IChara chara
--- @tparam IItem item
--- @treturn bool success
--- @treturn[opt] string error
function Action.equip(chara, item)
   if not chara:has_item(item) then
      return false, "not_owned_by_chara"
   end

   chara:equip_item(item)
   chara:refresh()
   Gui.play_sound("base.equip1");

   return true
end

--- @tparam IChara chara
--- @tparam IChara target
--- @treturn bool success
--- @treturn[opt] string error
function Action.melee(chara, target)
   target:damage_hp(Rand.rnd(10), chara, {})
   return true
end

return Action
