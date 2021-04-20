local Fs = require("api.Fs")
local Compat = require("mod.elona_sys.api.Compat")
local TalkTxtParser = require("mod.cdata_tools.api.talk.TalkTxtParser")
local TalkTxtEntryDecoder = require("mod.cdata_tools.api.decoder.TalkTxtEntryDecoder")

local TalkTxtDecoder = {}

local LANGS = {
   JP = "jp",
   EN = "en"
}

local function decode_lang(txt)
   local result = {}
   for elona_txt_id, cands in pairs(txt) do
      local talk_event_id = Compat.convert_122_talk_event(elona_txt_id) or ("%%%s"):format(elona_txt_id)
      result[talk_event_id] = fun.iter(cands):map(TalkTxtEntryDecoder.decode):to_list()
   end
   return result
end

function TalkTxtDecoder.decode(str, tone_id)
   assert(tone_id, "must provide tone ID")

   local parsed = TalkTxtParser.parse(str)

   local texts = {}

   for elona_lang, lang in pairs(LANGS) do
      local txt = parsed.txt[elona_lang]
      if txt then
         texts[lang] = decode_lang(txt)
      end
   end

   local result = {
      _type = "base.tone",
      _id = tone_id,

      texts = texts
   }

   return result
end

function TalkTxtDecoder.decode_file(filepath, tone_id)
   local content = Fs.read_all(filepath)
   return TalkTxtDecoder.decode(content, tone_id)
end

return TalkTxtDecoder
