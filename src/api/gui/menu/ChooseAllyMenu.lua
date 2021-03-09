local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local StayingCharas = require("api.StayingCharas")
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
         choose_ally_menu.chip_batch:add(entry.icon, x - 44, y + 8, nil, nil, entry.color, true)
      end
      UiList.draw_item_text(self, text, entry, i, x, y, x_offset)

      -- TODO x offset can differ based on operation
      Draw.text(entry.info, x + 272, y + 2)
   end
   function E:draw()
      UiList.draw(self)
      choose_ally_menu.chip_batch:draw()
      choose_ally_menu.chip_batch:clear()
   end

   return E
end

local function format_name_and_area(chara)
   -- >>>>>>>> shade2/command.hsp:545 		s=""+cnAka(i)+" "+cnName(i)  ...
   local name = ("%s %s"):format(chara.title, chara.name)
   local staying_map = StayingCharas.get_staying_map_for_global(chara)
   if staying_map then
      name = name .. ("(%s)"):format(staying_map.map_name)
   end
   return name
   -- <<<<<<<< shade2/command.hsp:546 		if cArea(i)!0:s=s+"("+mapName(cArea(i))+")" ..
end

function ChooseAllyMenu.make_list(charas, topic, multi_select)
   local result = {}

   if multi_select then
      result[#result+1] = { kind = "proceed", text = "Proceed" }
   end

   for _, ally in ipairs(charas) do
      local info
      if topic and topic.info_formatter then
         info = topic.info_formatter(ally)
      else
         info = ""
      end

      local name
      if topic and topic.name_formatter then
         name = topic.name_formatter(ally)
      else
         name = format_name_and_area(ally)
      end

      result[#result+1] = {
         kind = "ally",
         text = name,
         icon = ally:calc("image"),
         color = ally:calc("color"),
         info = info,
         ally = ally
      }
   end

   table.insertion_sort(result, function(a, b) return a.ally:calc("level") > b.ally:calc("level") end)

   return result
end

function ChooseAllyMenu:init(charas, topic)
   charas = charas or Chara.iter_allies():filter(Chara.is_alive):to_list()
   self.pages = UiList:new_paged({}, 16)
   self.topic = self.topic or nil

   self.multi_select = false
   self.multi_select_count = 2
   self.multi_select_selected = {}

   self.headers = {
      "name",
      "sell.value"
   }

   local title = (self.topic and self.topic.window_title) or "ui.ally_list.title"
   self.window = UiWindow:new(title, true, "key help")
   table.merge(self.pages, UiListExt(self))

   self.chip_batch = nil

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())

   local list = ChooseAllyMenu.make_list(charas, topic, self.multi_select)

   if self.multi_select then
      -- select the first N allies by default until max is reached
      local selected = 0
      for i, ally in ipairs(list) do
         if selected >= self.multi_select_count then
            break
         end
         if ally.state ~= "PetDead" then
            self.multi_select_selected[i] = true
            selected = selected + 1
         end
      end
   end

   self.pages:set_data(list)
end

function ChooseAllyMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end
   }
end

function ChooseAllyMenu:relayout()
   self.width = 620
   self.height = 400
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.chip_batch = Draw.make_chip_batch("chip")

   self.window:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66, self.width, self.height)

   Ui.draw_topic(self.headers[1], self.x + 28, self.y + 36)
   Ui.draw_topic(self.headers[2], self.x + 350, self.y + 36)
end

function ChooseAllyMenu:draw()
   self.window:draw()

   Ui.draw_topic("ui.ally_list.name", self.x + 28, self.y + 36)

   local header_status = (self.topic and self.topic.header_status) or "ui.ally_list.status"
   Ui.draw_topic(header_status, self.x + 350, self.y + 36)

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

function ChooseAllyMenu:on_select(index)
   if self.multi_select then
      return self:on_multi_select(index)
   end

   return self.pages:get(index)
end

function ChooseAllyMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      local result = self:on_select(self.pages.selected)
      if result then
         return { chara = result.ally }
      end
   end

   self.pages:update()
end

function ChooseAllyMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
end

return ChooseAllyMenu
