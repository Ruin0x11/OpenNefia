local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Rand = require("api.Rand")

local RandomEventPrompt = require("api.gui.RandomEventPrompt")

local RandomEvent = {}

local global_kind = "normal"

local KINDS = table.set { "normal", "sleep", "disabled" }

function RandomEvent.set_kind(kind_)
   kind_ = kind_ or "normal"
   if not KINDS[kind_] then
      error("invalid random event kind " .. kind_)
   end
   global_kind = kind_
end

-- @tparam string kind "normal" (default), "sleep"
function RandomEvent.random_event_id(kind)
   local player = Chara.player()
   local map = player:current_map()

   if player.current_speed < 10 then
      return nil
   end

   if config.base.debug_skip_random_events then
      return nil
   end

   kind = kind or global_kind or "normal"

   if kind == "disabled" then
      return
   end

   local id = nil
   local luck_threshold = nil

   if not KINDS[kind] then
      error("invalid random event kind " .. kind)
   end

   if kind == "sleep" then
      -- TODO god

      if Rand.one_in(80) then id = "elona.creepy_dream" end
      if Rand.one_in(20) then id = "elona.development" end
      if Rand.one_in(25) then id = "elona.wizards_dream" end
      if Rand.one_in(100) then id = "elona.cursed_whispering" end
      if Rand.one_in(20) then id = "elona.regeneration" end
      if Rand.one_in(20) then id = "elona.meditation" end
      if Rand.one_in(250) and not player:is_inventory_full() then id = "elona.treasure_of_dream" end
      if Rand.one_in(10000) and not player:is_inventory_full() then id = "elona.quirk_of_fate" end
      if Rand.one_in(70) then id = "elona.malicious_hand" end
      if Rand.one_in(200) then id = "elona.lucky_day" end
      if Rand.one_in(50) then id = "elona.dream_harvest" end
      if Rand.one_in(300) then id = "elona.your_potential" end
      if Rand.one_in(90) then id = "elona.monster_dream" end

      return id, luck_threshold
   end

   if not map:has_type("world_map") and player:has_activity() then
      return nil
   end

   if map:has_type("player_owned") then
      return nil
   end

   if Rand.one_in(30) then id = "elona.wandering_priest" end
   if Rand.one_in(25) then id = "elona.mad_millionaire" end
   if Rand.one_in(25) then id = "elona.small_luck" end
   if Rand.one_in(50) then id = "elona.great_luck" end
   if Rand.one_in(80) then id = "elona.strange_feast" end
   if Rand.one_in(50) then id = "elona.malicious_hand" end
   if Rand.one_in(80) then id = "elona.smell_of_food" end

   if map:has_type("town") then
      if Rand.one_in(25) then id = "elona.murderer" end

      return id, luck_threshold
   end

   if map:has_type("world_map") then
      if not Rand.one_in(40) then
         return nil
      end

      return id, luck_threshold
   end

   if Rand.one_in(25) then id = "elona.camping_site" end
   if Rand.one_in(25) then id = "elona.corpse" end

   return id, luck_threshold
end

function RandomEvent.trigger_randomly(kind)
   local id, luck_threshold = RandomEvent.random_event_id(kind)

   if id == nil then
      return nil
   end

   local proto = data["elona.random_event"]:ensure(id)
   if proto.luck_threshold then
      luck_threshold = luck_threshold or proto.luck_threshold
   end

   if luck_threshold then
      if Rand.rnd(Chara.player():skill_level("elona.stat_luck")) > luck_threshold then
         id = "elona.avoiding_misfortune"
      end
   end

   return RandomEvent.trigger(id)
end

function RandomEvent.trigger(random_event_id)
   local proto = data["elona.random_event"]:ensure(random_event_id)

   local choice_count = math.max(proto.choice_count or 1, 1)
   assert(math.type(choice_count) == "integer", "Choice count must be integer")
   assert(data["base.asset"][proto.image], ("Random event must declare valid asset, got %s"):format(proto.asset))

   if proto.on_event_triggered then
      proto.on_event_triggered()
   end

   Gui.refresh_hud()

   local to_choice_text = function(i)
      return ("random_event._.%s.choices._%d"):format(random_event_id, i)
   end
   local choice_texts = fun.range(choice_count):map(to_choice_text):to_list()

   local prompt = RandomEventPrompt:new(
      ("random_event._.%s.title"):format(random_event_id),
      ("random_event._.%s.text"):format(random_event_id),
      proto.image,
      choice_texts)

   local index = prompt:query()

   local choices = proto.choices

   if choices then
      local choice_cb = choices[index]
      if choice_cb then
         choice_cb()
      end
   end

   return index
end

return RandomEvent
