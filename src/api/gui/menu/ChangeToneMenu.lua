local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Gui = require("api.Gui")
local data = require("internal.data")
local MapObjectBatch = require("api.draw.MapObjectBatch")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local ChangeToneMenu = class.class("ChangeToneMenu", IUiLayer)

ChangeToneMenu:delegate("pages", "chosen")
ChangeToneMenu:delegate("input", IInput)

local UiListExt = function(choose_npc_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end
   function E:draw_item_text(text, entry, i, x, y, x_offset)
      UiList.draw_item_text(self, text, entry, i, x, y, x_offset)

      Draw.text(entry.mod_id, x + 288, y + 2)
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 500 - 100, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   return E
end

function ChangeToneMenu.generate_list(show_hidden)
   local list = {
      { text = I18N.get("action.interact.change_tone.default_tone"), tone_id = nil, mod_id = "" }
   }

   for _, tone in data["base.tone"]:iter() do
      if (tone.show_in_menu or show_hidden) and tone.texts[I18N.language()] then
         list[#list+1] = {
            text = I18N.localize_optional("base.tone", tone._id, "title") or tone._id,
            tone_id = tone._id,
            mod_id = tone._id:gsub("%..*", "")
         }
      end
   end

   table.sort(list, function(a, b) return a.mod_id < b.mod_id end)

   return list
end

function ChangeToneMenu:init(show_hidden)
   self.show_hidden = show_hidden

   self.data = ChangeToneMenu.generate_list(self.show_hidden)
   self.pages = UiList:new_paged(self.data, 16)

   local key_hints = self:make_key_hints()
   self.window = UiWindow:new("action.interact.change_tone.title", true, key_hints)
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ChangeToneMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ChangeToneMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      identify = function() self:toggle_hidden(not self.show_hidden) end,
   }
end

function ChangeToneMenu:make_key_hints()
   local hints = self.pages:make_key_hints()

   table.insert(
      hints, 1,
      {
         action = "action.interact.change_tone.hint.action.change_tone",
         key_name = "ui.key_hint.action.confirm",
         keys = "enter"
      }
   )

   hints[#hints+1] = {
      action = "action.interact.change_tone.hint.action.show_hidden",
      keys =  "identify"
   }

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ChangeToneMenu:toggle_hidden(show_hidden)
   Gui.play_sound("base.ok1")
   self.show_hidden = show_hidden
   self.data = ChangeToneMenu.generate_list(show_hidden)
   self.pages:set_data(self.data)
end

function ChangeToneMenu:relayout()
   self.width = 500
   self.height = 440
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.window:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66, self.width, self.height)
end

function ChangeToneMenu:draw()
   self.window:draw()

   Ui.draw_topic("action.interact.change_tone.tone_title", self.x + 28, self.y + 36)
   Ui.draw_topic("action.interact.change_tone.mod_name", self.x + 350, self.y + 36)

   self.pages:draw()
end

function ChangeToneMenu:update(dt)
   local canceled = self.canceled
   local chosen = self.pages.chosen

   self.canceled = nil
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if chosen then
      Gui.play_sound("base.ok1")
      return { tone_id = self.pages:selected_item().tone_id }
   end
end

return ChangeToneMenu
