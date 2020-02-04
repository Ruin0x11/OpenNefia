return {
   trait = {
      anorexia = "You have anorexia.",
      body_is_complicated = function(_1)
         return ("Your body is complicated. [SPD-%s%]")
            :format(_1)
      end,
      ether_disease_grows = {
         fast = "Your Ether disease grows fast.",
         slow = "Your Ether disease grows slow."
      },
      incognito = "You are disguising yourself.",
      pregnant = "You are pregnant.",
      window = {
         ally = "Ally",
         already_maxed = "You already have maxed out the feat.",
         available_feats = "[Available feats]",
         category = {
            etc = "ETC",
            ether_disease = "Disease",
            feat = "Feat",
            mutation = "Mutation",
            race = "Race"
         },
         detail = "Detail",
         enter = "Enter [Gain Feat]",
         feats_and_traits = "[Feats and traits]",
         his_equipment = function(_1, _2)
            return ("%s equipment %s")
               :format(_1, _2)
         end,
         level = "Level",
         name = "Name",
         requirement = "requirement",
         title = "Feats and Traits",
         you_can_acquire = function(_1)
            return ("You can acquire %s feats")
               :format(_1)
         end,
         your_trait = function(_1)
            return ("%s's Trait")
               :format(_1)
         end
      }
   }
}
