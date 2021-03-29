local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local PicViewer = class.class("PicViewer", IUiLayer)

PicViewer:delegate("input", IInput)

function PicViewer:init(drawable, orig)
   self.regions = {}

   if type(orig.draw) == "function" then
      self.width = orig:get_width()
      self.height = orig:get_height()

      if type(orig.quads) == "table" then
         local to_region = function(_, q, tbl)
            if q.typeOf and q:typeOf("Quad") then
               local tx, ty, tw, th, iw, ih = q:getViewport()
               return {
                  x = tx,
                  y = ty,
                  width = tw,
                  height = th
               }
            elseif tbl and tbl.typeOf and tbl:typeOf("Quad") then
               -- ["region_id"] = <Quad>
               local tx, ty, tw, th, iw, ih = tbl:getViewport()
               return {
                  x = tx,
                  y = ty,
                  width = tw,
                  height = th
               }
            end

            return nil
         end
         self.regions = fun.iter_pairs(orig.quads):map(to_region):to_list()
      end
   else
      self.width = drawable:getWidth()
      self.height = drawable:getHeight()
   end

   self.offset_x = 0
   self.offset_y = 0
   self.scale = 1.0
   self.delta = 50
   self.draw_border = true

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.drawable = drawable
end

function PicViewer:default_z_order()
   return 100000000
end

function PicViewer:make_keymap()
   return {
      north = function() self.offset_y = self.offset_y - self.delta end,
      south = function() self.offset_y = self.offset_y + self.delta end,
      east = function() self.offset_x = self.offset_x + self.delta end,
      west = function() self.offset_x = self.offset_x - self.delta end,
      repl_page_up = function() self.scale = self.scale + 0.1 end,
      repl_page_down = function() self.scale = math.max(0.1, self.scale - 0.1) end,
      mode = function() self.draw_border = not self.draw_border end,
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      enter = function() self.canceled = true end,
   }
end

function PicViewer:on_query()
   Gui.play_sound("base.pop2")
end

function PicViewer:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.y = self.y
end

function PicViewer:draw()
   local x = self.x + self.offset_x
   local y = self.y + self.offset_y

   local width = math.floor(self.width * self.scale)
   local height = math.floor(self.height * self.scale)
   local pad = 10 * self.scale
   local border_width = width + pad
   local border_height = height + pad

   if self.draw_border then
      Draw.filled_rect(x-pad/2, y-pad/2, border_width, border_height, {0, 0, 0})
      Draw.line_rect(x-pad/2, y-pad/2, border_width, border_height, {255, 255, 255})
   end

   Draw.set_color(255, 255, 255)
   if self.drawable.draw then
      self.drawable:draw(x, y, width, height)
   else
      Draw.image(self.drawable, x, y, width, height)
   end

   for _, r in ipairs(self.regions) do
      Draw.line_rect(x + r.x * self.scale, y + r.y * self.scale, r.width * self.scale, r.height * self.scale, {255, 0, 0})
   end
end

function PicViewer:update(dt)
   if self.canceled then
      return nil, "canceled"
   end
end

local function is_type(_type, comp, _id)
   return _type == comp or (comp == nil and data[_type][_id])
end

local function drawable_to_image(drawable, width, height)
   local canvas = Draw.create_canvas(width, height)
   Draw.with_canvas(canvas, function() drawable:draw(0, 0) end)
   return Draw.new_image(canvas:newImageData())
end

function PicViewer.start(asset, _type)
   local orig = asset
   local drawable = asset

   if type(asset) == "string" then
      if is_type("base.asset", _type, asset) then
         orig = UiTheme.load()[asset]
         if orig == nil then
            error("unknown asset " .. asset)
         end
         drawable = drawable_to_image(orig, orig:get_width(), orig:get_height())
      elseif is_type("base.chip", _type, asset) then
         local width, height = Draw.get_chip_size("chip", asset)
         drawable = Draw.make_chip_batch("chip")
         drawable:add(asset, 0, 0, width, height)
         drawable = drawable_to_image(drawable, width, height)
      elseif is_type("base.map_tile", _type, asset) then
         local width, height = Draw.get_coords():get_size()
         drawable = Draw.make_chip_batch("tile")
         drawable:add(asset, 0, 0, width, height)
         drawable = drawable_to_image(drawable, width, height)
      else
         error(("unknown type %s"):format(_type))
      end
   elseif class.is_an("internal.draw.atlas", asset) then
      drawable = asset.image
   elseif class.is_an("internal.draw.tile_batch", asset) then
      drawable = asset.atlas.image
   elseif asset.typeOf and asset:typeOf("ImageData") then
      drawable = Draw.new_image(asset)
   end

   PicViewer:new(drawable, orig):query()
end

return PicViewer
