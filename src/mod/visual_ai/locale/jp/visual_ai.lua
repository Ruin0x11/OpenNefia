local blocks = {
   condition_target_in_sight = {
      name = "対象が見える"
   },
   condition_hp_mp_sp_threshold = {
      name = function(kind, comparator, threshold)
         return ("自分の%sは%s%s%%"):format(kind, comparator, threshold)
      end,
   },
   condition_can_do_melee_attack = {
      name = "近接攻撃ができる"
   },
   condition_can_do_ranged_attack = {
      name = "遠隔攻撃ができる"
   },
   condition_target_tile_dist = {
      name = function(comparator, threshold)
         return ("対象の距離が%s%s"):format(comparator, threshold)
      end
   },
   condition_skill_in_range = {
      name = function(skill_name)
         return ("スペル/スキル「%s」が使える"):format(skill_name)
      end
   },
   condition_random_chance = {
      name = function(chance)
         return ("%d%%の確率で「はい」"):format(chance)
      end
   },

   target_player = {
      name = "プレイヤー"
   },
   target_self = {
      name = "自分"
   },
   target_allies = {
      name = "仲間"
   },
   target_enemies = {
      name = "敵"
   },
   target_characters = {
      name = "キャラー"
   },
   target_ground_items = {
      name = "地面のアイテム"
   },
   target_inventory = {
      name = "所有してるアイテム"
   },
   target_stored = {
      name = "保存された対象"
   },
   target_player_targeting_character = {
      name = "プレイヤーの対象"
   },
   target_set_position = {
      name = function(x, y)
         return ("（%d,%d）の位置"):format(x, y)
      end
   },
   target_player_targeting_position = {
      name = "プレイヤーのターゲット位置"
   },
   target_hp_mp_sp_threshold = {
      name = function(kind, comparator, threshold)
         return ("%s%s%s%%の対象"):format(kind, comparator, threshold)
      end,
   },

   target_order_nearest = {
      name = "一番近い対象"
   },
   target_order_furthest = {
      name = "一番遠い対象"
   },
   target_order_hp_mp_sp = {
      name = function(comparator, kind)
         return ("残り%s割合が最も%s対象"):format(kind, comparator)
      end,
      comparator = {
         [">"] = "高い",
         ["<"] = "低い",
      }
   },

   action_move_close_as_possible = {
      name = "対象に一番近い場所へ移動"
   },
   action_move_within_distance = {
      name = function(threshold)
         return ("対象から%dマスの場所へ移動"):format(threshold)
      end
   },
   action_move_until_skill_in_range = {
      name = function(skill_name)
         return ("対象に「%s」が使える場所へ移動"):format(skill_name)
      end
   },
   action_retreat_from_target = {
      name = "対象から一番遠い場所へ後退"
   },
   action_retreat_until_distance = {
      name = function(threshold)
         return ("対象から%dマスの場所へ後退"):format(threshold)
      end
   },
   action_melee_attack = {
      name = "近接攻撃"
   },
   action_ranged_attack = {
      name = "遠隔攻撃"
   },
   action_cast_spell = {
      name = function(skill_name)
         return ("スペル/スキル「%s」を使う"):format(skill_name)
      end
   },
   action_change_ammo = {
      name = "弾丸の切り替え"
   },
   action_pick_up = {
      name = "拾う"
   },
   action_equip = {
      name = "装備する"
   },
   action_throw_potion = {
      name = "ポーションを投げる"
   },
   action_throw_monster_ball = {
      name = "モンスターボールを投げる"
   },
   action_store_target = {
      name = "現在の対象を保存する"
   },
   action_wander = {
      name = "彷徨う"
   },
   action_do_nothing = {
      name = "何もしない"
   },

   special_clear_target = {
      name = "対象をリセットする"
   }
}

return {
   visual_ai = {
      var = {
         hp_mp_sp = {
            hp = "HP",
            mp = "MP",
            stamina = "スタミナ"
         }
      },
      block = {
         visual_ai = blocks
      },
      interact_action = "ビジュアルAIの設定"
   }
}
