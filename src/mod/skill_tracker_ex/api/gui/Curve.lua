local Curve = class.class("Curve")

local function sort_keyframes(kfs)
   table.sort(kfs, function(a, b) return a.time < b.time end)
end

function Curve:init(keyframes)
   keyframes = keyframes or {}
   self.keyframes = keyframes
   sort_keyframes(self.keyframes)
end

function Curve:insert_keyframe(kf)
   assert(type(kf.time) == "number")
   assert(type(kf.value) == "number")
   self.keyframes[#self.keyframes+1] = kf
   sort_keyframes(self.keyframes)
end

function Curve:keyframes_between(t)
   for i, kf in ipairs(self.keyframes) do
      if kf.time >= t then
         if i == 1 then
            return { time = 0.0, value = kf.value }, kf
         else
            return self.keyframes[i-1], kf
         end
      end
   end

   return self.keyframes[#self.keyframes], { time = 1.0, value = self.keyframes[#self.keyframes].value }
end

local function linear(v0, v1, t)
   return (1 - t) * v0 + t * v1
end

local function is_nan(t)
   -- According to IEEE 754, a nan value is considered not equal to any value,
   -- including itself.
   return t ~= t
end

function Curve:evaluate(t)
   if #self.keyframes == 0 then
      return 0.0
   end

   t = math.clamp(t, 0.0, 1.0)

   local kf_before, kf_after = self:keyframes_between(t)

   local t_scaled = (t - kf_before.time) / (kf_after.time - kf_before.time)
   if is_nan(t_scaled) then
      t_scaled = 0.0
   end

   return linear(kf_before.value, kf_after.value, t_scaled)
end

return Curve
