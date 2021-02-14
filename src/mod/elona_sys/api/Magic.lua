local Map = require("api.Map")
local Chara = require("api.Chara")
local IItem = require("api.item.IItem")
local IMapObject = require("api.IMapObject")
local Effect = require("mod.elona.api.Effect")
local Input = require("api.Input")
local Gui = require("api.Gui")
local Pos = require("api.Pos")
local Action = require("api.Action")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Enum = require("api.Enum")

local Magic = {}

local function calc_adjusted_power(magic, power, curse_state)
   if magic.alignment == "negative" then
      if curse_state == Enum.CurseState.Blessed then
         return 50
      elseif Effect.is_cursed(curse_state) then
         return power * 150 / 100
      end
   else
      if curse_state == Enum.CurseState.Blessed then
         return power * 150 / 100
      elseif Effect.is_cursed(curse_state) then
         return 50
      end
   end

   return power
end

-- Possible magic locations:
--   self (tgSelfOnly): only affects the caster
--   self_or_nearby (tgSelf): can affect the caster or someone nearby, but only if a wand is being used. fails if no
--     character on tile (heal, holy veil)
--   nearby (tgDirection): can affect the caster or someone nearby, fails if no character on tile (touch, steal,
--     dissasemble)
--   location (tgLocation): affects a ground position (web, create wall)
--   target_or_location (tgBoth): affects the currently targeted character or ground position (breaths, bolts)
--   enemy (tgEnemy): affects the currently targeted character, prompts if friendly (most attack magic)
--   other (tgOther): affects the currently targeted character (shadow step)
--   direction (tgDir): casts in a cardinal direction (teleport other)

--- @tparam id:base.skill skill_id
--- @tparam IChara caster
--- @tparam IChara ai_target
--- @tparam[opt] string triggered_by
--- @tparam[opt] boolean check_ranged_if_self
--- @treturn table
function Magic.get_ai_location(target_type, range, caster, triggered_by, ai_target, check_ranged_if_self)
   assert(target_type, "Skill does not support targeting")

   if target_type == "self_or_nearby" and triggered_by == "wand" then
      target_type = "nearby"
   end

   if target_type == "nearby" then
      if Pos.dist(ai_target.x, ai_target.y, caster.x, caster.y) > range then
         return false, {}
      end

      return true, {
         source = caster,
         target = ai_target
      }
   end

   if target_type == "location" then
      if not Map.has_los(caster.x, caster.y, ai_target.x, ai_target.y) then
         return false, {}
      end

      return true, {
         source = caster,
         target = ai_target,
         x = ai_target.x,
         y = ai_target.y,
      }
   end

   if target_type == "self" or target_type == "self_or_nearby" then
      -- This is a special case for ball magic, which prevents the AI from
      -- trying to cast it if its target will not be contained in the ball's
      -- radius.
      if check_ranged_if_self then
         if Pos.dist(caster.x, caster.y, ai_target.x, ai_target.y) > range
            or not Map.has_los(caster.x, caster.y, ai_target.x, ai_target.y)
         then
            return false, {}
         end
      end

      return true, {
         source = caster,
         target = caster
      }
   end

   if target_type == "enemy" or target_type == "other" or target_type == "target_or_location" then
      if Pos.dist(caster.x, caster.y, ai_target.x, ai_target.y) > range then
         Gui.mes_duplicate()
         Gui.mes("action.which_direction.out_of_range")
         return false, {}
      end

      if not Map.has_los(caster.x, caster.y, ai_target.x, ai_target.y) then
         return false, {}
      end

      return true, {
         source = caster,
         target = ai_target
      }
   end

   if target_type == "direction" then
      return true, {}
   end

   error(("Unknown skill target_type '%s'"):format(target_type))

   return false, {}
end

--- @tparam string target_type
--- @tparam uint range
--- @tparam IChara caster
--- @tparam[opt] string triggered_by
--- @treturn table
function Magic.prompt_magic_location(target_type, range, caster, triggered_by)
   -- >>>>>>>> shade2/proc.hsp:1561 *effect_selectTg ..
   assert(target_type, "Skill does not support targeting")

   local source = caster

   -- If the player waves a wand supporting targeting ("self_or_target"), allow
   -- them to pick a square with a character on it (e.g. rods of healing, rods
   -- of teleport). If the targeting type is "self", don't allow this (e.g. rods
   -- of wishing, rods of identify).
   if target_type == "self_or_nearby" and triggered_by == "wand" then
      target_type = "nearby"
   end

   if target_type == "nearby" then
         Gui.mes("action.which_direction.ask")
         local dir = Input.query_direction(caster)
         if dir == nil then
            return false, {}
         end
         local x, y = Pos.add_direction(dir, caster.x, caster.y)
         local target = Chara.at(x, y)
         if target == nil then
            return true, {
               no_effect = true,
               obvious = false
            }
         end

         return true, {
            source = caster,
            target = target
         }
   end

   -- The target location is set by Command.target() and is cleared at the start
   -- of the player's turn.
   local target_location = caster.target_location

   if target_type == "target_or_location" and target_location then
      if not Map.has_los(caster.x, caster.y, target_location.x, target_location.y) then
         Gui.mes("action.which_direction.cannot_see_location")
         return false, {
            obvious = false,
         }
      end

      return true, {
         source = caster,
         x = target_location.x,
         y = target_location.y
      }
   elseif target_type == "location" then
      local x, y = Input.query_position(caster)
      if not x then
         Gui.mes("action.which_direction.cannot_see_location")
         return false, {
            obvious = false,
         }
      end
      return true, {
         source = caster,
         target = Chara.at(x, y),
         x = x,
         y = y
      }
   end

   if target_type == "self" or target_type == "self_or_nearby" then
      return true, {
         source = caster,
         target = caster
      }
   end

   if target_type == "enemy" or target_type == "other" or target_type == "target_or_location" then
      local target = Action.find_target(caster)
      if target == nil then
         return false, {
            obvious = false,
         }
      end

      if target_type == "enemy" and caster:relation_towards(target) >= Enum.Relation.Neutral then
         if not ElonaAction.prompt_really_attack(caster, target) then
            return false, {
               obvious = false
            }
         end
      end

      if Pos.dist(caster.x, caster.y, target.x, target.y) > range then
         Gui.mes_duplicate()
         Gui.mes("action.which_direction.out_of_range")
         return false, {}
      end

      if not Map.has_los(caster.x, caster.y, target.x, target.y) then
         return false, {}
      end

      return true, {
         source = source,
         target = target
      }
   end

   if target_type == "direction" then
      if triggered_by == "spell" or triggered_by == "action" then
         Gui.mes("action.which_direction.spell")
      else
         Gui.mes("action.which_direction.wand")
      end

      local dir = Input.query_direction(caster)
      if dir == nil then
         Gui.mes("common.it_is_impossible")
         return false, {
            obvious = false
         }
      end

      local x, y = Pos.add_direction(dir, caster.x, caster.y)

      return true, {
         source = source,
         target = Chara.at(x, y),
         x = x,
         y = y
      }
   end

   error(("Unknown skill target_type '%s'"):format(target_type))

   return false, {}
   -- <<<<<<<< shade2/proc.hsp:1640 	return true ..
end

function Magic.get_magic_location(target_type, range, caster, triggered_by, ai_target, check_ranged_if_self, on_choose_cb)
   local success, result

   if on_choose_cb then
      success, result = on_choose_cb(target_type, range, caster, triggered_by, ai_target, check_ranged_if_self)
      if success ~= nil then
         return success, result
      end
   end

   if caster:is_player() then
      success, result = Magic.prompt_magic_location(target_type,
                                                    range,
                                                    caster,
                                                    triggered_by)
   else
      local target = caster:get_target()
      success, result = Magic.get_ai_location(target_type,
                                              range,
                                              caster,
                                              triggered_by,
                                              target,
                                              check_ranged_if_self)
   end

   return success, result
end


-- Casts a spell.
--
-- @tparam id:base.magic id
-- @tparam[opt] table params Magic parameters.
--  - power (int): Relative power of spell.
--  - source (IChara): Thing casting the spell.
--  - target (IChara): Target of the spell.
--  - item (IItem): Item used in the spell.
--  - triggered_by (string?): Affects targeting. One of "wand", "scroll",
--      "spell", "action", potion", "potion_thrown", "potion_spilt" or "trap".
--  - curse_state (string): Curse state affecting the spell.
--  - x (uint): Target map X position.
--  - y (uint): Target map Y position.
--  - element (id:base.element): Element the spell uses.
function Magic.cast(id, params)
   local magic = data["elona_sys.magic"]:ensure(id)
   params = params or {
      power = 0,
      source = nil,
      target = nil,
      item = nil,
      triggered_by = nil,
      curse_state = nil,
      x = nil,
      y = nil,
      range = nil
   }
   params.power = params.power or 0
   params.range = params.range or 1

   -- If no position is specified, first try to use the target's if
   -- one is provided, then the source.
   if class.is_an(IMapObject, params.target) then
      params.x = params.x or params.target.x
      params.y = params.y or params.target.y
   end
   if class.is_an(IMapObject, params.source) then
      params.x = params.x or params.source.x
      params.y = params.y or params.source.y
   end

   local curse_state = Enum.CurseState.Normal

   if class.is_an(IItem, params.item) then
      params.curse_state = params.curse_state or params.item:calc("curse_state")
   end
   params.curse_state = params.curse_state or Enum.CurseState.Normal

   params.power = calc_adjusted_power(magic, params.power, curse_state)

   local did_something, result = magic:cast(params)

   return did_something, result
end

function Magic.skills_for_magic(magic_id)
   if magic_id == nil then
      return nil
   end
   return data["base.skill"]:iter():filter(function(s) return s.effect_id == magic_id end):to_list()
end

return Magic
