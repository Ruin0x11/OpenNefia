local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local SelectAliasMenu = class("SelectAliasMenu", IUiLayer)

SelectAliasMenu:delegate("input", IInput)
SelectAliasMenu:delegate("list", "items")

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

function SelectAliasMenu:init()
   self.width = 400
   self.height = 458

   self.win = UiWindow:new("alias")

   local items = {
      { text = "Reroll", type = "reroll", on_choose = function() self:reroll() end }
   }
   table.append(items, table.of(function(i) return { text = "alias" .. i, type = "alias" } end, 16))

   self.list = UiList:new(items)
   table.merge(self.list, UiListExt(self))

   self.bg = Ui.random_cm_bg()

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      ["kp*"] = function() -- BUG stopgap for now
         self:lock(self.list.selected)
      end,
      shift = function() self.canceled = true end
   }

   self.caption = "Choose an alias."
   self.intro_sound = "base.ok1"
end

function SelectAliasMenu:lock(i)
   if not self.items[i] then return end

   if self.items[i].locked then
      self.items[i].locked = nil
   else
      self.items[i].locked = true
   end
end

function SelectAliasMenu:reroll()
   print("reroll")
   for _, v in ipairs(self.items) do
      if v.type == "alias" and not v.locked then
         v.text = "alias" .. math.random(1, 15)
      end
   end
end

function SelectAliasMenu:relayout(x, y)
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
end

function SelectAliasMenu:on_charamake_finish()
end

function SelectAliasMenu:draw()
   self.win:draw()
   self.list:draw()
   Ui.draw_topic("alias_list", self.x + 28, self.y + 30)

   Draw.image(self.bg,
              self.x + self.width / 2,
              self.y + self.height / 2,
              self.width / 3 * 2,
              self.height - 80,
              {255, 255, 255, 40},
              true)
end

function SelectAliasMenu:update()
   if self.list.chosen then
      return true
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectAliasMenu
