local blocks = {
   condition_target_in_sight = {
      name = "Target is in sight"
   },
   condition_hp_threshold = {
      name = function(comparator, threshold)
         return ("My HP is %s %s%%"):format(comparator, threshold)
      end
   },
   condition_target_tile_dist = {
      name = function(comparator, threshold)
         return ("Target is %s %s tile%s away"):format(comparator, threshold, plural(threshold))
      end
   },

   target_player = {
      name = "Player"
   },
   target_self = {
      name = "Self"
   },
   target_allies = {
      name = "Allies"
   },
   target_enemies = {
      name = "Enemies"
   },
   target_characters = {
      name = "Characters"
   },
   target_ground_items = {
      name = "Items on ground"
   },
   target_inventory = {
      name = "Inventory"
   },
   target_previous = {
      name = "Previous target"
   },
   target_player_targeting_character = {
      name = "Target of player"
   },
   target_set_position = {
      name = function(x, y)
         return ("Position at (%d, %d)"):format(x, y)
      end
   },
   target_player_targeting_position = {
      name = "Target position of player"
   },

   target_order_nearest = {
      name = "Thing nearest to me"
   },
   target_order_furthest = {
      name = "Thing furthest from me"
   },

   action_move_close_as_possible = {
      name = "Move as close to target as possible"
   },
   action_retreat_from_target = {
      name = "Retreat from target"
   },
   action_change_ammo = {
      name = "Change ammo to"
   },
   action_pick_up = {
      name = "Pick up"
   },
   action_equip = {
      name = "Equip"
   },
   action_do_nothing = {
      name = "Do nothing"
   },

   special_clear_target = {
      name = "Clear current target"
   }
}

return {
   visual_ai = {
      block = {
         visual_ai = blocks
      }
   }
}
