local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiWindow = require("api.gui.UiWindow")
local TopicWindow = require("api.gui.TopicWindow")
local ChangeAppearanceList = require("api.gui.menu.ChangeAppearanceList")
local ChangeAppearancePreview = require("api.gui.menu.ChangeAppearancePreview")
local InputHandler = require("api.gui.InputHandler")

local ChangeAppearanceMenu = class.class("ChangeAppearanceMenu", ICharaMakeSection)

ChangeAppearanceMenu:delegate("list", "focus")
ChangeAppearanceMenu:delegate("input", IInput)

local function make_deco()
   local image = Draw.load_image("graphic/deco_mirror.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   quad["a"] = love.graphics.newQuad(0, 0, 48, 120, iw, ih)

   return { image = image, quad = quad }
end

local ChangeAppearanceListExt = function(change_appearance_menu)
   local E = {}

   function E:on_select(item)
      change_appearance_menu.preview.show_portrait = item.type == "portrait"
   end

   return E
end

function ChangeAppearanceMenu:init()
   self.width = 380
   self.height = 340

   self.deco = make_deco()
   self.win = UiWindow:new("appearance", true, "key_help")

   self.list = ChangeAppearanceList:new()

   self.preview = ChangeAppearancePreview:new()

   table.merge(self.list, ChangeAppearanceListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   self.caption = "Change appearance."
   self.intro_sound = "base.port"
end

function ChangeAppearanceMenu:on_charamake_finish()
end

function ChangeAppearanceMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height, false)
   self.y = self.y - 12

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.preview:relayout(self.x + 234, self.y + 71)
   self.list:relayout(self.x + 60, self.y + 66)
end

function ChangeAppearanceMenu:draw()
   self.win:draw()
   Ui.draw_topic("category", self.x + 34, self.y + 36)
   Draw.image_region(self.deco.image, self.deco.quad["a"], self.x + self.width - 40, self.y, nil, nil, {255, 255, 255})

   self.preview:draw()
   self.list:draw()
end

function ChangeAppearanceMenu:update()
   if self.list.chosen then
      self.list.chosen = false
      return true
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.preview:update()
   self.list:update()
end

return ChangeAppearanceMenu
