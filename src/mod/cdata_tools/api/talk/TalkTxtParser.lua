local CustomFileLexer = require("mod.cdata_tools.api.custom_file.CustomFileLexer")
local Fs = require("api.Fs")

-- This module is for parsing custom talk files. They are similar to custom
-- config files.
local TalkTxtParser = {}

local function read_txt(txt, state, result)
   local id = txt[1]
   local lang = txt[#txt]

   if not lang then
      lang = "<unknown>"
   end

   local line = state:read_rest_of_line()

   if line:match("^%%END") then
      return nil, false
   end

   result.txt[lang] = result.txt[lang] or {}
   local t = result.txt[lang]
   for i = 1, #txt-1 do
      t[txt[i]] = t[txt[i]] or {}
      t = t[txt[i]]
   end

   table.insert(t, line)

   return txt, false
end

function TalkTxtParser.parse(content)
   local state = CustomFileLexer:new(content)

   local txt = nil
   local finished
   local result = {
      txt = {}
   }

   while not state:end_of_file() do
      state:skip_blank_lines()

      if txt == nil then
         while not state:has_directive() do
            state:read_rest_of_line()
         end
         txt = state:read_directive()
      else
         if state:has_directive() then
            txt = state:read_directive()
         else
            txt, finished = read_txt(txt, state, result)
            if finished then
               break
            end
         end
      end
   end

   return result
end

function TalkTxtParser.parse_file(file)
   local content = Fs.read_all(file)
   return TalkTxtParser.parse(content)
end

return TalkTxtParser
