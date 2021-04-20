local data = require("internal.data")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Rand = require("api.Rand")
local I18N = require("api.I18N")

local Talk = {}

Talk.DEFAULT_RANDOM_WEIGHT = 10

function Talk.gen_text(chara, talk_event_id, args)
   local tone = chara:calc("tone")
   if type(tone) == "nil" then
      return
   elseif type(tone) == "string" then
      tone = { tone }
   end

   assert(type(tone) == "table")

   data["base.talk_event"]:ensure(talk_event_id)

   local cands = {}

   for _, tone_id in ipairs(tone) do
      local tone_proto = data["base.tone"]:ensure(tone_id)

      local lang = tone_proto.texts[I18N.language()]
      if lang then
         local texts = lang[talk_event_id]
         if texts then
            for _, cand in ipairs(texts) do
               cands[#cands+1] = { tone_id = tone_id, cand = cand }
            end
         end
      end
   end

   local sampler = WeightedSampler:new()

   for _, entry in ipairs(cands) do
      local tone_id = entry.tone_id
      local cand = entry.cand

      local ty = type(cand)

      local weight = Talk.DEFAULT_RANDOM_WEIGHT
      if ty == "string" or ty == "function" then
      elseif ty == "table" then
         if cand.pred == nil or cand.pred(chara, args) then
            if type(cand[1]) == "string" then
               cand = cand
            else
               cand = cand
               weight = cand.weight or weight
            end
         end
      else
         error("Unknown talk text of type " .. ty .. "(" .. tone_id .. ")")
      end

      sampler:add(cand, weight)
   end

   if sampler:len() == 0 then
      return nil
   end

   local result = sampler:sample()
   local ty = type(result)

   local locale_data = nil

   local function get_text(r)
      local text
      if ty == "string" then
         text = r
      elseif ty == "function" then
         locale_data = locale_data or chara:produce_locale_data()
         text = r(locale_data, chara, args)
      elseif ty == "table" then
         local choice = Rand.choice(r)
         if choice then
            text = get_text(r)
         end
      else
         error("Unknown talk text of type " .. ty)
      end
      return text
   end

   return get_text(result)
end

function Talk.say(chara, talk_event_id, args, opts)
   local text = Talk.gen_text(chara, talk_event_id, args)

   if text then
      local color = opts and opts.color
      chara:mes_c(text, color)
   end

   return text
end

return Talk
