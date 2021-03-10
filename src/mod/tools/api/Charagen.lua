--- Character generation algorithm for Elona.
--- @module Charagen
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Enum = require("api.Enum")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Hash = require("mod.elona_sys.api.Hash")
local Event = require("api.Event")

local Charagen = {}

-- fltselects:
--  1: at, younger_sister_of_mansion, maid, moyer, bug, younger_sister
--  2: isca, mad_scientist, goda
--  3: little_sister, cacy, ebon, noel, loyter, big_daddy, poppy
--  4: silver_wolf, twintail
--  5: town_child, mercenary, old_person, beggar
--  7: elder, citizen, citizen_of_cyber_dome, wizard, bard, hot_spring_maniac
--  9: guard, fairy, acid_slime, bat, rook, gagu, artist, prisoner
-- quality:
--  1 is bad, 6 is special

local sampler = nil
local hash = ""

local function clear_cache_itemgen(_, params)
   if params.hotloaded_types["base.chara"] then
      sampler = nil
      hash = ""
   end
end

Event.register("base.on_hotload_end", "Clear charagen cache", clear_cache_itemgen)

local function chara_gen_weight(chara, objlv)
   return math.floor((chara.rarity or 100000) / (500 + math.abs(chara.level - objlv) * chara.coefficient))
end

function Charagen.random_chara_id_raw(objlv, fltselect, category, race_filter, tag_filters)
   objlv = objlv or 0
   fltselect = fltselect or 0
   category = category or 0
   race_filter = race_filter or nil
   tag_filters = tag_filters or {}

   -- Speed up multiple consecutive generations with the exact same parameters
   -- by hashing them and comparing the hash to that of the last generation.
   local new_hash = Hash.hash(objlv, fltselect, category, race_filter, tag_filters)
   if new_hash ~= hash then
      sampler = nil
   end
   hash = new_hash

   if sampler == nil then
      local pred = function(chara)
         if objlv > 0 and (chara.level or 0) > objlv then
            return false
         end

         if fltselect ~= (chara.fltselect or 0) then
            return false
         end

         if chara.is_unique and NpcMemory.generated(chara._id) > 0 then
            return false
         end

         if category ~= 0 and category ~= chara.category then
            return false
         end

         if race_filter ~= nil and race_filter ~= chara.race then
            return false
         end

         for _, tag in ipairs(tag_filters) do
            if not table.index_of(chara.tags or {}, tag) then
               return false
            end
         end

         if chara.rarity <= 0 then
            return false
         end

         return true
      end

      local candidates = data["base.chara"]:iter():filter(pred)
      sampler = WeightedSampler:new()

      for _, chara in candidates:unwrap() do
         local weight = chara_gen_weight(chara, objlv)
         sampler:add(chara._id, weight)
      end
   end

   return sampler:sample()
end

function Charagen.random_chara_id(level, quality, fltselect, category, race_filter, tag_filters)
   if category == 0 and #tag_filters == 0 and race_filter == nil then
      if quality == Enum.Quality.Good and Rand.one_in(20) then
         fltselect = Enum.FltSelect.Unique
      end
      if quality == Enum.Quality.Great and Rand.one_in(10) then
         fltselect = Enum.FltSelect.Unique
      end
   end

   local id = Charagen.random_chara_id_raw(level, fltselect, category, race_filter, tag_filters)

   if id == nil then
      if fltselect == Enum.FltSelect.Unique or quality == Enum.Quality.Unique then
         quality = Enum.Quality.Great
      end
      level = level + 10
      id = Charagen.random_chara_id_raw(level, fltselect, category, race_filter, tag_filters)
   end

   return id or "elona.bug", quality
end

--- Creates a random character.
---
--- @tparam[opt] int x
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
--- test
--- test2
--- @tparam[opt] ILocation where
--- @treturn[opt] IChara
function Charagen.create(x, y, params, where)
   params = params and table.deepcopy(params) or {}

   params.quality = params.quality or Enum.Quality.Bad
   params.level = params.level or 0
   params.fltselect = params.fltselect or nil
   params.category = params.category or nil
   params.create_params = params.create_params or {}
   params.tag_filters = params.tag_filters or {}
   params.race_filter = params.race_filter or nil

   local id = params.id or nil
   if id == nil then
      local quality
      id, quality = Charagen.random_chara_id(params.level,
                                             params.quality,
                                             params.fltselect,
                                             params.category,
                                             params.race_filter,
                                             params.tag_filters)
      if quality then
         params.quality = quality
      end
   end

   local create_params = params.create_params
   create_params.quality = params.quality
   create_params.level = params.initial_level or params.level
   create_params.ownerless = params.ownerless
   local chara = Chara.create(id, x, y, create_params, where)

   return chara
end

return Charagen
