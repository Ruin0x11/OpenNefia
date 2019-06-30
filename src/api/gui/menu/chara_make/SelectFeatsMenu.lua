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

function SelectFeatsMenu:init(chara)
   self.inner = FeatsMenu:new(chara)
   self.inner.chara_make = true

   self.input = InputHandler:new()
   self.input:forward_to(self.inner)

   self.caption = "Your caption here."
   self.intro_sound = "base.feat"
end

function SelectFeatsMenu:relayout()
   self.inner:relayout()
end

function SelectFeatsMenu:draw()
   self.inner:draw()
end

function SelectFeatsMenu:on_charamake_finish(chara)
end

function SelectFeatsMenu:update()
   if self.inner.chosen then
      -- if self.chara.feats_learnable == 0
      return true
   end

   if self.inner.canceled then
      return nil, "canceled"
   end

   self.inner:update()
end

return SelectFeatsMenu
