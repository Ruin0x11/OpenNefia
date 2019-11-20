--- @module Talk

local Rand = require("api.Rand")
local Log = require("api.Log")
local Event = require("api.Event")
local Gui = require("api.Gui")
local data = require("internal.data")

local Talk = {}

--- Formats a string according to the talk ID given.
---
--- @tparam id:base.talk talk_id
--- @tparam string talk_event_id
--- @tparam[opt] IChara chara
--- @tparam[opt] table args Extra arguments to the talk formatter.
function Talk.message(talk_id, talk_event_id, chara, args)
   if not talk_id then
      return
   end

   local talk = data["base.talk"][talk_id]
   if not talk then
      return
   end

   args = args or {}
   local is_event = string.has_prefix(talk_event_id, "event:")

   if not is_event then
      local ev = data["base.talk_event"][talk_event_id]
      if not ev then
         Log.warn("Unknown talk event %s for talk %s", talk_event_id, talk_id)
         return nil
      end
      args = table.merge_existing(table.deepcopy(ev.params) or {}, args)
   end

   local lang = "jp"
   local talk_entry = talk.messages[lang][talk_event_id]
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

--- Makes a character say a message given a talk event ID.
---
--- @tparam IChara chara
--- @tparam string talk_event_id
--- @tparam[opt] table args
--- @tparam[opt] any source
function Talk.say(chara, talk_event_id, args, source)
   local message, talk_entry = Talk.message(chara.talk, talk_event_id, chara, args, source)

   if not string.nonempty(message) then
      return
   end

   Gui.mes(message)

   chara:emit("base.on_talk", {talk_event_id=talk_event_id,message=message,talk_entry=talk_entry})
end

local function talk_voice_handler(chara, params)
   if type(params.talk_entry) == "table" and params.talk_entry.voice then
      Gui.play_sound(params.talk_entry.voice, chara.x, chara.y)
   end
end

Event.register("base.on_talk", "talk voice handler2", talk_voice_handler)

--- Sets up talk events for this character.
--- TODO shouldn't be public.
---
--- @tparam IChara chara
function Talk.setup(chara)
   if not chara.talk then
      return
   end

   local talk = data["base.talk"][chara.talk]
   if not talk then
      chara:disconnect_self("base.before_handle_self_event", "talk handler")
      return
   end

   local lang = "jp"
   for event_id, _ in pairs(talk.messages[lang]) do
      -- TODO: unify talk and base events
      if string.has_prefix(event_id, "event:") then
         event_id = string.strip_prefix(event_id, "event:")
         if data["base.event"][event_id] then
            -- Event.add_observer(event_id, chara)
         end
      end
   end

   if not chara:has_event_handler("base.before_handle_self_event", "talk handler") then
      chara:connect_self("base.before_handle_self_event", "talk handler",
                            function(self, params)
                               if params.event_id == "base.on_talk" then
                                  return
                               end

                               Talk.say(self, "event:" .. params.event_id, params.args)
                            end
      )
   end
end

return Talk
