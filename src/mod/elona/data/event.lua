local event = {
   { _id = "on_physical_attack_hit" },
   { _id = "on_physical_attack_miss" },
   { _id = "after_physical_attack" },
   { _id = "on_bash" },
   { _id = "on_ai_calm_action" },
   { _id = "on_ai_ally_action" },
   { _id = "on_eat_item_begin" },
   { _id = "on_eat_item_effect" },
   { _id = "on_eat_item_finish" },
}

data:add_multi("base.event", event)
