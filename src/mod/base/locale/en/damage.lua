return {
   damage = {
      critical_hit = "Critical Hit!",
      death_word_breaks = "The death word breaks.",
      evade = {
         ally = function(_1, _2)
            return ("%s skillfully evade%s %s.")
               :format(name(_2), s(_2), name(_1))
         end,
         other = function(_1, _2)
            return ("%s skillfully evade%s %s.")
               :format(name(_2), s(_2), name(_1))
         end
      },
      explode_click = "*click*",
      furthermore = "Futhermore,",
      get_off_corpse = function(_1)
         return ("%s get off the corpse of %s.")
            :format(you(), name(_1))
      end,
      is_engulfed_in_fury = function(_1)
         return ("%s %s engulfed in fury!")
            :format(name(_1), is(_1))
      end,
      is_frightened = function(_1)
         return ("%s %s frightened.")
            :format(name(_1), is(_1))
      end,
      is_healed = function(_1)
         return ("%s %s healed.")
            :format(name(_1), is(_1))
      end,
      lay_hand = function(_1)
         return ("%s shout%s, \"Lay hand!\"")
            :format(name(_1), s(_1))
      end,
      levels = {
         critically = function(_1, _2)
            return ("critically wound%s %s!")
               :format(s(_2), him(_1))
         end,
         moderately = function(_1, _2)
            return ("moderately wound%s %s.")
               :format(s(_2), him(_1))
         end,
         scratch = function(_1, _2)
            return ("make%s a scratch.")
               :format(s(_2))
         end,
         severely = function(_1, _2)
            return ("severely wound%s %s.")
               :format(s(_2), him(_1))
         end,
         slightly = function(_1, _2)
            return ("slightly wound%s %s.")
               :format(s(_2), him(_1))
         end
      },
      magic_reaction_hurts = function(_1)
         return ("Magic reaction hurts %s!")
            :format(name(_1))
      end,
      miss = {
         ally = function(_1, _2)
            return ("%s evade%s %s.")
               :format(name(_2), s(_2), name(_1))
         end,
         other = function(_1, _2)
            return ("%s miss%s %s.")
               :format(name(_1), s(_1, true), name(_2))
         end
      },
      reactions = {
         is_severely_hurt = function(_1)
            return ("%s %s severely hurt!")
               :format(name(_1), is(_1))
         end,
         screams = function(_1)
            return ("%s scream%s.")
               :format(name(_1), s(_1))
         end,
         writhes_in_pain = function(_1)
            return ("%s writhe%s in pain.")
               :format(name(_1), s(_1))
         end
      },
      reactive_attack = {
         acids = "Acids spread over the ground.",
         ether_thorns = function(_1)
            return ("%s %s stuck by several ether thorns.")
               :format(name(_1), is(_1))
         end,
         thorns = function(_1)
            return ("%s %s stuck by several thorns.")
               :format(name(_1), is(_1))
         end
      },
      runs_away_in_terror = function(_1)
         return ("%s run%s away in terror.")
            :format(name(_1), s(_1))
      end,
      sand_bag = {
         _0 = "Kill me already!",
         _1 = "No..not yet...!",
         _2 = "I can't take it anymore...",
         _3 = "Argh!",
         _4 = "Uhhh",
         _5 = "Ugggg"
      },
      sleep_is_disturbed = function(_1)
         return ("%s%s sleep %s disturbed")
            :format(name(_1), his_owned(_1), is(_1))
      end,
      splits = function(_1)
         return ("%s split%s!")
            :format(name(_1), s(_1))
      end,
      vorpal = {
         melee = "*vopal*",
         ranged = "*vopal*"
      },
      weapon = {
         attacks_and = function(_1, _2, _3)
            return ("%s %s%s %s and")
               :format(name(_1), _2, s(_1), name(_3))
         end,
         attacks_throwing = function(_1, _2, _3)
            return ("%s %s%s %s and")
               :format(name(_1), _2, s(_1), name(_3))
         end,
         attacks_unarmed = function(_1, _2, _3)
            return ("%s %s%s %s.")
               :format(name(_1), _2, s(_1), name(_3))
         end,
         attacks_unarmed_and = function(_1, _2, _3)
            return ("%s %s%s %s and")
               :format(name(_1), _2, s(_1), name(_3))
         end,
         attacks_with = function(_1, _2, _3, _4)
            return ("%s %s%s %s with %s %s.")
               :format(name(_1), _2, s(_1), name(_3), his(_1), _4)
         end
      },
      wields_proudly = function(_1, _2)
         return ("%s wield%s %s proudly.")
            :format(name(_1), s(_1), _2)
      end,
      you_feel_sad = "You feel sad for a moment.",

      melee = {
         default = {
            enemy = "punch",
            ally = "punch",
            weapon = "hand",
         },

         claw = {
            enemy = "claw",
            ally = "claw",
            weapon = "claw",
         },

         bite = {
            enemy = "bite",
            ally = "bite",
            weapon = "fang",
         },

         gaze = {
            enemy = "gaze",
            ally = "gaze",
            weapon = "eye",
         },

         sting = {
            enemy = "sting",
            ally = "sting",
            weapon = "needle",
         },

         touch = {
            enemy = "touch",
            ally = "touch",
            weapon = "hand",
         },

         spore = {
            enemy = "attack",
            ally = "attack",
            weapon = "spore",
         }
      }
   }
}
