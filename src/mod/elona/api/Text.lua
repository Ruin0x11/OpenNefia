local IItem = require("api.item.IItem")
local Sha1 = require("mod.extlibs.api.Sha1")
local Csv = require("mod.elona_sys.api.Csv")
local I18N = require("api.I18N")
local Rand = require("api.Rand")

local Text = {}

local names = nil
local titles = {}

local function convert_en(text)
   if I18N.language() ~= "en" or text:len() == 0 then
      return text
   end

   if text:sub(1, 1) == "*" then
      if text:len() == 1 then
         return text
      end
      return text:gsub("^(%l)(%l)", function(a, b) return a .. string.upper(b) end)
   else
      return text:gsub("^(%l)", string.upper)
   end
end

local function random_name_internal()
   local ind = 1
   if I18N.language() == "en" then
      ind = 2
   end

   local ret = Rand.choice(names)[ind]
   if ret == nil then
      return nil
   end

   if I18N.language() == "jp" and Rand.one_in(8) then
      ret = ret .. "ー"
   end
   if Rand.one_in(5) then
      ret = ret .. Rand.choice(names)[ind+2]
   end

   local len = string.len(ret)
   if len < 4 then
      return nil
   end
   if len < 6 and Rand.one_in(3) then
      return nil
   end
   if len < 8 and Rand.one_in(2) then
      return nil
   end

   if I18N.language() == "jp" then
      if string.match(ret, "^ー") or string.find(ret, "ーッ") then
         return nil
      end
   end

   return convert_en(ret)
end

function Text.random_name()
   if names == nil then
      names = Csv.parse_file("mod/elona/data/csv/name.csv"):to_list()
   end

   return fun.tabulate(random_name_internal):filter(function(i) return i end):nth(1)
end

local function random_title_internal(kind)
   local titles = titles[I18N.language()]

   local ret = ""
   local row, col
   while ret == nil or ret == "" do
      row = Rand.rnd(#titles) + 1
      col = Rand.rnd(14) + 1
      ret = titles[row][col]
   end

   local category = titles[row][15]

   if (kind == "weapon" or kind == "living_weapon")
      and category == "具"
   then
      return nil
   end

   local do_skip = false

   if I18N.language() == "jp" then
   else
      if col == 0 or col == 1 then
         if Rand.one_in(6) then
            ret = ret .. " of"
         elseif Rand.one_in(6) then
            ret = "the " .. ret
            do_skip = true
         end
      end

      if not do_skip then
         ret = ret .. " "
      end

      ret = convert_en(ret)
   end

   if not do_skip then
      local it = nil

      for _ = 1, 100 do
         local row2 = Rand.rnd(#titles) + 1
         if row2 ~= row then
            if not (titles[row2][15] == category
                    and titles[row2][15] ~= "万能"
                    and category ~= "万能")
            then
               if col < 10 then
                  col = Rand.rnd(2) + 1
               else
                  col = Rand.rnd(2) + 10 + 1
               end

               if titles[row2][col] ~= "" then
                  it = titles[row2][col]
                  break
               end
            end
         end
      end

      if not it then
         return nil
      end

      if I18N.language() == "en" then
         it = convert_en(it)
      end

      ret = ret .. it

      if string.len(ret) >= 28 then
         return nil
      end
   end

   if kind == "party" then
      if I18N.language() == "jp" then
         if Rand.one_in(5) then
            local suffix = Rand.choice {
               "団",
               "チーム",
               "パーティー",
               "の集い",
               "の軍",
               "アーミー",
               "隊",
               "の一家",
               "軍",
               "の隊",
               "の団",
            }
            ret = ret .. suffix
         end
      elseif Rand.one_in(2) then
         local prefix = Rand.choice {
            "The army of ",
            "The party of ",
            "The house of ",
            "Clan ",
         }
         ret = prefix .. ret
      else
         local suffix = Rand.choice {
            " Clan",
            " Party",
            " Band",
            " Gangs",
            " Gathering",
            " House",
            " Army",
         }
         ret = ret .. suffix
      end
   end

   return ret
end

local TITLE_FILES = {
   jp = "ndata.csv",
   en = "ndata-e.csv"
}

--- @tparam[opt] string kind One of "character" (default), "weapon",
--- "party" or "living_weapon"
--- @tparam[opt] uint seed
--- @treturn string
function Text.random_title(kind, seed)
   kind = kind or "character"
   local lang = I18N.language()
   if titles[lang] == nil then
      local file = TITLE_FILES[lang]
      if file == nil then
         file = TITLE_FILES["en"]
      end

      titles[lang] = Csv.parse_file("mod/elona/data/csv/" .. file):to_list()
   end

   if seed then
      Rand.set_seed(seed)
   end

   -- keep trying until we get a valid title
   local result = fun.tabulate(function() return random_title_internal(kind) end)
                        :filter(function(i) return i end)
                        :nth(1)

   if seed then
      Rand.set_seed()
   end

   return result
end

local function string_to_int(str)
   local hash_chunks = {Sha1.sha1(str)} -- list of ints
   return fun.iter(hash_chunks):foldl(fun.op.add, 0)
end

-- TODO hardcoded
local RANDOM_COLORS = {
   { 255, 255, 255 },
   { 175, 255, 175 },
   { 255, 155, 155 },
   { 175, 175, 255 },
   { 255, 215, 175 },
   { 255, 255, 175 },
}

--- Gets the name and color of an unidentified item.
--- @tparam base.item|IItem item
--- @tparam[opt] uint seed Seed used for randomized color/name
--- @treturn string,color
function Text.unidentified_item_params(item, seed)
   local unknown_name = I18N.get_optional("item.info." .. item._id .. ".unidentified_name")
   if unknown_name then
      return unknown_name, item.color
   end

   local has_random_name = item.has_random_name

   if has_random_name then
      seed = seed or save.base.random_seed
      local index = (string_to_int(item._id) % seed) % 6
      unknown_name = I18N.get("ui.random_item." .. item.originalnameref2 .. "._" .. index)
         .. I18N.space()
         .. I18N.get("ui.random_item." .. item.originalnameref2 .. ".name")
      local color = RANDOM_COLORS[index+1]
      return unknown_name, color
   end

   return item.name, item.color
end

return Text
