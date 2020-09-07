local CustomFileLexer = require("mod.cdata_tools.api.custom_file.CustomFileLexer")

-- This module is for parsing the configuration format shared by various custom
-- files used by many Elona variants.
--
-- These files typically start with a header like "%Elona Custom Item", and
-- contain key-value pairs like "author. Noa" and custom text directives like
-- "%txtdescription,JP".
local CustomFileParser = {}

function CustomFileParser.parse(content, header_check)
   local state = CustomFileLexer:new(content)

   local header = state:read_directive()
   if header_check and header[1] ~= header_check then
      error("Bad header: " .. header[1])
   end

   local result = {
      options = {},
      txt = {}
   }

   while not state:end_of_file() do
      state:skip_blank_lines()

      if state:has_directive() then
         -- TODO: is this needed sometimes?
         local directive = state:read_directive()

         -- print("DIR: " .. inspect(directive))
      elseif state.in_text then
         local in_text = state.in_text
         local text = state:read_rest_of_line()
         -- print("TEXT: " .. inspect(in_text))
         local key = in_text[1]
         local lang = in_text[2] or "JP"
         local args = {}
         for i=3, #in_text do
            args[i-2] = in_text[i]
         end
         if not result.txt[lang] then
            result.txt[lang] = {}
         end
         if not result.txt[lang][key] then
            result.txt[lang][key] = {}
         end
         if #args > 0 then
            table.insert(result.txt[lang][key], {args = args, text = text, event = state.has_event })
         else
            table.insert(result.txt[lang][key], text)
         end
      else
         local option = state:read_option()
         if option ~= nil then
            -- print("OPTION: " .. inspect(option))
            table.insert(result.options, option)
         end
      end
   end

   return result
end

return CustomFileParser
