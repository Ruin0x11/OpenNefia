local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local MapObjectBatch = require("api.draw.MapObjectBatch")
local Chara = require("api.Chara")
local Adventurer = require("mod.elona.api.Adventurer")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local ListAdventurersMenu = class.class("ListAdventurersMenu", IUiLayer)

ListAdventurersMenu:delegate("pages", "chosen")
ListAdventurersMenu:delegate("input", IInput)

local UiListExt = function(choose_npc_menu)
   local E = {}

   function E:get_item_text(entry)
      return ""
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.set_blend_mode("subtract")
         Draw.filled_rect(x - 1, y, 540, 18, {12, 14, 16})
         Draw.set_blend_mode("alpha")
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end
   function E:draw_item_text(text, entry, i, x, y, x_offset)
      choose_npc_menu.map_object_batch:add(entry.adv, x - 18 - 24, y, nil, nil, nil, true)

      Draw.set_color(0, 0, 0)
      Draw.text(entry.rank, x + 26, y + 2)
      Draw.text(entry.name_rank, x + 60, y + 2)
      Draw.text(entry.fame_lv, x + 344 - Draw.text_width(entry.fame_lv), y + 2)
      Draw.text(entry.location, x + 377, y + 2)
   end
   function E:draw()
      UiList.draw(self)
      choose_npc_menu.map_object_batch:draw()
      choose_npc_menu.map_object_batch:clear()
   end

   return E
end

function ListAdventurersMenu.generate_list(advs)
   local list = fun.iter(advs):filter(Chara.is_alive)
      :map(function(adv)
            local name_rank = utf8.wide_sub(("%s %s"):format(adv:calc("title"), adv:calc("name"), 0, 26))
            local fame_lv = ("%d(%d)"):format(adv.fame, adv.level)
            local location = utf8.wide_sub(Adventurer.location_name(adv), 0, 18)

            return {
               adv = adv,
               name_rank = name_rank,
               fame_lv = fame_lv,
               location = location,
               fame = adv.fame
            }
          end)
      :to_list()

   table.insertion_sort(list, function(a, b) return a.fame > b.fame end)

   for i, entry in ipairs(list) do
      entry.rank = I18N.get("ui.adventurers.rank_counter", i)
   end

   return list
end

function ListAdventurersMenu:init(advs)
   self.data = ListAdventurersMenu.generate_list(advs)
   self.pages = UiList:new_paged(self.data, 16)

   table.merge(self.pages, UiListExt(self))

   self.map_object_batch = nil

   local key_hints = self:make_key_hints()
   self.window = UiWindow:new("ui.adventurers.title", true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ListAdventurersMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function ListAdventurersMenu:make_key_hints()
   local hints = self.pages:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ListAdventurersMenu:relayout()
   self.width = 640
   self.height = 448
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.map_object_batch = MapObjectBatch:new()

   self.window:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66, self.width, self.height)
end

function ListAdventurersMenu:draw()
   self.window:draw()

   Ui.draw_topic("ui.adventurers.name_and_rank", self.x + 28, self.y + 36)
   Ui.draw_topic("ui.adventurers.fame_lv", self.x + 320, self.y + 36)
   Ui.draw_topic("ui.adventurers.location", self.x + 420, self.y + 36)

   self.pages:draw()
end

function ListAdventurersMenu:update(dt)
   local canceled = self.canceled
   local chosen = self.pages.chosen

   self.canceled = nil
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if chosen then
      return self.pages:selected_item().adv, nil
   end
end

function ListAdventurersMenu:release()
   if self.map_object_batch then
      self.map_object_batch:release()
   end
end

return ListAdventurersMenu
