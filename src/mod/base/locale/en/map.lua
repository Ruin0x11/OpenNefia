return {
  map = {
    loading_failed = "Map loading failed.",
    location_changed = function(_1, _2, _3, _4, _5)
  return ("The location of %s has been changed from x%s:y%s to x%s:y%s.")
  :format(_1, _2, _3, _4, _5)
end,
    misc_location = {
      _1 = "Mine",
      _2 = "Crop",
      _3 = "Art Atelier",
      _4 = "Temple",
      _5 = "Smuggler's Hideout",
      _6 = "Light House"
    },
    nefia = {
      level = "",
      prefix = {
        type_a = {
          _0 = "Beginner's ",
          _1 = "Adventurer's ",
          _2 = "Dangerous ",
          _3 = "Fearful ",
          _4 = "King's "
        },
        type_b = {
          _0 = "Safe ",
          _1 = "Exciting ",
          _2 = "Servant's ",
          _3 = "Shadow ",
          _4 = "Chaotic "
        }
      },
      suffix = {
        _20 = "Dungeon",
        _21 = "Tower",
        _22 = "Forest",
        _23 = "Fort"
      }
    },
    no_dungeon_master = "This place is pretty dull. The dungeon master is no longer sighted here.",
    prompt_initialize = "Initialize this map? (Warning, only do this if an error occurs when loading this map. Make sure make a backup of the current save folder before doing this.)",
    quest = {
      field = "Field nearby town",
      on_enter = {
        conquer = function(_1, _2)
  return ("You have to slay %s within %s minites.")
  :format(_1, _2)
end,
        harvest = function(_1, _2)
  return ("To complete the quest, you have to harvest %s worth farm products and put them into the delivery chest within %s minutes.")
  :format(_1, _2)
end,
        party = function(_1, _2)
  return ("You have to warm up the party within %s minites. Your target score is %s points.")
  :format(_1, _2)
end
      },
      outskirts = "The outskirts",
      party_room = "Party Room",
      urban_area = "Urban area"
    },
    since_leaving = {
      time_passed = function(_1, _2, _3)
  return ("%s day%s and %s hour%s have passed since you left %s.")
  :format(_1, s(_1), _2, s(_2), _3)
end,
      walked = {
        you = function(_1)
  return ("You've walked about %s miles and have gained experience.")
  :format(_1)
end,
        you_and_allies = function(_1)
  return ("You and your allies have walked about %s miles and have gained experience.")
  :format(_1)
end
      }
    },
    unique = {
      _10 = {
        desc = "You see the graveyard of Lumiest. It's silent. Very silent.",
        name = "the graveyard"
      },
      _101 = {
        name = "My Museum"
      },
      _102 = {
        name = "Shop"
      },
      _103 = {
        name = "Crop"
      },
      _104 = {
        name = "Storage House"
      },
      _11 = {
        desc = "You see Port Kapul. The port is crowded with merchants.",
        name = "Port Kapul"
      },
      _12 = {
        desc = "You see a small town, Yowyn. You remember fondly the smell of the soil.",
        name = "Yowyn"
      },
      _14 = {
        desc = "You see the infamous rogue's den Derphy.",
        name = "Derphy"
      },
      _15 = {
        desc = "You see the great city of Palmia. Entire city is surrounded by tall wall.",
        name = "Palmia"
      },
      _16 = {
        name = "the Tower of Fire"
      },
      _17 = {
        name = "the crypt of the damned"
      },
      _18 = {
        name = "the Ancient Castle"
      },
      _19 = {
        name = "the Dragon's Nest"
      },
      _2 = {
        desert = "Desert",
        forest = "Forest",
        grassland = "Grassland",
        name = "Wilderness",
        plain_field = "Plain Field",
        sea = "Sea",
        snow_field = "Snow Field"
      },
      _20 = {
        desc = "You see old shrines. Sacred air surrounds the ground.",
        name = "the Truce Ground"
      },
      _21 = {
        desc = "You see a very strange building.",
        name = "Cyber Dome"
      },
      _22 = {
        desc = "You see an unearthly fort. Your inner voice warns you to not go there. (Approximate danger level: 666) ",
        name = "Fort of Chaos <Beast>"
      },
      _23 = {
        desc = "You see an unearthly fort. Your inner voice warns you to not go there. (Approximate danger level: 666) ",
        name = "Fort of Chaos <Machine>"
      },
      _24 = {
        desc = "You see an unearthly fort. Your inner voice warns you to not go there. (Approximate danger level: 666) ",
        name = "Fort of Chaos <Collapsed>"
      },
      _25 = {
        name = "Larna"
      },
      _26 = {
        name = "the Mountain Pass"
      },
      _27 = {
        name = "the Puppy Cave"
      },
      _28 = {
        name = "the Yeek's Nest"
      },
      _29 = {
        name = "the mansion of younger sister"
      },
      _3 = {
        desc = "You see the dungeon of Lesimas. The wheel of fortune starts to turn.",
        name = "Lesimas",
        the_depth = "The Depth"
      },
      _30 = {
        name = "Shelter"
      },
      _31 = {
        name = "Ranch"
      },
      _32 = {
        name = "the Embassy"
      },
      _33 = {
        desc = "You see Noyel. The laughters of children travel from the playground.",
        name = "Noyel"
      },
      _34 = {
        name = "Miral and Garok's Workshop"
      },
      _35 = {
        name = "Show House"
      },
      _36 = {
        desc = "You see Lumiest. Murmuring of water pleasantly echoes.",
        name = "Lumiest"
      },
      _37 = {
        name = "the Pyramid"
      },
      _38 = {
        name = "the Minotaur's Nest"
      },
      _39 = {
        desc = "It's your dungeon.",
        name = "Your Dungeon"
      },
      _4 = {
        name = "North Tyris"
      },
      _40 = {
        name = "Pet Arena"
      },
      _41 = {
        desc = "You see a prison. The entrance is strictly closed.",
        name = "Jail"
      },
      _42 = {
        desc = "What is this place?",
        name = "the Void"
      },
      _43 = {
        name = "North Tyris south border"
      },
      _44 = {
        name = "South Tyris"
      },
      _45 = {
        name = "South Tyris north border"
      },
      _46 = {
        name = "The smoke and pipe"
      },
      _47 = {
        name = "Test World"
      },
      _48 = {
        name = "Test World north border"
      },
      _499 = {
        name = "Debug Map"
      },
      _5 = {
        desc = "You see Vernis. The mining town is full of liveliness.",
        name = "Vernis"
      },
      _6 = {
        name = "Arena"
      },
      _7 = {
        desc = "It's your sweet home.",
        name = "Your Home"
      },
      _9 = {
        name = "Test Ground"
      },
      battle_field = {
        name = "Battle Field"
      },
      cat_mansion = {
        name = "Cat Mansion"
      },
      doom_ground = {
        name = "Doom Ground"
      },
      fighters_guild = {
        name = "Fighters Guild"
      },
      mages_guild = {
        name = "Mages Guild"
      },
      robbers_hideout = {
        name = "Robber's Hideout"
      },
      test_site = {
        name = "Test Site"
      },
      the_mine = {
        name = "The Mine"
      },
      the_sewer = {
        name = "The Sewer"
      },
      thieves_guild = {
        name = "Thieves Guild"
      }
    },
    you_see = function(_1)
  return ("You see %s.")
  :format(_1)
end,
    you_see_an_entrance = function(_1, _2)
  return ("You see an entrance leading to %s.(Approximate danger level: %s) ")
  :format(_1, _2)
end
  }
}