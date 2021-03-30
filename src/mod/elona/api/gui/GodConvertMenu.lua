local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local MapObjectBatch = require("api.draw.MapObjectBatch")
local TopicWindow = require("api.gui.TopicWindow")
local UiHelpMarkup = require("api.gui.UiHelpMarkup")
local UiShadowedText = require("api.gui.UiShadowedText")
local Gui = require("api.Gui")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")

local GodConvertMenu = class.class("GodConvertMenu", IUiLayer)

GodConvertMenu:delegate("pages", "chosen")
GodConvertMenu:delegate("input", IInput)

local UiListExt = function(choose_npc_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end

   return E
end

function GodConvertMenu.generate_list(player, god_id)
   local choices = {}

   local god_name
   if god_id then
      god_name = "god." .. god_id .. ".name"
   end

   if player.god ~= nil then
      if god_id == nil then
         choices[#choices+1] = { text = I18N.get("god.desc.window.abandon"), action = "convert" }
      else
         choices[#choices+1] = { text = I18N.get("god.desc.window.convert", god_name), action = "convert" }
      end
   else
      choices[#choices+1] = { text = I18N.get("god.desc.window.believe", god_name), action = "convert" }
   end

   choices[#choices+1] = { text = I18N.get("god.desc.window.cancel"), action = "cancel" }

   return choices
end

function GodConvertMenu.build_god_details(god_id)
   god_id = god_id or "elona.eyth"

   local result = {}

   local root = "god." .. god_id .. ".desc"
   local text = I18N.get_optional(root .. ".text")
   if text == nil then
      return ""
   end

   result[#result+1] = text .. "<p>"

   local offering = I18N.get_optional(root .. ".offering")
   if offering then
      result[#result+1] = I18N.get("god.desc.offering", offering)
   end

   local bonus = I18N.get_optional(root .. ".bonus")
   if bonus then
      result[#result+1] = I18N.get("god.desc.bonus", bonus)
   end

   local ability = I18N.get_optional(root .. ".ability")
   if ability then
      result[#result+1] = I18N.get("god.desc.ability", ability)
   end

   return table.concat(result, "<p>")
end

function GodConvertMenu:init(player, god_id)
   self.player = player
   self.god_id = god_id

   self.data = GodConvertMenu.generate_list(self.player, self.god_id)
   self.pages = UiList:new_paged(self.data, 16, 20)

   local god_name
   if god_id then
      god_name = "god." .. god_id .. ".name"
   else
      god_name = "god.elona.eyth.name"
   end
   self.god_name = UiShadowedText:new(I18N.get("god.desc.window.title", god_name), 18)

   local details = GodConvertMenu.build_god_details(self.god_id)
   self.details = UiHelpMarkup:new(details, 14, true)

   self.topic_win = TopicWindow:new(4, 6)
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function GodConvertMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function GodConvertMenu:on_query()
   Gui.play_sound("base.pop4")
end

function GodConvertMenu:relayout()
   self.width = 520
   self.height = 270
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.map_object_batch = MapObjectBatch:new()

   self.topic_win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 50, self.y + self.height - (self.pages:len() * 20) - 18, self.width, self.height)

   self.god_name:relayout(self.x + 20, self.y + 20)

   self.details:relayout(self.x + 23, self.y + 60, self.width - 60, self.height - 60)
   self.details:set_color(self.t.elona.help_markup_text_color)
end

function GodConvertMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.bg_altar:draw(0, 0, Draw.get_width(), Draw.get_height())

   self.topic_win:draw()

   self.god_name:draw()
   self.details:draw()

   self.pages:draw()
end

function GodConvertMenu:update(dt)
   local canceled = self.canceled
   local chosen = self.pages.chosen

   self.canceled = nil
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if chosen then
      Gui.play_sound("base.click1")

      local action = self.pages:selected_item().action
      return { action = action }, nil
   end
end

return GodConvertMenu
