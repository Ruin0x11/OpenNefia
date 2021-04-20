return {
   config = {
      menu = {
         chat_bubbles = {
            menu = {
               name = "Chat Bubbles",
            },
         }
      },
      option = {
         chat_bubbles = {
            enabled = {
               name = "Speech balloon",
               variants = {
                  disabled = "Don't show",
                  once = "Show(1 balloon per chara)",
                  unlimited = "Show(unlimited)"
               }
            },
            default_font_size = {
               name = "Font size"
            },
            display_duration = {
               name = "Displayed duration"
            },
            default_text_color = {
               name = "Text color"
            },
            default_bubble_color = {
               name = "Bubble color"
            },
            shorten_last_words = {
               name = "Last words",
               no = "Remain in a while",
               yes = "Fade out soon"
            }
         }
      }
   }
}
