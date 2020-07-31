local state = require("mod.midi.internal.global.state")
local Log = require("api.Log")

local Midi = {}

function Midi.is_opened()
   return state.midi ~= nil
end

function Midi.open()
   if Midi.is_opened() then
      return true, nil
   end

   local ok, _midi = pcall(require, "luamidi")
   if not ok or not _midi then
      return false, "Cannot open luamidi:\n" .. (_midi or "missing library")
   end
   state.midi = _midi
   return true, nil
end

function Midi.close()
   if state.midi then
      state.midi.gc()
   end
   state.midi = nil
   state.ports = nil
end

function Midi.output_ports()
   if not Midi.is_opened() then
      return {}
   end

   if state.ports == nil then
      state.ports = state.midi.enumerateoutports()
   end

   return state.ports
end

function Midi.is_port_available(port)
   return Midi.is_opened() and Midi.output_ports()[port] ~= nil
end

function Midi.raw_note_on(port, note, vel, channel)
   if not Midi.is_port_available(port) then
      return
   end
   state.midi.noteOn(port, note, vel, channel)
end

function Midi.raw_note_off(port, note, vel, channel)
   if not Midi.is_port_available(port) then
      return
   end
   state.midi.noteOff(port, note, vel, channel)
end

-- TODO scheduling
function Midi.note_on(port, note, vel, channel)
   Midi.raw_note_on(port, note, vel, channel)
end

-- TODO scheduling
function Midi.note_off(port, note, vel, channel)
   Midi.raw_note_off(port, note, vel, channel)
end

function Midi.send_message(port, a, b, c, channel)
   if not Midi.is_port_available(port) then
      return
   end
   state.midi.sendMessage(port, a, b, c, channel)
end

function Midi.change_program(port, program, channel)
   channel = channel or 0
   Midi.send_message(port, 0xCF + channel, program)
end

return Midi
