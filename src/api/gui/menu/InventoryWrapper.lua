local Draw = require("api.Draw")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local IconBar = require("api.gui.menu.IconBar")
local InputHandler = require("api.gui.InputHandler")
local InventoryContext = require("api.gui.menu.InventoryContext")
local InventoryContext = require("api.gui.menu.InventoryContext")
local InventoryMenu = require("api.gui.menu.InventoryMenu")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")

local InventoryWrapper = class("InventoryWrapper", IUiLayer)

InventoryWrapper:delegate("input", IInput)

local protos = require("api.gui.menu.InventoryProtos")

function InventoryWrapper:init(params)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.params = params

   self.input = InputHandler:new()
   self.submenu = nil
   self.icon_bar = IconBar:new()

   self:switch_context()
end

function InventoryWrapper:switch_context()
   local ctxt = InventoryContext:new(protos.inv_general, self.params)
   self.submenu = InventoryMenu:new(ctxt)
   self.input:forward_to(self.submenu)

   self.submenu:relayout(self.x, self.y, self.width, self.height)
end

function InventoryWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   local count = 12
   self.icon_bar:set_data(self.t.inventory_icons)
   self.icon_bar:relayout(self.width - (44 * count + 60), 34, 44 * count + 40, 22)

   self.submenu:relayout(self.x, self.y, self.width, self.height)
end

function InventoryWrapper:draw()
   self.icon_bar:draw()
   self.submenu:draw()
end

function InventoryWrapper:handle_action(act)
   if act == "go_to_start" then
      self:go_to_start()
   else
      if #self.trail == 0 then
         self.canceled = true
      else
         self:go_back()
      end
   end
end

function InventoryWrapper:update()
   local result, canceled = self.submenu:update()
   if canceled then
      return nil, "canceled"
   elseif result then
      return result
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return InventoryWrapper
