local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local UiPagedList = require("api.gui.UiPagedList")
local TopicWindow = require("api.gui.TopicWindow")
local ChangeAppearanceList = require("api.gui.menu.ChangeAppearanceList")
local ChangeAppearancePreview = require("api.gui.menu.ChangeAppearancePreview")

local ChangeAppearanceMenu = class("ChangeAppearanceMenu", IUiLayer)

ChangeAppearanceMenu:delegate("win", {"x", "y", "width", "height"})
ChangeAppearanceMenu:delegate("pages", {"focus", "bind"})

local function make_deco()
   local image = Draw.load_image("graphic/deco_mirror.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   quad["a"] = love.graphics.newQuad(0, 0, 48, 120, iw, ih)

   return { image = image, quad = quad }
end

function ChangeAppearanceMenu:init()
   self.x, self.y, self.width, self.height = Ui.params_centered(380, 340, false)
   self.y = self.y - 12

   self.deco = make_deco()
   self.win = UiWindow:new("chara_make.select_race.title", self.x, self.y, self.width, self.height, true, "")

   local data = {
        { category = "done", value = 10, kind = "number" },
        { category = "portrait", value = 10, kind = "number" },
        { category = "hair", value = 10, kind = "number" },
        { category = "sub_hair", value = 10, kind = "number" },
        { category = "hair_color", value = 10, kind = "number" },
        { category = "body", value = 10, kind = "number" },
        { category = "cloth", value = 10, kind = "number" },
        { category = "pants", value = 10, kind = "number" },
        { category = "set_detail", value = 10, kind = "number" },
        { category = "riding", value = 10, kind = "number" },
        { category = "body_color", value = 10, kind = "number" },
        { category = "cloth_color", value = 10, kind = "number" },
        { category = "pants_color", value = 10, kind = "number" },
        { category = "etc_1", value = 10, kind = "number" },
        { category = "etc_2", value = 10, kind = "number" },
        { category = "etc_3", value = 10, kind = "number" },
        { category = "eyes", value = 10, kind = "number" },
        { category = "set_basic", value = 10, kind = "number" },
   }
   self.pages = UiPagedList:new(self.x + 60, self.y + 66, data, 10)

   self.pages.get_item_text = function(l, item)
      return item.category
   end

   self.preview = ChangeAppearancePreview:new(self.x + 234, self.y + 71)
end

function ChangeAppearanceMenu:relayout()
   self.win:relayout()
   self.preview:relayout()
   self.pages:relayout()
end

function ChangeAppearanceMenu:draw()
   self.win:draw()
   Ui.draw_topic("category", self.x + 34, self.y + 36)
   Draw.image_region(self.deco.image, self.deco.quad["a"], self.x + self.width - 40, self.y, nil, nil, {255, 255, 255})

   self.preview:draw()
   self.pages:draw()
end

function ChangeAppearanceMenu:update()
   self.win:update()
   self.preview:update()
   self.pages:update()
end

return ChangeAppearanceMenu
