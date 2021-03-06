local Gui = require("api.Gui")

local RandomEventPrompt = require("api.gui.RandomEventPrompt")

local RandomEvent = {}

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
