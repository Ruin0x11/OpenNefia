local Ipadic = require("mod.aquestalk.api.Ipadic")

local Mecab = {}

local mecab = nil

local NA = "な"
local NI = "に"
local TE = "て"
local DE = "で"
local BA = "ば"
local NN = "ん"
local SA = "さ"

local feature_keys = {
   "pos",
   "pos2",
   "pos3",
   "pos4",
   "inflection_type",
   "inflection_form",
   "lemma",
   "reading",
   "pronounciation"
}

local function parse_features(line)
   local features = {}
   local i = 1
   for tok in line:gmatch("([^,]+)[,]?") do
      local k = feature_keys[i]
      features[k] = tok
      i = i + 1
   end
   return features
end

local function to_node(line)
   local spl = string.split(line, "\t")

   local literal = spl[1]
   local features = parse_features(spl[2])
   features.literal = literal

   return {
      literal = literal,
      features = features
   }
end

local function to_nodes(raw)
   local nodes = {}

   for _, line in ipairs(string.split(raw), "\n") do
      if line == "EOS" then
         break
      end
      if line ~= "" then
         nodes[#nodes+1] = to_node(line)
      end
   end

   return nodes
end

local function to_words(nodes)
   local words = {}
   local previous = nil

   for i, node in ipairs(nodes) do
      local pos = nil
      local grammar = nil
      local eat_next = false
      local eat_lemma = true
      local attach_to_previous = false
      local attach_to_lemma = false
      local update_pos = false

      local features = node.features

      if features.pos == Ipadic.MEISHI then
         pos = "noun"

         local pos2 = features.pos2
         if pos2 == Ipadic.KOYUUMEISHI then
            pos = "proper_noun"
         elseif pos2 == Ipadic.DAIMEISHI then
            pos = "pronoun"
         elseif pos2 == Ipadic.FUKUSHIKANOU
            or pos2 == Ipadic.SAHENSETSUZOKU
            or pos2 == Ipadic.KEIYOUDOUSHIGOKAN
            or pos2 == Ipadic.NAIKEIYOUSHIGOKAN
         then
            if i < #nodes then
               local following = nodes[i+1].features
               if following.inflection_type == Ipadic.SAHEN_SURU then
                  pos = "verb"
                  eat_next = true
               elseif following.inflection_type == Ipadic.TOKUSHU_DA then
                  pos = "adjective"
                  if following.inflection_type == Ipadic.TAIGENSETSUZOKU then
                     eat_next = true
                     eat_lemma = false
                  end
               elseif following.inflection_type == Ipadic.TOKUSHU_NAI then
                  pos = "adjective"
               elseif following.pos == Ipadic.JOSHI and following.literal == NI then
                  pos = "adverb"
                  eat_next = false
               end
            end
         elseif pos2 == Ipadic.HIJIRITSU
            or pos2 == Ipadic.TOKUSHU
         then
            if i < #nodes then
               local following = nodes[i+1].features
               local pos3 = features.pos3
               if pos3 == Ipadic.FUKUSHIKANOU then
                  if following.pos == Ipadic.JOSHI and following.literal == NI then
                     pos = "adverb"
                     eat_next = true
                  end
               elseif pos3 == Ipadic.JODOUSHIGOKAN then
                  if following.inflection_type == Ipadic.TOKUSHU_DA then
                     pos = "verb"
                     grammar = "auxillary"
                     if following.inflection_form == Ipadic.TAIGENSETSUZOKU then
                        eat_next = true
                     elseif following.pos == Ipadic.JOSHI and following.pos2 == Ipadic.FUKUSHIKA then
                        pos = "adverb"
                        eat_next = true
                     end
                  end
               elseif pos3 == Ipadic.KEYOUDOUSHIGOKAN then
                  pos = "adjective"
                  if (following.inflection_type == Ipadic.TOKUSHU_DA and following.inflection_form == Ipadic.TAIGENSETSUZOKU)
                     or following.pos2 == Ipadic.RENTAIKA
                  then
                     eat_next = true
                  end
               end
            end
         elseif pos2 == Ipadic.KAZU then
            pos = "number"
            -- TODO
         elseif pos2 == Ipadic.SETSUBI then
            if features.pos3 == Ipadic.JINMEI then
               pos = "suffix"
            else
               if features.pos3 == Ipadic.TOKUSHU and features.lemma == SA then
                  pos = "noun"
                  update_pos = true
               else
                  attach_to_lemma = true
               end
               attach_to_previous = true
            end
         elseif pos2 == Ipadic.SETSUZOKUSHITEKI then
            pos = "conjunction"
         elseif pos2 == Ipadic.DOUSHIHIJIRITSUTEKI then
            pos = "verb"
            grammar = "nominal"
         end
      elseif features.pos == Ipadic.SETTOUSHI then
         pos = "prefix"
      elseif features.pos == Ipadic.JODOUSHI then
         pos = "postposition"
         local set = table.set {
            Ipadic.TOKUSHU_TA,
            Ipadic.TOKUSHU_NAI,
            Ipadic.TOKUSHU_TAI,
            Ipadic.TOKUSHU_MASU,
            Ipadic.TOKUSHU_NU
         }
         if (previous == nil or previous.pos2 == Ipadic.KAKARIJOSHI) and set[features.inflection_type] then
            attach_to_previous = true
         elseif features.inflection_type == Ipadic.FUHEKAGATA and features.lemma == NN then
            attach_to_previous = true
         elseif (features.inflection_type == Ipadic.TOKUSHU_DA
                    or features.inflection_type == Ipadic.TOKUSHU_DESU)
            and features.literal ~= NA
         then
            pos = "verb"
         end
      elseif features.pos == Ipadic.DOUSHI then
         pos = "verb"
         if features.pos2 == Ipadic.SETSUBI then
            attach_to_previous = true
         elseif features.pos2 == Ipadic.HIJIRITSU and features.inflection_form ~= Ipadic.MEIREI_I then
            attach_to_previous = true
         end
      elseif features.pos == Ipadic.KEIYOUSHI then
         pos = "adjective"
      elseif features.pos == Ipadic.JOSHI then
         pos = "postposition"
         if features.pos2 == Ipadic.SETSUZOKUJOSHI and table.set({TE, DE, BA})[features.literal] then
            attach_to_previous = true
         end
      elseif features.pos == Ipadic.RENTAISHI then
         pos = "determiner"
      elseif features.pos == Ipadic.SETSUZOKUSHI then
         pos = "conjunction"
      elseif features.pos == Ipadic.FUKUSHI then
         pos = "adverb"
      elseif features.pos == Ipadic.KIGOU then
         pos = "symbol"
      elseif features.pos == Ipadic.FIRAA or features.pos == Ipadic.KANDOUSHI then
         pos = "interjection"
      elseif features.pos == Ipadic.SONOTA then
         pos = "other"
      end

      if attach_to_previous and #words > 0 then
         local word = words[#words]
         table.insert(word.tokens, features)
         word.word = word.word .. features.literal
         if features.reading then
            word.extra.reading = word.extra.reading .. features.reading
         end
         if features.pronounciation then
            word.extra.pronounciation = word.extra.pronounciation .. features.pronounciation
         end
         if attach_to_lemma then
            word.lemma = word.lemma .. features.lemma
         end
         if update_pos then
            word.part_of_speech = pos
         end
      else
         pos = pos or "unknown"
         local word = {
            word = features.literal,
            lemma = features.lemma,
            part_of_speech = pos,
            tokens = { features },
            extra = {
               reading = features.reading or "",
               pronounciation = features.pronounciation or "",
               grammar = grammar
            }
         }

         if eat_next then
            local following = nodes[i+1].features
            table.insert(word.tokens, following)
            word.word = word.word .. following.literal
            if following.reading then
               word.extra.reading = word.extra.reading .. following.reading
            end
            if following.pronounciation then
               word.extra.pronounciation = word.extra.pronounciation .. following.pronounciation
            end
            if eat_lemma then
               word.lemma = word.lemma .. following.lemma
            end
         end

         words[#words+1] = word
      end

      previous = features
   end

   return words
end

function Mecab.parse(text)
   if mecab == nil then
      local ok, lib = pcall(require, "lua-mecab")
      if not ok then return false, lib end
      mecab = lib
   end

   local parser = mecab:new("")

   local raw = parser:parse(text)
   local nodes = to_nodes(raw)
   local words = to_words(nodes)

   return true, words
end

return Mecab
