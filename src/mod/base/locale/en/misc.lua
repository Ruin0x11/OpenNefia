return {
  misc = {
    ["and"] = " and ",
    artifact_regeneration = function(_1, _2)
  return ("%s turns its shape into %s.")
  :format(_1, itemname(_2))
end,
    black_cat_licks = function(_1, _2)
  return ("%s licks %s.")
  :format(name(_1), itemname(_2))
end,
    caught_by_assassins = "You are caught by assassins. You have to protect your client.",
    corpse_is_dried_up = function(_1)
  return ("%s %s dried up in the sun.")
  :format(itemname(_1), is(_1))
end,
    curse = {
      blood_sucked = function(_1)
  return ("Something sucks %s%s blood.")
  :format(name(_1), his_owned(_1))
end,
      creature_summoned = "Several creatures are summoned from a vortex of magic.",
      experience_reduced = function(_1)
  return ("%s become%s inexperienced.")
  :format(name(_1), s(_1))
end,
      gold_stolen = function(_1)
  return ("A malicious hand filches some gold pieces from %s%s wallet.")
  :format(name(_1), his_owned(_1))
end
    },
    custom = {
      do_you_want_to_delete = function(_1)
  return ("Do you really want to delete %s? ")
  :format(_1)
end,
      fail_to_retrieve_file = "Failed to retrieve designated files.",
      incompatible = "Selected item is incompatible.",
      key_hint = "BackSpace [Delete]  ",
      pet_team = {
        list = "Team List",
        name = "Name",
        which_team = "Which team do you want to play a match? "
      },
      show_room = {
        list = "Room List",
        name = "Name",
        which_show_room = "Which room do you want to visit? "
      }
    },
    death = {
      crawl_up = "Crawl up",
      date = function(_1, _2, _3)
  return ("%s/%s/%s")
  :format(_1, _2, _3)
end,
      dying_message = function(_1)
  return ("\"%s\"")
  :format(_1)
end,
      good_bye = "Good bye... ",
      lie_on_your_back = "Lie on your back",
      rank = function(_1)
  return ("%s")
  :format(ordinal(_1))
end,
      you_are_about_to_be_buried = "You are about to be buried...",
      you_died = function(_1, _2)
  return ("%s in %s.")
  :format(capitalize(_1), _2)
end,
      you_have_been_buried = "You have been buried. Bye...(Hit any key to exit)",
      you_leave_dying_message = "You leave a dying message."
    },
    dungeon_level = " Lv",
    extract_seed = function(_1)
  return ("You extract plant seeds from %s.")
  :format(itemname(_1))
end,
    fail_to_cast = {
      creatures_are_summoned = "Several creatures are summoned from a vortex of magic.",
      dimension_door_opens = function(_1)
  return ("A dimension door opens in front of %s.")
  :format(name(_1))
end,
      is_confused_more = function(_1)
  return ("%s %s confused more.")
  :format(name(_1), is(_1))
end,
      mana_is_absorbed = function(_1)
  return ("%s mana is absorbed.")
  :format(name(_1), his_owned(_1))
end,
      too_difficult = "It's too difficult!"
    },
    finished_eating = function(_1, _2)
  return ("%s %s finished eating %s.")
  :format(name(_1), have(_1), itemname(_2, 1))
end,
    get_rotten = function(_1)
  return ("%s rot%s.")
  :format(itemname(_1), s(_1))
end,
    hostile_action = {
      get_excited = "Animals get excited!",
      gets_furious = function(_1)
  return ("%s gets furious!")
  :format(name(_1))
end,
      glares_at_you = function(_1)
  return ("%s glares at you.")
  :format(name(_1))
end
    },
    identify = {
      almost_identified = function(_1, _2)
  return ("You sense the quality of %s is %s.")
  :format(itemname(_1), _2)
end,
      fully_identified = function(_1, _2)
  return ("You appraise %s as %s.")
  :format(_1, itemname(_2))
end
    },
    income = {
      sent_to_your_house = function(_1)
  return ("As a salary, %s gold piece%s have been sent to your house.")
  :format(_1, s(_1))
end,
      sent_to_your_house2 = function(_1, _2)
  return ("As a salary, %s gold piece%s and %s item%s have been sent to your house.")
  :format(_1, s(_1), _2, s(_2))
end
    },
    living_weapon_taste_blood = function(_1)
  return ("%s has tasted enough blood!")
  :format(itemname(_1))
end,
    love_miracle = {
      uh = "Uh...!"
    },
    map = {
      jail = {
        guard_approaches = "You hear footsteps coming towards your cell.",
        leave_here = "Hey punk, our boss says you can leave the jail now. Do not come back, okay?",
        repent_of_sin = "You repent of your sin.",
        unlocks_your_cell = "A guard unenthusiastically unlocks your cell."
      },
      museum = {
        chats = { "*noise*", "Hmm. Not bad.", "What's this?", "Ohh...", "I want to be stuffed...", "So this is the famous..." },
        chats2 = { "*murmur*", "Gross! Disgusting.", "Hey. Is it really dead?", "Scut!", "Absolutely amazing.", "Can I touch?" }
      },
      shelter = {
        eat_stored_food = "You eat stored food.",
        no_longer_need_to_stay = "You don't need to stay in the shelter any longer."
      },
      shop = {
        chats = { "*murmur*", "I want this! I want this!", "Oh what's this?", "I'm just watching", "My wallet is empty...", "So this is the famous...." }
      }
    },
    no_target_around = "You look around and find nothing.",
    pregnant = {
      gets_pregnant = function(_1)
  return ("%s get%s pregnant.")
  :format(name(_1), s(_1))
end,
      pats_stomach = function(_1)
  return ("%s pat%s %s stomach uneasily.")
  :format(name(_1), s(_1), his(_1))
end,
      pukes_out = function(_1)
  return ("But %s puke%s it out quickly.")
  :format(he(_1), s(_1))
end,
      something_breaks_out = function(_1)
  return ("Something splits %s%s body and breaks out!")
  :format(name(_1), his_owned(_1))
end,
      something_is_wrong = { "I'm going to have a baby!", "Something is wrong with my stomach..." }
    },
    quest = {
      kamikaze_attack = {
        message = "The messenger The retreat of our army is over now. You don't need to fight them any more. Please leave at once!",
        stairs_appear = "Suddenly, stairs appear."
      }
    },
    ranking = {
      changed = function(_1, _2, _3, _4)
  return ("Ranking Change (%s %s -> %s) <%s>")
  :format(_1, _2, _3, _4)
end,
      closer_to_next_rank = "You are one step closer to the next rank."
    },
    resurrect = function(_1, _2)
  return ("%s %s been resurrected!")
  :format(capitalize(_1), have(_2))
end,
    ["return"] = {
      air_becomes_charged = "The air around you becomes charged.",
      forbidden = "Returning while taking a quest is forbidden. Are you sure you want to return?",
      lord_of_dungeon_might_disappear = "The lord of the dungeon might disappear if you escape now.",
      no_location = "You don't know any location you can return to",
      where_do_you_want_to_go = "Where do you want to go?"
    },
    save = {
      cannot_save_in_user_map = "The game is not saved in a user map.",
      need_to_save_in_town = "To update your game, please save your game in a town in the previous version then retry.",
      take_a_while = "The next updating process may take a while to complete.",
      update = function(_1)
  return ("Updating your save data from Ver.%s now.")
  :format(_1)
end
    },
    score = {
      rank = function(_1)
  return ("%s")
  :format(ordinal(_1))
end,
      score = function(_1)
  return ("%s")
  :format(_1)
end
    },
    shakes_head = function(_1)
  return ("%s shake%s %s head.")
  :format(name(_1), s(_1), his(_1))
end,
    sound = {
      can_no_longer_stand = "That's it.",
      get_anger = function(_1)
  return ("%s can no longer put up with it.")
  :format(name(_1))
end,
      waken = function(_1)
  return ("%s notice%s the sound and wake%s up.")
  :format(name(_1), _s(_1), _s(_1))
end
    },
    spell_passes_through = function(_1)
  return ("The spell passes through %s.")
  :format(name(_1))
end,
    status_ailment = {
      breaks_away_from_gravity = function(_1)
  return ("%s break%s away from gravity.")
  :format(name(_1), s(_1))
end,
      calms_down = function(_1)
  return ("%s calm%s down.")
  :format(name(_1), s(_1))
end,
      choked = "Ughh...!",
      insane = { function(_1)
  return ("%s start%s to take %s cloths off.")
  :format(name(_1), s(_1), his(_1))
end, function(_1)
  return ("%s shout%s.")
  :format(name(_1), s(_1))
end, function(_1)
  return ("%s dance%s.")
  :format(name(_1), s(_1))
end, "Weeeeeee!", "Forgive me! Forgive me!", "P-P-Pika!", "Shhhhhh!", "So I have to kill.", "You snail!" },
      sleepy = "You need to sleep."
    },
    tax = {
      accused = function(_1)
  return ("You have been accused for being in arrears with your tax for%s months.")
  :format(_1)
end,
      bill = "A bill has been sent to your house.",
      caution = "Caution! ",
      have_to_go_embassy = "You have to go to the Embassy of Palmia and pay tax at once. ",
      left_bills = function(_1)
  return ("You are in arrears with your tax for %s month%s.")
  :format(_1, s(_1))
end,
      lose_fame = function(_1)
  return ("You lose %s fame.")
  :format(_1)
end,
      no_duty = "You don't have to pay tax until you hit level 6.",
      warning = "Warning!! "
    },
    walk_down_stairs = "You walk down the stairs. ",
    walk_up_stairs = "You walk up the stairs. ",
    wet = {
      gets_wet = function(_1)
  return ("%s get%s wet.")
  :format(name(_1), s(_1))
end,
      is_revealed = function(_1)
  return ("%s %s revealed %s shape.")
  :format(name(_1), is(_1), his(_1))
end
    },
    wields_proudly = {
      the = "The "
    }
  }
}
