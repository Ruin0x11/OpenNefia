local Gui = require("api.Gui")
local IChara = require("api.chara.IChara")
local Input = require("api.Input")
local Magic = require("mod.elona_sys.api.Magic")
local Anim = require("mod.elona_sys.api.Anim")
local Item = require("api.Item")
local Rand = require("api.Rand")

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

function God.can_offer_item_to(god_id, item)
   local gods = item.gods or item.proto.gods
   if gods then
      -- `gods` table overrides categories set in god prototype.
      if gods[god_id] == true then
         return true
      elseif gods[god_id] == false then
         return false
      end
      -- Ignore the nil case.

      if gods["any"] == true then
         return true
      end
   end

   if god_id == nil then
      -- Eyth.
      return false
   end

   if item:calc("is_precious") then
      return false
   end

   -- TODO optimize
   local god_proto = data["elona.god"]:ensure(god_id)
   for _, category in pairs(god_proto.offerings or {}) do
      if item:has_category(category) then
         return true
      end
   end

   return false
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

function God.offer(chara, item, altar)
   -- >>>>>>>> shade2/god.hsp:368 *god_offer ...
   local god_id = chara:calc("god")
   if god_id == nil then
      Gui.mes("action.offer.do_not_believe")
      return "turn_end"
   end

   local god_proto = data["elona.god"]:ensure(god_id)

   item:remove_activity()
   local item = item:separate()

   local god_name = ("god.%s.name"):format(god_id)
   Gui.mes("action.offer.execute", item:build_name(), god_name)

   Gui.play_sound("base.offer2", chara.x, chara.y)
   local cb = Anim.heal(chara.x, chara.x, "base.offer_effect")
   Gui.start_draw_callback(cb)

   if not Item.is_alive(altar) then
      return "turn_end"
   end

   local points

   -- TODO capability
   if item._id == "elona.corpse" then
      points = math.clamp(item:calc("weight") / 200, 1, 50)
      if (item.spoilage_date or 0) < 0 then
         points = 0
      end
   else
      points = 25
   end

   if altar.params.altar_god_id ~= god_id then
      local other_god_name
      if altar.params.altar_god_id then
         other_god_name = ("god.%s.name"):format(altar.params.altar_god_id)
      end

      local was_claimed

      if altar.params.altar_god_id == nil then
         was_claimed = true
         Gui.mes("action.offer.claims", god_name)
      else
         Gui.mes("action.offer.take_over.attempt", god_name, other_god_name)
         was_claimed = Rand.rnd(17) <= points
      end

      if was_claimed then
         God.modify_piety(chara, points * 5)
         chara.prayer_charge = chara.prayer_charge + points * 30
         local positions = {{ x = chara.x, y = chara.y }}
         local cb = Anim.miracle(positions)
         Gui.start_draw_callback(cb)
         Gui.play_sound("base.pray2", chara.x, chara.y)
         if altar.params.altar_god_id ~= nil then
            Gui.mes("action.offer.take_over.shadow")
         end
         Gui.mes_c("action.offer.take_over.succeed", "Yellow", god_name, altar:build_name())
         God.say(chara, "elona.god_take_over_succeed")
         altar.params.altar_god_id = god_id
      else
         Gui.mes("action.offer.take_over.fail", god_name)
         God.say(chara, "elona.god_take_over_fail")
         God.punish(chara)
      end
   else
      local text
      if points >= 15 then
         text = "action.offer.result.best"
         God.say(chara, "elona.god_offer_great")
      elseif points >= 10 then
         text = "action.offer.result.good"
      elseif points >= 5 then
         text = "action.offer.result.okay"
      elseif points >= 1 then
         text = "action.offer.result.poor"
      end
      if text then
         Gui.mes_c(text, "Green", item:build_name(), item.amount)
      end
      God.modify_piety(chara, points)
      chara.prayer_charge = chara.prayer_charge + points * 7
   end

   item:remove()

   return "turn_end"
   -- <<<<<<<< shade2/god.hsp:428 	goto *turn_end ..
end

function God.punish(chara)
   -- >>>>>>>> shade2/god.hsp:432 *god_punish ...
   -- <<<<<<<< shade2/god.hsp:435 	if rnd(2) : call effect,(efId=efDecStats,efP=100, ..
end

return God
