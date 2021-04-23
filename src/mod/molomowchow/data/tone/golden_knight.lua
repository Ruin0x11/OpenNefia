data:add {
   _id = "golden_knight",
   _type = "base.tone",

   author = "MoloMowChow",
   show_in_menu = true,

   texts = {
      en = {
         ["base.aggro"] = {
            function(t, env, args, chara)
               return ("You feel the ground vibrate as %s enters a combat stance.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s rattles the ground as she takes a step towards the enemy.")
                  :format(env.name(t))
            end,
            '"The enemy has come!"'
         },
         ["base.calm"] = {
            "You hear heavy, yet somewhat delicate footsteps."
         },
         ["base.dead"] = {
            function(t, env, args, chara)
               return ("\"Forgive me...%s...\"")
                  :format(env.player())
            end,
            '"Is this...my limit?"',
            "\"It's heavy...\"",
            function(t, env, args, chara)
               return ("You hear a loud *THUMP* as %s collapses.")
                  :format(env.name(t))
            end
         },
         ["base.dialog"] = {
            "(You see a beautiful blonde female knight, her hair like yarn spun from gold itself.  Beneath this delicate appearance is an immense physical power.)",
            function(t, env, args, chara)
               return ("(%s stares at you intently)")
                  :format(env.name(t))
            end,
            "...?",
            function(t, env, args, chara)
               return ("How can I help, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("What do you need, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("(Onlookers marvel at the huge load being hauled effortlessly behind %s.)")
                  :format(env.name(t))
            end,
            "It is my duty to shoulder your burdens.",
            "Lord Opatos tasked me with your well being. Rest assured, you can depend on me!",
            "Please, feel free to rely on me more!",
            "Do you have something for me to carry?",
            "Try not to strain your back too much. Let me lighten your load.",
            "If you get too tired, do not hesitate to rest.",
            "Please don't overdo it.",
            "Need me for something? An item from the pack? Organize your inventory? Perhaps a back massage?",
            "Are you doing okay? Have you been getting sleep? Are you hungry? Is that pack getting heavy? I'll be here if you need me!",
            "Am I carrying enough? Have I been dependable? If I have, I wouldn't mind a little praise...",
            function(t, env, args, chara)
               return ("When do we leave for our next destination, %s?")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("(%s is trying to practice an awkward laugh as onlookers stare in mocking amusement.)")
                  :format(env.name(t))
            end,
            "M-Mua-ha-ha...ha-ha...ha... Um, lord Opatos said I should practice laughing everyday...",
            "Sometimes, I can still hear lord Opatos laughing in the distance.",
            "There's more to lord Opatos than his abrasiveness...or his laugh...honest!",
            "Lord Opatos loves to shake the land. When he does, the nefia ruins shift, and new dungeons appear.",
            "I will carry anything, even your furniture!",
            "You won't make me carry a nuke...will you?",
            "...",
            function(t, env, args, chara)
               return ("People will know of %s %s in due time. You're one of the best adventurers!")
                  :format(env.aka(), env.player())
            end,
            "Do not worry about me. I won't get uncomfortable no matter how much I carry.",
            "I don't like stethoscopes...",
            function(t, env, args, chara)
               return ("(%s is dusting off her clothes.)")
                  :format(env.name(t))
            end,
            "I feel the world is growing more and more dangerous...",
            "Cats...why are they so cute?",
            function(t, env, args, chara)
               return ("(%s adjusts their pack.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s stretches her back.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("(%s slightly adjusts her hair.)")
                  :format(env.name(t))
            end,
            "I wonder how many enemies we've defeated?",
            "Thieves make me so angry...",
            "What's for dinner?"
         },
         ["base.killed"] = {
            function(t, env, args, chara)
               return ("%s sighs in relief.")
                  :format(env.name(t))
            end,
            "\"I've seen enough.\"",
            '"This fight is mine."',
            '"One less burden."'
         },
         ["base.welcome"] = {
            function(t, env, args, chara)
               return ("\"Welcome home %s. Let me carry what you've brought back.\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("\"Welcome back, %s.\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("\"Welcome home, %s. Have you brought back more furniture?\"")
                  :format(env.player())
            end,
            '"Bring me with you next time. I can lighten your load.',
            '"I am relieved, but depend on me next time. It is my duty to shoulder your burdens."'
         },
         ["plus.breakfast"] = {
            function(t, env, args, chara)
               return ("\"Good morning, %s! I have procured breakfast for us!\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("\"Please eat %s, breakfast is essential for adventurers!\"")
                  :format(env.player())
            end,
            function(t, env, args, chara)
               return ("%s looks fixedly at you, hoping for praise.")
                  :format(env.name(t))
            end
         },
         ["plus.charge"] = {
            function(t, env, args, chara)
               return ("\"%s is depending on me!\"")
                  :format(env.player())
            end,
            '"Moving to intercept!"',
            function(t, env, args, chara)
               return ("\"They won't touch %s!\"")
                  :format(env.aka())
            end,
            function(t, env, args, chara)
               return ("%s is focusing her next attack.")
                  :format(env.name(t))
            end,
            '"Prepare yourselves!"',
            function(t, env, args, chara)
               return ("%s deals a powerful blow!")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s continues her onslaught!")
                  :format(env.name(t))
            end,
            '"Return to the earth!"'
         },
         ["plus.choco"] = {
            function(t, env, args, chara)
               return ("%s bashfully hands you a fancy looking box of chocolate.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("\"Are these are to your taste, %s? If they are...um, may I ask for your praise?\"")
                  :format(env.player())
            end
         },
         ["plus.create"] = {
            '"I have procured this equipment for you."',
            function(t, env, args, chara)
               return ("\"Perhaps this will be of use to %s?\"")
                  :format(env.player())
            end,
            '"Are these reliable?"'
         },
         ["plus.dialog_e"] = {
            "Ah...I can't carry those kinds of burdens...",
            "I-Is this also part of my duty?",
            function(t, env, args, chara)
               return ("(%s seems to be embarrassed.)")
                  :format(env.name(t))
            end
         },
         ["plus.dialog_f"] = {
            function(t, env, args, chara)
               return ("(%s looks at you and smiles happily.)")
                  :format(env.name(t))
            end,
            "Have I been dependable? If I have, I wouldn't mind a little praise...",
            function(t, env, args, chara)
               return ("(%s is staring at you with a happy expression.)")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("To be spoiled by the %s, it may be slightly addictive...")
                  :format(env.aka())
            end
         },
         ["plus.dialog_h"] = {
            "Ah, I'm being praised!",
            function(t, env, args, chara)
               return ("(%s is pleased.)")
                  :format(env.name(t))
            end,
            "To be praised by you, pleases me greatly!",
            "I'd be happy if you praise me more~"
         },
         ["plus.discipline"] = {
            '"Nngh!?"',
            '"H-have I done something wrong?"',
            '"This too is...my duty!"'
         },
         ["plus.discipline_2"] = {
            '"Nngh!?"',
            '"H-have I do something wrong?"',
            '"This too is...my duty!"'
         },
         ["plus.discipline_eat"] = {
            '"Thank you."'
         },
         ["plus.discipline_off"] = {
            '"I-I will endeavor to improve!"',
            '"These burdens of yours...I will carry them too..."'
         },
         ["plus.drain"] = {
            function(t, env, args, chara)
               return ("%s stands her ground.")
                  :format(env.name(t))
            end,
            '"My strength is yours."'
         },
         ["plus.evochat_b"] = {
            "I've never felt this way before, this quivering in my chest."
         },
         ["plus.ex_act"] = {
            "You rest your head against her chest as she smothers you like a child."
         },
         ["plus.ex_react"] = {
            function(t, env, args, chara)
               return ("%s caresses you tenderly.")
                  :format(env.name(t))
            end,
            '"Tonight, let us spoil each other silly..."'
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
            '"Underground is a fitting place for you!"',
            '"The sole of my boots are enough for the likes of you!"',
            '"Um...M-Mua-ha-ha...ha-ha...ha!"',
            '"Do you even lift!?"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.insult_2"] = {
            '"The ground is a fitting place for you!"',
            '"The sole of my boots are enough for the likes of you!"',
            '"Um...M-Mua-ha-ha...ha-ha...ha!"',
            '"Do you even lift!?"',
            '"Your mother was a hamster, and your father smelt of crimberries!"'
         },
         ["plus.kiss"] = {
            function(t, env, args, chara)
               return ("%s's face turns crimson red as she almost loses her footing.")
                  :format(env.name(t))
            end,
            function(t, env, args, chara)
               return ("%s squeaks in surprise and embarrassment as she puts her hand to her mouth.")
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
               return ("\"%s! I lend you my shoulder! Rely on me!\"")
                  :format(env.player())
            end,
            '"It is my duty to carry you!"'
         },
         ["plus.limit"] = {
            '"I will take in all you. Your burdens, your worries, your feelings....everything..."',
            function(t, env, args, chara)
               return ("\"%s...\"")
                  :format(env.player())
            end
         },
         ["plus.material"] = {
            '"I have procured supplies for us."',
            "\"Are you sure you don't need me to carry these for you?\"",
            '"I can carry whatever you craft out of these!"'
         },
         ["plus.meal"] = {
            "Delicious!",
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
               return ("\"In the name of lord Opatos, shake the earth for %s!\"")
                  :format(env.aka())
            end
         },
         ["plus.nade"] = {
            '"Ah, I got praised! Ehehe..."',
            function(t, env, args, chara)
               return ("%s looks at you and smiles happily.")
                  :format(env.name(t))
            end,
            '"Ah...you can pet me again, you know!"'
         },
         ["plus.night"] = {
            function(t, env, args, chara)
               return ("You see strands of golden hair next to you, and feel %s's hand caressing your cheek...")
                  :format(env.name(t))
            end,
            "\"I'd like to be spoiled sometimes too, you know...\""
         },
         ["plus.ride_off"] = {
            "\"Are you okay to walk now? I'll be here if you need me.\"",
            '"I could carry you further, you know?"',
            '"Feel free to rely on me anytime!"'
         },
         ["plus.ride_off_pc"] = {
            "\"I-I'm not too heavy, am I?\"",
            "\"It's not me that's heavy! It's the pack I'm carrying!\"",
            '"Are you okay? Are your legs tired? Want a foot rub?"'
         },
         ["plus.ride_on"] = {
            '"I will shoulder all your burdens!"',
            "\"Do not worry, you're light as a feather!\""
         },
         ["plus.ride_on_pc"] = {
            '"Um...are you sure about this?"',
            '"Ah, well then...e-excuse me."'
         },
         ["plus.shift"] = {
            '"My body is one with this land!"',
            '"I am indomitable!"'
         },
         ["plus.special"] = {
            '"Return to the earth!"',
            function(t, env, args, chara)
               return ("\"For %s!\"")
                  :format(env.aka())
            end,
            '"In the name of lord Opatos!"'
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
