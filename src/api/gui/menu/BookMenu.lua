local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")
local ISettable = require("api.gui.ISettable")
local IPaged = require("api.gui.IPaged")

local BookMenu = class.class("BookMenu", {IUiLayer, ISettable, IPaged})

BookMenu:delegate("input", IInput)
BookMenu:delegate("model", IPaged)

function BookMenu:init(text, elona_compat)
   self.max_page_text = 20
   self.max_page_width = 0
   self.input = InputHandler:new()
   self.model = PagedListModel:new({}, 40, false)
   self:set_data(text)
   self.elona_compat = elona_compat or false

   self.input = InputHandler:new()
   self.input:bind_keys {
      escape = function() self.canceled = true end,
      shift = function() self.canceled = true end,
      left = function()
         if self:previous_page() then
            Gui.play_sound("base.card1")
         end
      end,
      right = function()
         if self:next_page() then
            Gui.play_sound("base.card1")
         end
      end,
      ["return"] = function() self.canceled = true end
   }
end

local function parse_color(hex)
   hex = hex:gsub("#","")
   return {
      tonumber("0x"..hex:sub(1,2)),
      tonumber("0x"..hex:sub(3,4)),
      tonumber("0x"..hex:sub(5,6))
   }
end

local function parse_params(line)
   local params = {}

   while string.sub(line, 1, 1) == "<" do
      if string.sub(line, 2, 2) == "<" then
         break
      end
      local part = string.sub(line, 1, string.find(line, ">"))
      print(part,line)
      local stop = string.find(line, ">")
      assert(stop ~= nil)
      line = string.sub(line, stop)
      part = string.sub(part, 2, string.len(part) - 1)
      print(part,line)
      local key, value = table.unpack(string.split(part, "="))
      if key == "size" then
         params.size = tonumber(value)
      elseif key == "style" then
         params.style = value
      elseif key == "color" then
         params.color = parse_color(value)
      else
         error(string.format("unknown key %s (%s)", tostring(key), part))
      end
   end

   return line, params
end

function BookMenu:on_query()
   Gui.play_sound("base.book1")
end

function BookMenu:set_data(text)
   local lines = {}
   local i = 0
   for line in string.lines(text) do
      local params
      line, params = parse_params(line)
      local font = {}
      font.size = params.size or 12 -- 12 + sizefix - en * 2
      local color = params.color or {0, 0, 0}
      if self.elona_compat then
         if i == 0 then
            font = { size = 12, style = "bold" }
         elseif i == 1 then
            font = { size = 10 }
         end
      end
      i = i + 1
      lines[#lines+1] = { font = font, color = color, line = line }
   end
   self.model:set_data(lines)
end

function BookMenu:relayout()
   self.t = UiTheme.load(self)
   self.width = self.t.book:get_width()
   self.height = self.t.book:get_height()
   self.max_page_width = self.width / 2

   self.x, self.y, self.width, self.height = Ui.params_centered(self.width - 16, self.height + 20)

end

function BookMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.book:draw(self.x, self.y)

   Draw.set_color(self.t.text_color)
   for i, item in self.model:iter() do
      i = i - 1
      local x = self.x + 80 + math.floor(i / 20) * 306
      local y = self.y + 45 + i % 20 * 16
      Draw.set_font(item.font)
      Draw.text(item.line, x, y)
      if i % 20 == 0 then
         local page = math.floor(i / 20 + 1) + self.model.page * 2
         Draw.set_font(12, "bold")
         Draw.text(string.format("- %s -", page), x + 90, y + 330)
      end
   end
end

function BookMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   self.model.changed = false
end

return BookMenu
