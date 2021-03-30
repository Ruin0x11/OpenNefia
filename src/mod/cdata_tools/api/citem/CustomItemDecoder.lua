local Enum = require("api.Enum")
local Fs = require("api.Fs")
local Util = require("mod.cdata_tools.api.Util")
local Sjis = require("mod.extlibs.api.Sjis")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local CustomFileParser = require("mod.cdata_tools.api.custom_file.CustomFileParser")
local CustomFileDecoder = require("mod.cdata_tools.api.custom_file.CustomFileDecoder")
local ArchiveUnpacker = require("mod.cdata_tools.api.archive.ArchiveUnpacker")

local CustomItemDecoder = {}

local FLTMAJOR_TO_EQSLOT  = {
   ["elona.equip_head"]   = "elona.head",
   ["elona.equip_neck"]   = "elona.neck",
   ["elona.equip_back"]   = "elona.back",
   ["elona.equip_body"]   = "elona.body",
   ["elona.equip_melee"]  = "elona.hand",
   ["elona.equip_shield"] = "elona.hand",
   ["elona.equip_ring"]   = "elona.ring",
   ["elona.equip_wrist"]  = "elona.arm",
   ["elona.equip_leg"]    = "elona.leg",
   ["elona.equip_ranged"] = "elona.ranged",
   ["elona.ammo"]         = "elona.ammo",
   ["elona.waist"]        = "elona.waist",
}

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
   material     = { to = "material", cb = function(material_id) return assert(Compat.convert_122_id("elona.item_material", material_id)) end },
   objlv        = { to = "level" },
   fixlv        = { to = "quality", type = Enum.Quality },
   irangehit    = { to = "effective_range", type = "int_list", default = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
   ibitvaluable = { to = "is_precious", cb = function(valuable) if valuable ~= 0 then return true end end },
   relaskill    = { to = "skill", cb = function(skill_id) return assert(Compat.convert_122_id("base.skill", skill_id)) end },
   -- irangepow    = { to = "effective_power", type = "int_list", default = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }, -- TODO
   author       = { to = "custom_author", type = "string" },
   ieffect = {
      to = "on_use",
      cb = function(_)
         return CodeGenerator.gen_literal [[
function(self, params)
   return true
end]]
      end
   },
}

local function make_item_locale_data(item_data, locale, mod_id, item_id)
   local result = {}

   local is_jp = locale == "jp"

   local name = Util.get_string(item_data, "name")
   if name then
      local split = string.split(name, ",")
      if is_jp then
         result.name = split[2]
      else
         result.name = split[1]
      end
   end

   if is_jp then
      local iknownnameref = Util.get_string(item_data, "iknownnameref")
      if iknownnameref then
         result.unidentified_name = iknownnameref
      end

      local ialphanameref = Util.get_string(item_data, "ialphanameref")
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

   -- TODO locale namespace standardization
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

local function find_item_type(elona_item_type)
   local filter = function(t) return t.ordering == elona_item_type end
   local ty = data["base.item_type"]:iter():filter(filter):nth(1)
   if ty == nil then
      error("Could not find Elona item type " .. elona_item_type)
   end
   return ty._id
end

function CustomItemDecoder.decode(archive, mod_id, item_id)
   assert(type(mod_id) == "string", "Please provide a mod ID.")

   -- item1.t: ignored
   -- local ignored = result["item1.t"]

   -- item2.t: BMP format image
   local item_bmp = archive["item2.t"]

   -- item3.t: Custom item data, as plain text
   local item_data = archive["item3.t"]

   item_data = CustomFileParser.parse(item_data)
   item_data = CustomFileDecoder.decode(item_data)

   if item_id == nil then
      local name = Util.get_string(item_data, "name")
      if name then
         local split = string.split(name, ",")
         if Util.is_ascii_only(split[1]) then
            item_id = split[1]:gsub(" ", "_")
         end
      end
   end

   item_id = item_id or "$item_id$"

   local chip_result = {
      _bmp = item_bmp,
      proto = {
         _type = "base.chip",
         _id = ("item_%s"):format(item_id)
      },
      requires = {}
   }

   local requires = Util.apply_spec(chip_result, chip_spec, item_data)
   chip_result.requires = requires

   local proto = {
      _type = "base.item",
      _id = item_id
   }

   requires = Util.apply_spec(proto, item_spec, item_data)
   local result = {
      proto = proto,
      requires = requires,

      image = ("%s.%s"):format(mod_id, chip_result.proto._id)
   }

   for i = 0, 8 do
      local fixenc = Util.get_int_list(item_data, "fixenc" .. i, { 0, 0 })
      if fixenc then
         print(inspect(fixenc))
         print("TODO enchantments")
      end
   end

   local light = Util.get_number(item_data, "ilight")
   if light then
      print(inspect(light))
      print("TODO light")
   end

   local gods = Util.get_int_list(item_data, "givegod", { -1 })
   if gods then
      result.gods = {}
      for _, elona_god_id in ipairs(gods) do
         table.insert(result.gods, Compat.convert_122_id("elona.god", elona_god_id))
      end
   end

   local tags = Util.get_string(item_data, "ifilterref")
   if tags then
      result.tags = {}
      for _, tag in ipairs(string.split(tags, "/")) do
         if tag ~= "" then
            table.insert(result.tags, tag)
         end
      end
   end

   result.categories = {}
   local major_category = Util.get_number(item_data, "reftype")
   if major_category then
      local major_item_type = find_item_type(major_category)
      table.insert(result.categories, major_item_type)
      local equip_slot = FLTMAJOR_TO_EQSLOT[major_item_type]
      if equip_slot then
         result.equip_slots = result.equip_slots or {}
         table.insert(result.equip_slots, equip_slot)
      end
   end
   local minor_category = Util.get_number(item_data, "reftypeminor")
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
   local archive = ArchiveUnpacker.unpack_string(content)
   return CustomItemDecoder.decode(archive, mod_id, item_id)
end

return CustomItemDecoder
