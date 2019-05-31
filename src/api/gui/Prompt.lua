local Draw = require("api.Draw")
local IUiLayer = require("api.gui.IUiLayer")
local TopicWindow = require("api.gui.TopicWindow")
local KeyHandler = require("api.gui.KeyHandler")
local MouseHandler = require("api.gui.MouseHandler")
local UiList = require("api.gui.UiList")
local IKeyInput = require("api.gui.IKeyInput")

local Prompt = class("Prompt", IUiLayer)

Prompt:delegate("list", IKeyInput)

function Prompt:init(choices, width)
   self.width = width or 160
   self.height = #choices * 20 + 42
   local inf_verh = 16 + 72
   local prompt_x = (Draw.get_width() - 10) / 2 + 3
   local prompt_y = (Draw.get_height() - inf_verh - 30) / 2 - 4 -- inf_verh
   self.x = prompt_x - self.width / 2
   self.y = prompt_y - #choices * 10
   self.keys = KeyHandler:new()
   self.mouse = MouseHandler:new()
   self.win = TopicWindow:new(self.x + 8, self.y + 8, self.width - 16, self.height - 16, 0, 0)
   self.radar_deco = Draw.load_image("graphic/temp/radar_deco.bmp")
   self.list = UiList:new(self.x + 30, self.y + 24, choices, 20)
end

Prompt.query = require("api.Input").query

function Prompt:focus()
   self.keys:focus()
   self.mouse:focus()
end

function Prompt:relayout()
   self.win:relayout()
   self.list:relayout()
end

function Prompt:update()
   self.list:update()

   if self.list.chosen then
      return self.list:selected_item()
   end
end

function Prompt:draw()
   Draw.filled_rect(self.x + 12, self.y + 12, self.width - 17, self.height - 16, {60, 60, 60, 128})
   self.win:draw()
   Draw.image(self.radar_deco, self.x - 16, self.y)
   Draw.set_font(14) -- 14 - en * 2
   self.list:draw()
end

return Prompt
