local Item = require("api.Item")
local Gui = require("api.Gui")
local Log = require("api.Log")
local ElonaMagic = require("mod.elona.api.ElonaMagic")

local Shortcut = {}

function Shortcut.iter()
   return fun.iter_pairs(save.elona.shortcuts)
end

function Shortcut.get(index)
   return save.elona.shortcuts[index]
end

--- Causes the same behavior as selecting the given item in a given
--- inventory context. The item must be contained in the inventory's
--- sources and be selectable.
---
--- @tparam IItem item
--- @tparam string operation
--- @tparam[opt] table params
--- @treturn[opt] IItem non-nil on success
--- @treturn[opt] string error
function Shortcut.activate_item_shortcut(item, operation, params, rest)
   if not Item.is_alive(item) then
      return nil, nil, "item_dead"
   end

   local proto = data["elona_sys.inventory_proto"]:ensure(operation)

   params = params or {}
   params.chara = params.chara or item:get_owning_chara() or nil
   params.map = (params.chara and params.chara:current_map()) or nil

   local InventoryContext = require("api.gui.menu.InventoryContext")
   local ctxt = InventoryContext:new(proto, params)

   local turn_result, err = ctxt:on_shortcut(item)
   if turn_result ~= nil then
      return nil, err, "on_shortcut"
   end

   local ok
   ok, err = ctxt:filter(item)
   if not ok then
      return nil, err, "filter"
   end

   turn_result = ctxt:after_filter({item})
   if turn_result ~= nil then
      return nil, nil, "after_filter"
   end

   ok, err = ctxt:can_select(item)
   if not ok then
      return nil, err, "can_select"
   end

   ok, err = ctxt:on_select(item, nil, rest or nil)
   return ok, err, "on_select"
end

local function shortcut_item(player, sc)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:50222 *label_1283 ...
   local item_id = sc.item_id
   local inv_proto_id = sc.inventory_proto_id
   local curse_state = sc.curse_state

   local filter = function(item)
      if item._id ~= item_id then
         return false
      end

      if config.elona.item_shortcuts_respect_curse_state then
         if item:calc("curse_state") ~= curse_state then
            return false
         end
      end

      if (item.proto.charge_level or 0) > 0 and item.charges <= 0 then
         return false
      end

      return true
   end

   -- BUG: needs to take items on the ground into consideration
   local rest = player:iter_items():filter(filter)
   local found = rest:nth(1)

   if not Item.is_alive(found) then
      Gui.mes("ui.inv.common.does_not_exist")
      return "player_turn_query"
   end

   local result, err, cb_name = Shortcut.activate_item_shortcut(found, inv_proto_id, { chara = player }, rest)

   if not result then
      err = err or "action.shortcut.cannot_use_anymore"
      Gui.mes(err)
      Log.debug("Could not run shortcut for %s, %s: %s", item_id, inv_proto_id, cb_name)
      return "player_turn_query"
   end

   if result == "inventory_continue"
      or result == "inventory_cancel"
   then
      result = "player_turn_query"
   end

   return result
   -- <<<<<<<< oomSEST/src/southtyris.hsp:50268 	} ..
end

local function shortcut_skill(player, sc)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:45589 		efid = ogdata(36 + sc) ...
   local skill_id = sc.skill_id
   local skill_proto = data["base.skill"][skill_id]
   if skill_proto == nil then
      Gui.error("Missing shortcut skill ID %s", skill_id)
      Gui.mes("action.shortcut.cannot_use_anymore")
      return "player_turn_query"
   end

   local map = player:current_map()
   if map and map:has_type("world_map") then
      Gui.mes("action.cannot_do_in_global")
      return "player_turn_query"
   end

   if not player:has_skill(skill_id) then
      Gui.mes("action.shortcut.cannot_use_anymore")
      return "player_turn_query"
   end

   if skill_proto.type == "skill_action" or skill_proto.type == "action" then
      local did_something = ElonaMagic.do_action(skill_id, player)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   elseif skill_proto.type == "spell" then
      if (player.spell_stocks[skill_id] or 0) <= 0 then
         Gui.mes_duplicate()
         Gui.mes("action.shortcut.cannot_use_spell_anymore")
         return "player_turn_query"
      end

      local did_something = ElonaMagic.cast_spell(skill_id, player, false)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   end

   Gui.error("Cannot activate shortcut for skill %s (%s)", skill_id, skill_proto.type)
   return "player_turn_query"
   -- <<<<<<<< oomSEST/src/southtyris.hsp:45682 	goto *label_1623 ..
end

function Shortcut.assign_skill_shortcut(index, skill_id)
   local sc = {
      type = "skill",
      skill_id = skill_id
   }

   local scs_equal = function(sc, other_sc)
      return sc.type == other_sc.type
         and sc.skill_id == other_sc.skill_id
   end

   local other = save.elona.shortcuts[index]
   if other and scs_equal(sc, other) then
      save.elona.shortcuts[index] = nil
      return "unassign"
   end

   for other_index, other_sc in pairs(save.elona.shortcuts) do
      if scs_equal(sc, other_sc) then
         save.elona.shortcuts[other_index] = nil
      end
   end

   save.elona.shortcuts[index] = sc
   return "assign"
end

function Shortcut.assign_item_shortcut(index, item_id, inventory_proto_id, curse_state)
   local sc = {
      type = "item",
      item_id = item_id,
      inventory_proto_id = inventory_proto_id,
      curse_state = curse_state
   }

   local scs_equal = function(sc, other_sc)
      return sc.type == other_sc.type
         and sc.item_id == other_sc.item_id
         and sc.inventory_proto_id == other_sc.inventory_proto_id
         and (not config.elona.item_shortcuts_respect_curse_state or sc.curse_state == other_sc.curse_state)
   end

   local other = save.elona.shortcuts[index]
   if other and scs_equal(sc, other) then
      save.elona.shortcuts[index] = nil
      return "unassign"
   end

   for other_index, other_sc in pairs(save.elona.shortcuts) do
      if scs_equal(sc, other_sc) then
         save.elona.shortcuts[other_index] = nil
      end
   end

   save.elona.shortcuts[index] = sc
   return "assign"
end

function Shortcut.activate(player, sc)
   if sc.type == "item" then
      return shortcut_item(player, sc)
   elseif sc.type == "skill" then
      return shortcut_skill(player, sc)
   end

   Log.error("Unknown shortcut type %s", sc.type)
   return "player_turn_query"
end

return Shortcut
