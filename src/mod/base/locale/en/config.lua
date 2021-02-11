return {
   config = {
      common = {
         assign_button = "To assign a button, move the cursor to\nan item and press the button.",
         formatter = {
            every_minutes = function(_1)
               return ("Every %s min.")
                  :format(_1)
            end,
            wait = function(_1)
               return ("%s wait")
                  :format(_1)
            end
         },
         menu = "Menu",
         no_desc = "(No description available.)",
         require_restart = "Items marked with * require restart to apply changes.",
         yes_no = {
            default = {
               no = "No",
               yes = "Yes"
            },
            enable_disable = {
               no = "Disable",
               yes = "Enable"
            },
            high_low = {
               no = "Low",
               yes = "High"
            },
            on_off = {
               no = "Off",
               yes = "On"
            },
            play_dont_play = {
               no = "Don't play",
               yes = "Play"
            },
            show_dont_show = {
               no = "Don't show",
               yes = "Show"
            },
            slow_fast = {
               no = "No (Fast)",
               yes = "Yes (Slow)"
            },
            unsupported = {
               no = "No(unsupported)",
               yes = "No(unsupported)"
            },
            use_dont_use = {
               no = "Don't use",
               yes = "Use"
            }
         }
      },
      menu = {
         base = {
            default = {
               name = "Option",
            },
            anime = {
               name = "Animation Setting",
            }
         },
      },
      option = {
         base = {
            screen_refresh = {
               doc = "Number of frames to wait between updates to animations in the screen, like rain/lighting.\nThis does not affect key delay or animations that block input.\n",
               formatter = "config.common.formatter.wait",
               name = "Screen Refresh"
            }
         }
      }
   }
}
