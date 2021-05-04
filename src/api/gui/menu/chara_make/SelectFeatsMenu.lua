local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local FeatsMenu = require("api.gui.menu.FeatsMenu")
local ICharaMakeMenu = require("api.gui.menu.chara_make.ICharaMakeMenu")

local SelectFeatsMenu = class.class("SelectFeatsMenu", ICharaMakeMenu)

SelectFeatsMenu:delegate("input", IInput)

function SelectFeatsMenu:init(charamake_data)
   self.charamake_data = charamake_data

   self:on_charamake_query_menu()

   self.caption = "chara_make.select_feats.caption"
   self.intro_sound = "base.feat"
end

function SelectFeatsMenu:make_keymap()
   return {}
end

function SelectFeatsMenu:relayout()
   self.inner:relayout()
end

function SelectFeatsMenu:draw()
   self.inner:draw()
end

function SelectFeatsMenu:on_charamake_query_menu()
   local chara = self.charamake_data.chara
   chara.traits = {}
   chara.feats_acquirable = 3
   self.inner = FeatsMenu:new(chara, true)

   self.input = InputHandler:new()
   self.input:forward_to(self.inner)
end

function SelectFeatsMenu:update()
   if self.charamake_data.chara.feats_acquirable == 0 then
      return true
   end

   if self.inner.canceled then
      return nil, "canceled"
   end

   self.inner:update()
end

return SelectFeatsMenu
