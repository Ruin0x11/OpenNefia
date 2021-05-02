return {
  ui = {
    adventurers = {
      fame_lv = "Fame(Lv)",
      hospital = "Hospital",
      location = "Location",
      name_and_rank = "Name and Rank",
      rank_counter = function(_1) return ("%s"):format(ordinal(_1)) end,
      title = "Adventurer Rank",
      unknown = "Unknown"
    },
    alias = {
      hint = {
         action = {
            lock_alias = "Lock Alias",
            reroll = "Reroll",
         }
      },
      list = "Alias List",
      title = "Alias Selection"
    },
    ally_list = {
      alive = "(Alive)",
      call = {
        prompt = "Call who?",
        title = "Ally List",
        waiting = "(Waiting)"
      },
      dead = "(Dead)",
      gene_engineer = {
        body_skill = "Body/Skill",
        none = "None",
        prompt = "Who is the subject?",
        skill_too_low = "You need to be a better gene engineer.",
        title = "Ally List"
      },
      name = "Name",
      pet_arena = {
        ["in"] = "In",
        is_dead = function(_1)
  return ("%s %s dead.")
  :format(he(_1), is(_1))
end,
        need_at_least_one = "You need at least 1 pet to start the battle.",
        prompt = "Participant",
        title = "Ally List",
        too_many = "Too many participants."
      },
      proceed = "Proceed",
      ranch = {
        breed_power = "Breed Power",
        prompt = "Who takes the role of breeder?",
        title = "Ally List"
      },
      sell = {
        prompt = "Sell who?",
        title = "Ally List",
        value = "Value"
      },
      shop = {
        chr_negotiation = "CHR/Negotiation",
        prompt = "Who takes the role of shopkeeper?",
        title = "Ally List"
      },
      status = "Status",
      stayer = {
        prompt = "Who stays in your home?",
        title = "Ally List"
      },
      title = "Ally List",
      waiting = "Waiting"
    },
    analysis = {
      result = "Analysis Result",
      title = "Analyze Self"
    },
    appearance = {
      basic = {
        body = "Body    ",
        category = "Category",
        cloth = "Cloth   ",
        custom = "Custom  ",
        done = "Done    ",
        hair = "Hair    ",
        hair_color = "Hair CL ",
        pants = "Pants   ",
        portrait = "Portrait",
        riding = "Riding  ",
        set_detail = "Set Detail",
        sub_hair = "Sub Hair",
        title = "Appearance"
      },
      detail = {
        body_color = "Body CL ",
        cloth_color = "Cloth CL",
        etc_1 = "Etc1    ",
        etc_2 = "Etc2    ",
        etc_3 = "Etc3    ",
        eyes = "Eyes    ",
        pants_color = "Pants CL",
        set_basic = "Set Basic"
      },
      equipment = {
        belt = "Belt    ",
        chest = "Chest   ",
        done = "Done    ",
        glove = "Glove   ",
        leg = "Leg     ",
        mantle = "Mantle  ",
        part = "Part",
        title = "Parts to hide"
      },
    },
    article = function(_1)
  return ("[%s]")
  :format(_1)
end,
    assign_shortcut = function(_1)
  return ("You have assigned the shortcut to {%s} key.")
  :format(_1)
end,
    autodig = {
      disabled = "You disable autodig.",
      enabled = "You enable autodig.",
      mode = "Autodig"
    },
    autopick = {
      destroyed = function(_1)
  return ("%s was destroyed.")
  :format(name(_1))
end,
      do_you_really_destroy = function(_1)
  return ("Destroy %s?")
  :format(name(_1))
end,
      do_you_really_open = function(_1)
  return ("Open %s?")
  :format(name(_1))
end,
      do_you_really_pick_up = function(_1)
  return ("Pick up %s?")
  :format(name(_1))
end
    },
    board = {
      difficulty = "$",
      difficulty_counter = function(_1)
  return ("$ x %s")
  :format(_1)
end,
      do_you_meet = "Do you want to meet the client?",
      no_new_notices = "It seems there are no new notices.",
      title = "Notice Board"
    },
    body_part = {
      _0 = "",
      _1 = "Head",
      _10 = "Shoot",
      _11 = "Ammo",
      _2 = "Neck",
      _3 = "Back",
      _4 = "Body",
      _5 = "Hand",
      _6 = "Ring",
      _7 = "Arm",
      _8 = "Waist",
      _9 = "Leg"
    },
    bye = "Bye bye.",
    cast_style = {
      default = " casts a spell.",
      spider = " splits cobweb.",
      spill = " spreads body fluid.",
      tentacle = " puts out a tentacle.",
      gaze = " gazes.",
      spore = " scatters spores.",
      machine = " vibrates."
    },
    chara_sheet = {
      attribute = {
        fame = "Fame",
        karma = "Karma",
        life = "Life",
        mana = "Mana",
        melee = "Melee",
        sanity = "Sanity",
        shoot = "Shoot",
        speed = "Speed"
      },
      attributes = "Attributes(Org) - Potential",
      blessing_and_hex = "Blessing and Hex",
      buff = {
        duration = function(_1)
  return ("(%s) ")
  :format(_1)
end,
        hint = "Hint:",
        is_not_currently = "This character isn't currently blessed or hexed."
      },
      category = {
        resistance = "Resistance",
        skill = "Skill",
        weapon_proficiency = "Weapon Proficiency"
      },
      combat_rolls = "Combat Rolls",
      damage = {
        dist = "Dist",
        evade = "Evade",
        hit = "Hit",
        melee = "Melee",
        protect = "Prot",
        unarmed = "Unarmed"
      },
      exp = {
        exp = "EXP",
        god = "God",
        guild = "Guild",
        level = "Level",
        next_level = "Next Lv"
      },
      extra_info = "Extra Info",
      hint = {
        blessing_info = "Cursor [Blessing/Curse Info] ",
        confirm = "Shift,Esc [Confirm]",
        hint = "Cursor [Hint]  ",
        learn_skill = "Enter [Learn Skill]  ",
        reroll = "Enter Key [Reroll]  ",
        spend_bonus = "Enter [Spend Bonus]  ",
        track_skill = "Track Skill",
        train_skill = "Enter [Train Skill]  "
      },
      history = "Trace",
      personal = {
        age = "Age",
        age_counter = function(_1) return ("%s"):format(_1) end,
        aka = "Aka",
        class = "Class",
        height = "Height",
        name = "Name",
        race = "Race",
        sex = "Sex",
        weight = "Weight"
      },
      skill = {
        detail = "Detail",
        level = "Lv(Potential)",
        name = "Name",
        resist = function(_1)
  return ("Resist %s")
  :format(_1)
end
      },
      time = {
        days = "Days",
        days_counter = function(_1)
  return ("%s Days")
  :format(_1)
end,
        kills = "Kills",
        time = "Time",
        turn_counter = function(_1)
  return ("%s Turns")
  :format(_1)
end,
        turns = "Turns"
      },
      title = {
        default = "Character Sheet",
        learning = "Skill Learning",
        training = "Skill Training"
      },
      train_which_skill = "Train which skill?",
      weight = {
        cargo_limit = "Cargo Lmt",
        cargo_weight = "Cargo Wt",
        deepest_level = "Deepest Lv",
        equip_weight = "Equip Wt",
        level_counter = function(_1)
  return ("%s Level")
  :format(ordinal(_1))
end
      },
      you_can_spend_bonus = function(_1)
  return ("You can spend %s bonus points.")
  :format(_1)
end
    },
    chat = {
      key_hint = "Hit any key to close"
    },
    cheer_up_message = {
      _1 = "Larnneire cheers, Way to go!",
      _12 = "Opatos laughs, Muwahahahahahaha!",
      _2 = "Lomias grins, Go for it.",
      _24 = "Ehekatl hugs you,Don't die! Promise you don't die!",
      _3 = "Kumiromi worries, Are you...okay..?",
      _4 = "Lulwy sneers, You're tougher than I thought, little kitty.",
      _5 = "Larnneire cries, No...before it is too late...",
      _6 = "Lomias grins, It hasn't even started yet... has it?",
      _7 = "Lulwy warns you, Have a rest, kitty. If you are broken, you're no use to me.",
      _8 = "Lulwy laughs, I guess there's no use warning you. Alright. Do as you please, kitty."
    },
    curse_state = {
      blessed = "blessed",
      cursed = "cursed",
      doomed = "doomed"
    },
    date = function(_1, _2, _3)
  return ("%s %s/%s")
  :format(_1, _2, _3)
end,
    date_hour = function(_1)
  return ("%sh")
  :format(_1)
end,
    economy = {
      basic_tax = "Basic Tax",
      excise_tax = "Excise Tax",
      finance = "Town Finance",
      finance_detail = "Finance Detail",
      information = "Town Information",
      population = "Population",
      population_detail = "Population Detail"
    },
    equip = {
      acidproof = "Ac",
      ailment = {
        _0 = "Bl",
        _1 = "Pa",
        _2 = "Co",
        _3 = "Fe",
        _4 = "Sl",
        _5 = "Po"
      },
      cannot_be_taken_off = function(_1)
  return ("%s can't be taken off.")
  :format(itemname(_1))
end,
      category_name = "Category/Name",
      damage_bonus = "Damage Bonus",
      equip_weight = "Equip weight",
      fireproof = "Fi",
      hit_bonus = "Hit Bonus",
      main_hand = "Hand*",
      maintenance = {
        _0 = "St",
        _1 = "Co",
        _2 = "De",
        _3 = "Pe",
        _4 = "Le",
        _5 = "Wi",
        _6 = "Ma",
        _7 = "Ch",
        _8 = "Sp",
        _9 = "Lu"
      },
      title = "Equipment",
      weight = "Weight",
      you_unequip = function(_1)
  return ("You unequip %s.")
  :format(itemname(_1))
end
    },
    exhelp = {
      title = "- Norne's travel guide -"
    },
    furniture = {
      _0 = "",
      _1 = "stupid",
      _2 = "lame",
      _3 = "cool",
      _4 = "madam's favorite",
      _5 = "bewitched",
      _6 = "maniac",
      _7 = "magnificent",
      _8 = "royal",
      _9 = "masterpiece",
      _10 = "heavenly",
      _11 = "godly"
    },
    gold = " gold pieces",
    home = {
       elona = {
          cave = "cave",
          shack = "shack",
          cozy_house = "cozy house",
          estate = "estate",
          cyber_house = "cyber house",
          small_castle = "small castle"
       }
    },
    impression = {
      _0 = "Foe",
      _1 = "Hate",
      _2 = "Annoying",
      _3 = "Normal",
      _4 = "Amiable",
      _5 = "Friend",
      _6 = "Fellow",
      _7 = "Soul Mate",
      _8 = "*Love*"
    },
    invalid_target = "There's no valid target in that direction.",
    inventory_command = {
      general = "Examine",
      give = "Give",
      buy = "Buy",
      sell = "Sell",
      identify = "Identify",
      use = "Use",
      open = "Open",
      cook = "Cook",
      dip_source = "Mix",
      dip = "Mix Target",
      offer = "Offer",
      drop = "Drop",
      trade = "Trade",
      present = "Present",
      take = "Take",
      target = "Target",
      put = "Put",
      receive = "Take", -- "morau" (もらう) in JP, means to receive something
      throw = "Throw",
      steal = "Pickpocket",
      trade2 = "Trade",
      reserve = "Reserve",
      get = "Pick Up",
      eat = "Eat",
      equip = "Wear",
      read = "Read",
      drink = "Drink",
      zap = "Zap"
    },
    manual = {
      keys = {
        action = {
          apply = "Apply",
          bash = "Bash",
          cast = "Cast",
          dig = "Dig",
          fire = "Fire",
          go_down = "Go Down",
          go_up = "Go Up",
          interact = "Interact",
          open = "Open",
          search = "Search",
          target = "Target",
          title = "Action Keys",
          wait = "Wait"
        },
        info = {
          chara = "Character Info",
          feat = "Feat",
          help = "Help",
          journal = "Journal",
          log = "Log",
          material = "Material",
          title = "Information Keys"
        },
        item = {
          ammo = "Ammo",
          blend = "Blend",
          drop = "Drop",
          eat = "Eat",
          examine = "Examine",
          get = "Get",
          quaff = "Quaff",
          read = "Read",
          throw = "Throw",
          title = "Item Keys",
          tool = "Tool",
          wear_wield = "Wear/Wield",
          zap = "Zap"
        },
        list = "Key List",
        other = {
          close = "Close",
          console = "Console",
          export_chara_sheet = "Export chara sheet",
          give = "Give",
          hide_interface = "Hide interface",
          offer = "Offer",
          pray = "Pray",
          save = "Save",
          title = "Other Keys"
        }
      },
      topic = "Topic"
    },
    mark = {
      _0 = ".",
      _1 = "?",
      _2 = "!",
      _3 = ""
    },
    material = {
      detail = "Detail",
      name = "Name",
      amount = function(name, amount)
         return ("%s x %d"):format(name, amount)
      end
    },
    menu = {
      change = "Change",
      chara = {
        chara = "Chara",
        feat = "Feat",
        material = "Material",
        wear = "Wear"
      },
      log = {
        chat = "Chat",
        journal = "Journal",
        log = "Log"
      },
      spell = {
        skill = "Skill",
        spell = "Spell"
      },
      town = {
        chart = "Chart",
        economy = "City",
        politics = "Law"
      }
    },
    message = {
      key_hint = "Up,Down [Scr 1 line]   Left,Right [Scr 1 page]   Hit other key to close"
    },
    more = "(More)",
    no = "No..",
    no_gold = "(You don't have enough money!)",
    npc_list = {
      age_counter = function(_1)
  return ("(%s)")
  :format(_1)
end,
      gold_counter = function(_1)
  return ("%sgp")
  :format(_1)
end,
      info = "Info",
      init_cost = "Init. Cost(Wage)",
      name = "Name",
      title = "NPC List",
      wage = "Wage"
    },
    onii = {
      _0 = "brother",
      _1 = "sister"
    },
    platinum = " platinum pieces",
    playtime = function(_1, _2, _3)
  return ("%02d:%02d:%02d Sec")
  :format(_1, _2, _3)
end,
    politics = {
      global = "Global",
      law = "Law",
      law_of = function(_1)
  return ("Law of %s")
  :format(_1)
end,
      lawless = "Murder is allowed in this city.",
      name = function(_1)
  return ("The capital of this country is %s.")
  :format(_1)
end,
      taxes = function(_1)
  return ("The consumption tax in this city is %s%.")
  :format(_1)
end,
      well_pollution = function(_1)
  return ("The well is polluted. (%s people have died)")
  :format(_1)
end
    },
    quality = {
      _0 = "",
      _1 = "bad",
      _2 = "good",
      _3 = "great",
      _4 = "miracle",
      _5 = "godly",
      _6 = "special"
    },
    quick_menu = {
      action = "Action",
      ammo = "Ammo",
      bash = "Bash",
      chara = "Chara",
      dig = "Dig",
      etc = "Etc",
      fire = "Fire",
      help = "Help",
      info = "Info",
      interact = "Interact",
      journal = "Journal",
      log = "Log",
      pray = "Pray",
      rest = "Rest",
      skill = "Skill",
      spell = "Spell",
      wear = "Wear"
    },
    random_item = {
      potion = {
        _0 = "clear",
        _1 = "green",
        _2 = "blue",
        _3 = "gold",
        _4 = "brown",
        _5 = "red",
        name = "potion"
      },
      ring = {
        _0 = "iron",
        _1 = "green",
        _2 = "sapphire",
        _3 = "golden",
        _4 = "wooden",
        _5 = "rusty",
        name = "ring"
      },
      amulet = {
        name = "amulet"
      },
      staff = {
        _0 = "iron",
        _1 = "ivy",
        _2 = "sapphire",
        _3 = "golden",
        _4 = "wooden",
        _5 = "rusty",
        name = "rod"
      },
      scroll = {
        _0 = "blurred",
        _1 = "mossy",
        _2 = "ragged",
        _3 = "boring",
        _4 = "old",
        _5 = "bloody",
        name = "scroll"
      },
      spellbook = {
        _0 = "thick",
        _1 = "mossy",
        _2 = "clear",
        _3 = "luxurious",
        _4 = "old",
        _5 = "bloody",
        name = "spellbook"
      }
    },
    reserve = {
      name = "Name",
      not_reserved = "-",
      reserved = "Reserved",
      status = "Status",
      title = "Reserve List",
      unavailable = "Ah, that book is unavailable."
    },
    resistance = {
      _0 = "Critically Weak",
      _1 = "Weak",
      _2 = "No Resist",
      _3 = "Little",
      _4 = "Normal",
      _5 = "Strong",
      _6 = "Superb"
    },
    save = "*saving*",
    save_on_suspend = "App focus was lost. Quicksaving game.",
    scene = {
      has_been_played = "The scene has been played.",
      scene_no = "Scene No. ",
      which = "Which scene do you want to replay?",
      you_can_play = "You can play the unlocked scenes."
    },
    sex = {
      male = "Male",
      female = "Female"
    },
    sex2 = {
      male = "boy",
      female = "girl"
    },
    sex3 = {
      female = "female",
      male = "male"
    },
    skill = {
      cost = "Cost",
      detail = "Detail",
      name = "Name",
      title = "Skill"
    },
    spell = {
      effect = "Effect",
      lv_chance = "Lv/Chance",
      name = "Name",
      power = "Power:",
      cost_stock = "Cost(Stock)",
      title = "Spell",
      turn_counter = "t"
    },
    syujin = {
      _0 = "my master",
      _1 = "my lady"
    },
    time = {
      _0 = "Midnight",
      _1 = "Dawn",
      _2 = "Morning",
      _3 = "Noon",
      _4 = "Dusk",
      _5 = "Night",
      _6 = "",
      _7 = ""
    },
    town_chart = {
      chart = function(_1)
  return ("%s City Chart")
  :format(_1)
end,
      empty = "Empty",
      no_economy = "There's no economy running in this area.",
      title = "City Chart"
    },
    unit_of_weight = "s",
    weight = {
      _0 = "extremely mini",
      _1 = "small",
      _2 = "handy",
      _3 = "rather big",
      _4 = "huge",
      _5 = "pretty huge",
      _6 = "monstrous-size",
      _7 = "bigger than a man",
      _8 = "legendary-size",
      _9 = "heavier than an elephant"
    },
    yes = "Yes",

    now_loading = "Now Loading...",

    sense_quality = function(_1, _2)
       return (" (%s)[%s]"):format(capitalize(_1), capitalize(_2))
    end,

    key_hint = {
       key = {
          cursor = "Cursor",
          enter_key = "Enter key",
          left_right = "Right,left",
          shortcut = "0~9",
       },
       action = {
          back = "Back",
          change = "Change",
          switch_menu = "Change",
          close = "Close",
          help = "Help",
          known_info = "Known info",
          mode = "Mode",
          page = "Page",
          portrait = "Portrait",
          select = "Select",
          shortcut = "Shortcut",
          window = "Window"
       },
    },
    hint = {
       back = "Shift,Esc [Back]  ",
       close = "Shift,Esc [Close]  ",
       cursor = "Cursor [Select]  ",
       enter = "Enter,",
       help = " [Help]  ",
       known_info = " [Known info]  ",
       mode = " [Mode]  ",
       page = " [Page]  ",
       portrait = "p [Portrait]  ",
       shortcut = "0~9 [Shortcut]  "
    },
  }
}
