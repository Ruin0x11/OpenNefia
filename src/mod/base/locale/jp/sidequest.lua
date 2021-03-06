return {
   sidequest = {
      journal = {
         title = "[サブクエスト]",
         done = "[達成]",
      },
      _ = {
         elona = {
            ambitious_scientist = {
               progress = {
                  _0 = function(_1)
                     return ("カプールのイコールに、実験用の生物5体の捕獲を頼まれた。依頼品、モンスターボールに捕獲したものでなくてはならない。あと%s個の捕獲済みモンスターボールを届ける必要がある。")
                        :format(_1)
                  end
               },
               name = "生化学者の野望 Lv5相当"
            },
            cat_house = {
               progress = {
                  _0 = "ヨウィンのタムに、家の猫退治を依頼された。家は南の畑のあたりにあるそうだ。",
                  _1 = "タムの家の中の猫を退治した。あとはヨウィンでタムに報告するだけだ。"
               },
               name = "猫退治 Lv25相当"
            },
            defense_line = {
               progress = {
                  _0 = "ヨウィンのギルバート大佐に、ジューア解放軍の援護を求められた。準備が整い次第、大佐に話し掛けよう。",
                  _1 = "イェルスの防衛軍を殲滅しなければならない。",
                  _2 = "防衛線を見事に突破した。ヨウィンのギルバート大佐に報告しよう。"
               },
               name = "防衛戦線の死闘 Lv17相当"
            },
            joining_fighters_guild = {
               progress = {
                  _0 = function(_1, _2)
                     return ("戦士ギルドに加入するには、%sをあと%s匹討伐してから、カプールのギルドの番人に話しかける必要がある。")
                        :format(_2, _1)
                  end
               },
               name = "戦士ギルド審査"
            },
            joining_mages_guild = {
               progress = {
                  _0 = function(_1)
                     return ("魔術士ギルドに加入するには、ルミエストのメイジギルドの納入箱に、解読済みの古書物を納入し、ギルドポイントを貯めた後、ギルドの番人に話しかけなければならない。審査をクリアするには、あと%sギルドポイントを獲得する必要がある。")
                        :format(_1)
                  end
               },
               name = "魔術士ギルド審査"
            },
            joining_thieves_guild = {
               progress = {
                  _0 = "盗賊ギルドに加入するには、税金を4ヶ月以上滞納した状態で、ダルフィのギルドの番人に話しかける必要がある。"
               },
               name = "盗賊ギルド審査"
            },
            kamikaze_attack = {
               progress = {
                  _0 = "カプールのアーノルドに、カミカゼ特攻隊に耐えるパルミア軍への援軍を頼まれた。準備が整い次第、アーノルドに話し掛けよう。",
                  _1 = "パルミア軍が撤退を完了するまでの間、カミカゼ特攻隊の猛攻に耐えなければならない。パルミア軍が撤退したら、知らせが入るはずだ。",
                  _2 = "カミカゼ特攻隊の猛攻に耐えきった。カプールのアーノルドに報告しよう。"
               },
               name = "カミカゼ特攻隊 Lv14相当"
            },
            little_sister = {
               progress = {
                  _0 = "アクリ・テオラの謎の科学者に、リトルシスターを連れてくるよう頼まれた。捕獲するためには、ビッグダディを倒し、捕獲玉をリトルにぶつける必要がある。"
               },
               name = "リトルシスター Lv30相当"
            },
            mias_dream = {
               progress = {
                  _0 = "パルミアのミーアは、稀少猫シルバーキャットが欲しいらしい。なんとか捕まえて、ミーアに渡そう。"
               },
               name = "ミーアの夢 Lv1相当"
            },
            minotaur_king = {
               progress = {
                  _0 = "パルミアのコネリー少将に、ミノタウロスの首領の退治を頼まれた。ミノタウロスの巣窟は、ヨウィンの南にあるみたいだ。",
                  _1 = "ミノタウロスの首領を無事討伐した。パルミアのコネリー少将に報告しよう。"
               },
               name = "ミノタウロスの王 Lv24相当"
            },
            nightmare = {
               progress = {
                  _0 = "ヴェルニースのロイターに金になる仕事を持ちかけられた。何やら危険な仕事のようだ。万全の準備を整えてからロイターに話し掛けよう。",
                  _1 = "実験場の全ての敵を殲滅しなければならない。",
                  _2 = "実験を生き延びて完了させた。ヴェルニースのロイターに報告しよう。"
               },
               name = "実験場のナイトメア Lv50相当"
            },
            novice_knight = {
               progress = {
                  _0 = "ヨウィンのアインクに騎士昇格試験の手伝いを頼まれた。ヨウィンの西にあるイークの洞窟に住むイークの首領を倒せばいいそうだ。",
                  _1 = "イークの首領を無事討伐した。ヨウィンのアインクに報告しよう。"
               },
               name = "騎士昇格試験の手伝い Lv8相当"
            },
            pael_and_her_mom = {
               progress = {
                  _0 = "ノイエルのパエルにエーテル抗体を渡した。母親の容態に変化があらわれるのを待とう。",
                  _1 = "ノイエルのパエルの母親の容態が変わったようだ。今度見舞いにいったほうがいいかもしれない。"
               },
               name = "エーテル病を治せ Lv20相当"
            },
            puppys_cave = {
               progress = {
                  _0 = "ヴェルニースのリリアンに、迷子の子犬ポピーを捜すよう頼まれた。どうやら子犬はヴェルニースのすぐ東にある洞窟にいるらしい。"
               },
               name = "迷子の子犬 Lv4相当"
            },
            putit_attacks = {
               progress = {
                  _0 = "ヴェルニースのミシェスに、スライムの退治を頼まれた。スライムの巣窟は、ミシェスの家のすぐ南の家のようだ。",
                  _1 = "ヴェルニースのミシェスに頼まれたスライムの退治を完了した。あとは報告するだけだ。"
               },
               name = "ぬいぐるみを守れ！ Lv6相当"
            },
            pyramid_trial = {
               progress = {
                  _0 = "ピラミッドに出入りする資格を得た。ピラミッドはカプールの北にあり、中には古代の秘宝が眠っているといわれている。"
               },
               name = "ピラミッドからの挑戦状 Lv16相当"
            },
            guild_fighter_quota = {
               progress = {
                  _0 = function(_1, _2)
                     return ("戦士ギルドのランクを上げるためには、%sをあと%s匹討伐してから、カプールのギルドの番人に話しかける必要がある。")
                        :format(_2, _1)
                  end
               },
               name = "戦士ギルドノルマ"
            },
            guild_mage_quota = {
               progress = {
                  _0 = function(_1)
                     return ("魔術士ギルドのランクを上げるためには、ルミエストのメイジギルドの納入箱に、解読済みの古書物を納入し、ギルドポイントを貯めた後、ギルドの番人に話しかけなければならない。ランク上昇のためには、あと%sギルドポイントを獲得する必要がある。")
                        :format(_1)
                  end
               },
               name = "魔術士ギルドノルマ"
            },
            guild_thief_quota = {
               progress = {
                  _0 = function(_1)
                     return ("盗賊ギルドのランクを上げるためには、あと金貨%s枚分の盗品を売りさばき、ダルフィのギルドの番人に話しかける必要がある。")
                        :format(_1)
                  end
               },
               name = "盗賊ギルドノルマ"
            },
            rare_books = {
               progress = {
                  _0 = "ルミエストのレントンが、レイチェルという童話作家によって描かれた絵本を探している。絵本は全部で4巻あるらしい。全て見つけたら、レントンに報告しよう。"
               },
               name = "幻の絵本 Lv12相当"
            },
            red_blossom_in_palmia = {
               progress = {
                  _0 = "ダルフィのノエルにパルミアの街に爆弾をしかけるように依頼された。爆弾をパルミアの宿屋の部屋にあるぬいぐるみにしかけよう。",
                  _1 = "見事にパルミアを壊滅させた。あとはダルフィのノエルの元に戻り、報告するだけだ。"
               },
               name = "パルミアに赤い花を Lv14相当"
            },
            sewer_sweeping = {
               progress = {
                  _0 = "ルミエストのバルザックに、下水道の清掃を頼まれた。下水道の入り口は宿屋の近くにあるみたいだ。。",
                  _1 = "下水道の大掃除を完了した。あとはルミエストのバルザックに報告するだけだ。"
               },
               name = "下水道大作戦 Lv23相当"
            },
            thieves_hideout = {
               progress = {
                  _0 = "ヴェルニースのシーナが勤める酒場に、酒泥棒が頻出しているらしい。盗賊団を壊滅させてシーナに報告しよう。",
                  _1 = "酒樽を盗んでいたごろつき団を殲滅した。あとはヴェルニースのシーナに報告するだけだ。"
               },
               name = "お酒泥棒 Lv2相当"
            },
            wife_collector = {
               progress = {
                  _0 = "カプールのラファエロに嫁を持ってくるよう頼まれた。なんという下劣な男だ。"
               },
               name = "嫁泥棒 Lv3相当"
            }

         }
      }
   }
}
