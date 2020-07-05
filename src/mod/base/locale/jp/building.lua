return {
  building = {
    built_new = function(_1)
  return ("あなたは%sを建設した！ ")
  :format(_1)
end,
    built_new_house = "新しい家を建てた！ ",
    can_only_use_in_world_map = "それはワールドマップでしか使えない。",
    cannot_build_anymore = "もうこれ以上建物は建てられない。",
    cannot_build_it_here = "その場所には建てられない。",
    guests = {
      armory = function(_1)
  return ("武具店の%s")
  :format(basename(_1))
end,
      blackmarket = function(_1)
  return ("ブラックマーケットの%s")
  :format(basename(_1))
end,
      general_store = function(_1)
  return ("雑貨屋の%s")
  :format(basename(_1))
end,
      goods_store = function(_1)
  return ("何でも屋の%s")
  :format(basename(_1))
end,
      magic_store = function(_1)
  return ("魔法店の%s")
  :format(basename(_1))
end
    },
    home = {
      design = {
        help = "マウスの左クリックでタイルの敷設、右クリックでタイルの取得、移動キーでスクリーン移動、決定キーでタイル一覧、キャンセルキーで終了。"
      },
      hire = {
        too_many_guests = "家はすでに人であふれかえっている。",
        who = "誰を雇用する？",
        you_hire = function(_1)
  return ("%sを家に迎えた。")
  :format(basename(_1))
end
      },
      move = {
        dont_touch_me = function(_1)
  return ("%s「触るな！」")
  :format(basename(_1))
end,
        invalid = "その場所には移動させることができない。",
        is_moved = function(_1)
  return ("%sを移動させた。")
  :format(basename(_1))
end,
        where = function(_1)
  return ("%sをどこに移動させる？")
  :format(basename(_1))
end,
        who = "誰を移動させる？"
      },
      rank = {
        change = function(_1, _2, _3, _4, _5, _6)
  return ("家具(%s点) 家宝(%s点) ランク変動(%s %s位 → %s位 )《%s》")
  :format(_1, _2, _6, _3, _4, _5)
end,
        enter_key = "決定ｷｰ,",
        heirloom_rank = "家宝ランク",
        place = function(_1)
  return ("%s位.")
  :format(_1)
end,
        star = "★",
        title = "家の情報",
        type = {
          base = "基本.",
          deco = "家具.",
          heir = "家宝.",
          total = "総合."
        },
        value = "価値"
      },
      staying = {
        add = {
          ally = function(_1)
  return ("%sを滞在させた。")
  :format(basename(_1))
end,
          worker = function(_1)
  return ("%sを任命した。")
  :format(basename(_1))
end
        },
        count = function(_1, _2)
  return ("現在%s人の滞在者がいる(最大%s人) ")
  :format(_1, _2)
end,
        remove = {
          ally = function(_1)
  return ("%sの滞在を取り消した。")
  :format(basename(_1))
end,
          worker = function(_1)
  return ("%sを役目から外した。")
  :format(basename(_1))
end
        }
      }
    },
    house_board = {
      choices = {
        allies_in_your_home = "仲間の滞在",
        assign_a_breeder = "ブリーダーを任命する",
        assign_a_shopkeeper = "仲間に店主を頼む",
        design = "家の模様替え",
        extend = function(_1)
  return ("店を拡張(%s GP)")
  :format(_1)
end,
        home_rank = "家の情報",
        move_a_stayer = "滞在者の移動",
        recruit_a_servant = "使用人を募集する"
      },
      item_count = function(_1, _2, _3, _4)
  return ("%sには%s個のアイテムと%s個の家具がある(アイテム最大%s個) ")
  :format(_1, _2, _3, _4)
end,
      only_use_in_home = "ここはあなたの家ではない。",
      what_do = "何をする？"
    },
    museum = {
      rank_change = function(_1, _2, _3, _4)
  return ("ランク変動(%s %s位 → %s位 )《%s》")
  :format(_4, _1, _2, _3)
end
    },
    names = {
      _521 = "博物館",
      _522 = "店",
      _542 = "畑",
      _543 = "倉庫",
      _572 = "牧場",
      _712 = "ダンジョン"
    },
    not_enough_money = "お金が足りない…",
    ranch = {
      current_breeder = function(_1)
  return ("現在のブリーダーは%sだ。")
  :format(basename(_1))
end,
      no_assigned_breeder = "現在ブリーダーはいない。"
    },
    really_build_it_here = "本当にこの場所に建設する？ ",
    shop = {
      current_shopkeeper = function(_1)
  return ("現在の店主は%sだ。")
  :format(basename(_1))
end,
      extend = function(_1)
  return ("店を拡張した！これからは%s個のアイテムを陳列できる。")
  :format(_1)
end,
      info = "店",
      log = {
        and_items = function(_1)
  return ("と%s個のアイテム")
  :format(_1)
end,
        could_not_sell = function(_1, _2)
  return ("%s人が来客したが、%sはアイテムを一つも売れなかった。")
  :format(_1, basename(_2))
end,
        gold = function(_1)
  return ("%sgold")
  :format(_1)
end,
        no_shopkeeper = "店には店番がいない。",
        sold_items = function(_1, _2, _3, _4)
  return ("%s人の来客があり、%sは%s個のアイテムを売却した。%sが売り上げとして金庫に保管された。")
  :format(_1, basename(_2), _3, _4)
end
      },
      no_assigned_shopkeeper = "現在店主はいない。"
    }
  }
}
