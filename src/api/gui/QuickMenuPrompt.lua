local Draw = require("api.Draw")
local Gui = require("api.Gui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local QuickMenuList = require("api.gui.QuickMenuList")

local QuickMenuPrompt = class.class("QuickMenuPrompt", IUiLayer)

QuickMenuPrompt:delegate("input", IInput)

local last_page

function QuickMenuPrompt:init()
   local pages = {
      {
         title = "Info",
         items = {
            { text = "Help", action = "help" },
            { text = "Log", action = "message_log" },
            { text = "Chara", action = "chara_info" },
            nil,
            { text = "Journal", action = "journal" },
            nil
         }
      },
      {
         title = "Action",
         items = {
            { text = "Wear", action = "wear" },
            { text = "Rest", action = "rest" },
            { text = "Spell", action = "cast" },
            { text = "Skill", action = "skill" },
            { text = "Fire", action = "fire" },
            { text = "Dig", action = "dig" }
         }
      },
      {
         title = "Etc",
         items = {
            { text = "Pray", action = "pray" },
            { text = "Ammo", action = "ammo" },
            { text = "Interact", action = "interact" },
            nil,
            { text = "Bash", action = "bash" },
            nil
         }
      },
   }
   self.list = QuickMenuList:new(pages)
   self.list:select_page(1)

   self.frame = 0

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   if last_page then
   end
end

function QuickMenuPrompt:make_keymap()
   return {
      escape = function()
         self.canceled = true
      end,
      cancel = function()
         self.canceled = true
      end
   }
end

function QuickMenuPrompt:relayout(x, y)
   self.t = UiTheme.load(self)
   self.list:relayout(50, 345)
end

function QuickMenuPrompt:on_query()
   Gui.play_sound("base.cursor1")
end

function QuickMenuPrompt:draw()
   self.list:draw()
end

function QuickMenuPrompt:update(dt)
   local result = self.list:update(dt)
   if result then
      return result.action or ""
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return QuickMenuPrompt
