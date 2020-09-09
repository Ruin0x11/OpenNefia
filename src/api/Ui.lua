--- @module Ui

local UiTheme = require("api.gui.UiTheme")
local Rand = require("api.Rand")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local data = require("internal.data")

-- Commonly used functions for UI rendering.
-- @module Ui
local Ui = {}

local tile_size = 48

--- @tparam int width
--- @tparam int height
--- @tparam[opt] boolean tiled
function Ui.params_centered(width, height, tiled)
   if tiled == nil then
      tiled = Gui.field_is_active()
   end

   local x = (Draw.get_width() - width) / 2
   local y
   if tiled then
      local tiled_height = Draw.get_height() / tile_size
      y = ((tiled_height - 2) * tile_size - height) / 2 + 8
   else
      y = (Draw.get_height() - height) / 2
   end

   return x, y, width, height
end

local topic_cache = setmetatable({}, { __mode = "kv" })
local t
-- @tparam string topic
-- @tparam int x
-- @tparam int y
function Ui.draw_topic(topic, x, y)
   t = t or UiTheme.load()
   Draw.set_font(12, "bold")
   Draw.set_color(255, 255, 255)
   t.base.tip_icons:draw_region(1, x, y + 7)
   Draw.set_color(0, 0, 0)
   local text = topic_cache[topic] or I18N.get_optional(topic) or topic
   topic_cache[topic] = text
   Draw.text(text, x + 26, y + 8) -- y + vfix + 8
   Draw.line(x + 22, y + 21, x + Draw.text_width(text) + 36, y + 21)
   Draw.set_color(255, 255, 255)
end

-- @tparam string text
-- @tparam int x
-- @tparam int y
-- @tparam int width
-- @tparam int height
-- @tparam int x_offset
function Ui.draw_note(text, x, y, width, height, x_offset)
   Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
   Draw.text(text,
             x + width - Draw.text_width(text) - 140 - x_offset,
             y + height - 65 - height % 8,
             {0, 0, 0})
end

function Ui.random_cm_bg()
   t = t or UiTheme.load()
   local bg = Rand.rnd(4) + 1
   return t.base[string.format("g%d", bg)]
end

function Ui.unpack_font_desc(font)
   if type(font) == "number" then
      return font, nil
   else
      return font.size, font.style
   end
end

function Ui.display_weight(weight)
   return string.format("%d.%d%s",
                        math.abs(math.floor(weight / 1000)),
                        math.abs(math.floor((weight % 1000) / 100)),
                        "s")
end

function Ui.display_armor_class(weight)
   if weight >= 35000 then
      return I18N.get("item.armor_class.heavy")
   elseif weight >= 15000 then
      return I18N.get("item.armor_class.medium")
   end
   return I18N.get("item.armor_class.light")
end

--- Cuts off text past a pixel width according to the current global
--- font.
function Ui.cutoff_text(text, width)
   local t = ""
   local w = 0

   for _, c in utf8.chars(text) do
      if c == nil or w >= width then
         break
      end

      t = t .. c
      w = w + Draw.text_width(c)
   end

   return t
end

local ENDINGS = table.set {"。", "、", "」", "』", "！", "？", "…"}
local TAGS = {
   emp1   = { font_style = "underline", color = {50, 50, 255} },
   emp2   = { font_style = "bold", color = {40, 130, 40} },
   title1 = { font_delta = -2, font_style = "bold", color = {100, 50, 50} },
   def    = { font_delta = 0, font_style = "none", color = "base" },
   p      = { y_delta = 24, reset_x = true },
   br     = { y_delta = 16, reset_x = true },
   b      = { font_style = "bold" },
   green  = { color = {20, 120, 20} },
   red    = { color = {120, 20, 20} },
   col    = { color = "base" }
}

function Ui.parse_elona_markup(text, width, color)
   assert(type(text) == "string")
   assert(type(width) == "number")
   color = color or {0, 0, 0}

   local last_x = 0
   local last_y = 0
   local x = 0
   local y = 0
   local i = 1
   local base_color = color
   local font_size = 14 -- 14 - en * 2
   local base_font_size = font_size
   local font_style = nil
   local current_text = ""
   local result = {}

   local function push_result(nx, ny)
      if current_text ~= "" then
         result[#result+1] = {
            text = current_text,
            x = last_x,
            y = last_y,
            font_style = font_style,
            font_size = font_size,
            color = color
         }
      end
      current_text = ""
      last_x = nx
      last_y = ny
   end

   Draw.set_font(font_size)

   local c = utf8.sub(text, i, i)

   while c ~= "" do
      local wait_to_break_line = false
      local append = true

      if ENDINGS[c] then
         wait_to_break_line = true
      elseif c == "<" then
         -- Parse a markup tag. (This isn't HTML.)
         push_result(x, y)
         append = false

         -- `i` is a UTF-8 codepoint position, and we translate to byte position.
         local byte = utf8.offset(text,i)

         -- This is a byte position.
         local close_index = string.find(text, ">", byte)
         if close_index == nil then
            return nil, ("missing '>' to close '<' at position %d"):format(i)
         end

         local tag_name = string.sub(text, byte+1, close_index-1)
         local tag = TAGS[tag_name]
         if tag ~= nil then
            if tag.color then
               if tag.color == "base" then
                  color = base_color
               else
                  color = tag.color
               end
            end
            if tag.y_delta then
               y = y + tag.y_delta
            end
            if tag.reset_x then
               x = 0
            end
            if tag.font_delta then
               font_size = base_font_size + tag.font_delta
            end
            if tag.font_style then
               if tag.font_style == "none" then
                  font_style = nil
               else
                  font_style = tag.font_style
               end
            end

            -- Set font to ensure text width calculation stays accurate
            Draw.set_font(font_size)
         end

         -- Convert from byte position to UTF-8 codepoint position
         i = utf8.codepoint_pos(text, close_index)
      elseif c == "^" then
         -- Treat the next character literally.
         i = i + 1
         c = utf8.sub(text, i, i)
      elseif c == "\r" then
         append = false
      elseif c == "\n" then
         append = false
         x = 0
         y = y + font_size + 2
         push_result(x, y)
      end

      if append then
         current_text = current_text .. c
         if not wait_to_break_line and x > width then
            x = 0
            y = y + font_size + 2
            push_result(x, y)
         end

         x = x + Draw.text_width(c)
      end

      i = i + 1
      c = utf8.sub(text, i, i)
   end

   push_result(x, y)

   return result
end

function Ui.draw_elona_markup(markup, x, y, shadow)
   for _, item in ipairs(markup) do
      Draw.set_font(item.font_size, item.font_style)
      if shadow then
         Draw.text(item.text, x + item.x - 1, y + item.y - 1, {160, 160, 140})
      end
      Draw.set_color(item.color)
      Draw.text(item.text, x + item.x, y + item.y)
   end
end

local SKILL_ICONS = {
   ["elona.stat_strength"] = 1,
   ["elona.stat_constitution"] = 2,
   ["elona.stat_dexterity"] = 3,
   ["elona.stat_perception"] = 4,
   ["elona.stat_learning"] = 5,
   ["elona.stat_will"] = 6,
   ["elona.stat_magic"] = 7,
   ["elona.stat_charisma"] = 8,

   -- This is the same icon as the item chip for scrolls, because of an
   -- off-by-one error. There isn't actually a proper icon for LUK. The behavior
   -- is preserved here.
   ["elona.stat_luck"] = 9,
}

function Ui.skill_icon(skill_id)
   local skill = data["base.skill"]:ensure(skill_id)
   local related_skill = skill.related_skill or skill._id
   return SKILL_ICONS[related_skill]
end

return Ui
