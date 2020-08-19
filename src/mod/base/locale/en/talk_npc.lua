return {
  talk = {
    ignores_you = function(_1)
  return ("(%s ignores you...)")
  :format(he(_1))
end,
    is_busy = function(_1)
  return ("%s is in the middle of something.")
  :format(name(_1))
end,
    is_sleeping = function(_1)
  return ("%s is sleeping.")
  :format(name(_1))
end,
    npc = {
      adventurer = {
        choices = {
          hire = "I want to hire you.",
          join = "Join me!"
        },
        hire = {
          choices = {
            go_back = "Some other time.",
            pay = "Sounds fair enough."
          },
          cost = function(_1)
  return ("I will take the job for %s gold pieces, for seven day.")
  :format(_1)
end,
          you_hired = function(_1)
  return ("You hired %s.")
  :format(name(_1))
end
        },
        join = {
          accept = "Sure, I guess you and I can make a good team.",
          not_known = "Huh? What made you think I'd want to join you? I don't even know you well.",
          party_full = "It seems your party is already full. Come see me again when you're ready.",
          too_weak = "Huh? You are no match for me."
        }
      },
      ally = {
        abandon = {
          choices = {
            no = "No.",
            yes = "Yes."
          },
          prompt = function(_1)
  return ("(%s looks at you sadly. Really abandon %s?)")
  :format(name(_1), him(_1))
end,
          you_abandoned = function(_1)
  return ("You abandoned %s...")
  :format(name(_1))
end
        },
        choices = {
          abandon = "I'm going to abandon you.",
          ask_for_marriage = "May I ask for your hand?",
          make_gene = "Let's make a gene.",
          silence = {
            start = "Shut up.",
            stop = "You can speak now."
          },
          wait_at_town = "Wait at the town."
        },
        make_gene = {
          accepts = "*blush*",
          refuses = "Not here!"
        },
        marriage = {
          accepts = "With preasure.",
          refuses = function(_1)
  return ("(%s gently refuses your proposal. )")
  :format(name(_1))
end
        },
        silence = {
          start = function(_1)
  return ("(%s stops talking...)")
  :format(name(_1))
end,
          stop = function(_1)
  return ("(%s hugs you.)")
  :format(name(_1))
end
        },
        wait_at_town = function(_1)
  return ("(You order %s to wait at the town.)")
  :format(name(_1))
end
      },
      arena_master = {
        choices = {
          enter_duel = "I'm entering the arena. [Duel]",
          enter_rumble = "I'm entering the arena. [Rumble]",
          score = "Tell me my scores."
        },
        enter = {
          cancel = "Alright. Call me if you changed your mind.",
          choices = {
            enter = "Alright.",
            leave = "I'll pass."
          },
          game_is_over = "The game is over today. Come again tomorrow.",
          target = function(_1)
  return ("You got %s today. What'ya say?")
  :format(_1)
end,
          target_group = function(_1)
  return ("Your play is a group of monster around level %s. Sounds easy huh?")
  :format(_1)
end
        },
        streak = function(_1)
  return ("Your winning streak has reached %s matches now. Keep the audience excited. You get nice bonus at every 5th and 20th wins in a row.")
  :format(_1)
end
      },
      bartender = {
        call_ally = {
          brings_back = function(_1, _2)
  return ("(%s brings %s from the stable.) There you go.")
  :format(name(_1), name(_2))
end,
          choices = {
            go_back = "Never mind.",
            pay = "I'll pay."
          },
          cost = function(_1)
  return ("Alright. We had taken good care of your pet. It will cost you %s gold pieces.")
  :format(_1)
end,
          no_need = "Huh? You don't need to do that."
        },
        choices = {
          call_ally = "Call back my allies."
        }
      },
      caravan_master = {
        choices = {
          hire = "Hire caravan."
        },
        hire = {
          choices = {
            go_back = "Never mind!"
          },
          tset = "tset"
        }
      },
      common = {
        choices = {
          sex = "Interested in a little tail t'night?",
          talk = "Let's Talk.",
          trade = "Are you interested in trade?"
        },
        hand_over = function(_1)
  return ("You hand over %s.")
  :format(itemname(_1, 1))
end,
        sex = {
          choices = {
            accept = "Let's do it.",
            go_back = "W-wai.t.."
          },
          prompt = "You are...quite attractive. I'll buy you.",
          response = "Come on!",
          start = "Okay, no turning back now!"
        },
        thanks = "Thanks!",
        you_kidding = "You kidding? "
      },
      guard = {
        choices = {
          lost_suitcase = "Here is a lost suitcase I found.",
          lost_wallet = "Here is a lost wallet I found.",
          where_is = function(_1)
  return ("Where is %s?")
  :format(basename(_1))
end
        },
        lost = {
          dialog = "How nice of you to take the trouble to bring it. You're a model citizen indeed!",
          empty = {
            dialog = "Hmm! It's empty!",
            response = "Oops...!"
          },
          found_often = {
            dialog = {
              _0 = "Oh, it's you again? How come you find the wallets so often?",
              _1 = "(...suspicious)"
            },
            response = "I really found it on the street!"
          },
          response = "It's nothing."
        },
        where_is = {
          close = function(_1, _2)
  return ("I saw %s just a minute ago. Try %s.")
  :format(basename(_2), _1)
end,
          dead = "Oh forget it, dead for now.",
          direction = {
            east = "east",
            north = "north",
            south = "south",
            west = "west"
          },
          far = function(_1, _2)
  return ("If you want to meet %s, you have to considerably walk to %s.")
  :format(basename(_2), _1)
end,
          moderate = function(_1, _2)
  return ("Walk to %s for a while, you'll find %s.")
  :format(_1, basename(_2))
end,
          very_close = function(_1)
  return ("Oh look carefully before asking, just turn %s.")
  :format(_1)
end,
          very_far = function(_1, _2)
  return ("You need to walk long way to %s to meet %s.")
  :format(_1, basename(_2))
end
        }
      },
      healer = {
        choices = {
          restore_attributes = "Restore my attributes."
        },
        restore_attributes = "Done treatment. Take care!"
      },
      horse_master = {
        choices = {
          buy = "I want to buy a horse."
        }
      },
      informer = {
        choices = {
          investigate_ally = "I want you to investigate one of my allies.",
          show_adventurers = "Show me the list of adventurers."
        },
        investigate_ally = {
          choices = {
            go_back = "No way!",
            pay = "Too expensive, but okay."
          },
          cost = "10000 gold pieces."
        },
        show_adventurers = "Done?"
      },
      innkeeper = {
        choices = {
          eat = "Bring me something to eat.",
          go_to_shelter = "Take me to the shelter."
        },
        eat = {
          here_you_are = "Here you are.",
          not_hungry = "You don't seem that hungry.",
          results = { "It was tasty.", "Not bad at all.", "You smack your lips." }
        },
        go_to_shelter = "The shelter is free to use for anyone. Here, come in."
      },
      maid = {
        choices = {
          do_not_meet = "I don't want to meet anyone.",
          meet_guest = "Yes, I'll meet the guest now.",
          think_of_house_name = "Think of a nice name for my house."
        },
        do_not_meet = "Alright.",
        think_of_house_name = {
          come_up_with = function(_1)
  return ("Hey, I've come up a good idea! \"%s\", doesn't it sound so charming?")
  :format(_1)
end,
          suffixes = { function(_1)
  return ("%s Home")
  :format(_1)
end, function(_1)
  return ("%s Mansion")
  :format(_1)
end, function(_1)
  return ("%s Shack")
  :format(_1)
end, function(_1)
  return ("%s Nest")
  :format(_1)
end, function(_1)
  return ("%s Base")
  :format(_1)
end, function(_1)
  return ("%s Hideout")
  :format(_1)
end, function(_1)
  return ("%s Dome")
  :format(_1)
end, function(_1)
  return ("%s Hut")
  :format(_1)
end, function(_1)
  return ("%s Cabin")
  :format(_1)
end, function(_1)
  return ("%s Hovel")
  :format(_1)
end, function(_1)
  return ("%s Shed")
  :format(_1)
end }
        }
      },
      moyer = {
        choices = {
          sell_paels_mom = "I want to sell Pael's mom."
        },
        sell_paels_mom = {
          choices = {
            go_back = "You cold bastard.",
            sell = "Sure, take her."
          },
          prompt = "Look what we have! A woman who got a monster's face. It'll be a good show. Wanna sell me for 50000 gold coins?",
          you_sell = "You sell Pael's mom..."
        }
      },
      pet_arena_master = {
        choices = {
          register_duel = "I want to register my pet. [Duel]",
          register_team = "I want to register my team. [Team]"
        },
        register = {
          choices = {
            enter = "I'll send my pet.",
            leave = "I'll pass."
          },
          target = function(_1)
  return ("The opponent is around level %s. Want to give it a try? ")
  :format(_1)
end,
          target_group = function(_1, _2)
  return ("It's a %s vs %s match. The opponent's group is formed by the pets less than %s levels. What you say?")
  :format(_1, _1, _2)
end
        }
      },
      prostitute = {
        buy = function(_1)
  return ("Okay sweetie, I need %s gold pieces in front.")
  :format(_1)
end,
        choices = {
          buy = "I'll buy you."
        }
      },
      quest_giver = {
        about = {
          backpack_full = "It seems your backpack is already full. Come see me again when you're ready.",
          choices = {
            leave = "Not now.",
            take = "I will take the job."
          },
          during = "What about my contract? Is everything alright? ",
          here_is_package = "Here's the package. Be aware of the deadline. I don't want to report you to the guards.",
          party_full = "It seems your party is already full. Come see me again when you're ready.",
          thanks = "Thanks. I'm counting on you.",
          too_many_unfinished = "Hey, you've got quite a few unfinished contracts. See me again when you have finished them."
        },
        accept = {
          harvest = "Fine. I'll take you to my farm.",
          hunt = "Great! I'll guide you to the place, kill them all!",
          party = "Alright, I'll take you to the party now."
        },
        choices = {
          about_the_work = "About the work.",
          here_is_delivery = "Here's your delivery.",
          here_is_item = function(_1)
  return ("Here is %s you asked.")
  :format(itemname(_1, 1))
end
        },
        finish = {
          escort = "We made it! Thank you!"
        }
      },
      servant = {
        choices = {
          fire = "You are fired."
        },
        fire = {
          choices = {
            no = "No.",
            yes = "Yes."
          },
          prompt = function(_1)
  return ("(%s looks at you sadly. Really dismiss %s? )")
  :format(name(_1), him(_1))
end,
          you_dismiss = function(_1)
  return ("You dismiss %s.")
  :format(name(_1))
end
        }
      },
      shop = {
        ammo = {
          choices = {
            go_back = "Another time.",
            pay = "Alright."
          },
          cost = function(_1)
  return ("Sure, let me check what type of ammos you need....Okay, reloading all of your ammos will cost %s gold pieces.")
  :format(_1)
end,
          no_ammo = "Reload what? You don't have any ammo in your inventory."
        },
        attack = {
          choices = {
            attack = "Pray to your God.",
            go_back = "W-Wait! I was just kidding."
          },
          dialog = "Oh crap. Another bandit trying to spoil my business! Form up, mercenaries."
        },
        choices = {
          ammo = "I need ammos for my weapon.",
          attack = "Prepare to die!",
          buy = "I want to buy something.",
          invest = "Need someone to invest in your shop?",
          sell = "I want to sell something."
        },
        criminal = {
          buy = "I don't have business with criminals.",
          sell = "I don't have business with criminals."
        },
        invest = {
          ask = function(_1)
  return ("Oh, do you want to invest in my shop? It will cost you %s golds. I hope you got the money.")
  :format(_1)
end,
          choices = {
            invest = "Invest",
            reject = "Reject"
          }
        }
      },
      sister = {
        buy_indulgence = {
          choices = {
            buy = "Deal.",
            go_back = "The price is too high."
          },
          cost = function(_1)
  return ("In the authority of all the saints, I will grant you an indulgence, for money of course. The price is %s gold pieces.")
  :format(_1)
end,
          karma_is_not_low = "You karma isn't that low. Come back after you have committed more crimes!"
        },
        choices = {
          buy_indulgence = "I want to buy an indulgence."
        }
      },
      slave_trader = {
        buy = {
          choices = {
            go_back = "Never mind.",
            pay = "I'll pay."
          },
          cost = function(_1, _2)
  return ("Okay. Let me check the stable....How about %s for %s gold pieces. I'd say it's quite a bargain!")
  :format(_1, _2)
end,
          you_buy = function(_1)
  return ("You buy %s.")
  :format(_1)
end
        },
        choices = {
          buy = "I want to buy a slave.",
          sell = "I want to sell a slave."
        },
        sell = {
          choices = {
            deal = "Deal.",
            go_back = "No way."
          },
          price = function(_1)
  return ("Let me see....Hmmm, this one got a nice figure. I'll give you %s gold pieces.")
  :format(_1)
end,
          you_sell_off = function(_1)
  return ("You sell off %s.")
  :format(_1)
end
        }
      },
      spell_writer = {
        choices = {
          reserve = "I want to reserve some books."
        }
      },
      trainer = {
        choices = {
          go_back = "Never mind.",
          learn = {
            accept = "Teach me the skill.",
            ask = "What skills can you teach me?"
          },
          train = {
            accept = "Train me.",
            ask = "Train me."
          }
        },
        cost = {
          learning = function(_1, _2)
  return ("Learning %s will cost you %s platinum pieces.")
  :format(_1, _2)
end,
          training = function(_1, _2)
  return ("Training %s will cost you %s platinum pieces.")
  :format(_1, _2)
end
        },
        finish = {
          learning = "I've taught you all that I know of the skill. Now develop it by yourself.",
          training = "Well done. You've got more room to develop than anyone else I've ever drilled. Keep training."
        },
        leave = "Come see me again when you need more training."
      },
      wizard = {
        choices = {
          identify = "I need you to identify an item.",
          identify_all = "Identify all of my stuff.",
          investigate = "Investigate an item.",
          ["return"] = "I want to return."
        },
        identify = {
          already = "Your items have already been identified.",
          count = function(_1, _2)
  return ("%s out of %s unknown items are fully identified.")
  :format(_1, _2)
end,
          finished = "Here, I have finished identifing your stuff.",
          need_investigate = "You need to investigate it to gain more knowledge."
        },
        ["return"] = "I'm practicing a spell of return. Would you like to take my service?"
      }
    },
    will_not_listen = function(_1)
  return ("%s won't listen.")
  :format(name(_1))
end,
    window = {
      attract = "Attract",
      fame = function(_1)
  return ("Fame: %s")
  :format(_1)
end,
      impress = "Impress",
      of = function(_1, _2)
  return ("%s of %s")
  :format(_1, _2)
end,
      shop_rank = function(_1)
  return ("Shop Rank:%s")
  :format(_1)
end
    }
  }
}
