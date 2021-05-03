local Gui = require("api.Gui")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local data = require("internal.data")

local IUiLayer = require("api.gui.IUiLayer")
local UiList = require("api.gui.UiList")
local UiScroll = require("api.gui.UiScroll")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local MaterialsMenu = class.class("MaterialsMenu", IUiLayer)

MaterialsMenu:delegate("pages", "chosen")
MaterialsMenu:delegate("input", IInput)

local UiListExt = function(materials_menu)
   local E = {}

   function E:get_item_text(item)
      return item.text
   end
   function E:draw_select_key(item, i, key_name, x, y)
      UiList.draw_select_key(self, item, i, key_name, x, y)

      if item.proto.image then
         materials_menu.chip_batch:add(item.proto.image, x - 21, y + 11, nil, nil, nil, true)
      end
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      UiList.draw_item_text(self, text, item, i, x, y, x_offset)

      Draw.text(item.desc, x + 212, y)
   end
   function E:draw()
      UiList.draw(self)
      materials_menu.chip_batch:draw()
      materials_menu.chip_batch:clear()
   end

   return E
end

function MaterialsMenu.generate_list(chara)
   local list = {}

   for _id, amount in pairs(chara.materials) do
      if amount > 0 then
         local name = "material." .. _id .. ".name"
         list[#list+1] = {
            _id = _id,
            amount = amount,
            proto = data["elona.material"]:ensure(_id),
            text = I18N.get("ui.material.amount", name, amount),
            desc = I18N.get("material." .. _id .. ".desc")
         }
      end
   end

   local sort = function(a, b)
      return (a.elona_id or 0) < (b.elona_id or 0)
   end

   table.sort(list, sort)

   return list
end

function MaterialsMenu:init(chara, can_choose)
   self.chara = chara

   self.data = MaterialsMenu.generate_list(self.chara)

   self.pages = UiList:new_paged(self.data, 15)
   table.merge(self.pages, UiListExt(self))
   self.can_choose = (can_choose ~= nil and can_choose) or false

   self.chip_batch = nil

   local key_hints = self:make_key_hints()
   self.scroll = UiScroll:new(true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function MaterialsMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function MaterialsMenu:make_keymap()
   local hints = self.pages:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.back",
      keys = { "cancel", "escape" }
   }

   return hints
end

function MaterialsMenu:on_query()
   Gui.play_sound("base.scroll")
end

function MaterialsMenu:relayout(x, y)
   self.width = 600
   self.height = 430
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)
   self.chip_batch = Draw.make_chip_batch("chip")

   self.scroll:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.scroll:set_pages(self.pages)
end

function MaterialsMenu:draw()
   self.scroll:draw()

   Ui.draw_topic("ui.material.name", self.x + 38, self.y + 36, self.t)
   Ui.draw_topic("ui.material.detail", self.x + 296, self.y + 36, self.t)

   self.pages:draw()
end

function MaterialsMenu:update(dt)
   local canceled = self.canceled
   local changed = self.pages.changed
   local chosen = self.pages.chosen

   self.canceled = false
   self.scroll:update(dt)
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if changed then
      self.scroll:set_pages(self.pages)
   elseif chosen and self.can_choose then
      local selected = self.pages:selected_item()
      return { _id = selected._id }
   end
end

function MaterialsMenu:release()
   self.chip_batch:release()
end

return MaterialsMenu
