
-- {
--   ["05e8dae8c7abf606f3f0b660871295b253a70ee8"] = { "younger_sister", "younger_sister_of_mansion" },
--   ["16c2077639e6deb61044a6b80266bfb019f94bed"] = { "putit", "red_putit", "slime", "acid_slime", "bubble", "blue_bubble" },
--   ["27588615921934cb29f11255d8e9846dcaf9e24a"] = { "mercenary_warrior", "mercenary_archer", "mercenary_wizard" },
--   ["2a55aa0a19580468278db202a765ce240d341692"] = { "informer", "arena_master", "elder", "sailor", "captain" },
--   ["4964ccf1939addb1fd69f0cca8ba4f6217663934"] = { "punk", "gangster" },
--   ["4ec0b7ba7d6e689e5229f2db5f90b97154390e36"] = { "wooden_golem", "stone_golem", "steel_golem", "golden_golem", "mithril_golem", "sky_golem", "adamantium_golem" },
--   ["5937a3863592a7bceb3716026b3ef2675d2f93ea"] = { "fallen_soldier", "mercenary" },
--   ["77fd17831dcdf51a5f5954e37f18a611e797b351"] = { "yerles_machine_infantry", "yerles_elite_machine_infantry" },
--   ["8fb9e017b73b91378b639c935c8b8a69c29eed45"] = { "citizen", "citizen2", "citizen_of_cyber_dome", "citizen_of_cyber_dome2" },
--   a8fd5ff51fb2df5b2f3f514118efd087d9225ce7 = { "mage_guild_member", "thief_guild_member", "fighter_guild_member" },
--   aff2badbd7afc4bac325231abd7bd9f13a3b68cb = { "rogue", "prostitute" },
--   b1781a446ba75261881ca1d6e6ee10542682ff8e = { "rogue_boss", "rogue_warrior", "rogue_archer", "rogue_wizard" },
--   b5c33cdff39a9a907a67b305663bec95c1d7b0f9 = { "spider", "black_widow", "paralyzer", "tarantula", "blood_spider" },
--   c557035f455dcf944d70eac35d1af11e0557befc = { "trainer", "guild_trainer" },
--   c729a5133db175c4ec0d55e7c3341eb6f3e6e396 = { "juere_infantry", "juere_swordman" },
--   d8c4993a558db1c14b315ed5388c6405a32199d0 = { "guard_port_kapul", "guard" },
--   fa91afb0c1032b28892c41974bc894e9cfa7cc69 = { "silver_bell", "gold_bell" }
-- }

data:add {
  _type = "base.tone",
  _id = "shopkeeper",

  texts = {
    en = {
      ["base.aggro"] = { '"Guard! Guard!"', '"Ambush!"', '"You thief!"' },
      ["base.dead"] = { '"Please spare my life."', '"Ahhhh...."' },
      ["base.killed"] = { '"Die thief."', '"You deserve this."' }
    },
    jp = {
      ["base.aggro"] = { "「ガード！ガード！」", "「襲撃だ！」", "「強盗め！」" },
      ["base.dead"] = { "「命だけわぁ」", "「あぁぁ…」" },
      ["base.killed"] = { "「あの世で後悔するがいい」", "「虫けらめ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "bartender",

  texts = {
    en = {
      ["base.aggro"] = { '"Hey  stop it drunkard."', '"Are you sick from drinking too much?"' },
      ["base.calm"] = { "You hear the sound of cocktail shakers.", "\"How 'bout a drink sir?\"", '"We got vintage crim ales."', "The bar is crowded with people." },
      ["base.dead"] = { '"I got killed by a drunkard."', '"This is ridiculous."' },
      ["base.killed"] = { '"Sober up now huh?"' },
      ["base.welcome"] = { "\"Welcome home. I've got some decent ales for you.\"", "\"Are you tired? How'bout a drink?\"" }
    },
    jp = {
      ["base.aggro"] = { "「この酔っ払いめ！」", "「悪酔いはいけませんよ」" },
      ["base.calm"] = { "カクテルをシェイクする音が聞こえる。", "「一杯どうだい？」", "「年季物のクリムエールがあるよ」", "酒場は多くの人でにぎわっている。" },
      ["base.dead"] = { "「酔っ払いごときに…」", "「ふざけた運命だ」" },
      ["base.killed"] = { "「酔いは覚めましたか？」" },
      ["base.welcome"] = { "「お帰りですか。美味い酒を用意してありますよ」", "「お疲れだったでしょう。冷酒でもどうですか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "citizen_2",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "healer",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' },
      ["base.welcome"] = { '"Are you wonded?"', '"Good to see you again. Welcome home."' }
    },
    jp = {
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" },
      ["base.welcome"] = { "「お怪我はありませんか？」", "「無事な姿で何よりです。おかえりなさい」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "nun",

  texts = {
    en = {
      ["base.aggro"] = { '"Atone for you sin."', '"Well  you need to be punished."', '"You sonova..."', '"Shit!"' },
      ["base.calm"] = { "You hear the chants of prayer in the distance.", '"Come hither stray kittens  I shall guide you to the light."', "\"Pray hard. There's always chance for salvation.\"", '"Do unto others as you wish others to do unto you."' },
      ["base.dead"] = { '"God help me!"' },
      ["base.killed"] = { '"Go to hell."' },
      ["base.welcome"] = { '"Are you wonded?"', '"Good to see you again. Welcome home."' }
    },
    jp = {
      ["base.aggro"] = { "「償いなさい」", "「あなたには罰が必要なようですね」", "「てめー♪」", "「くそがーっ」" },
      ["base.calm"] = { "誰かが祈りを捧げる声が聞こえる。", "「おお、この迷える子猫に道標の光を…」", "「祈りなさい。どんな時でも救いはあります」", "「他人を憎んではなりません」" },
      ["base.dead"] = { "「おお、神よー」" },
      ["base.killed"] = { "「地獄に墜ちなさい♪」" },
      ["base.welcome"] = { "「お怪我はありませんか？」", "「無事な姿で何よりです。おかえりなさい」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "trainer",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" },
      ["base.welcome"] = { "「準備はいいかい？いくぞ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "guard",

  texts = {
    en = {
      ["base.aggro"] = { '"Stop there criminal!"', '"You scum! Stay there."', '"You are under arrest."', '"You will pay for your sin."' },
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.aggro"] = { "「お尋ね者だ！」", "「犯罪者め、おとなしくしろ」", "「のこのこ現れるとはな！」", "「罪をつぐなってもらおう」" },
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "palmian_elite_soldier",

  texts = {
    en = {
      ["base.aggro"] = { '"Who the hell released this monster!"', '"Fire  fire  fire!"', '"This is ridiculous."', '"Blood! My blooood!"', '"Holy cow!"', '"What is THIS?"', '"Go go go!"' },
      ["base.dead"] = { "\"Ok  I'm done.\"", '"Arrrrrggghhh!"', '"Man down! Man down!"', '"M-Medic!"', '"We got another man killed!"' }
    },
    jp = {
      ["base.aggro"] = { "「どこの馬鹿がこいつを放った！」", "「撃て、撃て、撃ちまくれー！！」", "「こいつは、ちょっと無理です」", "「隊長！血が血がー！！」", "「くそっ。この化け物め！」", "「なんなんだこの怪物は！」", "「ひるむな、突撃しろ！」" },
      ["base.dead"] = { "「隊長！もうダメです…」", "「うぎゃぁぁぁぁぁぁ」", "「隊長！味方がまた一人やられました！」", "「ぐふっ」", "「ふばぼー」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "zeome",

  texts = {
    en = {
      ["base.aggro"] = { '"Fool!"' },
      ["base.calm"] = { "You hear raspy bitter laughter in the distance…" },
      ["base.dead"] = { '"Impossible!"' },
      ["base.killed"] = { '"Hahaha!"' }
    },
    jp = {
      ["base.aggro"] = { "「愚かな！」" },
      ["base.calm"] = { "ひどくしゃがれた笑い声が聞こえる… " },
      ["base.dead"] = { "「ば、馬鹿な…！」" },
      ["base.killed"] = { "「ふははははっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "at",

  texts = {
    en = {
      ["base.aggro"] = { '"Qy@!!"' },
      ["base.calm"] = { '"Qy@"' },
      ["base.dead"] = { '"Q...Qy...@"' },
      ["base.killed"] = { '"Qy@!"' }
    },
    jp = {
      ["base.aggro"] = { "「Ｑｙ＠！！」" },
      ["base.calm"] = { "「Ｑｙ＠」" },
      ["base.dead"] = { "「Ｑ…Ｑｙ＠…」" },
      ["base.killed"] = { "「Ｑｙ＠！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "orphe",

  texts = {
    en = {
      ["base.calm"] = { "You hear childish laughter  only it's oddly distorted in some eldritch manner", "You have been looking for someone like this…" }
    },
    jp = {
      ["base.aggro"] = { "オルフェ 「お前がこうすることを、予期していなかったとでも？」", "オルフェ 「さあ、少しは楽しませてくれ」" },
      ["base.calm"] = { "何かがクスクスと笑った。", "あなたは誰かに見つめられている感じがした。" },
      ["base.dead"] = { "オルフェ「こんな結末があるとは…」" },
      ["base.killed"] = { " *クスクス* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "whom_dwell_in_the_vanity",

  texts = {
    en = {
      ["base.aggro"] = { "You are like a rabbit fascinated by a snake.", "Someone mutters. {Worthless.}", "You sense death." },
      ["base.calm"] = { "You have been struck by a terrible feeling of powerlessness. ", "The air around here is heavy and sorrowful. But you somehow feel not all is lost.", '"Elishe...why did it have to be you..."' },
      ["base.dead"] = { '"Finally...I come to you...Elishe..."' },
      ["base.killed"] = { '"I live again...in vain."' }
    },
    jp = {
      ["base.aggro"] = { "『虚空を這いずる者』はあなたに冷ややかな視線を送った。", "「くだらない…」と誰かが言った。", "あなたは死を覚悟した。" },
      ["base.calm"] = { "あなたはひどい無力感に襲われた。", "重たい空気が辺りに漂っている。しかし希望はまだ失われてはいない、とあなたは感じた。", "「エリシェ…なぜ……お前が…」" },
      ["base.dead"] = { "「やっと…これでお前の元に…」" },
      ["base.killed"] = { "『虚空を這いずる者』は深いため息をついた。「…また生き延びてしまった」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "loyter",

  texts = {
    en = {
      ["base.aggro"] = { '"Oh what a jerk."', '"Die like a maggot you are."' },
      ["base.calm"] = { "Loyter grumbles incessantly. {How he sounds so miserable...}", "You hear someone muttering sulfurously somewhere", "Loyter mutters to himself. {Why are you still attached to him...}" },
      ["base.dead"] = { '"You are shit."' },
      ["base.killed"] = { '"Huh? Done already?"' }
    },
    jp = {
      ["base.aggro"] = { "「馬鹿な奴だ！」", "「身の程を思い知らせやる」" },
      ["base.calm"] = { "ロイター「…情けないな！」", "誰かが呟く声が聞こえる。", "ロイター「まだあの男に未練があるのか？」" },
      ["base.dead"] = { "「俺が…奴以外の者に負けるだと？」" },
      ["base.killed"] = { "「もう終わりか？」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "miches",

  texts = {
    en = {
      ["base.aggro"] = { '"You molester!"', '"Stop it!"' },
      ["base.calm"] = { "You hear childish laughter nearby", '"You know your face is funny looking. Were you born that way?"', "\"How are your travels? I'd love to go but I'm stuck here...\"", "\"I'm so bored. Maybe we can play a game of Purits & Yeeks later.\"" },
      ["base.dead"] = { '"N-Nooo..."' },
      ["base.killed"] = { '"You are so weak."' }
    },
    jp = {
      ["base.aggro"] = { "「何するのよ、変態！」", "「いや！」" },
      ["base.calm"] = { "小鳥のさえずりのような笑い声がする。", "「ねえ、君って面白い顔してるね」", "「旅は楽しい？」", "「退屈だよ。どこかに連れていって欲しいな」" },
      ["base.dead"] = { "「だめぇ…」" },
      ["base.killed"] = { "「なーんだ、弱いじゃない」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "shena",

  texts = {
    en = {
      ["base.aggro"] = { '"You are drinking too much!"', '"Stop it before I get angry."' },
      ["base.calm"] = { '"Come on in! The ale is flowing well tonight!"', '"Hey! Keep yer stinking hands of the serving ladies!"', "The rowdy crowd is making a fair bit of noise tonight", "You hear the sound of tankerds striking in a toast " },
      ["base.dead"] = { '"Why me?"' },
      ["base.killed"] = { '"Ahhh! Are you alright  sir?"' }
    },
    jp = {
      ["base.aggro"] = { "「ちょっと飲みすぎですよ！」", "「いい加減怒りますからね」" },
      ["base.calm"] = { "「お酒いかが〜」", "「やだっ。どこ触ってるんですか」", " *ざわざわ* ", "盃を交わす音が聞こえる。" },
      ["base.dead"] = { "「なんであたしがこんな目に…」" },
      ["base.killed"] = { "「キャー！お客さま、大丈夫ですか？！" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "the_leopard_warrior",

  texts = {
    en = {
      ["base.aggro"] = { '"If Jarn wishes  then let it be done."', '"Grrrrrr!"', '"Doal!"' },
      ["base.calm"] = { '"Aural...it seems I know that name"', '"Lady Silvia  you are my only princess"' },
      ["base.dead"] = { '"Me...meow...."' },
      ["base.killed"] = { '"Let Janus decide your fate"' }
    },
    jp = {
      ["base.aggro"] = { "「ヤーンがそう望むならば仕方あるまい」", "「ガルルル」", "「ドールめ！」", "「追い詰められたトルクに噛まれぬよう、気をつけなければな」" },
      ["base.calm"] = { "「暁の女神アウラ…その名をどうやら俺は知っているようだ」", "「俺はあなたが好きだ。あなたは俺のたったひとりの姫だ。可愛いシルヴィア」", "「子供たちよ戦え、そして希望しろ」", "「俺は自分が何者で、この仮面は何故かを、着き止めねばならん」", "「俺は…誰だ…？」", "「ヤーンがそう望むのなら」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "「ヤヌスのみ心のままに」", "「ヤーンは与えたまい、また奪いたまう」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "silvia",

  texts = {
    en = {
      ["base.aggro"] = { '"I will beat you with a whip!"', '"You...you insolent peasant! I will bring you to the scaffold!"' },
      ["base.calm"] = { '"Come on  you stupid leopard! You ignorant  mean  stupid  uncouth numbnut!"', "\"Don't touch! Don't touch me  leopard!\"", "You hear someone stamps her feet." },
      ["base.dead"] = { '"To hell with me!"', '"Villain! Devil! Fiend! Murderer  murderer murderer!"' },
      ["base.killed"] = { "\"And you promised you wouldn't leave me alone...\"" }
    },
    jp = {
      ["base.aggro"] = { "「ムチをくれるわよ！」", "「こ、この、無礼者！お前なんか死刑にするわよ！」", "「よくも切ったな！よくも私を切ったな！」", "「アアアアア！ヒィィィィ！人殺し！お父様にいってやる！」", "「いまやっとわかったわ。あなたは私が死ねばいいと本気で思ってるのね！」" },
      ["base.calm"] = { "「何よ、この、ばか豹！いじわるの、ばかの、何もわかってない唐変木のでくのぼう！」", "「触らないで！私に触らないでよ、この豹！」", "誰かが足で床を踏み鳴らす音が聞こえる。", "「どうせ私は姉さんとはメダカとクジラほど違う、ガリガリの痩せっぽっちで貧相なちびの妹よ。私の味方なんて、一人もいやしないんだわ！」", "「あんたが＊＊＊してくれないんなら、宮廷中の男をくわえこんで＊＊＊してやる！」" },
      ["base.dead"] = { "「私なんか、生まれてこなければよかったんだわ！」", "「非人！悪魔！鬼！人殺し、人殺し、人殺し！」" },
      ["base.killed"] = { "「私を一人にしないでって約束した、あんなに固く約束したのに」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "dungeon_cleaner",

  texts = {
    en = {
      ["base.aggro"] = { '"Target accuired!"', '"Resistance is futile!"' },
      ["base.calm"] = { "*bzzzz*whirrrrrrr*click*", "Something is buffing the floor at an inhuman speed" },
      ["base.dead"] = { '"Pwned!"' },
      ["base.killed"] = { '"WTF"' }
    },
    jp = {
      ["base.aggro"] = { "「Target Acquired.」", "「Resistance is futile!」" },
      ["base.calm"] = { "*ぶ〜ん* ", "何かが高速で回転している。" },
      ["base.dead"] = { "「Pwned!」" },
      ["base.killed"] = { "「wtf」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "larnneire",

  texts = {
    en = {
      ["base.aggro"] = { '"Do we really have to fight?"', "\"Sorry  I don't have time for this.\"", "The Elean little girl has an angry look in her beautiful cold eyes." },
      ["base.calm"] = { '"You know the fairy tale where a wicked witch transforms a dashing prince into an monster?"', "The stunning beauty of Elea's face halts your step a moment.", '"The world is thrown into bedlam and chaos. We must remain strong in the face of it."', '"The man we saw in Vernis  he just might be..."', "Someone mutters in mysterious ancient language.", "\"Eleas is already being regarded as a heretic  your lofty dignity isn't helping this.\"" },
      ["base.dead"] = { '"A-ah...I failed my task...this world....this world will...."' },
      ["base.killed"] = { '"Sorry..."' }
    },
    jp = {
      ["base.aggro"] = { "「なぜ戦わなければならないの？」", "「悪いけど、遊んでいる暇は無いの」", "エレアの少女は凍りつくような美しい瞳をとがらせた。" },
      ["base.calm"] = { "「獣に変えられた王子の童話をしっているかしら？」", "痺れるほど美しいエレアの横顔にあなたは見とれた。", "「この世界は今、大きく変わろうとしているの」", "「ヴェルニースで見かけたあの男…まさか…」", "神秘的な古代の言葉で誰かが囁いた。", "「あなたはプライドが高すぎるのよ。ただでさえエレアは異端視されているのに」" },
      ["base.dead"] = { "「うぅ…誰かが…ジャビ王に風の異変を伝えなければ…このままでは…」" },
      ["base.killed"] = { "「ごめんなさい…」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "lomias",

  texts = {
    en = {
      ["base.aggro"] = { '"You repay kindness with ingratitude?"', '"Do you really mean it?"' },
      ["base.calm"] = { "\"Wait'll they hear the news we bring. And they think they have problems. Hah!\"", '"Hey... This is a fine looking cave. I oughta enquire about it sometime. Everyone needs a hideaway..."', "\"Pah! It would take a child less than a day to walk to Vernis  we won't be late.\"", '"Man  that girl at the pub... She could clean my glass if you know what I mean!"', "You hear someone testing the string of his bow." },
      ["base.dead"] = { '"Jesus...you are kidding..."' },
      ["base.killed"] = { "\"There's always someone I can never understand.\"" }
    },
    jp = {
      ["base.aggro"] = { "「恩を仇で返すとはこのことだ」", "「貴様、かの者の手先だったのか？」" },
      ["base.calm"] = { "「異形の森、か…。我等のもたらす真実を、彼らはどう受け止めるか」", "「この洞窟は、なかなか住み心地がよさそうじゃないか」", "「ヴェルニースの炭鉱街までは、子供の足でも一日でたどり着けるだろう」", "「あの酒場の娘にはまいったな！」", "誰かが弓矢を手入れする音が聞こえた。" },
      ["base.dead"] = { "「おいおい、冗談だろう…」" },
      ["base.killed"] = { "「世の中には、おかしな奴がいるものだ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "slan",

  texts = {
    en = {
      ["base.calm"] = { '"H-help me… please..."', '"Is someone there? Help me... The King must be forewarned!"', "You hear cries of help echoing off the walls. They sound quite weak...." }
    },
    jp = {
      ["base.calm"] = { "「…うぅ…」", "「誰か、誰かいないか？」", "何者かが助けを求める声が聞こえる。" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "karam",

  texts = {
    en = {
      ["base.calm"] = { "\"Curse my weakness! This shouldn't have happened.\"", '"This place will be the end of me I fear."', "You hear a low moan of pain somewhere" }
    },
    jp = {
      ["base.calm"] = { "「…不覚だった…」", "「こんな場所が墓場になるとは…」", "何者かのうめき声が聞こえる。" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "erystia",

  texts = {
    en = {
      ["base.aggro"] = { '"Stop it  please!"', '"Why are you doing this?"' },
      ["base.calm"] = { '"I wonder what the runic translation of this is..."', '"Hmm...interesting. Interesting indeed..."', "You hear someone arranging books on shelves." },
      ["base.dead"] = { '"How can you...."' },
      ["base.killed"] = { '"You are useless!"' }
    },
    jp = {
      ["base.aggro"] = { "「やめてください！」", "「あなたは、そんな人だったのですね」" },
      ["base.calm"] = { "「この文はどういう意味かしら…」", "「興味深いわね」", "誰かが本を整理する音が聞こえる。" },
      ["base.dead"] = { "「ひどい…」" },
      ["base.killed"] = { "「この役立たず！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "slime",

  texts = {
    en = {
      ["base.dead"] = { "*putit*" }
    },
    jp = {
      ["base.dead"] = { " *ぷちゅ* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "snail",

  texts = {
    en = {
      ["base.calm"] = { "*Zzzzle*" }
    },
    jp = {
      ["base.calm"] = { "ズルズル…" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "fallen_soldier",

  texts = {
    en = {
      ["base.aggro"] = { '"What the hell!"', '"You will regret this."', '"Ok  no turning back now."', '"Now you die!"', '"Come on chicken."', '"Huh."', '"You touch me  you die."' },
      ["base.dead"] = { '"You....you will pay for this someday..."', '"Nooo!"', '"A murderer!"', '"Stop it!"', '"F-forgive me..."', '"Arrr--rr..."', "\"D-don't!\"" },
      ["base.killed"] = { '"Look at you."', '"Bye bye."' }
    },
    jp = {
      ["base.aggro"] = { "「なにしやがる！」", "「この野郎」", "「今更謝っても遅いぞ」", "「なめやがって」", "「上等だ！」", "「かかってこい、おらぁ」", "「指一本触れて見やがれ」" },
      ["base.dead"] = { "「貴様…覚えていろ」", "「うわぁぁ」", "「人殺し！」", "「やめろー」", "「次があるとは思うなよ」", "「ひぃー」", "「命だけは助けてくれー」" },
      ["base.killed"] = { "「いいざまだ」", "「出直して来い」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "beggar",

  texts = {
    en = {
      ["base.aggro"] = { '"P-please  no sir..."', '"Waaaa!"', '"You get nothing from killing me..."', "\"Don't make a fool of me!\"", '"Why are you doing this?"', '"A violent revolution!"', '"W-w-what...!"' },
      ["base.dead"] = { '"You are cruel."', '"Ahhhh!"', "\"I don't deserve this...\"", "\"It's unfair.\"", '"Beggars always cry..."', '"My life is pathetic."' },
      ["base.killed"] = { '"Weak! Weak!"', '"Huh?"', '"Ha ha ha!"' }
    },
    jp = {
      ["base.aggro"] = { "「やめて下さい、旦那」", "「ひぃ！」", "「私を殺しても何の得にもならないよ」", "「馬鹿にするな！」", "「なぜこんなことを！」", "「暴力反対！」", "「ちょ、ちょっと…！」" },
      ["base.dead"] = { "「殺生な！」", "「ぐわぁ」", "「なんでこんな目に…」", "「ひどい」", "「乞食だからって…」", "「私の人生っていったい」" },
      ["base.killed"] = { "「よわ！」", "「何がしたかったんだ？」", "「ははは！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "farmer",

  texts = {
    en = {
      ["base.killed"] = { '"Weak!"' }
    },
    jp = {
      ["base.aggro"] = { "「なにするだー」", "「やめるだー」" },
      ["base.dead"] = { "「おらは…おらはー！」", "「田舎モンだからって…！」", "「食べ物を粗末にするな！」", "「はぐわ」" },
      ["base.killed"] = { "「よわいべ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "cleaner",

  texts = {
    jp = {
      ["base.aggro"] = { "「なめくじぃ」", "「俺様に歯向かうとはいい度胸だ」" },
      ["base.dead"] = { "「ああ、俺の肉片が街を汚してしまう！」" },
      ["base.killed"] = { "「フハハハハ！」", "「この下等生物め」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "miner",

  texts = {
    jp = {
      ["base.aggro"] = { "「炭鉱の毒にでもやられたか？」", "「この街の平和は俺が守る」" },
      ["base.dead"] = { "「夢だ。これは悪い夢なんだ」", "「うげあー」" },
      ["base.killed"] = { "「炭鉱で鍛えた成果だな」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "bard",

  texts = {
    en = {
      ["base.aggro"] = { '"S-Stop it..!"', '"Was my music that bad?"' },
      ["base.calm"] = { '"Oh I once heard of a place called Nantucket..."', '"Ninety-nine Yeeks in a dank hole. Ninety-nine Yeeks in a Hole!"', '"Crawling in my Robes! These wounds will need a Healer!"', "\"If you go down to the woods today. You're sure of a big surprise. If you go down to the woods today. You'd better go in disguise.\"" },
      ["base.dead"] = { '"No way!"', "\"It's a bitter tirade.\"", "{Did I suck that bad?} " }
    },
    jp = {
      ["base.aggro"] = { "「や、やめてくれたまえ」", "「そんなに耳障りな演奏だったかい？」" },
      ["base.calm"] = { "「タラララララー♪」", "「チキチキ♪」", "「ドナドナドナ〜♪」", "「ダバダ〜♪」" },
      ["base.dead"] = { "「そんな馬鹿な…」", "「厳しい客だぜ」", "「下手で悪かったよ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "sister",

  texts = {
    jp = {
      ["base.aggro"] = { "「おやめなさい」", "「暴力はダメです」" },
      ["base.dead"] = { "「なんという悪」", "「大罪です…」", "「ふにゃー」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "holy_beast",

  texts = {
    en = {
      ["base.calm"] = { '"Happy holy night!"', "The town is awash with people arriving at the festival and drums and whistles make a merry rhythm.", "\"It's a festival!\"", "You feel excited.", "Fervor!" }
    },
    jp = {
      ["base.calm"] = { "「おめでたや。おめでたや」", "祭りは人で溢れかえり、太鼓や笛の音が絶え間なく聞こえる。", "「祭りじゃー」", "あなたはワクワクしてきた。", "祭りの熱気で雪も溶けてしまいそうだ！" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "part_time_worker",

  texts = {
    en = {
      ["base.calm"] = { "\"St.Jure's body pillow for FREE!\"", '"Step right up!"', '"You there lucky one  a beautiful and sweet woman awaits for you!"', '"A flower growing in the desert  fragile yet most noble. A maiden pure in heart with compassion and indomitable will to vanquish evil. Jure of Healing  our only Goddess!"' }
    },
    jp = {
      ["base.calm"] = { "「今なら無料でジュア様の抱き枕が手に入るよ〜」", "「見てらっしゃい、よってらっしゃい」", "「そこの君、清楚で綺麗なお姉さんが君を待ってるよ」", "「この荒れすさんだ世に咲く一輪の花、気高く汚れを知らぬ純白の乙女、その名も癒しのジュア！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "fanatic",

  texts = {
    en = {
      ["base.calm"] = { '"Jure  oh holy Jure  forgive our sins and purify us from all unrighteousness."', "\"We're so ready to see you  Goddness Jure!\"", '"Glory to Jure! May the victory always be with Jure!"', '"Come  become a new servant of Jure today."', '"Death to the heretic! Crack down those who bring shame to the name of Jure!"' }
    },
    jp = {
      ["base.calm"] = { "「ジュア様、ああ、ジュア様、罪深き私たちをどうかお許しください」", "「我々はあなた様のご光臨を強く願っております！」", "「ジュア様に栄光あれ！ジュア様に勝利を！」", "「さあ、あなたもジュア教に改宗しなさい」", "「異教徒に死を！ジュアの名を汚すものに裁きの鉄槌を！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rogue",

  texts = {
    jp = {
      ["base.aggro"] = { "「喧嘩か」", "「みぐるみはいでやるよ」" },
      ["base.dead"] = { "「きさまー」", "「このままでは終わらないぞ」" },
      ["base.killed"] = { "「おねんねしてな」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "prostitute",

  texts = {
    jp = {
      ["base.aggro"] = { "「喧嘩か」", "「みぐるみはいでやるよ」" },
      ["base.dead"] = { "「きさまー」", "「このままでは終わらないぞ」" },
      ["base.killed"] = { "「おねんねしてな」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "prisoner",

  texts = {
    jp = {
      ["base.aggro"] = { "「うわ、なにをする」" },
      ["base.calm"] = { "「だしてくれ！」", "「私は無実なのだよ」" },
      ["base.dead"] = { "「あばよ」", "「死のう」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "artist",

  texts = {
    jp = {
      ["base.aggro"] = { "「感性の下劣なやつめ！」", "「低俗なやつだ」" },
      ["base.dead"] = { "「これぞ芸術！」", "「争いとは無縁の世界に生きていたのに」", "「アートだー！」" },
      ["base.killed"] = { "「人をあやめてしまった！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "noble",

  texts = {
    jp = {
      ["base.aggro"] = { "「無礼者！」", "「ガード、とっととこのアホを捕まえろ」", "「ガード！きてくれー！」" },
      ["base.dead"] = { "「パパにいいつけてやるんだ」", "「なんという！なんという…！」", "「や、やめて…」" },
      ["base.killed"] = { "「ゴミくずめ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "guild_member",

  texts = {
    jp = {
      ["base.aggro"] = { "「侵入者か？」", "「ギルドメンバーを集めろ。敵襲だ！」" },
      ["base.dead"] = { "「無念！」" },
      ["base.killed"] = { "「ネズミめ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "town_child",

  texts = {
    en = {
      ["base.aggro"] = { '"H-help-!"', '"No no!"', '"You are evil."', '"Pervert!"', '"G-g-go away!"', '"Why are you teasing me?"', '"Adults."' },
      ["base.dead"] = { '"Mom...."', '"A---ahh-"', '"Go to hell!"', '"Waaaan!"', '"Urghhh!"', '"My life ends here."', '"Sorry  mom  dad...."' },
      ["base.killed"] = { '"Weak! You are weak!"' }
    },
    jp = {
      ["base.aggro"] = { "「たすけてー」", "「や、やめて」", "「悪の手先だ！」", "「変質者！」", "「わ、わわあ」", "「なんで叩くの？」", "「大人はこれだから」" },
      ["base.dead"] = { "「おかーさん…」", "「えーん」", "「地獄に落ちろ！」", "「わぁぁん」", "「うぐぅ！」", "「もっと…生きたかった…」", "「先立つ不幸をお許し下さい…」" },
      ["base.killed"] = { "「この人よわーい」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "old_person",

  texts = {
    en = {
      ["base.aggro"] = { '"Stop it  please."', '"Unreasonable!"', '"You foul scum."', '"Fool!"', '"Youngsters."', '"Respect elders!"', '"Leave me alone."' },
      ["base.dead"] = { '"God will punish you."', '"My remaining years..."', '"Demon!"', '"Grrhhh"', '"I hate this planet."', '"Am I dead?"' },
      ["base.killed"] = { '"Holy...why are you so weak?"', '"Muwahahaha!"' }
    },
    jp = {
      ["base.aggro"] = { "「止めてくだされ」", "「ご無体な」", "「なんと卑劣な」", "「たわけ！」", "「いまどきの若者は…」", "「老人をいたわれ！」", "「金などもっていないんじゃ」" },
      ["base.dead"] = { "「神様はみておるぞ！」", "「わしの老後が…」", "「鬼！」", "「ぐほぉ」", "「化けて出ちゃるぞ」", "「わしゃ死んだのか」" },
      ["base.killed"] = { "「なんとよわっちぃ奴じゃ」", "「いまどきの若者はなっとらんのぉ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "punk",

  texts = {
    jp = {
      ["base.aggro"] = { "「チキショー」", "「カモンベイベー」", "「ウラァ」", "「ヘドぶち吐きなッ！」", "「さあ、お仕置きの時間だよ」", "「コラー」" },
      ["base.dead"] = { "「逃げろぉぉ」", "「お前プッツンしてるぜ」", "「くそったれー」", "「やめてくれー」", "「うそだー」", "「俺は負けんのだぁ」" },
      ["base.killed"] = { "「二度と俺を馬鹿にするな」", "「ギャハハハハ！」", "「ゴゥトゥヘル」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "kamikaze_samurai",

  texts = {
    jp = {
      ["base.aggro"] = { "「武士とは死ぬこととみつけたり！」", "「玉砕じゃ！」", "「死なばもろとも」" },
      ["base.dead"] = { "「バンザーイ！」", "「スシ！」" },
      ["base.killed"] = { "「討ち取ったり！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "hard_gay",

  texts = {
    en = {
      ["base.aggro"] = { '"Foooooo!"', '"Fooooo"', '"Foooooo!"' },
      ["base.calm"] = { '"Foooooo!"', '"Fooooo"', '"Foooooo!"' },
      ["base.dead"] = { '"Foooooo!"', '"Fooooo"', '"Foooooo!"' },
      ["base.killed"] = { '"Foooooo!"', '"Fooooo"', '"Foooooo!"' },
      ["base.welcome"] = { '"Foooooo!"', '"Fooooo"', '"Foooooo!"' }
    },
    jp = {
      ["base.aggro"] = { "「フーーーーｰｰ！」", "「フーーー」", "「フゥーーーー！」" },
      ["base.calm"] = { "「フーーーーｰｰ！」", "「フーーー」", "「フゥーーーー！」" },
      ["base.dead"] = { "「フーーーーｰｰ！」", "「フーーー」", "「フゥーーーー！」" },
      ["base.killed"] = { "「フーーーーｰｰ！」", "「フーーー」", "「フゥーーーー！」" },
      ["base.welcome"] = { "「フーーーーｰｰ！」", "「フーーー」", "「フゥーーーー！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rodlob",

  texts = {
    jp = {
      ["base.aggro"] = { "「ケケケッ」", "「コロセ！」", "「愚か者に死を」" },
      ["base.dead"] = { "「イーク万歳！」" },
      ["base.killed"] = { "「イーク万歳！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "hot_spring_maniac",

  texts = {
    jp = {
      ["base.aggro"] = { "「何をするんですか！」", "「野蛮人！」", "「私だって」" },
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" },
      ["base.killed"] = { "「市民パワー」", "「ぺっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "citizen",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.aggro"] = { "「何をするんですか！」", "「野蛮人！」", "「私だって」" },
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" },
      ["base.killed"] = { "「市民パワー」", "「ぺっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "sales_person",

  texts = {
    jp = {
      ["base.aggro"] = { "「ガード！ガード！」", "「襲撃だ！」", "「強盗め！」" },
      ["base.dead"] = { "「命だけわぁ」", "「あぁぁ…」" },
      ["base.killed"] = { "「あの世で後悔するがいい」", "「虫けらめ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "sailor",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "captain",

  texts = {
    en = {
      ["base.dead"] = { '"I was a good citizen."', '"Go to hell!"', '"I give up."', '"Nooooo....."', '"Is it a joke?"', '"Why me."', '"W-What have you done!"' }
    },
    jp = {
      ["base.dead"] = { "「私は善良な市民だったのに」", "「くそめ」", "「まいった」", "「ぐえ」", "「嘘でしょ」", "「なぜなんだー」", "「何の冗談ですか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "stersha",

  texts = {
    en = {
      ["base.calm"] = { "The quiet majesty of the room makes you feel small and grubby", "You note just how alert and well armed the guards are", "Somewhere  a harpsicord is playing a tune befitting nobility" }
    },
    jp = {
      ["base.aggro"] = { "「おやめなさい！」", "「皆の者、この曲者をどうにかするのです」" },
      ["base.calm"] = { "荘厳な感じが漂っている。", "辺りは厳重に警備されている。", "宮廷から華麗な音楽の響きが聞こえる。" },
      ["base.dead"] = { "「無念じゃ…」" },
      ["base.killed"] = { "「さあ、この見苦しい死体を片付けるのです」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "xabi",

  texts = {
    jp = {
      ["base.aggro"] = { "「おお、乱心者だ！」", "「近衛兵、何をしている。奴をとらえよ！」", "「血迷ったか！」" },
      ["base.dead"] = { "「役に立たない兵どもだ」" },
      ["base.killed"] = { "「愚か者め」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "titan",

  texts = {
    en = {
      ["base.aggro"] = { "*THUMP*" }
    },
    jp = {
      ["base.aggro"] = { " *ドスン* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "brown_bear",

  texts = {
    jp = {
      ["base.dead"] = { "「うぉーん…」" },
      ["base.killed"] = { "「ぐるる」", "「ぐるぁ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "spider",

  texts = {
    jp = {
      ["base.aggro"] = { " *カサカサ* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "golem",

  texts = {
    jp = {
      ["base.aggro"] = { " *ガチャ* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "missionary_of_darkness",

  texts = {
    jp = {
      ["base.aggro"] = { "「改宗せよ」" },
      ["base.dead"] = { "「神はいないのですか！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "mercenary",

  texts = {
    jp = {
      ["base.aggro"] = { "「お尋ね者だ！」", "「犯罪者め、おとなしくしろ」", "「のこのこ現れるとはな！」", "「罪をつぐなってもらおう」" },
      ["base.dead"] = { "「ぐふっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rogue_party",

  texts = {
    jp = {
      ["base.aggro"] = { "「イヒヒヒヒ」", "「もうすぐ殺してあげるよ」", "「かわいそうに、ウヒャ」", "「おまえさん、ついてないな」", "「馬鹿な選択をしたね」" },
      ["base.dead"] = { "「たちけて」", "「ひぃぃ、こいつ強い」", "「命だけは！」" },
      ["base.killed"] = { "「ついてなかったな」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "yerles_machine_infantry",

  texts = {
    jp = {
      ["base.aggro"] = { "「撃てぇ！」", "「弾が尽きるまで撃て！」", "「虫けらめェ！」" },
      ["base.dead"] = { "「隊長！もうだめです」", "「メディーック！！」", "「マンダウン！マンダウン！」" },
      ["base.killed"] = { "「ターゲット・ダウン！」", "「グッドジョブ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "gilbert",

  texts = {
    en = {
      ["base.calm"] = { '"Help the helpless! Crush the vileness"', '"Atten-TION! Salute!"', '"For the Kingdom  we shall never fall!"', "\"Who's house? Mah House!\"" }
    },
    jp = {
      ["base.aggro"] = { "「撃てぇ！」", "「フハー！」" },
      ["base.calm"] = { "「困ったことになったぞ」", "「敬礼！」", "「新王国め…」", "「フハハハハッ」" },
      ["base.dead"] = { "「フハー…」" },
      ["base.killed"] = { "「フハハハハ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "juere_infantry",

  texts = {
    jp = {
      ["base.aggro"] = { "「イェルス兵を殺せ！」", "「突っ込め！」", "「突撃！突撃！」", "「ひるむな！」", "「ウォォォ」" },
      ["base.dead"] = { "「ギャァァァァ」", "「衛生兵！！」", "「大佐、また一人死にました！」", "「仲間が戦闘不能です、大佐！」" },
      ["base.killed"] = { "「敵兵の首とったり！」", "「敵兵撃破！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "cat",

  texts = {
    en = {
      ["base.aggro"] = { '"Meow!"', '"Mew mew!"', '"Mew!"', '"Meow"' },
      ["base.calm"] = { '"Meow."', '"Mew."', '"Mew mew."', '"Rowr!"', '"Mewl."' },
      ["base.dead"] = { '"Me...meow...."' },
      ["base.killed"] = { "*hiss*", '"Meoow!"', '"Meew!"', '"Mew!"', '"Meow meow."' }
    },
    jp = {
      ["base.aggro"] = { "「ニャー！」", "「ニャウ！」", "「ニャン！」", "「ゥニャ！」" },
      ["base.calm"] = { "「ミャア」", "「にゃ」", "「ミャ」", "「にゅぅ」", "「ニャア」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "* ふしゅぅ * ", "「ニャァー！」", "「にゃー」", "「ゥニャ！」", "爪を研ぐ音が聞こえる。" },
      ["base.welcome"] = { "「おかえりニャン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "silver_cat",

  texts = {
    en = {
      ["base.aggro"] = { '"Meow!"', '"Mew mew!"', '"Mew!"', '"Meow"' },
      ["base.calm"] = { '"Meow."', '"Mew."', '"Mew mew."', '"Mew!"', '"Mewl."' },
      ["base.dead"] = { '"Me...meow...."' },
      ["base.killed"] = { "*hiss*", '"Meoow!"', '"Meew!"', '"Mew!"', '"Meow meow."' }
    },
    jp = {
      ["base.aggro"] = { "「ニャー！」", "「ニャウ！」", "「ニャン！」", "「ゥニャ！」" },
      ["base.calm"] = { "「ミャア」", "「にゃ」", "「ミャ」", "「にゅぅ」", "「ニャア」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "* ふしゅぅ * ", "「ニャァー！」", "「にゃー」", "「ゥニャ！」", "爪を研ぐ音が聞こえる。" },
      ["base.welcome"] = { "「おかえりニャン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "stray_cat",

  texts = {
    en = {
      ["base.aggro"] = { "\"I'm gonna be killed.\"", "\"I'm gonna die!\"" },
      ["base.calm"] = { '"Do you know where my home is?"', "\"I'm going home.\"", "\"I'm going home!\"", '"Momma? Where are you?"', '"Home! Nyaow!"' },
      ["base.dead"] = { "\"I'm...going...hom....e...\"" },
      ["base.killed"] = { '"That scared me!"' }
    },
    jp = {
      ["base.aggro"] = { "「ころさえう」", "「しぬぅ！」" },
      ["base.calm"] = { "「おうちしってう？」", "「おうちかえう」", "「おうちかえう！」", "「ママどっち？おうちどっち？」", "「ニャア」" },
      ["base.dead"] = { "「おうち…かえ…ぅ…」" },
      ["base.killed"] = { "「あぁ〜ビックリしたぁ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "lion",

  texts = {
    en = {
      ["base.calm"] = { "You hear the near silent footfalls of a cat. A Big cat." }
    },
    jp = {
      ["base.aggro"] = { "「ガウッ」", "「ガルル！」" },
      ["base.calm"] = { "「ガルルル…」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "「ガオー」", "「ガル♪」" },
      ["base.welcome"] = { "「おかえりニャン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "cacy",

  texts = {
    jp = {
      ["base.aggro"] = { "「ガウッ」", "「ガルル！」" },
      ["base.calm"] = { "「ガルルル…」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "「ガオー」", "「ガル♪」" },
      ["base.welcome"] = { "「おかえりニャン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "carbuncle",

  texts = {
    jp = {
      ["base.aggro"] = { "ニャー", "ニャウ", "ニャン", "ゥニャ" },
      ["base.calm"] = { "「ミャア」", "「にゃ」", "「ミャ」", "「にゅぅ」", "「ニャア」" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "* ふしゅぅ *", "「ニャァー！」", "「にゃー」", "「ゥニャ！」", "爪を研ぐ音が聞こえる。" },
      ["base.welcome"] = { "「おかえりニャン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "dog",

  texts = {
    jp = {
      ["base.dead"] = { "「クゥン…」" },
      ["base.killed"] = { "「わん！」", "「ゥワン！」" },
      ["base.welcome"] = { "「おかえりワン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "poppy",

  texts = {
    en = {
      ["base.calm"] = { "You hear the high pitched yips of a young dog", "A plaintive howl is heard in the distance", "Rowf!" }
    },
    jp = {
      ["base.calm"] = { "「くぅ〜」", "「ぁぅぁぅ」", "「ぅ〜」" },
      ["base.dead"] = { "「クゥン…」" },
      ["base.killed"] = { "「わん！」", "「ぁぅぁぅ！」" },
      ["base.welcome"] = { "「おかえりワン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rilian",

  texts = {
    en = {
      ["base.aggro"] = { '"What! Stop!"' },
      ["base.calm"] = { '"Poppy!"', '"Wuff wuff."' },
      ["base.dead"] = { '"Poppy  where are you poppy...."' },
      ["base.killed"] = { '"Idiot!"' }
    },
    jp = {
      ["base.aggro"] = { "「なにするの！」" },
      ["base.calm"] = { "「ポピー！」", "「わん〜わん〜」" },
      ["base.dead"] = { "「来世は犬になりたい…」" },
      ["base.killed"] = { "「めっ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "tam",

  texts = {
    en = {
      ["base.calm"] = { '" hate those bloody cats!"', '"Come closer kitty  I gotta present for ya!"', "\"I've got your number  mate. It's down to two for you. Ahh! There's a oner. Ha ha  yes. Not long for you now!\"" }
    },
    jp = {
      ["base.calm"] = { "「ひっ！」", "「猫はどうしてあんなに恐ろしいのだろう」", "「細い目が苦手です」" },
      ["base.dead"] = { "「うわー猫ー」" },
      ["base.killed"] = { "「ふんっ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "little_girl",

  texts = {
    en = {
      ["base.dead"] = { '"No....no...!"', "\"I'm sorry I failed you.\"" },
      ["base.killed"] = { "The little girl brushes dust off her clothes.", "The little girl smiles at you.", "You look admiringly at the little girl.", '"Another death. *grin* "' },
      ["base.welcome"] = { '"Welcome home!"' }
    },
    jp = {
      ["base.dead"] = { "「きゃぁー」", "「ダメぇ！」" },
      ["base.killed"] = { "少女は服のほこりをはらった。", "少女はあなたを見てにっこり笑った。", "あなたは少女に見とれた。", "「うふふ♪」" },
      ["base.welcome"] = { "「おかえりなさい♪」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rat",

  texts = {
    jp = {
      ["base.dead"] = { "「チュー！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "public_performer",

  texts = {
    jp = {
      ["base.aggro"] = { "愉快な音楽が聞こえる。" },
      ["base.dead"] = { "「出直してくる」" },
      ["base.welcome"] = { "「おか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "frisia",

  texts = {
    jp = {
      ["base.dead"] = { "「負けたニャー」" },
      ["base.killed"] = { "フリージアは死体を玩具にして遊び始めた。" }
    }
  }
}

data:add {
   _type = "base.tone",
   _id = "younger_sister",

   texts = {
      jp = {
         ["base.calm"] = {
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃんー」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん！」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃ〜ん」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃんっ」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん？」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "〜ちゃん」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん♪」" end
         },
         ["base.dead"] = { "「ダメぇ！」" },
         ["base.killed"] = { "あなたは妹の頭をなでた。", "あなたは妹の姿に目を細めた。", "妹は上目づかいにあなたの顔を覗いた。" },
         ["base.welcome"] = {
            function(t, env) return "「おかえり、お" .. env.i18n.nii(t) .. "ちゃん！」" end,
            function(t, env) return "「おかえりなさーい、お" .. env.i18n.nii(t) .. "ちゃん♪」" end,
            function(t, env) return "「待ってたよ、お" .. env.i18n.nii(t) .. "ちゃん」" end
         }
      }
   }
}

data:add {
   _type = "base.tone",
   _id = "younger_cat_sister",

   texts = {
      jp = {
         ["base.calm"] = {
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃんー」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん！」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃ〜ん」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃんっ」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん？」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "〜ちゃん」" end,
            function(t, env) return "「お" .. env.i18n.nii(t) .. "ちゃん♪」" end
         },

         ["base.dead"] = { "「ダメぇにゃ！」" },
         ["base.killed"] = { "あなたは妹の頭をなでた。", "あなたは妹の姿に目を細めた。", "妹は上目づかいにあなたの顔を覗いた。", "「うにゃん」" },
         ["base.welcome"] = {
            function(t, env) return "「おかえりにゃ、お" .. env.i18n.nii(t) .. "ちゃん！」" end,
            function(t, env) return "「おかえりなさいにゃー、お" .. env.i18n.nii(t) .. "ちゃん♪」" end,
            function(t, env) return "「待ってたにゃ、お" .. env.i18n.nii(t) .. "ちゃん」" end
         }
      }
   }
}

data:add {
  _type = "base.tone",
  _id = "young_lady",

  texts = {
    jp = {
      ["base.dead"] = { "「きゃぁー」", "「ダメぇ！」" },
      ["base.killed"] = { "嬢は服のほこりをはらった。", "嬢はあなたを見てにっこり笑った。", "あなたは嬢に見とれた。", "「うふふ♪」" },
      ["base.welcome"] = { "「おかえりなさい♪」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "utima",

  texts = {
    jp = {
      ["base.dead"] = { "「ピー…ザザザザ…」" },
      ["base.killed"] = { "「ターゲット破壊確認！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "azzrssil",

  texts = {
    jp = {
      ["base.dead"] = { "「ひぃ」" },
      ["base.killed"] = { "不浄なる者はあなたの死体をむさぼった。" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "garokk",

  texts = {
    en = {
      ["base.calm"] = { "You hear the rhymthic clang of a hammer on steel", "You hear the whoosh of a bellows being pumped", "You hear the perfect ring of steel-on-steel. It makes your blood race", '"And just what shall you be  oh noble ingot? A dagger perhaps  an axe blade by chance? Let us find out..."', '"Ah! A good shipment of steel today. Oh  what to make  decisions  decisions..."', '"With this  I have created half a legend. Your wielder will make the other half with you."', "\"Let's just sit you on the shelf oh noble blade  for soon your brothers shall join you.\"" }
    },
    jp = {
      ["base.calm"] = { " *トンカン*  ", " *カーン*  ", " *キン*  ", "鉄を打つ音が響いている。", "「つまらんのう」", "「ミラルの奴め、何の役にも立たないものばかり作りおって」", "「宝の持ち腐れじゃ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "miral",

  texts = {
    en = {
      ["base.calm"] = { '"Oh  what to make for dinner."', '"All work and no play makes Miral a dull boy."', "\"There's never enough time in the world to get everything done.\"", '"Guests? Goodness it has been a while indeed."', "\"I've got a cat I wanna frame! And now nothing shall ever be the same.\"" }
    },
    jp = {
      ["base.calm"] = { "「今日のご飯はなんにしよう」", "「ガロクの作品には遊びがないね」", "「暇だぬ」", "「おお、客人かな？」", "「猫 イズ フリ〜ダ〜ム♪ 猫 イズ フリ〜ダ〜ム♪」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "twintail",

  texts = {
    en = {
      ["base.calm"] = { "All around you is the sensation of being in a sacred place", "You have seldom felt such an air of peace", "All around is very quiet  yet you aren't the least bit lonely", "In your mind you hear the strange echoes of a voice in prayer" }
    },
    jp = {
      ["base.calm"] = { "辺りは神聖な雰囲気に包まれている。", "あなたは何者かの穏やかな視線を感じた。", "とても静かで、平和な場所だ。", "心の中で、奇妙な祈りの声がこだました。" },
      ["base.dead"] = { "「ニャァー…ァ」" },
      ["base.killed"] = { "* ふしゅぅ *", "「ニャァー！」", "「にゃー」", "「ゥニャ！」", "爪を研ぐ音が聞こえる。" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "silver_wolf",

  texts = {
    en = {
      ["base.calm"] = { "All around you is the sensation of being in a sacred place", "You have seldom felt such an air of peace", "All around is very quiet  yet you aren't the least bit lonely", "In your mind you hear the strange echoes of a voice in prayer" }
    },
    jp = {
      ["base.calm"] = { "辺りは神聖な雰囲気に包まれている。", "あなたは何者かの穏やかな視線を感じた。", "とても静かで、平和な場所だ。", "心の中で、奇妙な祈りの声がこだました。" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "nurse",

  texts = {
    jp = {
      ["base.aggro"] = { "ナースの匂いがする…" },
      ["base.dead"] = { "「キャァー」" },
      ["base.welcome"] = { "「おかえりなさい。怪我はしていませんか♪」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "rich_person",

  texts = {
    jp = {
      ["base.aggro"] = { "「金か？金が欲しいのか？」", "「汚い手で触らないでくれるか」", "「周りの衆、見てないで助けぬか」", "「金の亡者め！」" },
      ["base.dead"] = { "「貴様には一銭もやらん…」", "「なんとまあ」", "「下衆め」", "「まだ死にたくないー…ぐぉ」", "「遺言書いといてよかったわ」" },
      ["base.killed"] = { "「フン」" },
      ["base.welcome"] = { "「帰ってきおったか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "noble_child",

  texts = {
    jp = {
      ["base.aggro"] = { "「無礼者！」", "「お父上に言いつけてやる」", "「下郎め」", "「汚い！触るな！」", "「誰か！」", "「下がれ！」" },
      ["base.dead"] = { "「うわぁ」", "「こ、殺さないで」", "「助、助けて…うぐ」", "「お父上ぇー」", "「む、無念」" },
      ["base.killed"] = { "「この人よわーい」" },
      ["base.welcome"] = { "「チェッ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "tourist",

  texts = {
    jp = {
      ["base.aggro"] = { "「観光客だからって馬鹿にするな」", "「なんて治安の悪い国だ」", "「野蛮な土地だな」", "「金などもってないぞ」" },
      ["base.dead"] = { "「こんな国二度とくるか」", "「無差別テロだー」", "「いやーん」" },
      ["base.killed"] = { "「弱い弱い」" },
      ["base.welcome"] = { "「おかえり。いやぁ、いい家に住ませてもらっています」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "festival_tourist",

  texts = {
    en = {
      ["base.calm"] = { "\"Let's check the food stall.\"", '"No! I want to play a little longer!"', '"What a noisy street."', "\"So it's the holy night festival people were talking about...\"", '"Hey look  those children are making cute snowmen."', '"Where does the giant come from?"', '"Holy cow!"', "\"It's that time of year again.\"", '"Aha  some human garbage."' }
    },
    jp = {
      ["base.aggro"] = { "「観光客だからって馬鹿にするな」", "「なんて治安の悪い国だ」", "「野蛮な土地だな」", "「金などもってないぞ」" },
      ["base.calm"] = { "「屋台でおいしいもの売ってるかな？」", "「今日ははじけるぜ」", "「なんとも騒々しいな」", "「これが噂の聖夜祭か…」", "「見て見て、子供が雪だるまをつくっているよ」", "「なんだあの巨人は！」", "「すげえ！」", "「もう今年も終わりなんだな」", "「見ろ人がゴミのようだ」" },
      ["base.dead"] = { "「こんな国二度とくるか」", "「無差別テロだー」", "「いやーん」" },
      ["base.killed"] = { "「弱い弱い」" },
      ["base.welcome"] = { "「おかえり。いやぁ、いい家に住ませてもらっています」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "kaneda_bike",

  texts = {
    en = {
      ["base.aggro"] = { '"Teeee tsuuu oooooo!!."', "\"Yo  what's up? A fight?\"", "\"Relax  it's gonna take some time to warm my engine up.\"" },
      ["base.calm"] = { "*Varoom!*", "*Va-Va-Va*" },
      ["base.dead"] = { "*Pan*" },
      ["base.killed"] = { '"My body is too peaky for ya."', "\"Just hold on Tetsuo. I'm gonna find you to end your pain.\"" }
    },
    jp = {
      ["base.aggro"] = { "「てつぅぅぅうううおおおおおおお！！」", "「よう、どうした。揉め事か？」", "「やっとモーターのコイルが温まって来た所だぜ」" },
      ["base.calm"] = { "*ブルン ブルン* ", "*バババババ* " },
      ["base.dead"] = { "*ぷすん* " },
      ["base.killed"] = { "「ピーキーすぎてお前には無理だよ」", "「テツオ、まってろよ。俺が苦痛を終わらせてやる」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "cub",

  texts = {
    en = {
      ["base.aggro"] = { '"Craaaap! You are so dead!."', '"You dorf  get away get away!"' },
      ["base.calm"] = { "*Bo-Bo-Bo*", "*Pusss*" },
      ["base.dead"] = { "*Pan*" },
      ["base.killed"] = { '"Teeee tsuuu oooooo!!."', "\"Yo  what's up? A fight?\"", "\"Relax  it's gonna take some time to warm my engine up.\"" }
    },
    jp = {
      ["base.aggro"] = { "「われぇ、いい度胸じゃぁ！」", "「おんどりゃぁ！」" },
      ["base.calm"] = { "* ボ ボ ボ * ", "* プスン * " },
      ["base.dead"] = { "*ぷすん* " },
      ["base.killed"] = { "「てつぅぅぅうううおおおおおおお！！」", "「よう、どうした。揉め事か？」", "「やっとモーターのコイルが温まって来た所だぜ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "chicken",

  texts = {
    en = {
      ["base.calm"] = { "You hear something scratching for worms", '"*Bwwwuuuuu-buk-buk-buk-buKAWK*"', "You hear poultry in the distance" }
    },
    jp = {
      ["base.calm"] = { " *クックッ* ", "「コケー」", "「コッ」" },
      ["base.dead"] = { "「コケー」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "ebon",

  texts = {
    en = {
      ["base.calm"] = { "You hear a bonfire in the distance  only it sounds like it's breathing" }
    },
    jp = {
      ["base.aggro"] = { "「ウフハァ」", "「グゴガー」", "「ギャオース！」", " *どすん* ", " *ドスッ* " },
      ["base.calm"] = { "「ぐぉぉぉん」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "moyer_the_crooked",

  texts = {
    en = {
      ["base.calm"] = { '"Hey now  I stopped  I stopped!"', "\"Behold! a Legendary Giant of Fire! Be careful you aren't burned now.\"", "\"And if you think that's special  wait till you see what I got over here!\"" }
    },
    jp = {
      ["base.aggro"] = { "「観光客だからって馬鹿にするな」", "「なんて治安の悪い国だ」", "「野蛮な土地だな」", "「金などもってないぞ」" },
      ["base.calm"] = { "モイアー「さあ、寄った寄った！」", "モイアー「これなるは伝説の火の巨人、見なきゃ損だよ！」", "モイアー「他の店じゃ手に入らない珍品を見ていってくれ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "maid",

  texts = {
    en = {
       ["base.calm"] = {
          "\"Master〜\"",
          "\"Oh Master  I don't do THOSE sorts of things♪...\"",
          "The maid looks good enough to touch"
       }
    },
    jp = {
       ["base.aggro"] = { "「おいたが過ぎますよ！」", "「お仕置きです！」" },
       ["base.calm"] = {
          function(t, env) return "「" .. env.i18n.syujin(t) .. "〜」" end,
          "「用事はありませんか♪」",
          "メイドの熱い視線を感じる…"
       },

      ["base.dead"] = {
         "「ダメぇ！」",
         function(t, env) return "「" .. env.i18n.syujin(t) .. "ー！」" end
      },

      ["base.welcome"] = {
         function(t, env) return "「おかえりなさいませ、" .. env.i18n.syujin(t) .. "〜」" end,
         "「おかえりなさいまし〜」"
      }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "ebon2",

  texts = {
    en = {
      ["base.calm"] = { "You hear a bonfire in the distance  only it sounds like it's breathing  AND moving..." }
    },
    jp = {
      ["base.aggro"] = { "「ウフハァ」", "「グゴガー」", "「ギャオース！」", " *どすん* ", " *ドスッ* " },
      ["base.calm"] = { "「ぐぉぉぉん」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "gwen",

  texts = {
    en = {
      ["base.calm"] = { '"Oh my! Such pretty flowers♪"', "\"Can I tag along? I won't be a bother♪\"", "\"I hope Sandra's red cape...♪\"", '"Eat flowers evil-doer!♪"', '"Red is the color of love  of blood  and of roses♪"', '"A crown of flowers did his mother weave with all her heart...♪"', '"♪La  laaaah  la  la-la. Lah  la-la   la la....♪"' }
    },
    jp = {
      ["base.calm"] = { "「あー…かわいいお花！」", "「ついていっていい？」", "「サンドラさんの赤いケープほしい…」", "「ざっつあぷりちーふらわー」", "「赤って好きな色なの〜」", "「この花の冠はお母さんに編んでもらったの」", "「るるる♪」" },
      ["base.dead"] = { "「どうして、そんなことするの？」" },
      ["base.killed"] = { "「怖いのはいや…」" },
      ["base.welcome"] = { "「あ…もどってきた！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "pael",

  texts = {
    en = {
      ["base.calm"] = { '"Mother…"', '"Do not go alone."', '"Oh  look at you…"' }
    },
    jp = {
      ["base.calm"] = { "「おかあさん…」", "「ひとりにしないでよ」", "「みゅ…」" },
      ["base.dead"] = { "「ごめんね…ごめんね…おかあさん」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "lily",

  texts = {
    en = {
      ["base.calm"] = { '"Pael  such a spoiled child…dear oh dear."', "\"Hush now  I've got you.\"", '"I hope Pael is not in trouble with the guards again…"', '"Now you be good dear  understand?"' }
    },
    jp = {
      ["base.calm"] = { "「うふっ。パエルはいつまでも甘えん坊さんね」", "「あらあら。心配しないでも、私は平気よ」", "「けほっ。けほっ」", "「いい子ね」" },
      ["base.dead"] = { "「ああ…パエル…パエル…」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "raphael",

  texts = {
    en = {
      ["base.calm"] = { '"Ladies! The line starts here!"', '"No woman can resist my charms  be they my dashing good looks  my wit and charm  or even my coinpurse."', '"ero-ero-ero-ero  mushroom  mushroom!"', '"I am the Gods gift to women. Come and get a memory you shall never forget!"' }
    },
    jp = {
      ["base.aggro"] = { "「真の男ってものを見せてやるよ」" },
      ["base.calm"] = { "「あんな極上の女はそうはいねえ」", "「俺の手に掛かれば、どんな女もイチコロよ」", " *レロレロレロ* ", "「まったく罪な男に生まれちまったもんだ」" },
      ["base.dead"] = { "「ママー！」" },
      ["base.killed"] = { "「ペッ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "ainc",

  texts = {
    en = {
      ["base.calm"] = { "\"Let's roll!\"", "\"I may be new to this whole knight gig  but I won't be for long!\"", "\"Are my spurs polished enough you think? I'd just die if a senior thought they were sub-par.\"", "You hear someone adjusting their armor for the umpteenth time" }
    },
    jp = {
      ["base.aggro"] = { "「けが人相手に卑怯な！」" },
      ["base.calm"] = { "「イーック」", "「か、かみかぜ…」", "「ィィーック」", "「なんという生物だ」" },
      ["base.dead"] = { "「ああ…立派な騎士になりたかった…」" },
      ["base.killed"] = { "「ガードに突き出してやる」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "arnord",

  texts = {
    en = {
      ["base.calm"] = { '"Pah  a minor flesh wound…"', '"Come closer… I got rounds for this thing still…"', "\"It's not a tumor!\"", "\"I'll be back.\"" }
    },
    jp = {
      ["base.aggro"] = { "「うわぁぁぁ！」" },
      ["base.calm"] = { "「ヤ、ヤツらがくる！」", "「撃つのを止めるな…ヤツらを近づけるな！」", "「オーマイガッ！」", "「神よぉ…」" },
      ["base.dead"] = { "「爆死よりはマシか」" },
      ["base.killed"] = { "「アポ！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "mia",

  texts = {
    en = {
      ["base.calm"] = { '"I nyo talk funny  nyou talk funny♪"', '"Nyah! Water! I hates it so."', '"Pug!"', '"Nyo touching! No Bump-Bump for nyou."', "\"♪Nyobody knyows the touble Mia's seen  nyobody knyows Mia's Tru-bull♪\"", "You hear the oddest voice in the crowd  it is lilting and...cat-like?", '"Meow♪1"' }
    },
    jp = {
      ["base.calm"] = { "「るんるんるん♪」", "「うみみゃ？」", "「にしし！」", "「ふ〜んふ〜んふ〜ん♪1」", "「きのこのこのこげんきのこぉ〜♪ 」", "「おー。えりんぎまいたけぶなしめじぃ〜」", "「フーン　フンフン　フーン　フンフン　ネコのフ〜ン♪　フーン　フンフン　フーン　フンフン　かたい♪」" },
      ["base.dead"] = { "「はわわ、きっと来世は猫に生まれるんだモン」" },
      ["base.killed"] = { "「アーン、バカ♪」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "renton",

  texts = {
    en = {
      ["base.calm"] = { "\"I mean there's nothing in my soul but pain and misery. Oh and agony too  can't leave that out.\"", '"My body will keep moving  like a machine  but without the oils of love  my heart will not stop squeaking"', "You hear the shuffling step of a man who's world is nothing but pain and misery. With just an aftertase of agony  for good measure", '"Will the kiss of Death bring an end to the cloying  double-plus-ungood that is my life?"' }
    },
    jp = {
      ["base.aggro"] = { "「ああ、わかりやすくていいね」" },
      ["base.calm"] = { "「意味なんてものはないさ」", "「身体はまだ動くよ、油の切れた機械のように。だが心は…」", "「もし生まれ変われるのなら…」", "「もう死んでもいいかな？」" },
      ["base.dead"] = { "「死か。別に何も感じない」" },
      ["base.killed"] = { "「心配するな。生きている価値なんて、もともとこの世界にはないよ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "marks",

  texts = {
    en = {
      ["base.calm"] = { '"Impossible? Bah  to you maybe."', "\"You catch me? Ha! You'd have a better chance shackling your shadow!\"", "You hear the swagger of a man of supreme confidence  only it's oh so quiet…" }
    },
    jp = {
      ["base.aggro"] = { "「ホッホッホッ」" },
      ["base.calm"] = { "「私に不可能はないのです」", "「捕まえられるものなら、どうぞいつでも」", "「そこらのコソ泥と、一緒にしないでください」" },
      ["base.dead"] = { "「これは何かの間違いです」" },
      ["base.killed"] = { "「ホホーっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "noel",

  texts = {
    en = {
      ["base.calm"] = { "You hear a someone making ticking sounds  followed by a pantomimed 'Ka-BOOOOM'  followed by manical laughter", "\"He says to me  he says to me  'Baby I'm TIRED of workin' for the MAN!' I says  I says  WHY DON'T YOU BLOW HIM TO BITS?\"", "\"You got STYLE  baby. But if you're going to be a real villain  you gotta get a gimmick.' And so I go I says YEAH  baby. A gimmick  that's it. High explosives.\"" }
    },
    jp = {
      ["base.aggro"] = { "「ヘンタイ！」" },
      ["base.calm"] = { "「もえちゃえ」", "「クズね。この世界は」", "「あたし、綺麗かしら？」" },
      ["base.dead"] = { "「全部、全部、真っ赤にもえちゃ…」" },
      ["base.killed"] = { "「綺麗な血。ぺろっ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "conery",

  texts = {
    en = {
      ["base.calm"] = { '"Kill a man  they put you in the gallows. Kill ten-thousand  they make you a General."', "\"We're going to need all the help we can get  yes indeed.\"", "\"You know what separates a soldier from a thug? The polish on his buttons  that's what.\"" }
    },
    jp = {
      ["base.aggro"] = { "「貴様、軍事裁判にかけてやるわ」" },
      ["base.calm"] = { "「うむうむ、精進せよ」", "「困ったことになったぞ」", "「軍人たるもの、常に身だしなみに気をつけねばならぬ」" },
      ["base.dead"] = { "「ちょこざいなー！」" },
      ["base.killed"] = { "「こわっぱが」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "thief",

  texts = {
    en = {
      ["base.calm"] = { '"Heh  easy money…"', '"Think I can get some good coin for those fancy bits you got on stranger?"', '"Another one with a coinpurse just dangling there  like a bit of ripe fruit. Time to pluck it."' }
    },
    jp = {
      ["base.calm"] = { "「やばいヤマだったぜ」", "「お、カモだ…」", "「ククク…」" },
      ["base.dead"] = { "「覚えていろよ」", "「やめてください！」" },
      ["base.killed"] = { "「ふん！青二才め」" },
      ["base.welcome"] = { "「よう、生きてたか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "robber",

  texts = {
    en = {
      ["base.calm"] = { "\"Man  this one'll feed me for a week. Two even!\"", "\"I was just sayin' we needed some coin  and look  it just came walkin' towards us.\"", '"Your GP or your HP good chum!"' }
    },
    jp = {
      ["base.calm"] = { "「やばいヤマだったぜ」", "「お、カモだ…」", "「ククク…」" },
      ["base.dead"] = { "「覚えていろよ」", "「やめてください！」" },
      ["base.killed"] = { "「ふん！青二才め」" },
      ["base.welcome"] = { "「よう、生きてたか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "master_thief",

  texts = {
    en = {
      ["base.calm"] = { '"Like taking candy from a baby in armor."', "You hear someone humming the *Money* tune while cracking their knuckles", '"Another satisifying finance adjustment."' }
    },
    jp = {
      ["base.calm"] = { "「やばいヤマだったぜ」", "「お、カモだ…」", "「ククク…」" },
      ["base.dead"] = { "「覚えていろよ」", "「やめてください！」" },
      ["base.killed"] = { "「ふん！青二才め」" },
      ["base.welcome"] = { "「よう、生きてたか」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "black_cat",

  texts = {
    jp = {
      ["base.aggro"] = { "「フシューッ」", "「うみみゃ！」", "「みゃ！」" },
      ["base.calm"] = { "「うみみゃ」", "「みゅー」", "「みゃ」", " *ごろごろ* " },
      ["base.dead"] = { "「うみ…みゃ…」" },
      ["base.killed"] = { "黒猫は尻尾をふった。" },
      ["base.welcome"] = { "「おかえりみゃー」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "cute_fairy",

  texts = {
    en = {
      ["base.calm"] = { "You hear the fluttering of gossamer wings", "You hear tittering laughter like tiny crystal bells", "You smell what reminds you of sugerplums…" }
    },
    jp = {
      ["base.calm"] = { " *パタパタ*  ", "「にひひ」", " *ハタハタ* " }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "black_angel",

  texts = {
    en = {
      ["base.calm"] = { "You hear what sounds like wings of feather  but with grace and dignity somehow...", "You hear a quiet voice in prayer  but with a note of sadness...", "You smell Myrrh in the air  but with the faintest hints of charcoal…" }
    },
    jp = {
      ["base.calm"] = { " *パタパタ*  ", " * ばさっばさっ*", " *ハタハタ* " },
      ["base.dead"] = { "「きゃあ！」" },
      ["base.killed"] = { "「地獄に落ちなさい」", "「いいざまね」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "lame_horse",

  texts = {
    en = {
      ["base.calm"] = { "You hear faltering hoofbeats in the distance", "", "" }
    },
    jp = {
      ["base.calm"] = { " *ぱかぱか* ", " *ぱからっぱからっ*", " *パコパコ*" },
      ["base.dead"] = { "「ひ…ひん…」" },
      ["base.killed"] = { "「ヒヒーン！」" },
      ["base.welcome"] = { "「おかえりヒヒーン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "wild_horse",

  texts = {
    en = {
      ["base.calm"] = { "You hear hoofbeats  but they are wild and free", "", "" }
    },
    jp = {
      ["base.calm"] = { " *ぱかぱか* ", " *ぱからっぱからっ*", " *パコパコ*" },
      ["base.dead"] = { "「ひ…ひん…」" },
      ["base.killed"] = { "「ヒヒーン！」" },
      ["base.welcome"] = { "「おかえりヒヒーン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "noyel_horse",

  texts = {
    en = {
      ["base.calm"] = { "You hear hoofbeats  a trot that almost belongs on a parade", "", "" }
    },
    jp = {
      ["base.calm"] = { " *ぱかぱか* ", " *ぱからっぱからっ*", " *パコパコ*" },
      ["base.dead"] = { "「ひ…ひん…」" },
      ["base.killed"] = { "「ヒヒーン！」" },
      ["base.welcome"] = { "「おかえりヒヒーン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "yowyn_horse",

  texts = {
    en = {
      ["base.calm"] = { "You hear the crisp hoofbeats of a horse trained for war", "", "" }
    },
    jp = {
      ["base.calm"] = { " *ぱかぱか* ", " *ぱからっぱからっ*", " *パコパコ*" },
      ["base.dead"] = { "「ひ…ひん…」" },
      ["base.killed"] = { "「ヒヒーン！」" },
      ["base.welcome"] = { "「おかえりヒヒーン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "wild_horse2",

  texts = {
    en = {
      ["base.calm"] = { "You hear hoofbeats. You hope it's not zebras", "", "" }
    },
    jp = {
      ["base.calm"] = { " *ぱかぱか* ", " *ぱからっぱからっ*", " *パコパコ*" },
      ["base.dead"] = { "「ひ…ひん…」" },
      ["base.killed"] = { "「ヒヒーン！」" },
      ["base.welcome"] = { "「おかえりヒヒーン！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "icolle",

  texts = {
    en = {
      ["base.calm"] = { "\"Science is it's own reward!\"", '"With a little bit of this  and a little bit of that  why  who knows what you are going to get?"', "\"I wonder if a black cat's genes are more or less lucky than a regular cat?\"" }
    },
    jp = {
      ["base.calm"] = { "「これからの世界はカガクなのじゃ」", "「実験体が足りぬ」", "「ふむふむ…この遺伝子を猫に組み込めば…」" },
      ["base.dead"] = { "「カガク万歳！」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "balzak",

  texts = {
    en = {
      ["base.calm"] = { "\"This citie's health is my charge!\"", '"Those who DARE litter before me shall face my broom!"', "\"I am garbage's worst nightmare.\"" }
    },
    jp = {
      ["base.calm"] = { "「街の衛生は俺が守る！」", "「街道にゴミを捨てる奴はゆるさねえ」", "「俺はゴミの天敵だ」" },
      ["base.dead"] = { "「俺はゴミじゃない！」" },
      ["base.killed"] = { "「掃除完了」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "revlus",

  texts = {
    en = {
      ["base.calm"] = { '"Magic is not for the faint of heart  nor dull of mind."', "You hear chants for spells you can't even begin to imagine the purpose of", "A pulse of arcane and raw eldritch energies nearly knocks you off your feet" }
    },
    jp = {
      ["base.aggro"] = { "「口で言っても無駄のようですね」" },
      ["base.calm"] = { "魔法を詠唱する声が聞こえる。", "辺りはピリピリとした緊張で包まれている。", "部屋全体に魔力の波がただよっている。" },
      ["base.dead"] = { "「そ、そんなはずはないのです！」" },
      ["base.killed"] = { "「みなさん、新たな献体が手に入りましたよ」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "lexus",

  texts = {
    en = {
      ["base.calm"] = { "\"I am an officer of the Mage Guild's jurisdiction. Beware the un-learn-ed.\"", '"Stop... Let me make sure you are on my lists."' }
    },
    jp = {
      ["base.calm"] = { "「この先は魔術士ギルドの管轄だ」", "「止まれ…身分を照会させてもらう」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "abyss",

  texts = {
    en = {
      ["base.calm"] = { "\"I am an officer of the Thief Guild's jurisdiction. Beware the clumsy-fingered.\"", '"Stop… Let me make sure you are on my lists."' }
    },
    jp = {
      ["base.calm"] = { "「この先は盗賊ギルドの管轄だ」", "「止まれ…身分を照会させてもらう」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "doria",

  texts = {
    en = {
      ["base.calm"] = { "\"I am an officer of the Fighter Guild's jurisdiction. Beware the weak-thewed.\"", '"Stop… Let me make sure you are on my lists."' }
    },
    jp = {
      ["base.calm"] = { "「この先は戦士ギルドの管轄だ」", "「止まれ…身分を照会させてもらう」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "silver_eyed_witch",

  texts = {
    en = {
      ["base.calm"] = { "\"What do I have to fear? You aren't an Abyssal One.\"", "{Good grief  is someone trying to cop a feel?} " }
    },
    jp = {
      ["base.aggro"] = { "「オマエ…私と同じ目をしているな」", "「ついてこれるか？」" },
      ["base.calm"] = { "「何故私に興味を持つ？怖くは無いのか？」 ", "「やれやれ。ペットを持った気分だ」" },
      ["base.dead"] = { "「ふっ。人のまま死ねて嬉しいよ」", "「どうせすぐ忘れられる名だ」 " },
      ["base.killed"] = { "「オマエ弱いな。ナンバーはいくつだ？」", "「優秀だが長く生きすぎたな」", "「金は要らん。後から取りに来る者がいるから金はその時に渡せばいい」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "big_daddy",

  texts = {
    en = {
      ["base.calm"] = { "You feel the ground tremble with the steps of a large  angry  Protector", "Little Sister: {Look Mr. Bubbles  the angels.}", "Little Sister: {Look Mr. Bubbles  the angels are dancing in the sky!}", "You hear the tread of something you do NOT want to anger. Ever." }
    },
    jp = {
      ["base.aggro"] = { "リトルシスター「殺せ！殺せ！」", "リトルシスター「粉々に砕いちゃいなさい！」", "リトルシスター「いけMr Bubbles、いけ！！」" },
      ["base.calm"] = { " *ドスン*  ", "リトルシスター「見てMr Bubbles、天使がいるわ」", "リトルシスター「急いでMr Bubbles、空で天使が踊っているの！」", " *ドン*  " },
      ["base.dead"] = { "「グウォォォォ！」" },
      ["base.killed"] = { "リトルシスター「天使の血でお腹を満たすの」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "little_sister",

  texts = {
    en = {
      ["base.calm"] = { '"Mr. Bubbles  please stand up… Please!"', "You hear the sound of a frightened little girl somewhere", "\"Angel  angel  until we find the right one we don't dare die…\"" }
    },
    jp = {
      ["base.aggro"] = { "「い、いや…！こないで！やだ…助けて…お願い…」" },
      ["base.calm"] = { "「Mr Bubbles、動いて…おねがい！」", "「来ないで！触わらないで！」", "「天使…天使に出会うまで、まだ死にたくないの…」" },
      ["base.dead"] = { "「死…死にたくない…いやあぁ…ぁ」" },
      ["base.killed"] = { "「天使の血でお腹を満たすの」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "strange_scientist",

  texts = {
    en = {
      ["base.aggro"] = { '"How can you do this things?"' },
      ["base.calm"] = { '"The path of the righteous is not always easy  yes?"', "\"I'll not have him hurt my Little ones… I've worked far too long on them to see them fail now.\"" },
      ["base.dead"] = { '"Have you no heart?"' },
      ["base.killed"] = { '"Have you no heart?"' }
    },
    jp = {
      ["base.aggro"] = { "「どうしてそんなことができるの？」" },
      ["base.calm"] = { "「正しいことを行うのが時には難しいこともあるわ」", "「私の子供達を傷つけたらひどいわよ」" },
      ["base.dead"] = { "「あなたには心がないの？」" },
      ["base.killed"] = { "「あなたには心がないの？」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "mysterious_producer",

  texts = {
    en = {
      ["base.aggro"] = { '"How can you do this things?"' },
      ["base.calm"] = { '"The problem is about choice. It is always about the choices we make."', '"While choices make the man  a pity most see only the shallowest ones to choose from."' },
      ["base.dead"] = { '"Have you no heart?"' },
      ["base.killed"] = { '"Have you no heart?"' }
    },
    jp = {
      ["base.aggro"] = { "「どうしてそんなことができるの？」" },
      ["base.calm"] = { "「正しいことを行うのが時には難しいこともあるわ」", "「私の子供達を傷つけたらひどいわよ」" },
      ["base.dead"] = { "「あなたには心がないの？」" },
      ["base.killed"] = { "「あなたには心がないの？」" }
    }
  }
}

data:add {
  _type = "base.tone",
  _id = "metal",

  texts = {
    en = {
      ["base.aggro"] = { "*ring*" },
      ["base.calm"] = { "*ring*" }
    },
    jp = {
      ["base.aggro"] = { " *リン* " },
      ["base.calm"] = { " *リン* " }
    }
  }
}
