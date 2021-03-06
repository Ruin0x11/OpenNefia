return {
   random_event = {
      skip = function(_1)
         return ("\"%s\"")
            :format(_1)
      end,
      title = function(_1)
         return (" < %s > ")
            :format(_1)
      end,
      _ = {
         elona = {
            _1 = {
               choices = {
                  _1 = "Good."
               },
               text = "You sense a bad feeling for a moment but it fades away quickly.",
               title = "Avoiding Misfortune"
            },
            _10 = {
               choices = {
                  _1 = "(Search)",
                  _2 = "(Leave)"
               },
               text = "You discover a camping site someone left behind. Chunks of leftovers and junks remain here. You may possibly find some useful items.",
               title = "Camping Site"
            },
            _11 = {
               bury = "You bury the corpse with respect.",
               choices = {
                  _1 = "(Loot)",
                  _2 = "(Bury)"
               },
               loot = "You loot the remains.",
               text = "You find a corpse of an adventurer. There're bones and equipment scatters on the ground waiting to decay.",
               title = "Corpse"
            },
            _12 = {
               choices = {
                  _1 = "Nice."
               },
               text = "You stumble over a stone and find some materials on the ground. ",
               title = "Small Luck"
            },
            _13 = {
               choices = {
                  _1 = "I'm hungry now!"
               },
               text = "A sweet smell of food floats from nowhere. Your stomach growls but you can't find out where it comes from.",
               title = "Smell of Food"
            },
            _14 = {
               choices = {
                  _1 = "(Eat)",
                  _2 = "(Leave)"
               },
               text = "You come across a strange feast.",
               title = "Strange Feast"
            },
            murderer = {
               choices = {
                  _1 = "Sorry for you."
               },
               scream = function(_1)
                  return ("%s screams, \"Ahhhhhhh!\"")
                     :format(name(_1))
               end,
               text = "Suddenly, a painful shriek rises from somewhere in the town. You see several guards hastily run by.",
               title = "Murderer"
            },
            _16 = {
               choices = {
                  _1 = "What a luck!"
               },
               text = "A rich mad man is scattering his money all over the ground.",
               title = "Mad Millionaire",
               you_pick_up = function(_1)
                  return ("You pick up %s gold pieces.")
                     :format(_1)
               end
            },
            _17 = {
               choices = {
                  _1 = "Thanks."
               },
               text = "A priest comes up to you and casts a spell on you. No problem.",
               title = "Wandering Priest"
            },
            _18 = {
               choices = {
                  _1 = "Great."
               },
               text = "In your dream, a saint comes out and blesses you.",
               title = "Gaining Faith"
            },
            _19 = {
               choices = {
                  _1 = "Woohoo!"
               },
               text = "You buried treasure in your dream. You quickly get up and write down the location.",
               title = "Treasure of Dream"
            },
            _2 = {
               choices = {
                  _1 = "A weird dream."
               },
               text = "In your dream, you meet a wizard with a red mustache. Who are you? Hmm, I guess I picked up the wrong man's dream. My apology for disturbing your sleep. To make up for this... The wizard draws a circle in the air and vanishes. You feel the effects of a faint headache.",
               title = "Wizard's Dream"
            },
            _20 = {
               choices = {
                  _1 = "Woohoo!"
               },
               text = "Mewmewmew!",
               title = "Lucky Day"
            },
            _21 = {
               choices = {
                  _1 = "Woohoo!"
               },
               text = "Mewmew? You've found me!",
               title = "Quirk of Fate"
            },
            _22 = {
               choices = {
                  _1 = "Urrgh..hh.."
               },
               text = "You are fighting an ugly monster. You are about to thrust a dagger into the neck of the monster. And the monster screams. You are me! I am you! You are awakened by your own low moan.",
               title = "Monster Dream"
            },
            _23 = {
               choices = {
                  _1 = "Sweet."
               },
               text = "In your dream, you harvest materials peacefully.",
               title = "Dream Harvest"
            },
            _24 = {
               choices = {
                  _1 = "Woohoo!"
               },
               text = "Suddenly you develop your gift!",
               title = "Your Potential"
            },
            _3 = {
               choices = {
                  _1 = "Good!"
               },
               text = "You lie awake, sunk deep into thought. As memories of your journey flow from one into another, you chance upon a new theory to improve one of your skills.",
               title = "Development"
            },
            _4 = {
               choices = {
                  _1 = "Strange..."
               },
               text = "In your dreams, several pairs of gloomy eyes stare at you and laughter seemingly from nowhere echoes around you.  Keh-la keh-la keh-la I found you...I found you.. keh-la keh-la keh-la After tossing around a couple times, the dream is gone.",
               title = "Creepy Dream"
            },
            _5 = {
               choices = {
                  _1 = "Can't...sleep..."
               },
               no_effect = "Your prayer nullifies the curse.",
               text = "Your sleep is disturbed by a harshly whispering that comes from nowhere.",
               title = "Cursed Whispering"
            },
            _6 = {
               choices = {
                  _1 = "Good."
               },
               text = "Your entire body flushes. When you wake up, a scar in your arm is gone.",
               title = "Regeneration"
            },
            _7 = {
               choices = {
                  _1 = "Good."
               },
               text = "In your dream, you meditate and feel inner peace.",
               title = "Meditation"
            },
            _8 = {
               choices = {
                  _1 = "Bloody thieves..."
               },
               no_effect = "The thief fails to steal money from you.",
               text = "A malicious hand slips and steals your money.",
               title = "Malicious Hand",
               you_lose = function(_1)
                  return ("You lose %s gold pieces.")
                     :format(_1)
               end
            },
            _9 = {
               choices = {
                  _1 = "What a luck!"
               },
               text = "You stumble over a stone and find a platinum coin.",
               title = "Great Luck"
            },
            marriage = {
               choices = {
                  _1 = "Without you, life has no meaning."
               },
               text = function(_1)
                  return ("At last, you and %s are united in marriage! After the wedding ceremony, you receive some gifts.")
                     :format(name(_1))
               end,
               title = "Marriage"
            },
            reunion_with_pet = {
               choices = {
                  _1 = "a dog!",
                  _2 = "a cat!",
                  _3 = "a bear!",
                  _4 = "a little girl!"
               },
               text = "As you approach the mining town, you notice a familiar call and stop walking. Your old pet who got separated from you during the shipwreck is now running towards you joyfully! Your pet is...",
               title = "Reunion with your pet"
            },
         }
      }
   }
}
