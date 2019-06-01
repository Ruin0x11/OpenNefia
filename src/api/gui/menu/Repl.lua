local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local Repl = class("Repl", IUiLayer)

Repl:delegate("input", IInput)

function Repl:init()
   self.win = UiWindow:new("chara_make.select_race.title", self.x, self.y, self.width, self.height)
   self.list = UiList:new(self.x, self.y, {})
   self.input = InputHandler:new()
end

function Repl:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height() / 3
end

function Repl:focus()
end

function Repl:draw()
   self.win:draw()
   self.list:draw()
end

function Repl:update()
   self.win:update()
   self.list:update()
end

return Repl
