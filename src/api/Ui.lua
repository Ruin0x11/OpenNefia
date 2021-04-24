--- @module Ui
local Const = require("api.Const")
local DateTime = require("api.DateTime")

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


local t_
-- @tparam string topic
-- @tparam int x
-- @tparam int y
function Ui.draw_topic(topic, x, y, t)
   t_ = t_ or UiTheme.load() -- TODO pass as argument?
   t = t or t_
   Draw.set_font(12, "bold")
   Draw.set_color(255, 255, 255)
   t.base.tip_icons:draw_region(1, x, y + 7)
   Draw.set_color(0, 0, 0)
   local text = I18N.get_optional(topic) or topic
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

-- TODO return string identifier instead
function Ui.random_cm_bg(t)
   t_ = t_ or UiTheme.load() -- TODO pass as argument?
   t = t or t_
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
   if weight >= Const.ARMOR_WEIGHT_CLASS_HEAVY then
      return I18N.get("item.armor_class.heavy")
   elseif weight >= Const.ARMOR_WEIGHT_CLASS_MEDIUM then
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

function Ui.format_date(date, with_hour)
   if type(date) == "number" then
      date = DateTime:from_hours(date)
   end
   return date:format_localized(with_hour)
end

return Ui
