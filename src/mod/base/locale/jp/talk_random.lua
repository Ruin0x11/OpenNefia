local area = {
   elona = {
      vernis = {
         "ヴェルニースへようこそ。",
         function(npc)
            return ("鉱山のおかげでこの街は潤っている%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("ヴェルニースは歴史ある炭鉱街%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("あのバーでピアノを弾くのは、やめたほうがいい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("イェルスとエウダーナの戦争に巻き込まれるのは、ごめん%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("レシマスで何かが見つかったらしい%s。		")
               :format(yo(npc))
         end,
         function(npc)
            return ("新たなスキルを得る方法があるらしい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("荷物の持ち過ぎには、注意したほうがいい%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("お墓の傍にいる人？ああ、あの薬中とは関わっちゃいけない%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("ミシェスはぬいぐるみマニア%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("王都パルミアまでは、道をひたすら東にすすめばいい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("シーナの尻は最高%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("最近は、盗賊団なる輩がいて困る%s。")
               :format(yo(npc))
         end
      },
      port_kapul = {
         function(npc)
            return ("潮風が香る%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("ペットアリーナで観戦するのが趣味%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("ラファエロは女の敵%s。")
               :format(dana(npc))
         end,
         function(npc)
            return ("もっと強くなりたいのなら戦士ギルドに行くと良い%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("ここの海産物は内陸部で高く売れる%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("ピラミッドにはどうやったら入れる%s？")
               :format(noda(npc))
         end
      },
      yowyn = {
         function(npc)
            return ("こんな田舎街にもちゃんとヨウィンと言う名前があるん%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("馬ならここで買って行くと良い%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("収穫期はいつも人が足りない%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("何もない場所だけど、ゆっくりしていくといい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("西に無法者の街があるそう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("街を出て東の道沿いに行けば王都%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("南西に古い城があるのを見かけた人がいる%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("この街の葬具は他に自慢出来る一品%s。")
               :format(da(npc))
         end
      },
      derphy = {
         "無法者の街、ダルフィへようこそ。",
         function(npc)
            return ("ノエルみたいにはなれない%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("その道に興味があるなら盗賊ギルドに行くと良い%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("奴隷は世に必要なもの%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("アリーナで血を見るのが好き%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("この街にはガードがいない%s。")
               :format(yo(npc))
         end
      },
      palmia = {
         "パルミア国の王都へようこそ。",
         function(npc)
            return ("ミーアのしゃべり方はどうにからならないか%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("パルミアは何でも揃っていて便利でいい%s、広いから人探しが大変%s。")
               :format(ga(npc), da(npc))
         end,
         function(npc)
            return ("ジャビ様とスターシャ様は、本当に仲がいい%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("パルミア名産といえば、貴族のおもちゃ%s。")
               :format(da(npc))
         end
      },
      noyel = {
         function(npc)
            return ("えっくし！ うぅ、今日も寒い%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("毎日雪かきが大変%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("あの巨人の名前はエボンと言うそう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("罪悪感に耐え切れなくなったら教会に行くと良い%s。")
               :format(yo(npc))
         end,
         "寒いっ！",
         function(npc)
            return ("少し南に行った所に小さな工房が建ってるのを見た%s。")
               :format(noda(npc))
         end
      },
      lumiest = {
         "ようこそ、水と芸術の街へ。",
         function(npc)
            return ("どこかに温泉で有名な街があるそう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("この街じゃ、どこでも釣りが出来る%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("絵画に関してはうるさい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("パルミアには、魔術師ギルドはこの街にしかない%s。")
               :format(noda(npc))
         end
      },

      shelter = {
         function(npc)
            return ("はやく天候が回復するといい%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("このシェルターは、みんなの献金で建設した%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("シェルターがあって助かる%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("ものすごく暇%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("なんだかワクワクする%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("食料は十分あるみたい%s。")
               :format(da(npc))
         end
      },
   }
}


local random = {
   default = {
      function(npc, player, params)
         return ("%s？ …なんだか聞き覚えが%s。")
            :format(player.title, aru(npc))
      end,
      function(npc, player, params)
         return ("暇%s。")
            :format(da(npc))
      end,
      function(npc, player, params)
         return ("ん？ 何か用%s？")
            :format(kana(npc))
      end,
      function(npc, player, params)
         return ("たまには豪勢な食事をしたい%s。")
            :format(na(npc))
      end,
      function(npc, player, params)
         return ("神の存在なくしてこの世は無意味%s！")
            :format(da(npc))
      end,
      function(npc, player, params)
         return ("エーテルの風は異形の森のせいで発生しているとか…ま、あまり興味ない%s。")
            :format(na(npc))
      end
   },

   ally_default = {
      "(あなたをじっと見ている)",
      "…？"
   },

   prostitute = {
      function(npc, player, params)
         return ("あ〜ら、あなたいい%sね。一晩の夢を見させてあげてもいいのよ。")
            :format(params.gender)
      end
   },

   bored = {
      "(退屈そうにあなたを見ている)",
      function(npc)
         return ("(%sはあなたを一瞥すると、そっぽを向いた。)")
            :format(npc.name)
      end
   },

   fortune_cookie = {
      blessed = {
         "牧場では肉から干し肉を生産することができるぞ。",
         "クミロミを信仰すれば、腐った食料から種を取り出すことができる。",
         "ダルフィの近くに牧場を立てればすぐに金持ちになれるぞ！",
         "素材槌を普通の装備に使うな！",
         "ハーブの真の効果はペットに食べさせた時に発揮される。",
         "質の良いベッドで眠ると睡眠の効果があがるぞ。",
         "カルマが高ければ税金は割り引かれる。",
         "モンスターのフンは重ければ重いほど高く売れる。",
         "祝福された下落のポーションは飲んだ者のレベルを上げる。",
         "呪われた回復のポーションを飲むと病気になることがある。",
         "新しいスキルが欲しければ、祝福された能力獲得の巻物を読むといい。",
         "朦朧とした相手には、かなりの確率で会心の一撃を叩き込める。",
         "毒や麻痺、出血などの状態異常にかかっている間は、自然治癒することはない。",
         "キューブは状態異常にかかっている間は増殖しない。",
         "アーティファクトに*素材変化*の巻物を使うと、再生成することができる。",
         "音耐性が十分にあれば朦朧を防ぐことができる。",
         "幻惑耐性が十分にあれば狂気を防ぐことができる。",
         "杖を祝福するのはいいアイデアだが、祝福されたポーションや巻物よりは若干効果が劣るそうだ。",
         "濡れている間は炎属性のダメージはほとんど受けない。しかし雷属性のダメージは増加する。",
         "短期間に吐きすぎると拒食症になるぞ。病気になったら飲み物で空腹を癒すしかない。",
         "祝福された能力復活や精神復活のポーションは、肉体や精神強化する。",
         "強敵には呪われた能力復活や精神復活のポーションを投げつけろ。",
         "ヘルメスの血は*必ず*祝福してから飲め！",
         "帰還場所を間違うと大変なことになるかもしれない。"
      },
      normal = {
         "ニンフは本当の名前、ローレライと呼ばれると、たまらなく喜ぶだろう。",
         "指追加というすばらしい指輪があるそうだ。",
         "杖はしばらく地面に置いておけば充填されるぞ！",
         "何を願えばいいかわからない？アスールの秘宝を試すといい。",
         "宝石はプラチナ硬貨と交換することができる。",
         "宝の地図は常に祝福してから読め。",
         "にゃぁ…ァ…ぁぁ…",
         "水泳のスキルがあれば、他の大陸に泳いで渡ることができる。",
         "何を望む？",
         "チャットウィンドウで Guards!と叫べば、ガードが助けに来てくれることがあるぞ。",
         "神をペットにする方法があるという。",
         "ムーンゲートの先ではプレイヤーキラーが待ち構えている。",
         "やってしまったようだな。これを読んだ者には*必ず*呪いがふりかかるだろう。",
         "後ろ！気をつけて！ほ、ほら、妹がー！逃げてー！あー！",
         "あいにょーとーくふぁにー、にょーばんっばんっふぉうゆう。",
         "あなたのセーブファイルが破損しているため、正しいおみくじを表示できませんでした。",
         "猫を一匹も殺さないといいことがあるそうだ。",
         "宝箱を開ける前に祝福された神託の巻物を読めば、良質なエンチャントを持った装備品が生成されるといわれている。",
         "ガードは裸で体当たりされると喜ぶらしい。",
         "妹専用の最強のアーティファクトがあるらしい。",
         "水泳のスキルは願いでのみ習得できる。"
      }
   },

   christmas_festival = {
      function(npc)
         return ("ようこそ、ノイエルの聖夜祭へ！楽しんでいって%s。")
            :format(kure(npc))
      end,
      function(npc)
         return ("聖夜祭は、聖ジュア祭とも呼ばれてい%s。癒しの女神を称え、年の終わりを祝う宴でもある%s。")
            :format(ru(npc), noda(npc))
      end,
      function(npc)
         return ("モイアーのやつ、今年の聖夜祭ではなにか特別な品物を用意すると張り切っていた%s。")
            :format(na(npc))
      end,
      function(npc)
         return ("%s、あの神々しいジュア像をもう見た%s？なんとも美しく可憐じゃない%s！%sもこの機に改宗するといい%s！")
            :format(kimi(npc), kana(npc), ka(npc), kimi(npc), yo(npc))
      end,
      function(npc)
         return ("今宵は愛する人と気持ちいいことをする%s！")
            :format(noda(npc))
      end,
      function(npc)
         return ("この祭りを見るために、この時期には多くの観光客がノイエルを訪れる%s。")
            :format(noda(npc))
      end,
      function(npc)
         return ("聖夜祭は歴史ある祭り%s。かつてはパルミアの王室もジュア像に祈りを捧げに来ていたらしい%s。")
            :format(da(npc), yo(npc))
      end,
      function(npc)
         return ("伝説では、ジュアの癒しの涙は、いかなる難病をも治療するといわれてい%s。事実、聖夜祭の期間には、盲人が光を取り戻すなど、数々の奇跡が目撃されている%s。")
            :format(ru(npc), noda(npc))
      end
   },

   maid = {
      function(npc, player, ref)
         return ("おかえり、%s♪%sのいない間に、来客が%s人あった%s。今すぐ会う%s？")
            :format(name(player), kimi(npc), ref, yo(npc), kana(npc))
      end,
      function(npc, player, ref)
         return ("%s、%s！お客さんが%s人待ってる%s。会う%s？")
            :format(name(player), player.name, ref, yo(npc), daro(npc))
      end
   },

   moyer = {
      "お客さん、怯えなくても大丈夫だ。この怪物は、魔法によって身動き一つとれないんだ。さあ、見物ついでに、うちの商品も見て言ってくれ。",
      "これなるは、かのネフィアの迷宮ベロンを支配した、伝説の火の巨人！今日立ち寄ったあなたは、実に運がいい！さあ、この神々しくも禍々しい怪物の雄姿を、とくとご覧あれ。商品を買ってくれれば、お触りもオッケーだよ。"
   },

   personality = {
      ["0"] = {
         function(npc)
            return ("ジャビ王は聡明なお方%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("クリムエールをふらふらになるまで飲みたい%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("猫は何故こんなにかわいいの%s。")
               :format(kana(npc))
         end,
         function(npc)
            return ("イェルスは最近台頭してきた新王国%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("エウダーナは、他のどの国よりも先に、ネフィアの探索と研究をはじめた%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("店の主人は不死身なの%s。")
               :format(kana(npc))
         end,
         function(npc)
            return ("どうやら、アーティファクトの所在を知る方法があるみたい%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("大食いトドは魚が好きみたい%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("病気や体調が悪い時は、十分に睡眠をとって休むのが大事%s。祝福された回復のポーションも病気に効くと、昔からよくいわれてい%s。")
               :format(da(npc), ru(npc))
         end
      },
      ["1"] = {
         function(npc)
            return ("ともかく、世の中お金が大事%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("どこかにお金が落ちていない%s。")
               :format(kana(npc))
         end,
         function(npc)
            return ("経済の話題には関心がある%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("プラチナ硬貨はなかなか手に入らない%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("エウダーナの財政は、少し苦しいらしい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("戦後のザナンは形式こそ王国制をとるものの、実質的にはエイス・テールの諸国をモデルにした経済国家%s。")
               :format(da(npc))
         end
      },
      ["2"] = {
         function(npc)
            return ("ノースティリス西部には、数々の遺跡やダンジョンがあり、ネフィアとよばれている%s。")
               :format(noda(npc))
         end,
         function(npc)
            return ("エイス・テールは第七期の文明%s。高度な科学を持っていた%s。")
               :format(da(npc), noda(npc))
         end,
         function(npc)
            return ("エイス・テールは、魔法と科学を対立するものと考えていたよう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("科学について語るのが好き%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("ヴェルニースはパルミアで一番大きな炭鉱街%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("ルミエストは芸術の街として有名%s。")
               :format(dana(npc))
         end
      },
      ["3"] = {
         function(npc)
            return ("食料の供給源は、しっかり決めておいたほうがいい%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("まだ解き明かされない謎が多く眠るネフィアは、冒険者にとって聖地のようなもの%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("永遠の盟約…？そんな言葉は聞いたことがない%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("シエラ・テールは十一期目の文明%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("色々なところを旅するのが好き%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("もし冒険が難しくなってきたら、名声を下げてみればいいかもしれない%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("宝くじ箱は鍵開けの訓練にもってこい%s。")
               :format(da(npc))
         end
      }
   },

   rumor = {
      loot = {
         function(npc)
            return ("うさぎの尻尾は幸運を呼ぶみたい%s。")
               :format(dana(npc))
         end,
         function(npc)
            return ("乞食は体内を浄化する魔法のペンダントを持っていることがあるみたい%s。奴らは何でも食べるから%s。")
               :format(da(npc), na(npc))
         end,
         function(npc)
            return ("ゾンビは稀に奇妙なポーションを落とすよう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("そういえば、以前とてつもない名器を奏でる詩人の演奏を聴いたことが%s。感動して、つい、履いていた高価な靴を投げてしまった%s。")
               :format(aru(npc), yo(npc))
         end,
         function(npc)
            return ("なんでもマミーは死者を蘇らせる書をもっているそう%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("見てしまった%s！死刑執行人が、首を切られたのに生きかえるのを！")
               :format(noda(npc))
         end,
         function(npc)
            return ("異形の目に見入られた者の肉体は変化するという%s、たまに生物の進化を促すポーションを落とすらしい%s。")
               :format(ga(npc), yo(npc))
         end,
         function(npc)
            return ("妖精はとっても秘密な経験を隠しているらしい%s！")
               :format(yo(npc))
         end,
         function(npc)
            return ("ロックスロアーの投げる石をあなどってはいけない%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("銀眼の魔女には気をつけるの%s。あの大剣に斬りつけられたらひとたまりもない%s。たまにとんでもない業物を持っていることもあるらしい%s。")
               :format(dana(npc), daro(npc), ga(npc))
         end,
         function(npc)
            return ("キューピットが重そうなものを運んでいるのをみた%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("夢で神様に会える%s？")
               :format(kana(npc))
         end,
         function(npc)
            return ("黄色い首輪をつけた四本腕の化け物に出会ったのなら、すぐに逃げるのが賢明%s")
               :format(dana(npc))
         end,
         "盗賊団の殺し屋は、射撃の回数を増やす魔法の首輪を稀に所持しているらしい。",
         function(npc)
            return ("貴族の中には変わった物を収集している者がいるらしい%s。")
               :format(ga(npc))
         end,
         function(npc)
            return ("パーティーで演奏していると、酔った客がたまに変なものを投げてくるの%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("赤い腰当をしたロボットを見たことがある%s。")
               :format(na(npc))
         end,
         function(npc)
            return ("インプが持つ魔法の巻物は、アーティファクトの名前を変えられるそう%s。")
               :format(dana(npc))
         end,
         function(npc)
            return ("ヨウィンの無邪気な少女は、不思議な宝物を大切に持っているみたい%s。")
               :format(da(npc))
         end,
         function(npc)
            return ("この前、とても綺麗な貝をかぶったやどかりを見た%s。")
               :format(yo(npc))
         end,
         function(npc)
            return ("盗賊団の連中は、何やら怪しい薬を常用しているらしい%s。")
               :format(na(npc))
         end
      }
   },

   shopkeeper = {
      function(npc)
         return ("店の経営は、なかなか難しい%s。")
            :format(na(npc))
      end,
      function(npc)
         return ("他の店では、足元を見られないよう、気をつけたほうがいい%s。")
            :format(yo(npc))
      end,
      function(npc)
         return ("ごろつきを追い払えるぐらい強くないと、店主はつとまらない%s。")
            :format(yo(npc))
      end,
      function(npc)
         return ("何かの時のために、店を継ぐ人は決めて%s。")
            :format(ru(npc))
      end,
      function(npc)
         return ("いらっしゃい。ゆっくり見ていって%s。")
            :format(kure(npc))
      end,
      function(npc)
         return ("品揃えには自信がある%s。")
            :format(noda(npc))
      end,
      function(npc)
         return ("さあ、自慢の商品を見ていって%s。")
            :format(kure(npc))
      end,
      function(npc)
         return ("最近は物騒な人が多くて大変%s。")
            :format(da(npc))
      end,
      function(npc)
         return ("武器と防具はきちんと鑑定されたものでないと、高くは買い取れない%s。")
            :format(yo(npc))
      end
   },

   slavekeeper = {
      function(npc)
         return ("お客さんも悪い人間%s。")
            :format(dana(npc))
      end,
      function(npc)
         return ("ひひひ…旦那も好き者%s。")
            :format(dana(npc))
      end
   },

   area = area,

   params = {
      maid = function(_1)
         return ("%s")
            :format(_1)
      end
   },
}

return {
   talk = {
      random = random
   }
}
