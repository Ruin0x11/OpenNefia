require("boot")

local UiList = require("api.gui.UiList")
local UiPagedList = require("api.gui.UiPagedList")
local MyThing = class("MyThing")

function MyThing:init()
   self.x = 0
   self.y = 0
   local list = UiList:new(self.x + 64, self.y + 66, {"hoge", "fuga"})

   local super = UiList.draw_select_key
   list.draw_select_key = function(l, i, item, name, x, y)
      super(l, i, item, name, x, y)
      print("in my new")
   end

   self.pages = UiPagedList:new(list, 23)
end

function MyThing:draw()
   self.pages:draw()
end

local t = MyThing:new()
t:draw()

MyThing.draw = function(self)
   print("in my new draw")
end

t:draw()

t.draw = function(self)
   print("a newer draw")
end

t:draw()


local m = require("api.gui.menu.FeatsMenu"):new(true)

m.pages:choose(1)

m:relayout()
m:draw()

-- m:send_key("return")
