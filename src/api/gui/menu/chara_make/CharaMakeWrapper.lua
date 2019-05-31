local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ISettable = require("api.gui.ISettable")
local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local KeyHandler = require("api.gui.KeyHandler")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")
local Prompt = require("api.gui.Prompt")

local CharaMakeWrapper = class("CharaMakeWrapper", IUiLayer)

CharaMakeWrapper:delegate("submenu", {"focus", "bind"})

function CharaMakeWrapper:init(submenu)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.submenu = submenu
   self.trail = {}
   self.results = {}
   self.gene_used = "gene"

   self.bg = Draw.load_image("graphic/void.bmp")
   self.caption = CharaMakeCaption:new(20, 30, "")

   self.keys = KeyHandler:new()

   self:proceed(submenu)
end

function CharaMakeWrapper:proceed(submenu)
   if self.submenu then
      table.push(self.trail, self.submenu)
   end

   self.submenu = submenu

   self.caption.caption = self.submenu.caption
   self.caption:relayout()

   assert_is_an(ICharaMakeSection, self.submenu)

   self.keys:forward_to(self.submenu)
end

function CharaMakeWrapper:go_back()
   if #self.trail <= 1 then return end

   self.submenu = table.pop(self.trail)

   self.caption.caption = self.submenu.caption
   self.caption:relayout()

   self.keys:forward_to(self.submenu)
end

function CharaMakeWrapper:relayout()
   self.caption:relayout()
   self.submenu:relayout()
end

function CharaMakeWrapper:draw()
   Draw.image(self.bg, self.x, self.y, self.width, self.height, {255, 255, 255})

   self.caption:draw()

   Draw.set_font(13, "bold") -- 13 - en * 2
   Draw.text("Press F1 to show help.", self.x + 20, self.height - 20, {0, 0, 0})

   if self.gene_used then
      Draw.text("Gene from " .. self.gene_used, self.x + 20, self.height - 36)
   end

   self.submenu:draw()
end

function CharaMakeWrapper:final_query()
   local d = Prompt:new("yes", "no", "go back", "return"):query()
   if r == "yes" then
      local canceled
      -- r, canceled = TextDialog:new():query()
      -- if canceled then
      --    return false
      -- else
      --    return r
      -- end
   elseif r == "no" then
      return false
   elseif r == "go back" then
      return false
   elseif r == "return" then
      return false
   end
end

function CharaMakeWrapper:update()
   self.keys:run_actions()

   local result = self.submenu:update()
   if result then
      self.results[self.submenu.name] = result
   end

   local has_next = true
   if has_next then
      self:proceed()
   else
      local final = self:final_query()
   end
end

return CharaMakeWrapper
