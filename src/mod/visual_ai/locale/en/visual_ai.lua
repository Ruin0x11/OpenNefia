local blocks = {
   condition_hp_threshold = {
      name = function(comparator, threshold)
         return ("My HP is %s %s"):format(comparator, threshold)
      end
   },

   target_player = {
      name = "Player"
   },

   action_change_ammo = {
      name = "Change ammo to"
   },
   action_equip = {
      name = "Equip"
   },
   action_move_close_as_possible = {
      name = "Move as close to target as possible"
   }
}

return {
   visual_ai = {
      block = {
         visual_ai = blocks
      }
   }
}
