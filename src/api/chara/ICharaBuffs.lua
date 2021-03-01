local data = require("internal.data")
local Gui = require("api.Gui")

local ICharaBuffs = class.interface("ICharaBuffs")

function ICharaBuffs:init()
   self.buffs = {}
end

function ICharaBuffs:remove_all_buffs(force)
   if force then
      self.buffs = {}
   else
      local remove = {}
      for i = #self.buffs, 1, -1 do
         local buff = self.buffs[i]
         local buff_data = data["elona_sys.buff"]:ensure(buff._id)
         if not buff_data.no_remove_on_heal then
            remove[#remove+1] = i
         end
      end

      for _, i in ipairs(remove) do
         self:remove_buff(i)
      end
   end
end

function ICharaBuffs:iter_buffs()
   return fun.iter(self.buffs)
end

function ICharaBuffs:find_buff(buff_id)
   return self:iter_buffs():filter(function(b) return b._id == buff_id end):nth(1)
end

function ICharaBuffs:add_buff(buff_id, power, duration)
   data["elona_sys.buff"]:ensure(buff_id)

   if type(power) == "table" then
      for i = 1, #power do
         power[i] = math.floor(power[i])
      end
   else
      power = math.floor(power)
   end

   local buff = {
      _id = buff_id,
      power = power,
      duration = math.floor(duration)
   }
   table.insert(self.buffs, buff)
   self:refresh()
end

function ICharaBuffs:get_buff(buff_id)
   return self:iter_buffs():filter(function(b) return b._id == buff_id end):nth(1)
end

function ICharaBuffs:remove_buff(buff_id_or_idx)
   local buff_data = data["elona_sys.buff"][buff_id_or_idx]

   local remove = {}
   if buff_data then
      for i, buff in ipairs(self.buffs) do
         if buff._id == buff_id_or_idx then
            remove[#remove+1] = i
         end
      end
   elseif type(buff_id_or_idx) == "table" then
      for i, buff in ipairs(self.buffs) do
         if buff == buff_id_or_idx then
            remove[#remove+1] = i
            break
         end
      end
   else
      remove[1] = buff_id_or_idx
      assert(self.buffs[remove[1]], ("Missing buff %s"):format(remove[1]))
   end

   if #remove == 0 then
      return false
   end

   for _, idx in ipairs(remove) do
      local buff = table.remove(self.buffs, idx)

      if self:is_player() and self:is_in_fov() then
         Gui.mes_c("magic.buff.ends", "Purple", "buff." .. buff._id .. ".name")
      end

      local buff_data = data["elona_sys.buff"]:ensure(buff._id)
      if buff_data.on_remove then
         buff_data.on_remove(buff, self)
      end
   end

   self:refresh()

   return true
end

return ICharaBuffs
