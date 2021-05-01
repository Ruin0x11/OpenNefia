local Event = require("api.Event")
local Chara = require("api.Chara")
local Title = require("mod.titles.api.Title")

local function proc_title_earned_kill_chara(victim, params)
   if params.attacker then
      -- >>>>>>>> oomSEST/src/dmg.hsp:1063 			gosub *label_1177 ...
      Title.check_earned(params.attacker)
      -- <<<<<<<< oomSEST/src/dmg.hsp:1063 			gosub *label_1177 ..
   end
end
Event.register("base.on_kill_chara", "Proc title earned", proc_title_earned_kill_chara)

local function proc_title_earned_chara(chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:5737 			txt -1, txtskillchange(__skillId, 0, __cc) ...
   Title.check_earned(chara)
   -- <<<<<<<< oomSEST/src/southtyris.hsp:5737 			txt -1, txtskillchange(__skillId, 0, __cc) ..
end
Event.register("elona_sys.on_gain_skill_exp", "Proc title earned", proc_title_earned_chara)

local function proc_title_earned_player()
   local player = Chara.player()
   if Chara.is_alive(player) then
      Title.check_earned(player)
   end
end
Event.register("base.on_map_entered", "Proc title earned", proc_title_earned_player)

local function apply_temporary_title_effects(chara)
   if chara:is_player() then
      for _, title_id, title_state in Title.iter_earned() do
         local proto = data["titles.title"]:ensure(title_id)
         if proto.on_refresh then
            proto.on_refresh(chara, title_state == "effect_on")
         end
      end
   end
end
Event.register("base.on_refresh", "Apply temporary title effects", apply_temporary_title_effects)
