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
local Item = require("api.Item")
local Feat = require("api.Feat")
local Map = require("api.Map")
local Pos = require("api.Pos")
local I18N = require("api.I18N")
local save = require("internal.global.save")

local Action = {}

local function item_on_cell_text(x, y)
   local items = Item.at(x, y):to_list()
   if #items == 0 then
      return nil
   end

   if #items > 4 then
      return I18N.get("action.move.item_on_cell.more_than_three", #items)
   end

   local mes = ""
   for i, v in ipairs(items) do
      if i > 1 then
         mes = mes .. I18N.get("misc.and")
      end
      mes = mes .. v:build_name()
   end

   local own_state = items[1].own_state
   if own_state == "none" then
      return I18N.get("action.move.item_on_cell.item", mes)
   elseif own_state == "shelter" then
      return I18N.get("action.move.item_on_cell.building", mes)
   else
      return I18N.get("action.move.item_on_cell.not_owned", mes)
   end
end

Event.register("base.on_chara_moved", "Item on cell text", function(chara)
   if chara:is_player() then
      local text = item_on_cell_text(chara.x, chara.y)
      if text then
         Gui.mes(text)
      end
   end
end)

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
                     params.chara:refresh_weight()
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
      chara:refresh_weight()
      return true
   end

   return false
end

--- @tparam IChara chara
--- @tparam IItem item
--- @tparam[opt] int amount
--- @treturn bool success
function Action.get_from_container(chara, item, amount)
   return item:emit("base.on_get_item", {chara=chara,amount=amount,source=item.location}, false)
end

--- @tparam ILocation container
--- @tparam IItem item
--- @tparam[opt] int amount
--- @treturn bool success
function Action.put_in_container(container, item, amount)
   if item == nil then
      return false
   end

   item:emit("base.on_put_item", {amount=amount,target=container}, false)

   local success = item:move_some(amount, container)
   if success then
      Gui.play_sound(Rand.choice({"base.get1", "base.get2"}))
      Gui.mes("action.pick_up.put_in_container", item:build_name(amount))
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

function Action.target_level_text(chara, target)
   local clvl = chara:calc("level")
   local tlvl = target:calc("level")
   local key

   if     clvl * 20  < tlvl then key = 10
   elseif clvl * 10  < tlvl then key = 9
   elseif clvl * 5   < tlvl then key = 8
   elseif clvl * 3   < tlvl then key = 7
   elseif clvl * 2   < tlvl then key = 6
   elseif clvl * 3/2 < tlvl then key = 5
   elseif clvl       < tlvl then key = 4
   elseif clvl / 3*2 < tlvl then key = 3
   elseif clvl / 2   < tlvl then key = 2
   elseif clvl / 3   < tlvl then key = 1
   else                          key = 0
   end

   return I18N.get("action.target.level._" .. key, target)
end

function Action.target_item_text(chara, item)
   return "TODO item"
end

function Action.target_feat_text(chara, feat)
   return "TODO feat"
end

function Action.target_text(chara, x, y, visible_only)
   local text = {}

   if visible_only and (not Map.has_los(chara.x, chara.y, x, y)
                           or Pos.dist(chara.x, chara.y, x, y) > chara:calc("fov") / 2)
   then
      text[#text+1] = I18N.get("action.target.out_of_sight")
      return text, false
   end

   local target = Chara.at(x, y)
   if target and target:calc("can_target") then
      local dist = Pos.dist(chara.x, chara.y, target.x, target.y)
      text[#text+1] = Action.target_level_text(chara, target)
      text[#text+1] = I18N.get("action.target.you_are_targeting", target, dist)
   end

   local item = Item.at(x, y):nth(1)
   if item then
      text[#text+1] = Action.target_item_text(item)
   end

   local feat = Feat.at(x, y):nth(1)
   if feat then
      text[#text+1] = Action.target_feat_text(feat)
   end

   return text, true
end

function Action.build_target_list(chara)
   local filter = function(other)
      if chara ~= other and other:is_in_fov() then
         local consider = true
         if chara:is_allied() then
            if other:is_player() then
               consider = false
            end
         end

         if not chara:has_los(other.x, other.y) then
            consider = false
         end

         if not chara:calc("can_target") then
            consider = false
         end

         if consider then
            return true
         end
      end

      return false
   end

   local targets = Chara.iter():filter(filter):to_list()

   -- Sort by closeness to the targeting character.
   local sort = function(a, b)
      return Pos.dist(chara.x, chara.y, a.x, a.y) < Pos.dist(chara.x, chara.y, b.x, b.y)
   end

   table.sort(targets, sort)

   return targets
end

function Action.find_target(chara)
   local target = chara:get_target()
   if target == nil or not Chara.is_alive(target) or not target:is_in_fov() then
      chara:set_target(nil)
   end

   target = chara:get_target()
   if target == nil then
      local targets = Action.build_target_list(chara)
      local filter = function(other)
         return chara:reaction_towards(other) < 0
      end
      target = fun.iter(targets):filter(filter):nth(1)
      if target then
         chara:set_target(target)
      end
   end

   target = chara:get_target()
   if target == nil or chara:has_effect("elona.blindness") then
      if chara:is_player() then
         Gui.mes("action.ranged.no_target")
      end
      return nil
   end

   return target
end

return Action
