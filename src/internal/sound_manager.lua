local Log = require("api.Log")

-- Borrowed from https://love2d.org/wiki/Minimalist_Sound_Manager
local sound_manager = class("sound_manager")

function sound_manager:init(data)
   self.data = data
   self.sources = {}
   self.looping_sources = {}

   love.audio.setDistanceModel("inverse")
end

function sound_manager:set_listener_pos(x, y)
   love.audio.setPosition(x, y)
end

function sound_manager:update()
   local remove = {}
   for _,s in pairs(sources) do
      if s:isStopped() then
         remove[#remove + 1] = s
      end
   end

   for i, s in ipairs(remove) do
      sources[s] = nil
   end
end

function sound_manager:play_looping(id)
   local sound = self.data[id]
   if sound == nil then
      Log.warn("Unknown sound %s", tostring(id))
      return
   end

   local src = love.audio.newSource(sound.file, "stream")
   src:setLooping(true)
   if src:getChannelCount() == 1 then
      src:setRelative(true)
      src:setAttenuationDistances(0, 0)
   end

   love.audio.play(src)

   self.looping_sources[id] = src
end

function sound_manager:stop_looping(id, unique)
   if id == nil then
      for k, _ in pairs(self.looping_sources) do
         self:stop_looping(k, unique)
      end

      return
   end

   local src = self.looping_sources[id]
   if src == nil then return end

   love.audio.stop(src)

   self.looping_sources[id] = nil
end

function sound_manager:play(id, x, y, channel)
   local sound = self.data[id]
   if sound == nil then
      Log.warn("Unknown sound %s", tostring(id))
      return
   end

   local src = love.audio.newSource(sound.file, "static")
   src:setLooping(false)

   if src:getChannelCount() == 1 then

      if x ~= nil and y ~= nil then
         src:setRelative(false)
         src:setPosition(x, y)
         src:setAttenuationDistances(100, 500)
      else
         src:setRelative(true)
         src:setAttenuationDistances(0, 0)
      end
   end

   love.audio.play(src)

   local channel = channel or src

   if self.sources[channel] then
      love.audio.stop()
   end

   self.sources[channel] = src
end

function sound_manager:stop(channel)
   local src = self.sources[channel]
   if src == nil then return end

   love.audio.stop(src)
   self.sources[channel] = nil
end

return sound_manager
