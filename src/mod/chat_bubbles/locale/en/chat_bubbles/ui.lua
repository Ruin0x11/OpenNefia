return {
   ui = {
      menu = {
         config = {
            title = {
               individual = "Individual Settings",
               default = "Default Settings"
            },
            options = {
               talk_type = {
                  title = "Talk Type",
                  choices = {
                     male = {
                        _0 = "Type 0",
                        _1 = "Type 1",
                        _2 = "Type 2",
                        _3 = "Type 3",
                        _4 = "Type 4",
                        _5 = "Type 5",
                        _6 = "Type 6"
                     },
                     female = {
                        _0 = "Type 0",
                        _1 = "Type 1",
                        _2 = "Type 2",
                        _3 = "Type 3",
                        _4 = "Type 4",
                        _5 = "Type 5",
                        _6 = "Type 6"
                     }
                  }
               },
               show_when_disabled = {
                  title = "Show When Disabled",
                  choices = {
                     never = "Never",
                     once = "Once",
                     unlimited = "Unlimited",
                  }
               },
               x_offset = {
                  title = "X Offset",
               },
               y_offset = {
                  title = "Y Offset",
               },
               text_color = {
                  title = "Text Color",
               },
               bg_color = {
                  title = "BG Color",
               },
               font = {
                  title = "Font",
               },
               font_size = {
                  title = "Font Size",
               },
               font_style = {
                  title = "Font Style",
                  choices = {
                     normal = "Normal",
                     bold = "Bold",
                     italic = "Italic",
                     underline = "Underline",
                     strikethrough = "Strikethrough",
                  }
               },
            },
            key_actions = {
               individual_config = "Config Individual",
               default_config = "Config Defaults"
            },
            topic = {
               category = "Category"
            },

            test_text = "Chat Bubble TEST",

            individual_setting = function(_1) return ("Indiv. Setting: %s"):format(_1) end,
         }
      }
   }
}
