local CustomFileParser = require("mod.cdata_tools.api.custom_file.CustomFileParser")
local Fs = require("api.Fs")

-- This module consumes the raw output from CustomFileParser and returns a
-- structured Lua table.
local CustomFileDecoder = {}

function CustomFileDecoder.decode(obj)
   local result = {
      options = {},
      txt = {}
   }

   for _, v in ipairs(obj.options) do
      local key = v[1]
      local value = v[2]
      if type(result.options[key]) == "table" then
         table.insert(result.options[key], value)
      elseif result.options[key] ~= nil then
         result.options[key] = { result.options[key], value }
      else
         result.options[key] = value
      end
   end
   for k, v in pairs(obj.txt) do
      result.txt[k] = v
   end

   return result
end

function CustomFileDecoder.decode_file(file, header)
   local content = Fs.read_all(file)
   local result = CustomFileParser.parse(content, header)
   return CustomFileDecoder.decode(result)
end

return CustomFileDecoder
