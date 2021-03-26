return {
   autopickup = {
      act = {
         destroy = {
            prompt = function(_1) return ("%sを破壊する？"):format(_1) end,
            execute = function(_1) return ("%sを破壊した。"):format(_1) end,
         },
         pick_up = {
            prompt = function(_1) return ("%sを拾う？"):format(_1) end,
         },
      },
      matcher = {
         _ = {
            autopickup = {
               all = {
                  identifier = "すべての"
               },
               unknown = {
                  identifier = "名称不明の"
               },
               identify_stage_1 = {
                  identifier = "鑑定段階1の"
               },
               identify_stage_2 = {
                  identifier = "鑑定段階2の"
               },
               identify_stage_3 = {
                  identifier = "鑑定段階3の"
               },
               worthless = {
                  identifier = "無価値の"
               },
               rotten = {
                  identifier = "腐った"
               },
               zombie = {
                  identifier = "腐りきった"
               },
               dragon = {
                  identifier = "ドラゴンの"
               },
               empty = {
                  identifier = "空っぽの"
               },
               bad = {
                  identifier = "粗悪な"
               },
               good = {
                  identifier = "良質な"
               },
               great = {
                  identifier = "高品質な"
               },
               miracle = {
                  identifier = "奇跡の"
               },
               godly = {
                  identifier = "神器の"
               },
               special = {
                  identifier = "特別な"
               },
               precious = {
                  identifier = "貴重な"
               },
               blessed = {
                  identifier = "祝福された"
               },
               cursed = {
                  identifier = "呪われた"
               },
               doomed = {
                  identifier = "堕落した"
               },
               alive = {
                  identifier = "生きている"
               },
            }
         }
      },
      target = {
         _ = {
            autopickup = {
               item = {
                  identifier = "アイテム",
               },
               equipment = {
                  identifier = "装備品",
               },
               melee_weapon = {
                  identifier = "近接武器"
               },
               helm = {
                  identifier = "兜"
               },
               shield = {
                  identifier = "盾"
               },
               armor = {
                  identifier = "鎧"
               },
               boots = {
                  identifier = "靴"
               },
               belt = {
                  identifier = "腰当"
               },
               cloak = {
                  identifier = "マント"
               },
               gloves = {
                  identifier = "グローブ"
               },
               ranged_weapon = {
                  identifier = "遠隔武器"
               },
               ammo = {
                  identifier = "矢弾"
               },
               ring = {
                  identifier = "指輪"
               },
               necklace = {
                  identifier = "首輪"
               },
               potion = {
                  identifier = "ポーション"
               },
               scroll = {
                  identifier = "巻物"
               },
               spellbook = {
                  identifier = "魔法書"
               },
               book = {
                  identifier = "本"
               },
               rod = {
                  identifier = "魔法の杖"
               },
               food = {
                  identifier = "食べ物"
               },
               tool = {
                  identifier = "道具"
               },
               furniture = {
                  identifier = "家具"
               },
               well = {
                  identifier = "井戸"
               },
               altar = {
                  identifier = "祭壇"
               },
               remains = {
                  identifier = "残骸"
               },
               junk = {
                  identifier = "ジャンク"
               },
               gold_piece = {
                  identifier = "金貨"
               },
               platinum_coin = {
                  identifier = "プラチナ硬貨"
               },
               chest = {
                  identifier = "宝箱"
               },
               ore = {
                  identifier = "鉱石"
               },
               tree = {
                  identifier = "樹木"
               },
               travelers_food = {
                  identifier = "旅糧"
               },
               cargo = {
                  identifier = "交易品"
               },
            }
         }
      }
   }
}
