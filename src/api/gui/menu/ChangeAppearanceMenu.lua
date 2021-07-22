local Ui = require("api.Ui")
local Pcc = require("api.gui.Pcc")
local data = require("internal.data")
local Gui = require("api.Gui")
local IUiLayer = require("api.gui.IUiLayer")
local Rand = require("api.Rand")

local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local ChangeAppearanceList = require("api.gui.menu.ChangeAppearanceList")
local ChangeAppearancePreview = require("api.gui.menu.ChangeAppearancePreview")
local InputHandler = require("api.gui.InputHandler")

local ChangeAppearanceMenu = class.class("ChangeAppearanceMenu", IUiLayer)

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

-- PCC parts whose color can be changed via the appearance menu.
local COLORABLE_PARTS = table.set {
   "body",
   "eye",
   "cloth",
   "pants",
   "hair",
   "subhair"
}

local function make_default_pcc()
   local seen = table.set {}
   local defaults = {}

   local parts = data["base.pcc_part"]:iter():to_list()
   Rand.shuffle(parts)

   for _, pcc_part in ipairs(parts) do
      if seen[pcc_part.kind] == nil then
         local default = { id = pcc_part._id }
         if COLORABLE_PARTS[pcc_part.kind] then
            default.color = Rand.choice(Pcc.COLORS)
         end
         defaults[#defaults+1] = default
         seen[pcc_part.kind] = true
      end
   end

   local pcc = Pcc:new(defaults)
   pcc:refresh()
   return pcc
end

function ChangeAppearanceMenu:init(chara)
   self.width = 380
   self.height = 340

   self.chara = chara
   chara.pcc = chara.pcc or make_default_pcc()

   self.list = ChangeAppearanceList:new()
   self.list:set_appearance_from_chara(chara)

   self.preview = ChangeAppearancePreview:new(chara)

   table.merge(self.list, ChangeAppearanceListExt(self))

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("ui.appearance.basic.title", true, key_hints)

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

function ChangeAppearanceMenu:make_key_hints()
   return {
      {
         action = "ui.key_hint.action.change",
         key_name = "ui.key_hint.key.left_right"
      },
      {
         action = "ui.key_hint.action.close",
         key_name = "ui.key_hint.key.cancel",
         keys = { "cancel", "escape" }
      }
   }
end

function ChangeAppearanceMenu:build_preview()
   local pcc_parts = {}

   local list_values = self.list:get_appearance_values()

   for _, entry in pairs(list_values) do
      local value_ty = entry.value_type[1]
      if value_ty == "pcc_part" then
         local pcc_part_kind = entry.value_type[2]
         local pcc_part_id = entry.value_type[3] or pcc_part_kind
         if entry.value ~= "none" then
            pcc_parts[pcc_part_id] = { id = entry.value }
         end
      elseif value_ty == "portrait" then
         self.chara.portrait = entry.value
      elseif value_ty == "custom" then
         self.chara.use_pcc = entry.value
      end
   end

   -- make sure all PCC parts are initialized first before setting colors
   for _, entry in pairs(list_values) do
      local value_ty = entry.value_type[1]
      if value_ty == "color" then
         -- Color pickers can change the color of more than one PCC part at once
         -- (hair/subhair).
         local pcc_part_ids = entry.value_type[2]
         for _, id in ipairs(pcc_part_ids) do
            if pcc_parts[id] then
               pcc_parts[id].color = entry.value
            end
         end
      end
   end

   pcc_parts = table.values(pcc_parts)
   local pcc = Pcc:new(pcc_parts)
   pcc:refresh()
   self.chara.pcc = pcc
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
   Gui.play_sound("base.port")
   self.canceled = false
   self.list:update()
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
