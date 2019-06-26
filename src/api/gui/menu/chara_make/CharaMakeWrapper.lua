local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local env = require("internal.env")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local InputHandler = require("api.gui.InputHandler")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")
local Prompt = require("api.gui.Prompt")

local CharaMakeWrapper = class("CharaMakeWrapper", IUiLayer)

CharaMakeWrapper:delegate("input", IInput)

function CharaMakeWrapper:init(menus)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.menus = menus
   self.trail = {}
   self.results = {}
   self.gene_used = "gene"

   self.bg = Draw.load_image("graphic/core/void.png")
   self.caption = CharaMakeCaption:new()

   self.input = InputHandler:new()

   self:proceed()
end

function CharaMakeWrapper:proceed()
   if self.submenu then
      table.insert(self.trail, self.submenu)
   end

   local menu_id = self.menus[#self.trail+1]
   local success, class = pcall(function() return env.safe_require(menu_id) end)

   if not success then
      local err = class
      -- TODO turn this into a log warning
      error("Error loading menu " .. menu_id .. ":\n\t" .. err)
   elseif class == nil then
      error("Cannot find menu " .. menu_id)
   end

   self.submenu = class:new()
   assert_is_an(ICharaMakeSection, self.submenu)

   self.caption:set_data(self.submenu.caption)
   self:relayout()

   Gui.play_sound(self.submenu.intro_sound)

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_back()
   if #self.trail == 0 then return end

   self.submenu = table.remove(self.trail)
   self.submenu:on_charamake_go_back()
   print(self.submenu:get_fq_name())

   self.caption:set_data(self.submenu.caption)
   self:relayout()

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_to_start()
   while #self.trail > 0 do
      self:go_back()
   end

   -- call the constructor of the first menu again.
   self.submenu = nil
   self:proceed()
end

function CharaMakeWrapper:get_section_result(fq_name)
   for _, menu in ipairs(self.trail) do
      if menu:get_fq_name() == fq_name then
         return menu:charamake_result()
      end
   end

   return nil
end

function CharaMakeWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.caption:relayout(self.x + 20, self.y + 30)
   self.submenu:relayout(self.x, self.y, self.width, self.height)
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

function CharaMakeWrapper:handle_action(act)
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

function CharaMakeWrapper:update()
   local result, canceled = self.submenu:update()
   if canceled then
      local act = table.maybe(result, "chara_make_action")
      self:handle_action(act)
   elseif result then
      self.results[self.submenu.name] = result

      local has_next = self.menus[#self.trail+1] ~= nil
      if has_next then
         self:proceed()
      else
         for _, menu in ipairs(self.trail) do
            local result = menu:charamake_result()
            menu:on_charamake_finish(result)
         end
         return true
      end
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return CharaMakeWrapper
