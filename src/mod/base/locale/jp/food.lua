return {
   food = {
      anorexia = {
         develops = function(_1)
            return ("%sは拒食症になった。")
               :format(name(_1))
         end,
         recovers_from = function(_1)
            return ("%sの拒食症は治った。")
               :format(name(_1))
         end
      },
      cook = function(_1, _2, _3)
         return ("%sで%sを料理して、%sを作った。")
            :format(_2, _1, _3)
      end,
      eat_status = {
         bad = function(_1)
            return ("%sは嫌な感じがした。")
               :format(name(_1))
         end,
         cursed_drink = function(_1)
            return ("%sは気分が悪くなった。")
               :format(name(_1))
         end,
         good = function(_1)
            return ("%sは良い予感がした。")
               :format(name(_1))
         end
      },
      eating_message = {
         bloated = { "もう当分食べなくてもいい。", "こんなに食べたことはない！", "信じられないぐらい満腹だ！" },
         hungry = { "まだまだ食べたりない。", "物足りない…", "まだ空腹だ。", "少しは腹の足しになったか…" },
         normal = { "まだ食べられるな…", "あなたは腹をさすった。", "少し食欲を満たした。" },
         satisfied = { "あなたは満足した。", "満腹だ！", "あなたは食欲を満たした。", "あなたは幸せそうに腹をさすった。" },
         starving = { "こんな量では意味がない！", "これぐらいでは、死を少し先に延ばしただけだ。", "無意味だ…もっと栄養をとらなければ。" },
         very_hungry = { "全然食べたりない！", "腹の足しにもならない。", "すぐにまた腹が鳴った。" }
      },
      effect = {
         ability = {
            deteriorates = function(_1, _2)
               return ("%sの%sは衰えた。")
                  :format(name(_1), _2)
            end,
            develops = function(_1, _2)
               return ("%sの%sは発達した。")
                  :format(name(_1), _2)
            end
         },
         sustains_growth = function(_1, _2)
            return ("%sの%sは成長期に突入した。")
               :format(name(_1), _2)
         end,
         fairy_seed = function(_1, _2)
            return ("「げふぅ」%sは%sを吐き出した。")
               :format(name(_1), _2)
         end,
         uncooked_message = { "まずいわけではないが…", "平凡な味だ。" },
         corpse = {
            alien = function(_1)
               return ("何かが%sの体内に入り込んだ。")
                  :format(name(_1))
            end,
            at = "＠を食べるなんて…",
            beetle = "力が湧いてくるようだ。",
            calm = "この肉は心を落ち着かせる効果があるようだ。",
            cat = "猫を食べるなんて！！",
            chaos_cloud = function(_1)
               return ("%sの胃は混沌で満たされた。")
                  :format(name(_1))
            end,
            cupid_of_love = function(_1)
               return ("%sは恋をしている気分になった！")
                  :format(name(_1))
            end,
            deformed_eye = "気が変になりそうな味だ。",
            ether = function(_1)
               return ("%sの体内はエーテルで満たされた。")
                  :format(name(_1))
            end,
            ghost = "精神が少しずぶとくなった。",
            giant = "体力がつきそうだ。",
            grudge = "胃の調子がおかしい…",
            guard = "ガード達はあなたを憎悪した。",
            holy_one = function(_1)
               return ("%sは神聖なものを汚した気がした。")
                  :format(name(_1))
            end,
            horse = "馬肉だ！これは精がつきそうだ。",
            imp = "魔力が鍛えられる。",
            insanity = function(_1)
               return ("%sの胃は狂気で満たされた。")
                  :format(name(_1))
            end,
            iron = function(_1)
               return ("まるで鉄のように硬い！%sの胃は悲鳴をあげた。")
                  :format(name(_1))
            end,
            lightning = function(_1)
               return ("%sの神経に電流が走った。")
                  :format(name(_1))
            end,
            mandrake = "微かな魔力の刺激を感じた。",
            poisonous = "これは有毒だ！",
            putit = "肌がつるつるになりそうだ。",
            quickling = function(_1)
               return ("ワアーォ、%sは速くなった気がする！")
                  :format(name(_1))
            end,
            rotten_one = "腐ってるなんて分かりきっていたのに…うげぇ",
            strength = "力がつきそうだ。",
            troll = "血が沸き立つようだ。",
            vesda = function(_1)
               return ("%sの体は一瞬燃え上がった。")
                  :format(name(_1))
            end
         },
         fortune_cookie = function(_1)
            return ("%sはクッキーの中のおみくじを読んだ。")
               :format(name(_1))
         end,
         herb = {
            alraunia = "ホルモンが活発化した。",
            curaria = "このハーブは活力の源だ。",
            mareilon = "魔力の向上を感じる。",
            morgia = "新たな力が湧きあがってくる。",
            spenseweed = "感覚が研ぎ澄まされるようだ。"
         },
         kagami_mochi = "これは縁起がいい！",
         human = {
            delicious = "ウマイ！",
            dislike = "これは人肉だ…うぇぇ！",
            like = "これはあなたの大好きな人肉だ！",
            would_have_rather_eaten = "人肉の方が好みだが…"
         },
         little_sister = function(_1)
            return ("%sは進化した。")
               :format(name(_1))
         end,
         poisoned = {
            dialog = { "「ギャァァ…！」", "「ブッ！」" },
            text = function(_1)
               return ("これは毒されている！%sはもがき苦しみのたうちまわった！")
                  :format(name(_1))
            end
         },
         quality = {
            bad = { "うぅ…腹を壊しそうだ。", "まずい！", "ひどい味だ！" },
            delicious = { "最高に美味しい！", "まさに絶品だ！", "天にも昇る味だ！" },
            good = { "かなりいける。", "それなりに美味しかった。" },
            great = { "美味しい！", "これはいける！", "いい味だ！" },
            so_so = { "まあまあの味だ。", "悪くない味だ。" }
         },
         raw_glum = function(_1)
            return ("%sは渋い顔をした。")
               :format(name(_1))
         end,
         rotten = "うげっ！腐ったものを食べてしまった…うわ…",
         sisters_love_fueled_lunch = function(_1)
            return ("%sの心はすこし癒された。")
               :format(name(_1))
         end,
         spiked = {
            other = { function(_1)
                  return ("%s「なんだか…変な気分なの…」")
                     :format(name(_1))
                      end, function(_1)
                  return ("%s「あれ…なにこの感じは…」")
                     :format(name(_1))
            end },
            self = "あなたは興奮した！"
         }
      },
      hunger_status = {
         hungry = { "腹がすいてきた。", "空腹になった。", "さて何を食べようか。" },
         starving = { "このままだと餓死してしまう！", "腹が減ってほとんど死にかけている。" },
         very_hungry = { "空腹で目が回りだした…", "すぐに何かを食べなくては…" }
      },
      mochi = {
         chokes = function(_1)
            return ("%sはもちを喉につまらせた！")
               :format(name(_1))
         end,
         dialog = "「むがっ」"
      },
      names = {
         elona = {
            meat = {
               _1 = function(_1)
                  return ("グロテスクな%sの肉")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("焼け焦げた%sの肉")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sのこんがり肉")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%s肉のオードブル")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("%sのピリ辛炒め")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sコロッケ")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("%sのハンバーグ")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%s肉の大葉焼き")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%sステーキ")
                     :format(_1)
               end,
               default_origin = "動物",
               uncooked_message = "生肉だ…",
            },
            vegetable = {
               _1 = function(_1)
                  return ("生ごみ同然の%s")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("悪臭を放つ%s")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sのサラダ")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%sの炒め物")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("%s風味の肉じゃが")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sの天ぷら")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("%sの煮込み")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%sシチュー")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%s風カレー")
                     :format(_1)
               end,
               default_origin = "野菜"
            },
            fruit = {
               _1 = function(_1)
                  return ("食べてはならない%s")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("べっちょりした%s")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sのフルーツサラダ")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%sのプリン")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("%sシャーベット")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sシェイク")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("%sクレープ")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%sフルーツケーキ")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%sパフェ")
                     :format(_1)
               end,
               default_origin = "果物"
            },
            sweet = {
               _1 = function(_1)
                  return ("原型を留めない%s")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("まずそうな%s")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sクッキー")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%sのゼリー")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("%sパイ")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sまんじゅう")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("%s風味のシュークリーム")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%sのケーキ")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%s風ザッハトルテ")
                     :format(_1)
               end,
               default_origin = "お菓子"
            },
            pasta = {
               _1 = function(_1)
                  return ("禁断の%s")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("のびてふにゃった%s")
                     :format(_1)
               end,
               _3 = "サラダパスタ",
               _4 = "うどん",
               _5 = "冷やし蕎麦",
               _6 = "ペペロンチーノ",
               _7 = "カルボナーラ",
               _8 = "ラーメン",
               _9 = "ミートスパゲティ",
               default_origin = "麺",
               uncooked_message = "生で食べるものじゃないな…",
            },
            fish = {
               _1 = function(_1)
                  return ("%sの残骸")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("骨だけ残った%s")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sのフライ")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%sの煮込み")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("%sスープ")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sの天ぷら")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("%sソーセージ")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%sの刺身")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%sの活け作り")
                     :format(_1)
               end,
               default_origin = "魚"
            },
            bread = {
               _1 = function(_1)
                  return ("恐怖の%s")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("ガチガチの%s")
                     :format(_1)
               end,
               _3 = "くるみパン",
               _4 = "アップルパイ",
               _5 = "サンドイッチ",
               _6 = "クロワッサン",
               _7 = "コロッケパン",
               _8 = "カレーパン",
               _9 = "メロンパン",
               default_origin = "パン",
               uncooked_quality = "粉の味がする…",
            },
            egg = {
               _1 = function(_1)
                  return ("グロテスクな%sの卵")
                     :format(_1)
               end,
               _2 = function(_1)
                  return ("焦げた%sの卵")
                     :format(_1)
               end,
               _3 = function(_1)
                  return ("%sの卵の目玉焼き")
                     :format(_1)
               end,
               _4 = function(_1)
                  return ("%s風味のキッシュ")
                     :format(_1)
               end,
               _5 = function(_1)
                  return ("半熟%s")
                     :format(_1)
               end,
               _6 = function(_1)
                  return ("%sの卵入りスープ")
                     :format(_1)
               end,
               _7 = function(_1)
                  return ("熟成%sチーズ")
                     :format(_1)
               end,
               _8 = function(_1)
                  return ("%sのレアチーズケーキ")
                     :format(_1)
               end,
               _9 = function(_1)
                  return ("%s風オムライス")
                     :format(_1)
               end,
               default_origin = "鳥"
            }
         }
      },
      not_affected_by_rotten = function(_1)
         return ("しかし、%sは何ともなかった。")
            :format(name(_1))
      end,
      passed_rotten = { "「うぐぐ！なんだこの飯は！」", "「うっ！」", "「……！！」", "「あれれ…」", "「…これは何の嫌がらせですか」", "「まずい！」" },
      spits_alien_children = function(_1)
         return ("%sは体内のエイリアンを吐き出した！")
            :format(name(_1))
      end,
      vomits = function(_1)
         return ("%sは吐いた。")
            :format(name(_1))
      end
   }
}
