local Gui = require("api.Gui")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local data = require("internal.data")

local IUiLayer = require("api.gui.IUiLayer")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local FeatsMenu = class.class("FeatsMenu", IUiLayer)

FeatsMenu:delegate("pages", "chosen")
FeatsMenu:delegate("input", IInput)

local TRAIT_ICONS = {
   feat = 5,
   mutation = 5,
   race = 5,
   disease = 5
}

local UiListExt = function(feats_menu)
   local E = {}

   function E:get_item_text(item)
      local text = ""

      if item.type == "header" then
         text = item.text
      elseif item.type == "can_acquire" then
         text = item.name or "a"
      elseif item.type == "have" then
         local category = item.trait.type

         text = ("[%s]%s")
            :format(I18N.get("trait.window.category." .. category), item.desc)
      elseif item.type == "extra" then
         text = ("[%s]%s")
            :format(I18N.get("trait.window.category.etc"), item.desc)
      end

      return text or ""
   end
   function E:can_choose(item)
      return item.type == "can_acquire"
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if item.type == "header" then
         return
      end
      if (i - 1) % 2 == 0 then
         -- TODO gfini 540, 18
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 16})
      end
      if item.type ~= "can_acquire" then
         return
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      if item.type == "header" then
         UiList.draw_item_text(self, text, item, i, x, y, x_offset)
         return
      end

      local color = item.color
      local icon = item.icon or 5

      local draw_name = item.type == "can_acquire"

      local new_x_offset, name_x_offset
      if draw_name then
         new_x_offset = 84 - 64
         name_x_offset = 30 - 64 - 20
      else
         new_x_offset = 70 - 64
         name_x_offset = 45 - 64 - 20
      end

      feats_menu.t.base.trait_icons:draw_region(icon, x + name_x_offset, y - 4, nil, nil, {255, 255, 255})

      if draw_name then
         UiList.draw_item_text(self, text, item, i, x + new_x_offset, y, x_offset, color)
         Draw.text(item.menu_desc, x + 186, y + 2, color)
      else
         UiList.draw_item_text(self, text, item, i, x + new_x_offset, y, x_offset, color)
      end
   end

   return E
end

function FeatsMenu.localize_trait(id, level, chara)
  local trait_data = data["base.trait"]:ensure(id)
  local max = false
  if trait_data.level_max == level - 1 then
     level = level - 1
     max = true
  end

  local root = "trait." .. id .. "." .. tostring(level)
  local desc
  if trait_data.locale_params then
    desc = I18N.get(root .. ".desc", trait_data.locale_params({ level = level }, chara))
  else
    desc = I18N.get_optional(root .. ".desc")
  end
  local name = I18N.get_optional(root .. ".name")
  if name and max then
     name = name .. "(MAX)"
  end
  local menu_desc = I18N.get_optional("trait." .. id .. ".menu_desc")

  return { name = name, desc = desc, menu_desc = menu_desc }
end

local function trait_color(level)
   if level == 0 then
      return {0, 0, 0}
   elseif level > 0 then
      return {0, 0, 200}
   else
      return {200, 0, 0}
   end
end

local function can_acquire_trait(trait, level, chara)
   local can_acquire = true
   if trait.can_acquire then
      can_acquire = trait.can_acquire({level = level}, chara)
   end
   return can_acquire
end


function FeatsMenu.generate_list(chara)
   local list = {}

   local sort = function(a, b) return (a.ordering or a.elona_id or 0) < (b.ordering or b.elona_id or 0) end

   if chara.feats_acquirable > 0 then
      list[#list+1] = { type = "header", text = I18N.get("trait.window.available_feats") }

      for _, trait in data["base.trait"]:iter():filter(function(t) return t.type == "feat" end):into_sorted(sort) do
         local level = chara:trait_level(trait._id)
         if can_acquire_trait(trait, level, chara) then
            local delta = 1
            local color = trait_color(level)
            local icon = TRAIT_ICONS[trait.type]
            list[#list+1] = table.merge({ type = "can_acquire", trait = trait, icon = icon, color = color }, FeatsMenu.localize_trait(trait._id, level+delta, chara))
         end
      end
   end

   list[#list+1] = { type = "header", text = I18N.get("trait.window.feats_and_traits") }

   for _, trait in data["base.trait"]:iter():into_sorted(sort) do
      local level = chara:trait_level(trait._id)
      if level ~= 0 then
         local color = trait_color(level)
         local icon = TRAIT_ICONS[trait.type]
         list[#list+1] = table.merge({ type = "have", trait = trait, icon = icon, color = color }, FeatsMenu.localize_trait(trait._id, level, chara))
      end
   end

   for _, trait_ind in data["base.trait_indicator"]:iter():into_sorted(sort) do
      if trait_ind.applies_to(chara) then
         local indicator = trait_ind.make_indicator(chara)
         list[#list+1] = {
            type = "extra",
            name = "",
            desc = indicator.desc,
            menu_desc = "",
            trait = nil,
            color = indicator.color or {0, 0, 0}
         }
      end
   end

   return list
end

function FeatsMenu:init(chara, chara_make)
   self.chara = chara
   self.chara_make = chara_make

   self.win = UiWindow:new("trait.window.title", true, "key help", 55, 40)

   self.data = FeatsMenu.generate_list(self.chara)

   self.pages = UiList:new_paged(self.data, 15)
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function FeatsMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function FeatsMenu:on_query()
   Gui.play_sound("base.feat")
end

function FeatsMenu:relayout(x, y)
   self.width = 730
   self.height = 430
   self.x, self.y = Ui.params_centered(self.width, self.height)

   if self.chara_make then
      self.y = self.y + 15
   end

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.win:set_pages(self.pages)
end

function FeatsMenu:draw()
   self.win:draw()

   Ui.draw_topic("trait.window.name", self.x + 46, self.y + 36)
   -- UNUSED trait.window.level
   Ui.draw_topic("trait.window.detail", self.x + 255, self.y + 36)
   self.t.base.inventory_icons:draw_region(11, self.x + 46, self.y - 16)
   self.t.base.deco_feat_a:draw(self.x + self.width - 56, self.y + self.height - 198)
   self.t.base.deco_feat_b:draw(self.x, self.y)
   self.t.base.deco_feat_c:draw(self.x + self.width - 108, self.y)
   self.t.base.deco_feat_d:draw(self.x, self.y + self.height - 70)

   self.pages:draw()

   local is_player = true
   local text
   if is_player then
      text = I18N.get("trait.window.you_can_acquire", self.chara.feats_acquirable)
   else
      text = I18N.get("trait.window.your_trait", "someone")
   end

   Ui.draw_note(text, self.x, self.y, self.width, self.height, 50)
end

function FeatsMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.changed then
      self.win:set_pages(self.pages)
   elseif self.pages.chosen then
      local item = self.pages:selected_item()
      if (self.chara:is_player() or self.chara_make)
         and self.chara.feats_acquirable > 0
         and item.type == "can_acquire"
      then
         if self.chara:trait_level(item.trait._id) >= item.trait.level_max then
            if not self.chara_make then
               Gui.mes("trait.window.already_maxed")
            end
         else
            self.chara.feats_acquirable = self.chara.feats_acquirable - 1
            Gui.play_sound("base.ding3")
            self.chara:increment_trait(item.trait._id, true)
            if not self.chara_make then
               -- In character making, `self.chara` has not been built yet by `IChara:built`.
               -- Because most callbacks expect the given character to be built, you cannot call `refresh` during character making.
               self.chara:refresh()
            end
            self.data = FeatsMenu.generate_list(self.chara)
            self.pages:set_data(self.data)

            local filter = function(_, i)
               return i.type == "have" and i.trait._id == item.trait._id
            end
            local index = self.pages:iter_all_pages():enumerate():filter(filter):nth(1)
            self.pages:select(index)

            if not self.chara_make then
               Gui.update_screen()
            end
         end
      end
   end

   self.win:update()
   self.pages:update()
end

return FeatsMenu
