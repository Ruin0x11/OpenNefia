data:add {
   _id = "little_girl",
   _type = "base.tone",

   author = "MoloMowChow",
   show_in_menu = true,

   texts = {
      en = {
         ["base.aggro"] = {
            '"Go away!"',
            '"Leave us alone!"',
            '"Bully!"'
         },
         ["base.calm"] = {
            function(t, env, args, chara)
               return ("%s fixedly looks at you.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s rubs her eyes.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s is staring at the sky.")
                  :format(env.name(t))
            end
         },
         ["base.dead"] = {
            function(t, env, args, chara)
               return ("\"No....no...%s...!\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("\"I'm sorry...%s...I failed...\"")
                  :format(env.player())
            end
         },
         ["base.dialog"] = {
            function(t, env, args, chara)
               return ("(%s fixedly looks at you.)")
                  :format(env.name(t))
            end,
            "...?",
            "Did you need something?",
            "What do you want?",
            "Yes?",
            "Is something wrong?",
            "What is it?",
            function(t, env, args, chara)
               return ("What is it, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("(%s sighs wistfully.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s sneezes.)")
                  :format(env.name(t))
            end,
            "I hate kamikaze yeeks!",
            "When are we going to leave?",
            "I could really go for some roast putit right now!",
            "I'm getting tired...",
            function(t, env, args, chara)
               return ("(%s yawns.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is trying to practice her whistling.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("How much longer are we going to stay here, %s?")
                  :format(env.player())
            end,
            "Putits are so easy to kill, and they taste good!",
            "...",
            function(t, env, args, chara)
               return ("I can't believe nobody knows who %s %s is! You're one of the best adventurers!")
                  :format(env.aka(), env.player())
            end,
            function(t, env, args, chara)
               return ("Need help with anything, %s?")
                  :format(env.player())
            end,
            "Sometimes this gear gets so uncomfortable...",
            function(t, env, args, chara)
               return ("(%s is cleaning her weapon.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is dusting off her clothes.)")
                  :format(env.name(t))
            end,
            "I feel the world is growing more and more dangerous...",
            "Cats.. why are they so cute?",
            function(t, env, args, chara)
               return ("Eh? What do you want, %s?")
                  :format(env.player())
            end,
            "Yes?",
            function(t, env, args, chara)
               return ("(%s adjusts their gear.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s slightly adjusts her hair.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is absentmindedly twirling a bang of her hair.)")
                  :format(env.name(t))
            end,
            "I wonder how many enemies we've defeated?",
            "I want to visit a trainer and learn some new skills.",
            "Remember that attack I did a while ago? It was pretty cool!",
            "Thieves make me so angry...",
            "I wonder what's for dinner?",
            "What?"
         },
         ["base.killed"] = {
            function(t, env, args, chara)
               return ("%s brushes dust off her clothes.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s smiles at you.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end,
            '"I got another one~"',
            function(t, env, args, chara)
               return ("She prods the %s's corpse with her weapon.")
                  :format(args.target.name)
            end
         },
         ["base.welcome"] = {
            '"Welcome home~♪!"',
            function(t, env, args, chara)
               return ("\"Welcome home, %s!\"")
                  :format(env.player())
            end,
            '"Welcome back! You look tired!"',
            '"Did you bring back anything cool?"',
            "\"Welcome home! What's there to eat?\"",
            function(t, env, args, chara)
               return ("%s runs up to you excitedly.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s is relieved to see you back safely.")
                  :format(env.name(t))
            end
         },
         ["plus.breakfast"] = {
            '"Good morning! I made this for you!"',
            '"Breakfast is ready!"',
            '"Did it turn out okay?"',
            '"Does it taste good?"',
            function(t, env, args, chara)
               return ("%s looks fixedly at you with bated breath as you take the first bite.")
                  :format(env.name(t))
            end
         },
         ["plus.charge"] = {
            '"You can count on me!"',
            function(t, env, args, chara)
               return ("\"They won't touch %s!\"")
                  :format(env.aka())
            end,
            function(t, env, args, chara)
               return ("%s is focusing her next attack.")
                  :format(env.name(t))
            end,
            '"Here I come!"',
            '"H-hold on!"',
            function(t, env, args, chara)
               return ("%s deals a powerful blow!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s continues her onslaught!")
                  :format(env.name(t))
            end,
            '"My turn!"'
         },
         ["plus.choco"] = {
            function(t, env, args, chara)
               return ("%s bashfully hands you a fancy looking box of chocolate.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("\"I made this with thoughts of only you, %s...!\"")
                  :format(env.player())
            end
         },
         ["plus.create"] = {
            '"Will this work?"',
            function(t, env, args, chara)
               return ("\"Can %s use it?\"")
                  :format(env.player())
            end,
            '"I practiced making these!"'
         },
         ["plus.dialog_e"] = {
            "P-please don't joke in a place like this!",
            function(t, env, args, chara)
               return ("(%s seems to be embarassed.)")
                  :format(env.name(t))
            end
         },
         ["plus.dialog_f"] = {
            function(t, env, args, chara)
               return ("(%s fixedly looks at you, with more fervor than usual.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s looks at you and smiles happily.)")
                  :format(env.name(t))
            end,
            "Right now, I'm very happy!",
            "I'm glad we met that day...",
            "Someday, just the two of us...♪1"
         },
         ["plus.dialog_h"] = {
            "Hahaha! Thank you~♪",
            function(t, env, args, chara)
               return ("(%s is pleased.)")
                  :format(env.name(t))
            end,
            "Is it alright?",
            function(t, env, args, chara)
               return ("(%s is staring at you with a happy expression.)")
                  :format(env.name(t))
            end
         },
         ["plus.discipline"] = {
            '"Ouch!"',
            '"Uwah!"',
            function(t, env, args, chara)
               return ("%s whimpers.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_2"] = {
            '"Ouch!"',
            '"Uwah!"',
            function(t, env, args, chara)
               return ("%s whimpers.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_eat"] = {
            '"Thank you."',
            function(t, env, args, chara)
               return ("%s eagerly eyes at the food you gave her.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_off"] = {
            '"Please...stop..."',
            '"W-Why?"',
            "Tears peak out of the corners of her eyes."
         },
         ["plus.drain"] = {
            function(t, env, args, chara)
               return ("%s lets out a yelp.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s struggles halfheartedly.")
                  :format(env.name(t))
            end
         },
         ["plus.evochat_b"] = {
            "My heart is pounding..."
         },
         ["plus.ex_act"] = {
            "You hold each other's hands. Lewd!!!"
         },
         ["plus.ex_react"] = {
            function(t, env, args, chara)
               return ("%s shows you her brightest smile.")
                  :format(env.name(t))
            end
         },
         ["plus.fawn_on"] = {
            function(t, env, args, chara)
               return ("%s's gaze is transfixed in a fervor.")
                  :format(env.name(t))
            end
         },
         ["plus.hug"] = {
            function(t, env, args, chara)
               return ("%s struggles halfheartedly.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s's body tenses up, but relaxes as she hugs back.")
                  :format(env.name(t))
            end,
            '"Come here..."'
         },
         ["plus.insult"] = {
            '"Y-You suck...I think!"',
            '"Y-You will die alone...probably!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.insult_2"] = {
            '"Y-You suck...I think!"',
            '"Y-You will die alone...probably!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.kiss"] = {
            function(t, env, args, chara)
               return ("%s's face turns crimson red as she lowers her head.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s puts her hands to her cheeks and shakes her head in embarrassment.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end
         },
         ["plus.kizuna"] = {
            function(t, env, args, chara)
               return ("\"Stand up! Stand up …! Get up %s!\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("%s grabs your arm and pulls you up!")
                  :format(env.name(t))
            end,
            "\"No! I won't let you!\""
         },
         ["plus.limit"] = {
            '"Ahn~♪1"',
            function(t, env, args, chara)
               return ("\"%s...♪1\"")
                  :format(env.player())
            end
         },
         ["plus.material"] = {
            '"Look what I found!"',
            function(t, env, args, chara)
               return ("\"%s, what's this?\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("%s runs up to you with an armful of materials.")
                  :format(env.name(t))
            end,
            "\"W-why can't I hold all these materials!?\""
         },
         ["plus.meal"] = {
            "Delicious!",
            function(t, env, args, chara)
               return ("(%s eats with a big grin on her face.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is absorbed with eating.)")
                  :format(env.name(t))
            end
         },
         ["plus.midnight"] = {
            function(t, env, args, chara)
               return ("%s slaps your hand away.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s slaps you.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s pushes you away.")
                  :format(env.name(t))
            end
         },
         ["plus.multiple"] = {
            function(t, env, args, chara)
               return ("\"Everybody, for %s!\"")
                  :format(env.aka())
            end,
            "\"Eh? I'm up next!?\"",
            "\"H-huh? It's my turn!?\""
         },
         ["plus.nade"] = {
            '"Ehehehe..."',
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s has a dopey, blissful grin on her face.")
                  :format(env.name(t))
            end
         },
         ["plus.night"] = {
            function(t, env, args, chara)
               return ("%s fixedly looks at you, with more fervor than usual.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("You wake up to %s's face right up against yours!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s yawns.")
                  :format(env.name(t))
            end
         },
         ["plus.ride_off"] = {
            function(t, env, args, chara)
               return ("%s sighs exasperatedly.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s stretches her back.")
                  :format(env.name(t))
            end
         },
         ["plus.ride_off_pc"] = {
            '"No more?"',
            '"Awww..."'
         },
         ["plus.ride_on"] = {
            '"Leave it to me!"',
            function(t, env, args, chara)
               return ("%s gives you a thumbs up as she lets you climb her back.")
                  :format(env.name(t))
            end
         },
         ["plus.ride_on_pc"] = {
            '"Piggy back!"',
            '"You could carry me like a prin-... N-nevermind!"'
         },
         ["plus.shift"] = {
            '"Mahou Shoujo! Henshin!!!"'
         },
         ["plus.special"] = {
            '"Eat...THIS!!!"',
            function(t, env, args, chara)
               return ("\"For %s!\"")
                  :format(env.aka())
            end,
            '"Take this!"'
         }
      },
      jp = {
         ["base.aggro"] = {
            "「こいつ、動くよ」",
            "「戦いが終わったらぐっすり眠れるっていう保証がある？」",
            "「見える。動きが見える！」"
         },
         ["base.calm"] = {
            "「誰だ？誰かが私を見ている」",
            "「悔しいけど…」"
         },
         ["base.dead"] = {
            "「では、この私たちの出会いはなんなんだ！」",
            "「これが、た、戦い。」"
         },
         ["base.dialog"] = {
            "なんだい？",
            "（ちっ)"
         },
         ["base.killed"] = {
            "「と、取り返しのつかない事を…取り返しのつかない事をしてしまった…」",
            "「自信があってやる訳じゃないのに」"
         },
         ["base.welcome"] = {
            "「間違いない。やつだ、やつが来たんだ」"
         },
         ["plus.breakfast"] = {
            function(t, env, args, chara)
               return ("「%s、今日も元気だね」")
                  :format(env.player())
            end
         },
         ["plus.charge"] = {
            "「ここで食い止めてみせる！」"
         },
         ["plus.charge_a"] = {
            "「落ちろっ！」"
         },
         ["plus.charge_s"] = {
            function(t, env, args, chara)
               return ("「離れろ…%sの力は」")
                  :format(env.name(t))
            end
         },
         ["plus.choco"] = {
            "「こんなに嬉しいことはない…」"
         },
         ["plus.create"] = {
            "「私が作ったのさ。コレってね」"
         },
         ["plus.dialog_e"] = {
            "だ、駄目だ、前へ進んじゃ駄目だ。",
            "光と人の渦がと、溶けていく。",
            function(t, env, args, chara)
               return ("%s、%sは、私を愛してないの？")
                  :format(env.player(), env.player())
            end
         },
         ["plus.dialog_f"] = {
            "もういいのか？",
            "人はいつか時間さえ支配することができるさ。",
            "ははは、ありがとう。"
         },
         ["plus.dialog_h"] = {
            "ああ、そうだ、そうだと思う。これも運命だ。",
            "信じるさ、君ともこうしてわかり合えたんだから。",
            function(t, env, args, chara)
               return ("見えるよ、%s…。見えるよ、みんなが…。")
                  :format(env.player())
            end
         },
         ["plus.discipline"] = {
            "「な、殴ったね…」"
         },
         ["plus.discipline_2"] = {
            "「親父にもぶたれたことないのに！」"
         },
         ["plus.discipline_eat"] = {
            "「あっ…食べなくちゃ…」"
         },
         ["plus.discipline_off"] = {
            "「二度もぶった！」"
         },
         ["plus.drain"] = {
            "「…」"
         },
         ["plus.evochat_b"] = {
            "や、やってやる、やってやるぞ！",
            "何をしようというんです？"
         },
         ["plus.ex_act"] = {
            "目隠しする"
         },
         ["plus.ex_react"] = {
            "「まだだ！たかがメインカメラがやられただけだ！！」"
         },
         ["plus.fawn_on"] = {
            function(t, env, args, chara)
               return ("「%sがチャーミングすぎる…」")
                  :format(env.name(t))
            end
         },
         ["plus.hug"] = {
            function(t, env, args, chara)
               return ("「私の好きな%s…」")
                  :format(env.player())
            end
         },
         ["plus.insult"] = {
            "「エゴだよそれは！」",
            "「貴様ほど急ぎもしなければ、人類に絶望もしちゃいない！」"
         },
         ["plus.insult_2"] = {
            "「情けない奴ッ！」"
         },
         ["plus.kiss"] = {
            "「すごい…親父が熱中するわけだ」"
         },
         ["plus.kizuna"] = {
            "「人の心の光を、見せなけりゃならないんだ」",
            function(t, env, args, chara)
               return ("「%sは伊達じゃない！」")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("「立ち上がれ！立ち上がれ…！立ち上がれ%s！」")
                  :format(env.player())
            end
         },
         ["plus.limit"] = {
            "「ただ明日へと…永遠に」"
         },
         ["plus.material"] = {
            "「人の善意を無視する奴は一生苦しむぞ」"
         },
         ["plus.meal"] = {
            "食らえ！"
         },
         ["plus.midnight"] = {
            "「人は同じ過ちを繰り返す。まったく…！」"
         },
         ["plus.multiple"] = {
            "「まだ怒りに燃える闘志　巨大な敵を討て」",
            "「絶望に沈む悲しみ　渦巻く血潮を燃やせ」"
         },
         ["plus.nade"] = {
            "「そこ！」",
            "「心配かけたようだね。大丈夫だよ」"
         },
         ["plus.night"] = {
            "「こう近付けば、四方からの攻撃は無理だな！」"
         },
         ["plus.ride_off"] = {
            "「遅すぎた…？」"
         },
         ["plus.ride_off_pc"] = {
            function(t, env, args, chara)
               return ("「私が一番%sを上手く使えるんだ。一番、一番上手く使えるんだ…」")
                  :format(env.player())
            end
         },
         ["plus.ride_on"] = {
            "「突撃をするぞ！」"
         },
         ["plus.ride_on_pc"] = {
            "「行きまーす！」"
         },
         ["plus.shift"] = {
            "「チェンジサイボーグ！！」",
            "「ビルドアーップ！」"
         },
         ["plus.special"] = {
            "「これでぇぇぇぇっ！」",
            "「やらせるか！そこだ！」"
         }
      }
   }
}
