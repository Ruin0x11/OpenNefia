--- @module Ui
local Const = require("api.Const")
local DateTime = require("api.DateTime")

local UiTheme = require("api.gui.UiTheme")
local Rand = require("api.Rand")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local config = require("internal.config")
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

--- `key_id` is a raw key name like `a` or `ctrl_c`, not a `base.keybind` ID.
function Ui.localize_key_name(raw_key, include_joypad)
   local function get_key_name(key, is_shift)
      -- First see if this key has an explicit name.
      local key_name = I18N.get_optional("keyboard." .. key)
      if key_name then
         return key_name
      end

      -- If this key is a keypad key (kp1, kpenter, etc.), prefix it with
      -- "Numpad".
      if key:match("^kp") then
         key = key:gsub("^kp", "")

         local keypad = I18N.get("keyboard.keypad")
         return keypad .. get_key_name(key)
      end

      -- Check for function keys.
      if key:match("^f[0-9]+$") then
         return I18N.capitalize(key)
      end

      -- Check for joystick keys.
      if key:match("^joystick_") then
         if not include_joypad then
            return nil
         end

         key = key:gsub("^joystick_", "")

         local joypad = I18N.get("keyboard.joypad")

         local axis_no, dir = key:match("^axis_[0-9]+_[+-]$")
         if axis_no and dir then
            local axis = I18N.get("keyboard.axis")

            return ("%s %s %s%s"):format(joypad, axis, axis_no, dir)
         end

         return joypad .. I18N.space() .. key
      end

      if key:match("^[a-zA-Z]$") then
         local hide_shift_prefix = key:match("^[A-Z]")
         return key, hide_shift_prefix
      end

      return key
   end

   local ctrl = raw_key:match("ctrl_")
   raw_key = raw_key:gsub("ctrl_", "")
   local shift = raw_key:match("shift_")
   raw_key = raw_key:gsub("shift_", "")
   local alt = raw_key:match("alt_")
   raw_key = raw_key:gsub("alt_", "")
   local gui = raw_key:match("gui_")
   raw_key = raw_key:gsub("gui_", "")

   local key_name, hide_shift_prefix = get_key_name(raw_key, shift ~= nil)
   if key_name == nil then
      return nil
   end

   local final = {}

   if ctrl then
      final[#final+1] = I18N.get("keyboard.ctrl")
   end
   if shift and not hide_shift_prefix then
      final[#final+1] = I18N.get("keyboard.shift")
   end
   if alt then
      final[#final+1] = I18N.get("keyboard.alt")
   end
   if gui then
      final[#final+1] = I18N.get("keyboard.gui")
   end

   final[#final+1] = key_name

   return table.concat(final, "+")
end

function Ui.format_key_hints(key_hints)
   if type(key_hints) == "nil" then
      return ""
   elseif type(key_hints) == "string" then
      return key_hints
   end

   assert(type(key_hints) == "table", "Key help must be a list or string")

   --[[
      {
      action_name = "ui.action.back",
      keys = { "cancel", "escape" }
      }
   --]]

   local function get_bound_keys(keybind_id)
      if keybind_id:match("^raw_") then
         local key_name = keybind_id:gsub("^raw_", "")
         return {key_name}
      end

      local keybinds = config.base.keybinds
      local keybind = keybinds[keybind_id]
      if not keybind then
         return {}
      end

      -- TODO keybinds should not be separated by primary/alternate
      local key_ids = {}
      if keybind.primary then
         key_ids[#key_ids+1] = keybind.primary
      end
      if keybind.alternate then
         for _, key in ipairs(keybind.alternate) do
            key_ids[#key_ids+1] = key
         end
      end

      return key_ids
   end

   local result = {}

   for _, entry in ipairs(key_hints) do
      assert(type(entry.action) == "string", "Must specify 'action' in key help")
      local action_name = I18N.get_optional(entry.action) or entry.action

      local keybind_names
      if entry.key_name then
         keybind_names = I18N.get_optional(entry.key_name)
      end

      if keybind_names == nil then
         local keys = {}
         if type(entry.keys) == "string" then
            keys[1] = entry.keys
         elseif type(entry.keys) == "table" then
            keys = entry.keys
         else
            error("Unknown `keys` field in key help entry")
         end

         local key_ids = {}
         for _, keybind_id in ipairs(keys) do
            local bound_key_ids = get_bound_keys(keybind_id)
            table.append(key_ids, bound_key_ids)
         end

         if #key_ids > 0 then
            print(inspect(key_ids))
            keybind_names = fun.iter(key_ids):map(Ui.localize_key_name):filter(fun.op.truth):to_list()
            if #keybind_names > 0 then
               keybind_names = table.concat(keybind_names, ",")
            else
               keybind_names = "???"
            end
         else
            keybind_names = "???"
         end
      end

      result[#result+1] = ("%s [%s]"):format(keybind_names, action_name)
   end

   return table.concat(result, " " .. I18N.space())
end

return Ui
