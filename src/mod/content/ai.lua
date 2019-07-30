local ai_drunk = {
   params = {}
   cb = function(chara)
      if Effect.has(chara, "base.drunk") then
         if Map.is_in_fov(chara) then
            if chara.race == "base.cat" then
               if Effect.turns(chara, "base.drunk") < 5 then
                  Effect.add_turns(chara, "base.drunk", 40)
               end

               return true
            end
         end
      end

      return false
   end
}

local bard = function(chara)
   if Rand.one_in(5) then
      Magic.cast(chara, "base.perform")
   end
end

local citizen = function(chara)
   if Map.is_in_fov(chara) then
      local target = Ai.get_target(chara)
      if target and Pos.dist(chara.x, chara.y, target.x, target.y) then
         if target.race == "base.snail" then
            local i = Item.create("base.salt")
            Action.throw(chara, i, target)
            return "turn_end"
         end
      end
   end

   return false
end
