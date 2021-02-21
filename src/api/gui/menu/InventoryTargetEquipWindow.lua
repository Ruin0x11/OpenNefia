local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local Window = require("api.gui.Window")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local UiTheme = require("api.gui.UiTheme")

local InventoryTargetEquipWindow = class.class("InventoryTargetEquipWindow", {IUiElement, ISettable})

function InventoryTargetEquipWindow:init()
   self.win_shadow = Window:new(true)
   self.win = Window:new()

   self.text_dv_pv = ""
   self.text_equip_weight = ""
end

function InventoryTargetEquipWindow:set_data(target)
   local dv = target:calc("dv")
   local pv = target:calc("pv")
   self.text_dv_pv = ("Dv:%d Pv:%d"):format(dv, pv)

   local equipment_weight = target:calc("equipment_weight")
   self.text_equip_weight = I18N.get("ui.inv.take_ally.window.equip_weight",
                                     Ui.display_weight(equipment_weight),
                                     Ui.display_armor_class(equipment_weight))
end

function InventoryTargetEquipWindow:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = self.t or UiTheme.load(self)

   -- >>>>>>>> shade2/command.hsp:3573 		window x+4,y+4,w,h-h¥8,0,-1 ...
   self.win_shadow:relayout(self.x+4, self.y+4, self.width, self.height - (self.height % 8))
   self.win:relayout(self.x, self.y, self.width, self.height - (self.height % 8))
   -- <<<<<<<< shade2/command.hsp:3574 		window x,y,w,h-h¥8,0,0 ..
end

function InventoryTargetEquipWindow:draw()
   -- >>>>>>>> shade2/command.hsp:3576 		fontSize 12+en,0 ...
   Draw.set_color(255, 255, 255, 80)
   Draw.set_blend_mode("subtract")
   self.win_shadow:draw()
   Draw.set_blend_mode("alpha")

   Draw.set_color(255, 255, 255)
   self.win:draw()

   Draw.set_color(self.t.base.text_color)
   Draw.set_font(12) -- fontSize 12+en,0

   Draw.text(self.text_dv_pv, self.x + 16, self.y + 17)
   Draw.text(self.text_equip_weight, self.x + 16, self.y + 35)
   -- <<<<<<<< shade2/command.hsp:3579 		x=wX+40:y=wY+wH-65-wH¥8 ..
end

function InventoryTargetEquipWindow:update(dt)
   self.win_shadow:update(dt)
   self.win:update(dt)
end

return InventoryTargetEquipWindow
