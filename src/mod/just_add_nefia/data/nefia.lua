local Nefia = require("mod.elona.api.Nefia")
local DungeonMap = require("mod.elona.api.DungeonMap")
local Advice = require("api.Advice")
local I18N = require("api.I18N")
local JANDungeonTemplate = require("mod.just_add_nefia.api.JANDungeonTemplate")
local Area = require("api.Area")
local Event = require("api.Event")

data:add {
   _type = "elona.nefia",
   _id = "mazey",

   image = "elona.feat_area_tower",
   color = { 255, 200, 150 },

   on_generate_floor = function(area, floor)
      local gen, params = JANDungeonTemplate.nefia_mazey(floor, { level = Nefia.get_level(area) })
      local map =  DungeonMap.generate(area, floor, gen, params)
      map.prevents_mining = true
      map.prevents_teleport = true

      return map
   end
}

data:add {
   _type = "elona.nefia",
   _id = "putit",

   image = "elona.feat_area_temple",
   color = { 150, 200, 255 },

   on_generate_floor = function(area, floor)
      Advice.set_enabled("api.Chara", "create", _MOD_NAME, "Putitify during initial nefia mapgen", true)
      local ok, map = xpcall(function()
         local gen, params = JANDungeonTemplate.nefia_putit(floor, { level = Nefia.get_level(area) })
         return DungeonMap.generate(area, floor, gen, params)
      end, debug.traceback)
      Advice.set_enabled("api.Chara", "create", _MOD_NAME, "Putitify during initial nefia mapgen", false)

      if not ok then
         error(map)
      end

      return map
   end
}

data:add {
   _type = "elona.nefia",
   _id = "weird",

   image = "elona.feat_area_temple",
   color = { 150, 255, 150 },

   on_generate_floor = function(area, floor)
      local gen, params = JANDungeonTemplate.nefia_weird(floor, { level = Nefia.get_level(area) })
      local map = DungeonMap.generate(area, floor, gen, params)

      return map
   end
}

local function putitify(chara)
   chara.image = "elona.chara_race_slime"
   chara.portrait = nil
   chara.name = I18N.get("chara.elona.putit.name")
   if chara.own_name then
      chara.name = I18N.get("chara.job.own_name", chara.name, chara.own_name)
   end
end

local function putitify_around_create(orig_fn, id, x, y, params, where)
   local chara = orig_fn(id, x, y, params, where)

   if chara and (params == nil or not params.no_modify) then
      putitify(chara)
   end

   return chara
end
Advice.add("around", "api.Chara", "create", "Putitify during initial nefia mapgen", putitify_around_create, { enabled = false })

local function putitify_in_nefia(chara)
   local map = chara:current_map()
   if map == nil then
      return
   end
   local area = Area.for_map(map)
   if area == nil or Nefia.get_type(area) ~= "just_add_nefia.putit" then
      return
   end

   putitify(chara)
end
Event.register("base.on_chara_generated", "Putitify inside putit nefia", putitify_in_nefia, 300000)
