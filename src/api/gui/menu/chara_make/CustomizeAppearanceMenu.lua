local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local ChangeAppearanceMenu = require("api.gui.menu.ChangeAppearanceMenu")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")

local CustomizeAppearanceMenu = class.class("CustomizeAppearanceMenu", ICharaMakeSection)

CustomizeAppearanceMenu:delegate("input", IInput)

function CustomizeAppearanceMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.charamake_data.chara.use_pcc = true

   self.caption = "chara_make.customize_appearance.caption"
   self.intro_sound = "base.port"

   self.menu = ChangeAppearanceMenu:new(self.charamake_data.chara)

   self.input = InputHandler:new()
   self.input:forward_to(self.menu)
end

function CustomizeAppearanceMenu:make_keymap()
   return {}
end

function CustomizeAppearanceMenu:on_charamake_finish(chara)
end

function CustomizeAppearanceMenu:get_charamake_result(charamake_data)
   return charamake_data
end

function CustomizeAppearanceMenu:relayout(x, y, width, height)
   self.menu:relayout(x, y, width, height)
end

function CustomizeAppearanceMenu:draw()
   self.menu:draw()
end

function CustomizeAppearanceMenu:update(dt)
   local finished, canceled = self.menu:update(dt)

   if canceled then
      return nil, canceled
   end

   if finished then
      return true
   end
end

return CustomizeAppearanceMenu
