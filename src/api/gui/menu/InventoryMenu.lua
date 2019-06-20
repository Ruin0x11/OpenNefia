local Draw = require("api.Draw")
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
   Draw.filled_rect(x, y, x + 400, y + 16, {200, 0, 0})
   text = utf8.wide_sub(text, 0, 24)
   return text, subtext
end

local rl = ResistanceLayout:new()

local UiListExt = function(inventory_menu)
   local E = {}

   function E:get_item_text(item)
      return "dood"
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if i % 2 == 0 then
         Draw.filled_rect(x - 1, y, 540, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)

      -- Draw.image(x - 21, y + 9 + 2)
   end
   function E:draw_item_text(text, item, i, x, y, x_offset)
      -- on_display_item_value
      local itemname = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      local subtext = "1.2s"

      local weight = "1.2s"
      local value = "12345 gp"

      local is_on_ground = true
      if is_on_ground then
         weight = weight .. "(Ground)"
      end

      local equipped = true
      if equipped then
         local main_hand = true
         if main_hand then
            itemname = itemname .. " " .. "(main hand)"
         end
      end

      rl:draw_row(item, text, subtext, x, y)

      UiList.draw_item_text(self, itemname, item, i, x, y, x_offset)

      -- TODO: memoize and update inside update()
      local color = get_item_color(item)

      Draw.text(subtext, x + 600 - Draw.text_width(subtext), y + 2, color)
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

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   -- TODO
   -- self.pages:register("on_chosen", self.on_chosen)
   self.input:bind_keys {
      x = function()
         local item = self.pages:selected_item()
         self:show_item_description(item)
      end,
      shift = function() self.canceled = true end
   }

   self:update_filtering()
end

function InventoryMenu:show_item_description(item)
   print("Item description " .. item.uid)
end

function InventoryMenu:on_item_selected(item)
   -- HACK: bad. Shortcuts need to be able to run this callback
   -- without being coupled to building a new inventory menu just to
   -- get at the item filtering to ensure the item can be used.
   return nil
end

function InventoryMenu:relayout(x, y)
   self.width = 640
   self.height = 432
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   print(self.x,self.y,self.width,self.height)
   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 70, self.y + 60)
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
   return ctxt.chara.inv:make_list()
end

local function source_ground(ctxt)
   return Item.at(ctxt.chara.x, ctxt.chara.y)
end

function InventoryMenu:update_filtering()
   local filtered = {}

   local filter = function(item)
      return true
   end

   local all = {}

   local sources = self.ctxt.sources
   if type(sources) == "string" then
      sources = {sources}
   end

   for _, v in ipairs(self.ctxt.sources) do
      if v == "chara" then
         all = table.append(all, source_chara(self.ctxt))
      elseif v == "ground" then
         all = table.append(all, source_ground(self.ctxt))
      end
   end

   for _, item in ipairs(all) do
      if not Item.is_alive(item) then
         Item.delete(item)
      else
         if filter(item) then
            filtered[#filtered+1] = "filtered " .. item.uid
         end
      end
   end

   self.pages:set_data(filtered)
end

function InventoryMenu:draw()
   self.win:draw()

   local topic = "a topic"
   Ui.draw_topic(topic, self.x + 526, self.y + 30)

   local note = "total_weight"
   Ui.draw_note(note, self.x, self.y, self.width, self.height, 0)

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

   -- HACK
   if self.pages.chosen then
      local result = self:on_item_selected()
      if result then return result end
   end

   self.pages:update()
end

return InventoryMenu
