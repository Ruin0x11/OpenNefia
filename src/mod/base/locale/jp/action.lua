return {
  action = {
    ally_joins = {
      party_full = "仲間の最大数に達しているため、仲間にできなかった…",
      success = function(_1)
  return ("%sが仲間に加わった！")
  :format(basename(_1))
end
    },
    ammo = {
      current = "現在の装填弾:",
      is_not_capable = function(_1)
  return ("%sは切り替えに対応していない。")
  :format(_1)
end,
      need_to_equip = "矢弾を装備していない。",
      normal = "通常弾",
      unlimited = "無限"
    },
    angband = {
      at = "うわぁぁぁ！！",
      q = "え…",
      y = "まさか…"
    },
    autopick = {
      reloaded_autopick_file = "autopickファイルを再読み込みした。"
    },
    backpack_squashing = function(_1)
  return ("%sは荷物に圧迫されもがいた。")
  :format(name(_1))
end,
    bash = {
      air = function(_1)
  return ("%sは空気に体当たりした。")
  :format(name(_1))
end,
      choked = {
        dialog = "「助かったよ！」",
        execute = function(_1, _2)
  return ("%sは%sに全力で体当たりした。")
  :format(name(_1), name(_2))
end,
        spits = function(_1)
  return ("%sはもちを吐き出した。")
  :format(name(_1))
end
      },
      disturbs_sleep = function(_1, _2)
  return ("%sは睡眠を妨害された。")
  :format(name(_2))
end,
      door = {
        cracked = "扉は少しだけ壊れた。",
        destroyed = "扉に体当たりして破壊した。",
        execute = "扉に体当たりした。",
        hurt = function(_1)
  return ("%sは筋肉を痛めた。")
  :format(name(_1))
end,
        jail = "さすがに牢獄の扉は頑丈だ。"
      },
      execute = function(_1, _2)
  return ("%sは%sに体当たりした。")
  :format(name(_1), name(_2))
end,
      prompt = "どの方向に体当たりする？ ",
      shatters_pot = function(_1)
  return ("%sは壷を割った。")
  :format(name(_1))
end,
      tree = {
        execute = function(_1)
  return ("%sに体当たりした。")
  :format(_1)
end,
        falls_down = function(_1)
  return ("%sが降ってきた。")
  :format(_1)
end,
        no_fruits = "もう実はないようだ… "
      }
    },
    cannot_do_in_global = "その行為は、ワールドマップにいる間はできない。",
    cast = {
      confused = function(_1)
  return ("%sは混乱しながらも魔法の詠唱を試みた。")
  :format(name(_1))
end,
      fail = function(_1)
  return ("%sは詠唱に失敗した。")
  :format(name(_1))
end,
      other = function(_1, _2)
  return ("%sは%s")
  :format(name(_1), _2)
end,
      overcast_warning = "マナが足りないが、それでも詠唱を試みる？",
      self = function(_1, _2, _3)
  return ("%sは%sの%s")
  :format(name(_1), _2, _3)
end,
      silenced = "沈黙の霧が詠唱を阻止した。"
    },
    close = {
      blocked = "何かが邪魔で閉められない。",
      execute = function(_1)
  return ("%sは扉を閉めた。")
  :format(name(_1))
end,
      nothing_to_close = "その方向に閉められるものはない。"
    },
    day_breaks = "夜が明けた。",
    dig = {
      prompt = "どの方向を掘る？ ",
      too_exhausted = "疲れ過ぎて無理だ。"
    },
    dip = {
      execute = function(_1, _2)
  return ("%sを%sに浸した。")
  :format(_2, _1)
end,
      result = {
        bait_attachment = function(_1, _2)
  return ("%sを%sに装着した。")
  :format(_2, _1)
end,
        becomes_blessed = function(_1)
  return ("%sは銀色に輝いた。")
  :format(_1)
end,
        becomes_cursed = function(_1)
  return ("%sは黒いオーラに包まれた。")
  :format(_1)
end,
        blessed_item = function(_1, _2)
  return ("%sを%sに降りかけた。")
  :format(_2, _1)
end,
        dyeing = function(_1)
  return ("あなたは%sを染めた。")
  :format(_1)
end,
        empty_bottle_shatters = "空き瓶の割れる音がした。",
        gains_acidproof = function(_1)
  return ("%sは酸から守られた。")
  :format(_1)
end,
        gains_fireproof = function(_1)
  return ("%sは熱から守られた。")
  :format(_1)
end,
        good_idea_but = "いいアイデアだ！しかし…",
        holy_well_polluted = "井戸は汚れた。",
        love_food = {
          grin = "あなたはにやりと笑った。",
          guilty = "あなたはうしろめたさを感じた…",
          made = function(_1, _2)
  return ("%sに%sを混入した！")
  :format(_1, _2)
end
        },
        natural_potion = "空き瓶に水をすくった。",
        natural_potion_drop = "あっ！空き瓶を井戸に落としてしまった…",
        natural_potion_dry = function(_1)
  return ("%sは涸れている。")
  :format(_1)
end,
        poisoned_food = "あなたはにやりと口元を歪めた。",
        put_on = function(_1, _2)
  return ("%sに%sを塗りたくった。")
  :format(_1, _2)
end,
        snow_melts = {
          blending = "しかしこんな量では… ",
          dip = "こんな量では… "
        },
        well_dry = function(_1)
  return ("%sは完全に枯れている。")
  :format(_1)
end,
        well_refill = function(_1, _2)
  return ("%sを%sに放り込んだ。")
  :format(_2, _1)
end,
        well_refilled = function(_1)
  return ("%sは一瞬輝いた。")
  :format(_1)
end
      },
      rots = function(_1)
  return ("%sは腐ってしまった…")
  :format(_1)
end,
      rusts = function(_1)
  return ("%sは錆びてしまった…")
  :format(_1)
end,
      unchanged = function(_1)
  return ("%sに変化はない。")
  :format(_1)
end,
      you_get = function(_1)
  return ("%sを手に入れた。")
  :format(_1)
end
    },
    drink = {
      potion = function(_1, _2)
  return ("%s%sを飲み干した。")
  :format(kare_wa(_1), _2)
end,
      well = {
        completely_dried_up = function(_1)
  return ("%sは完全に干上がった。")
  :format(_1)
end,
        draw = function(_1, _2)
  return ("%sは%sの水をすくって飲んだ。")
  :format(name(_1), _2)
end,
        dried_up = function(_1)
  return ("%sは干上がった。")
  :format(_1)
end,
        effect = {
          default = "この水は清涼だ。",
          falls = {
            dialog = function(_1)
  return ("%s「手を伸ばせー」")
  :format(name(_1))
end,
            floats = "しかしすぐに浮いてきた… ",
            text = function(_1)
  return ("%sは井戸に落ちた！ ")
  :format(name(_1))
end
          },
          finds_gold = function(_1)
  return ("%sは水の中に金貨を見つけた。")
  :format(name(_1))
end,
          monster = "井戸から何かが出てきた！",
          pregnancy = function(_1)
  return ("%sは何かいけないものを飲み込んだ。")
  :format(name(_1))
end,
          wish_too_frequent = "ものすごい幸運が訪れた…ような気がしたが気のせいだった。"
        },
        is_dry = function(_1)
  return ("%sは涸れている。")
  :format(_1)
end
      }
    },
    drop = {
      execute = function(_1)
  return ("%sを地面に置いた。")
  :format(_1)
end,
      too_many_items = "もう周りに物を置くスペースがない！ ",
      water_is_blessed = "水は祝福を受けた。"
    },
    eat = {
      snatches = function(_1, _2)
  return ("%sは%sの食べ物を横取りした。")
  :format(name(_1), name(_2))
end
    },
    equip = {
      two_handed = {
        fits_well = function(_1)
  return ("装備中の%sは両手にしっくりとおさまる。")
  :format(_1)
end,
        too_heavy = function(_1)
  return ("装備中の%sは利手で扱うにも重すぎる。")
  :format(_1)
end,
        too_heavy_other_hand = function(_1)
  return ("装備中の%sは片手で扱うには重すぎる。")
  :format(_1)
end,
        too_heavy_when_riding = function(_1)
  return ("装備中の%sは乗馬中に扱うには重すぎる。")
  :format(_1)
end,
        too_light = function(_1)
  return ("装備中の%sは両手持ちにはやや軽すぎる。")
  :format(_1)
end
      },
      you_change = "装備を変更した。"
    },
    exit = {
      cannot_save_in_usermap = "ユーザーマップの中ではセーブできない。それでも終了する？",
      choices = {
        cancel = "いいえ",
        exit = "はい",
        game_setting = "ゲーム設定",
        return_to_title = "タイトルに戻る"
      },
      prompt = "これまでの冒険を記録して終了する？",
      saved = "無事に記録された。",
      you_close_your_eyes = function(_1)
  return ("%sは静かに目を閉じた… (キーを押すと自動終了します)")
  :format(name(_1))
end
    },
    exit_map = {
      burdened_by_cargo = "荷車の重量超過でかなり鈍足になっている！ ",
      cannot_enter_jail = "あなたはガードに追い返された。",
      delivered_to_your_home = "あなたは家まで運ばれた。",
      entered = function(_1)
  return ("%sに入った。")
  :format(_1)
end,
      gate = {
        need_network = "ネット機能をONにする必要がある。",
        step_into = "あなたはゲートに足を踏み入れた。ゲートはあなたの背後で消滅した。"
      },
      it_is_hot = "熱い！",
      larna = "ラーナの村に辿りついた。",
      left = function(_1)
  return ("%sを後にした。")
  :format(_1)
end,
      mountain_pass = "マウンテンパスに降りた。",
      no_invitation_to_pyramid = "あなたはピラミッドへの招待状を持っていない。",
      not_permitted = "あなたはこの洞窟の探索を許可されていない。",
      returned_to = function(_1)
  return ("%sに戻った。")
  :format(_1)
end,
      surface = {
        left = function(_1)
  return ("%sの表層を後にした。")
  :format(_1)
end,
        returned_to = function(_1)
  return ("%sの表層に戻った。")
  :format(_1)
end
      }
    },
    gatcha = {
      do_not_have = function(_1)
  return ("%sを持っていない…")
  :format(_1)
end,
      prompt = function(_1)
  return ("%sを使ってガシャガシャする？")
  :format(_1)
end
    },
    get = {
      air = "あなたは空気をつかんだ。",
      building = {
        prompt = "本当にこの建物を撤去する？（注意！建物と中の物は完全に失われます）",
        remove = "建物を撤去した。"
      },
      cannot_carry = "それは持ち運べない。",
      not_owned = { "それはあなたの物ではない。", "盗むなんてとんでもない。", "それは拾えない。" },
      plant = {
        dead = "枯れた草を摘み取った。",
        young = "芽を摘み取った。"
      },
      snow = "雪をかきあつめた。"
    },
    hit_key_for_help = "?キーを押すと、コマンドの一覧が見られる。",
    interact = {
      change_tone = {
        default_tone = "デフォルトの口調",
        hint = "決定 [口調の変更]  ",
        is_somewhat_different = function(_1)
  return ("%sの口調が変わった気がする。")
  :format(name(_1))
end,
        prompt = "どんな言葉を教えようか。",
        title = "口調一覧",
        tone_title = "題名"
      },
      choices = {
        appearance = "着替えさせる",
        attack = "攻撃する",
        bring_out = "連れ出す",
        change_tone = "口調を変える",
        give = "何かを渡す",
        info = "情報",
        inventory = "所持品",
        name = "名前をつける",
        release = "縄を解く",
        talk = "話しかける",
        teach_words = "言葉を教える"
      },
      choose = "操作する対象の方向は？",
      name = {
        cancel = "名前をつけるのはやめた。",
        prompt = function(_1)
  return ("%sを何と呼ぶ？ ")
  :format(name(_1))
end,
        you_named = function(_1)
  return ("%sという名前で呼ぶことにした。")
  :format(basename(_1))
end
      },
      prompt = function(_1)
  return ("%sに何をする？ ")
  :format(name(_1))
end,
      release = function(_1)
  return ("%sの縄を解いた。")
  :format(name(_1))
end
    },
    look = {
      find_nothing = "視界内にターゲットは存在しない。",
      target = function(_1)
  return ("%sをターゲットにした。")
  :format(name(_1))
end,
      target_ground = "地面をターゲットにした。"
    },
    melee = {
      shield_bash = function(_1, _2)
  return ("%sは盾で%sを殴りつけた。")
  :format(name(_1), name(_2))
end
    },
    move = {
      carry_too_much = "潰れていて動けない！ ",
      confused = " *ごつん* ",
      displace = {
        dialog = { "「おっと、ごめんよ」", "「気をつけな」" },
        text = function(_1)
  return ("%sと入れ替わった。")
  :format(name(_1))
end
      },
      drunk = " *ふらり* ",
      feature = {
        material = {
          mining = "採掘場がある。",
          plants = "色んな植物が生えている。",
          remains = "何かの残骸がある。",
          spot = "何かが見つかりそうだ。",
          spring = "泉がある。"
        },
        seed = {
          growth = {
            bud = function(_1)
  return ("%sが育っている。")
  :format(_1)
end,
            seed = function(_1)
  return ("%sの種が植えてある。")
  :format(_1)
end,
            tree = function(_1)
  return ("%sの実が成っている。")
  :format(_1)
end,
            withered = function(_1)
  return ("%sの草は枯れてしまっている… ")
  :format(_1)
end
          },
          type = {
            artifact = "アーティファクト",
            fruit = "果物",
            gem = "宝石",
            herb = "ハーブ",
            magic = "魔法の木",
            strange = "何か",
            vegetable = "野菜"
          }
        },
        stair = {
          down = "降り階段がある。",
          up = "昇り階段がある。"
        }
      },
      global = {
         ambush = {
            message = function(_1, _2)
               return ("襲撃だ！ (最も近い街までの距離:%s 敵勢力:%s)")
                  :format(_1, _2)
            end,
            rank = {
               dragon = "ドラゴン級",
               drake = "ドレイク級",
               grizzly_bear = "グリズリー級",
               lich = "リッチ級",
               orc = "オーク級",
               putit = "プチ級"
            },
         },
        diastrophism = "この大陸に大きな地殻変動が起こった。",
        nap = "仮眠をとった。",
        weather = {
          heavy_rain = {
            message = { "雨が激しすぎてどこを歩いているかもわからない！", "あまりにも視界が悪すぎる。", "豪雨のせいで前が全く見えない。" },
            sound = { " *びしゃ* ", " *ザブッ* ", " *パシャッ* ", " *ざぶ* " }
          },
          snow = {
            eat = "空腹のあまり、あなたは積もっている雪を腹にかきこんだ。",
            message = { "積雪のせいで旅程が遅れている。", "雪道を進むのは大変な苦労だ。", "深い雪に脚をとられている。" },
            sound = { " *ずぶっ* ", " *ザシュ* ", " *ズボ* ", " *ズサッ* " }
          }
        }
      },
      interrupt = function(_1)
  return ("%sはあなたを睨み付けた。")
  :format(name(_1))
end,
      item_on_cell = {
        building = function(_1)
  return ("%sが設置されている。")
  :format(_1)
end,
        item = function(_1)
  return ("%sが落ちている。")
  :format(_1)
end,
        more_than_three = function(_1)
  return ("ここには%s種類のアイテムがある。")
  :format(_1)
end,
        not_owned = function(_1)
  return ("%sがある。")
  :format(_1)
end
      },
      leave = {
        abandoning_quest = "注意！現在のクエストは失敗に終わってしまう。",
        prompt = function(_1)
  return ("%sを去る？ ")
  :format(_1)
end
      },
      sense_something = "地面に何かがあるようだ。",
      trap = {
        activate = {
          blind = "墨が噴き出した。",
          confuse = "臭い匂いがたちこめた。",
          mine = " *チュドーン！* ",
          paralyze = "刺激的な匂いがただよう。",
          poison = "魔法の力がテレポートを防いだ。",
          sleep = "毒ガスが噴き出した。",
          spears = {
            target_floating = function(_1)
  return ("しかし%sには届かなかった。")
  :format(name(_1))
end,
            text = "槍が地面から飛び出した。"
          },
          text = function(_1)
  return ("%s罠にかかった！")
  :format(kare_wa(_1))
end
        },
        disarm = {
          dismantle = "あなたは罠を解体した。",
          fail = "解除に失敗した。",
          succeed = "罠を解除した。"
        },
        evade = function(_1)
  return ("%sは罠を避けた。")
  :format(name(_1))
end
      },
      twinkle = " *キラン* ",
      walk_into = function(_1)
  return ("足元には%sがある。")
  :format(_1)
end
    },
    new_day = "一日が終わり、日付が変わった。",
    npc = {
      arena = { "「いいぞ！」", "「もっとやれー」", "「血をみせろー」", "「頑張って！」", "「うぉぉぉぉ！」", "「行けぇ！」", "「頭を使えよ」", "「きゃー」" },
      drunk = {
        annoyed = {
          dialog = "「酔っ払いにはうんざり！」",
          text = function(_1)
  return ("%sはカチンときた。")
  :format(name(_1))
end
        },
        dialog = { "「一杯どうだい？」", "「飲んでないよ」", "「何見てるのさ」", "「遊ぼうぜ」" },
        gets_the_worse = function(_1, _2)
  return ("%sは酔っ払って%sにからんだ。")
  :format(name(_1), name(_2))
end
      },
      is_busy_now = function(_1)
  return ("%sは忙しい。")
  :format(name(_1))
end,
      leash = {
        dialog = { "「痛っ！」", "「やめて！」" },
        untangle = function(_1)
  return ("%sは巻きついていた紐をほどいた。")
  :format(name(_1))
end
      },
      sand_bag = { function(_1)
  return ("もっとぶって%s")
  :format(yo(_1, 2))
end, function(_1)
  return ("こんなことして、許さない%s")
  :format(yo(_1))
end, function(_1)
  return ("何をする%s")
  :format(noda(_1, 2))
end }
    },
    offer = {
      claim = function(_1)
  return ("異世界で、%sが空白の祭壇の権利を主張した。")
  :format(_1)
end,
      do_not_believe = "あなたは神を信仰していないが、試しに捧げてみた。",
      execute = function(_1, _2)
  return ("あなたは%sを%sに捧げ、その名を唱えた。")
  :format(_1, _2)
end,
      result = {
        best = function(_1)
  return ("%sはまばゆく輝いて消えた。")
  :format(_1)
end,
        good = function(_1)
  return ("%sは輝いて消え、三つ葉のクローバーがふってきた。")
  :format(_1)
end,
        okay = function(_1)
  return ("%sは一瞬輝いて消えた。")
  :format(_1)
end,
        poor = function(_1)
  return ("%sは消えた。")
  :format(_1)
end
      },
      take_over = {
        attempt = function(_1, _2)
  return ("異様な霧が現れ、%sと%sの幻影がせめぎあった。")
  :format(_1, _2)
end,
        fail = function(_1)
  return ("%sは祭壇を守りきった。")
  :format(_1)
end,
        shadow = "あなたの神の幻影は、次第に色濃くなった。",
        succeed = function(_1, _2)
  return ("%sは%sを支配した。")
  :format(_1, _2)
end
      }
    },
    open = {
      door = {
        fail = function(_1)
  return ("%s開錠に失敗した。")
  :format(kare_wa(_1))
end,
        succeed = function(_1)
  return ("%sは扉を開けた。")
  :format(name(_1))
end
      },
      empty = "中身は空っぽだ。",
      goods = function(_1)
  return ("%sから溢れ出た高級品が、足元に散らばった。")
  :format(_1)
end,
      new_year_gift = {
        cursed_letter = "中には呪いの手紙が入っていた。",
        ring = " *チリリリリーン* ",
        something_inside = "何かが袋から出てきた。",
        something_jumps_out = "悪意を持った何かが袋から飛び出してきた！",
        trap = "罠だ！お年玉袋は発火した。",
        wonderful = "これは素晴らしい贈り物だ！",
        younger_sister = "妹が入っていた！"
      },
      only_in_home = "それは家の中でのみ使用できる。",
      only_in_shop = "それは店の中でのみ使用できる。",
      shackle = {
        dialog = "モイアー「馬鹿やろう！！」",
        text = "足枷を外した。"
      },
      text = function(_1)
  return ("あなたは%sを開けた。")
  :format(_1)
end
    },
    pick_up = {
      do_you_want_to_remove = function(_1)
  return ("%sを撤去する？ ")
  :format(_1)
end,
      execute = function(_1, _2)
  return ("%sは%sを拾った。")
  :format(name(_1), _2)
end,
      poison_drips = "あなたの手から毒が滴った。",
      put_in_container = function(_1)
  return ("%sを保管した。")
  :format(_1)
end,
      shopkeepers_inventory_is_full = "店の倉庫が一杯のため売れない。",
      thieves_guild_quota = function(_1)
  return ("盗賊ギルドのノルマ達成まで、あと金貨%s枚相当の盗品を売却する必要がある。")
  :format(_1)
end,
      used_by_mount = function(_1)
  return ("それは%sが使用中だ。")
  :format(name(_1))
end,
      you_absorb_magic = function(_1)
  return ("あなたは%sから魔力を吸い取った。")
  :format(_1)
end,
      you_buy = function(_1)
  return ("%sを買った。")
  :format(_1)
end,
      you_sell = function(_1)
  return ("%sを売った。")
  :format(_1)
end,
      you_sell_stolen = function(_1)
  return ("盗品の%sを売却した。")
  :format(_1)
end,
      your_inventory_is_full = "バックパックには、もうアイテムを入れる余裕がない。"
    },
    plant = {
      cannot_plant_it_here = "この場所には埋められない。",
      execute = function(_1)
  return ("%sを埋めた。")
  :format(_1)
end,
      harvest = function(_1)
  return ("%sを収穫した。")
  :format(_1)
end,
      new_plant_grows = "新しい芽が息吹いている！",
      on_field = function(_1)
  return ("畑に%sを埋めた。")
  :format(_1)
end
    },
    playtime_report = function(_1)
  return ("Elonaをはじめてから%s時間が経過しています。")
  :format(_1)
end,
    quicksave = " *保存* ",
    ranged = {
      equip = {
        need_ammo = "矢/弾丸を装備する必要がある。",
        need_weapon = "射撃用の道具を装備していない。",
        wrong_ammo = "矢/弾丸の種類が適していない。"
      },
      load_normal_ammo = "通常弾を装填した。",
      no_target = "ターゲットが見当たらない。"
    },
    read = {
      book = {
        already_decoded = "それは既に解読済みだ。",
        book_of_rachel = "レイチェルという作家による、心あたたまる童話集だ。",
        falls_apart = function(_1)
  return ("%sは塵となって崩れ落ちた。")
  :format(_1)
end,
        finished_decoding = function(_1)
  return ("%sを解読した！")
  :format(_1)
end,
        not_interested = "この本の内容には興味がない。それでも読む？ ",
        void_permit = "すくつの探索を許可する、という内容の文面が形式的に書いてある。"
      },
      cannot_see = function(_1)
  return ("%sは何も見えない。")
  :format(name(_1))
end,
      recipe = {
        info = "最後に調合したアイテムを、レシピに加えることができる。(まだ未実装)",
        learned = function(_1)
  return ("%sを覚えた！")
  :format(_1)
end
      },
      scroll = {
        dimmed_or_confused = function(_1)
  return ("%sはふらふらした。")
  :format(name(_1))
end,
        execute = function(_1, _2)
  return ("%s%sを読んだ。")
  :format(kare_wa(_1), _2)
end
      }
    },
    really_attack = function(_1)
  return ("本当に%sを攻撃する？ ")
  :format(name(_1))
end,
    search = {
      crystal = {
        close = "辺りの空気は息苦しいほどの緊張に包まれている。",
        far = "まだだ、まだ遠い…",
        normal = "微かだが、あなたの心臓はトクンと脈打った。",
        sense = "あなたは青い水晶の存在を感じた。"
      },
      discover = {
        hidden_path = "隠れた通路を発見した。",
        trap = "罠を発見した。"
      },
      execute = "周囲を注意深く調べた。",
      small_coin = {
        close = "あなたは何かが輝くのを目にした。",
        far = "この辺りには何かがありそうな予感がする…",
        find = "なんと小さなメダルを見つけた！"
      }
    },
    shortcut = {
      cannot_use_anymore = "もうその行動はできない。",
      cannot_use_spell_anymore = "その魔法はもう使えない。",
      unassigned = "そのキーにはショートカットが割り当てられていない。"
    },
    someone_else_is_using = "そのアイテムは他の誰かが使用中だ。",
    take_screenshot = "スクリーンショットを撮った。",
    target = {
      level = {
        _0 = "目隠しして座っていても勝てる。",
        _1 = "目隠ししていても勝てそうだ。",
        _10 = "相手が巨人だとすれば、あなたは蟻のフン以下だ。",
        _2 = "負ける気はしない。",
        _3 = "たぶん勝てそうだ。",
        _4 = "勝てない相手ではない。",
        _5 = "相手はかなり強そうだ。",
        _6 = "少なくとも、あなたの倍は強そうだ。",
        _7 = "奇跡が起きなければ殺されるだろう。",
        _8 = "確実に殺されるだろう。",
        _9 = "絶対に勝てない相手だ。"
      },
      out_of_sight = "視界範囲外",
      you_are_targeting = function(_1, _2)
  return ("現在のターゲットは%s (距離 %s)")
  :format(name(_1), _2)
end
    },
    throw = {
      execute = function(_1, _2)
  return ("%sは%sを投げた。")
  :format(name(_1), _2)
end,
      hits = function(_1)
  return ("%sに見事に命中した！")
  :format(name(_1))
end,
      monster_ball = {
        cannot_be_captured = "その生物には無効だ。",
        capture = function(_1)
  return ("%sをモンスターボールに捕獲した。")
  :format(name(_1))
end,
        does_not_work = "この場所では効果がない。",
        not_enough_power = "その生物を捕獲するには、より高レベルのモンスターボールが必要だ。",
        not_weak_enough = "捕獲するためにはもっと弱らせる必要がある。"
      },
      shatters = "それは地面に落ちて砕けた。",
      snow = {
        dialog = { "「いてー！」", "「やったな」", " *クスクス* ", "「キャハハ」", "「こやつめ」", "「むむっ」" },
        hits_snowman = function(_1)
  return ("%sに命中して、雪だるまは崩れた。")
  :format(_1)
end,
        melts = "それは地面に落ちて溶けた。"
      },
      tomato = " *ぷちゅ* "
    },
    time_stop = {
      begins = function(_1)
  return ("%sは時を止めた。")
  :format(name(_1))
end,
      ends = "時は再び動き出した。"
    },
    unlock = {
      do_not_have_lockpicks = "ロックピックを所持していない。",
      easy = "楽勝だ。",
      fail = "開錠に失敗した。",
      lockpick_breaks = "ロックピックは壊れた。",
      succeed = "開錠に成功した。",
      too_difficult = "この鍵を開ける技術はない。",
      try_again = "もう一度試みる？",
      use_lockpick = "ロックピックを使用した。",
      use_skeleton_key = "スケルトンキーも使用した。"
    },
    use_stairs = {
      blocked_by_barrier = "階段は不思議なバリアで塞がれている。",
      cannot_during_debug = "デバッグ中はその操作はできない。",
      cannot_go = {
        down = "これ以上降りられない。",
        up = "これ以上昇れない。"
      },
      kotatsu = {
        prompt = "本当にこたつの中に入る？",
        use = "まっくらだ！"
      },
      locked = "鍵のかかった扉が行く手を塞いでいる。",
      lost_balance = function()
  return ("うわああ！%sは階段から足を踏み外した。")
  :format(you())
end,
      no = {
        downstairs = "降りる階段は見つからない。",
        upstairs = "昇る階段は見つからない。"
      },
      prompt_give_up_game = "試合を放棄する？",
      prompt_give_up_quest = "クエストを放棄して階を移動する？",
      unlock = {
        normal = "扉の鍵を開けた。",
        stones = "厳重に封印された扉の前に立つと、三つの魔石が鈍い光を放った。"
      }
    },
    weather = {
      changes = "天候が変わった。",
      ether_wind = {
        starts = "エーテルの風が吹き始めた。すぐに避難しなくては。",
        stops = "エーテルの風は止んだ。"
      },
      rain = {
        becomes_heavier = "雨が本格的に降り出した。",
        becomes_lighter = "雨は小降りになった。",
        draw_cloud = "あなたは雨雲を引き寄せた。",
        starts = "雨が降り出した。",
        starts_heavy = "突然どしゃぶりになった。",
        stops = "雨は止んだ。"
      },
      snow = {
        starts = "雪が降ってきた。",
        stops = "雪は止んだ。"
      }
    },
    which_direction = {
      ask = "どの方向？",
      cannot_see_location = "その場所は見えない。",
      default = "どの方向に？ ",
      door = "何を閉める？",
      out_of_range = "射程距離外だ。",
      spell = "どの方向に唱える？ ",
      wand = "どの方向に振る？ "
    },
    zap = {
      execute = function(_1)
  return ("%sを振った。")
  :format(_1)
end,
      fail = function(_1)
  return ("%sは杖をうまく使えなかった。")
  :format(name(_1))
end
    }
  }
}
