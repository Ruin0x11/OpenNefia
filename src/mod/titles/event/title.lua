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
Event.register("base.on_map_changed", "Proc title earned", proc_title_earned_player)
