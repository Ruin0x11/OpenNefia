local Draw = require("api.Draw")
local global_sound_manager = require("internal.global.global_sound_manager")
local config = require("internal.config")
local field = require("game.field")

local ISoundHolder = class.interface("ISoundHolder", {})

function ISoundHolder:init()
   self._sounds = {}
end

function ISoundHolder:instantiate()
   ISoundHolder.on_set_location(self)
end

function ISoundHolder:on_set_location()
   if self:current_map() == field.map then
      self._sounds = {}
      local sounds = self.proto.ambient_sounds
      if sounds then
         for _, sound_id in ipairs(sounds) do
            self:play_ambient_sound(sound_id)
         end
      end
   else
      self:stop_all_ambient_sounds()
   end
end

local function make_tag(obj, sound_id)
   return("ISoundHolder:%s:%s"):format(obj.uid, sound_id)
end

function ISoundHolder:on_set_pos()
   if not config.base.positional_audio then
      return
   end

   local coords = Draw.get_coords()
   local sx, sy = coords:tile_to_screen(coords:tile_to_screen(self.x, self.y))

   for tag, _ in pairs(self._sounds) do
      global_sound_manager:set_source_pos(tag, sx, sy)
   end
end

function ISoundHolder.stop_all_ambient_sounds_global()
   for tag, _ in pairs(global_sound_manager.looping_sources) do
      if tag:match("^ISoundHolder:") then
         global_sound_manager:stop_looping(tag, "sound")
      end
   end
end

function ISoundHolder:play_ambient_sound(sound_id, volume)
   local tag = make_tag(self, sound_id)
   if self._sounds[tag] then
      return
   end

   local sx, sy
   if config.base.positional_audio then
      local coords = Draw.get_coords()
      sx, sy = coords:tile_to_screen(self.x, self.y)
   end

   global_sound_manager:play_looping(tag, sound_id, "sound", sx, sy, volume)
   self._sounds[tag] = true
end

function ISoundHolder:stop_ambient_sound(sound_id)
   local tag = make_tag(self, sound_id)
   if not self._sounds[tag] then
      return
   end

   global_sound_manager:stop_looping(tag)
   self._sounds[tag] = nil
end

function ISoundHolder:stop_all_ambient_sounds()
   for tag, _ in pairs(self._sounds) do
      global_sound_manager:stop_looping(tag)
   end
   self._sounds = {}
end

return ISoundHolder
