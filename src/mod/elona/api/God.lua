local Gui = require("api.Gui")
local IChara = require("api.chara.IChara")
local Input = require("api.Input")
local Magic = require("mod.elona_sys.api.Magic")

-- TODO implement gods as capability (god ID, piety, prayer charge, god rank in one struct)
local God = {}

function God.say(god_id, talk_event_id)
   local chara
   if class.is_an(IChara, god_id) then
      chara = god_id
      god_id = chara:calc("god")
   end

   if god_id then
      local god = data["elona.god"][god_id]
      if god and god.talk_id then
         -- local mes = Talk.message(god.talk_id, talk_event_id, chara)
         -- Gui.mes_c(mes, "Yellow")
         Gui.mes_c("TODO god talk " .. talk_event_id, "Yellow")
      end
   end
end

function God.modify_piety(chara, amount)
   local rank = chara.god_rank
   local piety = chara:calc("piety")

   if rank == 4 and piety >= 4000 then
      chara.god_rank = chara.god_rank + 1
      God.say(chara, "elona.god_gift_2")
   end
   if rank == 2 and piety >= 2500 then
      chara.god_rank = chara.god_rank + 1
      God.say(chara, "elona.god_gift_1")
   end
   if rank == 0 and piety >= 1500 then
      chara.god_rank = chara.god_rank + 1
      God.say(chara, "elona.god_gift_1")
   end

   if chara:skill_level("elona.faith") * 100 < piety then
      Gui.mes("god.pray.indifferent", chara.god)
      return
   end

   -- TODO show house

   chara.piety = chara.piety + amount
end

function God.make_skill_blessing(skill, coefficient, add)
   -- data["base.skill"]:ensure(skill) TODO
   return function(chara)
      if chara:has_skill(skill) then
         local amount = math.clamp((chara:calc("piety") or 0) / coefficient, 1, add + chara:skill_level("elona.faith") / 10)
         chara:mod_skill_level(skill, amount, "add")
      end
   end
end

function God.switch_religion_with_penalty(chara, new_god)
   -- >>>>>>>> shade2/god.hsp:238 		gosub *screen_drawStatus ...
   Gui.update_screen()

   if chara.god ~= nil and data["elona.god"][chara.god] then
      local god_name = ("god.%s.name"):format(chara.god)
      Gui.mes_c("god.enraged", "Purple", god_name)
      God.say(chara.god, "elona.god_stop_believing")

      Magic.cast("elona.buff_punishment", { power = 10000, target = chara })
      Gui.play_sound("base.punish1")
      Gui.wait(500)
   end

   God.switch_religion(chara, new_god)
   -- <<<<<<<< shade2/god.hsp:253 		gosub *change_god ..
end

function God.switch_religion(chara, new_god)
   if new_god ~= nil then
      data["elona.god"]:ensure(new_god)
   end

   chara.piety = 0
   chara.prayer_charge = 500
   chara.god_rank = 0

   chara.god = new_god

   if new_god == nil then
      Gui.mes_c("god.switch.unbeliever", "Yellow")
   else
      local god_name = ("god.%s.name"):format(new_god)
      Gui.play_sound("base.complete1")
      Gui.mes_c("god.switch.follower", "Yellow", god_name)
      God.say(chara.god, "elona.god_new_believer")
   end

   chara:refresh()
end

function God.pray(chara, altar)
   if not chara:calc("god") then
      Gui.mes("god.pray.do_not_believe")
      return "turn_end"
   end

   if chara:is_player() then
      Gui.mes("god.pray.prompt")
      if not Input.yes_no() then
         Gui.update_screen()
         return "player_turn_query"
      end
   end
end

function God.offer(player)
   error("offer")
end

return God
