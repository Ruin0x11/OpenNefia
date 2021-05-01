return {
   config = {
      common = {
         assign_button = "ボタンを割り当てたい項目にカーソルをあわせて\nゲームパッドのボタンを押してください。(L),(R)の付いている\n項目は、メニュー画面でタブの移動に使われます。",
         formatter = {
            every_minutes = function(_1)
               return ("%s分毎")
                  :format(_1)
            end,
            wait = function(_1)
               return ("%s wait")
                  :format(_1)
            end
         },
         menu = "項目",
         no_desc = "(説明はありません)",
         require_restart = "* 印のついた項目は、ゲームの再起動後に適用されます",
         yes_no = {
            anime_ari_nashi = {
               no = "アニメなし",
               yes = "アニメあり"
            },
            ari_nashi = {
               no = "なし",
               yes = "あり"
            },
            ari_nashi_slow_fast = {
               no = "なし (高速)",
               yes = "あり (低速)"
            },
            default = {
               no = "しない",
               yes = "する"
            },
            kougashitsu_teigashitsu = {
               no = "低画質",
               yes = "高画質"
            },
            on_off = {
               no = "オフ",
               yes = "オン"
            },
            saisei_suru_shinai = {
               no = "再生しない",
               yes = "再生する"
            },
            shiyou_suru_shinai = {
               no = "使用しない",
               yes = "使用する"
            },
            tsukau_tsukawanai = {
               no = "使わない",
               yes = "使う"
            },
            unsupported = {
               no = "オフ(未実装)",
               yes = "オフ(未実装)"
            },
            yuukou_mukou = {
               no = "無効",
               yes = "有効"
            }
         }
      },
      menu = {
         base = {
            default = {
               name = "オプション",
            },
            game = {
               name = "ゲーム設定"
            },
            screen = {
               name = "画面と音の設定"
            },
            net = {
               name = "ネット機能の設定"
            },
            anime = {
               name = "アニメ設定"
            },
            input = {
               name = "入力設定"
            },
            keybindings = {
               name = "キーの割り当て"
            },
            message = {
               name = "メッセージとログ"
            },
            language = {
               name = "言語(Language)"
            },
         }
      },
      option = {
         base = {

            --
            -- Menu: game
            --

            extra_help = {
               doc = "Elonaに不慣れな冒険者に向けて妖精ノルンによる案内が表示されます。",
               name = "ノルンの冒険ガイド"
            },

            attack_neutral_npcs = {
               doc = "中立NPCに向かって歩いたとき、そのNPCに対して攻撃します。",
               name = "非好戦的NPCを攻撃"
            },

            story = {
               doc = "Elonaのメインストーリーを再生します。",
               name = "シーンの再生",
               yes_no = "config.common.yes_no.saisei_suru_shinai"
            },

            default_save = {
               doc = "Elonaを起動した際にデフォルトで読み込まれるセーブデータです。\nこれを設定するとタイトル画面を飛ばしてすぐにゲームを始めることができます。\n",
               name = "デフォルトセーブ",
               variants = {
                  [""] = "使用しない"
               }
            },

            hide_shop_updates = {
               doc = "店の販売ログを非表示にします。",
               name = "店ﾒｯｾｰｼﾞの非表示"
            },

            hide_autoidentify = {
               doc = "自然鑑定が行われた際のメッセージを非表示にします。",
               name = "自然鑑定ﾒｯｾｰｼﾞの非表示"
            },

            skip_random_event_popups = {
               doc = "ランダムイベントのポップアップウィンドウをスキップします。\nスキップされた場合デフォルトの選択肢が選ばれます。\n",
               name = "イベントの短縮"
            },

            autosave = {
               doc = [[
特定の行動/イベントの後に行われる自動的な*保存*を制限します。
[ほぼなし]にするとほぼ全ての*保存*を行いません。
]],
               name = "オートセーブ頻度",
               variants = {
                  always = "いつも",
                  sometimes = "大抵",
                  rarely = "希に",
                  almost_never = "ほぼなし"
               }
            },

            --
            -- Menu: screen
            --

            music = {
               doc = "BGMを再生します。",
               name = "BGMの再生*",
               yes_no = "config.common.yes_no.ari_nashi"
            },

            sound = {
               doc = "SEを再生します。",
               name = "サウンドの再生*",
               yes_no = "config.common.yes_no.ari_nashi"
            },

            midi_driver = {
               name = "MIDIのドライバー",
               variants = {
                  generic = "汎用",
                  native = "MCI"
               }
            },

            midi_device = {
               name = "MIDIのデバイス"
            },

            positional_audio = {
               doc = "音が鳴った場所に応じてSEを再生します。\n例えば、画面左で鳴ったSEが左から聞こえるようになります。\n",
               name = "ステレオサウンド"
            },

            screen_mode = {
               doc = "ウィンドウとフルスクリーンを切り替えます。\nフルスクリーン2は、スクリーンと同じサイズのウィンドウを生成し擬似的にフルスクリーンとします。\n",
               name = "画面モード*",
               variants = {
                  desktop = "フルスクリーン2",
                  exclusive = "フルスクリーン",
                  windowed = "ウィンドウ"
               }
            },

            object_shadows = {
               doc = "地面に置かれたアイテムの下に影を表示します。",
               name = "アイテムの影描写",
               yes_no = "config.common.yes_no.ari_nashi_slow_fast"
            },

            screen_resolution = {
               name = "画面の大きさ*"
            },

            high_quality_shadows = {
               doc = "影の描写品質を設定します。\n高画質は描写速度がやや低下しますが、影がより綺麗に表示されます。\n",
               name = "光源の描写",
               yes_no = "config.common.yes_no.kougashitsu_teigashitsu"
            },

            heartbeat = {
               doc = "HPが残り少ないとき、心拍音を再生します。",
               name = "心臓の音",
               yes_no = "config.common.yes_no.saisei_suru_shinai"
            },

            heartbeat_threshold = {
               doc = "現在のHPがこのパーセンテージを下回っているとき心拍音が再生されます。\nこの設定は「心臓の音」の設定を「再生する」にしているときのみ使われます。\n",
               name = "心音再生の閾値"
            },

            --
            -- Menu: net
            --

            enable_net = {
               doc = "ネット機能を使用するかどうかを設定します。\n以下のオプションはこのオプションを「する」にしたときに限り有効となります。\n",
               name = "ネットの使用"
            },

            --
            -- Menu: anime
            --

            attack_anime = {
               doc = "物理攻撃した際にアニメーションを表示します。",
               name = "攻撃時アニメ"
            },

            general_wait = {
               formatter = "config.common.formatter.wait",
               name = "キーウェイト"
            },

            title_effect = {
               doc = "タイトル画面に水の波紋のエフェクトを表示します。",
               name = "タイトルの水の波紋",
               yes_no = "config.common.yes_no.on_off"
            },

            auto_turn_speed = {
               name = "オートターンの挙動",
               variants = {
                  high = "速め",
                  highest = "省略",
                  normal = "普通"
               }
            },

            scroll = {
               doc = "PCが動くときスクロールアニメーションを表示します。",
               name = "スクロール"
            },

            window_anime = {
               doc = "ゲーム内でウィンドウが表示される際アニメーションが表示されます。",
               name = "ウィンドウアニメ"
            },

            always_center = {
               doc = "常にPCを中心として描写を行います。",
               name = "主人公中心に描写"
            },

            alert_wait = {
               doc = "重要なメッセージが表示された際のウェイトの長さです。",
               name = "アラートウェイト"
            },

            screen_refresh = {
               formatter = "config.common.formatter.wait",
               name = "画面の更新頻度"
            },

            anime_wait = {
               doc = "アニメーションの長さです。",
               formatter = "config.common.formatter.wait",
               name = "アニメウェイト"
            },

            anime_wait_type = {
               name = "アニメーションウェイト種類",
               variants = {
                  always_wait = "待つ",
                  at_turn_start = "ターン開始に待つ",
                  never_wait = "待たない"
               }
            },

            weather_effect = {
               doc = "天候に関わるアニメーションを表示します。",
               name = "天候エフェクト"
            },

            background_effect_wait = {
               name = "背景エフェクトウェイト",
            },

            scroll_when_run = {
               doc = "走っているときもスクロールアニメーションを表示します。\nこれを切ることで若干の高速化が望めます。\n",
               name = "走り時スクロール"
            },

            --
            -- Menu: message
            --

            message_timestamps = {
               doc = "メッセージに現在の分を表示します。",
               name = "ﾒｯｾｰｼﾞに分表示追加"
            },

            message_transparency = {
               doc = "古いメッセージをこのパーセンテージだけ透明にして表示します。",
               formatter = function(_1)
                  return ("%s %%")
                     :format(_1*10)
               end,
               name = "過去のﾒｯｾｰｼﾞの透過"
            },

            --
            -- Menu: language
            --

            language = {
               name = "言語*",
            },

            --
            -- Menu: input
            --

            autodisable_numlock = {
               name = "numlockを自動制御"
            },

            attack_wait = {
               formatter = "config.common.formatter.wait",
               name = "攻撃の間隔"
            },

            key_repeat_wait = {
               formatter = "config.common.formatter.wait",
               name = "キーリピートウェイト"
            },

            select_wait = {
               formatter = "config.common.formatter.wait",
               name = "選択ウェイト"
            },

            run_wait = {
               formatter = "config.common.formatter.wait",
               name = "走りの速さ"
            },

            initial_key_repeat_wait = {
               formatter = "config.common.formatter.wait",
               name = "キーリピートウェイト(開始)"
            },

            walk_wait = {
               formatter = "config.common.formatter.wait",
               name = "歩きの速さ"
            },

            key_wait = {
               formatter = "config.common.formatter.wait",
               name = "キーウェイト"
            },

            select_fast_wait = {
               formatter = "config.common.formatter.wait",
               name = "選択ウェイト(早い)"
            },

            start_run_wait = {
               formatter = function(_1)
                  return ("After %s+1 steps")
                     :format(_1)
               end,
               name = "走り開始の速さ"
            },

            select_fast_start_wait = {
               formatter = "config.common.formatter.wait",
               name = "選択ウェイト(早い,開始)"
            },
         }
      }
   }
}
