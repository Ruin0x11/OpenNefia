local event = {
   { _id = "on_physical_attack_hit" },
   { _id = "on_physical_attack_miss" },
   { _id = "after_physical_attack" },
   { _id = "on_ai_calm_action" },
   { _id = "on_ai_ally_action" },
   { _id = "on_eat_item_begin" },
   { _id = "on_eat_item_finish" },
   { _id = "on_sleep" },
   { _id = "on_dig_success" },
   { _id = "calc_dialog_choices" },
   { _id = "calc_bad_performance_damage" },
   { _id = "before_respawn_mobs" },
   { _id = "before_cast_return" },
   { _id = "on_displaced" },
   { _id = "calc_wand_success" },

}

data:add_multi("base.event", event)
