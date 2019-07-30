local Chara = require("api.Chara")
local Item = require("api.Item")
local Rand = require("api.Rand")

local function should_drop_player_item(item, player, map)
   if not Item.is_alive(item) then
      return false
   end

   if map:calc("is_temporary") then
      if item:is_equipped() or item:calc("is_precious") or Rand.one_in(3) then
         return false
      end
   elseif Rand.one_in(5) then
      return false
   end

   if item:calc("is_cargo") then
      -- TODO
      return false
   end

   local result = true

   if item:is_equipped() then
      if Rand.one_in(10) then
         result = false
      end

      if item:calc("curse_state") == "blessed" then
         if Rand.one_in(2) then
            result = false
         end
      end

      if item:is_cursed() then
         if Rand.one_in(2) then
            result = true
         end
      end

      if item:calc("curse_state") == "doomed" then
         if Rand.one_in(2) then
            result = true
         end
      end
   elseif item:calc("identify_state") == "completely" then
      if Rand.one_in(4) then
         result = false
      end
   end

   return result
end

local function should_drop_item(item, chara)
   if not Item.is_alive(item) then
      return false
   end

   if chara:calc("role") == 20 then -- TODO
      return false
   end

   local result = false
   if item:calc("quality") == "godly"
   or item:calc("quality") == "special" then
      result = true
   end
   if Rand.one_in(30) then
      result = true
   end
   if item:calc("quality") == "miracle"
   or item:calc("quality") == "godly"
   or item:calc("quality") == "special" then
      if Rand.one_in(2) then
         result = true
      end
   end
   if chara:calc("role") == 13 then
      if Rand.one_in(5) then
         result = false
      end
   end
   if item:calc("quality") == "special" then
      result = true
   end
   if item:calc("always_drop") then
      result = true
   end

   return result
end

local function calc_dropped_player_items(player, result)
   local map = player:current_map()
   if not map then return result end

   local pred = function(item)
      return should_drop_player_item(item, player, map)
   end
   local items = player:iter_items():filter(pred)
   for _, item in fun.unwrap(items) do
      local remove = false
      if not item:calc("is_precious") then
         if Rand.one_in(4) then
            remove = true
         end
         if item:calc("curse_state") == "blessed" then
            if Rand.one_in(3) then
               remove = false
            end
         end
         if item:is_cursed() then
            if Rand.one_in(3) then
               remove = true
            end
         end
         if item:calc("curse_state") == "doomed" then
            if Rand.one_in(3) then
               remove = true
            end
         end
      end

      result[#result+1] = { item = item, remove = remove, own_state = "inherited" }
   end

   return result
end

local function calc_dropped_items(chara, result)
   if chara:is_player() then
      return calc_dropped_player_items(chara, result)
   end

   if Chara.player():is_party_leader_of(chara) then
      return {}
   end

   if chara:calc("is_contracting") then
      return {}
   end

   if chara:calc("splits") or chara:calc("splits2") then
      if Rand.one_in(6) then
         return {}
      end
   end

   local pred = function(item)
      return should_drop_item(item, chara)
   end
   return chara:iter_items():filter(pred):to_list()
end

local function drop_items(chara, map, items)
   for _, entry in ipairs(items) do
      local item = entry.item
      if entry.remove then
         item:remove_ownership()
      else
         local success = map:take_object(item, chara.x, chara.y)
         if not success then
            break
         end
         if not item:stack() then
            if entry.own_state then
               item.own_state = entry.own_state
            end
         end
      end
   end
end
