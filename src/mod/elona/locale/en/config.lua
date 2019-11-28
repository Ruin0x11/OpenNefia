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
      android = {
        hide_navigation = {
          doc = "Hides the software navigation buttons for handsets without hardware navigation buttons.\n",
          name = "Hide Nav Buttons*"
        },
        name = "Android Setting",
        quick_action_size = {
          doc = "Controls size of touch actions.",
          name = "Quick Action Size"
        },
        quick_action_transparency = {
          doc = "Controls transparency of touch actions.",
          name = "Quick Action Transp."
        },
        quicksave = {
          doc = "Quicksave the game if you're being queried for input and app focus is lost.\n",
          name = "Save On Suspend"
        },
        vibrate = {
          doc = "Vibrate on important events and low health.\n",
          name = "Vibrate"
        },
        vibrate_duration = {
          doc = "Controls the duration of the vibration in 'Vibrate'.",
          name = "Vibrate Duration"
        }
      },
      anime = {
        alert_wait = {
          doc = "Number of frames to wait if an important message is received.\nThese are: leveling up, leveling up a skill, or having a change in hunger status.\n",
          name = "Alert Wait"
        },
        always_center = {
          doc = "Always keep the center of the screen near the player when walking near the edge of the screen.",
          name = "Always Center"
        },
        anime_wait = {
          doc = "Number of frames to wait for animations.\nThis also acts as multiplier for the speed of auto-turn actions.\n",
          formatter = "core.config.common.formatter.wait",
          name = "Animation Wait"
        },
        attack_anime = {
          doc = "Play animations when melee/ranged attacking.",
          name = "Attack Animation"
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
        general_wait = {
          doc = "Number of frames to wait for most animations/actions.\nFor example, it controls the amount of delay for input polling.\n",
          formatter = "core.config.common.formatter.wait",
          name = "General Wait"
        },
        name = "Animation Setting",
        screen_refresh = {
          doc = "Number of frames to wait between updates to animations in the screen, like rain/lighting.\nThis does not affect key delay or animations that block input.\n",
          formatter = "core.config.common.formatter.wait",
          name = "Screen Refresh"
        },
        scroll = {
          doc = "Enable scrolling animations.",
          name = "Smooth Scroll"
        },
        scroll_when_run = {
          doc = "Show scrolling animations when running.\nTurning this off can speed up running somewhat.\n",
          name = "Scroll When Run"
        },
        title_effect = {
          doc = "Play animations at the title screen.\n",
          name = "Title Water Effect",
          yes_no = "core.config.common.yes_no.on_off"
        },
        weather_effect = {
          doc = "Play weather-related animations.",
          name = "Weather Effect"
        },
        window_anime = {
          doc = "Play window animations for certain character-related menus.",
          name = "Window Animation"
        }
      },
      balance = {
        doc = "These settings affect game balance.",
        extra_class = {
          doc = "Enable extra classes in character creation.",
          name = "Extra Class"
        },
        extra_race = {
          doc = "Enable extra races in character creation.",
          name = "Extra Race"
        },
        name = "Game Balance Setting",
        restock_interval = {
          doc = "Interval in days it takes shops to restock items.\nIf 0, the item selection will change each time you interact with a shopkeeper.\n",
          formatter = function(_1)
  return ("%s day%s")
  :format(_1, s(_1))
end,
          name = "Restock Interval"
        }
      },
      font = {
        doc = "Font-related settings.\nPlace fonts (TTF format) in data/font. Please ensure the fonts are monospaced to avoid issues.\n",
        name = "Font Setting",
        quality = {
          doc = "Text rendering quality. High is beautiful, but slow. Low is cheap, but fast.\n",
          name = "Rendering Quality",
          variants = {
            high = "High",
            low = "Low"
          }
        },
        size_adjustment = {
          doc = "Size adjustment for certain pieces of text.\n",
          name = "Size Adjustment"
        },
        vertical_offset = {
          doc = "Vertical text offset for certain menu titles.\n",
          name = "Vertical Offset"
        }
      },
      foobar = {
        allow_enhanced_skill_tracking = {
          doc = "Increases the number of trackable skills to 10 and colorizes potential.\n",
          name = "Allow enhanced skill tracking"
        },
        autopick = {
          doc = "Automatically pick up items you pass over.",
          name = "Autopick",
          yes_no = "core.config.common.yes_no.use_dont_use"
        },
        autosave = {
          doc = "Automatically save the game at certain intervals.\nThese include (but are not limited to):\nUsing scrolls of create material.\nUsing potions of gain potential.\nOpening chests/material boxes.\n",
          name = "Autosave",
          yes_no = "core.config.common.yes_no.enable_disable"
        },
        damage_popup = {
          doc = "Show damage popups.",
          name = "Damage popup",
          yes_no = "core.config.common.yes_no.on_off"
        },
        doc = "Extra config settings added in Elona foobar.",
        enhanced_skill_tracking_lowerbound = {
          doc = "Potential below this amount will be colored red in the skill tracker.\nOnly has an effect when used with 'Allow enhanced skill tracking'.\n",
          name = "Enhanced tracking lowerbound"
        },
        enhanced_skill_tracking_upperbound = {
          doc = "Potential above this amount will be colored green in the skill tracker.\nOnly has an effect when used with 'Allow enhanced skill tracking'.\n",
          name = "Enhanced tracking upperbound"
        },
        hp_bar_position = {
          name = "Pets' HP bar",
          variants = {
            hide = "Don't show",
            left = "Show left side",
            right = "Show right side"
          }
        },
        leash_icon = {
          doc = "Display a leash icon for leashed pets.\n",
          name = "Leash icon",
          yes_no = "core.config.common.yes_no.show_dont_show"
        },
        max_damage_popup = {
          doc = "Maximum amount of damage popups to render.\nOnly has an effect when used with 'Damage popup'.\n",
          name = "Max damage popup"
        },
        name = "Ex setting(foobar)",
        pcc_graphic_scale = {
          name = "PCC Graphic",
          variants = {
            fullscale = "Full-scale",
            shrinked = "Shrinked"
          }
        },
        show_fps = {
          name = "Show FPS",
          yes_no = "core.config.common.yes_no.show_dont_show"
        },
        skip_confirm_at_shop = {
          doc = "Skip confirm to buy or sell items at town shops.",
          name = "Skip confirm at shop"
        },
        skip_overcasting_warning = {
          doc = "Skip warning prompt displayed when you are going to over-cast spells.",
          name = "Skip over-casting warning"
        },
        startup_script = {
          doc = "Run a script in the data/script/ folder at startup.\nProvide a script's name, like 'my_script.lua' for 'data/script/my_script.lua'.\n"
        }
      },
      game = {
        attack_neutral_npcs = {
          doc = "Attack non-hostile, non-ally NPCs when running into them.",
          name = "Attack Netural NPCs"
        },
        default_save = {
          doc = "Saved game to be loaded on startup.\nThese are calculated when the game loads.\nIf one is missing, restart the game to have it appear.\n",
          name = "Default Save",
          variants = {
            [""] = "None"
          }
        },
        extra_help = {
          doc = "Show extra help popups for new players.",
          name = "Extra Help"
        },
        hide_autoidentify = {
          doc = "Hide identify status updates from Sense Quality.",
          name = "Hide Auto-Identify"
        },
        hide_shop_updates = {
          doc = "Hide daily shop reports of items sold for shops you own.",
          name = "Hide Shop Updates"
        },
        name = "Game Setting",
        story = {
          doc = "Enable playback of the story cutscenes.",
          name = "Enable Cutscenes"
        }
      },
      input = {
        attack_wait = {
          doc = "Number of frames to wait between consecutive attacks when running into enemies.",
          formatter = "core.config.common.formatter.wait",
          name = "Attack Interval"
        },
        autodisable_numlock = {
          doc = "If Numlock is on, turns off Numlock while playing and turns it back on again after exiting.\nIt can fix issues related to holding Shift and a numpad movement key at the same time.\nThis only has an effect on Windows.\n",
          name = "Auto-Disable Numlock"
        },
        initial_key_repeat_wait = {
          doc = "Number of frames to wait between the first action and the second.",
          formatter = "core.config.common.formatter.wait",
          name = "Initial key repeat wait"
        },
        joypad = {
          doc = "Enable gamepads.\nCurrently unimplemented.\n",
          name = "Game Pad",
          yes_no = "core.config.common.yes_no.unsupported"
        },
        key_repeat_wait = {
          doc = "Number of frames to wait between any actions.",
          formatter = "core.config.common.formatter.wait",
          name = "Key repeat wait"
        },
        key_wait = {
          doc = "Number of frames to wait between presses of shortcut keys.",
          formatter = "core.config.common.formatter.wait",
          name = "Key Wait"
        },
        name = "Input Setting",
        run_wait = {
          doc = "Number of frames to wait between movement commands when running.",
          formatter = "core.config.common.formatter.wait",
          name = "Run Speed"
        },
        select_fast_start_wait = {
          doc = "Number of selections to wait before selecting quickly.",
          formatter = "core.config.common.formatter.wait",
          name = "Select Fast Start Wait"
        },
        select_fast_wait = {
          doc = "Number of frames to wait between item selection when selecting quickly.",
          formatter = "core.config.common.formatter.wait",
          name = "Select Fast Wait"
        },
        select_wait = {
          doc = "Number of frames to wait between item selection initially.",
          formatter = "core.config.common.formatter.wait",
          name = "Select Wait"
        },
        start_run_wait = {
          doc = "Number of movement commands to play when walking before starting to run.",
          formatter = function(_1)
  return ("%s %s+1 steps")
  :format(After , _1)
end,
          name = "Run Start Wait"
        },
        walk_wait = {
          doc = "Number of frames to wait between movement commands when walking.",
          formatter = "core.config.common.formatter.wait",
          name = "Walk Speed"
        }
      },
      keybindings = {
        doc = "Configure game keybindings.",
        name = "Keybindings"
      },
      language = {
        language = {
          name = "Language*",
          variants = {
            en = "English",
            jp = "Japanese"
          }
        },
        name = "Language"
      },
      message = {
        add_timestamps = {
          doc = "Add a turn timestamp to each message received.\n",
          name = "Add time info"
        },
        name = "Message & Log",
        transparency = {
          doc = "Controls the amount of transparency older message log messages receive.",
          formatter = function(_1)
  return ("%s*10 %")
  :format(_1)
end,
          name = "Transparency"
        }
      },
      mods = {
        doc = "Settings provided by individual mods.\nThese can be created by editing the config_def.hcl file in the mod's folder.\n",
        name = "Mod Settings"
      },
      name = "Option",
      net = {
        chat = {
          name = "Chat Log",
          variants = {
            disabled = "Disable",
            receive = "Only receive",
            send_receive = "Send & receive"
          }
        },
        chat_receive_interval = {
          doc = "Set the interval between receiving chat, death wish and news log.\n",
          formatter = "core.config.common.formatter.every_minutes",
          name = "Chat Interval"
        },
        death = {
          name = "Death Log",
          variants = {
            disabled = "Disable",
            receive = "Only receive",
            send_receive = "Send & receive"
          }
        },
        hide_your_alias = {
          doc = "If you set the option Yes, your character's alias is replaced with a random alias\nwhen sending chat, death or wish log.\nWhen you register your alias, the converted one is used, too.\n",
          name = "Hide Your Alias"
        },
        hide_your_name = {
          doc = "If you set the option Yes, your character's name is replaced with a random name\nwhen sending chat, death or wish log.\nWhen you register your name, the converted one is used, too.\n",
          name = "Hide Your Name"
        },
        is_alias_vote_enabled = {
          name = "Alias Vote",
          yes_no = "core.config.common.yes_no.enable_disable"
        },
        is_enabled = {
          doc = "Enable or disable network-related features.\nThe following options are available only if the option is set to Yes.\n",
          name = "Use Network"
        },
        name = "Network Setting",
        news = {
          name = "Palmia Times",
          variants = {
            disabled = "Disable",
            receive = "Only receive",
            send_receive = "Send & receive"
          }
        },
        wish = {
          name = "Wish Log",
          variants = {
            disabled = "Disable",
            receive = "Only receive",
            send_receive = "Send & receive"
          }
        }
      },
      screen = {
        display_mode = {
          doc = "Screen resolution to use.\nThe available options may change depending on the graphics hardware you use.\n",
          name = "Screen Resolution*"
        },
        fullscreen = {
          doc = "Fullscreen mode.\n'Full screen' will use a hardware fullscreen mode.\n'Desktop fullscr' will create a borderless window the same size as the screen.\n",
          name = "Screen Mode*",
          variants = {
            desktop_fullscreen = "Desktop fullscr",
            fullscreen = "Full screen",
            windowed = "Window mode"
          }
        },
        heartbeat = {
          doc = "Play heartbeat sound when health is low.\nThe threshold to play at is configurable.\n",
          name = "Heartbeat Sound"
        },
        heartbeat_threshold = {
          doc = "% of HP remaining to play heartbeat sound at.",
          name = "Heartbeat Threshold"
        },
        high_quality_shadows = {
          doc = "Render shadows at higher quality.",
          name = "Shadow Quality",
          yes_no = "core.config.common.yes_no.high_low"
        },
        music = {
          doc = "Enable or disable music.",
          name = "Music*",
          yes_no = "core.config.common.yes_no.on_off"
        },
        name = "Screen & Sound",
        object_shadows = {
          doc = "Display shadows under items on the ground.",
          name = "Object Shadow",
          yes_no = "core.config.common.yes_no.slow_fast"
        },
        orientation = {
          doc = "Screen orientation to use when running the app.\nPortrait modes will display the game in a window at the top.\nLandscape modes will fill the entire screen.\n",
          name = "Screen Orientation",
          variants = {
            landscape = "Landscape",
            portrait = "Portrait",
            reverse_landscape = "Reverse Landscape",
            reverse_portrait = "Reverse Portrait",
            sensor = "Any",
            sensor_landscape = "Landscape (Auto)",
            sensor_portrait = "Portrait (Auto)"
          }
        },
        skip_random_event_popups = {
          doc = "Skip displaying random event popup windows.\nRandom events will still occur. In most cases, a default option will be chosen.\n",
          name = "Skip Random Events"
        },
        sound = {
          doc = "Enable or disable sound.",
          name = "Sound*",
          yes_no = "core.config.common.yes_no.on_off"
        },
        stereo_sound = {
          doc = "Whether or not to play certain sounds based on the position of the source.\nExamples are magic casting, eating/drinking, and damage.\n",
          name = "Stereo Sound"
        },
        window_mode = {
          name = "Window Size*"
        }
      }
    }
  }
}