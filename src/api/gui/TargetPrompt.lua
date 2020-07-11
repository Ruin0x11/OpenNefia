local Draw = require("api.Draw")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Action = require("api.Action")

local TargetPromptList = require("api.gui.TargetPromptList")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local TargetPrompt = class.class("TargetPrompt", IUiLayer)

TargetPrompt:delegate("input", IInput)

function TargetPrompt:init(chara, targets)
   self.chara = chara

   self.targets = targets or Action.build_target_list(self.chara)
   self.canceled = false
   self.list = TargetPromptList:new(self.targets, chara.x, chara.y)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.target_text = {}
   self:update_target_text()
end

function TargetPrompt:make_keymap()
   return {
      north = function()
         self.list:run_keybind_action("north")
         self:update_target_text()
      end,
      south = function()
         self.list:run_keybind_action("south")
         self:update_target_text()
      end,
      west = function()
         self.list:run_keybind_action("west")
         self:update_target_text()
      end,
      east = function()
         self.list:run_keybind_action("east")
         self:update_target_text()
      end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function TargetPrompt:update_target_text()
   local target = self.list:selected_item()
   if target then
      self.target_text = Action.target_text(self.chara, target.x, target.y, true)
   end
end

function TargetPrompt:on_query()
   if #self.targets == 0 then
      Gui.mes_duplicate()
      Gui.mes("action.look.find_nothing")
      return false
   end
end

function TargetPrompt:relayout()
   -- self.x, self.y = Gui.tile_to_screen(self.target_x, self.target_y)
   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.t = UiTheme.load(self)
   self.list:relayout(0, 0)
end

function TargetPrompt:draw()
   Draw.set_blend_mode("add")
  
   self.list:draw()

   for i, line in ipairs(self.target_text) do
      Draw.text_shadowed(line, 100, Gui.message_window_y() - 45 - i * 20)
   end
end

function TargetPrompt:update(dt)
   if self.canceled then
      return nil, "canceled"
   end

   if self.list.chosen then
      return self.list:selected_item()
   end
end

return TargetPrompt
