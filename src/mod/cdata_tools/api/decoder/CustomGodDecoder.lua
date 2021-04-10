local Fs = require("api.Fs")
local Util = require("mod.cdata_tools.api.Util")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local CustomFileParser = require("mod.cdata_tools.api.custom_file.CustomFileParser")
local CustomFileDecoder = require("mod.cdata_tools.api.custom_file.CustomFileDecoder")
local ArchiveUnpacker = require("mod.cdata_tools.api.archive.ArchiveUnpacker")

local CustomGodDecoder = {}

-- local god_spec = {
--    author = { to = "custom_author", type = "string" },
--    bonus = "150013,160013,190013,1080014,1720013,1740013,1890013,5C0009",
--    filter = "",
--    foodbonus = "1503,1603,1903",
--    give = "440,290,505,623,624",
--    miracle0 = "Travel of Time,ŽžŠ ks,16,1005,10,3006,150 + {attb} / 4 + {faith} / 80,{efp} / 125 + 2 + {attb} / 50,{efp} / 60 + 9 + 1,0,54,100 + {efp} / 4",
--    miracle1 = "Salvation of Madoka,ƒVƒ…[ƒeƒBƒ“ƒOƒXƒ^[,16,11,60,10000,2000,5 + {attb} / 10,{efp} / 7 + 5 + 1,{efp} / 2,60,200 + {faith} / 200",
--    ["miracle?"] = { "Cupid Arrow of Young Sisters,ˆ •‚ ƒeƒI,16,11,220,10000,0,0,0,0,53,200 + {faith} / 200", "Cupid Arrow of Young Sisters,’n–‚ õü,16,1,10,9006,350,{efp} / 50 + 1 + {attb} / 20,{efp} / 26 + 4 + 1,{faith} * 3 / 10000,56,200 + {efp} / 3", "Cure of Young Sisters,“dŒ‚‚ Ö,16,3,20,3002,1000,{efp} / 80 + 1 + {attb} / 20,{efp} / 12 + 2 + 1,{faith} * 3 / 10000,52,180 + {efp} / 4", "Cure of Young Sisters,ƒz[ƒŠ[ƒ”ƒFƒCƒ‹(” Í),15,1010,20,3006,90 + {attb} * 6 * ({faith} * 3 / 10000),0,0,0,0,0", "Cure of Young Sisters, ã‚ ¶(” Í),16,1008,8,3006,90 + {attb} * 6 * ({faith} * 3 / 10000),0,0,0,0,0" },
--    name = "Madoka of Fortune Circle,‰~Š    ©",
--    shortname = "madoka,‚  ©",
--    specialfoodbonus = "191600,150150,160150",
--    specialpower = "404,450 + {attb} / 3 + {faith} / 50",
--    specialpoweralias = "White Ray,‹~ ·‚ ‚«Œõ"
-- }

local god_spec = {
   author = { to = "custom_author", type = "string" },
   bonus = {
      to = "blessings",
      type = "int_list",
      cb = function(bonus)
         local map = function(b)
            -- >>>>>>>> oomSEST/src/southtyris.hsp:35703 			if (sdata(bonusskill, r1) > 0) { ...
            local skill_elona_id = b % 10000
            local bonus_limit = math.floor(b / 10000)
            local skill_id = assert(Compat.convert_122_id("base.skill", skill_elona_id))
            local bonust = math.min(20 - bonus_limit, 1)
            local skill_proto = data["base.skill"]:ensure(skill_id)
            if skill_proto.type == "stat" then
               bonus_limit = 10 + bonus_limit * 10
            end
            -- This formula is from oomSEST.
            return CodeGenerator.gen_literal(([[

function(chara)
   local skill_id = "%s"
   if chara:has_skill(skill_id) then
       local amount = math.clamp((chara.piety or 0) / %d, 1, %d + chara:skill_level("elona.faith") / 5)
       chara:mod_skill_level(skill_id, amount, "add")
   end
end]]):format(skill_id, 50 * bonust, bonus_limit))
            -- <<<<<<<< oomSEST/src/southtyris.hsp:35710 			} ..
         end

         return fun.iter(bonus):map(map):to_list()
      end
   },

   -- Not used, according to oomSEST.
   -- filter = Util.filter_spec,

   foodbonus = { to = "__oomsest_foodbonus", type = "int_list" }, -- TODO

   give = {
      to = "offerings",
      type = "int_list",
      cb = function(give)
         local map = function(id)
            if id < 10000 then
               local item = assert(Compat.convert_122_id("base.item", id))
               return { type = "item", id = item }
            else
               local category = assert(Compat.convert_122_id("base.item_type", id))
               return { type = "category", id = category }
            end
         end

         return fun.iter(give):map(map):to_list()
      end
   },

   -- TODO
   -- miracle0 = "Travel of Time,ŽžŠ ks,16,1005,10,3006,150 + {attb} / 4 + {faith} / 80,{efp} / 125 + 2 + {attb} / 50,{efp} / 60 + 9 + 1,0,54,100 + {efp} / 4",
   -- miracle1 = "Salvation of Madoka,ƒVƒ…[ƒeƒBƒ“ƒOƒXƒ^[,16,11,60,10000,2000,5 + {attb} / 10,{efp} / 7 + 5 + 1,{efp} / 2,60,200 + {faith} / 200",
   -- ["miracle?"] = { "Cupid Arrow of Young Sisters,ˆ •‚ ƒeƒI,16,11,220,10000,0,0,0,0,53,200 + {faith} / 200", "Cupid Arrow of Young Sisters,’n–‚ õü,16,1,10,9006,350,{efp} / 50 + 1 + {attb} / 20,{efp} / 26 + 4 + 1,{faith} * 3 / 10000,56,200 + {efp} / 3", "Cure of Young Sisters,“dŒ‚‚ Ö,16,3,20,3002,1000,{efp} / 80 + 1 + {attb} / 20,{efp} / 12 + 2 + 1,{faith} * 3 / 10000,52,180 + {efp} / 4", "Cure of Young Sisters,ƒz[ƒŠ[ƒ”ƒFƒCƒ‹(” Í),15,1010,20,3006,90 + {attb} * 6 * ({faith} * 3 / 10000),0,0,0,0,0", "Cure of Young Sisters, ã‚ ¶(” Í),16,1008,8,3006,90 + {attb} * 6 * ({faith} * 3 / 10000),0,0,0,0,0" },

   specialfoodbonus = { to = "__oomsest_specialfoodbonus", type = "int_list" }, -- TODO

   -- TODO
   -- specialpower = "404,450 + {attb} / 3 + {faith} / 50",
}

local function make_god_locale_data(item_data, locale, mod_id, god_id)
   local result = {}

   local is_jp = locale == "jp"

   result.name = Util.get_localized_string(item_data, "name", is_jp)
   result.short_name = Util.get_localized_string(item_data, "shortname", is_jp)
   -- result.special_power_alias = Util.get_localized_string(item_data, "specialpoweralias", is_jp) -- TODO

   return {
      god = {
         _ = {
            [mod_id] = {
               [god_id] = result
            }
         }
      }
   }
end

function CustomGodDecoder.decode(archive, mod_id, god_id)
   assert(type(mod_id) == "string", "Please provide a mod ID.")

   -- god1.t: ignored
   -- local ignored = result["god1.t"]

   -- god2.t: Custom god data, as plain text
   local god_data = archive["god2.t"]

   god_data = CustomFileParser.parse(god_data)
   god_data = CustomFileDecoder.decode(god_data)

   if god_id == nil then
      local shortname = Util.get_localized_string(god_data, "shortname", false)
      if shortname and Util.is_ascii_only(shortname) then
         god_id = shortname:gsub(" ", "_")
      end
   end

   god_id = god_id or "$god_id$"

   local proto = {
      _type = "elona.god",
      _id = god_id,

      is_primary_god = false,
      servant = ("%s.servant"):format(mod_id),
      artifact = ("%s.artifact"):format(mod_id),
      summon = ("%s.branch"):format(mod_id),
   }

   local requires = Util.apply_spec(proto, god_spec, god_data, mod_id)
   local result = {
      proto = proto,
      requires = requires
   }

   local txt = god_data.txt
   print("TODO custom talk")

   local locale_data = {
      jp = make_god_locale_data(god_data, "jp", mod_id, god_id),
      en = make_god_locale_data(god_data, "en", mod_id, god_id),
   }

   return {
      data = result,
      locale_data = locale_data,
      requires = requires
   }
end

function CustomGodDecoder.decode_file(filepath, mod_id, god_id)
   local content = Fs.read_all(filepath)
   local archive = ArchiveUnpacker.unpack_string(content)
   return CustomGodDecoder.decode(archive, mod_id, god_id)
end

return CustomGodDecoder
