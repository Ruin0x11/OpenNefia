local Map = require("api.Map")
local WaveFunctionMap = require("mod.wfc.api.WaveFunctionMap")
local Draw = require("api.Draw")
local Layout = require("mod.wfc.api.Layout")
local layouts = require("mod.wfc.scratch.layouts")

local gen = {}

function gen.goto_map(layout, width, height)
   local map = WaveFunctionMap.generate_overlapping(layout, width or 30, height or 30)
   Map.travel_to(map)
end

function gen.test_1(w, h)
   local layout = {
      tiles = [[
.....#
.####.
.#oo#.
.#oo#.
.#oo#.
#.....]],
      tileset = {
         ["#"] = "elona.wall_brick_top",
         ["."] = "elona.wood_floor_5",
         ["o"] = "elona.carpet_5"
      }
   }

   gen.goto_map(layout, w, h)
end

function gen.layout(name, w, h, opts)
   local layout = layouts[name:lower()]
   assert(layout, ("No layout with name '%s'"):format(name))
   gen.goto_map(layout, w, h, opts)
end

function gen.all_layouts()
   return table.keys(layouts)
end

return gen
