local KeybindTranslator = class.class("KeybindTranslator")
local config = require("internal.config")

local MODIFIERS = {
   shift = 1,
   ctrl = 2,
   alt = 4,
   gui = 8
}

-- NOTE: assumes en_US
local SHIFTS = {
   ["?"] = "/",
   [">"] = ".",
   ["<"] = ",",
   [":"] = ";",
   ["\""] = "'",
   ["{"] = "[",
   ["}"] = "]",
   ["|"] = "\\",
   ["_"] = "-",
   ["+"] = "=",
   ["~"] = "`",
}

local CHARS = "abcdefghijklmnopqrstuvwxyz"
for ch in string.chars(CHARS) do
   SHIFTS[string.upper(ch)] = ch
end

local IGNORE_SHIFT = table.set {
   "north",
   "south",
   "west",
   "east",
   "northwest",
   "northeast",
   "southwest",
   "southeast"
}

local SHIFT = bit.bor(1, 2)
local CTRL = bit.bor(4, 8)
local ALT = bit.bor(16, 32)
local GUI = bit.bor(64, 128)

function KeybindTranslator:init()
   self.modifiers = 0
   self.translations = {}
   self.accepts = {}
   self.dirty = false
end

local function mod_key(key, actrl, ashift, aalt, agui)
   local ctrl = string.match(key, "ctrl_") or actrl
   key = string.gsub(key, "ctrl_", "")
   local shift = string.match(key, "shift_") or ashift
   key = string.gsub(key, "shift_", "")
   local alt = string.match(key, "alt_") or aalt
   key = string.gsub(key, "alt_", "")
   local gui = string.match(key, "gui_") or agui
   key = string.gsub(key, "gui_", "")

   shift = true

   local new = ""
   if ctrl then
      new = new .. "ctrl_"
   end
   if shift then
      new = new .. "shift_"
   end
   if alt then
      new = new .. "alt_"
   end
   if gui then
      new = new .. "gui_"
   end

   new = new .. key

   return new
end

function KeybindTranslator:set_dirty()
   self.dirty = true
end

-- @tparam {string} actions
function KeybindTranslator:enable(actions)
   self.accepts = table.merge(self.accepts, table.set(actions))
   self:set_dirty()
end

-- @tparam {string} actions
function KeybindTranslator:disable(actions)
   self.accepts = table.difference(self.accepts, table.set(actions))
   self:set_dirty()
end

function KeybindTranslator:reload()
   local keybinds = config["base.keybinds"]
   self.translations = {}
   for _, kb in pairs(keybinds) do
      self:load_key(kb.primary, kb.action)
      self:load_key(kb.alternate, kb.action)
   end
end

function KeybindTranslator:load_key(key, action)
   if key == nil then
      return
   end

   if SHIFTS[key] then
      key = mod_key(SHIFTS[key], nil, true, nil, nil)
   end
   self.translations[key] = action
end

function KeybindTranslator:key_to_keybind(key, modifiers, ignore_shift)
   if self.dirty then
      self:reload()
      self.dirty = false
   end

   local ident = ""

   if modifiers.ctrl then
      ident = ident .. "ctrl_"
   end
   if modifiers.alt then
      ident = ident .. "alt_"
   end
   if modifiers.shift
      and key ~= "shift"
      and not ignore_shift
   then
      ident = ident .. "shift_"
   end
   if modifiers.gui then
      ident = ident .. "gui_"
   end
   ident = ident .. key

   local event = self.translations[ident]

   if ignore_shift then
      if event and not IGNORE_SHIFT[event] then
         event = nil
      end
   elseif event == nil then
      event = self:key_to_keybind(key, modifiers, true)
   end

  return event
end

return KeybindTranslator
