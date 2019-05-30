local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local RollAttributesMenu = class("RollAttributesMenu", IUiLayer)

RollAttributesMenu:delegate("win", {"x", "y", "width", "height"})
RollAttributesMenu:delegate("alist", {"focus", "bind"})

---------------------------------------- dupe
local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end
----------------------------------------

function RollAttributesMenu:init()
   self.x, self.y, self.width, self.height = Ui.params_centered(360, 352)
   self.y = self.y - 20
   self.locks_left = 2
   self.locks = {}
   self.finished = false

   local texts = {
      "Strength",
      "Endurance",
      "Charisma"
   }
   self.data = {
      { text = "Reroll", on_choose = function() self:reroll() end },
      { text = "Proceed", on_choose = function() self.finished = true end },
   }
   local function lock(attr)
      return function()
         self:lock(attr)
      end
   end
   for _, v in ipairs(texts) do
      self.data[#self.data + 1] = { text = v, on_choose = lock(v), locked = false, value = 0 }
   end

   self.alist = UiList:new(self.x + 38, self.y + 66, self.data, 23)
   self.alist.get_item_text = function(l, item)
      return item.text
   end

   ---------------------------------------- dupe
   self.skill_icons = Draw.load_image("graphic/temp/skill_icons.bmp")

   local iw = self.skill_icons:getWidth()
   local ih = self.skill_icons:getHeight()

   self.quad = {}
   for i, s in ipairs(texts) do
      self.quad[s] = love.graphics.newQuad(i * 48, 0, 48, 48, iw, ih)
   end
   ----------------------------------------

   self.win = UiWindow:new("chara_make.roll_attributes.reroll", self.x, self.y, self.width, self.height)

   self.bg = load_cm_bg(1)

   local super = UiList.draw_item
   self.alist.draw_item = function(l, i, item, x, y)
      super(l, i, item, x, y)
      if item.value then
         self:draw_attribute(i, item, x, y)
      end
   end

   self:reroll()
end

function RollAttributesMenu:reroll()
   for _, v in ipairs(self.data) do
      if v.value and not v.locked then
         v.value = math.random(1, 15)
      end
   end
end

function RollAttributesMenu:lock(attr)
   local a = table.find(self.data, function(i) return i.text == attr end)
   if not a or a.locked == nil then return end
   a.locked = not a.locked
end

function RollAttributesMenu:draw_attribute(i, item, x, y)
   Draw.set_font(15, "bold")

   local quad = self.quad[item.text]
   if quad then
      Draw.image_region(self.skill_icons, quad, x + 160, y + 10, nil, nil, {255, 255, 255}, true)
   end

   Draw.text("123", x + 172, y, {0, 0, 0})

   local is_locked = true
   if is_locked then
      Draw.set_font(12, "bold") -- 12 - en * 2
      Draw.text("Locked!", x + 202, y + 2, {20, 20, 140})
   end
end

function RollAttributesMenu:restore(data)
   self.locks_left = data.locks_left
   self.locks = data.locks
   self.finished = false
end

function RollAttributesMenu:relayout()
   self.win:relayout()
   self.alist:relayout()
end

function RollAttributesMenu:draw()
   self.win:draw()
   Draw.image(self.bg, self.x + 85, self.y + self.height / 2, 150, 240, {255, 255, 255, 30})

   Draw.set_color()
   Ui.draw_topic("chara_making.roll_attributes.title", self.x + 28, self.y + 30)

   Draw.set_color(0, 0, 0)
   Draw.set_font(12) -- 12 + sizefix - en * 2
   Draw.text("locked items", self.x + 175, self.y + 52)
   Draw.set_font(13, "bold") -- 13 - en * 2
   Draw.text("remain" .. ": " .. self.locks_left, self.x + 180, self.y + 84)

   self.alist:draw()
end

function RollAttributesMenu:update()
   if self.finished then
      return true
   end

   self.win:update()
   self.alist:update()
end

return RollAttributesMenu
