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

function sound_manager:play_looping(tag, id, ty, x, y, volume)
   if _IS_LOVEJS then
      -- sound is completely broken in love.js (introduces lag and
      -- doesn't even play properly...)
      return
   end

   local sound = self.data[ty][id]
   if sound == nil then
      Log.warn("Unknown sound %s:%s", ty, id)
      return
   end

   local function setup_source(src)
      src:setLooping(true)
      src:setVolume(math.clamp(volume or 1.0, 0.0, 1.0))
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
   end

   local existing = self.looping_sources[tag]
   if existing then
      if existing.file == sound.file then
         setup_source(existing.source)
         return
      else
         self:stop_looping(tag, ty)
      end
   end

   local src = love.audio.newSource(sound.file, "stream")
   setup_source(src)

   if sound.volume then
      src:setVolume(sound.volume)
   end

   src:play()

   self.looping_sources[tag] = { source = src, file = sound.file }
end

function sound_manager:stop_looping(tag, ty)
   if _IS_LOVEJS then
      return
   end

   if tag == nil then
      for other_tag, _ in pairs(self.looping_sources) do
         if other_tag ~= "global_music" then
            self:stop_looping(other_tag, ty)
         end
      end

      return
   end

   local src = self.looping_sources[tag]
   if src == nil then return end

   love.audio.stop(src.source)

   self.looping_sources[tag] = nil
end

function sound_manager:play(id, x, y, volume, channel)
   if _IS_LOVEJS then
      return
   end

   local sound = self.data.sound[id]
   if sound == nil then
      Log.warn("Unknown sound %s", tostring(id))
      return
   end

   local src = love.audio.newSource(sound.file, "static")
   src:setLooping(false)
   src:setVolume(math.clamp(volume or 1.0, 0.0, 1.0))

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

   if sound.volume then
      src:setVolume(sound.volume)
   end

   love.audio.play(src)

   local channel = channel or src

   if self.sources[channel] then
      love.audio.stop()
   end

   self.sources[channel] = src
end

function sound_manager:stop(channel)
   if _IS_LOVEJS then
      return
   end

   local src = self.sources[channel]
   if src == nil then return end

   love.audio.stop(src)
   self.sources[channel] = nil
end

function sound_manager:set_source_pos(tag, x, y)
   assert(type(tag) == "string")

   local source = self.looping_sources[tag]
   if source == nil then
      error("No source with tag " .. tostring(tag) .. " found.")
   end

   local src = source.source

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
end

function sound_manager:play_music(sound_id)
   if _IS_LOVEJS then
      return
   end

   assert(type(sound_id) == "string")

   if self.music_id == sound_id then
      return
   end

   if self.music_id ~= nil then
      self:stop_music()
   end

   self:play_looping("global_music", sound_id, "music")
   self.music_id = sound_id
end

function sound_manager:stop_music()
   if self.music_id then
      self:stop_looping("global_music", "music")
   end
end

return sound_manager
