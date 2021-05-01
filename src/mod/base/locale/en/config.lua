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
            game = {
               name = "Game Setting"
            },
            screen = {
               name = "Screen & Sound"
            },
            net = {
               name = "Network Setting"
            },
            anime = {
               name = "Animation Setting"
            },
            input = {
               name = "Input Setting"
            },
            keybindings = {
               name = "Keybindings"
            },
            message = {
               name = "Message & Log"
            },
            language = {
               name = "Language"
            },
         }
      },
      option = {
         base = {

            --
            -- Menu: game
            --

            extra_help = {
               doc = "Show extra help popups for new players.",
               name = "Extra Help"
            },

            attack_neutral_npcs = {
               doc = "Attack non-hostile, non-ally NPCs when running into them.",
               name = "Attack Netural NPCs"
            },

            story = {
               doc = "Enable playback of the story cutscenes.",
               name = "Enable Cutscenes"
            },

            default_save = {
               doc = "Saved game to be loaded on startup.\nThese are calculated when the game loads.\nIf one is missing, restart the game to have it appear.\n",
               name = "Default Save",
               variants = {
                  [""] = "None"
               }
            },

            hide_shop_updates = {
               doc = "Hide daily shop reports of items sold for shops you own.",
               name = "Hide Shop Updates"
            },

            hide_autoidentify = {
               doc = "Hide identify status updates from Sense Quality.",
               name = "Hide Auto-Identify"
            },

            skip_random_event_popups = {
               doc = "Skip displaying random event popup windows.\nRandom events will still occur. In most cases, a default option will be chosen.\n",
               name = "Skip Random Events"
            },

            autosave = {
               doc = "Frequency of autosaving.",
               name = "Autosave",
               variants = {
                  always = "Always",
                  sometimes = "Sometimes",
                  rarely = "Rarely",
                  almost_never = "Almost never"
               }
            },

            default_return_to_title = {
               doc = "If enabled, sets 'Return to Title' as the default option for the quit menu.",
               name = "Default Return to Title",
            },

            --
            -- Menu: screen
            --

            music = {
               doc = "Enable or disable music.",
               name = "Music*",
               yes_no = "config.common.yes_no.on_off"
            },

            midi_driver = {
               doc = "Driver to use for MIDI playback.\nThe generic driver will work across all platforms.\nThe MCI driver is Windows-only.",
               name = "MIDI Driver",
               variants = {
                  generic = "Generic",
                  native = "MCI"
               }
            },

            midi_device = {
               doc = "Device to use for MIDI playback.\nOnly applies when using the generic MIDI driver.",
               name = "MIDI Device"
            },

            sound = {
               doc = "Enable or disable sound.",
               name = "Sound*",
               yes_no = "config.common.yes_no.on_off"
            },

            positional_audio = {
               doc = "Whether or not to play certain sounds based on the position of the source.\nExamples are magic casting, eating/drinking, and damage.\n",
               name = "Positional Audio"
            },

            screen_mode = {
               doc = "Fullscreen mode.\n'Full screen' will use a hardware fullscreen mode.\n'Desktop fullscr' will create a borderless window the same size as the screen.\n",
               name = "Screen Mode*",
               variants = {
                  desktop = "Desktop fullscr",
                  exclusive = "Full screen",
                  windowed = "Window mode"
               }
            },

            object_shadows = {
               doc = "Display shadows under items on the ground.",
               name = "Object Shadow",
               yes_no = "config.common.yes_no.slow_fast"
            },

            screen_resolution = {
               doc = "Screen resolution to use.\nThe available options may change depending on the graphics hardware you use.\n",
               name = "Screen Resolution*"
            },

            high_quality_shadows = {
               doc = "Render shadows at higher quality.",
               name = "Shadow Quality",
               yes_no = "config.common.yes_no.high_low"
            },

            heartbeat = {
               doc = "Play heartbeat sound when health is low.\nThe threshold to play at is configurable.\n",
               name = "Heartbeat Sound"
            },

            heartbeat_threshold = {
               doc = "% of HP remaining to play heartbeat sound at.",
               name = "Heartbeat Threshold"
            },

            --
            -- Menu: net
            --

            enable_net = {
               doc = "Enable or disable network-related features.\nThe following options are available only if the option is set to Yes.\n",
               name = "Use Network"
            },

            --
            -- Menu: anime
            --

            attack_anime = {
               doc = "Play animations when melee/ranged attacking.",
               name = "Attack Animation"
            },

            general_wait = {
               doc = "Number of frames to wait for most animations/actions.\nFor example, it controls the amount of delay for input polling.\n",
               formatter = "config.common.formatter.wait",
               name = "General Wait"
            },

            title_effect = {
               doc = "Play animations at the title screen.\n",
               name = "Title Water Effect",
               yes_no = "config.common.yes_no.on_off"
            },

            auto_turn_speed = {
               doc = "Speed of auto-turn actions.\nThis is also affected by 'Animation Wait'.\n",
               name = "Auto Turn Speed",
               variants = {
                  high = "High",
                  highest = "Highest",
                  normal = "Normal"
               }
            },

            scroll = {
               doc = "Enable scrolling animations.",
               name = "Smooth Scroll"
            },

            window_anime = {
               doc = "Play window animations for certain character-related menus.",
               name = "Window Animation"
            },

            always_center = {
               doc = "Always keep the center of the screen near the player when walking near the edge of the screen.",
               name = "Always Center"
            },

            alert_wait = {
               doc = "Number of frames to wait if an important message is received.\nThese are: leveling up, leveling up a skill, or having a change in hunger status.\n",
               name = "Alert Wait"
            },

            screen_refresh = {
               doc = "Number of frames to wait between updates to animations in the screen, like rain/lighting.\nThis does not affect key delay or animations that block input.\n",
               formatter = "config.common.formatter.wait",
               name = "Screen Refresh"
            },

            anime_wait = {
               doc = "Number of frames to wait for animations.\nThis also acts as multiplier for the speed of auto-turn actions.\n",
               formatter = "config.common.formatter.wait",
               name = "Animation Wait"
            },

            anime_wait_type = {
               name = "Animation Wait Type",
               variants = {
                  always_wait = "Always wait",
                  at_turn_start = "At turn start",
                  never_wait = "Don't wait"
               }
            },

            weather_effect = {
               doc = "Play weather-related animations.",
               name = "Weather Effect"
            },

            background_effect_wait = {
               name = "Background Effect Wait",
            },

            update_unfocused_ui_layers = {
               doc = [[
Updates things like the UI/weather/animations in the background if another window is active.
NOTE: This is an experimental feature which may lead to errors or lockups.
]],
               name = "Redraw Background Layers",
            },

            scroll_when_run = {
               doc = "Show scrolling animations when running.\nTurning this off can speed up running somewhat.\n",
               name = "Scroll When Run"
            },

            skip_sleep_animation = {
               doc = "Skip playing the fading animation when sleeping.",
               name = "Skip Sleep Animation"
            },

            --
            -- Menu: message
            --

            message_timestamps = {
               doc = "Add a turn timestamp to each message received.\n",
               name = "Add time info"
            },

            message_transparency = {
               doc = "Controls the amount of transparency older message log messages receive.",
               formatter = function(_1)
                  return ("%s %%")
                     :format(_1*10)
               end,
               name = "Transparency"
            },

            --
            -- Menu: language
            --

            language = {
               name = "Language*",
            },

            --
            -- Menu: input
            --

            autodisable_numlock = {
               doc = "If Numlock is on, turns off Numlock while playing and turns it back on again after exiting.\nIt can fix issues related to holding Shift and a numpad movement key at the same time.\nThis only has an effect on Windows.\n",
               name = "Auto-Disable Numlock"
            },

            attack_wait = {
               doc = "Number of frames to wait between consecutive attacks when running into enemies.",
               formatter = "config.common.formatter.wait",
               name = "Attack Interval"
            },

            key_repeat_wait = {
               doc = "Number of frames to wait between any actions.",
               formatter = "config.common.formatter.wait",
               name = "Key repeat wait"
            },

            select_wait = {
               doc = "Number of frames to wait between item selection initially.",
               formatter = "config.common.formatter.wait",
               name = "Select Wait"
            },

            run_wait = {
               doc = "Number of frames to wait between movement commands when running.",
               formatter = "config.common.formatter.wait",
               name = "Run Speed"
            },

            initial_key_repeat_wait = {
               doc = "Number of frames to wait between the first action and the second.",
               formatter = "config.common.formatter.wait",
               name = "Initial key repeat wait"
            },

            walk_wait = {
               doc = "Number of frames to wait between movement commands when walking.",
               formatter = "config.common.formatter.wait",
               name = "Walk Speed"
            },

            key_wait = {
               doc = "Number of frames to wait between presses of shortcut keys.",
               formatter = "config.common.formatter.wait",
               name = "Key Wait"
            },

            select_fast_wait = {
               doc = "Number of frames to wait between item selection when selecting quickly.",
               formatter = "config.common.formatter.wait",
               name = "Select Fast Wait"
            },

            start_run_wait = {
               doc = "Number of movement commands to play when walking before starting to run.",
               formatter = function(_1)
                  return ("After %s+1 steps")
                     :format(_1)
               end,
               name = "Run Start Wait"
            },

            select_fast_start_wait = {
               doc = "Number of selections to wait before selecting quickly.",
               formatter = "config.common.formatter.wait",
               name = "Select Fast Start Wait"
            },
         }
      }
   }
}
