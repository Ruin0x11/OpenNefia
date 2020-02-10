return {
  magic = {
    absorb_magic = function(_1)
  return ("%s absorb%s mana from the air.")
  :format(name(_1), s(_1))
end,
    acid = {
      apply = function(_1)
  return ("The sulfuric acid melts %s.")
  :format(name(_1))
end,
      self = "Arrrrg!"
    },
    alchemy = function(_1)
  return ("It is metamorphosed into %s.")
  :format(itemname(_1, 1))
end,
    alcohol = {
      cursed = { "*Hic*", "Ah, bad booze.", "Ugh...", "Bah, smells like rotten milk." },
      normal = { "*Hic*", "Ah, good booze.", "La-la-la-la.", "I'm going to heaven.", "Whew!", "I'm revived!", "Awesome." }
    },
    arrow = {
      ally = function(_1)
  return ("The arrow hits %s.")
  :format(name(_1))
end,
      other = function(_1)
  return ("The arrow hits %s and")
  :format(name(_1))
end
    },
    ball = {
      ally = function(_1)
  return ("The Ball hits %s.")
  :format(name(_1))
end,
      other = function(_1)
  return ("The ball hits %s and")
  :format(name(_1))
end
    },
    bolt = {
      ally = function(_1)
  return ("The bolt hits %s.")
  :format(name(_1))
end,
      other = function(_1)
  return ("The bolt hits %s and")
  :format(name(_1))
end
    },
    breath = {
      ally = function(_1)
  return ("The breath hits %s.")
  :format(name(_1))
end,
      bellows = function(_1, _2)
  return ("%s bellow%s %s from %s mouth.")
  :format(name(_1), s(_1), _2, his(_1))
end,
      named = function(_1)
  return ("%s breath")
  :format(_1)
end,
      no_element = "breath",
      other = function(_1)
  return ("The breath hits %s and")
  :format(name(_1))
end
    },
    buff = {
      ends = function(_1)
  return ("The effect of %s ends.")
  :format(_1)
end,
      holy_veil_repels = "The holy veil repels the hex.",
      no_effect = "But it produces no effect.",
      resists = function(_1)
  return ("%s resist%s the hex.")
  :format(name(_1), s(_1))
end
    },
    change = {
      apply = function(_1)
  return ("%s change%s.")
  :format(name(_1), s(_1))
end,
      cannot_be_changed = function(_1)
  return ("%s cannot be changed.")
  :format(name(_1))
end
    },
    change_material = {
      apply = function(_1, _2, _3)
  return ("%s%s %s transforms into %s.")
  :format(name(_1), his_owned(_1), _2, itemname(_3, 1))
end,
      artifact_reconstructed = function(_1, _2)
  return ("%s%s %s is reconstructed.")
  :format(name(_1), his_owned(_1), itemname(_2, 1, false))
end,
      more_power_needed = "More magic power is needed to reconstruct an artifact."
    },
    cheer = {
      apply = function(_1)
  return ("%s cheer%s.")
  :format(name(_1), s(_1))
end,
      is_excited = function(_1)
  return ("%s %s excited!")
  :format(name(_1), is(_1))
end
    },
    common = {
      cursed = function(_1)
  return ("%s hear%s devils laugh.")
  :format(name(_1), s(_1))
end,
      it_is_cursed = "It's cursed!",
      melts_alien_children = function(_1)
  return ("%s%s alien children melt in %s stomach.")
  :format(name(_1), his_owned(_1), his(_1))
end,
      resists = function(_1)
  return ("%s resist%s.")
  :format(name(_1), s(_1))
end,
      too_exhausted = "You are too exhausted!"
    },
    confusion = function(_1)
  return ("A foul stench floods %s%s nostrils!")
  :format(name(_1), his_owned(_1))
end,
    cook = {
      do_not_know = "You don't know how to cook."
    },
    create = {
      door = {
        apply = "A door appears.",
        resist = "These walls seem to resist your magic."
      },
      wall = "A wall appears."
    },
    create_material = {
      apply = function(_1)
  return ("Some %s fall from above!")
  :format(_1)
end,
      junks = "junks",
      materials = "materials"
    },
    cure_corruption = {
      apply = "Your Ether Disease is cured greatly.",
      cursed = " The Ether Disease spreads around your body."
    },
    cure_mutation = "You are now one step closer to yourself.",
    curse = {
      apply = function(_1, _2)
  return ("%s%s %s glows black.")
  :format(name(_1), his_owned(_1), _2)
end,
      no_effect = "Your prayer nullifies the curse.",
      spell = function(_1, _2)
  return ("%s point%s %s and mutter%s a curse.")
  :format(name(_1), s(_1), name(_2), s(_1))
end
    },
    deed_of_inheritance = {
      can_now_inherit = function(_1)
  return ("You can now inherit %s items.")
  :format(_1)
end,
      claim = function(_1)
  return ("You claim the right of succession. (+%s)")
  :format(_1)
end
    },
    descent = function(_1)
  return ("%s lose%s a level...")
  :format(name(_1), s(_1))
end,
    diary = {
      cat_sister = "How...! You suddenly get a younger cat sister!",
      young_lady = "A young lady falls from the sky.",
      younger_sister = "How...! You suddenly get a younger sister!"
    },
    dirty_water = {
      other = "*quaff*",
      self = "*quaff* Yucky!"
    },
    disassembly = "Delete.",
    domination = {
      cannot_be_charmed = function(_1)
  return ("%s cannot be charmed.")
  :format(name(_1))
end,
      does_not_work_in_area = "The effect doesn't work in this area."
    },
    draw_charge = function(_1, _2, _3)
  return ("You destroy %s and extract %s recharge powers. (Total:%s)")
  :format(itemname(_1), _2, _3)
end,
    drop_mine = function(_1)
  return ("%s drop%s something on the ground.")
  :format(name(_1), s(_1))
end,
    enchant = {
      apply = function(_1)
  return ("%s %s surrounded by a golden aura.")
  :format(itemname(_1), is(_1))
end,
      resist = function(_1)
  return ("%s resist%s.")
  :format(itemname(_1), s(_1))
end
    },
    escape = {
      begin = "The air around you becomes charged.",
      cancel = "The air around you gradually loses power.",
      during_quest = "Returning while taking a quest is forbidden. Are you sure you want to return?",
      lord_may_disappear = "The lord of the dungeon might disappear if you escape now."
    },
    explosion = {
      ally = function(_1)
  return ("The explosion hits %s.")
  :format(name(_1))
end,
      begins = function(_1)
  return ("%s explode%s.")
  :format(name(_1), s(_1))
end,
      chain = function(_1)
  return ("%s explode%s.")
  :format(name(_1), s(_1))
end,
      other = function(_1)
  return ("The explosion hits %s and")
  :format(name(_1))
end
    },
    eye_of_ether = function(_1)
  return ("%s gazes at you. Your Ether Disease deteriorates.")
  :format(name(_1))
end,
    faith = {
      apply = function(_1)
  return ("You feel as if %s is watching you.")
  :format(_1)
end,
      blessed = "A three-leaved falls from the sky.",
      doubt = "Your god doubts your faith."
    },
    fill_charge = {
      apply = function(_1, _2)
  return ("%s %s recharged by %s.")
  :format(itemname(_1), is(_1), _2)
end,
      cannot_recharge = "You can't recharge this item.",
      cannot_recharge_anymore = function(_1)
  return ("%s cannot be recharged anymore.")
  :format(itemname(_1))
end,
      explodes = function(_1)
  return ("%s explode%s.")
  :format(itemname(_1), s(_1))
end,
      fail = function(_1)
  return ("You fail to recharge %s.")
  :format(itemname(_1))
end,
      more_power_needed = "You need at least 10 recharge powers to recharge items.",
      spend = function(_1)
  return ("You spend 10 recharge powers. (Total:%s)")
  :format(_1)
end
    },
    fish = {
      cannot_during_swim = "You can't fish while swimming.",
      do_not_know = "You don't know how to fish.",
      need_bait = "You need a bait to fish.",
      not_good_place = "This isn't a good place to fish."
    },
    flying = {
      apply = function(_1)
  return ("%s becomes light as a feather.")
  :format(itemname(_1, 1))
end,
      cursed = function(_1)
  return ("%s becomes heavy.")
  :format(itemname(_1, 1))
end
    },
    four_dimensional_pocket = "You summon 4 dimensional pocket.",
    gain_knowledge = {
      furthermore = "Furthermore, ",
      gain = function(_1)
  return ("you gain knowledge of a spell, %s.")
  :format(_1)
end,
      lose = function(_1)
  return ("Suddenly, you lose knowledge of a spell, %s.")
  :format(_1)
end,
      suddenly = "Suddenly, "
    },
    gain_potential = {
      blessed = function(_1)
  return ("%s%s potential of every attribute expands.")
  :format(name(_1), his_owned(_1))
end,
      decreases = function(_1, _2)
  return ("%s%s potential of %s decreases.")
  :format(name(_1), his_owned(_1), _2)
end,
      increases = function(_1, _2)
  return ("%s%s potential of %s expands.")
  :format(name(_1), his_owned(_1), _2)
end
    },
    gain_skill = function(_1, _2)
  return ("%s gain%s a skill of %s!")
  :format(name(_1), s(_1), _2)
end,
    gain_skill_potential = {
      decreases = function(_1, _2)
  return ("The potential of %s%s %s skill decreases.")
  :format(name(_1), his_owned(_1), _2)
end,
      furthermore_the = "Furthermore, the ",
      increases = function(_1, _2)
  return ("potential of %s%s %s skill increases.")
  :format(name(_1), his_owned(_1), _2)
end,
      the = "The "
    },
    garoks_hammer = {
      apply = function(_1)
  return ("It becomes %s.")
  :format(itemname(_1, 1))
end,
      no_effect = "This item leaves no room for improvement."
    },
    gaze = function(_1, _2)
  return ("%s gaze%s at %s.")
  :format(name(_1), s(_1), name(_2))
end,
    gravity = function(_1)
  return ("%s feel%s gravity.")
  :format(name(_1), s(_1))
end,
    harvest_mana = function(_1)
  return ("%s%s mana is restored.")
  :format(name(_1), his_owned(_1))
end,
    healed = {
      completely = function(_1)
  return ("%s %s completely healed.")
  :format(name(_1), is(_1))
end,
      greatly = function(_1)
  return ("%s %s greatly healed.")
  :format(name(_1), is(_1))
end,
      normal = function(_1)
  return ("%s %s healed.")
  :format(name(_1), is(_1))
end,
      slightly = function(_1)
  return ("%s %s slightly healed.")
  :format(name(_1), is(_1))
end
    },
    hunger = function(_1)
  return ("Suddenly %s feel%s hungry.")
  :format(name(_1), s(_1))
end,
    ink_attack = function(_1)
  return ("Ink squirts into %s%s face!")
  :format(name(_1), his_owned(_1))
end,
    insanity = { function(_1, _2)
  return ("%s see%s maggots breed in the rent stomach of %s.")
  :format(name(_2), s(_2), name(_1))
end, function(_1, _2)
  return ("%s see%s %s chow%s dead bodies.")
  :format(name(_2), s(_2), name(_1), s(_1))
end, function(_1, _2)
  return ("%s shudders%s at %s%s terrifying eyes.")
  :format(name(_2), s(_2), name(_1), his_owned(_1))
end, function(_1, _2)
  return ("%s feel%s sick at entrails caught in %s%s tentacles.")
  :format(name(_2), s(_2), name(_1), his_owned(_1))
end },
    insult = {
      apply = function(_1, _2)
  return ("%s insult%s %s.")
  :format(name(_1), s(_1), name(_2))
end
    },
    love_potion = {
      cursed = function(_1)
  return ("This love potion is cursed. %s look%s at %s with a contemptuous glance.")
  :format(name(_1), s(_1), you())
end,
      other = function(_1)
  return ("%s give%s %s the eye.")
  :format(name(_1), s(_1), you())
end,
      self = "You are excited!",
      spill = function(_1)
  return ("%s sense%s a sign of love,")
  :format(name(_1), s(_1))
end
    },
    map = {
      apply = "There's a mark on the map...",
      cursed = "The cursed map crumbles as you touch.",
      mark = "O",
      need_global_map = "You need to read it while you are in the global map."
    },
    map_effect = {
      acid = "Acid puddles are generated.",
      ether_mist = "Ether mist spreads.",
      fire = "Walls of fire come out from the ground.",
      fog = "The air is wrapped in a dense fog.",
      web = "The ground is covered with thick webbing."
    },
    meteor = "Innumerable meteorites fall all over the area!",
    mewmewmew = "Mewmewmew!",
    milk = {
      cursed = {
        other = "Argh, the milk is cursed!",
        self = "Geee it's cursed! The taste is very dangerous."
      },
      other = "Yummy!",
      self = "The taste is very thick, almost addictive."
    },
    mirror = "You examine yourself.",
    molotov = function(_1)
  return ("%s %s surrounded by flames.")
  :format(name(_1), is(_1))
end,
    mount = {
      currently_riding = function(_1, _2)
  return ("%s %s currently riding %s.")
  :format(name(_1), is(_1), name(_2))
end,
      dismount = function(_1)
  return ("You dismount from %s.")
  :format(name(_1))
end,
      dismount_dialog = { "Phew.", "How was my ride?", "Tired...tired...", "It was nice." },
      mount = {
        dialog = { "Awww.", "You should go on a diet.", "Let's roll!", "Be gentle." },
        execute = function(_1, _2)
  return ("You ride %s. (%s's speed: %s->")
  :format(name(_1), name(_1), _2)
end,
        suitable = "You feel comfortable.",
        unsuitable = "This creature is too weak to carry you."
      },
      no_place_to_get_off = "There's no place to get off.",
      not_client = "You can't ride a client.",
      only_ally = "You can only ride an ally.",
      ride_self = "You try to ride yourself.",
      stays_in_area = "The ally currently stays in this area."
    },
    mutation = {
      apply = "You mutate.",
      resist = "You resist the threat of mutation.",
      spell = function(_1, _2)
  return ("%s cast%s an insane glance on %s.")
  :format(name(_1), s(_1), name(_2))
end
    },
    name = {
      apply = function(_1)
  return ("It's now called %s.")
  :format(_1)
end,
      prompt = "What do you want to name this artifact?"
    },
    oracle = {
      cursed = "You hear a sepulchral whisper but the voice is too small to distinguish a word.",
      no_artifacts = "No artifacts have been generated yet.",
      was_created_at = function(_1, _2, _3, _4, _5)
  return ("%s was created at %s in %s/%s, %s. ")
  :format(_1, _2, _3, _4, _5)
end,
      was_held_by = function(_1, _2, _3, _4, _5, _6)
  return ("%s was held by %s at %s in %s/%s, %s. ")
  :format(_1, basename(_2), _3, _4, _5, _6)
end
    },
    paralysis = function(_1)
  return ("%s get%s numbness!")
  :format(name(_1), s(_1))
end,
    perform = {
      do_not_know = function(_1)
  return ("%s %sn't know how to play an instrument.")
  :format(name(_1), does(_1))
end
    },
    poison_attack = function(_1)
  return ("%s %s hit by poison!")
  :format(name(_1), is(_1))
end,
    prayer = function(_1)
  return ("A golden aura wraps %s!")
  :format(name(_1))
end,
    pregnant = function(_1, _2)
  return ("%s put%s something into %s%s body!")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end,
    rain_of_sanity = function(_1)
  return ("%s %s completely sane again.")
  :format(name(_1), is(_1))
end,
    restore = {
      body = {
        apply = function(_1)
  return ("%s%s body is restored.")
  :format(name(_1), his_owned(_1))
end,
        blessed = function(_1)
  return ("In addition, %s body is enchanted.")
  :format(his(_1))
end,
        cursed = function(_1)
  return ("%s%s body is damaged.")
  :format(name(_1), his_owned(_1))
end
      },
      mind = {
        apply = function(_1)
  return ("%s%s spirit is restored.")
  :format(name(_1), his_owned(_1))
end,
        blessed = function(_1)
  return ("In addition, %s spirit is enchanted.")
  :format(his(_1))
end,
        cursed = function(_1)
  return ("%s%s spirit is damaged.")
  :format(name(_1), his_owned(_1))
end
      }
    },
    restore_stamina = {
      apply = function(_1)
  return ("%s restore%s some stamina.")
  :format(name(_1), s(_1))
end,
      dialog = "*quaff* Juicy!"
    },
    restore_stamina_greater = {
      apply = function(_1)
  return ("%s greatly restore%s stamina.")
  :format(name(_1), s(_1))
end,
      dialog = "*quaff*"
    },
    resurrection = {
      apply = function(_1, _2)
  return ("%s %s been resurrected!")
  :format(_1, have(_2))
end,
      cursed = "Hoards of undead raise from the hell!",
      dialog = "Thanks!",
      fail = function(_1)
  return ("%s%s prayer doesn't reach the underworld.")
  :format(name(_1), his_owned(_1))
end
    },
    ["return"] = {
      cancel = "The air around you gradually loses power.",
      destination_changed = "The capricious controller of time has changed your destination!",
      door_opens = "A dimensional door opens in front of you.",
      prevented = {
        ally = "One of your allies prevents you from returning.",
        normal = "Strange power prevents you from returning.",
        overweight = "Someone shouts, Sorry, overweight."
      },
      you_commit_a_crime = "You commit a crime."
    },
    salt = {
      apply = "Salty!",
      snail = function(_1)
  return ("It's salt! %s start%s to melt.")
  :format(name(_1), s(_1))
end
    },
    scavenge = {
      apply = function(_1, _2)
  return ("%s loot%s %s%s backpack.")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end,
      eats = function(_1, _2)
  return ("%s eat%s %s!")
  :format(name(_1), s(_1), itemname(_2, 1))
end,
      rotten = function(_1, _2)
  return ("%s notice%s unusual odor from %s and step%s back.")
  :format(name(_1), s(_1), itemname(_2, 1), s(_1))
end
    },
    sense = {
      cursed = "Hmm? You suffer minor memory defect.",
      magic_mapping = function(_1)
  return ("%s sense%s nearby locations.")
  :format(name(_1), s(_1))
end,
      sense_object = function(_1)
  return ("%s sense%s nearby objects.")
  :format(name(_1), s(_1))
end
    },
    sleep = function(_1)
  return ("Strange sweet liquid splashes onto %s!")
  :format(name(_1))
end,
    slow = function(_1)
  return ("%s%s aging process slows down.")
  :format(name(_1), his_owned(_1))
end,
    special_attack = {
      other = function(_1, _2)
  return ("%s%s")
  :format(name(_1), _2)
end,
      self = function(_1, _2)
  return ("%s cast %s.")
  :format(name(_1), _2)
end
    },
    speed = function(_1)
  return ("%s%s aging process speeds up.")
  :format(name(_1), his_owned(_1))
end,
    steal = {
      in_quest = "You have no time for it!"
    },
    sucks_blood = {
      ally = function(_1, _2)
  return ("%s suck%s %s%s blood.")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end,
      other = function(_1, _2)
  return ("%s suck%s %s%s blood and")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end
    },
    summon = "Several monsters come out from a portal.",
    swarm = "Swarm!",
    teleport = {
      disappears = function(_1)
  return ("Suddenly, %s disappear%s.")
  :format(name(_1), s(_1))
end,
      draw_shadow = function(_1)
  return ("%s %s drawn.")
  :format(name(_1), is(_1))
end,
      prevented = "Magical field prevents teleportation.",
      shadow_step = function(_1, _2)
  return ("%s teleport%s toward %s.")
  :format(name(_1), s(_1), basename(_2))
end,
      suspicious_hand = {
        after = "A thief escapes laughing.",
        prevented = function(_1)
  return ("%s guard%s %s wallet from a thief.")
  :format(name(_1), s(_1), his(_1))
end,
        succeeded = function(_1, _2, _3)
  return ("%s steal%s %s gold pieces from %s.")
  :format(name(_1), s(_1), _3, name(_2))
end
      }
    },
    touch = {
      ally = function(_1, _2, _3, _4)
  return ("%s touch%s %s with %s %s %s.")
  :format(name(_1), s(_1, true), name(_2), his(_1), _3, _4)
end,
      other = function(_1, _2, _3, _4)
  return ("%s touch%s %s with %s %s %s and")
  :format(name(_1), s(_1, true), name(_2), his(_1), _3, _4)
end
    },
    troll_blood = {
      apply = function(_1)
  return ("%s%s blood burns and a new strength fills %s body!")
  :format(name(_1), his_owned(_1), his(_1))
end,
      blessed = "It really burns!"
    },
    uncurse = {
      apply = function(_1)
  return ("%s %s equipment are surrounded by a white aura.")
  :format(name(_1), his_owned(_1))
end,
      blessed = function(_1)
  return ("%s %s surrounded by a holy aura.")
  :format(name(_1), is(_1))
end,
      equipment = function(_1)
  return ("The aura uncurses some of %s equipment.")
  :format(his(_1))
end,
      item = function(_1)
  return ("The aura uncurses some %s stuff.")
  :format(his(_1))
end,
      resist = "Several items resist the aura and remain cursed."
    },
    vanish = function(_1)
  return ("%s vanish%s.")
  :format(name(_1), s(_1, true))
end,
    vorpal = {
      ally = function(_1, _2)
  return ("%s cut%s %s%s head.")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end,
      other = function(_1, _2)
  return ("%s cut%s %s%s head and")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end,
      sound = "*Gash*"
    },
    water = {
      other = "*quaff*",
      self = "*quaff* The water is refreshing."
    },
    weaken = function(_1)
  return ("%s %s weakened.")
  :format(name(_1), is(_1))
end,
    weaken_resistance = {
      nothing_happens = "Nothing happens."
    },
    wizards_harvest = function(_1)
  return ("%s fall%s down!")
  :format(itemname(_1), s(_1))
end
  }
}
