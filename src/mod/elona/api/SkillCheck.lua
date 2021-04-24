local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")
local Rand = require("api.Rand")
local Pos = require("api.Pos")
local Item = require("api.Item")
local Input = require("api.Input")

local SkillCheck = {}

function SkillCheck.try_to_reveal(chara)
   local skill = chara:skill_level("elona.detection") * 15 + 20 + chara:skill_level("elona.stat_perception")
   local dungeon = chara:current_map():calc("level") * 8 + 60
   return Rand.rnd(skill) > Rand.rnd(dungeon)
end

function SkillCheck.proc_control_magic(source, target, damage)
   if source:has_skill("elona.control_magic") and source:is_in_same_party(target) then
      local level = source:skill_level("elona.control_magic")
      if level * 5 > Rand.rnd(damage+1) then
         damage = 0
      else
         damage = Rand.rnd(damage * 100 / (100 + level * 10) + 1)
      end

      if damage < 1 then
         return "success", damage
      end

      return "attempted", damage
   end

   return nil, damage
end

function SkillCheck.handle_control_magic(source, target, damage)
   local stat, damage = SkillCheck.proc_control_magic(source, target, damage)

   if stat == "success" then
      Gui.mes_visible("misc.spell_passes_through", target.x, target.y, target)
      Skill.gain_skill_exp(source, "elona.control_magic", 8, 4)
      return true, damage
   elseif stat == "attempted" then
      Skill.gain_skill_exp(source, "elona.control_magic", 30, 2)
      return false, damage
   else
      return false, damage
   end
end

function SkillCheck.is_floating(chara)
   return chara:calc("is_floating") and not chara:has_effect("elona.gravity")
end

local function is_in_square(cx, cy, tx, ty, radius)
   return cx > tx - radius and cx < tx + radius and cy > ty - radius and cy < ty + radius
end

function SkillCheck.try_to_perceive(target, perceiver)
   -- >>>>>>>> shade2/calculation.hsp:1141 *calcStealth ...
   local radius = 8
   if is_in_square(target.x, target.y, perceiver.x, perceiver.y, radius) then
      if perceiver:get_aggro(target) > 0 then
         return true
      end
      local chance = Pos.dist(target.x, target.y, perceiver.x, perceiver.y) * 150 + target:skill_level("elona.stealth") + 100 + 150 + 1
      if Rand.rnd(chance) < Rand.rnd(perceiver:skill_level("elona.stat_perception") * 60 + 150) then
         return true
      end
   end

   if target.noise and target.noise > 0 and Rand.rnd(150) < target.noise then
      return true
   end

   return false
   -- <<<<<<<< shade2/calculation.hsp:1149 	return false ..
end

--- @hsp *lockpick
function SkillCheck.try_to_lockpick(chara, difficulty)
   difficulty = difficulty or 0

   -- >>>>>>>> shade2/action.hsp:861 *lockpick ...
   while true do
      local lockpick = chara:iter_inventory()
         :filter(function(i) return Item.is_alive(i) and i._id == "elona.lockpick" end)
         :nth(1)

      if not lockpick then
         Gui.mes("action.unlock.do_not_have_lockpicks")
         return false
      end

      Gui.mes("action.unlock.use_lockpick")
      Gui.play_sound("base.locked1")

      local skeleton_key = chara:iter_inventory()
         :filter(function(i) return Item.is_alive(i) and i._id == "elona.skeleton_key" end)
         :nth(1)

      local power
      if skeleton_key then
         power = chara:skill_level("elona.lock_picking") * 150 / 100 + 5
         Gui.mes("action.unlock.use_skeleton_key")
      else
         power = chara:skill_level("elona.lock_picking")
      end

      local failed = false
      if power * 2 < difficulty then
         Gui.mes("action.unlock.too_difficult")
         failed = true
      elseif power / 2 >= difficulty then
         Gui.mes("action.unlock.easy")
      elseif Rand.rnd(Rand.rnd(power * 2)+1) < difficulty then
         Gui.mes("action.unlock.fail")
         failed = true
      end

      if failed then
         if Rand.one_in(3) then
            Gui.mes("action.unlock.lockpick_breaks")
            lockpick:remove(1)
         end
         Gui.mes("action.unlock.try_again")
         if not Input.yes_no() then
            return false
         end
      else
         break
      end
   end

   Gui.mes("action.unlock.succeed")
   Skill.gain_skill_exp(chara, "elona.lock_picking", 100)
   return true
   -- <<<<<<<< shade2/action.hsp:886 	return true ..
end

function SkillCheck.try_to_open_door(chara, door)
   -- TODO jail
   -- TODO move to aspect
   -- local difficulty = door.difficulty or 0
   -- if difficulty > 0 and chara:is_player() then
   --    if not SkillCheck.try_to_lockpick(chara, difficulty) then
   --       return false
   --    end
   --    door.difficulty = 0
   -- else
   --    return true
   -- end

   local difficulty = door.difficulty or 0
   if difficulty <= 0 then
      return true
   end

   return Rand.rnd(difficulty * 20 + 150) < chara:skill_level("elona.lock_picking") * 20 + 20
end

return SkillCheck
