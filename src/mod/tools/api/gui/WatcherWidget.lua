local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local WatcherTable = require("mod.tools.api.gui.WatcherTable")

local WatcherWidget = class.class("WatcherWidget", IUiWidget)

function WatcherWidget:init()
   self.table = WatcherTable:new()

   -- {{ object = {}, name = "name", indices = {"index"} }}
   self.watches = {}
end

function WatcherWidget:default_widget_position(x, y, width, height)
   local _width = 180
   return width - _width, 150, _width, height
end

function WatcherWidget:update_variable(name, value, preserve_delta, group)
   self.table:update_variable(name, value, preserve_delta, group)
end

function WatcherWidget:clear()
   self.table:clear()
   self.watches = {}
end

function WatcherWidget:update_watches()
   for object, watch in pairs(self.watches) do
      for _, index in ipairs(watch.indices) do
         local value = object[index]
         local name = ("%s.%s"):format(watch.name, index)
         self:update_variable(name, value, false, watch.name)
      end
   end
end

function WatcherWidget:start_watching_object(object, name, indices)
   indices = indices or {}
   self.watches[object] = { name = name, indices = indices }
   self:update_watches()
end

function WatcherWidget:stop_watching_object(object)
   self.watches[object] = nil
   self:update_watches()
end

function WatcherWidget:start_watching_index(object, index)
   assert(type(index) == "string")
   table.insert(self.watches[object].indices, index)
   self:update_watches()
end

function WatcherWidget:stop_watching_index(object, index)
   assert(type(index) == "string")
   table.remove_value(self.watches[object].indices, index)
   self:update_watches()
end

function WatcherWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.table:relayout(x, y, width, height)
end

function WatcherWidget:draw()
   self.table:draw()
end

function WatcherWidget:update(dt)
   self.table:update(dt)
end

return WatcherWidget
