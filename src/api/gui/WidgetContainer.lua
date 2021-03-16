local Env = require("api.Env")
local IUiElement = require("api.gui.IUiElement")
local WidgetHolder = require("api.gui.WidgetHolder")
local IUiWidget = require("api.gui.IUiWidget")
local PriorityMap = require("api.PriorityMap")

local WidgetContainer = class.class("WidgetContainer", IUiElement)

function WidgetContainer:init()
   self.map = PriorityMap:new()
end

function WidgetContainer:iter()
   return self.map:iter()
end

function WidgetContainer:iter_type(req_path)
   return fun.wrap(self:iter()):filter(function(holder) return Env.get_require_path(holder:widget()) == req_path end)
end

function WidgetContainer:get(tag)
   assert(type(tag) == "string")
   return self.map:get(tag)
end

function WidgetContainer:get_by_type(req_path)
   return self:iter_type(req_path):nth(1)
end

function WidgetContainer:add(widget, tag, opts)
   opts = opts or {}
   assert(class.is_an(IUiWidget, widget))
   assert(type(tag) == "string")

   if self.map:get(tag) then
      if Env.is_hotloading() then
         return
      else
         error(("tag '%s' is already in use"):format(tag))
      end
   end

   local holder = WidgetHolder:new(widget,
                                   tag,
                                   opts.z_order or widget:default_widget_z_order(),
                                   opts.position or nil,
                                   opts.refresh or nil,
                                   opts.enabled)

   self.map:set(tag, holder, holder:z_order())
end

function WidgetContainer:remove(tag)
   assert(type(tag) == "string")

   self.map:set(tag, nil)
end

function WidgetContainer:relayout(x, y, width, height)
   for _, holder in self:iter() do
      local widget = holder:widget()
      local position = holder:position() or widget.default_widget_position
      local _x, _y, _width, _height = position(widget, x, y, width, height)

      holder:widget():relayout(_x, _y, _width, _height)
   end
end

function WidgetContainer:refresh(player)
   for _, holder in self:iter() do
      local widget = holder:widget()
      local refresh = holder:refresh() or widget.default_widget_refresh
      refresh(widget, player)
   end
end

function WidgetContainer:draw()
   for _, holder in self:iter() do
      if holder:enabled() then
         holder:widget():draw()
      end
   end
end

function WidgetContainer:update(dt, map, screen_updated)
   self.updated = false
   for _, holder in self:iter() do
      holder:widget():update(dt, map, screen_updated)
      self.updated = self.updated or holder.updated
      holder.updated = false
   end
end

return WidgetContainer
