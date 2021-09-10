local Gui = require("api.Gui")
local IChara = require("api.chara.IChara")
local Input = require("api.Input")
local Magic = require("mod.elona_sys.api.Magic")
local Anim = require("mod.elona_sys.api.Anim")
local Item = require("api.Item")
local Rand = require("api.Rand")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local StayingCharas = require("api.StayingCharas")
local Chara = require("api.Chara")
local Log = require("api.Log")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

-- TODO implement gods as capability (god ID, piety, prayer charge, god rank in one struct)
local God = {}

function God.random_god_id(no_eyth)
   local gods = data["elona.god"]:iter()
   :filter(function(god) return god.is_primary_god end)
      :extract("_id")
      :to_list()

   if not no_eyth then
      gods[#gods+1] = "eyth"
   end

   local god_id = Rand.choice(gods)
   if god_id == "eyth"  then
      god_id = nil
   end

   return god_id
end

function God.say(god_id, talk_event_id)
   local chara
   if class.is_an(IChara, god_id) then
      chara = god_id
      god_id = chara:calc("god")
   end

   if god_id then
      local god = data["elona.god"][god_id]
      if god then
         -- local mes = Talk.message(god.talk_id, talk_event_id, chara)
         -- Gui.mes_c(mes, "Yellow")
         Gui.mes_c("TODO god talk " .. talk_event_id, "Yellow")
      end
   end
end

function God.modify_piety(chara, amount)
   local rank = chara.god_rank or 0
   local piety = chara.piety or 0

   if chara:skill_level("elona.faith") * 100 < piety then
      Gui.mes("god.pray.indifferent", chara.god)
      return false
   end

   if rank == 4 and piety >= 4000 then
      chara.god_rank = rank + 1
      God.say(chara, "elona.god_gift_2")
   end
   if rank == 2 and piety >= 2500 then
      chara.god_rank = rank + 1
      God.say(chara, "elona.god_gift_1")
   end
   if rank == 0 and piety >= 1500 then
      chara.god_rank = rank + 1
      God.say(chara, "elona.god_gift_1")
   end

   -- TODO show house

   chara.piety = math.floor(piety + amount)

   return true
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
   for _, offering in pairs(god_proto.offerings or {}) do
      if offering.type == "category" then
         if item:has_category(offering.id) then
            return true
         end
      elseif offering.type == "item" then
         if item._id == offering.id then
            return true
         end
      else
         error(("Invalid god offering type '%s'"):format(offering.type))
      end
   end

   return false
end

local function mkblessing(cb)
   return function(skill, coefficient, add)
      return function(chara)
         if chara["has_" .. cb](chara, skill) then
            local amount = math.clamp((chara.piety or 0) / coefficient, 1, add + chara:skill_level("elona.faith") / 10)
            chara["mod_" .. cb .. "_level"](chara, skill, amount, "add")
         end
      end
   end
end

God.make_skill_blessing = mkblessing("skill")
God.make_resist_blessing = mkblessing("resist")

function God.switch_religion_with_penalty(chara, new_god)
   -- >>>>>>>> shade2/god.hsp:238 		gosub *screen_drawStatus ...
   Gui.update_screen()

   if chara.god ~= nil and data["elona.god"][chara.god] then
      local god_name = ("god.%s.name"):format(chara.god)
      Gui.mes_c("god.enraged", "Purple", god_name)
      God.say(chara.god, "elona.god_stop_believing")

      Magic.cast("elona.buff_punishment", { power = 10000, target = chara })
      Gui.play_sound("base.punish1", chara.x, chara.y)
      Gui.wait(500)
   end

   God.switch_religion(chara, new_god)
   -- <<<<<<<< shade2/god.hsp:253 		gosub *change_god ..
end

function God.switch_religion(chara, new_god)
   local new_god_proto
   if new_god ~= nil then
      new_god_proto = data["elona.god"]:ensure(new_god)
   end

   chara.piety = 0
   chara.prayer_charge = 500
   chara.god_rank = 0

   if chara.god then
      local old_god_proto = data["elona.god"][chara.god]
      if old_god_proto then
         if old_god_proto.on_leave_faith then
            old_god_proto.on_leave_faith(chara)
         end
      else
         Log.warn("missing god id %s", chara.god)
      end
   end

   chara.god = new_god

   if new_god == nil then
      Gui.mes_c("god.switch.unbeliever", "Yellow")
   else
      local god_name = ("god.%s.name"):format(new_god)
      Gui.play_sound("base.complete1")
      Gui.mes_c("god.switch.follower", "Yellow", god_name)
      God.say(chara.god, "elona.god_new_believer")

      if new_god_proto.on_join_faith then
         new_god_proto.on_join_faith(chara)
      end
   end

   chara:refresh()
end

function God.pray(chara, altar)
   -- >>>>>>>> shade2/god.hsp:280 	if cGod(pc)=0:txt lang(name(pc)+"は神を信仰していないが、試しに祈 ...
   local god_id = chara:calc("god")

   if god_id == nil then
      Gui.mes("god.pray.do_not_believe")
      return "turn_end"
   end

   local god_proto = data["elona.god"]:ensure(god_id)

   if chara:is_player() then
      Gui.mes("god.pray.prompt")
      if not Input.yes_no() then
         Gui.update_screen()
         return "player_turn_query"
      end
   end

   local god_name = ("god.%s.name"):format(god_id)

   Gui.mes("god.pray.you_pray_to", god_name)

   if chara.piety < 200 or chara.prayer_charge < 1000 then
      Gui.mes("god.pray.indifferent", god_name)
      return "turn_end"
   end

   local positions = {{ x = chara.x, y = chara.y }}
   local cb = Anim.miracle(positions)
   Gui.start_draw_callback(cb)
   Gui.play_sound("base.pray2", chara.x, chara.y)

   Magic.cast("elona.effect_elixir", { power = 100, target = chara })
   Magic.cast("elona.buff_holy_veil", { power = 200, target = chara })

   chara.prayer_charge = 0
   chara.piety = math.max(math.floor(chara.piety * 85 / 100), 0)

   if chara.god_rank % 2 == 1 then
      God.say(chara, "elona.god_gift")

      if chara.god_rank == 1 then
         local servant = god_proto.servant
         if servant then
            local ally, declined = God.create_gift_servant(servant, chara, god_id)
            if not Chara.is_alive(ally) then
               if declined == "declined" then
                  chara.god_rank = chara.god_rank + 1
               end
               return "turn_end"
            end
         end
      elseif chara.god_rank == 3 then
         local specs = god_proto.items
         if specs and #specs > 0 then
            God.create_gift_items(specs, chara, god_id)
            Gui.mes("common.something_is_put_on_the_ground")
         end
      elseif chara.god_rank == 5 then
         local artifact = god_proto.artifact
         if artifact then
            God.create_gift_artifact(artifact, chara, god_id)
            Gui.mes("common.something_is_put_on_the_ground")
         end
      end

      chara.god_rank = chara.god_rank + 1
   end
   -- <<<<<<<< shade2/god.hsp:364 	goto *turn_end ..
end

function God.create_gift_servant(chara_id, chara, god_id)
   -- >>>>>>>> shade2/god.hsp:305 			f=false:p=0 ...
   local map = chara:current_map()
   local servants_in_party = StayingCharas.iter_allies_and_stayers(map)
      :filter(function(c) return c.race == "elona.servant" end)
      :length()

   local success = true

   if servants_in_party >= 2 then
      Gui.mes("god.pray.servant.no_more")
      success = false
   elseif not chara:can_recruit_allies() then
      Gui.mes("god.pray.servant.party_is_full")
      success = false
   end

   if not success then
      Gui.mes("god.pray.servant.prompt_decline")
      if Input.yes_no() then
         return nil, "declined"
      end

      return nil
   end

   local ally = Chara.create(chara_id, chara.x, chara.y, { no_modify = true }, chara:current_map())
   Gui.mes_c("god." .. god_id .. ".servant", "Blue")
   chara:recruit_as_ally(ally)

   return ally
   -- <<<<<<<< shade2/god.hsp:326 			rc=nc:gosub *add_ally ..
end

function God.create_gift_items(specs, chara, god_id)
   -- >>>>>>>> shade2/god.hsp:330 			flt :dbId=0 ...
   local items = {}
   for _, spec in ipairs(specs) do
      local _id = spec.id
      local no_stack = spec.no_stack
      if spec.only_once and ItemMemory.generated(_id) > 0 then
         _id = "elona.potion_of_cure_corruption"
         no_stack = false
      end
      local item = Item.create(_id, chara.x, chara.y, { no_stack = no_stack }, chara:current_map())
      if Item.is_alive(item) then
         if spec.properties then
            table.merge(item, spec.properties)
         end
         items[#items+1] = item
      end
   end
   return items
   -- <<<<<<<< shade2/god.hsp:346 			txtQuestItem ..
end

function God.create_gift_artifact(item_id, chara, god_id)
   -- >>>>>>>> shade2/god.hsp:350 			flt :dbId=0 ...
   if ItemMemory.generated(item_id) > 0 then
      item_id = "elona.treasure_map"
   end
   return Item.create(item_id, chara.x, chara.y, {}, chara:current_map())
   -- <<<<<<<< shade2/god.hsp:359 			item_create -1,dbId,cX(pc),cY(pc):txtQuestItem ..
end

function God.calc_item_piety_value(item)
   -- TODO capability
   local points
   if item._id == "elona.corpse" then
      points = math.clamp(item:calc("weight") / 200, 1, 50)
      local food = item:get_aspect(IItemFood)
      if food and food:is_rotten(item) then
         points = 0
      end
   else
      points = 25
   end
   return points
end

function God.offer(chara, item, altar)
   -- >>>>>>>> shade2/god.hsp:368 *god_offer ...
   local god_id = chara:calc("god")
   if god_id == nil then
      Gui.mes("action.offer.do_not_believe")
      return "turn_end"
   end

   local god_proto = data["elona.god"]:ensure(god_id)
   local god_name = ("god.%s.name"):format(god_id)

   item:remove_activity()
   local item = item:separate()

   Gui.mes("action.offer.execute", item:build_name(), god_name)

   Gui.play_sound("base.offer2", chara.x, chara.y)
   local cb = Anim.heal(chara.x, chara.y, "base.offer_effect")
   Gui.start_draw_callback(cb)

   if not Item.is_alive(altar) then
      return "turn_end"
   end

   local points = God.calc_item_piety_value(item)

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
   Magic.cast("elona.effect_curse", { power = 500, target = chara })
   if Rand.one_in(2) then
      Magic.cast("elona.buff_punishment", { power = 250, target = chara })
      Gui.play_sound("base.punish1", chara.x, chara.y)
   end
   if Rand.one_in(2) then
      Magic.cast("elona.effect_punish_decrement_stats", { power = 100, target = chara })
   end
   -- <<<<<<<< shade2/god.hsp:435 	if rnd(2) : call effect,(efId=efDecStats,efP=100, ..
end

return God
