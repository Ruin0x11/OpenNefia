local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local I18N = require("api.I18N")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Item = require("api.Item")

local IInput = require("api.gui.IInput")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")

local ReserveSpellbookMenu = class.class("ReserveSpellbookMenu", {IUiLayer, IPaged})

ReserveSpellbookMenu:delegate("input", IInput)
ReserveSpellbookMenu:delegate("pages", IPaged)

local COLOR_NOT_RESERVED = {120, 120, 120}
local COLOR_RESERVED = {55, 55, 255}

local UiListExt = function(reserve_spellbook_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end
   function E:draw_select_key(entry, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 540, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, entry, i, key_name, x, y)
   end
   function E:draw_item_text(item_name, entry, i, x, y, x_offset, color)
      UiList.draw_item_text(self, item_name, entry, i, x, y, x_offset, color)

      local detail_text
      if entry.is_reserved then
         color = COLOR_RESERVED
         detail_text = I18N.get("ui.reserve.reserved")
      else
         color = COLOR_NOT_RESERVED
         detail_text = I18N.get("ui.reserve.not_reserved")
      end
      Draw.text(detail_text, x + 342, y + 2, color)
      reserve_spellbook_menu.chip_batch:add(entry.image, x - 44, y + 8, nil, nil, nil, true)
   end
   function E:draw()
      UiList.draw(self)
      reserve_spellbook_menu.chip_batch:draw()
      reserve_spellbook_menu.chip_batch:clear()
   end

   return E
end

function ReserveSpellbookMenu.make_list()
   -- >>>>>>>> shade2/command.hsp:1256 *com_reserve ...
   local filter = function(item) return ItemMemory.reserved_state(item._id) ~= nil end

   local map = function(item_proto)
      -- Create the item, so we can get its default image (like FFHP extended
      -- ones)
      local item = Item.create(item_proto._id, nil, nil, {ownerless=true})

      return {
         proto = item_proto,
         image = item.image,
         name = item:build_name(1),
         is_reserved = ItemMemory.reserved_state(item._id) == "reserved",
      }
   end

   return data["base.item"]:iter():filter(filter):map(map):to_list()
   -- <<<<<<<< shade2/command.hsp:1265 	windowShadow=true ..
end

function ReserveSpellbookMenu:init()
   local list = ReserveSpellbookMenu.make_list()
   self.pages = UiList:new_paged(list, 16)
   table.merge(self.pages, UiListExt(self))

   self.chip_batch = nil

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("ui.reserve.title", true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ReserveSpellbookMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function ReserveSpellbookMenu:make_key_hints()
   local hints = self.pages:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ReserveSpellbookMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ReserveSpellbookMenu:relayout(x, y)
   self.width = 540
   self.height = 448
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)
   self.chip_batch = Draw.make_chip_batch("chip")

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.win:set_pages(self.pages)
end

function ReserveSpellbookMenu:draw()
   self.win:draw()

   Draw.set_color(255, 255, 255)

   Ui.draw_topic("ui.reserve.name", self.x + 28, self.y + 36)
   Ui.draw_topic("ui.reserve.status", self.x + 390, self.y + 36)

   Draw.set_font(14)
   self.pages:draw()
end

function ReserveSpellbookMenu:choose(index)
   local entry = self.pages:get_current_page(index)

   if entry == nil then
      return
   end

   local ext = data["base.item"]:ext(entry.proto._id, "elona.spellbook")
   if ext and ext.can_be_reserved == false then
      Gui.play_sound("base.fail1")
      Gui.mes("ui.reserve.unavailable")
      return
   end

   Gui.play_sound("base.ok1")

   local new_state
   if ItemMemory.reserved_state(entry.proto._id) == "not_reserved" then
      new_state = "reserved"
   else
      new_state = "not_reserved"
   end

   ItemMemory.set_reserved_state(entry.proto._id, new_state)
   entry.is_reserved = new_state == "reserved"
end

function ReserveSpellbookMenu:update(dt)
   local changed_page = self.pages.changed_page
   local chosen = self.pages.chosen
   local canceled = self.canceled

   self.win:update(dt)
   self.pages:update(dt)
   self.result = nil
   self.canceled = nil

   if changed_page then
      self.win:set_pages(self)
   end

   if chosen then
      local index = self.pages:selected_index()
      self:choose(index)
   end

   if canceled then
      return nil, "canceled"
   end
end

return ReserveSpellbookMenu
