require("boot")

local UiActionList = require("api.gui.UiActionList")
local UiList = require("api.gui.UiList")
local UiPagedList = require("api.gui.UiPagedList")
local MyThing = class("MyThing")

function MyThing:init()
   self.x = 0
   self.y = 0
   self.list = UiActionList:new(self.x + 64, self.y + 66, {"hoge", "fuga"})
end

function MyThing:draw()
   self.list:draw()
end

local t = MyThing:new()
t:draw()

t:draw()
