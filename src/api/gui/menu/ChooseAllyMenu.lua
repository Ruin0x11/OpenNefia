local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Input = require("api.Input")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local ChooseAllyMenu = class.class("ChooseAllyMenu", IUiLayer)

ChooseAllyMenu:delegate("pages", "chosen")
ChooseAllyMenu:delegate("input", IInput)

local UiListExt = function(choose_ally_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end
   function E:draw_item_text(text, entry, i, x, y, x_offset)
      if entry.kind == "ally" then
         Draw.chip(entry.icon, x - 44, y + 8, nil, nil, entry.color, true)
      end
      UiList.draw_item_text(self, text, entry, i, x, y, x_offset)

      -- TODO x offset can differ based on operation
      Draw.text(entry.info, x + 100, y + 2)
   end

   return E
end

function ChooseAllyMenu:init(filter)
   self.data = {}
   self.pages = UiList:new_paged(self.data, 16)
   self.filter = filter

   self.multi_select = false
   self.multi_select_count = 2
   self.multi_select_selected = {}

   self.select = function(entry) return entry end

   self.headers = {
      "name",
      "sell.value"
   }

   self.window = UiWindow:new("title", true, "hint")
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }
end

function ChooseAllyMenu:on_query()
   Gui.mes("ally?")
end

function ChooseAllyMenu:populate_list()
   self.data = {}

   if self.multi_select then
      self.data[#self.data+1] = { kind = "proceed", text = "Proceed" }
   end

   for _, ally in Chara.iter_allies() do
      if self:should_display_ally(ally) then
         self.data[#self.data+1] = {
            kind = "ally",
            text = string.format("%s %s Lv.%s", ally.title, ally.name, ally:calc("level")),
            icon = ally:calc("image"),
            color = {255, 255, 255},
            info = "info",
            ally = ally
         }
      end
   end

   table.insertion_sort(self.data, function(a, b) return a:calc("level") > b:calc("level") end)

   if self.multi_select then
      -- select the first N allies by default until max is reached
      local selected = 0
      for i, ally in ipairs(self.data) do
         if selected >= self.multi_select_count then
            break
         end
         if ally.state ~= "PetDead" then
            self.multi_select_selected[i] = true
            selected = selected + 1
         end
      end
   end
end

function ChooseAllyMenu:relayout()
   local width = 620
   local window_height = 400
   local height = window_height * 4
   local x, y = Ui.params_centered(width, height)

   self.t = UiTheme.load(self)

   self.window:relayout(x, y, width, height)
   self.pages:relayout(x + 58, y + 66, width, height)

   Ui.draw_topic(self.headers[1], self.x + 28, self.y + 36)
   Ui.draw_topic(self.headers[2], self.x + 350, self.y + 36)
end

function ChooseAllyMenu:draw()
   self.t.deco_board_a:draw_tiled()

   self.pages:draw()
end

function ChooseAllyMenu:on_multi_select(entry)
   if entry.kind == "proceed" then
      if self.multi_select then
         if table.count(self.multi_select_selected) == 0 then
            Gui.mes("need at least one")
            Gui.play_sound("base.fail1")
            return nil
         else
            local allies = {}
            for _, ally in pairs(self.multi_select_selected) do
               allies[#allies+1] = ally
            end
            Gui.play_sound("base.ok1")
            return allies
         end
      end
   elseif entry.kind == "ally" then
      if entry.ally.state == "PetDead" then
         Gui.mes("petdead")
         Gui.play_sound("base.fail1")
         return nil
      end

      if not self.multi_select_selected[entry.ally] then
         local count = table.count(self.multi_select_selected)
         if count >= self.multi_select_count then
            Gui.play_sound("base.fail1")
            Gui.mes("too many")
         else
            self.multi_select_selected[entry.ally] = true
            Gui.play_sound("base.ok1")
         end
      else
         self.multi_select_selected[entry.ally] = nil
         Gui.play_sound("base.ok1")
      end
   end

   return nil
end

function ChooseAllyMenu:on_select(entry)
   if self.multi_select then
      return self:on_multi_select(entry)
   end

   return self:select(entry)
end

function ChooseAllyMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      local result = self:on_select(self.pages.selected)
      if result then
         return result
      end
   end

   self.pages:update()
end

return ChooseAllyMenu
