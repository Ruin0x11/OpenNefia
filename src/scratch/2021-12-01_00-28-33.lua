local lyaml = require("lyaml")

local function capitalize(str)
  return str:gsub('^%l', string.upper)
end

local function camelize(str)
   return str:gsub('%W+(%w+)', capitalize)
end

local function rgbToHex(rgb)
   local hexadecimal = '#'

   for key, value in pairs(rgb) do
      local hex = ''

      while(value > 0)do
         local index = math.fmod(value, 16) + 1
         value = math.floor(value / 16)
         hex = string.sub('0123456789ABCDEF', index, index) .. hex
      end

      if(string.len(hex) == 0)then
         hex = '00'

      elseif(string.len(hex) == 1)then
         hex = '0' .. hex
      end

      hexadecimal = hexadecimal .. hex
   end

   return hexadecimal
end

local ops = {
   ["base.chara"] = {
      color = rgbToHex
   }
}

local function transform(i)
   local o = ops[i._type]
   if not o then
      return { i }
   end

   local result = {}

   for k, v in pairs(i) do
      local c = camelize(k)
      if o[k] then
         result[c] = o[k](v)
      else
         result[c] = v
      end
   end

   return { result }
end

print(inspect())
local datas = data["base.chara"]:iter():map(transform):to_list()
print(lyaml.dump({ datas }))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
