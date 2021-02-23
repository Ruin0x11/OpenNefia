return {
   ui = {
      adventurers = {
         fame_lv = "名声(Lv)",
         hospital = "病院",
         location = "現在地",
         name_and_rank = "冒険者の名前とランク",
         rank_counter = "位",
         title = "冒険者ランク",
         unknown = "不明"
      },
      alias = {
         list = "異名の候補",
         reroll = "別の名前を考える",
         title = "異名の選択"
      },
      ally_list = {
         alive = "(生きている)",
         call = {
            prompt = "誰を呼び戻す？",
            title = "呼び戻す仲間",
            waiting = "(待機している)"
         },
         dead = "(死んでいる)",
         gene_engineer = {
            body_skill = "獲得部位/技能",
            none = "なし",
            prompt = "対象にする仲間は？",
            skill_too_low = "遺伝子学のスキルが足りない。",
            title = "仲間"
         },
         name = "仲間の情報",
         pet_arena = {
            ["in"] = " *出場* ",
            is_dead = "死んでいる。",
            need_at_least_one = "最低でも一人の参加者が必要だ。",
            prompt = "試合の規定人数",
            title = "出場する仲間",
            too_many = "参加枠を超えている。"
         },
         proceed = "決定",
         ranch = {
            breed_power = "繁殖力",
            prompt = "誰をブリーダーにする？",
            title = "ブリーダー候補"
         },
         sell = {
            prompt = "誰を売り飛ばす？",
            title = "売り飛ばす仲間",
            value = "値段"
         },
         shop = {
            chr_negotiation = "魅力/交渉",
            prompt = "誰を店長にする？",
            title = "店長候補"
         },
         status = "状態",
         stayer = {
            prompt = "誰を滞在させる？",
            title = "滞在状態の変更"
         },
         waiting = "待機"
      },
      analysis = {
         result = "分析結果",
         title = "自己の分析"
      },
      appearance = {
         basic = {
            body = "体　　　",
            category = "項目",
            cloth = "服　　　",
            custom = "ｶｽﾀﾑｷｬﾗ ",
            done = "決定    ",
            hair = "髪　　　",
            hair_color = "髪の色　",
            pants = "ﾊﾟﾝﾂ　　",
            portrait = "肖像　　",
            riding = "乗馬時　",
            set_detail = "詳細設定",
            sub_hair = "副髪　　",
            title = "肖像の変更"
         },
         detail = {
            body_color = "体の色　",
            cloth_color = "服の色　",
            etc_1 = "ｱｸｾｻﾘ1　",
            etc_2 = "ｱｸｾｻﾘ2　",
            etc_3 = "ｱｸｾｻﾘ3　",
            eyes = "目　　　",
            pants_color = "ﾊﾟﾝﾂの色",
            set_basic = "基本設定"
         },
         equipment = {
            belt = "ベルト　",
            chest = "胸部鎧　",
            done = "決定    ",
            glove = "ｸﾞﾛｰﾌﾞ　",
            leg = "脚部鎧　",
            mantle = "マント　",
            part = "項目",
            title = "装備表示の変更"
         },
         hint = "左右キー [変更]  ｷｬﾝｾﾙ [閉じる]"
      },
      article = function(_1)
         return ("%s")
            :format(_1)
      end,
      assign_shortcut = function(_1)
         return ("{%s}キーにショートカットを割り当てた。")
            :format(_1)
      end,
      autodig = {
         disabled = "自動採掘をオフにした。",
         enabled = "自動採掘をオンにした。",
         mode = "採掘"
      },
      autopick = {
         destroyed = function(_1)
            return ("%sを破壊した。")
               :format(name(_1))
         end,
         do_you_really_destroy = function(_1)
            return ("%sを破壊する？")
               :format(name(_1))
         end,
         do_you_really_open = function(_1)
            return ("%sを開ける？")
               :format(name(_1))
         end,
         do_you_really_pick_up = function(_1)
            return ("%sを拾う？")
               :format(name(_1))
         end
      },
      board = {
         difficulty = "★",
         difficulty_counter = function(_1)
            return ("★×%s")
               :format(_1)
         end,
         do_you_meet = "依頼主に会う？",
         no_new_notices = "新しい依頼は掲示されていないようだ。",
         title = "掲載されている依頼"
      },
      body_part = {
         _0 = "",
         _1 = "頭",
         _10 = "遠隔",
         _11 = "矢弾",
         _2 = "首",
         _3 = "背中",
         _4 = "胴体",
         _5 = "手",
         _6 = "指",
         _7 = "腕",
         _8 = "腰",
         _9 = "足"
      },
      bye = "さようなら",
      cast_style = {
         default = "魔法を詠唱した。",
         spider = "糸を吐いた。",
         spill = "体液をまき散らした。",
         tentacle = "触手を伸ばした。",
         gaze = "鋭く睨んだ。",
         spore = "胞子を飛ばした。",
         machine = "細かく振動した。"
      },
      chara_sheet = {
         attribute = {
            fame = "名声",
            karma = "カルマ",
            life = "生命力",
            mana = "マナ",
            melee = "打撃修正",
            sanity = "狂気度",
            shoot = "射撃修正",
            speed = "速度"
         },
         attributes = "能力(元の値)  - 潜在能力",
         blessing_and_hex = "祝福と呪い",
         buff = {
            duration = function(_1)
               return ("(%s)ﾀｰﾝの間、")
                  :format(_1)
            end,
            hint = "説明:",
            is_not_currently = "今は持続効果を受けていない"
         },
         category = {
            resistance = "◆ 耐性と抵抗力",
            skill = "◆ スキルと特殊能力",
            weapon_proficiency = "◆ 武器の専門"
         },
         combat_rolls = "各種修正",
         damage = {
            dist = "射撃",
            evade = "回避",
            hit = "命中",
            melee = "武器",
            protect = "軽減",
            unarmed = "格闘"
         },
         exp = {
            exp = "経験",
            god = "信仰",
            guild = "所属",
            level = "レベル",
            next_level = "必要値"
         },
         extra_info = "その他",
         hint = {
            blessing_info = "ｶｰｿﾙ [祝福と呪いの情報] ",
            confirm = "Shift,Esc [最終確認]",
            hint = "ｶｰｿﾙ [祝福と呪いの情報]  ",
            learn_skill = "決定 [スキルを習得]  ",
            reroll = "決定ｷｰ [リロール]  ",
            spend_bonus = "決定 [ボーナスの分配]  ",
            track_skill = "スキルトラック",
            train_skill = "決定 [スキルを訓練]  "
         },
         history = "冒険の軌跡",
         personal = {
            age = "年齢",
            age_counter = function(_1)
               return ("%s 歳")
                  :format(_1)
            end,
            aka = "異名",
            class = "職業",
            height = "身長",
            name = "名前",
            race = "種族",
            sex = "性別",
            weight = "体重"
         },
         skill = {
            detail = "効果",
            level = "Lv(潜在)",
            name = "能力の名称",
            resist = function(_1)
               return ("%s耐性")
                  :format(_1)
            end
         },
         time = {
            days = "経過日",
            days_counter = function(_1)
               return ("%s日")
                  :format(_1)
            end,
            kills = "殺害数",
            time = "総時間",
            turn_counter = function(_1)
               return ("%sターン")
                  :format(_1)
            end,
            turns = "ターン"
         },
         title = {
            default = "キャラクターシート",
            learning = "能力の習得",
            training = "能力訓練"
         },
         train_which_skill = "どの能力を訓練する？",
         weight = {
            cargo_limit = "荷車限界",
            cargo_weight = "荷車重量",
            deepest_level = "最深到達",
            equip_weight = "装備重量",
            level_counter = function(_1)
               return ("%s階相当")
                  :format(_1)
            end
         },
         you_can_spend_bonus = function(_1)
            return ("残り %s のボーナスをスキルに分配できる")
               :format(_1)
         end
      },
      chat = {
         key_hint = "何かキーを押すと閉じる"
      },
      cheer_up_message = {
         _1 = "ラーネイレ「がんばれ〜」",
         _12 = "オパートス「フハハハハッフハー」",
         _2 = "ロミアス「陰ながら応援しているよ（ニヤリ）」",
         _24 = "虚空「希望はまだあるはずだ」",
         _3 = "クミロミ「…大丈夫…だよね？」",
         _4 = "ルルウィ「あら、思いの他がんばるのね」",
         _5 = "ラーネイレ「いけない。このままでは…手遅れになってしまうわ…」",
         _6 = "ロミアス「まだまだ、これからだろう（ニヤリ）」",
         _7 = "ルルウィ「休憩しなさい。壊れちゃったら、私の役にたてないじゃない」",
         _8 = "ルルウィ「何を言っても無駄のようね。好きにするといいわ」"
      },
      curse_state = {
         blessed = "祝福された",
         cursed = "呪われた",
         doomed = "堕落した"
      },
      date = function(_1, _2, _3)
         return ("%s年%s月%s日")
            :format(_1, _2, _3)
      end,
      date_hour = function(_1)
         return ("%s時")
            :format(_1)
      end,
      economy = {
         basic_tax = "基本税",
         excise_tax = "消費税",
         finance = "街の財政",
         finance_detail = "収支の詳細",
         information = "街の概要",
         population = "人口",
         population_detail = "人口推移の詳細"
      },
      equip = {
         acidproof = "酸",
         ailment = {
            _0 = "盲",
            _1 = "麻",
            _2 = "混",
            _3 = "恐",
            _4 = "睡",
            _5 = "毒"
         },
         cannot_be_taken_off = function(_1)
            return ("%sは外せない。")
               :format(itemname(_1))
         end,
         category = "部位",
         damage_bonus = "ダメージ修正",
         equip_weight = "装備重量",
         fireproof = "熱",
         hit_bonus = "命中修正",
         main_hand = "利手",
         maintenance = {
            _0 = "筋",
            _1 = "耐",
            _2 = "器",
            _3 = "感",
            _4 = "習",
            _5 = "意",
            _6 = "魔",
            _7 = "魅",
            _8 = "速",
            _9 = "運"
         },
         name = "装備品名称",
         resist = {
            _0 = "火",
            _1 = "冷",
            _10 = "魔",
            _2 = "雷",
            _3 = "闇",
            _4 = "幻",
            _5 = "毒",
            _6 = "獄",
            _7 = "音",
            _8 = "神",
            _9 = "沌"
         },
         title = "装備品",
         weight = "重さ",
         you_unequip = function(_1)
            return ("%sを外した。")
               :format(itemname(_1))
         end
      },
      exhelp = {
         title = "- ノルンの冒険ガイド -"
      },
      furniture = {
         _0 = "",
         _1 = "みすぼらしい",
         _2 = "気になる",
         _3 = "いい感じの",
         _4 = "マダム殺しの",
         _5 = "思わず見入りそうな",
         _6 = "マニア向けの",
         _7 = "凄く華麗な",
         _8 = "王家御用達の",
         _9 = "芸術的な",
         _10 = "神々しい",
         _11 = "世界最高の"
      },
      gold = " gold",
      hint = {
         back = "Shift,Esc [戻る]  ",
         close = "Shift,Esc [閉じる]  ",
         cursor = "ｶｰｿﾙ [選択]  ",
         enter = "決定、",
         help = " [説明]  ",
         known_info = " [既知の情報]  ",
         mode = " [情報切替]  ",
         page = " [ページ切替]  ",
         portrait = "p [ポートレイト変更]  ",
         shortcut = "0〜9 [ショートカット]  "
      },
      home = {
         elona = {
            cave = "洞窟",
            shack = "森のほったて小屋",
            cozy_house = "住み心地のいい家",
            estate = "セレブ邸",
            cyber_house = "サイバーハウス",
            small_castle = "小城"
         }
      },
      impression = {
         _0 = "天敵",
         _1 = "嫌い",
         _2 = "うざい",
         _3 = "普通",
         _4 = "好意的",
         _5 = "友達",
         _6 = "親友",
         _7 = "魂の友",
         _8 = "*Love*"
      },
      invalid_target = "その方向には、操作できる対象はない。",
      inventory_command = {
         general = "調べる",
         give = "渡す",
         buy = "購入する",
         sell = "売却する",
         identify = "鑑定する",
         use = "使う",
         open = "開く",
         cook = "料理する",
         dip_source = "調合",
         dip = "混ぜる対象",
         offer = "捧げる",
         drop = "置く",
         trade = "交換する",
         present = "提示する",
         take = "取る",
         target = "対象の",
         put = "入れる",
         receive = "もらう",
         throw = "投げる",
         steal = "盗む",
         trade2 = "交換する",
         reserve = "予約する",
         get = "拾う",
         eat = "食べる",
         equip = "装備する",
         read = "読む",
         drink = "飲む",
         zap = "振る"
      },
      journal = {
         income = {
            bills = {
               labor = function(_1)
                  return ("@RE　人件費  : 約 %s gold")
                     :format(_1)
               end,
               maintenance = function(_1)
                  return ("@RE　運営費  : 約 %s gold")
                     :format(_1)
               end,
               sum = function(_1)
                  return ("@RE　合計　  : 約 %s gold")
                     :format(_1)
               end,
               tax = function(_1)
                  return ("@RE　税金    : 約 %s gold")
                     :format(_1)
               end,
               title = "◆ 請求書内訳(毎月1日に発行)",
               unpaid = function(_1)
                  return ("現在未払いの請求書は%s枚")
                     :format(_1)
               end
            },
            salary = {
               sum = function(_1)
                  return ("@BL　合計　　 : 約 %s gold")
                     :format(_1)
               end,
               title = "◆ 給料(毎月1日と15日に支給)"
            }
         },
         rank = {
            arena = function(_1, _2)
               return ("EXバトル: 勝利 %s回 最高Lv%s")
                  :format(_1, _2)
            end,
            deadline = function(_1)
               return ("ノルマ: %s日以内")
                  :format(_1)
            end,
            fame = "名声",
            pay = function(_1)
               return ("給料: 約 %s gold  ")
                  :format(_1)
            end
         }
      },
      manual = {
         keys = {
            action = {
               apply = "能力を使う(apply)",
               bash = "体当たりする(bash)",
               cast = "魔法を唱える(cast)",
               dig = "穴を掘る(dig)",
               fire = "射撃する(fire)",
               go_down = "階段を降りる,入る(go down)",
               go_up = "階段を昇る(go up)",
               interact = "干渉する(interact)",
               open = "鍵を開ける(open)",
               search = "周囲を調べる(search)",
               target = "ターゲットを指定(target)",
               title = "行動に関するキー",
               wait = "その場で待機(wait)"
            },
            info = {
               chara = "能力・スキル情報(chara)",
               feat = "特徴の表示(feat)",
               help = "ヘルプを表示(help)",
               journal = "冒険日誌を表示(journal)",
               log = "メッセージログを表示(log)",
               material = "マテリアル表示(material)",
               title = "情報に関するキー"
            },
            item = {
               ammo = "装填(ammo)",
               blend = "調合(blend)",
               drop = "アイテムを置く(drop)",
               eat = "食べる(eat)",
               examine = "アイテムを調べる(examine)",
               get = "アイテムを取る(get)",
               quaff = "飲む(quaff)",
               read = "読む(read)",
               throw = "投げる(throw)",
               title = "アイテムに関するキー",
               tool = "道具を使う(tool)",
               wear_wield = "装備する(wear,wield)",
               zap = "振る(zap)"
            },
            list = "キーの一覧",
            other = {
               close = "ドアを閉める(close)",
               console = "コンソールの表示",
               export_chara_sheet = "キャラ情報の出力",
               give = "与える(give)",
               hide_interface = "インタフェース非表示",
               offer = "神に捧げる(offer)",
               pray = "神に祈る(pray)",
               save = "セーブして終了(save)",
               title = "その他のキー"
            }
         },
         topic = "項目"
      },
      mark = {
         _0 = "。",
         _1 = "？",
         _2 = "！",
         _3 = ""
      },
      material = {
         detail = "説明",
         name = "所持マテリアル"
      },
      menu = {
         change = "メニュー切替",
         chara = {
            chara = "情報",
            feat = "特徴",
            material = "ﾏﾃﾘｱﾙ",
            wear = "装備"
         },
         log = {
            chat = "チャット",
            journal = "日誌",
            log = "ログ"
         },
         spell = {
            skill = "技能",
            spell = "魔法"
         },
         town = {
            chart = "チャート",
            economy = "街情報",
            politics = "法律"
         }
      },
      message = {
         key_hint = "Up,Down [1行ｽｸﾛｰﾙ]   Left,Right [1ﾍﾟｰｼﾞｽｸﾛｰﾙ]   他のキーを押すと閉じる"
      },
      more = "(続く)",
      no = "いや…",
      no_gold = "(所持金が足りない！)",
      npc_list = {
         age_counter = function(_1)
            return ("%s歳")
               :format(_1)
         end,
         gold_counter = function(_1)
            return ("%s gold")
               :format(_1)
         end,
         info = "情報",
         init_cost = "雇用費(給料)",
         name = "NPCの名前",
         title = "NPC一覧",
         wage = "給料"
      },
      onii = {
         _0 = "お兄",
         _1 = "お姉"
      },
      platinum = " plat",
      playtime = function(_1, _2, _3)
         return ("%02d時間%02d分%02d秒")
            :format(_1, _2, _3)
      end,
      politics = {
         global = "国法",
         law = "法律",
         law_of = function(_1)
            return ("%sの法")
               :format(_1)
         end,
         lawless = "この街では殺人が許される。",
         name = function(_1)
            return ("この国の首都は%sだ。")
               :format(_1)
         end,
         taxes = function(_1)
            return ("この街の消費税は%s%だ。")
               :format(_1)
         end,
         well_pollution = function(_1)
            return ("この街の井戸水の汚染は深刻だ(死者%s人）。")
               :format(_1)
         end
      },
      quality = {
         _0 = "",
         _1 = "粗悪",
         _2 = "良質",
         _3 = "高品質",
         _4 = "奇跡",
         _5 = "神器",
         _6 = "特別"
      },
      quick_menu = {
         action = "行動",
         ammo = "装填",
         bash = "体当り",
         chara = "シート",
         dig = "掘る",
         etc = "特殊",
         fire = "射撃",
         help = "ヘルプ",
         info = "情報",
         interact = "干渉",
         journal = "日誌",
         log = "ログ",
         pray = "祈る",
         rest = "休息",
         skill = "技能",
         spell = "魔法",
         wear = "装備"
      },
      random_item = {
         potion = {
            _0 = "透明な",
            _1 = "緑色の",
            _2 = "青い",
            _3 = "金色の",
            _4 = "茶色い",
            _5 = "赤い",
            name = "ポーション"
         },
         ring = {
            _0 = "鉄の",
            _1 = "緑の",
            _2 = "サファイアの",
            _3 = "金の",
            _4 = "木の",
            _5 = "錆びた",
            name = "指輪"
         },
         amulet = {
            name = "首飾り"
         },
         staff = {
            _0 = "鉄の",
            _1 = "つたの",
            _2 = "サファイアの",
            _3 = "金の",
            _4 = "木の",
            _5 = "錆の",
            name = "魔法棒"
         },
         scroll = {
            _0 = "かすれた",
            _1 = "苔むした",
            _2 = "ぼろぼろの",
            _3 = "難しそうな",
            _4 = "古びた",
            _5 = "血文字の",
            name = "巻物"
         },
         spellbook = {
            _0 = "分厚い",
            _1 = "苔むした",
            _2 = "真新しい",
            _3 = "豪華な",
            _4 = "古びた",
            _5 = "血の滴る",
            name = "魔法書"
         }
      },
      reserve = {
         name = "アイテムの名前",
         not_reserved = "入荷なし",
         reserved = "入荷予定",
         status = "予約状況",
         title = "予約リスト",
         unavailable = "「その本は入手できないね」"
      },
      resistance = {
         _0 = "致命的な弱点",
         _1 = "弱点",
         _2 = "耐性なし",
         _3 = "弱い耐性",
         _4 = "普通の耐性",
         _5 = "強い耐性",
         _6 = "素晴らしい耐性"
      },
      save = " *保存* ",
      save_on_suspend = "アプリが中断された。セーブします。",
      scene = {
         has_been_played = "シーンの再生を終えた。",
         scene_no = "シーン No.",
         which = "どのシーンを再生する？",
         you_can_play = "アンロックされたシーンを再生できます。\nシーンNoは連続していません。"
      },
      sex = {
         male = "男",
         female = "女"
      },
      sex2 = {
         _0 = "男",
         _1 = "女"
      },
      sex3 = {
         female = "女性",
         male = "男性"
      },
      skill = {
         cost = "コスト",
         detail = "能力の効果",
         name = "能力の名称",
         title = "能力の発動"
      },
      spell = {
         effect = "効果",
         lv_chance = "Lv/成功",
         name = "魔法の名称",
         power = "ﾊﾟﾜｰ",
         cost_stock = "消費MP(ｽﾄｯｸ)",
         title = "魔法の詠唱",
         turn_counter = "ﾀｰﾝ"
      },
      syujin = {
         _0 = "ご主人様",
         _1 = "お嬢様"
      },
      time = {
         _0 = "深夜",
         _1 = "夜明け",
         _2 = "朝",
         _3 = "昼",
         _4 = "宵",
         _5 = "夜",
         _6 = "",
         _7 = ""
      },
      town_chart = {
         chart = function(_1)
            return ("%sのチャート")
               :format(_1)
         end,
         empty = "不在",
         no_economy = "この場所には経済活動がない。",
         title = "ポストチャート"
      },
      unit_of_weight = "s",
      weather = {
         _0 = "",
         _1 = "*エーテル*",
         _2 = "雪",
         _3 = "雨",
         _4 = "雷雨"
      },
      weight = {
         _0 = "超ミニに",
         _1 = "小振りに",
         _2 = "手ごろに",
         _3 = "やや大きく",
         _4 = "どでかく",
         _5 = "かなり巨大に",
         _6 = "化け物サイズに",
         _7 = "人より大きく",
         _8 = "伝説的サイズに",
         _9 = "象より重く"
      },
      yes = "ああ",

      now_loading = "ロード中…",

      sense_quality = function(_1, _2)
         return (" (%s)[%s製]"):format(_1, _2)
      end
   }
}
