return {
   item = {
      acid = {
         damaged = function(_1, _2)
            return ("%sの%sは酸で傷ついた。")
               :format(name(_1), itemname(_2))
         end,
         immune = function(_1, _2)
            return ("%sの%sは酸では傷つかない。")
               :format(name(_1), itemname(_2))
         end
      },
      approximate_curse_state = {
         cursed = "(恐ろしい)",
         doomed = "(禍々しい)"
      },
      armor_class = {
         heavy = "(重装備)",
         light = "(軽装備)",
         medium = "(中装備)"
      },
      charges = function(_1)
         return ("(残り%s回)")
            :format(_1)
      end,
      chest_empty = "(空っぽ)",
      cargo_buying_price = function(price)
         return ("(仕入れ値 %sg)"):format(price)
      end,
      aphrodisiac = "(媚薬混入)",
      poisoned = "(毒物混入)",
      interval = function(hours)
         return ("(%s時間)"):format(hours)
      end,
      serial_no = function(serial_no)
         return (" シリアルNo.%s"):format(serial_no)
      end,
      altar_god_name = function(god_name)
         return ("%sの"):format(god_name)
      end,
      harvest_grown = function(weight)
         return ("%s育った"):format(weight)
      end,
      chip = {
         dryrock = "日干し岩",
         field = "畑"
      },
      coldproof_blanket = {
         protects_item = function(_1, _2)
            return ("%sが%sの持ち物を冷気から守った。")
               :format(_1, name(_2))
         end,
         is_broken_to_pieces = function(_1)
            return ("%sは粉々に砕けた。")
               :format(_1)
         end,
      },
      desc = {
         bit = {
            acidproof = "それは酸では傷つかない",
            alive = "それは生きている",
            blessed_by_ehekatl = "それはエヘカトルの祝福を受けている",
            eternal_force = "相手は死ぬ",
            fireproof = "それは炎では燃えない",
            handmade = "それは心温まる手作り品だ",
            precious = "それは貴重な品だ",
            showroom_only = "それはショウルームでのみ使用できる。",
            stolen = "それは盗品だ"
         },
         bonus = function(_1, _2)
            return ("それは攻撃修正に%sを加え、ダメージを%s増加させる")
               :format(_1, _2)
         end,
         deck = "集めたカード",
         dv_pv = function(_1, _2)
            return ("それはDVを%s上昇させ、PVを%s上昇させる")
               :format(_1, _2)
         end,
         have_to_identify = "このアイテムに関する知識を得るには、鑑定する必要がある。",
         it_is_made_of = function(_1)
            return ("それは%sで作られている")
               :format(_1)
         end,
         living_weapon = function(growth, experience)
            return ("[Lv:%d Exp:%d%%]")
               :format(growth, experience)
         end,
         no_information = "特に情報はない",
         speeds_up_ether_disease = "それは装備している間、エーテルの病の進行を早める",
         weapon = {
            heavy = "それは両手持ちに適している",
            it_can_be_wielded = "それは武器として扱うことができる",
            light = "それは片手でも扱いやすい",
            dice = function(dice_x, dice_y, pierce)
               return ("(%dd%d 貫通 %d%%)")
                  :format(dice_x, dice_y, pierce)
            end
         },
         window = {
            error = "暫定エラー回避処置です。お手数ですが、どの持ち物メニュー(例えば飲む、振る、食べるなど）から調査(xキー)を押したか報告お願いします。",
            title = "アイテムの知識"
         }
      },
      filter_name = {
         elona = {
            equip_ammo = "矢弾",
            drink = "ポーション",
            scroll = "巻物",
            rod = "杖",
            food = "食べ物",
            furniture = "家具",
            furniture_well = "井戸",
            junk = "ジャンク",
            ore = "鉱石",
         },
         default = "不明"
      },
      fireproof_blanket = {
         protects_item = function(_1, _2)
            return ("%sが%sの持ち物を炎から守った。")
               :format(itemname(_1, 1), name(_2))
         end,
         turns_to_dust = function(_1)
            return ("%sは灰と化した。")
               :format(itemname(_1, 1))
         end,
      },
      item_on_the_ground = {
         breaks_to_pieces = function(_1)
            return ("地面の%sは粉々に砕けた。")
               :format(_1)
         end,
         gets_broiled = function(_1)
            return ("地面の%sはこんがりと焼き上がった。")
               :format(itemname(_1))
         end,
         turns_to_dust = function(_1)
            return ("地面の%sは灰と化した。")
               :format(_1)
         end,
      },
      items_are_destroyed = "アイテム情報が多すぎる！幾つかのアイテムは破壊された。",
      kitty_bank_rank = {
         _0 = "5百金貨",
         _1 = "2千金貨",
         _2 = "1万金貨",
         _3 = "5万金貨",
         _4 = "50万金貨",
         _5 = "500万金貨",
         _6 = "1億金貨"
      },
      title_paren = {
         great = function(_1)
            return ("『%s』"):format(_1)
         end,
         god = function(_1)
            return ("《%s》"):format(_1)
         end,
      },
      someones_item = {
         breaks_to_pieces = function(_1, _2, _3)
            return ("%sの%sは粉々に砕けた。")
               :format(name(_3), _1)
         end,
         gets_broiled = function(_1, _2)
            return ("%sの%sはこんがりと焼き上がった。")
               :format(name(_2), itemname(_1))
         end,
         turns_to_dust = function(_1, _2, _3)
            return ("%sの%sは灰と化した。")
               :format(name(_3), _1)
         end,
         equipment_turns_to_dust = function(_1, _2, _3)
            return ("%sの装備している%sは灰と化した。")
               :format(name(_3), _1)
         end,
         falls_and_disappears = "何かが地面に落ちて消えた…",
         falls_from_backpack = "何かが地面に落ちた。",
      },
      stacked = function(_1, _2)
         return ("%sをまとめた(計%s個) ")
            :format(_1, _2)
      end,
      unknown_item = "未知のアイテム(バージョン非互換)",
      qualified_name = function(name, originalnameref2)
         return name
      end
   },
}
