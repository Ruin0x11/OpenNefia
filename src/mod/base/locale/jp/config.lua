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
            anime = {
               name = "アニメ設定",
            }
         },
      },
      option = {
         base = {
            screen_refresh = {
               formatter = "core.config.common.formatter.wait",
               name = "画面の更新頻度"
            },
         }
      }
   }
}
