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
   Draw.set_font(12)
   local _width = Draw.text_width(string.rep(" ", 20 * 2 + 1))
   return width - _width, 150, _width, height
end

function WatcherWidget:update_variable(name, value, preserve_delta, group)
   self.table:update_variable(name, value, preserve_delta, group)
end

function WatcherWidget:clear()
   self.table:clear()
   self.watches = {}
end

local function is_valid_lua_ident(name)
   return string.match(name, "^[_a-z][_a-z0-9]*$")
end

local function index_object(object, index)
   if is_valid_lua_ident(index) then
      return true, object[index]
   end

   local match = string.match(index, "%['(.*)'%]")
   if match then
      return true, object[match]
   end

   match = string.match(index, "%[\"(.*)\"%]")
   if match then
      return true, object[match]
   end

   if not string.match(index, "%%s") and string.match(index, "^[%[.:(]") then
      index = "%s" .. index
   end

   local ident = "ident"

   local code = ([[
local %s = ...
return %s
]]):format(ident, string.format(index, ident))

   local chunk, err = loadstring(code)
   if chunk then
      return true, chunk(object), chunk
   end

   return false, err
end

function WatcherWidget:update_watches()
   for name, watch in pairs(self.watches) do
      for _, index in ipairs(watch.indices) do
         local value
         if index.chunk then
            value = index.chunk(watch.object)
         else
            _, value = index_object(watch.object, index.index)
         end
         self:update_variable(index.index, value, false, name)
      end
   end
end

function WatcherWidget:start_watching_object(name, object, indices)
   assert(type(object) == "table", ("watched object must be table, got '%s'"):format(type(object)))
   assert(type(name) == "string")
   indices = indices or {}
   for i=1,#indices do
      if type(indices[i]) == "string" then
         indices[i] = { index = indices[i] }
      end
   end
   self.watches[name] = { object = object, indices = indices }
   self:update_watches()
end

function WatcherWidget:stop_watching_object(name)
   self.watches[name] = nil
   self.table:remove_group(name)
   self:update_watches()
end

function WatcherWidget:start_watching_index(name, index)
   assert(type(index) == "string")

   local ok, res, chunk = index_object(self.watches[name].object, index)
   if not ok then
      return nil, res
   end

   index = { index = index, chunk = chunk }

   table.insert(self.watches[name].indices, index)
   self:update_watches()

   return true
end

function WatcherWidget:stop_watching_index(name, index)
   assert(type(index) == "string")
   local indices = self.watches[name].indices
   for i, v in ipairs(indices) do
      if v[1] == index then
         table.remove(indices, i)
         break
      end
   end
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
