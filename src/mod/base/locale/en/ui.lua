return {
  ui = {
    action = {
      _0 = "current action",
      _1 = "eating",
      _10 = "current action",
      _11 = "current action",
      _12 = "current action",
      _13 = "current action",
      _2 = "reading",
      _3 = "moving",
      _4 = "resting",
      _5 = "mining",
      _6 = "playing",
      _7 = "fishing",
      _8 = "collecting materials",
      _9 = "searching"
    },
    adventurers = {
      fame_lv = "Fame(Lv)",
      hospital = "Hospital",
      location = "Location",
      name_and_rank = "Name and Rank",
      rank_counter = "",
      title = "Adventurer Rank",
      unknown = "Unknown"
    },
    alias = {
      list = "Alias List",
      reroll = "Reroll",
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
      hint = "Right,left [Change]  Shift,Esc [Close]"
    },
    article = function(_1)
  return ("[%s]")
  :format(_1)
end,
    assign_shortcut = function(_1)
  return ("You have assigned the shortcut to {%s} key.")
  :format(_1)
end,
    attribute = {
      _0 = " STR",
      _1 = " CON",
      _2 = " DEX",
      _3 = " PER",
      _4 = " LER",
      _5 = " WIL",
      _6 = " MAG",
      _7 = " CHR"
    },
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
      difficulty = "",
      difficulty_counter = function(_1)
  return (" x %s")
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
      _0 = " casts a spell.",
      _1 = " splits cobweb.",
      _2 = " spreads body fluid.",
      _3 = " puts out a tentacle.",
      _4 = " gazes.",
      _5 = " scatters spores.",
      _6 = " vibrates."
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
        hint = "Hint",
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
        age_counter = "",
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
        level = "Lv",
        name = "Name",
        potential = "Potential",
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
  :format(_1)
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
      category = "Category",
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
      name = "Name",
      resist = {
        _0 = "Fi",
        _1 = "Co",
        _10 = "Ma",
        _2 = "Li",
        _3 = "Da",
        _4 = "Mi",
        _5 = "Po",
        _6 = "Nt",
        _7 = "So",
        _8 = "Nr",
        _9 = "Ch"
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
      _10 = "heavenly",
      _11 = "godly",
      _2 = "lame",
      _3 = "cool",
      _4 = "madam's favorite",
      _5 = "bewitched",
      _6 = "maniac",
      _7 = "magnificent",
      _8 = "royal",
      _9 = "masterpiece"
    },
    gold = " gold pieces",
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
    home = {
      _0 = "cave",
      _1 = "shack",
      _2 = "cozy house",
      _3 = "estate",
      _4 = "cyber house",
      _5 = "small castle"
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
      _0 = "",
      _1 = "Examine",
      _10 = "Give",
      _11 = "Buy",
      _12 = "Sell",
      _13 = "Identify",
      _14 = "Use",
      _15 = "Open",
      _16 = "Cook",
      _17 = "Mix",
      _18 = "Mix Target",
      _19 = "Offer",
      _2 = "Drop",
      _20 = "Trade",
      _21 = "Present",
      _22 = "Take",
      _23 = "Target",
      _24 = "Put",
      _25 = "Take",
      _26 = "Throw",
      _27 = "Pickpocket",
      _28 = "Trade",
      _29 = "Reserve",
      _3 = "Pick Up",
      _4 = "",
      _5 = "Eat",
      _6 = "Wear",
      _7 = "Read",
      _8 = "Drink",
      _9 = "Zap"
    },
    journal = {
      income = {
        bills = {
          labor = function(_1)
  return ("@RE  Labor  : About %s GP")
  :format(_1)
end,
          maintenance = function(_1)
  return ("@RE  Maint. : About %s GP")
  :format(_1)
end,
          sum = function(_1)
  return ("@RE  Sum    : About %s GP")
  :format(_1)
end,
          tax = function(_1)
  return ("@RE  Tax    : About %s GP")
  :format(_1)
end,
          title = "Bills  (Issued every 1st day)",
          unpaid = function(_1)
  return ("You have %s unpaid bills.")
  :format(_1)
end
        },
        salary = {
          sum = function(_1)
  return ("@BL  Sum    : About %s GP")
  :format(_1)
end,
          title = "Salary (Paid every 1st and 15th day)"
        }
      },
      rank = {
        arena = function(_1, _2)
  return ("EX Arena Wins:%s  Highest Level:%s")
  :format(_1, _2)
end,
        deadline = function(_1)
  return ("\nDeadline: %s Days left")
  :format(_1)
end,
        fame = "Fame",
        pay = function(_1)
  return ("Pay: About %s gold pieces ")
  :format(_1)
end
      }
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
      name = "Name"
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
  return ("%s:%s:%s Sec")
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
      rod = {
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
    reward = {
      _0 = "",
      _1 = "equipment",
      _2 = "magical goods",
      _3 = "armor",
      _4 = "weapons",
      _5 = "ores",
      _6 = "furnitures"
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
      _0 = "Male",
      _1 = "Female"
    },
    sex2 = {
      _0 = "boy",
      _1 = "girl"
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
      cost = "Cost",
      effect = "Effect",
      lv_chance = "Lv/Chance",
      name = "Name",
      power = "Power:",
      stock = "Stock",
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
    weather = {
      _0 = "",
      _1 = "Etherwind",
      _2 = "Snow",
      _3 = "Rain",
      _4 = "Hard rain"
    },
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

    now_loading = "Now Loading..."
  }
}
