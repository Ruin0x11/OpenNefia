return {
   servant = {
      shop_title = {
         armory = function(_1)
            return ("%s of armory")
               :format(basename(_1))
         end,
         blackmarket = function(_1)
            return ("%s of blackmarket")
               :format(basename(_1))
         end,
         general_store = function(_1)
            return ("%s of general store")
               :format(basename(_1))
         end,
         goods_store = function(_1)
            return ("%s of goods store")
               :format(basename(_1))
         end,
         magic_store = function(_1)
            return ("%s of magic store")
               :format(basename(_1))
         end
      },
      hire = {
         too_many_guests = "You already have too many guests in your home.",
         who = "Who do you want to hire?",
         not_enough_money = "You don't have enough money...",
         you_hire = function(_1)
            return ("You hire %s.")
               :format(basename(_1))
         end
      },
   }
}
