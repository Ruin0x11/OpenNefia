local event = {
   { _id = "on_physical_attack_hit" },
   { _id = "on_physical_attack_miss" },
   { _id = "after_physical_attack" },
   { _id = "on_ai_calm_action" },
   { _id = "on_ai_ally_action" },
   { _id = "on_item_eat_begin" },
   { _id = "on_chara_sleep" },
   { _id = "on_dig_success" },
   { _id = "on_search_finish" },
   { _id = "on_feat_calc_materials" },
   { _id = "calc_dialog_choices" },
   { _id = "before_spawn_mobs" },
   { _id = "before_cast_return" },
   { _id = "on_chara_displaced" },
   { _id = "calc_wand_success" },
   { _id = "on_shop_restocked" },
   { _id = "calc_return_forbidden" },
   { _id = "before_physical_attack" },
   { _id = "on_item_created_from_wish" },
   { _id = "on_harvest_plant" },
   { _id = "on_ai_dir_check" },
   { _id = "before_default_ai_action" },
   { _id = "on_default_ai_action" },
   { _id = "on_generate_random_encounter_id" },
   { _id = "on_item_given" },
   { _id = "on_item_taken" },
   { _id = "on_add_random_enchantments" },
   { _id = "on_item_steal_attempt" },
   { _id = "on_weather_changed" },
   { _id = "on_chara_travel_in_world_map" },
   { _id = "on_feat_tile_digged_into" },
   { _id = "before_chara_drop_items" },
   { _id = "on_chara_generate_loot_drops" },
   { _id = "on_chara_initialize_equipment" },
   { _id = "on_house_board_queried" },
   { _id = "on_build_house_board_actions" },
   { _id = "before_travel_using_feat" },
   { _id = "on_chara_changed_guild" },
}

data:add_multi("base.event", event)
