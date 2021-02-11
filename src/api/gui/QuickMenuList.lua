local Draw = require("api.Draw")
local Pos = require("api.Pos")
local Gui = require("api.Gui")

local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local UiTheme = require("api.gui.UiTheme")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local KeyHandler = require("api.gui.KeyHandler")
local config = require("internal.config")

local QuickMenuList = class.class("QuickMenuList", {IUiList, IPaged})

QuickMenuList:delegate("model", IUiList)
QuickMenuList:delegate("model", IPaged)
QuickMenuList:delegate("input", IInput)

function QuickMenuList:init(pages)
   self.page_contents = pages

   local items = {}

   local null = { type = "null", text = "" }
   local function mkitem(item)
      if item then
         return { type = "item", text = item.text, action = item.action }
      else
         return { type = "item", text = "" }
      end
   end

   for i, page in ipairs(pages) do
      local ind = (i-1) * 9
      local page_prev = pages[i-1]
      local page_next = pages[i+1]

      if page_prev then
         items[1+ind] = { type = "special", text = page_prev.title, special = "prev" }
      else
         items[1+ind] = null
      end

      items[5+ind] = { type = "special", text = page.title }

      if page_next then
         items[9+ind] = { type = "special", text = page_next.title, special = "next" }
      else
         items[9+ind] = null
      end

      items[2+ind] = mkitem(page.items[1])
      items[3+ind] = mkitem(page.items[2])
      items[4+ind] = mkitem(page.items[3])

      items[6+ind] = mkitem(page.items[4])
      items[7+ind] = mkitem(page.items[5])
      items[8+ind] = mkitem(page.items[6])
   end

   self.model = PagedListModel:new(items, 9)

   self.frame = 0

   local keys = KeyHandler:new(false, true)
   self.input = InputHandler:new(keys)
   self.input:bind_keys(self:make_keymap())
   self.input:ignore_modifiers { "alt" }
end

local POSITIONS = {
   { 25,  50  }, -- W (prev page)
   { 50,  15  }, -- NW
   { 50,  85  }, -- SW
   { 100, 0   }, -- N
   { 100, 50  }, -- C (page name)
   { 100, 100 }, -- S
   { 150, 15  }, -- NE
   { 150, 85  }, -- SE
   { 175, 50  }  -- E (next page)
}

local IND_WEST = 1
local IND_NORTHWEST = 2
local IND_SOUTHWEST = 3
local IND_NORTH = 4

local IND_SOUTH = 6
local IND_NORTHEAST = 7
local IND_SOUTHEAST = 8
local IND_EAST = 9

local IND_CARDINAL = table.set { IND_NORTH, IND_SOUTH, IND_WEST, IND_EAST }

function QuickMenuList:make_keymap()
   local keys = {
      north = function(pressed)
         if self.chosen and not pressed then
            self.finished = true
         elseif self.chosen == IND_WEST then
            self.chosen = IND_NORTHWEST
            self.finished = true
         elseif self.chosen == IND_EAST then
            self.chosen = IND_NORTHEAST
            self.finished = true
         else
            self.chosen = IND_NORTH
         end
      end,
      south = function(pressed)
         if self.chosen and not pressed then
            self.finished = true
         elseif self.chosen == IND_WEST then
            self.chosen = IND_SOUTHWEST
            self.finished = true
         elseif self.chosen == IND_EAST then
            self.chosen = IND_SOUTHEAST
            self.finished = true
         else
            self.chosen = IND_SOUTH
         end
      end,
      west = function(pressed)
         if self.chosen and not pressed then
            self.finished = true
         elseif self.chosen == IND_NORTH then
            self.chosen = IND_NORTHWEST
            self.finished = true
         elseif self.chosen == IND_SOUTH then
            self.chosen = IND_SOUTHWEST
            self.finished = true
         else
            self.chosen = IND_WEST
         end
      end,
      east = function(pressed)
         if self.chosen and not pressed then
            self.finished = true
         elseif self.chosen == IND_NORTH then
            self.chosen = IND_NORTHEAST
            self.finished = true
         elseif self.chosen == IND_SOUTH then
            self.chosen = IND_SOUTHEAST
            self.finished = true
         else
            self.chosen = IND_EAST
         end
      end,
      northwest = function()
         self.chosen = IND_NORTHWEST
         self.finished = true
      end,
      northeast = function()
         self.chosen = IND_NORTHEAST
         self.finished = true
      end,
      southwest = function()
         self.chosen = IND_SOUTHWEST
         self.finished = true
      end,
      southeast = function()
         self.chosen = IND_SOUTHEAST
         self.finished = true
      end,
   }

   return keys
end

function QuickMenuList:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function QuickMenuList:get_item_color(item)
   return {255, 255, 255}
end

function QuickMenuList:draw_item(item, i, x, y, key_name)
   if item.type == "null" then
      return
   end

   if self.diagonal_only and IND_CARDINAL[i] then
      return
   end

   local asset
   if item.type == "special" then
      asset = self.t.base.quick_menu_item_special
   else
      asset = self.t.base.quick_menu_item
   end

   local frame = math.floor(self.frame * config.base.anime_wait)
   local cnt = frame + i - 1
   local alpha = cnt % 10 * cnt % 10 * 12 * (((cnt % 50) < 10) and 1 or 0)

   if self.chosen == i then
      alpha = 140
   end

   Draw.set_color(255, 255, 255)
   asset:draw(x, y)

   Draw.set_color(255, 255, 255, alpha)
   Draw.set_blend_mode("add")
   asset:draw(x, y)

   Draw.set_blend_mode("alpha")

   Draw.text_shadowed(item.text, x + 25 - Draw.text_width(item.text) / 2, y + 19)
end

function QuickMenuList:draw_target_text(target)
end

function QuickMenuList:can_select(item, i)
   return item.type ~= "null"
end

function QuickMenuList:get_item_pos(i)
   local pos = POSITIONS[i]
   return self.x + pos[1], self.y + pos[2]
end

function QuickMenuList:draw()
   Draw.set_font(12) -- 12 + sizeFix

   for i, item in self.model:iter() do
      local x, y = self:get_item_pos(i)
      self:draw_item(item, i, x, y, nil)
   end
end

function QuickMenuList:update(dt)
   self.frame = self.frame + dt
   self.result = nil

   self.diagonal_only = self.input:is_modifier_held("alt")

   if self.chosen and self.finished then
      local consider = not self.diagonal_only or not IND_CARDINAL[self.chosen]

      if not consider then
         self.chosen = nil
         self.finished = false
         return
      end

      local item = self:get(self.chosen)

      self.chosen = nil
      self.finished = false

      if item.special then
         if item.special == "prev" then
            self:previous_page()
         elseif item.special == "next" then
            self:next_page()
         end
         self.chosen = nil
         self.finished = false
      else
         return item, nil
      end
   end
end

return QuickMenuList
