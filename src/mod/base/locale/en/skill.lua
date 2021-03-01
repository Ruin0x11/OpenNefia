return {
   skill = {
      elona = {
         stat_strength = {
            decrease = function(_1)
               return ("%s%s muscles soften.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s muscles feel stronger.")
                  :format(name(_1), his_owned(_1))
            end
         },
         stat_constitution = {
            decrease = function(_1)
               return ("%s lose%s patience.")
                  :format(name(_1), s(_1))
            end,
            increase = function(_1)
               return ("%s begin%s to feel good when being hit hard.")
                  :format(name(_1), s(_1))
            end
         },
         stat_dexterity = {
            decrease = function(_1)
               return ("%s become%s clumsy.")
                  :format(name(_1), s(_1))
            end,
            increase = function(_1)
               return ("%s become%s dexterous.")
                  :format(name(_1), s(_1))
            end
         },
         stat_perception = {
            decrease = function(_1)
               return ("%s %s getting out of touch with the world.")
                  :format(name(_1), is(_1))
            end,
            increase = function(_1)
               return ("%s feel%s more in touch with the world.")
                  :format(name(_1), s(_1))
            end
         },
         stat_learning = {
            decrease = function(_1)
               return ("%s lose%s curiosity.")
                  :format(name(_1), s(_1))
            end,
            increase = function(_1)
               return ("%s feel%s studious.")
                  :format(name(_1), s(_1))
            end
         },
         stat_will = {
            decrease = function(_1)
               return ("%s%s will softens.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s will hardens.")
                  :format(name(_1), his_owned(_1))
            end
         },
         stat_magic = {
            decrease = function(_1)
               return ("%s%s magic degrades.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s magic improves.")
                  :format(name(_1), his_owned(_1))
            end
         },
         stat_charisma = {
            decrease = function(_1)
               return ("%s start%s to avoid eyes of people.")
                  :format(name(_1), s(_1))
            end,
            increase = function(_1)
               return ("%s enjoy%s showing off %s body.")
                  :format(name(_1), s(_1), his(_1))
            end
         },
         stat_speed = {
            decrease = function(_1)
               return ("%s%s speed decreases.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s speed increases.")
                  :format(name(_1), his_owned(_1))
            end
         },
         stat_luck = {
            decrease = function(_1)
               return ("%s become%s unlucky.")
                  :format(name(_1), s(_1))
            end,
            increase = function(_1)
               return ("%s become%s lucky.")
                  :format(name(_1), s(_1))
            end
         },
         stat_life = {
            decrease = function(_1)
               return ("%s%s life force decreases.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s life force increases.")
                  :format(name(_1), his_owned(_1))
            end
         },
         stat_mana = {
            decrease = function(_1)
               return ("%s%s mana decreases.")
                  :format(name(_1), his_owned(_1))
            end,
            increase = function(_1)
               return ("%s%s mana increases.")
                  :format(name(_1), his_owned(_1))
            end
         },
      },
      default = {
         decrease = function(_1, _2)
            return ("%s%s %s skill falls off.")
               :format(name(_1), his_owned(_1), _2)
         end,
         increase = function(_1, _2)
            return ("%s%s %s skill increases.")
               :format(name(_1), his_owned(_1), _2)
         end
      },
      gained = function(_1)
         return ("You have learned new ability, %s.")
            :format(_1)
      end
   }
}
