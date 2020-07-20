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

      if drawable.quads then
         local to_region = function(q)
            local tx, ty, tw, th, iw, ih = q:getViewport()
            return {
               x = tx,
               y = ty,
               width = tw,
               height = th
            }
         end
         self.regions = fun.iter(drawable.quads):map(to_region):to_list()
      end
   else
      self.width = drawable:getWidth() + 20
      self.height = drawable:getHeight() + 20
   end

   self.offset_x = 0
   self.offset_y = 0
   self.delta = 50

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

   Draw.filled_rect(x, y, self.width, self.height, {0, 0, 0})
   Draw.line_rect(x+9, y+9, self.width-18, self.height-18, {255, 255, 255})

   for _, r in ipairs(self.regions) do
      Draw.line_rect(x + r.x + 10, y + r.y + 10, r.width, r.height, {255, 0, 0})
   end

   if self.drawable.draw then
      self.drawable:draw(x + 10, y + 10, nil, nil, {255, 255, 255})
   else
      Draw.image(self.drawable, x + 10, y + 10, nil, nil, {255, 255, 255})
   end
end

function PicViewer:update(dt)
   if self.canceled then
      return nil, "canceled"
   end
end

function PicViewer.start(asset, _type)
   local drawable

   if type(asset) == "string" then
      _type = _type or "base.asset"
      if _type == "base.asset" then
         drawable = UiTheme.load()[asset]
         if drawable == nil then
            error("unknown asset " .. asset)
         end
      elseif _type == "base.chip" then
         local width, height = Draw.get_coords():get_size()
         drawable = Draw.make_chip_batch("chip")
         drawable:add(asset, 0, 0, width, height)
      else
         error("unknown type " .. _type)
      end
   end

   PicViewer:new(drawable):query()
end

return PicViewer
