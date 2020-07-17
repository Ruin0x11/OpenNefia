local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Input = require("api.Input")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local ChooseNpcMenu = class.class("ChooseNpcMenu", IUiLayer)

ChooseNpcMenu:delegate("pages", "chosen")
ChooseNpcMenu:delegate("input", IInput)

local UiListExt = function(choose_npc_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end
   function E:draw_item_text(text, entry, i, x, y, x_offset)
      choose_npc_menu.chip_batch:add(entry.icon, x - 44, y - 7, nil, nil, entry.color, true)
      UiList.draw_item_text(self, text, entry, i, x, y, x_offset)

      Draw.text(entry.info, x + 288, y + 3)
   end
   function E:draw()
      UiList.draw(self)
      choose_npc_menu.chip_batch:draw()
      choose_npc_menu.chip_batch:clear()
   end

   return E
end

function ChooseNpcMenu.generate_list(filter)
   local filter_ = function(chara)
      if filter and not filter(chara) then
         return false
      end

      if chara:is_player() then
         return false
      end

      if chara:calc("is_being_escorted") then
         return false
      end

      return true
   end

   local list = Chara.iter_all():filter(filter_)
      :map(function(chara)
            local gender = I18N.capitalize(I18N.get("ui.sex3." .. chara:calc("gender")))
            local age = I18N.get("ui.npc_list.age_counter", chara:calc("age"))
            return {
               text = utf8.wide_sub(chara:calc("name"), 0, 36),
               icon = chara:calc("image"),
               color = {255, 255, 255},
               info = ("Lv.%d %s%s"):format(chara:calc("level"), gender, age),
               info2 = "", -- TODO hire cost
               chara = chara,
               ordering = chara:calc("level")
            }
          end)
      :to_list()

   table.insertion_sort(list, function(a, b) return a.ordering > b.ordering end)

   return list
end

function ChooseNpcMenu:init(filter)
   self.data = ChooseNpcMenu.generate_list(filter)
   self.pages = UiList:new_paged(self.data, 16)
   self.filter = filter

   self.window = UiWindow:new("title", true, "hint")
   table.merge(self.pages, UiListExt(self))

   self.chip_batch = nil

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ChooseNpcMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function ChooseNpcMenu:relayout()
   self.width = 700
   self.height = 448
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.chip_batch = Draw.make_chip_batch("chip")

   self.window:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66, self.width, self.height)
end

function ChooseNpcMenu:draw()
   self.window:draw()

   Ui.draw_topic("ui.npc_list.name", self.x + 28, self.y + 36)
   Ui.draw_topic("ui.npc_list.info", self.x + 350, self.y + 36)

   -- TODO hire
   local ctrl
   if ctrl == "hire" then
      Ui.draw_topic("ui.npc_list.init_cost", self.x + 490, self.y + 36)
   elseif ctrl == "list" then
      Ui.draw_topic("ui.npc_list.wage", self.x + 490, self.y + 36)
   end

   self.pages:draw()
end

function ChooseNpcMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      return self.pages:selected_item().chara
   end

   self.pages:update()
end

function ChooseNpcMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
end

return ChooseNpcMenu
