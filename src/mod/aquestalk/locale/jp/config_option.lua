return {
   config = {
      menu = {
         aquestalk = {
            menu = {
               name = "AquesTalk",
            },
         }
      },
      option = {
         aquestalk = {
            enabled_chara_talk = {
               name = "AquesTalkの使用(キャラ)",
            },
            enabled_dialog = {
               name = "AquesTalkの使用(対話)",
            },
            enabled_scene = {
               name = "AquesTalkの使用(シーン)",
               variants = {
                  disabled = "しない",
                  dialog = "対話",
                  dialog_and_text = "対話＆テキスト",
               }
            },
            default_bas = {
               name = "デフォルトの基本素片",
               variants = {
                  f1e = "女声１",
                  f2e = "女声２",
                  m1e = "男声",
               }
            },
            default_spd = {
               name = "デフォルトの話速"
            },
            default_vol = {
               name = "デフォルトの音量"
            },
            default_pit = {
               name = "デフォルトの高さ"
            },
            default_acc = {
               name = "デフォルトのアクセント"
            },
            default_lmd = {
               name = "デフォルトの音程１"
            },
            default_fsc = {
               name = "デフォルトの音程２"
            },
         }
      }
   }
}
