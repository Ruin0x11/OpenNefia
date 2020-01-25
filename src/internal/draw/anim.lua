local IChipAnimatable = require("api.gui.IChipAnimatable")

local anim = class.class("anim", IChipAnimatable)

function anim:init(anims, tile_id)
   self.anims = anims
   self.anim_id = nil
   self.frame = 1
   self.time_left = 0
   self.image = ""
   self.tile_id = tile_id or nil

   self:reset()
end

function anim:reset()
   self:set_anim("default")
end

function anim:set_anim(id)
   self.anim_id = id
   self.frame = 1
   self.time_left = self.anims[self.anim_id].frames[self.frame].time
   self.image = self.anims[self.anim_id].frames[self.frame].image
   assert(self.image, self.frame .. self.anim_id .. inspect(self.anims))
end

function anim:step_anim()
   local image = self.image
   local anim_data = self.anims[self.anim_id]
   self.frame = self.frame + 1
   if self.frame > #anim_data.frames then
      self.frame = 1
      self.anim_id = anim_data.next or "default"
      anim_data = self.anims[self.anim_id]
   end
   self.time_left = self.time_left + anim_data.frames[self.frame].time
   self.image = anim_data.frames[self.frame].image
   assert(self.image, self.frame .. self.anim_id .. inspect(self.anims))

   return self.image ~= image
end

function anim:update(dt)
   local changed_frame = false
   self.time_left = self.time_left - dt
   while self.time_left < 0 do
      changed_frame = self:step_anim()
   end
   return changed_frame
end

return anim
