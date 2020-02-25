local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local WatcherTable = class.class("WatcherTable", IUiElement)

function WatcherTable:init()
   self.vars = {}
   self.deltas = {}
   self.lines = {}
   self.groups = {}
   self.order = {}
   self.name_to_group = {}
   self.updated = true
end

function WatcherTable:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
end

function WatcherTable:update_variable(name, value, preserve_delta, group)
   if not self.name_to_group[name] then
      group = group or "__default"
   end

   local cur = self.vars[name]
   if cur ~= value then
      local delta = true
      if type(cur) == "number" and type(value) == "number" then
         delta = value - cur
         local sign = ""
         if delta > 0 then
            sign = "+"
         end
         delta = ("%s%d"):format(sign, delta)
      end
      self.deltas[name] = delta
   elseif not preserve_delta then
      self.deltas[name] = nil
   end

   if group and not self.groups[group] then
      print(group, #self.order)
      self.groups[group] = {}
      self.order[#self.order+1] = group
   end

   if not self.vars[name] then
      table.insert(self.groups[group], name)
      self.name_to_group[name] = group
   elseif not value then
      local group = self.name_to_group[name]
      table.iremove_value(self.groups[group], name)
   end

   self.vars[name] = value
   self.updated = true
end

function WatcherTable:clear()
   self.vars = {}
   self.deltas = {}
   self.lines = {}
   self.groups = {}
   self.order = {}
   self.name_to_group = {}
   self.updated = true
end

local function format_name(str, len)
   if string.len(str) > len then
      str = string.sub(str, 1, len-3) .. "..."
   end
   return str .. string.rep(" ", len - #str)
end

function WatcherTable:update_lines()
   self.lines = {}

   Draw.set_font(12)
   for _, group_name in ipairs(self.order) do
      if group_name ~= "__default" then
         local header = ("%s (%d)"):format(group_name, #self.groups[group_name])
         self.lines[#self.lines+1] = Draw.make_text(header)
         self.lines[#self.lines+1] = {255, 255, 255}
      end
      for _, name in ipairs(self.groups[group_name]) do
         local value = self.vars[name]
         if value then
            local delta = self.deltas[name]
            local delta_str = ""
            if type(delta) == "string" then
               delta_str = (" (%s)"):format(delta)
            end
            local formatted = ("%s%s%s"):format(format_name(name, 12), tostring(value), delta_str)
            local color = {255, 255, 255}
            if delta then
               color = { 175, 255, 175 }
            end
            self.lines[#self.lines+1] = Draw.make_text(formatted)
            self.lines[#self.lines+1] = color
         end
      end
   end
   self.updated = false
end

function WatcherTable:draw()
   local y = self.y
   for i=1,#self.lines,2 do
      local line = self.lines[i]
      local color = self.lines[i+1]
      Draw.text_shadowed(line, self.x, y, color)
      y = y + Draw.text_height()
   end
end

function WatcherTable:update(dt)
   if self.updated then
      self:update_lines()
   end
end

return WatcherTable
