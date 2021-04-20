local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")
local Hash = require("mod.elona_sys.api.Hash")

local TEXTS = {
   txtAggro = "base.aggro",
   -- txtBye = "base.bye",
   txtCalm = "base.calm",
   txtDead = "base.dead",
   txtKilled = "base.killed",
   txtWelcome = "base.welcome",
}

-- string.split is dumb and doesn't support delimiters with more than 1
-- character...
local function split(str, delimiter)
   local result = {}
   local from  = 1
   local delim_from, delim_to = string.find(str, delimiter, from)
   while delim_from do
      result[#result+1] = string.sub(str, from, delim_from-1)
      from  = delim_to + 1
      delim_from, delim_to = string.find(str, delimiter, from)
   end
   result[#result+1] = string.sub(str, from)
   return result
end

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))

   local texts = {}

   for elona_text_id, text_id in pairs(TEXTS) do
      local s = row[elona_text_id]
      if s and s ~= "" then
         local ts = split(s, "¥n")
         for _, text in ipairs(ts) do
            local jp_en = string.split(text, "#")
            local jp = jp_en[1]
            local en = jp_en[2]

            if jp then
               texts.jp = texts.jp or {}
               texts.jp[text_id] = texts.jp[text_id] or {}
               table.insert(texts.jp[text_id], jp)
            end
            if en then
               en = en:gsub("^{(.*)}$", "\"%1\"")
               texts.en = texts.en or {}
               texts.en[text_id] = texts.en[text_id] or {}
               table.insert(texts.en[text_id], en)
            end
         end
      end
   end

   return {
      _id = _id:gsub(".*%.", ""),
      texts = texts
   }
end

local seen = table.set {}
local dups = {}

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :map(map)
:filter(function(t) return next(t.texts) ~= nil end)
do
   local gen = CodeGenerator:new()

   gen:write("data:add ")
   gen:write_table_start()
   gen:write_key_value("_type", "base.tone")
   gen:write_key_value("_id", row._id)
   gen:tabify()
   gen:tabify()
   gen:write_key_value("texts", row.texts)
   gen:write_table_end()
   gen:tabify()

   print(gen)

   local hash = Hash.hash(row.texts)
   dups[hash] = dups[hash] or {}
   table.insert(dups[hash], row._id)
end

for k, v in pairs(dups) do
   if #v == 1 then
      dups[k] = nil
   end
end

print(inspect(dups))
