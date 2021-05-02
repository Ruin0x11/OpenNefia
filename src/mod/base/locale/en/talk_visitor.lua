return {
  talk = {
    visitor = {
      adventurer = {
        conversation = {
          dialog = function(_1)
  return ("Hey %s, how's your journey? I was bored to death so I decided to make a visit to you!")
  :format(basename(_1))
end,
          hold = function(_1)
  return ("You hold an amusing conversation with %s!")
  :format(name(_1))
end
        },
        drink = {
          cheers = "Cheers!",
          dialog = "Let's have a drink and deepen our friendship!"
        },
        favorite_skill = {
          dialog = function(_1)
  return ("%s is one of my favorite skills.")
  :format(_1)
end
        },
        favorite_stat = {
          dialog = function(_1)
  return ("I'm proud of my good %s.")
  :format(_1)
end
        },
        friendship = {
          dialog = "As a pledge of friendship, here's something for you!",
          no_empty_spot = "Your home has no empty spot..."
        },
        hate = {
          dialog = "You scum! You won't get away from me now!",
          text = "\"Eat this!\"",
          throws = function(_1)
  return ("%s throws molotov.")
  :format(name(_1))
end
        },
        like = {
          dialog = "Here, take this!",
          wonder_if = "Wonder if we can reach 100 friends? ♪"
        },
        materials = {
          dialog = "I found these during my journey. Thought you could find them useful.",
          receive = function(_1)
  return ("%s gives you a bag full of materials.")
  :format(name(_1))
end
        },
        new_year = {
          gift = "I've brought you a gift today, here.",
          happy_new_year = "Happy new year!",
          throws = function(_1, _2)
  return ("%s throws you %s.")
  :format(name(_1), _2)
end
        },
        souvenir = {
          dialog = "I just stopped by to see you. Oh, I happen to have a gift for you too.",
          inventory_is_full = "Your inventory is full...",
          receive = function(_1)
  return ("You receive %s.")
  :format(_1)
end
        },
        train = {
          choices = {
            learn = "Teach me the skill.",
            pass = "I think I'll pass.",
            train = "Train me."
          },
          learn = {
            after = "Fantastic! You've learned the skill in no time. I'm glad I could help.",
            dialog = function(_1, _2)
  return ("I can teach you the art of %s for a friendly price of %s platinum pieces. Do you want me to train you?")
  :format(_1, _2)
end
          },
          pass = "I see. I'll ask you again at some time in the future.",
          train = {
            after = "Marvelous! The training is now complete. I think you've improved some potential.",
            dialog = function(_1, _2)
  return ("I can train your %s skill for a friendly price of %s platinum pieces. Do you want me to train you?")
  :format(_1, _2)
end
          }
        }
      },
      beggar = {
        after = "Thanks! I'll never forget this.",
        cheap = "You're so cheap!",
        dialog = "I got no money to buy food. Will you spare me some coins?",
        spare = function(_1, _2)
  return ("You spare %s %s gold piece%s.")
  :format(him(_2), _1, plural(_1))
end
      },
      choices = {
        no = "No.",
        yes = "Yes."
      },
      merchant = {
        choices = {
          not_now = "Not now.",
        },
        dialog = "This is your lucky day. I wouldn't normally show my discounted goods to commoners but since I feel so good today...",
        regret = "I hope you won't regret it later."
      },
      mysterious_producer = {
        no_turning_back = "Okay, no turning back now!",
        want_to_be_star = "You want to be a star?"
      },
      punk = {
        dialog = "So, are you ready?",
        hump = "Hump!"
      },
      receive = function(_1, _2)
  return ("You receive %s from %s!")
  :format(_1, name(_2))
end,
      trainer = {
        after = "Good. You show a lot of potential.",
        choices = {
          improve = function(_1)
  return ("I want to improve %s.")
  :format(_1)
end,
          not_today = "Not today."
        },
        dialog = {
          member = function(_1, _2)
  return ("As a member of %s you have to forge your talent to live up to our reputation. For only %s platinum coins, I'll improve the potential of your talent.")
  :format(_1, _2)
end,
          nonmember = function(_1)
  return ("Training! Training! At the end, only thing that saves your life is training! For only %s platinum coins, I'll improve the potential of your talent.")
  :format(_1)
end
        },
        no_more_this_month = "No more training in this month.",
        potential_expands = function(_1, _2)
  return ("%s%s potential of %s greatly expands.")
  :format(name(_1), his_owned(_1), _2)
end,
        regret = "You'll regret this!"
      },
      just_visiting = "I just wanted to say hi."
    }
  }
}
