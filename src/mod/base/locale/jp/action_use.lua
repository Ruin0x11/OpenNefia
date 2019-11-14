return {
  action = {
    use = {
      chair = {
        choices = {
          free_chair = "誰でも座っていい",
          guest_chair = "お客用のチェアにする",
          my_chair = "マイチェアにする",
          relax = "くつろぐ"
        },
        free_chair = function(_1)
  return ("%sは誰でも座っていい席になった！")
  :format(itemname(_1, 1))
end,
        guest_chair = function(_1)
  return ("%sは訪問者の席になった！")
  :format(itemname(_1, 1))
end,
        my_chair = function(_1)
  return ("%sはあなた専用の席になった！")
  :format(itemname(_1, 1))
end,
        needs_place_on_ground = "床に置かないと使えない。",
        relax = "あなたは存分にくつろいだ。",
        you_sit_on = function(_1)
  return ("あなたは%sに座った。")
  :format(itemname(_1, 1))
end
      },
      deck = {
        add_card = function(_1)
  return ("%sをデッキに加えた。")
  :format(itemname(_1, 1))
end,
        no_deck = "デッキを所持していない。",
        put_away = "デッキをしまった。"
      },
      dresser = {
        prompt = "誰を対象にする？"
      },
      gem_stone = {
        kumiromi = {
          already_grown = "この作物は既に成長しきっている。",
          grows = "植物は成長した。",
          no_plant = "それは種を植えた場所で使わなければならない。",
          revives = "枯れた植物に生命が宿った。"
        }
      },
      gene_machine = {
        choose_original = "まずは素体となる仲間を選ぶ必要がある。",
        choose_subject = "遺伝子を取り出す仲間を選ぶ必要がある。この仲間は合成後、永久に失われる。",
        gains = {
          ability = function(_1, _2)
  return ("%sは%sの技術を覚えた！")
  :format(basename(_1), _2)
end,
          body_part = function(_1, _2)
  return ("%sは新しい%sを得た！")
  :format(basename(_1), _2)
end,
          level = function(_1, _2)
  return ("%sはレベル%sになった！")
  :format(basename(_1), _2)
end
        },
        has_inherited = function(_1, _2)
  return ("%sは%sの遺伝子を受けついだ！")
  :format(basename(_1), basename(_2))
end,
        precious_ally = function(_1)
  return ("%sはあなたの大事な仲間だ。遺伝子を取り出すには聴診器を外す必要がある。")
  :format(name(_1))
end,
        prompt = function(_1, _2)
  return ("本当に%sに%sの遺伝子を組み込む？")
  :format(basename(_2), basename(_1))
end
      },
      guillotine = {
        someone_activates = "突然誰かがギロチンの刃を落とした。",
        use = "あなたはギロチンに首をつっこんでみた。"
      },
      hammer = {
        use = function(_1)
  return ("%sを振った。")
  :format(itemname(_1, 1))
end
      },
      house_board = {
        cannot_use_it_here = "それはここでは使えない。"
      },
      iron_maiden = {
        grin = "「ニヤリ」",
        interesting = "「わくわく♪」",
        someone_activates = "突然誰かが蓋を閉めた。",
        use = "あなたはアイアンメイデンの中に入った。"
      },
      leash = {
        other = {
          start = {
            dialog = function(_1)
  return ("%sは呻き声を洩らした。「アン…♪」")
  :format(name(_1))
end,
            resists = function(_1)
  return ("%sが激しく抵抗したため紐は切れた。")
  :format(name(_1))
end,
            text = function(_1)
  return ("あなたは%sを紐でくくりつけた。")
  :format(name(_1))
end
          },
          stop = {
            dialog = function(_1)
  return ("%sは呻き声を洩らした。「はぁはぁ…」")
  :format(name(_1))
end,
            text = function(_1)
  return ("あなたは%sにくくりつけた紐をほどいた。")
  :format(name(_1))
end
          }
        },
        prompt = "誰を紐で結ぶ？",
        self = "あなたは自分を紐でくくってみた…"
      },
      living = {
        becoming_a_threat = "その力は次第に脅威になっている。",
        bonus = "ボーナス+1",
        displeased = function(_1)
  return ("%sは不満そうに震えた。")
  :format(itemname(_1))
end,
        it = "それは…",
        needs_more_blood = "この武器はまだ血を吸い足りない。",
        pleased = function(_1)
  return ("%sは嬉しげに震えた。")
  :format(itemname(_1))
end,
        ready_to_grow = function(_1)
  return ("%sは十分に血を吸い成長できる！")
  :format(itemname(_1))
end,
        removes_enchantment = function(_1)
  return ("%sはエンチャントを消した。")
  :format(itemname(_1))
end,
        weird = "しかし、なんだか様子がおかしい…"
      },
      mine = {
        cannot_place_here = "ここには置けない。",
        cannot_use_here = "ここでは使えない。",
        you_set_up = "地雷を設置した。"
      },
      money_box = {
        full = "貯金箱は一杯だ。",
        not_enough_gold = "金貨が足りない…"
      },
      monster_ball = {
        empty = "モンスターボールは空っぽだ。",
        party_is_full = "仲間はこれ以上増やせない。",
        use = function(_1)
  return ("%sを使用した。")
  :format(itemname(_1, 1))
end
      },
      music_disc = {
        play = function(_1)
  return ("%sを再生した。")
  :format(itemname(_1, 1))
end
      },
      not_sleepy = "まだ眠たくない。",
      nuke = {
        cannot_place_here = "ここでは使えない。",
        not_quest_goal = "ここはクエストの目標位置ではない。本当にここに設置する？",
        set_up = "原子爆弾を設置した。逃げろォー！"
      },
      out_of_charge = "それはもう使えない。",
      rope = {
        prompt = "本当に首を吊る？"
      },
      rune = {
        only_in_town = "それは街でしか使えない。",
        use = "突然、あなたの目の前に異次元へのゲートが現れた。"
      },
      sandbag = {
        ally = "仲間を吊るすなんてとんでもない！",
        already = "それは既に吊るされている。",
        cannot_use_here = "このエリアでは使えない。",
        not_weak_enough = "もっと弱らせないと吊るせない。",
        prompt = "誰を吊るす？",
        self = "あなたは自分を吊るそうと思ったがやめた…",
        start = function(_1)
  return ("あなたは%sを吊るした。")
  :format(name(_1))
end
      },
      secret_experience = {
        kumiromi = {
          not_enough_exp = "クミロミの声がした。「ダメ…経験…足りない…」",
          use = {
            dialog = "「…よく…経験をつんだね…酬いてあげる…」",
            text = "クミロミはあなたを祝福した。あなたは新たなフィートを取得できるようになった！"
          }
        },
        lomias = "何だか嫌な予感がする…"
      },
      secret_treasure = {
        use = "あなたは新たなフィートを獲得した！"
      },
      shelter = {
        cannot_build_it_here = "ここには建てられない。",
        during_quest = "クエストを放棄してシェルターに避難する？",
        only_in_world_map = "ワールドマップで建設するべきだ。"
      },
      snow = {
        make_snowman = function(_1)
  return ("%sは雪だるまを作った！")
  :format(name(_1))
end,
        need_more = "雪が足りない…"
      },
      statue = {
        activate = function(_1)
  return ("%sを始動させた。")
  :format(itemname(_1, 1))
end,
        creator = {
          in_usermap = "この石像を見つめていると、何かを投げつけたくなってうずうずしてきた！",
          normal = "それはこの場所ではみすぼらしく見える。"
        },
        ehekatl = "エヘカトル「呼んだ？呼んだ？」",
        jure = "ジュア「べ、別にあんたのためにするんじゃないからね。バカっ！」",
        lulwy = {
          during_etherwind = "ルルウィ「あさはかね。エーテルの風を止めてあげるとでも思ったの？」",
          normal = "ルルウィ「あらあら、定命の分際でそんなおねだりするの？ウフフ…今回は特別よ」"
        },
        opatos = "オパートス「フハハハ！間もなく、この地に変動が起こるであろう！」"
      },
      stethoscope = {
        other = {
          start = {
            female = {
              dialog = "「キャー」",
              text = function(_1)
  return ("%sは顔を赤らめた。")
  :format(name(_1))
end
            },
            text = function(_1)
  return ("あなたは%sに聴診器を当てた。")
  :format(name(_1))
end
          },
          stop = function(_1)
  return ("%sから聴診器を外した。")
  :format(name(_1))
end
        },
        prompt = "何に聴診器を当てる？",
        self = " *ドクン ドクン* "
      },
      summoning_crystal = {
        use = "それは鈍く輝いた。"
      },
      torch = {
        light = "松明を灯した。",
        put_out = "松明を消した。"
      },
      unicorn_horn = {
        use = function(_1)
  return ("%sを使った。")
  :format(itemname(_1, 1))
end
      },
      useable_again_at = function(_1)
  return ("そのアイテムが次に使用できるのは%sだ。")
  :format(_1)
end,
      whistle = {
        use = " *ピーーーー* "
      }
    }
  }
}