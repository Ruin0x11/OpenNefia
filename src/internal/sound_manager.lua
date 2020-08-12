local Log = require("api.Log")

-- Borrowed from https://love2d.org/wiki/Minimalist_Sound_Manager
local sound_manager = class.class("sound_manager")

function sound_manager:init(data)
   self.data = data
   self.sources = {}
   self.looping_sources = {}
   self.music_src = nil

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

function sound_manager:get_source(id_or_data, ty, source_type)
   if id_or_data:sub(1, 4) == "RIFF" then
      local file_data = love.filesystem.newFileData(id_or_data)
      return love.audio.newSource(file_data, source_type), "@wav"
   end

   local sound = self.data[ty][id_or_data]
   if sound == nil then
      return nil
   end

   local src = love.audio.newSource(sound.file, source_type)
   local loop_id = ty .. ":" .. id_or_data

   if sound.volume then
      src:setVolume(sound.volume)
   end

   return src, loop_id
end

function sound_manager:play_looping(src, loop_id, x, y)
   if _IS_LOVEJS then
      -- sound is completely broken in love.js (introduces lag and
      -- doesn't even play properly...)
      return
   end

   src:setLooping(true)
   if src:getChannelCount() == 1 then
      src:setRelative(true)
      src:setAttenuationDistances(0, 0)
   end

   src:play()

   self.looping_sources[loop_id] = src

   return loop_id
end

function sound_manager:stop_looping(loop_id)
   if _IS_LOVEJS then
      return
   end

   if loop_id == nil then
      for k, _ in pairs(self.looping_sources) do
         if k ~= "@music" then
            self:stop_looping(k)
         end
      end

      return
   end

   local src = self.looping_sources[loop_id]
   if src == nil then return end

   love.audio.stop(src)

   self.looping_sources[loop_id] = nil
end

function sound_manager:play(src, x, y, channel)
   if _IS_LOVEJS then
      return
   end

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
   if _IS_LOVEJS then
      return
   end

   local src = self.sources[channel]
   if src == nil then return end

   love.audio.stop(src)
   self.sources[channel] = nil
end

function sound_manager:play_music(src)
   if _IS_LOVEJS then
      return
   end

   if self.music_src == src then
      return
   end

   if self.music_src ~= nil then
      self:stop_music()
   end

   self:play_looping(src, "@music")
end

function sound_manager:stop_music()
   self:stop_looping("@music")
end

return sound_manager
