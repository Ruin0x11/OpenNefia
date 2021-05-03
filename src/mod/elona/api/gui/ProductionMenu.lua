local Gui = require("api.Gui")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Production = require("mod.elona.api.Production")
local UiWindow = require("api.gui.UiWindow")
local Itemname = require("mod.elona.api.Itemname")

local IUiLayer = require("api.gui.IUiLayer")
local UiList = require("api.gui.UiList")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local ProductionMenu = class.class("ProductionMenu", IUiLayer)

ProductionMenu:delegate("pages", "chosen")
ProductionMenu:delegate("input", IInput)

local UiListExt = function(production_menu)
   local E = {}

   function E:get_item_text(item)
      return item.name
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 18})
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
      production_menu.chip_batch:add(item.image, x - 21, y + 2, nil, nil, nil, true)
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      Draw.set_font(14)
      UiList.draw_item_text(self, text, item, i, x, y, x_offset, item.color)
      Draw.text(item.detail, x + 242, y)
   end
   function E:draw()
      UiList.draw(self)
      production_menu.chip_batch:draw()
      production_menu.chip_batch:clear()
   end

   return E
end

function ProductionMenu.generate_list(chara, skill)
   local filter = function(recipe)
      if config.elona.debug_production_versatile_tool then
         return true
      end

      return recipe.skill_used == skill
         and chara:skill_level(skill) + 3 >= recipe.required_skill_level
   end

   local map = function(recipe)
      local item = data["base.item"]:ensure(recipe.item_id)
      local can_create = Production.can_create(chara, recipe._id)
      local color
      if can_create then
         color = {10, 10, 10}
      else
         color = {160, 10, 10}
      end
      return {
         item = item,
         recipe = recipe,
         can_create = can_create,
         name = Itemname.qualify_name(recipe.item_id),
         image = item.image,
         detail = I18N.get("production.menu.make", Itemname.qualify_name(recipe.item_id)),
         color = color
      }
   end

   local function sort(a, b)
      return (a.item.elona_id or 0) < (b.item.elona_id or 0)
   end

   return data["elona.production_recipe"]:iter():filter(filter):map(map):into_sorted(sort):to_list()
end

function ProductionMenu:init(chara, skill_id)
   assert(chara)
   data["base.skill"]:ensure(skill_id)

   self.chara = chara
   self.skill_id = skill_id

   self.data = ProductionMenu.generate_list(self.chara, self.skill_id)

   self.pages = UiList:new_paged(self.data, 10)
   table.merge(self.pages, UiListExt(self))

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("production.menu.title", false, key_hints)

   self.chip_batch = nil
   self.recipe_info = nil
   self.recipe_info_color = nil
   self.recipe_material_info = {}

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())

   self:update_recipe_info()
end

function ProductionMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function ProductionMenu:make_key_hints()
   local hints = self.pages:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.back",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ProductionMenu:on_query()
end

function ProductionMenu:relayout(x, y)
   self.width = 640
   self.height = 448
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)
   self.chip_batch = Draw.make_chip_batch("chip")

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.win:set_pages(self.pages)
end

function ProductionMenu:update_recipe_info()
   local item = self.pages:selected_item()

   if item then
      local recipe = item.recipe
      local required = recipe.required_skill_level
      local have = self.chara:skill_level(self.skill_id)

      self.recipe_info = ("%s: %s %d(%d)")
         :format(I18N.get("production.menu.skill_needed"),
                 I18N.localize("base.skill", self.skill_id, "name"),
                 required,
                 have)

      -- TODO theme
      if required <= have then
         self.recipe_info_color = { 30, 30, 200 }
      else
         self.recipe_info_color = { 200, 30, 30 }
      end

      self.recipe_material_info = {}
      for _, material in ipairs(recipe.materials) do
         local required = material.amount
         local have = self.chara.materials[material._id] or 0
         local text = ("%s %s %d(%d)")
            :format(I18N.get("material." .. material._id .. ".name"), I18N.get("production.menu.x"), required, have)
         local color
         if have >= required then
            color = { 30, 30, 200 }
         else
            color = { 200, 30, 30 }
         end
         table.insert(self.recipe_material_info, {text = text, color = color})
      end
   end
end

function ProductionMenu:draw_recipe_info()
   if not self.recipe_info then
      return
   end

   Draw.set_font(13)
   Draw.set_color(self.recipe_info_color)
   Draw.text(self.recipe_info, self.x + 37, self.y + 288)

   for i, info in ipairs(self.recipe_material_info) do
      Draw.set_color(info.color)
      Draw.text(info.text, self.x + 37 + (i-1) % 3 * 192, self.y + 334 + math.floor((i-1) / 3) * 16)
   end
end

function ProductionMenu:draw()
   self.win:draw()

   Ui.draw_topic("production.menu.product", self.x + 28, self.y + 36)
   Ui.draw_topic("production.menu.detail", self.x + 296, self.y + 36)
   Ui.draw_topic("production.menu.requirement", self.x + 28, self.y + 258)
   Ui.draw_topic("production.menu.material", self.x + 28, self.y + 304)

   self.pages:draw()

   self:draw_recipe_info()
end

function ProductionMenu:update(dt)
   local canceled = self.canceled
   local changed = self.pages.changed
   local chosen = self.pages.chosen

   self.canceled = false
   self.win:update(dt)
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if changed then
      self.win:set_pages(self.pages)
      self:update_recipe_info()
   elseif chosen then
      local item = self.pages:selected_item()
      if not config.elona.debug_production_versatile_tool and not item.can_create then
         Gui.play_sound("base.fail1")
         Gui.mes("production.you_do_not_meet_requirements")
      elseif self.chara:is_inventory_full() then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.common.inventory_is_full")
      else
         Production.produce_item(self.chara, item.recipe._id)
      end
      self:update_recipe_info()
      self.data = ProductionMenu.generate_list(self.chara, self.skill_id)
      self.pages:set_data(self.data)
   end
end

function ProductionMenu:release()
   self.chip_batch:release()
end

return ProductionMenu
