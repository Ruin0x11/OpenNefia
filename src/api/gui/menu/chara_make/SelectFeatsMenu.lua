local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local FeatsMenu = require("api.gui.menu.FeatsMenu")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")

local SelectFeatsMenu = class.class("SelectFeatsMenu", ICharaMakeSection)

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
