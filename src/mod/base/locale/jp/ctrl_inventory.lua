return {
  ui = {
    inv = {
      buy = {
        how_many = function(_1, _2)
  return ("%sをいくつ買う？ (1〜%s)")
  :format(itemname(_2, 1), _1)
end,
        not_enough_money = { "あなたは財布を開いてがっかりした…", "もっと稼がないと買えない！" },
        prompt = function(_1, _2)
  return ("%sを %s gp で買う？")
  :format(_1, _2)
end,
        window = {
          price = "値段"
        }
      },
      cannot_use_cargo_items = "荷車の荷物は街か野外でしか操作できない。",
      common = {
        does_not_exist = "そのアイテムは存在しない。",
        invalid = function(_1, _2)
  return ("Invalid Item Id found. Item No:%s, Id:%s has been removed from your inventory.")
  :format(_1, _2)
end,
        inventory_is_full = "バックパックが一杯だ。",
        set_as_no_drop = "それはあなたの大事なものだ。<調べる>メニューから解除できる。",
        shortcut = {
          cargo = "荷車の荷物は登録できない。"
        }
      },
      drop = {
        cannot_anymore = "これ以上は置けない。",
        how_many = function(_1, _2)
  return ("%sをいくつ落とす？ (1〜%s) ")
  :format(itemname(_2, 1), _1)
end,
        multi = "続けてアイテムを置くことができる。"
      },
      eat = {
        too_bloated = { "今はとても食べられない。", "腹がさける…", "まだ腹は減っていない。" }
      },
      equip = {
        blessed = function(_1)
  return ("%sは何かに見守られている感じがした。")
  :format(name(_1))
end,
        cursed = function(_1)
  return ("%sは急に寒気がしてふるえた。")
  :format(name(_1))
end,
        doomed = function(_1)
  return ("%sは破滅への道を歩み始めた。")
  :format(name(_1))
end,
        too_heavy = "それは重すぎて装備できない。",
        you_equip = function(_1)
  return ("%sを装備した。")
  :format(itemname(_1))
end
      },
      examine = {
        no_drop = {
          set = function(_1)
  return ("%sを大事なものに指定した。")
  :format(itemname(_1))
end,
          unset = function(_1)
  return ("%sはもう大事なものではない。")
  :format(itemname(_1))
end
        }
      },
      give = {
        abortion = "「おろす…」",
        cursed = function(_1)
  return ("「それ、呪われてい%s」")
  :format(ru(_1))
end,
        engagement = function(_1)
  return ("%sは顔を赤らめた。")
  :format(name(_1))
end,
        inventory_is_full = function(_1)
  return ("%sはこれ以上持てない。")
  :format(name(_1))
end,
        is_sleeping = function(_1)
  return ("%sは眠っている。")
  :format(name(_1))
end,
        love_potion = {
          dialog = { function(_1)
  return ("%s「サイテー！！」")
  :format(name(_1))
end, function(_1)
  return ("%s「このヘンタイ！」")
  :format(name(_1))
end, function(_1)
  return ("%s「ガード！ガード！ガード！」")
  :format(name(_1))
end },
          text = function(_1, _2)
  return ("%sは激怒して%sを叩き割った。")
  :format(name(_1), itemname(_2, 1))
end
        },
        no_more_drink = function(_1)
  return ("「もう飲めない%s」")
  :format(yo(_1))
end,
        present = {
          dialog = function(_1)
  return ("「え、これを%sにくれるの%s%s」")
  :format(ore(_1, 3), ka(_1, 1), thanks(_1, 2))
end,
          text = function(_1, _2)
  return ("あなたは%sに%sをプレゼントした。")
  :format(name(_1), itemname(_2, 1))
end
        },
        refuse_dialog = {
          _0 = function(_1)
  return ("%s「重すぎ」")
  :format(name(_1))
end,
          _1 = function(_1)
  return ("%s「無理」")
  :format(name(_1))
end,
          _2 = function(_1)
  return ("%s「いらん」")
  :format(name(_1))
end,
          _3 = function(_1)
  return ("%s「イヤ！」")
  :format(name(_1))
end
        },
        refuses = function(_1, _2)
  return ("%sは%sを受け取らない。")
  :format(name(_1), itemname(_2, 1))
end,
        too_creepy = function(_1)
  return ("「そんな得体の知れないものはいらない%s」")
  :format(yo(_1))
end,
        you_hand = function(_1)
  return ("%sを渡した。")
  :format(itemname(_1, 1))
end
      },
      identify = {
        fully = function(_1)
  return ("それは%sだと完全に判明した。")
  :format(itemname(_1))
end,
        need_more_power = "新しい知識は得られなかった。より上位の鑑定で調べる必要がある。",
        partially = function(_1)
  return ("それは%sだと判明したが、完全には鑑定できなかった。")
  :format(itemname(_1))
end
      },
      offer = {
        no_altar = "ここには祭壇がない。"
      },
      put = {
        container = {
          cannot_hold_cargo = "荷物は入らない。",
          full = "これ以上入らない。",
          too_heavy = function(_1)
  return ("重さが%s以上の物は入らない。")
  :format(_1)
end
        },
        guild = {
          have_no_quota = "現在魔術士ギルドのノルマはない。",
          remaining = function(_1)
  return ("ノルマ残り: %sGP")
  :format(_1)
end,
          you_deliver = function(_1)
  return ("%sを納入した")
  :format(itemname(_1))
end,
          you_fulfill = "ノルマを達成した！"
        },
        harvest = function(_1, _2, _3, _4)
  return ("%sを納入した。 +%s  納入済み(%s) 納入ノルマ(%s)")
  :format(itemname(_1), _2, _3, _4)
end,
        tax = {
          do_not_have_to = "まだ納税する必要はない。",
          not_enough_money = "金が足りない…",
          you_pay = function(_1)
  return ("%sを支払った。")
  :format(itemname(_1))
end
        }
      },
      sell = {
        how_many = function(_1, _2)
  return ("%sをいくつ売る？ (1〜%s)")
  :format(itemname(_2, 1), _1)
end,
        not_enough_money = function(_1)
  return ("%sは財布を開いてがっかりした…")
  :format(name(_1))
end,
        prompt = function(_1, _2)
  return ("%sを %s gp で売る？")
  :format(_1, _2)
end
      },
      steal = {
        do_not_rob_ally = "仲間からは盗みたくない。",
        has_nothing = function(_1)
  return ("%sは盗めるものを所持していない。")
  :format(name(_1))
end,
        there_is_nothing = "そこに盗めるものはない。"
      },
      take = {
        can_claim_more = function(_1)
  return ("残り%s個分のアイテムの相続権を持っている。")
  :format(_1)
end,
        no_claim = "遺産の相続権を持っていない。",
        really_leave = "まだアイテムが残っているがいい？"
      },
      take_ally = {
        cursed = function(_1)
  return ("%sは呪われていて外せない。")
  :format(itemname(_1))
end,
        refuse_dialog = function(_1)
  return ("%s「あげないよ」")
  :format(name(_1))
end,
        swallows_ring = function(_1, _2)
  return ("%sは激怒して%sを飲み込んだ。")
  :format(name(_1), itemname(_2, 1))
end,
        window = {
          equip = "装備箇所",
          equip_weight = "装備重量"
        },
        you_take = function(_1)
  return ("%sを受け取った。")
  :format(_1)
end
      },
      throw = {
        cannot_see = "その場所は見えない。",
        location_is_blocked = "そこには投げられない。"
      },
      title = {
        general = "どのアイテムを調べる？ ",
        give = "どれを渡す？ ",
        buy = "どれを購入する？ ",
        sell = "どれを売却する？ ",
        identify = "どのアイテムを鑑定する？ ",
        use = "どのアイテムを使用する？ ",
        open = "どれを開ける？ ",
        cook = "何を料理する？ ",
        dip_source = "何を混ぜる？ ",
        dip = function(_1)
  return ("何に混ぜる？(%sの効果を適用するアイテムを選択) ")
  :format(_1)
end,
        offer = "何を神に捧げる？ ",
        drop = "どのアイテムを置く？ ",
        trade = "何を交換する？ ",
        present = function(_1)
  return ("%sの代わりに何を提示する？ ")
  :format(_1)
end,
        take = "何を取る？ ",
        target = "何を対象にする？ ",
        put = "何を入れる？ ",
        receive = "何をもらう？ ",
        throw = "何を投げる？ ",
        steal = "何を盗む？ ",
        trade2 = "何と交換する？ ",
        reserve = "何を予約する？",
        get = "どのアイテムを拾う？ ",
        equip = "何を装備する？",
        eat = "何を食べよう？ ",
        read = "どれを読む？ ",
        drink = "どれを飲む？ ",
        zap = "どれを振る？ "
      },
      trade = {
        too_low_value = function(_1)
  return ("%sに見合う物を所持していない。")
  :format(_1)
end,
        you_receive = function(_1, _2)
  return ("%sを%sと交換した。")
  :format(_2, _1)
end
      },
      trade_medals = {
        inventory_full = "これ以上持てない。",
        medal_value = function(_1)
  return ("%s 枚")
  :format(_1)
end,
        medals = function(_1)
  return ("(持っているメダル: %s枚)")
  :format(_1)
end,
        not_enough_medals = "メダルの数が足りない…",
        window = {
          medal = "メダル"
        },
        you_receive = function(_1)
  return ("%sを受け取った！")
  :format(itemname(_1, 1))
end
      },
      window = {
        change = "メニュー切替",
        ground = "足元",
        main_hand = "利腕",
        name = "アイテムの名称",
        select_item = function(_1)
  return ("%sアイテムの選択")
  :format(_1)
end,
        tag = {
          multi_drop = "連続で置く",
          no_drop = "保持指定"
        },
        total_weight = function(_1, _2, _3)
  return ("重さ合計 %s/%s  荷車 %s")
  :format(_1, _2, _3)
end,
        weight = "重さ"
      }
    }
  }
}
