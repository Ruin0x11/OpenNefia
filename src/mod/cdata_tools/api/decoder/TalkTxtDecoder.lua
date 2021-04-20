local Fs = require("api.Fs")
local TalkTxtParser = require("mod.cdata_tools.api.talk.TalkTxtParser")

local TalkTxtDecoder = {}

function TalkTxtDecoder.decode(str, mod_id, tone_id)
   local parsed = TalkTxtParser.parse(str)

   return parsed
end

function TalkTxtDecoder.decode_file(filepath, mod_id, tone_id)
   local content = Fs.read_all(filepath)
   return TalkTxtDecoder.decode(content, mod_id, tone_id)
end

return TalkTxtDecoder
