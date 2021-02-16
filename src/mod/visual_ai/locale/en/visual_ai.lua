local blocks = {
   condition_target_in_sight = {
      name = "Target is in sight"
   },
   condition_hp_mp_sp_threshold = {
      name = function(kind, comparator, threshold)
         return ("My %s is %s %s%%"):format(kind, comparator, threshold)
      end,
      kind = {
         hp = "HP",
         mp = "MP",
         stamina = "Stamina"
      }
   },
   condition_can_do_melee_attack = {
      name = "Can do melee attack"
   },
   condition_can_do_ranged_attack = {
      name = "Can do ranged attack"
   },
   condition_target_tile_dist = {
      name = function(comparator, threshold)
         return ("Target is %s %s tile%s away"):format(comparator, threshold, plural(threshold))
      end
   },
   condition_skill_in_range = {
      name = function(skill_name)
         return ("Skill '%s' is in range"):format(skill_name)
      end
   },
   condition_random_chance = {
      name = function(chance)
         return ("True %d%% of the time"):format(chance)
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
   target_stored = {
      name = "Previously preserved target"
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
   action_move_within_distance = {
      name = function(threshold)
         return ("Move to within %d tile%s of target"):format(threshold, plural(threshold))
      end
   },
   action_move_until_skill_in_range = {
      name = function(skill_name)
         return ("Move closer until skill '%s' is in range"):format(skill_name)
      end
   },
   action_retreat_from_target = {
      name = "Move away from target as far as possible"
   },
   action_retreat_until_distance = {
      name = function(threshold)
         return ("Move back until %d tile%s away from target"):format(threshold, plural(threshold))
      end
   },
   action_melee_attack = {
      name = "Melee attack"
   },
   action_ranged_attack = {
      name = "Ranged attack"
   },
   action_cast_spell = {
      name = function(skill_name)
         return ("Cast spell '%s'"):format(skill_name)
      end
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
   action_store_target = {
      name = "Preserve current target to next turn"
   },
   action_wander = {
      name = "Wander"
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
