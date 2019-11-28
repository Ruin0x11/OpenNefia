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
      android = {
        hide_navigation = {
          name = "ナビゲーションバーの非表示*"
        },
        name = "アンドロイド設定",
        quick_action_size = {
          name = "ボタンのサイズ"
        },
        quick_action_transparency = {
          name = "ボタンの透明度"
        },
        quicksave = {
          name = "中断した時のセーブ"
        },
        vibrate = {
          name = "振動"
        },
        vibrate_duration = {
          name = "振動の期間"
        }
      },
      anime = {
        alert_wait = {
          doc = "重要なメッセージが表示された際のウェイトの長さです。",
          name = "アラートウェイト"
        },
        always_center = {
          doc = "常にPCを中心として描写を行います。",
          name = "主人公中心に描写"
        },
        anime_wait = {
          doc = "アニメーションの長さです。",
          formatter = "core.config.common.formatter.wait",
          name = "アニメウェイト"
        },
        attack_anime = {
          doc = "物理攻撃した際にアニメーションを表示します。",
          name = "攻撃時アニメ"
        },
        auto_turn_speed = {
          name = "オートターンの挙動",
          variants = {
            high = "速め",
            highest = "省略",
            normal = "普通"
          }
        },
        general_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "キーウェイト"
        },
        name = "アニメ設定",
        screen_refresh = {
          formatter = "core.config.common.formatter.wait",
          name = "画面の更新頻度"
        },
        scroll = {
          doc = "PCが動くときスクロールアニメーションを表示します。",
          name = "スクロール"
        },
        scroll_when_run = {
          doc = "走っているときもスクロールアニメーションを表示します。\nこれを切ることで若干の高速化が望めます。\n",
          name = "走り時スクロール"
        },
        title_effect = {
          doc = "タイトル画面に水の波紋のエフェクトを表示します。",
          name = "タイトルの水の波紋",
          yes_no = "core.config.common.yes_no.on_off"
        },
        weather_effect = {
          doc = "天候に関わるアニメーションを表示します。",
          name = "天候エフェクト"
        },
        window_anime = {
          doc = "ゲーム内でウィンドウが表示される際アニメーションが表示されます。",
          name = "ウィンドウアニメ"
        }
      },
      balance = {
        extra_class = {
          name = "Extra職業"
        },
        extra_race = {
          name = "Extra種族"
        },
        name = "ゲームバランス設定",
        restock_interval = {
          doc = "街の店の品揃えが更新される頻度を設定します。",
          formatter = function(_1)
  return ("%s日")
  :format(_1)
end,
          name = "入荷頻度"
        }
      },
      font = {
        name = "フォント設定",
        quality = {
          doc = "テキスト描写の品質です。「高品質」は綺麗に表示されますが遅くなります。\n「低品質」は文字の描写がやや汚くなりますが動作は速くなります。\n",
          name = "描写の品質",
          variants = {
            high = "高品質",
            low = "低品質"
          }
        },
        size_adjustment = {
          doc = "テキストを表示する際、この値だけ大きくまたは小さくして表示します。\nお使いのフォントに合わせて調整してください。\n",
          name = "サイズの調整"
        },
        vertical_offset = {
          doc = "テキストを表示する際、垂直方向にこの値だけずらして表示します。\nお使いのフォントに合わせて調整してください。\n",
          name = "垂直オフセット"
        }
      },
      foobar = {
        allow_enhanced_skill_tracking = {
          doc = "スキルトラックに潜在能力を表示します。",
          name = "スキルトラック拡張"
        },
        autopick = {
          doc = "特定のアイテムの上に乗ったとき自動でそのアイテムを拾います。",
          name = "Autopick",
          yes_no = "core.config.common.yes_no.tsukau_tsukawanai"
        },
        autosave = {
          doc = "特定の行動をした後に自動でセーブされます。",
          name = "オートセーブ",
          yes_no = "core.config.common.yes_no.yuukou_mukou"
        },
        damage_popup = {
          name = "ダメージポップアップ",
          yes_no = "core.config.common.yes_no.ari_nashi"
        },
        enhanced_skill_tracking_lowerbound = {
          doc = "この値よりも潜在能力が低い場合赤色で表示されます。\nスキルトラック拡張を「する」に設定している場合にのみ効果があります。\n",
          name = "スキルトラック拡張(下限)"
        },
        enhanced_skill_tracking_upperbound = {
          doc = "この値よりも潜在能力が高い場合緑色で表示されます。\nスキルトラック拡張を「する」に設定している場合にのみ効果があります。\n",
          name = "スキルトラック拡張(上限)"
        },
        hp_bar_position = {
          doc = "聴診器を当てたペットのHPを表示します。\n「右側に表示」を推奨しています。\n",
          name = "ペットのHPバー",
          variants = {
            hide = "表示しない",
            left = "左側に表示",
            right = "右側に表示"
          }
        },
        leash_icon = {
          doc = "紐で繋がれているペットのHPバーの横に紐のアイコンを表示します。\nペットのHPバーを「左側に表示」か「右側に表示」にしている場合にのみ効果があります。\n",
          name = "紐のアイコン表示"
        },
        max_damage_popup = {
          name = "ダメージポップアップ最大数"
        },
        name = "拡張設定(foobar)",
        pcc_graphic_scale = {
          name = "PCC表示",
          variants = {
            fullscale = "原寸",
            shrinked = "縮小(通常)"
          }
        },
        show_fps = {
          name = "FPSを表示"
        },
        skip_confirm_at_shop = {
          doc = "街の店において、売り買いの確認を省略します。",
          name = "売買確認を省略"
        },
        skip_overcasting_warning = {
          doc = "マナが足りないときに表示される警告画面を省略します。",
          name = "マナ不足の警告を省略"
        },
        startup_script = {}
      },
      game = {
        attack_neutral_npcs = {
          doc = "中立NPCに向かって歩いたとき、そのNPCに対して攻撃します。",
          name = "非好戦的NPCを攻撃"
        },
        default_save = {
          doc = "Elonaを起動した際にデフォルトで読み込まれるセーブデータです。\nこれを設定するとタイトル画面を飛ばしてすぐにゲームを始めることができます。\n",
          name = "デフォルトセーブ",
          variants = {
            [""] = "使用しない"
          }
        },
        extra_help = {
          doc = "Elonaに不慣れな冒険者に向けて妖精ノルンによる案内が表示されます。",
          name = "ノルンの冒険ガイド"
        },
        hide_autoidentify = {
          doc = "自然鑑定が行われた際のメッセージを非表示にします。",
          name = "自然鑑定ﾒｯｾｰｼﾞの非表示"
        },
        hide_shop_updates = {
          doc = "店の販売ログを非表示にします。",
          name = "店ﾒｯｾｰｼﾞの非表示"
        },
        name = "ゲーム設定",
        story = {
          doc = "Elonaのメインストーリーを再生します。",
          name = "シーンの再生",
          yes_no = "core.config.common.yes_no.saisei_suru_shinai"
        }
      },
      input = {
        attack_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "攻撃の間隔"
        },
        autodisable_numlock = {
          name = "numlockを自動制御"
        },
        initial_key_repeat_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "キーリピートウェイト(開始)"
        },
        joypad = {
          name = "ゲームパッド",
          yes_no = "core.config.common.yes_no.unsupported"
        },
        key_repeat_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "キーリピートウェイト"
        },
        key_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "キーウェイト"
        },
        name = "入力設定",
        run_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "走りの速さ"
        },
        select_fast_start_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "選択ウェイト(早い,開始)"
        },
        select_fast_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "選択ウェイト(早い)"
        },
        select_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "選択ウェイト"
        },
        start_run_wait = {
          formatter = function(_1)
  return ("%s %s+1 steps")
  :format(After , _1)
end,
          name = "走り開始の速さ"
        },
        walk_wait = {
          formatter = "core.config.common.formatter.wait",
          name = "歩きの速さ"
        }
      },
      keybindings = {
        name = "キーの割り当て"
      },
      language = {
        language = {
          name = "言語*",
          variants = {
            en = "English",
            jp = "Japanese"
          }
        },
        name = "言語(Language)"
      },
      message = {
        add_timestamps = {
          doc = "メッセージに現在の分を表示します。",
          name = "ﾒｯｾｰｼﾞに分表示追加"
        },
        name = "メッセージとログ",
        transparency = {
          doc = "古いメッセージをこのパーセンテージだけ透明にして表示します。",
          formatter = function(_1)
  return ("%s*10 %")
  :format(_1)
end,
          name = "過去のﾒｯｾｰｼﾞの透過"
        }
      },
      mods = {
        name = "MOD設定"
      },
      name = "オプション",
      net = {
        chat = {
          name = "チャット",
          variants = {
            disabled = "使用しない",
            receive = "受信のみ",
            send_receive = "送信/受信"
          }
        },
        chat_receive_interval = {
          doc = "チャットや死亡ログ、願いログを受け取る頻度を設定します。\n",
          formatter = "core.config.common.formatter.every_minutes",
          name = "受信頻度"
        },
        death = {
          name = "死亡ログ",
          variants = {
            disabled = "使用しない",
            receive = "受信のみ",
            send_receive = "送信/受信"
          }
        },
        hide_your_alias = {
          doc = "チャットや死亡ログ、願いログを送るとき、PCの異名をランダムな異名で置き換えて送ります。\n異名投票でも変換後の異名が使われます。\n",
          name = "異名を隠す"
        },
        hide_your_name = {
          doc = "チャットや死亡ログ、願いログを送るとき、PCの名前をランダムな名前で置き換えて送ります。\n異名投票でも変換後の名前が使われます。\n",
          name = "名前を隠す"
        },
        is_alias_vote_enabled = {
          name = "異名投票"
        },
        is_enabled = {
          doc = "ネット機能を使用するかどうかを設定します。\n以下のオプションはこのオプションを「する」にしたときに限り有効となります。\n",
          name = "ネットの使用"
        },
        name = "ネット機能の設定",
        news = {
          name = "パルミア・タイムズ",
          variants = {
            disabled = "使用しない",
            receive = "受信のみ",
            send_receive = "送信/受信"
          }
        },
        wish = {
          name = "願いログ",
          variants = {
            disabled = "使用しない",
            receive = "受信のみ",
            send_receive = "送信/受信"
          }
        }
      },
      screen = {
        display_mode = {
          name = "画面の大きさ*"
        },
        fullscreen = {
          doc = "ウィンドウとフルスクリーンを切り替えます。\nフルスクリーン2は、スクリーンと同じサイズのウィンドウを生成し擬似的にフルスクリーンとします。\n",
          name = "画面モード*",
          variants = {
            desktop_fullscreen = "フルスクリーン2",
            fullscreen = "フルスクリーン",
            windowed = "ウィンドウ"
          }
        },
        heartbeat = {
          doc = "HPが残り少ないとき、心拍音を再生します。",
          name = "心臓の音",
          yes_no = "core.config.common.yes_no.saisei_suru_shinai"
        },
        heartbeat_threshold = {
          doc = "現在のHPがこのパーセンテージを下回っているとき心拍音が再生されます。\nこの設定は「心臓の音」の設定を「再生する」にしているときのみ使われます。\n",
          name = "心音再生の閾値"
        },
        high_quality_shadows = {
          doc = "影の描写品質を設定します。\n高画質は描写速度がやや低下しますが、影がより綺麗に表示されます。\n",
          name = "光源の描写",
          yes_no = "core.config.common.yes_no.kougashitsu_teigashitsu"
        },
        music = {
          doc = "BGMを再生します。",
          name = "BGMの再生*",
          yes_no = "core.config.common.yes_no.ari_nashi"
        },
        name = "画面と音の設定",
        object_shadows = {
          doc = "地面に置かれたアイテムの下に影を表示します。",
          name = "アイテムの影描写",
          yes_no = "core.config.common.yes_no.ari_nashi_slow_fast"
        },
        orientation = {
          name = "画面の向き",
          variants = {
            landscape = "横向き",
            portrait = "縦向き",
            reverse_landscape = "横向き (反転)",
            reverse_portrait = "縦向き (反転)",
            sensor = "自動回転",
            sensor_landscape = "横向き (自動)",
            sensor_portrait = "縦向き (自動)"
          }
        },
        skip_random_event_popups = {
          doc = "ランダムイベントのポップアップウィンドウをスキップします。\nスキップされた場合デフォルトの選択肢が選ばれます。\n",
          name = "イベントの短縮"
        },
        sound = {
          doc = "SEを再生します。",
          name = "サウンドの再生*",
          yes_no = "core.config.common.yes_no.ari_nashi"
        },
        stereo_sound = {
          doc = "音が鳴った場所に応じてSEを再生します。\n例えば、画面左で鳴ったSEが左から聞こえるようになります。\n",
          name = "ステレオサウンド"
        },
        window_mode = {
          name = "ウィンドウの大きさ*"
        }
      }
    }
  }
}