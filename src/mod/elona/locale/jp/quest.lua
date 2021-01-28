local quest = {
   cook = {
      food_type = {
         elona = {
            meat = {
               _1 = {
                  title = "肉！",
                  desc = function(player, speaker, params)
                     return ("どうしようもなく肉が食べたい%s！そう%s、料理は%sがいい%s。報酬は%s%s！")
                        :format(noda(speaker, 4), dana(speaker, 4), params.objective, na(speaker, 4), params.reward, da(speaker, 4))
                  end,
               },
               _2 = {
                  title = "おもてなし",
                  desc = function(player, speaker, params)
                     return ("今日は大事な人と会う予定%s。肉料理をふるまいたいので、%sを料理して%s。%sを払%s。")
                        :format(da(speaker, 4), params.objective, kure(speaker, 4), params.reward, u(speaker, 4))
                  end
               },
            },
            vegetable = {
               _1 = {
                  title = "ダイエット食",
                  desc = function(player, speaker, params)
                     return ("野菜がダイエットにいいのは常識%s。%sを料理して来て%s。代金は%s%s。")
                        :format(dana(speaker, 4), params.objective, kure(speaker, 4), params.reward, da(speaker, 4))
                  end,
               },
               _2 = {
                  title = "好き嫌いの改善",
                  desc = function(player, speaker, params)
                     return ("%sが依頼の報酬%s。子供がどうしても野菜を食べないので困ってい%s！%sなら食べるかも知れないので料理してきて%s。")
                        :format(params.reward, da(speaker, 4), ru(speaker, 4), params.objective, kure(speaker, 4))
                  end
               },
            },
            fruit = {
               _1 = {
                  title = "ディナーのデザート",
                  desc = function(player, speaker, params)
                     return ("報酬は%sで十分%s？今晩のディナーのデザートに%sが食べたくなったので、配達をお願いする%s。")
                        :format(params.reward, kana(speaker, 4), params.objective, yo(speaker, 4))
                  end,
               },
               _2 = {
                  title = "フルーツ料理",
                  desc = function(player, speaker, params)
                     return ("パーティーでフルーツ料理をふるまいたい%s。%sを用意してくれれば、%sを払%s。")
                        :format(noda(speaker, 4), params.objective, params.reward, u(speaker, 4))
                  end
               }
            },
            sweet = {
               _1 = {
                  title = "甘党のお好み",
                  desc = function(player, speaker, params)
                     return ("甘〜いお菓子を食べたい%s！%sと引き換えに%sをあげ%s。")
                        :format(noda(speaker, 4), params.objective, params.reward, ru(speaker, 4))
                  end,
               },
               _2 = {
                  title = "子供のおやつ",
                  desc = function(player, speaker, params)
                     return ("子供のおやつに%sを出そうと思っている%s。持ってきてくれれば、%sを払%s。")
                        :format(params.objective, noda(speaker, 4), params.reward, u(speaker, 4))
                  end
               }
            },
            pasta = {
               _1 = {
                  title = "麺マニア",
                  desc = function(player, speaker, params)
                     return ("報酬は%s%s。パスター、ラーメン、蕎麦…麺類をこよなく愛する%sに%sを食べさせて%s！")
                        :format(params.reward, da(speaker, 4), ore(speaker, 4), params.objective, kure(speaker, 4))
                  end,
               },
               _2 = {
                  title = "喉ごしがたまらない",
                  desc = function(player, speaker, params)
                     return ("つるんと食べられる%sを食べたい%s。%sを払うので、配達して%s。")
                        :format(params.objective, na(speaker, 4), params.reward, kure(speaker, 4))
                  end
               }
            },
            fish = {
               _1 = {
                  title = "健康食を",
                  desc = function(player, speaker, params)
                     return ("魚は身体に非常に良いそう%s。%sを料理して納入してくれるなら、%sを払%s。")
                        :format(da(speaker, 4), params.objective, params.reward, u(speaker, 4))
                  end,
               },
               _2 = {
                  title = "魚を食べさせたい",
                  desc = function(player, speaker, params)
                     return ("子供に魚を食べさせたいのだ%s、好き嫌いが激しくなかなか食べない%s。%sなら食べられるかもしないので、料理を依頼したい%s。報酬は%sでどう%s？")
                        :format(ga(speaker, 4), noda(speaker, 4), params.objective, noda(speaker, 4), params.reward, kana(speaker, 4))
                  end
               }
            },
            bread = {
               _1 = {
                  title = "パン党",
                  desc = function(player, speaker, params)
                     return ("%sはパン党？それともご飯党%s？%sは断然パンがいい%s。%sと引き換えに%sを料理して%s。")
                        :format(kimi(speaker, 4), kana(speaker, 4), ore(speaker, 4), na(speaker, 4), params.reward, params.objective, kure(speaker, 4))
                  end,
               },
               _2 = {
                  title = "ピクニックのお供",
                  desc = function(player, speaker, params)
                     return ("報酬は%s、これ以上は出せない%s。明日のピクニックに%sを持って行きたいので、よろしく%s！")
                        :format(params.reward, yo(speaker, 4), params.objective, tanomu(speaker, 4))
                  end
               }
            },
            egg = {
               _1 = {
                  title = "料理家の野望",
                  desc = function(player, speaker, params)
                     return ("新しい料理を研究している%s。参考にする料理として、%sと引き換えに、%sを持ってきて%s。")
                        :format(noda(speaker, 4), params.reward, params.objective, kure(speaker, 4))
                  end,
               },
               _2 = {
                  title = "美味しいものが食べたい",
                  desc = function(player, speaker, params)
                     return ("%sが食べたくなった%s。料理を届けてくれれば、報酬として%sを払%s。")
                        :format(params.objective, yo(speaker, 4), params.reward, u(speaker, 4))
                  end
               },
            }
         },
      },
      general = {
         _1 = {
            title = "料理家の野望",
            desc = function(player, speaker, params)
               return ("新しい料理を研究している%s。参考にする料理として、%sと引き換えに、%sを持ってきて%s。")
                  :format(noda(speaker, 4), params.reward, params.objective, kure(speaker, 4))
            end,
         },
         _2 = {
            title = "美味しいものが食べたい",
            desc = function(player, speaker, params)
               return ("%sが食べたくなった%s。料理を届けてくれれば、報酬として%sを払%s。")
                  :format(params.objective, yo(speaker, 4), params.reward, u(speaker, 4))
            end
         }
      }
   },
   collect = {
      _1 = {
         title = "物凄く欲しい物",
         desc = function(player, speaker, params)
            return ("%sが、最近やたらと%sを見せびらかして自慢してくる%s。%sもたまらなく%sが欲しい%s！どうにかしてブツを手に入れてくれれば、%sを払%s。手段はもちろん問わない%s。")
               :format(params.target_name, params.item_name, noda(speaker, 4), ore(speaker, 4), params.item_name, yo(speaker, 4), params.reward, u(speaker, 4), yo(speaker, 4))
         end,
      },
      _2 = {
         title = "狙った獲物",
         desc = function(player, speaker, params)
            return ("%sが%sを所持しているのは知っている%s？わけあって、どうしてもこの品物が必要なの%s。うまく取り合って入手してくれれば、%sを払%s。")
               :format(params.target_name, params.item_name, kana(speaker, 4), da(speaker, 4), params.reward, u(speaker, 4))
         end
      },
   },
   conquer = {
      _1 = {
         title = "討伐の依頼",
         desc = function(player, speaker, params)
            return ("熟練の冒険者にだけ頼める依頼%s。%sの変種が街に向かっているのが確認された%s。討伐すれば報酬に%sを与え%s。これは平凡な依頼ではない%s。この怪物の強さは、少なくともレベル%sは下らない%s。")
               :format(da(speaker, 4), params.objective, noda(speaker, 4), params.reward, ru(speaker, 4), yo(speaker, 4), params.enemy_level, daro(speaker, 4))
         end,
      },
      _2 = {
         title = "助けて！",
         desc = function(player, speaker, params)
            return ("ふざけて友人に変異のポーションを飲ませたら、%sになってしまった%s！レベル%sはあるモンスター%s！街の平和のためにも一刻もはやく始末して%s！お礼%s？もちろん、%sを用意し%s。%s！")
               :format(params.objective, yo(speaker, 4), params.enemy_level, da(speaker, 4), kure(speaker, 4), ka(speaker, 4), params.reward, ta(speaker, 4), tanomu(speaker, 4))
         end,
      },
      _3 = {
         title = "特務指令",
         desc = function(player, speaker, params)
            return ("脅威の芽はなるべく早く摘み取らなければならない%s。この街の中で、軍の実験体が檻から出て暴れている%s。%sを払うので討伐して%s。研究データによると、この%sはレベル%sのモンスターに匹敵する強さらしい%s。気をつけてかかって%s。")
               :format(na(speaker, 4), noda(speaker, 4), params.reward, kure(speaker, 4), params.objective, params.enemy_level, yo(speaker, 4), kure(speaker, 4))
         end
      }
   },
   escort = {
      difficulty = {
         _0 = {
            _1 = {
               title = "使者の護衛",
               desc = function(player, speaker, params)
                  return ("あまり大きな声ではいえない%s、重要な使者を%sまで無事届ける必要が%s。報酬は%s%s。%sの首がかかってい%s。絶対にしくじらないで%s！")
                     :format(ga(speaker, 4), params.map, aru(speaker, 4), params.reward, da(speaker, 4), ore(speaker, 4), ru(speaker, 4), kure(speaker, 4))
               end,
            },
            _2 = {
               title = "美しすぎる人",
               desc = function(player, speaker, params)
                  return ("美しすぎるのも罪なもの%s。%sの恋人が、以前交際を断った変質者に狙われて困っている%s。危険な旅になるだろう%s、%sと引き換えに、%sまで無事に護衛して%s。")
                     :format(dana(speaker, 4), ore(speaker, 4), noda(speaker, 4), ga(speaker, 4), params.reward, params.map, kure(speaker, 4))
               end,
            },
            _3 = {
               title = "暗殺を防げ",
               desc = function(player, speaker, params)
                  return ("あの方が、命を狙われているのは知っている%s？これは危険な依頼%s。%sに到着するまで護衛を全うしてくれれば、報酬に%sを出す%s。")
                     :format(daro(speaker, 4), da(speaker, 4), params.map, params.reward, yo(speaker, 4))
               end
            },
         },
         _1 = {
            _1 = {
               title = "急ぎの護衛",
               desc = function(player, speaker, params)
                  return ("とにかく大至急%sまで送ってもらいたい人がいる%s。報酬は%s。くれぐれも期限を過ぎないよう注意して%s。")
                     :format(params.map, noda(speaker, 4), params.reward, kure(speaker, 4))
               end,
            },
            _2 = {
               title = "死ぬ前に一度だけ",
               desc = function(player, speaker, params)
                  return ("言わなくてもわかっているん%s？そう、%sの最愛の人がもうすぐ病気で死んでしまう%s。%sに、最後に思い出の街%sに連れて行ってやりたい%s！%sで引き受けて%s。")
                     :format(daro(speaker, 4), ore(speaker, 4), noda(speaker, 4), params.map, params.map, noda(speaker, 4), params.reward, kure(speaker, 4))
               end,
            },
            _3 = {
               title = "手遅れにならないうちに",
               desc = function(player, speaker, params)
                  return ("大変%s！%sの親父がもの凄い猛毒に犯されてしまった%s！%s、%sに住むといわれる名医まで、大至急連れて行って%s！%sの全財産ともいうべき%sを謝礼に用意して%s！")
                     :format(da(speaker, 4), ore(speaker, 4), noda(speaker, 4), tanomu(speaker, 4), params.map, kure(speaker, 4), ore(speaker, 4), params.reward, aru(speaker, 4))
               end
            },
         },
         _2 = {
            _1 = {
               title = "護衛求む！",
               desc = function(player, speaker, params)
                  return ("わけあって%sまで護衛して欲しいという方がいる%s。特に狙われるようなこともないと思う%s、成功すれば%sを払う%s。冒険者にとっては、簡単な依頼%s？")
                     :format(params.map, noda(speaker, 4), ga(speaker, 4), params.reward, yo(speaker, 4), dana(speaker, 4))
               end,
            },
            _2 = {
               title = "観光客の案内",
               desc = function(player, speaker, params)
                  return ("何だか変な観光客に付きまとわれて、困っている%s！手間賃として%sを払うから、やっこさんを%sあたりまで案内してやって%s。")
                     :format(noda(speaker, 4), params.reward, params.map, kure(speaker, 4))
               end,
            },
            _3 = {
               title = "簡単な護衛",
               desc = function(player, speaker, params)
                  return ("%sの大の仲良しの親戚が%sに行きたがってい%s。生憎今は手を離せないので、期限内に無事送ってもらえれば、お礼に%sを払う%s。")
                     :format(ore(speaker, 4), params.map, ru(speaker, 4), params.reward, yo(speaker, 4))
               end
            },
         }
      }
   },
   harvest = {
      _1 = {
         title = "農作業の手伝い",
         desc = function(player, speaker, params)
            return ("そろそろ畑に植えた作物も育っている頃%s。%s付近にある畑まで行って、%sほどの作物を掘ってきて%s。報酬は%sを払%s。")
               :format(da(speaker, 4), params.map, params.required_weight, kure(speaker, 4), params.reward, u(speaker, 4))
         end,
      },
      _2 = {
         title = "代わりに収穫して",
         desc = function(player, speaker, params)
            return ("この時期になると、なんだか気が重くなる%s。畑に育った作物を、どっさりと掘らなきゃならない%s。%sを払うから、代わりに%sぐらいの量を収穫して来てくれない%s！")
               :format(yo(speaker, 4), noda(speaker, 4), params.reward, params.required_weight, kana(speaker, 4))
         end,
      },
      _3 = {
         title = "収穫期",
         desc = function(player, speaker, params)
            return ("いよいよ待ちに待った収穫期の到来%s！とてもじゃないが一人では無理なので、%sで手伝ってもらえない%s？そう%s、%sの担当は重さにして%sほど%s。")
               :format(da(speaker, 4), params.reward, kana(speaker, 4), dana(speaker, 4), kimi(speaker, 4), params.required_weight, da(speaker, 4))
         end
      },
   },
   hunt = {
      _1 = {
         title = "森の清浄化",
         desc = function(player, speaker, params)
            return ("森が危険になってい%s。近辺の森にモンスターが発生したよう%s。%sを出すので、誰か退治して%s。")
               :format(ru(speaker, 4), da(speaker, 4), params.reward, kure(speaker, 4))
         end,

      },
      _2 = {
         title = "魔物退治",
         desc = function(player, speaker, params)
            return ("%sを報酬として払%s。ある場所の魔物どもを退治してもらいたい%s。")
               :format(params.reward, u(speaker, 4), noda(speaker, 4))
         end,
      },
      _3 = {
         title = "家の周りのモンスター",
         desc = function(player, speaker, params)
            return ("自宅の近辺にモンスターが出没して困っている%s。退治してくれるなら、報酬として%sを払%s。")
               :format(noda(speaker, 4), params.reward, u(speaker, 4))
         end
      }
   },
   huntex = {
      _1 = {
         title = "街の危機",
         desc = function(player, speaker, params)
            return ("もう噂を耳にしたかもしれない%s、%sの亜種レベル%s相当が街の各地に出没してい%s。このままでは%sたちの平和も長くは続かない%s。%s、奴らを退治して%s。街を代表して報酬に%sを用意し%s。")
               :format(ga(speaker, 4), params.objective, params.enemy_level, ru(speaker, 4), ore(speaker, 4), daro(speaker, 4), tanomu(speaker, 4), kure(speaker, 4), params.reward, ta(speaker, 4))
         end,
      },
      _2 = {
         desc = function(player, speaker, params)
            return ("井戸の呪い:どこかの馬鹿が井戸におかしな液体を混ぜやがった%s！おかげで街の中を変異したレベル%s相当の%sが徘徊してい%s。役所に頼んで、なんとか報酬の%sは集めた%s。早くなんとかして%s！")
               :format(yo(speaker, 4), params.enemy_level, params.objective, ru(speaker, 4), params.reward, yo(speaker, 4), kure(speaker, 4))
         end,

      },
      _3 = {
         title = "エーテル変異体",
         desc = function(player, speaker, params)
            return ("大変%s！大変%s！%sの隣の家の一家全員が、エーテル病で%sに変異してしまった%s！見たところ、強さはレベル%sぐらいじゃない%s？ともかく、すぐに退治して%s。報酬は%s払%s。")
               :format(da(speaker, 4), da(speaker, 4), ore(speaker, 4), params.objective, noda(speaker, 4), params.enemy_level, kana(speaker, 4), kure(speaker, 4), params.reward, u(speaker, 4))
         end,
      }
   },
   party = {
      _1 = {
         title = "ベイベー！",
         desc = function(player, speaker, params)
            return ("ベイベーのってる%s！イェーイ、%sは凄くハイテンション%s！%sも%sのパーティーに来て%s。報酬？そんな野暮なものはない%s！%s！芸で%s記録すればプラチナコインをプレゼントする%s！イェーイ！")
               :format(kana(speaker, 4), ore(speaker, 4), da(speaker, 4), kimi(speaker, 4), ore(speaker, 4), kure(speaker, 4), yo(speaker, 4), ga(speaker, 4), params.required_points, yo(speaker, 4))
         end,
      },
      _2 = {
         title = "セレブパーティー",
         desc = function(player, speaker, params)
            return ("%sの名前を知らない？世間知らずの人間もいるもの%s。%sは泣く子も黙るトップセレブなの%s。近く開くパーティーの席で客を楽しませてくれる芸人を募集中%s。%sのパフォーマンスを出せたら、プラチナコインを払%s。")
               :format(ore(speaker, 4), da(speaker, 4), ore(speaker, 4), da(speaker, 4), da(speaker, 4), params.required_points, u(speaker, 4))
         end,
      },
      _3 = {
         title = "代替芸人募集",
         desc = function(player, speaker, params)
            return ("ああ、だれか%s、%sの代わりにパーティーで芸を披露して%s。聴衆の反応が怖くてとても舞台にあがれない%s！どうにか%s得点を稼いでくれれば、お礼にプラチナコインをあげ%s。")
               :format(tanomu(speaker, 4), ore(speaker, 4), kure(speaker, 4), noda(speaker, 4), params.required_points, ru(speaker, 4))
         end
      }
   },
   supply = {
      _1 = {
         title = "恋人への贈り物",
         desc = function(player, speaker, params)
            return ("恋人へのプレゼントはなにがいい%s？とりあえず報酬に%sを払うので、%sを調達してきて%s。")
               :format(kana(speaker, 4), params.reward, params.objective, kure(speaker, 4))
         end,
      },
      _2 = {
         title = "自分へのプレゼント",
         desc = function(player, speaker, params)
            return ("最近ちょっといいことがあったので、自分に%sをプレゼントしたい%s。報酬は、%sでどう%s？")
               :format(params.objective, noda(speaker, 4), params.reward, kana(speaker, 4))
         end,
      },
      _3 = {
         title = "子供の誕生日",
         desc = function(player, speaker, params)
            return ("報酬は%sぐらいが妥当%s。子供の誕生日プレゼントに%sがいる%s。")
               :format(params.reward, kana(speaker, 4), params.objective, noda(speaker, 4))
         end,
      },
      _4 = {
         title = "研究の素材",
         desc = function(player, speaker, params)
            return ("%sの研究をしてい%s。研究用のストックが尽きたので、%sで調達して来てもらえない%s？")
               :format(params.objective, ru(speaker, 4), params.reward, kana(speaker, 4))
         end,
      },
      _5 = {
         title = "コレクターの要望",
         desc = function(player, speaker, params)
            return ("%sのコレクションに%sが必要%s。どうか%sの報酬で依頼を受けて%s！")
               :format(ore(speaker, 4), params.objective, da(speaker, 4), params.reward, kure(speaker, 4))
         end,
      },
      _6 = {
         title = "アイテムの納入",
         desc = function(player, speaker, params)
            return ("ちょっとした用事で、%sが必要になった%s。期限内に納入してくれれば%sを払%s。")
               :format(params.objective, noda(speaker, 4), params.reward, u(speaker, 4))
         end
      },
   },
   deliver = {
      elona = {
         spellbook = {
            _1 = {
               title = "見習い魔術師の要望",
               desc = function(player, speaker, params)
                  return ("%sの%sという者が、魔法を勉強しているそう%s。%sを無事届けてくれれば、報酬として%sを払%s。")
                     :format(params.map, params.target_name, da(speaker, 4), params.item_name, params.reward, u(speaker, 4))
               end,
            },
            _2 = {
               title = "本の返却",
               desc = function(player, speaker, params)
                  return ("%sという%sに住む知り合いに、借りていた%sを届けてくれない%s。報酬は%s%s。")
                     :format(params.target_name, params.map, params.item_name, kana(speaker, 4), params.reward, da(speaker, 4))
               end,
            },
            _3 = {
               title = "珍しい本の配送",
               desc = function(player, speaker, params)
                  return ("%sという本が最近手に入ったので、前から欲しがっていた%sにプレゼントしたい。%sを手間賃として払うので、%sまで行って届けてくれない%s？")
                     :format(params.item_name, params.target_name, params.reward, params.map, kana(speaker, 4))
               end
            }
         },
         furniture = {
            _1 = {
               title = "家具の配達",
               desc = function(player, speaker, params)
                  return ("%sを配達して%s。期限内に無事に届ければ、配達先で報酬の%sを払%s。")
                     :format(params.item_name, kure(speaker, 4), params.reward, u(speaker, 4))
               end,
            },
            _2 = {
               title = "お祝いの品",
               desc =function(player, speaker, params)
                  return ("友達の%sが%sに家を建てたので、お祝いに%sをプレゼントしようと思%s。%sで届けてくれない%s？")
                     :format(params.target_name, params.map, params.item_name, u(speaker, 4), params.reward, kana(speaker, 4))
               end
            }
         },
         junk = {
            _1 = {
               title = "珍品の配達",
               desc = function(player, speaker, params)
                  return ("配達の依頼%s。なんに使うのか知らない%s、%sが%sを買い取りたいそう%s。%sまで配達すれば%sを払%s。")
                     :format(da(speaker, 4), ga(speaker, 4), params.target_name, params.item_name, da(speaker, 4), params.map, params.reward, u(speaker, 4))
               end,
            },
            _2 = {
               title = "廃品回収",
               desc = function(player, speaker, params)
                  return ("知っていた%s。%sに住む%sが廃品を回収しているらしい%s。%sを送ろうと思うが、面倒なので%sの手間賃で代わりに持っていって%s。")
                     :format(kana(speaker, 4), params.map, params.target_name, yo(speaker, 4), params.item_name, params.reward, kure(speaker, 4))
               end
            }
         },
         ore = {
            _1 = {
               title = "鉱石収集家に届け物",
               desc = function(player, speaker, params)
                  return ("%sに%sという鉱石収集家がいる%s。この%sを届けてもらえない%s。報酬は%s%s。")
                     :format(params.map, params.target_name, noda(speaker, 4), params.item_name, kana(speaker, 4), params.reward, da(speaker, 4))
               end,
            },
            _2 = {
               title = "石材の配送",
               desc = function(player, speaker, params)
                  return ("%sで、%sを素材に、彫刻コンテストが開かれるそう%s。責任者の%sまで、材料を届けてくれる人を探している%s。お礼には%sを用意してい%s。")
                     :format(params.map, params.item_name, da(speaker, 4), params.target_name, noda(speaker, 4), params.reward, ru(speaker, 4))
               end
            },
            _3 = {
               title = "鉱石のプレゼント",
               desc = function(player, speaker, params)
                  return ("長年の友好の証として、%sに%sを送ろうと思ってい%s。%sで%sまで運んでもらえない%s？")
                     :format(params.target_name, params.item_name, ru(speaker, 4), params.reward, params.map, kana(speaker, 4))
               end
            }
         },
      },
   }
}

return {
   quest = {
      types = {
         elona = quest
      },
      reward = {
         elona = {
            wear = "装備品",
            magic = "魔道具",
            armor = "防具",
            weapon = "武器",
            supply = "補給品"
         }
      }
   },
}
