local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local KeyHandler = require("api.gui.KeyHandler")

local SelectAliasMenu = class("SelectAliasMenu", IUiLayer)

SelectAliasMenu:delegate("win", {"x", "y", "width", "height", "relayout"})
SelectAliasMenu:delegate("keys", "focus")

local function random_cm_bg()
   return Draw.load_image(string.format("graphic/g%d.bmp", math.random(4) - 1))
end

function SelectAliasMenu:init()
   self.x, self.y, self.width, self.height = Ui.params_centered(400, 458)
   self.y = self.y + 20
   self.locks = {}

   self.win = UiWindow:new("alias", self.x, self.y, self.width, self.height)
   self.list = UiList:new(self.x + 38, self.y + 66, table.of(function(i) return "alias" .. i end, 16))
   self.bg = random_cm_bg()

   self.list.draw_item_text = function(l, text, i, item, x, y, x_offset)
      UiList.draw_item_text(l, text, i, item, x, y, x_offset)

      if self.locks[i] or true then
         Draw.set_font(12, "bold") -- 12 - en * 2
         Draw.text("Locked!", x + 216, y + 2, {20, 20, 140})
      end
   end

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.list)
   self.keys:bind_actions {
      ["*"] = function()
         print("But I'm in my own. Locking!")
      end,
      shift = function() self.canceled = true end
   }
end

SelectAliasMenu.query = require("api.Input").query

function SelectAliasMenu:get_result()
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
   self.keys:run_actions()

   if self.list.chosen then
      return self.list:selected_item()
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectAliasMenu
