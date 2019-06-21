local Rand = require("api.Rand")
local Event = require("api.Event")
local Gui = require("api.Gui")
local data = require("internal.data")

local Talk = {}

function Talk.message(talk_id, event_id, chara, args, source)
   if not talk_id then
      return
   end

   local talk = data["base.talk"][talk_id]
   if not talk then
      return
   end

   args = args or {}
   source = source or "talk"

   if source == "event" then
      event_id = "event:" .. event_id
   elseif source == "talk" then
      local ev = data["base.talk_event"][event_id]
      if not ev then
         return nil
      end
      args = table.merge_existing(table.deepcopy(ev.params) or {}, args)
   else
      error("unknown talk source " .. source)
   end

   local lang = "jp"
   local mes = talk.messages[lang][event_id]

   if type(mes) == "table" and mes[1] ~= nil then
      mes = Rand.choice(mes)
   end

   if type(mes) == "table" and mes[1] == nil then
      mes = mes.talk
   end

   if type(mes) == "function" then
      -- chara = chara or Chara.mock()
      mes = mes(chara, args)
   end

   return mes
end

function Talk.say(chara, event_id, args, source)
   local message = Talk.message(chara.talk, event_id, chara, args, source)

   if not message then
      return
   end

   Gui.mes(message)

   Event.trigger("base.on_talk", {chara=chara})
end

function Talk.setup(chara)
   if not chara.talk then
      return
   end

   local talk = data["base.talk"][chara.talk]
   if not talk then
      chara.events:unregister("on_event", "talk handler")
      return
   end

   local lang = "jp"
   for event_id, v in pairs(talk.messages[lang]) do
      if string.has_prefix(event_id, "event:") then
         local event_id = string.strip_prefix(event_id, "event:")
         if data["base.event"][event_id] then
            Event.add_observer(event_id, chara)
         end
      end
   end

   if not chara.events:has_handler("on_event", "talk handler") then
      chara.events:register("on_event", "talk handler",
                            function(params)
                               if params.event_id == "base.on_talk" then
                                  return
                               end

                               Talk.say(chara, params.event_id, params.args, "event")
                            end
      )
   end
end

return Talk
