local event = {
      { _id = "on_apply_effect" },
      { _id = "on_heal_effect" },
      { _id = "calc_effect_power" },
      { _id = "on_player_bumped_into_chara", },
      { _id = "before_player_map_leave" },
      { _id = "on_bump_into" },
      { _id = "on_quest_check" },
}

data:add_multi("base.event", event)
