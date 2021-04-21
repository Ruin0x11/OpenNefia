return {
   config = {
      menu = {
         chat_bubbles = {
            menu = {
               name = "セリフポップアップ",
            },
         }
      },
      option = {
         chat_bubbles = {
            enabled = {
               name = "セリフポップアップ",
               variants = {
                  disabled = "しない",
                  once = "する（1キャラ1つ）",
                  unlimited = "する（無制限）"
               }
            },
            default_font_size = {
               name = "フォントサイズ"
            },
            display_duration = {
               name = "表示速度"
            },
            default_text_color = {
               name = "テキストの色"
            },
            default_bubble_color = {
               name = "背景の色"
            },
            shorten_last_words = {
               name = "断末魔",
               no = "残す",
               yes = "消す"
            }
         }
      }
   }
}
