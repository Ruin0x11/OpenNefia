local Chara = require("api.Chara")
local Event = require("api.Event")
local Map = require("api.Map")
local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")

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

local function chara_gen_weight(chara, objlv)
   return math.floor((chara.rarity or 100000) / (500 + math.abs(chara.level - objlv) * chara.coefficient))
end

function Charagen.random_chara_id_raw(objlv, fltselect, category, race_filter, tag_filters)
   objlv = objlv or 0
   fltselect = fltselect or 0
   category = category or 0
   race_filter = race_filter or nil
   tag_filters = tag_filters or {}

   local pred = function(chara)
      if (chara.level or 0) > objlv then
         return false
      end

      if fltselect ~= (chara.fltselect or 0) then
         return false
      end

      local has_seen = false -- TODO
      if chara.is_unique and has_seen then
         return false
      end

      if category ~= 0 and category ~= chara.category then
         return false
      end

      if race_filter ~= nil and race_filter ~= chara.race then
         return false
      end

      for _, tag in ipairs(tag_filters) do
         if not table.has_value(chara.tags or {}, tag) then
            return false
         end
      end

      return true
   end

   local candidates = data["base.chara"]:iter():filter(pred)
   local sampler = WeightedSampler:new()

   for _, chara in candidates:unwrap() do
      local weight = chara_gen_weight(chara, objlv)
      sampler:add(chara._id, weight)
   end

   return sampler:sample()
end

local function do_get_chara_id(params)
   if params.category == 0 and #params.tag_filters == 0 and params.race_filter == nil then
      if params.quality == 3 and Rand.one_in(20) then
         params.fltselect = 2
      end
      if params.quality == 4 and Rand.one_in(10) then
         params.fltselect = 2
      end
   end

   local id = Charagen.random_chara_id_raw(params.level, params.fltselect, params.category)

   if id == nil then
      if params.fltselect == 2 or params.quality == 6 then
         params.quality = 4
      end
      params.level = params.level + 10
      id = Charagen.random_chara_id_raw(params.level, params.fltselect, params.category)
   end

   return id
end

function Charagen.create(x, y, params, where)
   params = params or {}

   params.quality = params.quality or 0
   params.level = params.level or 0
   params.fltselect = params.fltselect or nil
   params.category = params.category or nil
   params.create_params = params.create_params or {}
   params.tag_filters = params.tag_filters or {}
   params.race_filter = params.race_filter or nil

   local id = params.id or nil
   if id == nil then
      id = do_get_chara_id(params)
   end

   local bug_id = "elona.bug"
   id = id or bug_id

   local create_params = params.create_params
   create_params.quality = params.quality
   create_params.level = params.level
   local chara = Chara.create(id, x, y, create_params, where)

   return chara
end

return Charagen
