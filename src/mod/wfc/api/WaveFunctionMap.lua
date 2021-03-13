local Layout = require("mod.tools.api.Layout")
local OverlappingModel = require("mod.wfc.api.model.OverlappingModel")

local WaveFunctionMap = {}

function WaveFunctionMap.generate_overlapping_layout(layout, width, height, opts)
   width = width or 20
   height = height or 20
   opts = opts or {}
   local periodic_input = opts.periodic_input
   if periodic_input == nil then
      periodic_input = true
   end
   local periodic = opts.periodic
   if periodic == nil then
      periodic = true
   end
   local n = opts.n or 3
   local symmetry = opts.symmetry or 8
   local ground = opts.ground or 0
   local max_steps = opts.max_steps or 1000

   local image_data, color_to_tile = Layout.to_image_data(layout)

   local model = OverlappingModel:new(image_data, n, width, height, periodic_input, periodic, symmetry, ground)
   model:run(max_steps)

   if not model:is_fully_observed() then
      return nil, "no_convergence"
   end

   local final = model:to_image_data()

   local new_layout = Layout.from_image_data(final, color_to_tile)
   return new_layout
end

function WaveFunctionMap.generate_overlapping(layout, width, height, opts)
   local new_layout, err = WaveFunctionMap.generate_overlapping_layout(layout, width, height, opts)

   if not new_layout then
      return nil, err
   end

   return Layout.to_map(new_layout)
end

return WaveFunctionMap
