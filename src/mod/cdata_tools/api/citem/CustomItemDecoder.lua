local Enum = require("api.Enum")
local Fs = require("api.Fs")
local Util = require("mod.cdata_tools.api.Util")
local Sjis = require("mod.sjis.api.Sjis")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local CustomFileParser = require("mod.cdata_tools.api.custom_file.CustomFileParser")
local CustomFileDecoder = require("mod.cdata_tools.api.custom_file.CustomFileDecoder")
local ArchiveUnpacker = require("mod.cdata_tools.api.archive.ArchiveUnpacker")

local CustomItemDecoder = {}

local function get_number(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = tonumber(value)
   if value == default then
      return nil
   end

   return value
end

local function get_string(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = Sjis.to_utf8(value)
   if value == default then
      return nil
   end

   return value
end

local function get_int_list(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = fun.iter(string.split(value, ",")):map(tonumber):to_list()
   if table.deepcompare(value, default) then
      return nil
   end

   return value
end

local chip_spec = {
   isetpos      = { to = "y_offset" },
   ipilepos     = { to = "stack_height" },
   idropshadow  = { to = "shadow" },
}

local item_spec = {
   dicex        = { to = "dice_x" },
   dicey        = { to = "dice_y" },
   dodgevalue   = { to = "dv" },
   protectvalue = { to = "pv" },
   ipierce      = { to = "pierce_rate" },
   fixdamage    = { to = "damage_bonus" },
   fixhit       = { to = "hit_bonus" },
   irare        = { to = "rarity", cb = function(rarity) return rarity * 1000 end },
   icolref      = { to = "color", cb = Util.convert_122_color_index },
   iorgvalue    = { to = "value" },
   iorgweight   = { to = "weight" },
   identifydef  = { to = "identify_difficulty" },
   material     = { to = "material", cb = function(material_id) return assert(Compat.convert_122_id("elona.material", material_id)) end },
   objlv        = { to = "level" },
   fixlv        = { to = "quality", type = Enum.Quality },
   irangehit    = { to = "effective_range", type = "int_list", default = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
   ibitvaluable = { to = "is_precious", cb = function(valuable) if valuable ~= 0 then return true end end },
   relaskill    = { to = "skill", cb = function(skill_id) return assert(Compat.convert_122_id("base.skill", skill_id)) end },
   -- irangepow    = { to = "effective_power", type = "int_list", default = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }, -- TODO
   author       = { to = "citem_author", type = "string" },
   ieffect = {
      to = "on_use",
      cb = function(_)
         return CodeGenerator.gen_literal [[
function(self, params)
   return true
end
]]
      end
   },
}

local function apply_spec(result, spec, file_data)
   for k, v in pairs(spec) do
      local ty = v.type or "number"
      local value
      if ty == "number" then
         local default = v.default or 0
         value = get_number(file_data, k, default)
      elseif ty == "string" then
         local default = v.default or {}
         value = get_string(file_data, k, default)
      elseif ty == "int_list" then
         local default = v.default or {}
         value = get_int_list(file_data, k, default)
      elseif type(ty) == "table" and ty.__enum then
         local default = v.default or 0
         value = get_number(file_data, k, default)
         if value then
            assert(ty:has_value(value))
         end
      else
         error("Unknown type " .. ty)
      end

      if value then
         if v.cb then
            value = v.cb(value)
         end
         result[v.to] = value
      end
   end
end

local function make_item_locale_data(item_data, locale, mod_id, item_id)
   local result = {}

   local is_jp = locale == "jp"

   local name = get_string(item_data, "name")
   if name then
      local split = string.split(name, ",")
      if is_jp then
         result.name = split[2]
      else
         result.name = split[1]
      end
   end

   if is_jp then
      local iknownnameref = get_string(item_data, "iknownnameref")
      if iknownnameref then
         result.unidentified_name = iknownnameref
      end

      local ialphanameref = get_string(item_data, "ialphanameref")
      if ialphanameref then
         result.katakana_name = ialphanameref
      end
   end

   local txt_code
   if is_jp then
      txt_code = "JP"
   else
      txt_code = "EN"
   end

   local txt = item_data.txt[txt_code]
   if txt then
      local i = 0
      while true do
         local desc_entry = txt["txtdescription" .. i]
         if desc_entry == nil then
            break
         end

         local desc_text = Sjis.to_utf8(desc_entry[1])
         if desc_text == "nodescription" then
            desc_text = ""
         end

         result.desc = result.desc or {}
         result.desc["_" .. i] = {
            text = desc_text,
         }

         i = i + 1
      end
   end

   return {
      item = {
         info = {
            [mod_id] = {
               [item_id] = result
            }
         }
      }
   }
end

local function is_ascii_only(str)
   for c in string.chars(str) do
      if string.byte(c) >= 128 then
         return false
      end
   end
   return true
end

local function find_item_type(elona_item_type)
   local filter = function(t) return t.ordering == elona_item_type end
   local ty = data["base.item_type"]:iter():filter(filter):nth(1)
   if ty == nil then
      error("Could not find Elona item type " .. elona_item_type)
   end
   return ty._id
end

function CustomItemDecoder.decode(content, mod_id, item_id)
   assert(type(mod_id) == "string", "Please provide a mod ID.")

   local archive = ArchiveUnpacker.unpack_string(content)

   -- item1.t: ignored
   -- local ignored = result["item1.t"]

   -- item2.t: BMP format image
   local item_bmp = archive["item2.t"]

   -- item3.t: Custom item data, as plain text
   local item_data = archive["item3.t"]

   item_data = CustomFileParser.parse(item_data)
   item_data = CustomFileDecoder.decode(item_data)

   if item_id == nil then
      local name = get_string(item_data, "name")
      if name then
         local split = string.split(name, ",")
         if is_ascii_only(split[1]) then
            item_id = split[1]:gsub(" ", "_")
         end
      end
   end

   item_id = item_id or "$item_id$"

   local chip_result = {
      _bmp = item_bmp
   }

   apply_spec(chip_result, chip_spec, item_data)

   local result = {
      _type = "base.item",
      _id = ("%s.%s"):format(mod_id, item_id)
   }

   apply_spec(result, item_spec, item_data)

   for i = 0, 8 do
      local fixenc = get_int_list(item_data, "fixenc" .. i, { 0, 0 })
      if fixenc then
         error("TODO enchantments")
      end
   end

   local light = get_number(item_data, "ilight")
   if light then
      error("TODO light")
   end

   local gods = get_int_list(item_data, "givegod", { -1 })
   if gods then
      result.gods = {}
      for _, elona_god_id in ipairs(gods) do
         table.insert(result.gods, Compat.convert_122_id("elona.god", elona_god_id))
      end
   end

   local tags = get_string(item_data, "ifilterref")
   if tags then
      result.tags = {}
      for _, tag in ipairs(string.split(tags, "/")) do
         if tag ~= "" then
            table.insert(result.tags, tag)
         end
      end
   end

   result.categories = {}
   local major_category = get_number(item_data, "reftype")
   if major_category then
      table.insert(result.categories, find_item_type(major_category))
   end
   local minor_category = get_number(item_data, "reftypeminor")
   if minor_category then
      table.insert(result.categories, find_item_type(minor_category))
   end

   local locale_data = {
      jp = make_item_locale_data(item_data, "jp", mod_id, item_id),
      en = make_item_locale_data(item_data, "en", mod_id, item_id),
   }

   return {
      chip = chip_result,
      data = result,
      locale_data = locale_data
   }
end

function CustomItemDecoder.decode_file(filepath, mod_id, item_id)
   local content = Fs.read_all(filepath)
   return CustomItemDecoder.decode(content, mod_id, item_id)
end

return CustomItemDecoder
