local Chara = require("api.Chara")
local Text = require("mod.elona.api.Text")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local Event = require("api.Event")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local TestMenu = class.class("TestMenu", ICharaMakeSection)

TestMenu:delegate("input", IInput)
TestMenu:delegate("list", "items")

local UiListExt = function(select_alias_menu)
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
   function E:draw_item_text(text, item, i, x, y, x_offset)
      UiList.draw_item_text(self, text, item, i, x, y, x_offset)

      if item.locked then
         Draw.set_font(12, "bold") -- 12 - en * 2
         Draw.text("Locked!", x + 216, y + 2, {20, 20, 140})
      end
   end

   return E
end

function TestMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 400
   self.height = 458

   self.win = UiWindow:new("chara_make.select_alias.title", true)

   local items = {
      { text = I18N.get("chara_make.common.reroll"), type = "reroll", on_choose = function() self:reroll(true) end }
   }
   for i = 1, 16 do
      items[#items+1] = { text = Text.random_name(), type = "name" }
   end

   self.list = UiList:new(items)
   table.merge(self.list, UiListExt(self))

   self.bg_index = 0

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "Select a name."
   self.intro_sound = "base.ok1"

   self:reroll(false)
end

function TestMenu:make_keymap()
   return {
      mode2 = function()
         self:lock(self.list.selected)
      end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function TestMenu:relayout(x, y)
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
end

function TestMenu:lock(i)
   if not self.items[i] then return end
   if self.items[i].type ~= "name" then return end

   Gui.play_sound("base.ok1")
   if self.items[i].locked then
      self.items[i].locked = nil
   else
      self.items[i].locked = true
   end
end

function TestMenu:reroll(play_sound)
   for _, v in ipairs(self.items) do
      if v.type == "name" and not v.locked then
         v.text = Text.random_name()
      end
   end

   if play_sound then
      Gui.play_sound("base.dice")
   end

   self.bg_index = self.bg_index + 1
end

function TestMenu:draw()
   self.win:draw()
   self.list:draw()
   Ui.draw_topic("chara_make.select_alias.alias_list", self.x + 28, self.y + 30)

   local bg = self.t.base["g" .. (math.floor(self.bg_index / 4) % 4 + 1)]
   bg:draw(
      self.x + self.width / 2,
      self.y + self.height / 2,
      self.width / 3 * 2,
      self.height - 80,
      {255, 255, 255, 40},
      true)
end

function TestMenu:update()
   if self.list.chosen then
      local name = self.list:selected_item().text
      self.charamake_data.chara = Chara.create("elona.putit", nil, nil, { ownerless = true })
      self.charamake_data.chara.name = name
      return self.charamake_data
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return TestMenu
