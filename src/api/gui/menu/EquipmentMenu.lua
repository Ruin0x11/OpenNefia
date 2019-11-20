local Action = require("api.Action")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local Input = require("api.Input")
local InputHandler = require("api.gui.InputHandler")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")

local EquipmentMenu = class.class("EquipmentMenu", {IUiLayer, IPaged})

EquipmentMenu:delegate("input", IInput)
EquipmentMenu:delegate("pages", IPaged)

local UiListExt = function(equipment_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end
   function E:get_item_color(entry)
      return entry.color
   end
   function E:draw_select_key(entry, i, key_name, x, y)
      if i % 2 == 0 then
         Draw.filled_rect(x, y, 558, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, entry, i, key_name, x, y)

      Draw.set_color(255, 255, 255)

      local icon = entry.body_part.icon or 1
      equipment_menu.t.body_part_icons:draw_region(icon, x - 66, y - 2) -- wx + 88 - 66 = wx + 22
      Draw.set_font(12, "bold") -- 12 + sizefix - en * 2

      Draw.text(I18N.get("ui.body_part." .. entry.body_part._id), x - 42, y + 3, {0, 0, 0}) -- wx + 88 - y = wx + 46
   end
   function E:draw_item_text(item_name, entry, i, x, y, x_offset, color)
      local subtext = entry.subtext

      if entry.equipped then
         entry.icon:draw(x + 12, y + 10, nil, nil, {255, 255, 255}, true)

         if equipment_menu.layout then
            item_name, subtext = equipment_menu.layout:draw_row(entry.equipped, item_name, subtext, x, y)
         end
      end

      UiList.draw_item_text(self, item_name, entry, i, x, y, 30, color)

      Draw.text(subtext, x + 530 - Draw.text_width(subtext), y + 2, color)

   end

   return E
end

function EquipmentMenu:init(chara)
   self.width = 690
   self.height = 428

   self.chara = chara
   self.win = UiWindow:new("equipment_menu")
   self.pages = UiList:new_paged({}, 14)
   table.merge(self.pages, UiListExt(self))
   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      x = function() self:show_item_description() end,
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }

   self.stats = {}
   self.changed_equipment = false

   self:update_from_chara()
end

function EquipmentMenu:on_hotload_layer()
   table.merge(self.pages, UiListExt(self))
end

function EquipmentMenu:show_item_description()
   local item = self:selected_item_object()
   local rest = self.pages:iter_all_pages():to_list()
   ItemDescriptionMenu:new(item, rest):query()
end

function EquipmentMenu:refresh_item_icons()
   for _, entry in self.pages:iter() do
      if entry.equipped and not entry.icon then
         entry.icon = entry.equipped:copy_image()
      end
   end
end

function EquipmentMenu:update_from_chara()
   local data = {}
   for _, i in self.chara:iter_body_parts(true) do
      local entry = {}

      entry.body_part = i.body_part
      entry.equipped = nil
      entry.icon = nil
      entry.color = {10, 10, 10}
      entry.text = "-    "
      entry.subtext = "-"

      if i.equipped then
         entry.equipped = i.equipped
         entry.icon = i.equipped:copy_image()
         entry.color = i.equipped:calc_ui_color()
         entry.text = i.equipped:build_name()
         entry.subtext = Ui.display_weight(i.equipped:calc("weight"))
      end

      data[#data + 1] = entry
   end

   self.pages:set_data(data)
   self.win:set_pages(self.pages)
   self:refresh_item_icons()

   self.stats = {
      dv = self.chara:calc("dv"),
      pv = self.chara:calc("pv"),
      weight = self.chara:calc("equipment_weight"),
      hit_bonus = self.chara:calc("hit_bonus"),
      damage_bonus = self.chara:calc("damage_bonus"),
   }

   Gui.update_hud()
end

function EquipmentMenu:on_query()
   self.canceled = false
   Gui.play_sound("base.wear");
end

function EquipmentMenu:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 88, self.y + 60, self.width, self.height)
   self.win:set_pages(self.pages)
end

function EquipmentMenu:draw()
   self.win:draw()

   Ui.draw_topic("Category/Name", self.x + 28, self.y + 30)

   Draw.set_color(255, 255, 255)
   self.t.inventory_icons:draw_region(10, self.x + 46, self.y - 16)
   self.t.deco_wear_a:draw(self.x + self.width - 106, self.y)
   self.t.deco_wear_b:draw(self.x, self.y + self.height - 164)

   local note = string.format("weight: %s(%s) hit_bonus: %d damage_bonus: %d  DV/PV: %d/%d",
                              self.stats.weight,
                              "med",
                              self.stats.hit_bonus,
                              self.stats.damage_bonus,
                              self.stats.dv,
                              self.stats.pv)
   Ui.draw_note(note, self.x, self.y, self.width, self.height, 0)

   self.pages:draw()
end

function EquipmentMenu:update()
   if self.canceled then
      if self.changed_equipment then
         Gui.mes(self.chara.uid .. " changes equipment. ")
         return "turn_end"
      end

      return "player_turn_query"
   end

   if self.pages.chosen then
      local slot = self.pages.selected
      local entry = self.pages:selected_item()

      if entry.equipped then
         local success, err = Action.unequip(self.chara, entry.equipped)
         if success then
            self.changed_equipment = true
            self:update_from_chara()
         else
            Gui.mes("Can't unequip: " .. err)
         end
      else
         local selected_item, canceled = Input.query_item(self.chara, "inv_equip", { body_part_id = entry.body_part._id })
         if not canceled then
            assert(Action.equip(self.chara, selected_item))
            self.changed_equipment = true
            self:update_from_chara()
         end
      end
   end

   if self.pages.changed_page then
      self:refresh_item_icons()
      self.win:set_pages(self)
   end

   self.win:update()
   self.pages:update()
end

return EquipmentMenu
