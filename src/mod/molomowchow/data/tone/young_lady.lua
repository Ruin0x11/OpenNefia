data:add {
   _id = "young_lady",
   _type = "base.tone",

   author = "MoloMowChow",
   show_in_menu = true,

   texts = {
      en = {
         ["base.aggro"] = {
            '"Hmm, which one to throw?"',
            '"Will it blend?"',
            '"Show some respect!"',
            '"This is not medicine!"'
         },
         ["base.calm"] = {
            "You hear the clinking of potion bottles.",
            "You hear glass shattering somewhere."
         },
         ["base.dead"] = {
            '"Kyaaa!"',
            '"Nooo!"'
         },
         ["base.dialog"] = {
            function(t, env, args, chara)
               return ("(%s fixedly looks at you.)")
                  :format(env.name(t))
            end,
            "...?",
            "Did you need something? As long as it is not a Cure Corruption potion.",
            "Yes?",
            "Is something wrong?",
            function(t, env, args, chara)
               return ("What is it, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("(%s is gingerly sipping a potion.)")
                  :format(env.name(t))
            end,
            'What do you mean "Stop throwing molotovs?" They work wonderfully!',
            "You should carry a fireproof blanket~",
            "It is fun seeing others drunk, no?",
            "Throw healing potions at you? But you would get cut by the broken glass, silly!",
            "Do you have any Potions of Potential? How about some Hermes Blood? A Speed Upper? No?",
            "I am only throwing the bad ones at them...honest!",
            "I-I'm not keeping a secret stash of Potential Potions to myself or anything like that...honest!",
            "Love Potions are strictly forbidden!!!",
            "I asked the local potion seller for their strongest potions, but they said their potions are too strong for me! How rude!!!",
            "Give me your strongest potion!",
            "I hate those Pumpkins!",
            "A Bottle of Water? Can you not just draw some from a well?",
            "Milk is classified as a potion. Is that not that obvious?",
            "Aren't you going to pay more attention to me?",
            "Are you not obligated to protect me?",
            "Are we leaving soon?",
            function(t, env, args, chara)
               return ("(%s yawns.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s sighs from boredom.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is mixing a potion.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is absentmindedly twirling a potion bottle in her hand.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is carefully observing a potion at eye level.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(Surrounding onlookers stare at the surreal sight of %s nonchalantly juggling potions for some reason...)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("How much longer are we going to stay here, %s?")
                  :format(env.player())
            end,
            "...",
            function(t, env, args, chara)
               return ("I am sure they will know who %s %s is eventually! You are one of the best adventurers!")
                  :format(env.aka(), env.player())
            end,
            function(t, env, args, chara)
               return ("Need help with anything, %s? As long as it is not about a Cure Corruption potion.")
                  :format(env.player())
            end,
            "Sometimes, carrying all these potions gets so uncomfortable...",
            function(t, env, args, chara)
               return ("(%s is dusting off her clothes.)")
                  :format(env.name(t))
            end,
            "Cats.. why are they so cute?",
            function(t, env, args, chara)
               return ("Hmm? What do you want, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("(%s adjusts her potion bag.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s slightly adjusts her twintails.)")
                  :format(env.name(t))
            end,
            "Remember that potion I threw a while ago? It was pretty effective!",
            "Thieves make me so angry...",
            "I wonder what is for dinner?",
            "What?"
         },
         ["base.killed"] = {
            function(t, env, args, chara)
               return ("%s brushes dust off her clothes.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("She scoffs at the %s's remains.")
                  :format(args.target.name)
            end,
            '"My apologies."',
            '"They melted~ "'
         },
         ["base.welcome"] = {
            '"Welcome back. Please, try this new potion I made!"',
            '"Welcome home. Have you found any rare potions?"',
            '"Do not go in the kitchen! I um, kind of made a mess mixing stuff..."'
         },
         ["plus.breakfast"] = {
            '"Good morning. Here, eat this. N-No, I did not mix a potion in it or anything..."',
            '"Here, eat this. What? I can make stuff other than potions too!"',
            function(t, env, args, chara)
               return ("%s steals glances at you while feigning disinterest as you take the first bite.")
                  :format(env.name(t))
            end
         },
         ["plus.charge"] = {
            function(t, env, args, chara)
               return ("\"They will be too tipsy to notice %s.\"")
                  :format(env.aka())
            end,
            '"Need a little pick-me-up?"',
            function(t, env, args, chara)
               return ("%s is focusing her next attack.")
                  :format(env.name(t))
            end,
            '"This will take more than a potion..."',
            '"I would prefer not to get my hands dirty, but...!"',
            function(t, env, args, chara)
               return ("%s deals a powerful blow!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s continues her onslaught!")
                  :format(env.name(t))
            end,
            '"I will make you drink this!"'
         },
         ["plus.choco"] = {
            '"Yes, you have the right idea. I totally made this for you! N-No, I did not mix a love potion in it!"'
         },
         ["plus.create"] = {
            '"I guess it is fun to make something other than a potion once in awhile."',
            '"I can not give you a Cure Corruption potion, but how about this?"',
            '"I can not give you a Potential potion, but how about this?"',
            '"I can not give you a Hermes Blood, but how about this?"',
            '"I can not give you a Speed Upper, but how about this?"'
         },
         ["plus.dialog_e"] = {
            "At least think of the time and place!",
            function(t, env, args, chara)
               return ("(%s seems to be embarassed.)")
                  :format(env.name(t))
            end
         },
         ["plus.dialog_f"] = {
            function(t, env, args, chara)
               return ("(%s looks at you feverishly)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s has a gentle smile as she glaces at you)")
                  :format(env.name(t))
            end,
            "You are an exception...",
            "You will stay by my side, won't you?",
            "Someday, just the two of us...♪1"
         },
         ["plus.dialog_h"] = {
            "My, you're quite the gentleman.",
            function(t, env, args, chara)
               return ("(%s is pleased.)")
                  :format(env.name(t))
            end,
            "Is it alright?"
         },
         ["plus.discipline"] = {
            '"H-How rude"',
            '"Ow! You lech!"',
            function(t, env, args, chara)
               return ("%s glares at you through her embarassment.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_2"] = {
            '"H-How rude"',
            '"Ow! You lech!"',
            function(t, env, args, chara)
               return ("%s glares at you through her embarassment.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_eat"] = {
            '"You did not mix a love potion in there, did you?"',
            function(t, env, args, chara)
               return ("%s eagerly eyes at the food you gave her.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_off"] = {
            '"T-This is not how you treat a lady!"',
            '"I can no longer be a bride...*sniffle*"',
            function(t, env, args, chara)
               return ("%s's eyes are downcast in shame.")
                  :format(env.name(t))
            end
         },
         ["plus.drain"] = {
            function(t, env, args, chara)
               return ("%s lets out a yelp.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s pouts defiantly.")
                  :format(env.name(t))
            end
         },
         ["plus.evochat_b"] = {
            "My chest feels tight..."
         },
         ["plus.ex_act"] = {
            "Rest your head on her lap."
         },
         ["plus.ex_react"] = {
            function(t, env, args, chara)
               return ("%s strokes your head gently as you relax on her lap.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s is cleaning your ear with an earpick. ASMR!!!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s whispers in one of your ears. ASMR!!!")
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
               return ("%s stammers a response as she tries to compose herself.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s's body tenses up, but relaxes as she hugs back.")
                  :format(env.name(t))
            end,
            '"You may do more, you know..."'
         },
         ["plus.insult"] = {
            '"My potions are too strong for you!"',
            '"You milk-drinker!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.insult_2"] = {
            '"My potions are too strong for you!"',
            '"You milk-drinker!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.kiss"] = {
            function(t, env, args, chara)
               return ("%s's face turns crimson red as steam seemingly bellows from her ears.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s almost faints in embarrassment.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end
         },
         ["plus.kizuna"] = {
            function(t, env, args, chara)
               return ("\"You cannot leave a lady to fend for herself! Get up %s!\"")
                  :format(env.player())
            end,
            '"Drink this! It is my special brew! Do not give up yet!"'
         },
         ["plus.limit"] = {
            '"Ahn~♪1"',
            function(t, env, args, chara)
               return ("\"%s...♪1\"")
                  :format(env.player())
            end
         },
         ["plus.material"] = {
            '"Let us make some potions out of these!"',
            function(t, env, args, chara)
               return ("\"Here %s, make your own potions.\"")
                  :format(env.player())
            end
         },
         ["plus.meal"] = {
            "How wonderfully delicious!",
            function(t, env, args, chara)
               return ("(%s eats leisurely like a proper lady.)")
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
            '"This is better than any potion!"',
            '"Have a taste of this!"'
         },
         ["plus.nade"] = {
            '"Y-You have my permission to continue!"',
            function(t, env, args, chara)
               return ("%s smiles as she puts her hands on yours in response.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s has an elated look on her face.")
                  :format(env.name(t))
            end
         },
         ["plus.night"] = {
            function(t, env, args, chara)
               return ("%s gently shakes you awake.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("You wake up in your bed to %s pinching your cheeks defiantly as she sits on top of you.")
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
            '"Should I dangle a Potion of Potential on a stick for you?"',
            '"Can you not go a little further than this?"'
         },
         ["plus.ride_on"] = {
            '"Are not our roles reversed!?"',
            '"Let me show you what a lady can do!"'
         },
         ["plus.ride_on_pc"] = {
            '"Come, my noble steed!"',
            '"I expect a comfortable journey."'
         },
         ["plus.shift"] = {
            '"I will show you how a true lady carries herself!"'
         },
         ["plus.special"] = {
            '"Choke on this, you brute!"',
            '"Now I am mad!"',
            function(t, env, args, chara)
               return ("\"For %s!\"")
                  :format(env.aka())
            end
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
