local keybind_translator = class.class("keybind_translator")

local MODIFIERS = {
   rshift = 1,
   lshift = 2,
   rctrl = 4,
   lctrl = 8,
   ralt = 16,
   lalt = 32,
   rgui = 64,
   lgui = 128
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

function keybind_translator:init()
   self.modifiers = 0
   self.translations = {}
   self.event = nil
   self.accepts = table.set { "mode", "identify" } -- TODO
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

function keybind_translator:load(keybinds)
   self.translations = {}
   for _, kb in pairs(keybinds) do
      self:load_key(kb.primary, kb.action)
      self:load_key(kb.alternate, kb.action)
   end
end

function keybind_translator:load_key(key, action)
   if key == nil then
      return
   end

   if SHIFTS[key] then
      key = mod_key(key, nil, true, nil, nil)
   end
   self.translations[key] = action
end

function keybind_translator:keypressed(key, scancode, isrepeat, ignore_shift)
   local ident = ""

   if bit.band(self.modifiers, CTRL) ~= 0 then
      ident = ident .. "ctrl_"
   end
   if bit.band(self.modifiers, ALT)  ~= 0 then
      ident = ident .. "alt_"
   end
   if bit.band(self.modifiers, SHIFT) ~= 0 and not ignore_shift then
      ident = ident .. "shift_"
   end
   if bit.band(self.modifiers, GUI) ~= 0 then
      ident = ident .. "gui_"
   end
   ident = ident .. key

   local b = MODIFIERS[key]
   if b then
      self.modifiers = bit.bor(self.modifiers, b)
   end

   self.event = self.translations[ident]

   if ignore_shift then
      if self.event and not IGNORE_SHIFT[self.event] then
         self.event = nil
      end
   elseif self.event == nil then
      self:keypressed(key, scancode, isrepeat, true)
   end

   _ppr("PRESS", key, ident, self.event, self.modifiers)
end

function keybind_translator:keyreleased(key, scancode, isrepeat)
   local b = MODIFIERS[key]
   if b then
      self.modifiers = bit.band(self.modifiers, bit.bnot(b))
   else
      self.event = nil
   end

   _ppr("RELEASE", key, self.event, self.modifiers)
end

return keybind_translator
