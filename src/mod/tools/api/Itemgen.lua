local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local Map = require("api.Map")
local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")

-- This shouldn't be in base, since it has a lot of logic specific to
-- elona.
local Itemgen = {}

-- fltselects:
--  character:
--    1: at, younger_sister_of_mansion, maid, moyer, bug, younger_sister
--    2: isca, mad_scientist, goda
--    3: little_sister, cacy, ebon, noel, loyter, big_daddy, poppy
--    4: silver_wolf, twintail
--    5: town_child, mercenary, old_person, beggar
--    7: elder, citizen, citizen_of_cyber_dome, wizard, bard, hot_spring_maniac
--    9: guard, fairy, acid_slime, bat, rook, gagu, artist, prisoner
--  item:
--    nil: vegetable_seed, long_staff, scroll_of_greater_identify
--    1: bug, fountain, tamers_whip, wallet, putitoro
--    2: shield_of_thorn, hiryu_to, skeleton_key, bow_of_vinderre, zantetsu, ether_dagger
--    3: gem_stone_of_mani, wind_bow, magic_fruit, statue_of_jure, diablo
--    8: tree_of_naked, tree_of_fir, christmas_tree

local function item_gen_weight(item, objlv)
   return math.floor((item.rarity or 0) / (1000 + math.abs((item.level or 0) - objlv) * (item.coefficient or 0)) + 1)
end

local bug_id = "elona.bug"

function Itemgen.random_item_id(objlv, fltselect, categories)
   objlv = objlv or 0
   fltselect = fltselect or 0
   local filter = function(item)
      if (item.level or 0) > objlv then
         return false
      end
      if (item.fltselect or 0) ~= fltselect then
         return false
      end

      if categories then
         for cat, _ in pairs(categories) do
            if not item:has_type(cat) then
               return false
            end
         end
      end

      -- fltselect compatibility - item types with no_generate set to
      -- true means they will not be randomly generated unless
      -- explicitly asked for.
      for _, cat in ipairs(item.categories) do
         if data["base.item_type"]:ensure(cat).no_generate then
            if not categories[cat] then
               return false
            end
         end
      end

      return true
   end

   local candidates = data["base.item"]:iter():filter(filter)
   local sampler = WeightedSampler:new()

   for _, item in candidates:unwrap() do
      local weight = item_gen_weight(item, objlv)
      sampler:add(item._id, weight)
   end

   return sampler:sample() or bug_id
end

local function set_fltselect(categories, _type)
   local remove = {}
   for cat, _ in ipairs(categories) do
      if data["base.item_type"]:ensure(cat).no_generate then
         remove[#remove+1] = cat
      end
   end
   table.remove_keys(categories, remove)

   if _type then
      categories[#categories+1] = _type
   end
end

local function get_fltselect(categories)
   return fun.iter(categories)
       :filter(function(cat) return data["base.item_type"]:ensure(cat).no_generate end)
       :nth(1)
end


local function do_generate_item_id(params)
   local fltselect = get_fltselect(params.categories)

   if fltselect == nil and not params.is_shop then
      if params.quality == 3 and Rand.one_in(1000) then
         set_fltselect(params.categories, "elona.unique_item")
      end
      if params.quality == 4 and Rand.one_in(100) then
         set_fltselect(params.categories, "elona.unique_item")
      end
   end

   local id = Itemgen.random_item_id(params.objlv, fltselect, params.categories)

   if id == bug_id then
      if get_fltselect(params.categories) == "elona.unique_item" then
         params.quality = 4
      end
      params.objlv = params.objlv + 10
      set_fltselect(params.categories, nil)
      id = Itemgen.random_item_id(params.objlv, fltselect, params.categories)
   end

   if id == bug_id and params.categories["elona.furniture_altar"] then
      id = "elona.scroll_of_change_material"
   end

   return id
end

function Itemgen.generate_item(x, y, params, where)
   params = params or {}

   params.quality = params.quality or 0
   params.level = params.level or 0
   params.categories = table.set(params.categories or {})

   if params.ownerless then
      where = nil
   else
      where = where or Map.current()
   end

   -- EVENT: before_generate_item
   local chara
   if class.is_an(InstancedMap, where) then
      chara = Chara.player()
   elseif type(where) == "table" and where._type == "base.chara" then
      if where:is_player() or params.always_mod_fixlv then
         chara = where
      end
   end
   if params.quality < 5 and chara and chara:skill_level("elona.stat_luck") > Rand.rnd(5000) then
      params.quality = params.quality + 1
   end
   --

   if where and where:is_positional() then
      x, y = Map.find_free_position(x, y)
      if not x then
         return nil
      end
   end

   local id = params.id or nil
   if id == nil then
      -- EVENT: generate_item_id
      id = do_generate_item_id(params)
   end
end

return Itemgen
