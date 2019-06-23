local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local Item = require("api.Item")
local Inventory = require("api.Inventory")

local IInput = require("api.gui.IInput")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local Window = require("api.gui.Window")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local TopicWindow = require("api.gui.TopicWindow")
local UiWindow = require("api.gui.UiWindow")

local InventoryMenu = class("InventoryMenu", IUiLayer)

InventoryMenu:delegate("input", IInput)

local function get_item_color(item)
   -- TODO: keep list of known flags?
   if item.flags.is_no_drop then
        return {120, 80, 0}
   end

   if item.identify_state == "completely" then
      if     item.curse_state == "doomed"  then return {100, 10, 100}
      elseif item.curse_state == "cursed"  then return {150, 10, 10}
      elseif item.curse_state == "none"    then return {10, 40, 120}
      elseif item.curse_state == "blessed" then return {10, 110, 30}
      end
   end

   -- EVENT: on calc_item_color

    return {0, 0, 0}
end

local ResistanceLayout = class("ResistanceLayout")

function ResistanceLayout:draw_row(item, text, subtext, x, y)
   Draw.filled_rect(x, y, 400, 16, {200, 0, 0})
   text = utf8.wide_sub(text, 0, 22)
   return text, subtext
end

local rl = ResistanceLayout:new()

local UiListExt = function(inventory_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.item:build_name()
   end
   function E:get_item_color(entry)
      return get_item_color(entry.item)
   end
   function E:draw_select_key(entry, i, key_name, x, y)
      if i % 2 == 0 then
         Draw.filled_rect(x - 1, y, 540, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, entry, i, key_name, x, y)

      inventory_menu.item_icons[i]:draw(x - 21, y + 11, nil, nil, nil, true)

      if entry.source == "equipment" then
         inventory_menu.t.equipped_icon:draw(x - 12, y + 14)
      end
   end
   function E:draw_item_text(item_name, entry, i, x, y, x_offset, color)
      -- on_display_item_value
      local subtext = "1.2s"

      local weight = "1.2s"
      local value = "12345 gp"

      if entry.source == "ground" then
         item_name = item_name .. " (Ground)"
      end

      if entry.source == "equipment" then
         local main_hand = true
         if main_hand then
            item_name = item_name .. " " .. "(main hand)"
         end
      end

      if inventory_menu.layout then
         item_name, subtext = inventory_menu.layout:draw_row(entry.item, item_name, subtext, x, y)
      end

      UiList.draw_item_text(self, item_name, entry, i, x, y, x_offset, color)

      Draw.text(subtext, x + 516 - Draw.text_width(subtext), y + 2, color)
   end

   return E
end

-- TODO: Needs to remember position based on context
--   except 11 and 12 (shops)

function InventoryMenu:init(ctxt, can_cancel)
   assert(ctxt.chara ~= nil)
   assert_is_an(Inventory, ctxt.chara.inv)

   self.ctxt = ctxt

   self.win = UiWindow:new("ui.inv.window", true, "key help")
   self.pages = UiList:new_paged(table.of("hoge", 100), 16)
   table.merge(self.pages, UiListExt(self))

   self.total_weight = 0
   self.max_weight = 0
   self.layout = nil
   self.subtext_column = "subtext"
   self.item_icons = {}

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   -- TODO
   -- self.pages:register("on_chosen", self.on_chosen)
   self.input:bind_keys {
      x = function()
         local item = self.pages:selected_item()
         self:show_item_description(item)
      end,
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }

   self:update_filtering()
end

function InventoryMenu:on_select()
   local item = self.pages:selected_item().item
   return self.ctxt:on_select(item)
end

function InventoryMenu:relayout(x, y)
   self.width = 640
   self.height = 432
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   print(self.x,self.y,self.width,self.height)
   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 60)
   self.win:set_pages(self.pages)
end

local function draw_ally_weight(self)
   -- TODO: move to sub object
   -- local window = Window:new(true)
   -- window:relayout(self.x + 455, self.y - 32)

   -- Draw.set_font(12) -- 12 + en - en * 2
   -- Draw.text("DV: dv PV: pv", window.x + 16, window.y + 17)
   -- Draw.text("Equip sum: sum", window.x + 16, window.y + 35)
   -- Draw.text("ally equip", window.x + 40, window.y + window.height - 65 - window.height % 8)
end

local function source_chara(ctxt)
   return ctxt.chara:iter_items()
end

local function source_ground(ctxt)
   return Item.at(ctxt.ground_x, ctxt.ground_y)
end

local function source_equipment(ctxt)
   return ctxt.chara:iter_equipment()
end

function InventoryMenu:update_filtering()
   local filtered = {}

   local all = {}

   local sources = self.ctxt.sources
   if type(sources) == "string" then
      sources = {sources}
   end

   for _, source in ipairs(self.ctxt.sources) do
      local items
      if source == "chara" then
         items = source_chara(self.ctxt)
      elseif source == "ground" then
         items = source_ground(self.ctxt)
      elseif source == "equipment" then
         items = source_equipment(self.ctxt)
      else
         error("unknown source " .. source)
      end
      items = items:map(function(item)
                           return { item = item, source = source }
      end)

      all[#all+1] = items
   end

   local iter = fun.chain(table.unpack(all))

   for _, entry in iter:unwrap() do
      local item = entry.item
      if not Item.is_alive(item) then
         item:delete()
      else
         if self.ctxt:filter(item) then
            filtered[#filtered+1] = entry
         end
      end
   end

   table.sort(filtered, function(a, b) return self.ctxt:sort(a.item, b.item) end)

   self.pages:set_data(filtered)
   self:reload_item_icons()

   self.total_weight = self.ctxt.chara:calc("inventory_weight")
   self.max_weight = self.ctxt.chara:calc("max_inventory_weight")
end

function InventoryMenu:reload_item_icons()
   self.item_icons = {}
   for _, entry in self.pages:iter() do
      self.item_icons[#self.item_icons+1] = entry.item:copy_image()
   end
   self.win:set_pages(self.pages)
end

function InventoryMenu:draw()
   self.win:draw()

   Draw.set_color(255, 255, 255)
   self.t.inventory_icons:draw_region(5, self.x + 46, self.y - 14)

   self.t.deco_a:draw(self.x + self.width - 136, self.y - 6)
   if self.layout == nil then
      self.t.deco_b:draw(self.x + self.width - 186, self.y - 6)
   end
   self.t.deco_c:draw(self.x + self.width - 246, self.y - 6)
   self.t.deco_d:draw(self.x - 6, self.y - 6)

   local topic = "window items"
   Ui.draw_topic(topic, self.x + 28, self.y + 30)

   Ui.draw_topic(self.subtext_column, self.x + 526, self.y + 30)

   local weight_note = string.format("%d items  (%s/%ss)", self.pages:len(), self.total_weight, self.max_weight)
   Ui.draw_note(weight_note, self.x, self.y, self.width, self.height, 0)

   -- on_draw
   if true then
      draw_ally_weight(self)
   end

   Draw.set_font(14) -- 14 - en * 2
   self.pages:draw()

   local show_money = true
   if show_money then
      Draw.set_font(self.t.gold_count_font) -- 13 - en * 2
      self.t.gold_coin:draw(self.x + 340, self.y + 32, nil, nil, {255, 255, 255})
      Draw.text("12345 gp", self.x + 368, self.y + 37, self.t.text_color)
   end
end

function InventoryMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      local result = self:on_select()
      if result then return result end
   elseif self.pages.changed then
      self:reload_item_icons()
   end

   self.pages:update()
end

return InventoryMenu
