local Log = require("api.Log")

-- Borrowed from https://love2d.org/wiki/Minimalist_Sound_Manager
local sound_manager = class.class("sound_manager")

function sound_manager:init(data)
   self.data = data
   self.sources = {}
   self.looping_sources = {}
   self.music_id = nil

   love.audio.setDistanceModel("inverse")
end

function sound_manager:set_listener_pos(x, y)
   love.audio.setPosition(x, y)
end

function sound_manager:update()
   local remove = {}
   for _, s in pairs(self.sources) do
      if not s:isPlaying() then
         remove[#remove + 1] = s
      end
   end

   for _, s in ipairs(remove) do
      self.sources[s] = nil
   end
end

function sound_manager:play_looping(id, ty)
   if true then
      return
   end
   local sound = self.data[ty][id]
   if sound == nil then
      Log.warn("Unknown sound %s:%s", ty, id)
      return
   end

   local src = love.audio.newSource(sound.file, "stream")
   src:setLooping(true)
   if src:getChannelCount() == 1 then
      src:setRelative(true)
      src:setAttenuationDistances(0, 0)
   end

   src:play()

   self.looping_sources[ty .. ":" .. id] = src
end

function sound_manager:stop_looping(id, ty)
   if true then
      return
   end
   if id == nil then
      for k, _ in pairs(self.looping_sources) do
         if k ~= "music:" .. self.music_id then
            self:stop_looping(k, ty)
         end
      end

      return
   end

   local src = self.looping_sources[ty .. ":" .. id]
   if src == nil then return end

   love.audio.stop(src)

   self.looping_sources[ty .. ":" .. id] = nil
end

function sound_manager:play(id, x, y, channel)
   if true then
      return
   end
   local sound = self.data.sound[id]
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
   if true then
      return
   end
   local src = self.sources[channel]
   if src == nil then return end

   love.audio.stop(src)
   self.sources[channel] = nil
end

function sound_manager:play_music(sound_id)
   assert(type(sound_id) == "string")

   if self.music_id == sound_id then
      return
   end

   if self.music_id ~= nil then
      self:stop_music()
   end

   self:play_looping(sound_id, "music")
   self.music_id = sound_id
end

function sound_manager:stop_music()
   if self.music_id then
      self:stop_looping(self.music_id, "music")
   end
end

return sound_manager
