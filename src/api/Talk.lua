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
   local talk_entry = talk.messages[lang][event_id]
   local mes = talk_entry

   if type(mes) == "table" and mes[1] ~= nil then
      mes = Rand.choice(mes)
      talk_entry = mes
   end

   if type(mes) == "table" and mes[1] == nil then
      mes = mes.talk
   end

   if type(mes) == "function" then
      -- chara = chara or Chara.mock()
      mes = mes(chara, args)
   end

   return mes, talk_entry
end

function Talk.say(chara, event_id, args, source)
   local message, talk_entry = Talk.message(chara.talk, event_id, chara, args, source)

   if not string.nonempty(message) then
      return
   end

   Gui.mes(message)

   if type(talk_entry) == "table" and talk_entry.voice then
      Gui.play_sound(talk_entry.voice, chara.x, chara.y)
   end

   Event.trigger("base.on_talk", {chara=chara,event_id=event_id,message=message,talk_entry=talk_entry})
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
