data:add {
   _id = "black_angel",
   _type = "base.tone",

   author = "MoloMowChow",
   show_in_menu = true,

   texts = {
      en = {
         ["base.aggro"] = {
            '"Annoying rabble."',
            '"Scatter before me."',
            '"On your knees!"',
            '"Bend. Over."'
         },
         ["base.calm"] = {
            "You hear what sounds like wings of feather, but with grace and dignity...",
            "You hear a quiet voice in prayer, but with a note of sadness...",
            "You smell Myrrh in the air, but with the faintest hints of charcoal..."
         },
         ["base.dead"] = {
            '"Kya!"',
            '"How could this...!"',
            "\"I won't...forget this...\""
         },
         ["base.dialog"] = {
            function(t, env, args, chara)
               return ("(%s is ignoring you.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s scoffs at you.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is pretending you aren't there.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is looking at you as if you were less than the dirt beneath her heel.)")
                  :format(env.name(t))
            end,
            "(You see before you a subordinate of the Goddess Lulwy. A beautiful angel in black wings and skimpy dress. An air of sadism, egotism and eroticism surround her, not unlike her God.)",
            "Speak.",
            "What do you want?",
            "Ugh...what?",
            "Don't waste my time.",
            "Just drop dead.",
            "Bend over.",
            "You look dumber than the last time I saw you.",
            "You look uglier than the last time I saw you.",
            "Give me something to mince already, or else you'll do.",
            "Abusive? Compared to Mistress Lulwy, I am being most compassionate. You're lucky I don't punish you more on her behalf, you imbecile.",
            "It's YOU who should submit to ME!",
            "Know your place, servant.",
            "Make yourself useful to Mistress Lulwy!",
            "I have only one master, and that isn't you, nitwit.",
            "You will never be my master, you cretin.",
            function(t, env, args, chara)
               return ("(%s grumbling to herself.) Oh Mistress Lulwy...why this buffoon?")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s grumbling to herself.) Mistress Lulwy, just what do you see in this oaf...?")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s sighs wistfully.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is murmuring, eyes closed and hands clasped, in quiet prayer. There's a hint of sadness in the air...)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is murmuring to herself, daydreaming.) Ehehehe...and then Mani pushes Mistress Lulwy down...and then...Wha!? How long were you there for!? Do that again and I'll mince you!!!")
                  :format(env.name(t))
            end,
            "Mani looks like he would be on the bottom, wouldn't you agree?",
            "When are we going to leave?",
            "Kya~!!! Wha!? Don't touch the wings! Do that again and I'll mince you!!!",
            "I'm getting bored. Entertain me!",
            function(t, env, args, chara)
               return ("(%s yawns.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("How much longer are we going to stay here, %s? You're wasting my time.")
                  :format(env.player())
            end,
            "...",
            function(t, env, args, chara)
               return ("Nobody knows who %s %s is, and nobody ever will. Stop trying already, you clown.")
                  :format(env.aka(), env.player())
            end,
            "If only you knew the truth of etherwind...",
            function(t, env, args, chara)
               return ("(%s is cleaning her weapon.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is dusting off her clothes.)")
                  :format(env.name(t))
            end,
            "Cats.. why are they so cute?",
            function(t, env, args, chara)
               return ("(%s adjusts their gear.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is fiddling with her twintails.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s is absentmindedly floating in the air in boredom.)")
                  :format(env.name(t))
            end,
            "I wonder how many enemies I've minced?",
            "Fools make me so angry...",
            "What's for dinner? It best be to my taste."
         },
         ["base.killed"] = {
            '"Fall into hell."',
            '"Aha~! You look great minced!"',
            '"How reprehensible."',
            '"Thought you could win? Hah!"'
         },
         ["base.welcome"] = {
            "\"Well don't just stand there. I'm hungry!\"",
            "\"Oh, you're not dead yet?\"",
            '"What? Expecting a greeting? Make yourself useful already!"',
            '"You better have brought back something good."',
            function(t, env, args, chara)
               return ("%s scoffs at your return.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s pretends you aren't there.")
                  :format(env.name(t))
            end
         },
         ["plus.breakfast"] = {
            '"Just eat it, you halfwit."',
            '"About time you got up."',
            function(t, env, args, chara)
               return ("%s tosses the food at you without a care.")
                  :format(env.name(t))
            end,
            '"Bend over."'
         },
         ["plus.charge"] = {
            '"Eyes up here, worms!"',
            function(t, env, args, chara)
               return ("\"This better be worth the trouble, %s!\"")
                  :format(env.aka())
            end,
            function(t, env, args, chara)
               return ("%s is focusing her next attack.")
                  :format(env.name(t))
            end,
            "\"Don't push your luck!\"",
            "\"I've had it!\"",
            '"Who do you think I am!?"',
            '"Bend! Over!"',
            function(t, env, args, chara)
               return ("%s deals a powerful blow!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s continues her onslaught!")
                  :format(env.name(t))
            end,
            '"You bore me. Begone!"'
         },
         ["plus.choco"] = {
            function(t, env, args, chara)
               return ("Without eye contact, %s shoves a fancy looking box of chocolate onto your chest.")
                  :format(env.name(t))
            end,
            "\"Just take it, you dullard. Speak one word about this and I'll mince you.\"",
            '"This one is only for you. Bend over."'
         },
         ["plus.create"] = {
            '"Just take it, moron."',
            function(t, env, args, chara)
               return ("%s throws a piece of equipment at you from above. You swear she aimed at your head.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s drops a piece of equipment on you from above before flying off.")
                  :format(env.name(t))
            end,
            '"Bend over."'
         },
         ["plus.dialog_e"] = {
            "T-There's a time and place for everything you jerk!",
            "How dare you!",
            "Brute!",
            function(t, env, args, chara)
               return ("(%s face contorts in a mix of scorn and excitment.)")
                  :format(env.name(t))
            end
         },
         ["plus.dialog_f"] = {
            function(t, env, args, chara)
               return ("(In a rare occasion, %s looks you in the eye with a smile on her face.)")
                  :format(env.name(t))
            end,
            "Perhaps you are of use to Mistress Lulwy, afterall.",
            "Such a good servant.",
            "You're an entertaining one, for a nitwit.",
            "Bend over."
         },
         ["plus.dialog_h"] = {
            "Perhaps you are of use to Mistress Lulwy, afterall.",
            "Such a good servant.",
            function(t, env, args, chara)
               return ("(%s is pleased.)")
                  :format(env.name(t))
            end,
            "An offering! Good, you recognize your place, servant."
         },
         ["plus.discipline"] = {
            '"How dare you!!! I will make you regret this!!!"',
            "\"D-Don't misunderstand! There's no way I could be enjoying this!\"",
            '"Ahn~<3!!! I...I mean, STOP!!!"',
            "\"T-There's no way I could be enjoying this! How dare you even suggest-... Ahn~<3!!!\"",
            function(t, env, args, chara)
               return ("%s moans in what sounds more like ecstasy than pain...")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("Despite her protests, %s is breathing heavily with a flushed face and a dumb grin.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_2"] = {
            '"How dare you!!! I will make you regret this!!!"',
            "\"D-Don't misunderstand! There's no way I could be enjoying this!\"",
            '"Ahn~<3!!! I...I mean, STOP!!!"',
            "\"T-There's no way I could be enjoying this! How dare you even suggest-... Ahn~<3!!!\"",
            function(t, env, args, chara)
               return ("%s moans in what sounds more like ecstasy than pain...")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("Despite her protests, %s is breathing heavily with a flushed face and a dumb grin.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_eat"] = {
            '"Give it here!"',
            function(t, env, args, chara)
               return ("%s snatches the food that you give to her.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("You feed %s the food as she can't eat without your permission. Although she scowls, you notice she seems to enjoy this.")
                  :format(env.name(t))
            end
         },
         ["plus.discipline_off"] = {
            "\"Don't sto...n-nevermind!\"",
            '"You will rue this day, cretin!"',
            function(t, env, args, chara)
               return ("Although %s has a look of scorn on her face, you swear you see heart shapes in her eyes.")
                  :format(env.name(t))
            end
         },
         ["plus.drain"] = {
            function(t, env, args, chara)
               return ("%s scoffs.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s glares at you.")
                  :format(env.name(t))
            end
         },
         ["plus.evochat_b"] = {
            "How could an oaf like you could make me feel so insecure? I'll make you pay for the rest of your life.",
            "How could my heart move for a mortal? I'll have you take responsibility for the rest of your life."
         },
         ["plus.ex_act"] = {
            "Servant play."
         },
         ["plus.ex_react"] = {
            function(t, env, args, chara)
               return ("In a rare occasion, you gain the upper hand and managed to pin %s down. You begin to exact your revenge as she stares helpless in a mix of horror and excitement.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("With a leash around %s's neck, you begin to show her who her true master is tonight.")
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
            '"Getting a little presumptuous, are we?"',
            "\"Looks like I'll need to remind you of your place...tonight.\"",
            function(t, env, args, chara)
               return ("%s scoffs, but does not resist.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s's punches you in the gut before hugging back.")
                  :format(env.name(t))
            end,
            '"Come here, you lout..."'
         },
         ["plus.insult"] = {
            '"You suck!"',
            '"You will die alone!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"',
            '"Bend over!"'
         },
         ["plus.insult_2"] = {
            '"You suck!"',
            '"You will die alone!"',
            '"Your mother was a hamster, and your father smelt of crimberries!"',
            '"Bend over!"'
         },
         ["plus.kiss"] = {
            '"Getting a little presumptuous, are we?"',
            "\"Looks like I'll need to remind you of your place...tonight.\"",
            function(t, env, args, chara)
               return ("%s scoffs in embarrassment.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end,
            '"Alright, bend over."'
         },
         ["plus.kizuna"] = {
            '"No thanks needed, fool."',
            '"What are you doing, you imbecile? Get up before I mince you!"',
            function(t, env, args, chara)
               return ("%s grabs your arm and pulls you up!")
                  :format(env.name(t))
            end,
            '"Grovel before me, and I may just save you!"',
            '"Bend over!"'
         },
         ["plus.limit"] = {
            '"Ahn~"',
            function(t, env, args, chara)
               return ("\"%s...\"")
                  :format(env.player())
            end,
            '"Heh, you dolt..."'
         },
         ["plus.material"] = {
            '"Just take it, stupid."',
            function(t, env, args, chara)
               return ("%s aggressively throws materials at you as she cackles.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s dumps a bunch of materials on you from above before flying off.")
                  :format(env.name(t))
            end,
            '"Bend over."'
         },
         ["plus.meal"] = {
            "Not bad, for a simpleton.",
            "I've had better.",
            function(t, env, args, chara)
               return ("(%s is absorbed with eating.)")
                  :format(env.name(t))
            end
         },
         ["plus.midnight"] = {
            function(t, env, args, chara)
               return ("%s slaps you.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s kicks you away.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s kicks you in the crotch.")
                  :format(env.name(t))
            end
         },
         ["plus.multiple"] = {
            '"This ends here!"',
            "\"Are you watching? This is how it's done!\""
         },
         ["plus.nade"] = {
            '"Who said you could touch me? Wait for my permission next time, you twit."',
            function(t, env, args, chara)
               return ("%s scoffs, but does not move away.")
                  :format(env.name(t))
            end,
            '"Hmph..."'
         },
         ["plus.night"] = {
            function(t, env, args, chara)
               return ("You wake up to %s's sitting on top of you and a leash around your neck.")
                  :format(env.name(t))
            end,
            "\"I just don't understand. How could a dork like you...\"",
            function(t, env, args, chara)
               return ("%s yawns.")
                  :format(env.name(t))
            end,
            '"Bend over."'
         },
         ["plus.ride_off"] = {
            function(t, env, args, chara)
               return ("%s sighs exasperatedly.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s stretches her back and wings.")
                  :format(env.name(t))
            end,
            '"Did you enjoy the skies?"'
         },
         ["plus.ride_off_pc"] = {
            '"Who said you could stop?"',
            "\"You shouldn't stop until I tell you to.\"",
            '"Keep going, piggy."'
         },
         ["plus.ride_on"] = {
            '"You should be honored!"',
            "\"I'll show you how free the skies are. Be thankful, you poor sap.\"",
            "\"If you pull on my twintails, I'll drop you in a heartbeat!\""
         },
         ["plus.ride_on_pc"] = {
            '"Consider this an honor."',
            '"Forward, piggy!"',
            function(t, env, args, chara)
               return ("%s giggles as she pulls on the leash around your neck.")
                  :format(env.name(t))
            end,
            '"Bend over."'
         },
         ["plus.shift"] = {
            '"My speed is unmatched!"',
            '"Winds of freedom!"'
         },
         ["plus.special"] = {
            '"Repent now!"',
            '"I saved this for you, worm!"',
            '"Have you made your peace?"',
            function(t, env, args, chara)
               return ("%s laughs maniacally.")
                  :format(env.name(t))
            end,
            '"Bend! Over!"'
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
