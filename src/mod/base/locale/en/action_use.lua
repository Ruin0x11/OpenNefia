return {
  action = {
    use = {
      chair = {
        choices = {
          free_chair = "It's free to use.",
          guest_chair = "It's for my guest.",
          my_chair = "It's my chair.",
          relax = "Relax."
        },
        free_chair = function(_1)
  return ("%s can be used by anyone.")
  :format(itemname(_1, 1))
end,
        guest_chair = function(_1)
  return ("%s is used by your guests now.")
  :format(itemname(_1, 1))
end,
        my_chair = function(_1)
  return ("%s is your seat now.")
  :format(itemname(_1, 1))
end,
        needs_place_on_ground = "You need to put it on the ground.",
        relax = "You relax as much as you like.",
        you_sit_on = function(_1)
  return ("You sit on %s.")
  :format(itemname(_1, 1))
end
      },
      deck = {
        add_card = function(_1)
  return ("You add %s to your deck.")
  :format(itemname(_1, 1))
end,
        no_deck = "You don't have a deck.",
        put_away = "You put away the deck."
      },
      dresser = {
        prompt = "Make up who?"
      },
      gem_stone = {
        kumiromi = {
          already_grown = "The plant has already grown full.",
          grows = "The plant grows.",
          no_plant = "You don't see any plant on the ground.",
          revives = "The plant revives."
        }
      },
      gene_machine = {
        choose_original = "Choose an original body.",
        choose_subject = "Choose a gene. Once you extract a gene, the subject will be lost forever.",
        gains = {
          ability = function(_1, _2)
  return ("%s learns%s skill!")
  :format(basename(_1), _2)
end,
          body_part = function(_1, _2)
  return ("%s gains new %s!")
  :format(basename(_1), _2)
end,
          level = function(_1, _2)
  return ("%s is now level %s!")
  :format(basename(_1), _2)
end
        },
        has_inherited = function(_1, _2)
  return ("%s has inherited %s's gene!")
  :format(basename(_1), basename(_2))
end,
        precious_ally = function(_1)
  return ("%s is your precious ally. You need to unwatch %s health to extract %s gene.")
  :format(name(_1), his(_1), his(_1))
end,
        prompt = function(_1, _2)
  return ("Really add %s's gene to %s?")
  :format(basename(_1), basename(_2))
end
      },
      guillotine = {
        someone_activates = "Suddenly, someone activates the guillotine.",
        use = "You set your head on the guillotine."
      },
      hammer = {
        use = function(_1)
  return ("You swing %s.")
  :format(itemname(_1, 1))
end
      },
      house_board = {
        cannot_use_it_here = "You can't use it here."
      },
      iron_maiden = {
        grin = "*Grin*",
        interesting = "Interesting!",
        someone_activates = "Suddenly, someone closes the door.",
        use = "You enter the iron maiden."
      },
      leash = {
        other = {
          start = {
            dialog = function(_1)
  return ("%s gasp%s, \"Pervert!\"")
  :format(name(_1), s(_1))
end,
            resists = function(_1)
  return ("The leash is cut as %s resists.")
  :format(name(_1))
end,
            text = function(_1)
  return ("You leash %s.")
  :format(name(_1))
end
          },
          stop = {
            dialog = function(_1)
  return ("%s gasp%s, \"D-don't sto....N-nothing!\"")
  :format(name(_1), s(_1))
end,
            text = function(_1)
  return ("You unleash %s.")
  :format(name(_1))
end
          }
        },
        prompt = "Leash who?",
        self = "You leash yourself..."
      },
      living = {
        becoming_a_threat = "Its power is becoming a threat.",
        bonus = "Bonus+1",
        displeased = function(_1)
  return ("%s vibrates as if she is displeased.")
  :format(itemname(_1))
end,
        it = "It...",
        needs_more_blood = "The weapon needs more blood.",
        pleased = function(_1)
  return ("%s vibrates as if she is pleased.")
  :format(itemname(_1))
end,
        ready_to_grow = function(_1)
  return ("%s sucked enough blood and ready to grow!")
  :format(itemname(_1))
end,
        removes_enchantment = function(_1)
  return ("%s removes an enchantment.")
  :format(itemname(_1))
end,
        weird = "But you sense something weird."
      },
      mine = {
        cannot_place_here = "You can't place it here.",
        cannot_use_here = "You can't place it here.",
        you_set_up = "You set up the mine."
      },
      money_box = {
        full = "The money box is full.",
        not_enough_gold = "You count your coins and sigh..."
      },
      monster_ball = {
        empty = "This ball is empty.",
        party_is_full = "Your party is full.",
        use = function(_1)
  return ("You activate %s.")
  :format(itemname(_1, 1))
end
      },
      music_disc = {
        play = function(_1)
  return ("You play %s.")
  :format(itemname(_1, 1))
end
      },
      not_sleepy = "You don't feel sleepy yet.",
      nuke = {
        cannot_place_here = "You can't place it here.",
        not_quest_goal = "This location is not your quest goal. Really place it here?",
        set_up = "You set up the nuke...now run!!",
        countdown = function(_1) return ("*%s*"):format(_1) end
      },
      out_of_charge = "It's out of charge.",
      rope = {
        prompt = "Really hang yourself?"
      },
      rune = {
        only_in_town = "You can only use it in a town.",
        use = "Suddenly, a strange gate opens."
      },
      sandbag = {
        ally = "Hanging your ally is a brutal idea!",
        already = "It's already hanged up.",
        cannot_use_here = "You cant use it in this area.",
        not_weak_enough = "The target needs to be weakened.",
        prompt = "Hang who?",
        self = "You try to hang yourself but rethink...",
        start = function(_1)
  return ("You hang up %s.")
  :format(name(_1))
end
      },
      secret_experience = {
        kumiromi = {
          not_enough_exp = "Kumiromi talks to you, No...you aren't...experienced enough...for this...",
          use = {
            dialog = "...You have acquired enough...experience...I shall reward you...",
            text = "Kumiromi blesses you. You can obtain one more feat now!"
          }
        },
        lomias = "You have a bad feeling about this..."
      },
      secret_treasure = {
        use = "You gain a new feat."
      },
      shelter = {
        cannot_build_it_here = "You can't build it here.",
        during_quest = "Really give up the quest and evacuate to the shelter?",
        only_in_world_map = "You can only build it in the world map."
      },
      snow = {
        make_snowman = function(_1)
  return ("%s make%s a snow man!")
  :format(name(_1), s(_1))
end,
        need_more = "You need more snow."
      },
      statue = {
        activate = function(_1)
  return ("You activate %s.")
  :format(itemname(_1, 1))
end,
        creator = {
          in_usermap = "Watching this strange statue makes you want to throw something at it!",
          normal = "It looks so dumb here."
        },
        ehekatl = "A voice echoes, Did you call me? Call me?",
        jure = "A voice echoes, I-I'm not doing for you! Silly!",
        lulwy = {
          during_etherwind = "A rather angry voice echoes, Listen my little slave. Did you really think I would turn a hand in this filthy wind for you?",
          normal = "An impish voice echoes, Ah you ask too much for a mortal. Still, it is hard to refuse a call from such a pretty slave like you."
        },
        opatos = "A voice echoes, Muwahahaha! I shall shake the land for you!"
      },
      stethoscope = {
        other = {
          start = {
            female = {
              dialog = "Pervert!",
              text = function(_1)
  return ("%s blush%s.")
  :format(name(_1), s(_1, true))
end
            },
            text = function(_1)
  return ("You no longer watch on %s health.")
  :format(his(_1))
end
          },
          stop = function(_1)
  return ("You start to keep an eye on %s health.")
  :format(his(_1))
end
        },
        prompt = "Auscultate who?",
        self = "You blush."
      },
      summoning_crystal = {
        use = "It glows dully."
      },
      torch = {
        light = "You light up the torch.",
        put_out = "You put out the fire."
      },
      unicorn_horn = {
        use = function(_1)
  return ("You hold %s up high.")
  :format(itemname(_1, 1))
end
      },
      useable_again_at = function(_1)
  return ("This item will be useable again at %s.")
  :format(_1)
end,
      whistle = {
        use = "*Peeeeeeeeeep* "
      }
    }
  }
}
