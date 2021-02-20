return {
   effect = {
      elona = {
         bleeding = {
            apply = function(_1)
               return ("%s begin%s to bleed.")
                  :format(name(_1), s(_1))
            end,
            heal = function(_1)
               return ("%s%s bleeding stops.")
                  :format(name(_1), his_owned(_1))
            end,
            indicator = {
               _0 = "Bleeding",
               _1 = "Bleeding!",
               _2 = "Hemorrhage"
            },
         },
         blindness = {
            apply = function(_1)
               return ("%s %s blinded.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s can see again.")
                  :format(name(_1))
            end,
            indicator = "Blinded",
         },
         confusion = {
            apply = function(_1)
               return ("%s %s confused.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s recover%s from confusion.")
                  :format(name(_1), s(_1))
            end,
            indicator = "Confused",
         },
         dimming = {
            apply = function(_1)
               return ("%s %s dimmed.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s regain%s %s senses.")
                  :format(name(_1), s(_1), his(_1))
            end,
            indicator = {
               _0 = "Dim",
               _1 = "Muddled",
               _2 = "Unconscious"
            },
         },
         drunk = {
            apply = function(_1)
               return ("%s get%s drunk.")
                  :format(name(_1), s(_1))
            end,
            heal = function(_1)
               return ("%s get%s sober.")
                  :format(name(_1), s(_1))
            end,
            indicator = "Drunk",
         },
         fear = {
            apply = function(_1)
               return ("%s %s frightened.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s shake%s off %s fear.")
                  :format(name(_1), s(_1), his(_1))
            end,
            indicator = "Fear",
         },
         insanity = {
            apply = function(_1)
               return ("%s become%s insane.")
                  :format(name(_1), s(_1))
            end,
            heal = function(_1)
               return ("%s come%s to %s again.")
                  :format(name(_1), s(_1), himself(_1))
            end,
            indicator = {
               _0 = "Unsteady",
               _1 = "Insane",
               _2 = "Paranoia"
            },
         },
         paralysis = {
            apply = function(_1)
               return ("%s %s paralyzed.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s recover%s from paralysis.")
                  :format(name(_1), s(_1))
            end,
            indicator = "Paralyzed",
         },
         poison = {
            apply = function(_1)
               return ("%s %s poisoned.")
                  :format(name(_1), is(_1))
            end,
            heal = function(_1)
               return ("%s recover%s from poison.")
                  :format(name(_1), s(_1))
            end,
            indicator = {
               _0 = "Poisoned",
               _1 = "Poisoned Bad!"
            },
         },
         sick = {
            apply = function(_1)
               return ("%s get%s sick.")
                  :format(name(_1), s(_1))
            end,
            heal = function(_1)
               return ("%s recover%s from %s illness.")
                  :format(name(_1), s(_1), his(_1))
            end,
            indicator = {
               _0 = "Sick",
               _1 = "Very Sick"
            },
         },
         sleep = {
            apply = function(_1)
               return ("%s fall%s asleep.")
                  :format(name(_1), s(_1))
            end,
            heal = function(_1)
               return ("%s awake%s from %s sleep.")
                  :format(name(_1), s(_1), his(_1))
            end,
            indicator = {
               _0 = "Sleep",
               _1 = "Deep Sleep"
            },
         },
         choking = {
            indicator = "Choked",
         },
         fury = {
            indicator = {
               _0 = "Fury",
               _1 = "Berserk"
            }
         },
         gravity = {
            indicator = "Gravity",
         },
         wet = {
            indicator = "Wet"
         }
      },
      indicator = {
         burden = {
            _0 = "",
            _1 = "Burden",
            _2 = "Burden!",
            _3 = "Overweight",
            _4 = "Overweight!"
         },
         hunger = {
            _0 = "Starving!",
            _1 = "Starving",
            _10 = "Satisfied",
            _11 = "Satisfied!",
            _12 = "Bloated",
            _2 = "Hungry!",
            _3 = "Hungry",
            _4 = "Hungry",
            _5 = "",
            _6 = "",
            _7 = "",
            _8 = "",
            _9 = ""
         },
         sleepy = {
            _0 = "Sleepy",
            _1 = "Need Sleep",
            _2 = "Need Sleep!"
         },
         tired = {
            _0 = "Tired",
            _1 = "Very tired",
            _2 = "VERY tired"
         },
      }
   }
}
