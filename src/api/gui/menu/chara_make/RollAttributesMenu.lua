local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local RollAttributesMenu = class("RollAttributesMenu", ICharaMakeSection)

RollAttributesMenu:delegate("input", IInput)

---------------------------------------- dupe
local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end
----------------------------------------

local UiListExt = function(roll_attributes_menu)
   local E = {}

   function E:get_item_text(item)
      return item.text
   end
   function E:on_choose(item)
      if item.on_choose then
         self.chosen = false
         item.on_choose()
      end
   end
   function E:draw_item(item, i, x, y, key_name)
      UiList.draw_item(self, item, i, x, y, key_name)
      if item.value then
         roll_attributes_menu:draw_attribute(item, i, x, y)
      end
   end

   return E
end

function RollAttributesMenu:init()
   self.width = 360
   self.height = 352

   self.locks_left = 2
   self.locks = {}
   self.finished = false

   local texts = {
      "Strength",
      "Endurance",
      "Charisma"
   }
   self.data = {
      { text = "Reroll", on_choose = function() self:reroll(true) end },
      { text = "Proceed" },
   }
   local function lock(attr)
      return function()
         self:lock(attr)
      end
   end
   for _, v in ipairs(texts) do
      self.data[#self.data + 1] = { text = v, on_choose = lock(v), locked = false, value = 0 }
   end

   self.alist = UiList:new(self.data, 23)
   table.merge(self.alist, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.alist)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   ---------------------------------------- dupe
   self.skill_icons = Draw.load_image("graphic/temp/skill_icons.bmp")

   local iw = self.skill_icons:getWidth()
   local ih = self.skill_icons:getHeight()

   self.quad = {}
   for i, s in ipairs(texts) do
      self.quad[s] = love.graphics.newQuad(i * 48, 0, 48, 48, iw, ih)
   end
   ----------------------------------------

   self.win = UiWindow:new("roll_attributes.title")

   self.bg = load_cm_bg(1)

   self.caption = "Roll your attributes."
   self.intro_sound = "base.skill"

   self:reroll()
end

function RollAttributesMenu:on_charamake_finish()
end

function RollAttributesMenu:on_charamake_go_back()
   self.alist.chosen = false
end

function RollAttributesMenu:reroll(play_sound)
   for _, v in ipairs(self.data) do
      if v.value and not v.locked then
         v.value = math.random(1, 15)
      end
   end

   if play_sound then
      Gui.play_sound("base.dice")
   end
end

function RollAttributesMenu:lock(attr)
   local a = fun.iter(self.data):filter(function(i) return i.text == attr end):nth(1)
   if not a or a.locked == nil then return end
   if a.locked == true then
      a.locked = false
      self.locks_left = self.locks_left + 1
   else
      if self.locks_left == 0 then return end
      a.locked = true
      self.locks_left = self.locks_left - 1
   end

   Gui.play_sound("base.ok1")
end

function RollAttributesMenu:draw_attribute(item, i, x, y)
   Draw.set_font(15, "bold")

   local quad = self.quad[item.text]
   if quad then
      Draw.image_region(self.skill_icons, quad, x + 160, y + 10, nil, nil, {255, 255, 255}, true)
   end

   Draw.text(tostring(item.value), x + 172, y, {0, 0, 0})

   if item.locked == true then
      Draw.set_font(12, "bold") -- 12 - en * 2
      Draw.text("Locked!", x + 202, y + 2, {20, 20, 140})
   end
end

function RollAttributesMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 20

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.alist:relayout(self.x + 38, self.y + 66)
end

function RollAttributesMenu:draw()
   self.win:draw()
   Draw.image(self.bg, self.x + 85, self.y + self.height / 2, 150, 240, {255, 255, 255, 30}, true)

   Draw.set_color(255, 255, 255)
   Ui.draw_topic("chara_making.roll_attributes.title", self.x + 28, self.y + 30)

   Draw.set_color(0, 0, 0)
   Draw.set_font(12) -- 12 + sizefix - en * 2
   Draw.text("locked items", self.x + 175, self.y + 52)
   Draw.set_font(13, "bold") -- 13 - en * 2
   Draw.text("remain" .. ": " .. self.locks_left, self.x + 180, self.y + 84)

   self.alist:draw()
end

function RollAttributesMenu:update()
   if self.alist.chosen then
      return true
   end

   self.win:update()
   self.alist:update()

   if self.canceled then
      return nil, "canceled"
   end
end

return RollAttributesMenu
