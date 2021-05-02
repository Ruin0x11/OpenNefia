return {
   ui = {
      menu = {
         config = {
            title = {
               individual = "個別設定",
               default = "吹き出しデフォルト設定"
            },
            hint = {
               action = {
                  reset = "設定初期化",
                  individual_settings = "吹き出し個別設定",
                  default_settings = "吹き出しデフォルト設定"
               }
            },
            options = {
               talk_type = {
                  title = "会話タイプ",
                  choices = {
                     male = {
                        _0 = "私：お願いします",
                        _1 = "俺：頼む",
                        _2 = "僕：頼むね",
                        _3 = "自分：頼む…",
                        _4 = "麻呂：頼むぞよ",
                        _5 = "拙者：頼み申す",
                        _6 = "あっし：頼むッス"
                     },
                     female = {
                        _0 = "私：お願いしますわ",
                        _1 = "あたし：頼むよ",
                        _2 = "わたし：頼むわ",
                        _3 = "自分：頼むわ…",
                        _4 = "わらわ：頼むぞよ",
                        _5 = "手前：お頼み申し上げます",
                        _6 = "みゅー：おねがいにゃ"
                     }
                  }
               },
               show_when_disabled = {
                  title = "吹き出しオフでも表示",
                  choices = {
                     disabled = "しない",
                     once = "一つ",
                     unlimited = "無制限",
                  }
               },
               x_offset = {
                  title = "位置ｘ",
               },
               y_offset = {
                  title = "位置ｙ",
               },
               text_color = {
                  title = "文字色",
               },
               bg_color = {
                  title = "背景色",
               },
               font = {
                  title = "フォント",
               },
               font_size = {
                  title = "フォントサイズ",
               },
               font_style = {
                  title = "フォント装飾",
                  choices = {
                     normal = "N",
                     bold = "B",
                     italic = "I",
                     underline = "U",
                     strikethrough = "S",
                  }
               },
            },
            topic = {
               category = "項目"
            },

            test_text = "吹き出しTEST",

            individual_setting = function(_1) return ("個別設定：%s"):format(_1) end
         }
      }
   }
}
