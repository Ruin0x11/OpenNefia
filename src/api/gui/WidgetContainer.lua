local Env = require("api.Env")
local IUiElement = require("api.gui.IUiElement")
local WidgetHolder = require("api.gui.WidgetHolder")
local IUiWidget = require("api.gui.IUiWidget")

local WidgetContainer = class.class("WidgetContainer", IUiElement)

function WidgetContainer:init()
   -- {<WidgetHolder>...}
   self.holders = {}

   self.tag_to_idx = {}
end

function WidgetContainer:iter()
   return fun.iter(self.holders)
end

function WidgetContainer:iter_type(req_path)
   return self:iter():filter(function(holder) return Env.get_require_path(holder:widget()) == req_path end)
end

function WidgetContainer:get(tag)
   assert(type(tag) == "string")
   return self.holders[self.tag_to_idx[tag]]
end

function WidgetContainer:get_by_type(req_path)
   return self:iter_type(req_path):nth(1)
end

function WidgetContainer:add(widget, tag, opts)
   opts = opts or {}
   assert(class.is_an(IUiWidget, widget))
   assert(type(tag) == "string")
   assert(not self.tag_to_idx[tag], ("tag '%s' is already in use"):format(tag))

   local idx = #self.holders+1
   self.holders[idx] = WidgetHolder:new(widget,
                                        tag,
                                        opts.z_order or widget:default_widget_z_order(),
                                        opts.position or nil)

   self:update_sorting()
end

function WidgetContainer:remove(tag)
   assert(type(tag) == "string")
   if self.tag_to_idx[tag] then
      return
   end

   local idx = self.tag_to_idx[tag]
   table.remove(self.holders, idx)
   self.tag_to_idx[tag] = nil

   self:update_sorting()
end

function WidgetContainer:update_sorting()
   table.sort(self.holders, function(a, b) return a:z_order() < b:z_order() end)
   for idx, holder in ipairs(self.holders) do
      self.tag_to_idx[holder._tag] = idx
   end
   self.updated = false
end

function WidgetContainer:relayout(x, y, width, height)
   for _, holder in self:iter() do
      local position = holder:position() or holder:widget().default_widget_position
      local _x, _y, _width, _height = position(self.widget, x, y, width, height)

      holder:widget():relayout(_x, _y, _width, _height)
   end
   self:update_sorting()
end

function WidgetContainer:draw()
   for _, holder in self:iter() do
      if holder:enabled() then
         holder:widget():draw()
      end
   end
end

function WidgetContainer:update(dt)
   self.updated = false
   for _, holder in self:iter() do
      holder:widget():update(dt)
      self.updated = self.updated or holder.updated
      holder.updated = false
   end
end

return WidgetContainer
