return {
  activity = {
    cancel = {
      item = function(_1)
  return ("%s cancel%s %s action.")
  :format(name(_1), s(_1), his(_1))
end,
      normal = function(_1, _2)
  return ("%s stop%s %s.")
  :format(name(_1), s(_1), _2)
end,
      prompt = function(_1)
  return ("Do you want to cancel %s? ")
  :format(_1)
end
    },
    construct = {
      finish = function(_1)
  return ("You finish constructing %s.")
  :format(itemname(_1, 1))
end,
      start = function(_1)
  return ("You start to construct %s.")
  :format(itemname(_1, 1))
end
    },
    dig = function(_1)
  return ("You start to pick %s.")
  :format(itemname(_1, 1))
end,
    dig_mining = {
      fail = "Your back hurts...You give up digging.",
      finish = {
        find = "You found something out of crushed heaps of rock.",
        wall = "You finished digging the wall."
      },
      start = {
        hard = "These walls look pretty hard!",
        spot = "You start to dig the mining spot.",
        wall = "You start to dig the wall."
      }
    },
    dig_spot = {
      finish = "You finish digging.",
      something_is_there = "*click* ...something is there!",
      sound = { "*clink*", "*smash*", "*thud*", "*sing*", "*sigh*" },
      start = {
        global = "You start to dig the ground.",
        other = "You start to dig the spot."
      }
    },
    eat = {
      finish = function(_1, _2)
  return ("%s %s finished eating %s.")
  :format(name(_1), have(_1), itemname(_2, 1))
end,
      start = {
        in_secret = function(_1, _2)
  return ("%s start%s to eat %s in secret.")
  :format(name(_1), s(_1), itemname(_2, 1))
end,
        mammoth = "Let's eatammoth.",
        normal = function(_1, _2)
  return ("%s start%s to eat %s.")
  :format(name(_1), s(_1), itemname(_2, 1))
end
      }
    },
    fishing = {
      fail = "A waste of a time...",
      get = function(_1)
  return ("You get %s!")
  :format(itemname(_1, 1))
end,
      start = "You start fishing."
    },
    guillotine = "Suddenly, the guillotine is activated.",
    harvest = {
      finish = function(_1, _2)
  return ("You harvest %s. (%s)")
  :format(itemname(_1, 1), _2)
end,
      sound = { "*sing*", "*pull*", "*thud*", "*rumble*", "*gasp*" }
    },
    iron_maiden = "Suddenly, the iron maiden falls forward.",
    material = {
      digging = {
        fails = "Your mining attempt fails.",
        no_more = "There's no more ore around."
      },
      fishing = {
        fails = "Your fishing attempt fails.",
        no_more = "The spring dries up."
      },
      get = function(_1, _2, _3)
  return ("You %s %s %s%s.")
  :format(_1, _2, _3, s(_2))
end,
      get_verb = {
        dig_up = "dig up",
        find = "find",
        fish_up = "fish up",
        get = "get",
        harvest = "harvest"
      },
      harvesting = {
        no_more = "There's no more plant around."
      },
      lose = function(_1, _2)
  return ("You lose %s %s%s.")
  :format(_1, _2, s(_1))
end,
      lose_total = function(_1)
  return ("(Total: %s) ")
  :format(_1)
end,
      searching = {
        fails = "Your searching attempt fails.",
        no_more = "You can't find anything anymore."
      },
      start = "You start to search the spot."
    },
    perform = {
      dialog = {
        angry = { "Boo boo!", "Shut it!", "What are you doing!", "You can't play shit." },
        disinterest = { "Boring.", "I've heard this before.", "This song again?" },
        interest = { function(_1)
  return ("%s clap%s.")
  :format(name(_1), s(_1))
end, function(_1, _2)
  return ("%s listen%s to %s%s music joyfully.")
  :format(name(_1), s(_1), name(_2), his_owned(_2))
end, "Bravo!", "Nice song.", "Scut!", function(_1)
  return ("%s %s excited!")
  :format(name(_1), is(_1))
end }
      },
      gets_angry = function(_1)
  return ("%s get%s angry.")
  :format(name(_1), s(_1))
end,
      quality = {
        _0 = "It is a waste of time.",
        _1 = "Almost everyone ignores you.",
        _2 = "You need to practice lot more.",
        _3 = "You finish your performance.",
        _4 = "Not good.",
        _5 = "People seem to like your performance.",
        _6 = "Your performance is successful.",
        _7 = "Wonderful!",
        _8 = "Great performance. Everyone cheers you.",
        _9 = "A Legendary stage!"
      },
      sound = {
        cha = "*Cha*",
        random = { "*Tiki*", "*Dan*", "*Lala*" }
      },
      start = function(_1, _2)
  return ("%s start%s to play %s.")
  :format(name(_1), s(_1), itemname(_2))
end,
      throws_rock = function(_1)
  return ("%s throw%s a rock.")
  :format(name(_1), s(_1))
end,
      tip = function(_1, _2)
  return ("The audience gives %s total of %s gold pieces.")
  :format(name(_1), _2)
end
    },
    pull_hatch = {
      finish = function(_1)
  return ("You finish pulling the hatch of %s.")
  :format(itemname(_1, 1))
end,
      start = "You start to pull the hatch."
    },
    read = {
      finish = function(_1)
  return ("%s %s finished reading the book.")
  :format(name(_1), have(_1))
end,
      start = function(_1, _2)
  return ("%s start%s to read %s.")
  :format(name(_1), s(_1), _2)
end
    },
    rest = {
      drop_off_to_sleep = "After a short while, you drop off to sleep.",
      finish = "You finished taking a rest.",
      start = "You lie down to rest."
    },
    sex = {
      after_dialog = { "You are awesome!", "Oh my god....", "Okay, okay, you win!", "Holy...!" },
      dialog = { "Yes!", "Ohhh", "*gasp*", "*rumble*", "come on!" },
      format = function(_1, _2)
  return ("\"%s %s\"")
  :format(_1, _2)
end,
      gets_furious = function(_1)
  return ("%s gets furious, \"And you think you can just run away?\"")
  :format(name(_1))
end,
      spare_life = function(_1)
  return ("\"I-I don't really know that %s. Please spare my life!\"")
  :format(_1)
end,
      take = "Here, take this.",
      take_all_i_have = "Take this money, it's all I have!",
      take_clothes_off = function(_1)
  return ("%s begin%s to take %s clothes off.")
  :format(name(_1), s(_1), his(_1))
end
    },
    sleep = {
      but_you_cannot = "But you can't sleep right now.",
      finish = "You fall asleep.",
      new_gene = {
        choices = {
          _0 = "Sweet."
        },
        text = function(_1)
  return ("You spent a night with %s. A new gene is created.")
  :format(name(_1))
end,
        title = "Gene"
      },
      slept_for = function(_1)
  return ("You have slept for %s hours. You are refreshed.")
  :format(_1)
end,
      start = {
        global = "You start to camp.",
        other = "You lie down."
      },
      wake_up = {
        good = function(_1)
  return ("You wake up feeling good. Your potential increases. (Total:%s%%)")
  :format(_1)
end,
        so_so = "You wake up feeling so so."
      }
    },
    steal = {
      abort = "You abort stealing.",
      cannot_be_stolen = "It can't be stolen.",
      guilt = "You feel the stings of conscience.",
      it_is_too_heavy = "It's too heavy.",
      notice = {
        dialog = {
          guard = "You there, stop!",
          other = "Guards! Guards!"
        },
        in_fov = function(_1)
  return ("%s notice%s you,")
  :format(name(_1), s(_1))
end,
        out_of_fov = function(_1)
  return ("%s hear%s loud noise,")
  :format(name(_1), s(_1))
end,
        you_are_found = "You are found stealing."
      },
      start = function(_1)
  return ("You target %s.")
  :format(itemname(_1, 1))
end,
      succeed = function(_1)
  return ("You successfully steal %s.")
  :format(itemname(_1))
end,
      target_is_dead = "The target is dead.",
      you_lose_the_target = "You lose the target."
    },
    study = {
      finish = {
        studying = function(_1)
  return ("You finish studying %s.")
  :format(_1)
end,
        training = "You finish training."
      },
      start = {
        bored = "You are bored.",
        studying = function(_1)
  return ("You begin to study %s.")
  :format(_1)
end,
        training = "You start training.",
        weather_is_bad = "The weather's bad outside, you have plenty of time to waste."
      }
    }
  }
}
