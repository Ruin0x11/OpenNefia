local Log = require("api.Log")
local config = require("internal.config")

-- XXX: I have no idea why, but when running under LÖVE, the Lua runtime will
-- refuse to load any native modules unless they're directly under src/ or in
-- the same folder as the LÖVE binary. (It gives "specified module not found"
-- otherwise.) So for now the DLL for midplay will be put under src/.
local ok, midplay = pcall(require, "midplay_lua")

if not ok then
   local err = midplay
   Log.debug("midplay failed to load, so no MIDI support. (%s)", err)
   return {
      is_loaded = function() return false end,
      get_ports = function() return {} end,
      play = function() return false, "midplay failed to load" end,
      is_playing = function() return false end,
      stop = function() return false, "midplay failed to load" end,
   }
end

--- MIDI file playback.
---
--- See: https://github.com/Ruin0x11/midplay-lua
local midi = {}

function midi.is_loaded()
   return true
end

function midi.get_ports()
   return midplay.generic.get_ports()
end

function midi.play(filepath)
   local driver = config.base.midi_driver

   if driver == "native" then
      return midplay[driver].play_midi(filepath)
   end

   local midi_device = config.base.midi_device

   if midi_device == "<none>" then
      return nil, "No midi devices available!"
   end

   local index = midi_device:gsub("^([0-9]+):.*", "%1")
   local index_num = tonumber(index)
   if index_num == nil then
      return nil, "Invalid midi port " .. tostring(index)
   end

   local ports = midplay[driver].get_ports()
   local port = ports[index_num+1]
   if port == nil then
      return nil, "Missing midi port " .. tostring(index)
   end

   return midplay[driver].play_midi(filepath, port.index)
end

function midi.is_playing()
   return midplay.generic.is_midi_playing()
       or midplay.native.is_midi_playing()
end

function midi.stop()
   midplay.generic.stop_midi()
   midplay.native.stop_midi()
end

return midi
