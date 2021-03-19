local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local PicViewer = class.class("PicViewer", IUiLayer)

PicViewer:delegate("input", IInput)

function PicViewer:init(drawable)
   self.regions = {}

   if type(drawable.draw) == "function" then
      self.width = drawable:get_width() + 20
      self.height = drawable:get_height() + 20

      if type(drawable.quads) == "table" then
         local to_region = function(q, tbl)
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
         self.regions = fun.iter(drawable.quads):map(to_region):to_list()
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
      north = function() self.offset_y = self.offset_y + self.delta end,
      south = function() self.offset_y = self.offset_y - self.delta end,
      east = function() self.offset_x = self.offset_x - self.delta end,
      west = function() self.offset_x = self.offset_x + self.delta end,
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

   if self.draw_border then
      Draw.filled_rect(x, y, width, height, {0, 0, 0})
      Draw.line_rect(x-2, y-2, width+4, height+4, {255, 255, 255})
   end

   Draw.set_color(255, 255, 255)
   if self.drawable.draw then
      self.drawable:draw(x, y, width, height)
   else
      Draw.image(self.drawable, x, y, width, height)
   end

   for _, r in ipairs(self.regions) do
      Draw.line_rect(x + r.x, y + r.y, r.width * self.scale, r.height * self.scale, {255, 0, 0})
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

function PicViewer.start(asset, _type)
   local drawable = asset

   if type(asset) == "string" then
      if is_type("base.asset", _type, asset) then
         drawable = UiTheme.load()[asset]
         if drawable == nil then
            error("unknown asset " .. asset)
         end
      elseif is_type("base.chip", _type, asset) then
         local width, height = Draw.get_coords():get_size()
         drawable = Draw.make_chip_batch("chip")
         drawable:add(asset, 0, 0, width, height)
      elseif is_type("base.map_tile", _type, asset) then
         local width, height = Draw.get_coords():get_size()
         drawable = Draw.make_chip_batch("tile")
         drawable:add(asset, 0, 0, width, height)
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

   PicViewer:new(drawable):query()
end

return PicViewer
