local automagic = require("thirdparty.automagic")
local lyaml = require("lyaml")
local Enum = require("api.Enum")

local function capitalize(str)
  return str:gsub('^%l', string.upper)
end

local function camelize(str)
   return str:gsub('%W+(%w+)', capitalize)
end

local function classify(str)
  return str:gsub('%W*(%w+)', capitalize)
end

local function dotted(str)
   local mod_id, data_id = str:match("([^.]+)%.([^.]+)")
   return ("%s.%s"):format(classify(mod_id), classify(data_id))
end

local function dottedEntity(str, ty)
   local _, ty = ty:match("([^.]+)%.([^.]+)")
   local mod_id, data_id = str:match("([^.]+)%.([^.]+)")
   return ("%s.%s%s"):format(classify(mod_id), classify(ty), classify(data_id))
end

local function dotted_keys(t)
   return fun.iter(t):map(function(k, v) return dotted(k), v end):to_map()
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
   all = {
      _id = dotted,
      _type = dotted,
   },
   ["base.class"] = {
      equipment_type = dotted,
      skills = dotted_keys
   },
   ["base.chara"] = {
      color = rgbToHex
   }
}

local function transform(i)
   local o = ops[i._type] or {}

   local result = {}

   for k, v in pairs(i) do
      local c
      if k:sub(1, 1) == "_" then c = k else c = camelize(k) end
      local f = o[k] or ops.all[k]
      if f then
         result[c] = f(v)
      else
         result[c] = v
      end
   end

   return result
end

local function tuple(t)
   return table.concat(t, ",")
end

local hspTypes = {
   ["base.chara"] = "BaseChara",
   ["base.item"] = "BaseItem",
   ["base.feat"] = "BaseFeat",
   ["base.mef"] = "BaseMef",
}

local handlers = {}

local function comp(t, name)
   if t.components == nil then
      t.componentes = {}
   end

   for _, c in ipairs(t.components) do
      if c.type == name then
         return c
      end
   end

   local c = automagic()
   c.type = name
   t.components[#t.components+1] = c
   return c
end

handlers["base.chara"] = function(from, to)
   local c = comp(to, "Chip")
   if from.image then
      c.id = dotted(from.image)
   end
   if from.color then
      c.color = rgbToHex(from.color)
   end
end

handlers["base.item"] = function(from, to)
   local c = comp(to, "Chip")
   if from.image then
      c.id = dotted(from.image)
   end
   if from.color then
      c.color = rgbToHex(from.color)
   end

   c = comp(to, "Level")
   c.level = from.level or 1

   c = comp(to, "Item")
   c.value = from.value
   c.weight = from.weight
   if from.material then
      c.material = dotted(from.material)
   end
   if (from.identify_difficulty or 0) ~= 0 then
      c.identifyDifficulty = from.identify_difficulty
   end
   if from.originalnameref2 then
      c.originalnameref2 = from.originalnameref2
   end

   c = comp(to, "Tag")
   c.tags = {}
   for _, cat in ipairs(from.categories or {}) do
      c.tags[#c.tags+1] = "category:" .. dotted(cat)
   end
   for _, tag in ipairs(from.tags or {}) do
      c.tags[#c.tags+1] = "tag:" .. tag
   end
   if from.is_wishable == false then
      c.tags[#c.tags+1] = "Elona.NoWish"
   end

   if (from.fltselect or 0) ~= 0 or (from.rarity or 0) ~= 0 then
      c = comp(to, "RandomGen")
      c.tables.item = {
         coefficient = from.coefficient or 400,
         rarity = from.rarity or 100000
      }
      if (from.fltselect or 0) ~= 0 then
         c.tables.item.fltselect = Enum.FltSelect:to_string(from.fltselect)
      end
   end

   if from.quality then
      c = comp(to, "Quality")
      c.quality = Enum.Quality:to_string(from.quality)
   end

   if from.is_precious then
      comp(to, "Precious")
   end
end

handlers["base.feat"] = function(from, to)
   local c = comp(to, "Chip")
   if from.image then
      c.id = dotted(from.image)
   end
   if from.color then
      c.color = rgbToHex(from.color)
   end
end

handlers["base.mef"] = function(from, to)
   local c = comp(to, "Chip")
   if from.image then
      c.id = dotted(from.image)
   end
   if from.color then
      c.color = rgbToHex(from.color)
   end
end

local function sort(a, b)
   return (a.elona_id or 0) < (b.elona_id or 0)
end

local function transformMinimal(i)
   local t = automagic()
   if hspTypes[i._type] then
      t.type = "Entity"
      t.id = dottedEntity(i._id, i._type)
   else
      t.type = capitalize(i._type:gsub("(.*)%.(.*)", "%2"))
      t.id = dotted(i._id)
   end
   t.parent = hspTypes[i._type]

   if i.elona_id then
      t.hspOrigin = "elona122"
      t.hspIds = {
         elona122 = i.elona_id
      }
   end

   assert(handlers[i._type])(i, t)

   return t
end

local datas = data["base.item"]:iter():into_sorted(sort):map(transformMinimal):to_list()
print(lyaml.dump({ datas }))

-- print(inspect(data["base.item"]:iter():filter(function(a) return a.fltselect > 0 and a.rarity == 0 end):to_list()))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
