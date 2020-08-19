return {
   talk = {
      ignores_you = "…(あなたを無視している)",
      is_busy = function(_1)
         return ("%sはお取り込み中だ…")
            :format(name(_1))
      end,
      is_sleeping = function(_1)
         return ("%sはぐっすり眠っている…")
            :format(name(_1))
      end,
      npc = {
         adventurer = {
            choices = {
               hire = "護衛を依頼する",
               join = "仲間に誘う"
            },
            hire = {
               choices = {
                  go_back = "やめる",
                  pay = "頼む"
               },
               cost = function(_1, _2)
                  return ("%sの剣が必要な%sそう%s、%s gold払うならば、7日間護衛を引き受け%s")
                     :format(ore(_2, 3), noka(_2, 1), dana(_2, 3), _1, ru(_2))
               end,
               you_hired = function(_1)
                  return ("%sを雇った。")
                     :format(name(_1))
               end
            },
            join = {
               accept = function(_1)
                  return ("%sとなら上手くやっていけそう%s%s")
                     :format(kimi(_1, 3), da(_1), yoro(_1, 2))
               end,
               not_known = function(_1)
                  return ("%sの仲間になれと？悪い%sお断り%s")
                     :format(kimi(_1, 3), ga(_1, 3), da(_1))
               end,
               party_full = function(_1)
                  return ("これ以上仲間を連れて行けないよう%s人数を調整してまた来て%s")
                     :format(da(_1), kure(_1))
               end,
               too_weak = function(_1)
                  return ("%sの仲間になれと？あまりにも力の差がありすぎる%s")
                     :format(kimi(_1, 3), na(_1))
               end
            }
         },
         ally = {
            abandon = {
               choices = {
                  no = "やめる",
                  yes = "切る"
               },
               prompt = function(_1)
                  return ("(%sは悲しそうな目であなたを見ている。本当に縁を切る？)")
                     :format(name(_1))
               end,
               you_abandoned = function(_1)
                  return ("%sと別れた…")
                     :format(name(_1))
               end
            },
            choices = {
               abandon = "縁を切る",
               ask_for_marriage = "婚約を申し込む",
               make_gene = "遺伝子を残す",
               silence = {
                  start = "黙らせる",
                  stop = "喋らせる"
               },
               wait_at_town = "街で待機しろ"
            },
            make_gene = {
               accepts = "いやん、あなたったら…",
               refuses = "こんな場所では嫌よ"
            },
            marriage = {
               accepts = "はい…喜んで。",
               refuses = function(_1)
                  return ("(%sはやんわりと断った)")
                     :format(name(_1))
               end
            },
            silence = {
               start = function(_1)
                  return ("(%sはしゅんとなった…)")
                     :format(name(_1))
               end,
               stop = function(_1)
                  return ("(%sはあなたに抱きついた)")
                     :format(name(_1))
               end
            },
            wait_at_town = function(_1)
               return ("(あなたは、%sに街で待っているように指示した)")
                  :format(name(_1))
            end
         },
         arena_master = {
            choices = {
               enter_duel = "試合に出る[決闘]",
               enter_rumble = "試合に出る[ランブル]",
               score = "成績を聞く"
            },
            enter = {
               cancel = function(_1)
                  return ("用があるときは声をかけて%s")
                     :format(kure(_1))
               end,
               choices = {
                  enter = "挑戦する",
                  leave = "やめる"
               },
               game_is_over = function(_1)
                  return ("残念だが、今日の試合はもう終了し%s")
                     :format(ta(_1))
               end,
               target = function(_1, _2)
                  return ("今日の対戦相手は%s%s挑戦する%s")
                     :format(_1, da(_2), noka(_2, 1))
               end,
               target_group = function(_1, _2)
                  return ("対戦相手はレベル%s以下の相手複数%s挑戦する%s")
                     :format(_1, da(_2), noka(_2, 1))
               end
            },
            streak = function(_1, _2)
               return ("現在は%s連勝中%s5連勝,20連勝毎にボーナスを与え%s")
                  :format(_1, da(_2), ru(_2))
            end
         },
         bartender = {
            call_ally = {
               brings_back = function(_1, _2)
                  return ("(バーテンが店の奥から%sを連れてきた)%s")
                     :format(name(_2), dozo(_1))
               end,
               choices = {
                  go_back = "やめる",
                  pay = "呼び戻す"
               },
               cost = function(_1, _2)
                  return ("そいつを呼び戻すには、%s gold必要%s")
                     :format(_1, da(_2))
               end,
               no_need = function(_1)
                  return ("そいつは呼び戻す必要はないよう%s")
                     :format(da(_1))
               end
            },
            choices = {
               call_ally = "仲間を呼び戻す"
            }
         },
         caravan_master = {
            choices = {
               hire = "キャラバンを雇う"
            },
            hire = {
               choices = {
                  go_back = "やめる"
               },
               tset = "つぇｔ"
            }
         },
         common = {
            choices = {
               sex = "気持ちいいことしない？",
               talk = "話がしたい",
               trade = "アイテム交換"
            },
            hand_over = function(_1)
               return ("%sを手渡した。")
                  :format(itemname(_1, 1))
            end,
            sex = {
               choices = {
                  accept = "はじめる",
                  go_back = "やめる"
               },
               prompt = function(_1)
                  return ("なかなかの体つき%sよし、買%s")
                     :format(dana(_1), u(_1, 2))
               end,
               response = "うふふ",
               start = function(_1)
                  return ("いく%s")
                     :format(yo(_1, 2))
               end
            },
            thanks = function(_1)
               return ("%s")
                  :format(thanks(_1, 2))
            end,
            you_kidding = function(_1)
               return ("冷やかし%s")
                  :format(ka(_1, 1))
            end
         },
         guard = {
            choices = {
               lost_suitcase = "落し物のカバンを届ける",
               lost_wallet = "落し物の財布を届ける",
               where_is = function(_1)
                  return ("%sの居場所を聞く")
                     :format(basename(_1))
               end
            },
            lost = {
               dialog = function(_1)
                  return ("わざわざ落し物を届けてくれた%s%sは市民の模範%s%s")
                     :format(noka(_1), kimi(_1, 3), da(_1), thanks(_1))
               end,
               empty = {
                  dialog = function(_1)
                     return ("む…中身が空っぽ%s")
                        :format(dana(_1, 2))
                  end,
                  response = "しまった…"
               },
               found_often = {
                  dialog = {
                     _0 = function(_1)
                        return ("む、また%s%s随分と頻繁に財布を見つけられるもの%s")
                           :format(kimi(_1, 3), ka(_1), dana(_1))
                     end,
                     _1 = "（…あやしい）"
                  },
                  response = "ぎくっ"
               },
               response = "当然のことだ"
            },
            where_is = {
               close = function(_1, _2, _3)
                  return ("ちょっと前に%sの方で見かけた%s")
                     :format(_1, yo(_3))
               end,
               dead = function(_1)
                  return ("奴なら今は死んでいる%s")
                     :format(yo(_1, 2))
               end,
               direction = {
                  east = "東",
                  north = "北",
                  south = "南",
                  west = "西"
               },
               far = function(_1, _2, _3)
                  return ("%sに会いたいのなら、%sにかなり歩く必要があ%s")
                     :format(basename(_2), _1, ru(_3))
               end,
               moderate = function(_1, _2)
                  return ("%sなら%sの方角を探してごらん。")
                     :format(basename(_2), _1)
               end,
               very_close = function(_1, _2, _3)
                  return ("%sならすぐ近くにいる%s%sの方を向いてごらん。")
                     :format(basename(_2), yo(_3), _1)
               end,
               very_far = function(_1, _2, _3)
                  return ("%s%s、ここから%sの物凄く離れた場所にいるはず%s")
                     :format(basename(_2), ka(_3, 3), _1, da(_3))
               end
            }
         },
         healer = {
            choices = {
               restore_attributes = "能力の復元"
            },
            restore_attributes = function(_1)
               return ("治療が完了し%s")
                  :format(ta(_1))
            end
         },
         horse_master = {
            choices = {
               buy = "馬を買う"
            }
         },
         informer = {
            choices = {
               investigate_ally = "仲間の調査",
               show_adventurers = "冒険者の情報"
            },
            investigate_ally = {
               choices = {
                  go_back = "やめる",
                  pay = "調査する"
               },
               cost = function(_1)
                  return ("10000 goldかかるけどいい%s")
                     :format(ka(_1, 1))
               end
            },
            show_adventurers = function(_1)
               return ("お目当ての情報は見つかった%s")
                  :format(kana(_1))
            end
         },
         innkeeper = {
            choices = {
               eat = "食事をとる",
               go_to_shelter = "シェルターに入る"
            },
            eat = {
               here_you_are = function(_1)
                  return ("%s")
                     :format(dozo(_1))
               end,
               not_hungry = function(_1)
                  return ("腹が減っているようにはみえない%s")
                     :format(yo(_1))
               end,
               results = { "なかなか美味しかった。", "悪くない。", "あなたは舌鼓をうった。" }
            },
            go_to_shelter = function(_1)
               return ("悪天候時はシェルターを無料で開放している%sすみやかに避難して%s")
                  :format(nda(_1), kure(_1))
            end
         },
         maid = {
            choices = {
               do_not_meet = "追い返す",
               meet_guest = "客に会う",
               think_of_house_name = "家の名前を考えてくれ"
            },
            do_not_meet = function(_1)
               return ("追い返す%s")
                  :format(yo(_1))
            end,
            think_of_house_name = {
               come_up_with = function(_1, _2)
                  return ("そう%sこれからこの家の名前は%s%s")
                     :format(dana(_2), _1, da(_2))
               end,
               suffixes = { function(_1)
                     return ("%sの家")
                        :format(_1)
                            end, function(_1)
                     return ("%s邸")
                        :format(_1)
                                 end, function(_1)
                     return ("%s城")
                        :format(_1)
                                      end, function(_1)
                     return ("%sハーレム")
                        :format(_1)
                                           end, function(_1)
                     return ("%sの巣窟")
                        :format(_1)
                                                end, function(_1)
                     return ("%sハウス")
                        :format(_1)
                                                     end, function(_1)
                     return ("%sホーム")
                        :format(_1)
                                                          end, function(_1)
                     return ("%sの住処")
                        :format(_1)
                                                               end, function(_1)
                     return ("%s宅")
                        :format(_1)
                                                                    end, function(_1)
                     return ("%sの隠れ家")
                        :format(_1)
                                                                         end, function(_1)
                     return ("%sドーム")
                        :format(_1)
               end }
            }
         },
         moyer = {
            choices = {
               sell_paels_mom = "パエルの母を売る"
            },
            sell_paels_mom = {
               choices = {
                  go_back = "やめる",
                  sell = "売る"
               },
               prompt = "ほほう、モンスターの顔をした人間か。見世物としてなかなかいけそうだ。金貨50000枚で買い取ろう。",
               you_sell = "パエルの母親を売った…"
            }
         },
         pet_arena_master = {
            choices = {
               register_duel = "ペットデュエル",
               register_team = "チームバトル"
            },
            register = {
               choices = {
                  enter = "挑戦する",
                  leave = "やめる"
               },
               target = function(_1, _2)
                  return ("一対一の戦いで、対戦相手はレベル%sぐらいの相手%s挑戦する%s")
                     :format(_1, da(_2), noka(_2, 1))
               end,
               target_group = function(_1, _2, _3)
                  return ("人同士のチームバトルで、対戦相手はレベル%s以下の相手複数%s挑戦する%s")
                     :format(_2, da(_3), noka(_3, 1))
               end
            }
         },
         prostitute = {
            buy = function(_1, _2)
               return ("そう%s金貨%s枚を前払いで%s")
                  :format(dana(_2), _1, kure(_2))
            end,
            choices = {
               buy = "暗い場所に移ろう"
            }
         },
         quest_giver = {
            about = {
               backpack_full = function(_1)
                  return ("どうやらバックパックが一杯のよう%s持ち物を整理してまた来て%s")
                     :format(da(_1), kure(_1))
               end,
               choices = {
                  leave = "やめる",
                  take = "受諾する"
               },
               during = function(_1)
                  return ("頼んでいた依頼は順調%s")
                     :format(kana(_1, 1))
               end,
               here_is_package = function(_1)
                  return ("これが依頼の品物%s期限には十分気をつけて%s")
                     :format(da(_1), kure(_1))
               end,
               party_full = function(_1)
                  return ("これ以上仲間を連れて行けないよう%s人数を調整してまた来て%s")
                     :format(da(_1), kure(_1))
               end,
               thanks = function(_1)
                  return ("%s期待してい%s")
                     :format(thanks(_1), ru(_1))
               end,
               too_many_unfinished = function(_1)
                  return ("未完了の依頼が多すぎじゃない%sこの仕事は、安心してまかせられない%s")
                     :format(kana(_1, 1), yo(_1))
               end
            },
            accept = {
               harvest = function(_1)
                  return ("畑までは案内するから、しっかりと期限内に作物を納入して%s")
                     :format(kure(_1))
               end,
               hunt = function(_1)
                  return ("では、早速案内するので、モンスターを一匹残らず退治して%s")
                     :format(kure(_1))
               end,
               party = function(_1)
                  return ("ついて来て%sパーティー会場まで案内する%s")
                     :format(kure(_1), yo(_1))
               end
            },
            choices = {
               about_the_work = "依頼について",
               here_is_delivery = "配達物を渡す",
               here_is_item = function(_1)
                  return ("%sを納入する")
                     :format(itemname(_1, 1))
               end
            },
            finish = {
               escort = function(_1)
                  return ("無事に到着できてほっとした%s%s")
                     :format(yo(_1), thanks(_1, 2))
               end
            }
         },
         servant = {
            choices = {
               fire = "解雇する"
            },
            fire = {
               choices = {
                  no = "やめる",
                  yes = "切る"
               },
               prompt = function(_1)
                  return ("(%sは悲しそうな目であなたを見ている。本当に縁を切る？)")
                     :format(name(_1))
               end,
               you_dismiss = function(_1)
                  return ("%sを解雇した… ")
                     :format(name(_1))
               end
            }
         },
         shop = {
            ammo = {
               choices = {
                  go_back = "やめる",
                  pay = "頼む"
               },
               cost = function(_1, _2)
                  return ("そう%s、全ての矢弾を補充すると%s gold%s")
                     :format(dana(_2, 3), _1, da(_2))
               end,
               no_ammo = function(_1)
                  return ("充填する必要はないみたい%s")
                     :format(da(_1))
               end
            },
            attack = {
               choices = {
                  attack = "神に祈れ",
                  go_back = "いや、冗談です"
               },
               dialog = function(_1)
                  return ("%s")
                     :format(rob(_1, 2))
               end
            },
            choices = {
               ammo = "矢弾の充填",
               attack = "襲撃するよ",
               buy = "買いたい",
               invest = "投資したい",
               sell = "売りたい"
            },
            criminal = {
               buy = function(_1)
                  return ("犯罪者に売る物はない%s")
                     :format(yo(_1))
               end,
               sell = function(_1)
                  return ("犯罪者から買う物はない%s")
                     :format(yo(_1))
               end
            },
            invest = {
               ask = function(_1, _2)
                  return ("投資をしてくれる%s%s goldかかるけどいいの%s")
                     :format(noka(_2, 1), _1, kana(_2, 1))
               end,
               choices = {
                  invest = "投資する",
                  reject = "やめる"
               }
            }
         },
         sister = {
            buy_indulgence = {
               choices = {
                  buy = "買う",
                  go_back = "やめる"
               },
               cost = function(_1, _2)
                  return ("免罪符を希望する%s%s goldかかるけどいいの%s")
                     :format(noka(_2, 1), _1, kana(_2, 1))
               end,
               karma_is_not_low = "その程度の罪なら自分でなんとかしなさい。"
            },
            choices = {
               buy_indulgence = "免罪符を買いたい"
            }
         },
         slave_trader = {
            buy = {
               choices = {
                  go_back = "やめる",
                  pay = "買い取る"
               },
               cost = function(_1, _2, _3)
                  return ("そう%s%sを%s goldでどう%s")
                     :format(dana(_3), _1, _2, da(_3, 1))
               end,
               you_buy = function(_1)
                  return ("%sを買い取った。")
                     :format(_1)
               end
            },
            choices = {
               buy = "奴隷を買う",
               sell = "奴隷を売る"
            },
            sell = {
               choices = {
                  deal = "売る",
                  go_back = "やめる"
               },
               price = function(_1, _2)
                  return ("なかなかの身体つき%s%s goldでどう%s")
                     :format(dana(_2), _1, da(_2, 1))
               end,
               you_sell_off = function(_1)
                  return ("%sを売り飛ばした。")
                     :format(_1)
               end
            }
         },
         spell_writer = {
            choices = {
               reserve = "魔法書の予約"
            }
         },
         trainer = {
            choices = {
               go_back = "やめる",
               learn = {
                  accept = "習得する",
                  ask = "新しい能力を覚えたい"
               },
               train = {
                  accept = "訓練する",
                  ask = "訓練したい"
               }
            },
            cost = {
               learning = function(_1, _2, _3)
                  return ("%sの能力を習得するには%s platかかるけどいい%s")
                     :format(_1, _2, kana(_3, 1))
               end,
               training = function(_1, _2, _3)
                  return ("%sの能力を訓練するには%s platかかるけどいい%s")
                     :format(_1, _2, kana(_3, 1))
               end
            },
            finish = {
               learning = function(_1)
                  return ("可能な限りの知識は教え%s後は存分に訓練して%s")
                     :format(ta(_1), kure(_1))
               end,
               training = function(_1)
                  return ("訓練は完了し%s潜在能力が伸びているはずなので、後は自分で鍛えて%s")
                     :format(ta(_1), kure(_1))
               end
            },
            leave = function(_1)
               return ("訓練が必要なときは、声をかけて%s")
                  :format(kure(_1))
            end
         },
         wizard = {
            choices = {
               identify = "鑑定したい",
               identify_all = "全て鑑定してほしい",
               investigate = "調査したい",
               ["return"] = "帰還したい"
            },
            identify = {
               already = function(_1)
                  return ("鑑定するアイテムはないみたい%s")
                     :format(da(_1))
               end,
               count = function(_1, _2)
                  return ("%s個の未判明のアイテムのうち、%s個のアイテムが完全に判明した。")
                     :format(_2, _1)
               end,
               finished = function(_1)
                  return ("鑑定結果はこの通り%s")
                     :format(da(_1))
               end,
               need_investigate = function(_1)
                  return ("さらなる知識を求めるのなら、調査する必要が%s")
                     :format(aru(_1))
               end
            },
            ["return"] = function(_1)
               return ("ここからふもとに下りるのは不便だから、ボランティアで帰還サービスをやってい%s%sも帰還サービスを希望%s")
                  :format(ru(_1), kimi(_1, 3), kana(_1))
            end
         }
      },
      will_not_listen = function(_1)
         return ("%sは耳を貸さない。")
            :format(name(_1))
      end,
      window = {
         attract = "興味",
         fame = function(_1)
            return ("名声 %s")
               :format(_1)
         end,
         impress = "友好",
         of = function(_1, _2)
            return ("%s %s")
               :format(_2, _1)
         end,
         shop_rank = function(_1)
            return ("店の規模:%s")
               :format(_1)
         end
      }
   }
}
