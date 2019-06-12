local shadow_batch = require("internal.draw.shadow_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local tile_batch = require("internal.draw.tile_batch")
local Draw = require("api.Draw")

local field_renderer = class("field_renderer")

function field_renderer:init(width, height, layers)
   local coords = Draw.get_coords()

   self.width = width
   self.height = height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0

   self.screen_updated = true

   self.draw_coroutines = {}
   self.layers = {}
   self.scroll_info = {}

   for _, require_path in ipairs(layers) do
      local layer, err = package.try_require(require_path)
      if layer == nil then
         error("Could not load draw layer " .. require_path .. ":\n\t" .. err)
      end
      local IDrawLayer = require("api.gui.IDrawLayer")

      local instance = layer:new(width, height)
      assert_is_an(IDrawLayer, instance)

      -- TODO
      instance:relayout()

      self.layers[#self.layers+1] = instance
   end
end

function field_renderer:update_draw_pos(player_x, player_y)
   local draw_x, draw_y = self.coords:get_draw_pos(player_x,
                                                   player_y,
                                                   self.width,
                                                   self.height,
                                                   Draw.get_width(),
                                                   Draw.get_height())

   -- TODO: handle scrolling
   if draw_x ~= self.draw_x or draw_y ~= self.draw_y then
   end

   self:set_draw_pos(draw_x, draw_y)
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
   self.screen_updated = true
end

function field_renderer:add_async_draw_callback(cb)
   self.draw_coroutines[#self.draw_coroutines+1] = coroutine.create(cb)
end

function field_renderer:draw()
   local draw_x = self.draw_x
   local draw_y = self.draw_y

   for _, l in ipairs(self.layers) do
      l:draw(draw_x, draw_y)
   end

   local dead = {}
   for i, co in ipairs(self.draw_coroutines) do
      local msg, err = coroutine.resume(co, draw_x, draw_y)
      if err then
         dead[#dead+1] = i
      end
   end

   for _, i in ipairs(dead) do
      table.remove(self.draw_coroutines, i)
   end
end

function field_renderer:update(dt)
   local going = false
   for _, l in ipairs(self.layers) do
      local result = l:update(dt, self.screen_updated)
      if result then -- not nil or false
         going = true
      end
   end

   if not going then
      self.screen_updated = false
   end

   return going
end

return field_renderer
