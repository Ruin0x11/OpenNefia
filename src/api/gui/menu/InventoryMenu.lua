local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local I18N = require("api.I18N")
local InventoryTargetEquipWindow = require("api.gui.menu.InventoryTargetEquipWindow")
local Chara = require("api.Chara")
local MapObjectBatch = require("api.draw.MapObjectBatch")
local save = require("internal.global.save")
local config = require("internal.config")
local Shortcut = require("mod.elona.api.Shortcut")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")

local IInput = require("api.gui.IInput")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")


--- A menu for a single inventory action, like getting or eating.
local InventoryMenu = class.class("InventoryMenu", {IUiLayer, IPaged})

InventoryMenu:delegate("input", IInput)
InventoryMenu:delegate("pages", IPaged)

local UiListExt = function(inventory_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end
   function E:get_item_color(entry)
      return entry.item:calc_ui_color()
   end
   function E:draw_select_key(entry, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 540, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, entry, i, key_name, x, y)

      inventory_menu.map_object_batch:add(entry.item, x - 21, y + 11, nil, nil, entry.color, true)

      if entry.source.on_draw then
         entry.source:on_draw(x, y, entry.item, inventory_menu)
      end
   end
   function E:draw_item_text(item_name, entry, i, x, y, x_offset, color)
      local detail_text = entry.detail_text

      if inventory_menu.layout then
         item_name, detail_text = inventory_menu.layout:draw_row(entry.item, item_name, detail_text, x, y)
      end

      UiList.draw_item_text(self, item_name, entry, i, x, y, x_offset, color)

      Draw.text(detail_text, x + 516 - Draw.text_width(detail_text), y + 2, color)
   end
   function E:draw()
      UiList.draw(self)
      inventory_menu.map_object_batch:draw()
      inventory_menu.map_object_batch:clear()
   end

   return E
end

-- TODO: Needs to remember position based on context
--   except 11 and 12 (shops)

function InventoryMenu:init(ctxt, returns_item)
   self.ctxt = ctxt
   self.returns_item = returns_item

   self.win = UiWindow:new(self.ctxt.proto.window_title, true, "key help")
   self.target_equip = InventoryTargetEquipWindow:new()
   self.pages = UiList:new_paged({}, 16)
   table.merge(self.pages, UiListExt(self))

   self.total_weight = 0
   self.max_weight = 0
   self.cargo_weight = 0
   self.layout = nil -- ResistanceLayout:new()
   self.subtext_column = self.ctxt.proto.window_detail_header or "ui.inv.window.weight"
   self.is_drawing = true
   self.total_weight_text = ""
   self.text_equip_slots = {}
   self.play_sound = false

   self.result = nil

   self.map_object_batch = nil

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   -- TODO
   -- self.pages:register("on_chosen", self.on_chosen)
   self.input:bind_keys(self:make_keymap())
   self.input:bind_keys(self.ctxt:additional_keybinds())

   self:update_filtering(true)
end

function InventoryMenu:make_keymap()
   local keymap = {
      identify = function() self:show_item_description() end,
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }

   for i = 0, 39 do
      local action = ("shortcut_%d"):format(i)
      keymap[action] = function()
         self:assign_shortcut(i)
      end
   end

   return keymap
end

function InventoryMenu:on_query()
   if self.play_sound then
      Gui.play_sound("base.inv")
   end
   self:show_query_text()
end

function InventoryMenu:show_query_text()
   if self.result ~= nil then
      return
   end

   if self.ctxt.proto.query_text then
      local params = {}
      if self.ctxt.proto.locale_params then
         params = {self.ctxt.proto:locale_params()}
      end
      Gui.mes_newline()

      local text = self.ctxt.proto.query_text
      if type(text) == "function" then
         text = text(self.ctxt)
      end
      Gui.mes(text, table.unpack(params))
   end

   self.ctxt:on_query()
end


-- TODO: IList needs refactor to "selected_entry" to avoid naming
-- confusion
function InventoryMenu:selected_item_object()
   local selected = self.pages:selected_item()
   if selected == nil then
      return nil
   end
   return selected.item
end

function InventoryMenu:show_item_description()
   local item = self:selected_item_object()
   if item == nil then
      return
   end
   local rest = self.pages:iter_all_pages():extract("item"):to_list()
   ItemDescriptionMenu:new(item, rest):query()
end

function InventoryMenu:assign_shortcut(index)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:52037 		if (key == "sc") { ...
   if not self.ctxt.proto.shortcuts then
      return
   end

   local item = self:selected_item_object()
   if item == nil then
      return
   end

   if item:get_aspect(IItemCargo) then
      Gui.play_sound("base.fail1")
      Gui.mes("ui.inv.common.shortcut.cargo")
      return
   end

   Gui.play_sound("base.ok1")

   -- TODO Break this dependency (#30)
   local result = Shortcut.assign_item_shortcut(index, item._id, self.ctxt.proto._id, item:calc("curse_state"))

   if result == "assign" then
      Gui.mes("ui.assign_shortcut", index)
   end
   self:update_filtering()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:52068 		} ..
end

function InventoryMenu:can_select()
   local item = self:selected_item_object()
   return self.ctxt:can_select(item)
end

function InventoryMenu:on_select()
   local item = self:selected_item_object()

   local amount, canceled = self.ctxt:query_item_amount(item)
   if canceled then
      return nil, canceled
   end

   -- BUG: have some way of hiding the inventory window conditionally inside
   -- on_select(). when the window was shown in vanilla and a prompt appeared
   -- over it, the screen was not redrawn, which caused the window to be kept in
   -- the screen's drawing buffer. if a directional prompt or similar which puts
   -- the focus back on the tilemap was shown instead, the screen was refreshed
   -- and the menu would not be redrawn, so it would become hidden.
   self.is_drawing = false
   local result = self.ctxt:on_select(item, amount, self.pages:iter_all_pages():extract("item"))
   self.is_drawing = true

   return result
end

function InventoryMenu:on_menu_exit()
   return self.ctxt:on_menu_exit()
end

function InventoryMenu:relayout(x, y)
   self.width = 640
   self.height = 432
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)
   self.map_object_batch = MapObjectBatch:new()

   -- >>>>>>>> shade2/command.hsp:3569 		x=winPosX(640)+455 ...
   local te_width, te_height = 200, 102
   local te_x, te_y = Ui.params_centered(self.width, self.height)
   te_x = te_x + 455
   te_y = te_y - 32
   self.target_equip:relayout(te_x, te_y, te_width, te_height)
   -- <<<<<<<< shade2/command.hsp:3574 		window x,y,w,h-h¥8,0,0 ..

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 60)
   self.win:set_pages(self.pages)
end

function InventoryMenu.filter_item(ctxt, item)
   return ctxt:filter(item)
end

local function default_detail_text(item)
   local weight = item:calc("weight")
   if item:get_aspect(IItemCargo) then
      weight = item:calc_aspect(IItemCargo, "cargo_weight")
   end
   return Ui.display_weight(weight * item.amount)
end

function InventoryMenu.build_list(ctxt)
   local filtered = {}
   local all = {}

   local sources = ctxt.sources
   if type(sources) == "string" then
      sources = {sources}
   end

   -- Obtain an iterator of IItem for each source. For example, calls
   -- IChara:iter_inventory() for the "chara" and "target" sources.
   for _, source in pairs(sources) do
      local items = source.getter(ctxt)
      items = items:map(function(item)
            local item_name = item:build_name()
            if ctxt.proto.get_item_name then
               item_name = ctxt.proto.get_item_name(item_name, item)
            end
            if source.get_item_name then
               item_name = source:get_item_name(item_name, item)
            end
            for _, index, sc in Shortcut.iter() do
               if sc.item_id == item._id
                  and sc.inventory_proto_id == ctxt.proto._id
                  and (not config.elona.item_shortcuts_respect_curse_state or sc.curse_state == item:calc("curse_state"))
               then
                  item_name = ("%s {%d}"):format(item_name, index)
                  break
               end
            end

            local detail_text = default_detail_text(item)
            if ctxt.proto.get_item_detail_text then
               detail_text = ctxt.proto.get_item_detail_text(item_name, item)
            end
            if source.get_item_detail_text then
               detail_text = source:get_item_detail_text(detail_text, item)
            end

            return {
               item = item,
               source = source,
               name = item_name,
               detail_text = detail_text,
               color = item:calc("color")
            }
      end)

      all[#all+1] = items
   end

   -- Combine each source iterator into one chained iterator.
   local iter = fun.chain(table.unpack(all))

   -- Filter invalid items and items that do not pass the filter
   -- configured for the inventory action.
   for _, entry in iter:unwrap() do
      local item = entry.item
      if item.amount <= 0 then
         item:remove_ownership()
      else
         if InventoryMenu.filter_item(ctxt, item) then
            filtered[#filtered+1] = entry
         end
      end
   end

   -- Sort everything. Defaults to item ID but can be configured per
   -- inventory context.

   -- NOTE: This needs to be a stable sort, which table.sort isn't. If
   -- correctness is not important, it should use merge sort...
   table.insertion_sort(filtered, ctxt:gen_sort())

   return filtered
end

function InventoryMenu:update_filtering(play_sound)
   local filtered = InventoryMenu.build_list(self.ctxt)

   self.pages:set_data(filtered)
   --
   -- TODO: Determine when to display weight. Inventory contexts can
   -- be created out of any number of sources that might exclude a
   -- character, like a spot on the map.
   self.total_weight = Ui.display_weight(self.ctxt.chara:calc("inventory_weight"))
   self.max_weight = Ui.display_weight(self.ctxt.chara:calc("max_inventory_weight"))
   self.cargo_weight = Ui.display_weight(self.ctxt.chara:calc("cargo_weight"))

   if self.ctxt.show_money then
      if Chara.is_alive(self.ctxt.target) then
         self.money = self.ctxt.target.gold
      else
         self.money = 0
      end
   end

   if self.ctxt.show_target_equip and self.ctxt.target then
      self.target_equip:set_data(self.ctxt.target)

      local map = function(slot)
         return {
            text = I18N.get("ui.body_part." .. slot.body_part._id),
            has_equipment = slot.equipped ~= nil
         }
      end

      self.text_equip_slots = self.ctxt.target:iter_all_body_parts():map(map):to_list()
   end

   -- Run after filter actions that can return a turn result, like
   -- exiting the menu preemptively if a condition is false (for
   -- example, an altar is not on ground when praying).
   local result = self.ctxt:after_filter(filtered)
   if result then
      self.result = result
   elseif play_sound then
      self.play_sound = true
   end

   if self.ctxt.proto.show_weight_text then
      local weight_text = I18N.get("ui.inv.window.total_weight", self.total_weight, self.max_weight, self.cargo_weight)
      self.total_weight_text = ("%d items  (%s)"):format(self.pages:len(), weight_text)
   else
      self.total_weight_text = ""
   end
end

function InventoryMenu:draw()
   if not self.is_drawing then
      return
   end

   self.win:draw()

   Draw.set_color(255, 255, 255)
   self.t.base.inventory_icons:draw_region(self.ctxt.icon, self.x + 46, self.y - 14)

   self.t.base.deco_inv_a:draw(self.x + self.width - 136, self.y - 6)
   if self.layout == nil then
      self.t.base.deco_inv_b:draw(self.x + self.width - 186, self.y - 6)
   end
   self.t.base.deco_inv_c:draw(self.x + self.width - 246, self.y - 6)
   self.t.base.deco_inv_d:draw(self.x - 6, self.y - 6)

   Ui.draw_topic("ui.inv.window.name", self.x + 28, self.y + 30)

   Ui.draw_topic(self.subtext_column, self.x + 526, self.y + 30)

   Ui.draw_note(self.total_weight_text, self.x, self.y, self.width, self.height, 0)

   if self.ctxt.show_target_equip then
      self.target_equip:draw()

      -- >>>>>>>> shade2/command.hsp:3579 		x=wX+40:y=wY+wH-65-wH¥8 ...
      local x = self.x + 40
      local y = self.y + self.height - 65 - (self.height % 8)
      Draw.text(I18N.get("ui.inv.take_ally.window.equip"), x, y)
      x = x + 60

      for _, slot in ipairs(self.text_equip_slots) do
         if slot.has_equipment then
            Draw.set_color(self.t.base.equip_slot_text_color_occupied)
         else
            Draw.set_color(self.t.base.equip_slot_text_color_empty)
         end
         Draw.text(slot.text, x, y)
         x = x + Draw.text_width(slot.text) + Draw.text_width(" ")
      end
      -- <<<<<<<< shade2/command.hsp:3590 		loop ..
   end

   Draw.set_font(14) -- 14 - en * 2
   self.pages:draw()

   if self.ctxt.show_money then
      Draw.set_font(self.t.base.gold_count_font) -- 13 - en * 2
      self.t.base.gold_coin:draw(self.x + 340, self.y + 32, nil, nil, {255, 255, 255})
      Draw.text(("%d gp"):format(self.money), self.x + 368, self.y + 37, self.t.base.text_color)
   end
end

function InventoryMenu:update(dt)
   local changed_page = self.pages.changed_page
   local chosen = self.pages.chosen
   local result = self.result
   local canceled = self.canceled

   self.win:update(dt)
   self.pages:update(dt)
   self.target_equip:update(dt)
   self.result = nil
   self.canceled = nil

   if changed_page then
      self.win:set_pages(self)
   end

   if chosen then
      local can_select, reason = self:can_select()
      if type(can_select) == "string" then
         -- This is a turn result, like "turn_end".
         return can_select
      elseif not can_select then
      else
         if self.returns_item then
            return self:selected_item_object()
         end

         local result, canceled = self:on_select()

         if not canceled then
            if result == "inventory_continue" then
               self:update_filtering()
               self:show_query_text()
               Gui.update_screen()
            elseif result == "inventory_cancel" then
               return nil, "canceled"
            else
               return result
            end
         end
      end
   end

   if result and result ~= "inventory_continue" then
      if result == "inventory_cancel" then
         return nil, "canceled"
      end
      return result
   end

   if canceled then
      if self.returns_item then
         return nil, "canceled"
      end

      local result = self:on_menu_exit()
      if result ~= "inventory_continue" then
         return result, "canceled"
      end
   end
end

function InventoryMenu:release()
   self.map_object_batch:release()
end

return InventoryMenu
