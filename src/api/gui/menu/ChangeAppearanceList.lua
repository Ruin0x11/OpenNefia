local Draw = require("api.Draw")
local Gui = require("api.Gui")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local ListModel = require("api.gui.ListModel")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local I18N = require("api.I18N")
local data = require("internal.data")
local Rand = require("api.Rand")

local ChangeAppearanceList = class.class("ChangeAppearanceList", IUiList)

ChangeAppearanceList:delegate("model", IUiList)
ChangeAppearanceList:delegate("input", IInput)

-- TODO enum iteration
local COLORS = {
   { 255, 255, 255 },
   { 175, 255, 175 },
   { 255, 155, 155 },
   { 175, 175, 255 },
   { 255, 215, 175 },
   { 255, 255, 175 },
   { 155, 154, 153 },
   { 185, 155, 215 },
   { 155, 205, 205 },
   { 255, 195, 185 },
   { 235, 215, 155 },
   { 225, 215, 185 },
   { 105, 235, 105 },
   { 205, 205, 205 },
   { 255, 225, 225 },
   { 225, 225, 255 },
   { 225, 195, 255 },
   { 215, 255, 215 },
   { 210, 250, 160 },
}

function ChangeAppearanceList:init()
   self.model = ListModel:new({})
   self.item_height = 21
   self.chosen = false

   self.input = InputHandler:new()
   self.input:bind_keys {
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
      end,
      enter = function() self:choose(self.model:selected_item()) end,
      west = function() self:decrement(self.model:selected_item()) end,
      east = function() self:increment(self.model:selected_item()) end,
   }

   self.list_data = {
      [1] = {
         { id = "detail.body_color", type = "option", value_type = { "color", { "body", "eye" } } },
         { id = "detail.cloth_color", type = "option", value_type = { "color", { "cloth" } } },
         { id = "detail.pants_color", type = "option", value_type = { "color", { "pants" } } },
         { id = "detail.etc_1", type = "option", value_type = { "pcc_part", "etc" } },
         { id = "detail.etc_2", type = "option", value_type = { "pcc_part", "etc" } },
         { id = "detail.etc_3", type = "option", value_type = { "pcc_part", "etc" } },
         { id = "detail.eyes", type = "option", value_type = { "pcc_part", "eye" } },
         { id = "detail.set_basic", type = "action", action = function() self:set_page(2); self:select(#self.items) end },
      },
      [2] = {
         { id = "basic.done", type = "confirm" },
         { id = "basic.portrait", type = "option", value_type = { "portrait" } },
         { id = "basic.hair", type = "option", value_type = { "pcc_part", "hair" } },
         { id = "basic.sub_hair", type = "option", value_type = { "pcc_part", "subhair" } },
         { id = "basic.hair_color", type = "option", value_type = { "color", { "hair", "subhair" } } },
         { id = "basic.body", type = "option", value_type = { "pcc_part", "body" } },
         { id = "basic.cloth", type = "option", value_type = { "pcc_part", "cloth" } },
         { id = "basic.pants", type = "option", value_type = { "pcc_part", "pants" } },
         { id = "basic.set_detail", type = "action", action = function() self:set_page(1); self:select(#self.items) end },
         { id = "basic.custom", type = "option", value_type = { "custom" } }
      }
   }

   local cmp = function(a, b) return a._id < b._id end
   local portraits = data["base.portrait"]:iter():into_sorted(cmp):extract("_id"):to_list()

   local pcc_parts = {}
   for _, pcc_part in data["base.pcc_part"]:iter() do
      if pcc_parts[pcc_part.kind] == nil then
         pcc_parts[pcc_part.kind] = {}
      end
      table.insert(pcc_parts[pcc_part.kind], pcc_part._id)
   end
   for _, parts in pairs(pcc_parts) do
      table.sort(parts)
      table.insert(parts, 1, "none")
   end

   for _, page in pairs(self.list_data) do
      for _, entry in ipairs(page) do
         entry.text = I18N.get("ui.appearance." .. entry.id)
         entry.index = 1

         if entry.type == "option" then
            local value_ty = entry.value_type[1]
            if value_ty == "pcc_part" then
               entry.values = assert(pcc_parts[entry.value_type[2]], entry.value_type[2])
               entry.index = 2 -- 1 is "disable"
            elseif value_ty == "color" then
               entry.values = COLORS
            elseif value_ty == "portrait" then
               entry.values = portraits
            elseif value_ty == "custom" then
               entry.values = { false, true }
            else
               error("unknown appearance list item " .. tostring(value_ty))
            end
            assert(entry.values)
            entry.value = entry.values[entry.index]
         end
      end
   end

   self:set_page(2)
end

function ChangeAppearanceList:set_appearance_from_chara(chara)
   local lookup = {}
   for i, page in ipairs(self.list_data) do
      for _, entry in ipairs(page) do
         lookup[entry.id] = entry
      end
   end

   local lookup_type = {}
   for i, page in ipairs(self.list_data) do
      for _, entry in ipairs(page) do
         if entry.type == "option" then
            local value_ty = entry.value_type[1]
            local idx = entry.value_type[2]
            if idx then
               lookup_type[value_ty] = lookup_type[value_ty] or {}
               if type(idx) == "table" then
                  -- A single color picker can change more than one PCC part
                  -- color, so add all the PCC part types to the lookup.
                  for _, pcc_part_type in ipairs(idx) do
                     lookup_type[value_ty][pcc_part_type] = entry
                  end
               else
                  lookup_type[value_ty][idx] = entry
               end
            end
         end
      end
   end

   local find_idx = function(tbl, item)
      for i, v in ipairs(tbl) do
         if table.deepcompare(item, v) then
            return i
         end
      end
      return nil
   end


   if chara.use_pcc then
      lookup["basic.custom"].index = 2 -- true
   else
      lookup["basic.custom"].index = 1 -- false
   end

   if chara.pcc then
      -- Disable all PCC parts and copy the ones from the character instead.
      for _, entry in pairs(lookup_type["pcc_part"]) do
         entry.index = 1 -- "none"
      end

      for _, _, part in chara.pcc.parts:iterate() do
         local color_entry = lookup_type["color"][part.kind]
         if color_entry then
            color_entry.index = find_idx(color_entry.values, part.color) or color_entry.index
         end

         local pcc_part_entry = lookup_type["pcc_part"][part.kind]
         if pcc_part_entry then
            pcc_part_entry.index = find_idx(pcc_part_entry.values, part._id) or pcc_part_entry.index
         end
      end
   end

   if chara.portrait then
      local portrait_entry = lookup["basic.portrait"]
      portrait_entry.index = find_idx(portrait_entry.values, chara.portrait) or portrait_entry.index
   end

   for _, page in pairs(self.list_data) do
      for _, entry in ipairs(page) do
         if entry.type == "option" then
            entry.value = entry.values[entry.index]
         end
      end
   end
end

function ChangeAppearanceList:set_page(i)
   local list_data
   if i == 1 then
      list_data = self.list_data[1]
   else
      list_data = self.list_data[2]

      -- TODO riding
      local has_mount = false
      if has_mount then
         table.insert(list_data, { text = "mount", type = "option" })
      end
   end

   self.model:set_data(list_data)
end

function ChangeAppearanceList:increment(item)
   if item.type == "action" then
      item.action()
   elseif item.type == "option" then
      item.index = item.index + 1
      if item.index > #item.values then
         item.index = 1
      end
      item.value = item.values[item.index]
   end
   Gui.play_sound("base.cursor1")
   self.changed = true
end

function ChangeAppearanceList:decrement(item)
   if item.type == "action" then
      item.action()
   elseif item.type == "option" then
      item.index = item.index - 1
      if item.index < 1 then
         item.index = #item.values
      end
      item.value = item.values[item.index]
   end
   Gui.play_sound("base.cursor1")
   self.changed = true
end

function ChangeAppearanceList:choose(item)
   if item.type == "confirm" then
      self.chosen = true
   else
      self:increment(self.model:selected_item())
   end
end

function ChangeAppearanceList:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function ChangeAppearanceList:get_item_color(item)
   return {0, 0, 0}
end

function ChangeAppearanceList:get_appearance_values()
   local result = {}
   for _, page in ipairs(self.list_data) do
      for _, entry in ipairs(page) do
         if entry.type == "option" then
            result[entry.id] = { value = entry.value, value_type = entry.value_type }
         end
      end
   end
   return result
end

function ChangeAppearanceList:draw_item(item, i, x, y)
   local text
   if item.type == "confirm" or item.type == "action" then
      text = item.text
   else
      -- if type(item.value) == "string" then
      --    text = item.text .. " " .. item.value
      -- else
      text = item.text .. " " .. tostring(item.index - 1)
      -- end
   end

   UiList.draw_item_text(self, text, item, i, x, y - 1)

   if item.type ~= "confirm" then
      self.t.base.arrow_left:draw(x - 30, y - 5, nil, nil, {255, 255, 255})
      self.t.base.arrow_right:draw(x + 115, y - 5, nil, nil, {255, 255, 255})
   end
end

function ChangeAppearanceList:draw()
   Draw.set_font(14) -- 14 - en * 2
   for i, item in ipairs(self.items) do
      if self:can_select(self:selected_item(), self.selected) then
         local x = self.x
         local y = (i - 1) * self.item_height + self.y
         self:draw_item(item, i, x, y)
      end
   end
end

function ChangeAppearanceList:update()
   local result

   if self.changed then
      self.changed = false
      result = "changed"
   end
   if self.chosen then
      self.chosen = false
      result = "chosen"
   end

   return result
end

return ChangeAppearanceList
