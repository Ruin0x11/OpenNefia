local Ui = require("api.Ui")
local Pcc = require("api.gui.Pcc")
local data = require("internal.data")
local Skill = require("mod.elona_sys.api.Skill")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local ChangeAppearanceList = require("api.gui.menu.ChangeAppearanceList")
local ChangeAppearancePreview = require("api.gui.menu.ChangeAppearancePreview")
local InputHandler = require("api.gui.InputHandler")

local ChangeAppearanceMenu = class.class("ChangeAppearanceMenu", ICharaMakeSection)

ChangeAppearanceMenu:delegate("list", "focus")
ChangeAppearanceMenu:delegate("input", IInput)

local ChangeAppearanceListExt = function(change_appearance_menu)
   local E = {}

   function E:on_select(item)
      if item.type == "option" and item.value_type[1] == "portrait" then
         change_appearance_menu.preview.show_portrait = true
      else
         change_appearance_menu.preview.show_portrait = false
      end
   end

   return E
end

local function make_default_pcc()
   local seen = table.set {}
   local defaults = {}

   for _, pcc_part in data["base.pcc_part"]:iter() do
      if seen[pcc_part.kind] == nil then
         defaults[#defaults+1] = { id = pcc_part._id }
         seen[pcc_part.kind] = true
      end
   end

   local pcc = Pcc:new(defaults)
   pcc:refresh()
   return pcc
end

function ChangeAppearanceMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 380
   self.height = 340

   -- Apply race/class properties to make sure we have the default character
   -- image provided by race/class

   local chara = self.charamake_data.chara
   Skill.apply_race_params(chara, chara.race)
   Skill.apply_class_params(chara, chara.class)
   chara.pcc = make_default_pcc()

   self.win = UiWindow:new("ui.appearance.basic.title", true, "key_help")

   self.list = ChangeAppearanceList:new()
   self.list:set_appearance_from_chara(self.charamake_data.chara)

   self.preview = ChangeAppearancePreview:new(self.charamake_data.chara)

   table.merge(self.list, ChangeAppearanceListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.customize_appearance.caption"
   self.intro_sound = "base.port"

   self:build_preview()
end

function ChangeAppearanceMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function ChangeAppearanceMenu:build_preview()
   local use_pcc = self.charamake_data.chara.pcc ~= nil
   local pcc_parts = {}

   local list_values = self.list:get_appearance_values()

   for _, entry in pairs(list_values) do
      local value_ty = entry.value_type[1]
      if value_ty == "pcc_part" then
         local pcc_part_kind = entry.value_type[2]
         if entry.value ~= "none" then
            pcc_parts[pcc_part_kind] = { id = entry.value }
         end
      elseif value_ty == "portrait" then
         self.charamake_data.chara.portrait = entry.value
      elseif value_ty == "custom" then
         use_pcc = entry.value
      end
   end

   -- make sure all PCC parts are initialized first before setting colors
   for _, entry in pairs(list_values) do
      local value_ty = entry.value_type[1]
      if value_ty == "color" then
         -- Color pickers can change the color of more than one PCC part at once
         -- (hair/subhair).
         local pcc_part_kinds = entry.value_type[2]
         for _, kind in ipairs(pcc_part_kinds) do
            if pcc_parts[kind] then
               pcc_parts[kind].color = entry.value
            end
         end
      end
   end

   if use_pcc then
      pcc_parts = table.values(pcc_parts)
      local pcc = Pcc:new(pcc_parts)
      pcc:refresh()
      self.charamake_data.chara.pcc = pcc
   else
      self.charamake_data.chara.pcc = nil
   end
end

function ChangeAppearanceMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 12

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.preview:relayout(self.x + 234, self.y + 71)
   self.list:relayout(self.x + 60, self.y + 66)
end

function ChangeAppearanceMenu:draw()
   self.win:draw()
   Ui.draw_topic("ui.appearance.basic.category", self.x + 34, self.y + 36)
   self.t.base.deco_mirror_a:draw(self.x + self.width - 40, self.y, nil, nil, {255, 255, 255})

   self.preview:draw()
   self.list:draw()
end

function ChangeAppearanceMenu:on_query()
   self.canceled = false
   self.list:update()
end

function ChangeAppearanceMenu:get_charamake_result(charamake_data)
   return charamake_data
end

function ChangeAppearanceMenu:update(dt)
   if self.list.chosen then
      self.list.chosen = false
      return true
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update(dt)
   self.preview:update(dt)

   local list_result = self.list:update(dt)
   if list_result == "changed" then
      self:build_preview()
   end
end

return ChangeAppearanceMenu
