local quest = {
   cook = {
      food_type = {
         _1 = {
            _1 = {
               title = "A reception.",
               desc = function(player, speaker, params)
                  return ("We will be hosting this very important reception tonight. The guests must be satisfied and made to feel gorgeous. I want you to prepare %s and %s are yours.")
                     :format(params.objective, params.reward)
               end,
            },
         },
         _2 = {
            _1 = {
               title = "On a diet",
               desc = function(player, speaker, params)
                  return ("Vegetables are essential parts of a healthy diet. Cook %s for me. Your rewards are %s.")
                     :format(params.objective, params.reward)
               end,
            },
         },
         _3 = {
            _1 = {
               title = "Cocktail party!",
               desc = function(player, speaker, params)
                  return ("Run a small errand for us and earn {reward}. We need a wicked relish for our cocktail party. Say, {objective} sounds decent.")
                     :format(params.reward, params.objective)
               end,
            },
         },
         _4 = {
            _1 = {
               title = "Sweet sweet.",
               desc = function(player, speaker, params)
                  return ("I prefer cakes and candies to alcoholic drinks. You want {reward}? Gimme {objective}!")
                     :format(params.reward, params.objective)
               end,
            },
         },
         _5 = {
            _1 = {
               title = "I love noodles!",
               desc = function(player, speaker, params)
                  return ("I love noodles! Is there anyone that hates noodles? I want to eat {objective} now! Rewards? Of course. {reward} sound good? ")
                     :format(params.objective, params.reward)
               end,
            }
         },
         _6 = {
            _1 = {
               title = "Fussy taste.",
               desc = function(player, speaker, params)
                  return ("My children won't eat fish. It's killing me. I'm gonna give {reward} to anyone that makes {objective} delicious enough to sweep their fuss!")
                     :format(params.reward, params.objective)
               end,
            },
         },
         _7 = {
            _1 = {
               title = "Going on a picnic.",
               desc = function(player, speaker, params)
                  return ("First off, the rewards are no more than {reward}, ok? My kid needs {objective} for a picnic tomorrow. Please hurry.")
                     :format(params.reward, params.objective)
               end,
            },
         },
         _8 = {
            _1 = {
               title = "A new recipe!",
               desc = function(player, speaker, params)
                  return ("As in the capacity of a cooking master, I'm always eager to learn a new recipe. Bring me %s and I'll pay you %s.")
                     :format(params.objective, params.reward)
               end,
            },
         }
      },
      general = {
         _1 = {
            title = "My stomach!",
            desc = function(player, speaker, params)
               return ("My stomach growls like I'm starving to death habitually. Will you bring a piece to this beast? Maybe {objective} will do the job. I can give you {reward} as a reward.")
                  :format(params.objective, params.reward)
            end,
         },
      }
   },
   collect = {
      _1 = {
         title = "I want it!",
         desc = function(player, speaker, params)
            return ("Have you seen {client}'s {ref}? I want it! I want it! Get it for me by fair means or foul! I'll give you {reward}.")
               :format(params.target_name, params.item_name, params.reward)
         end,
      },
   },
   conquer = {
      _1 = {
         title = "Challenge",
         desc = function(player, speaker, params)
            return ("Only experienced adventurers should take this task. An unique mutant of {objective} has been sighted near the town. Slay this monster and we'll give you {reward}. This is no ordinary mission. The monster's leve is expected to be around {ref}.")
               :format(params.objective, params.reward, params.enemy_level)
         end,
      },
   },
   escort = {
      difficulty = {
         _0 = {
            _1 = {
               title = "Beauty and the beast",
               desc = function(player, speaker, params)
                  return ("Such great beauty is a sin...My girl friend is followed by her ex-lover and needs an escort. If you safely bring her to {map}, I'll give you {reward}. Please, protect her from the beast.")
                     :format(params.map, params.reward)
               end,
            },
         },
         _1 = {
            _1 = {
               title = "Before it's too late.",
               desc = function(player, speaker, params)
                  return ("Terrible thing happened! My dad is affected by a deadly poison. Hurry! Please take him to his doctor in {map}. I'll let you have {reward} if you sucssed!")
                     :format(params.map, params.reward)
               end,
            },
         },
         _2 = {
            _1 = {
               title = "Escort needed.",
               desc = function(player, speaker, params)
                  return ("We have this client secretly heading to {map} for certain reasons. We offer you {reward} if you succeed in escorting this person.")
                     :format(params.map, params.reward)
               end,
            },
         }
      }
   },
   harvest = {
      _1 = {
         title = "The harvest time.",
         desc = function(player, speaker, params)
            return ("At last, the harvest time has come. It is by no means a job that I alone can handle. You get {reward} if you can gather grown crops weighting {ref}.")
               :format(params.reward, params.required_weight)
         end,
      },
   },
   hunt = {
      _1 = {
         title = "Hunting.",
         desc = function(player, speaker, params)
            return ("Filthy creatures are spawning in a forest nearby this city. I'll give you {reward} if you get rid of them.")
               :format(params.reward)
         end,
      },
   },
   huntex = {
      _1 = {
         title = "Panic.",
         desc = function(player, speaker, params)
            return ("Help! Our town is being seized by several subspecies of {objective} which are expected to be around {ref} level. Eliminate them all and I'll reward you with {reward} on behalf of all the citizen.")
               :format(params.objective, params.enemy_level, params.reward)
         end,
      },
   },
   party = {
      _1 = {
         title = "Party time!",
         desc = function(player, speaker, params)
            return ("I'm throwing a big party today. Many celebrities are going to attend the party so I need someone to keep them entertained. If you successfully gather {ref}, I'll give you a platinum coin. You'll surely be earning tons of tips while you work, too.")
               :format(params.required_points)
         end,
      },
   },
   supply = {
      _1 = {
         title = "Birthday.",
         desc = function(player, speaker, params)
            return ("I want to give my kid {objective} as a birthday present. If you can send me this item, I'll pay you {reward} in exchange.")
               :format(params.objective, params.reward)
         end,
      },
   },
   deliver = {
      elona = {
         spellbook = {
            _1 = {
               title = "Book delivery.",
               desc = function(player, speaker, params)
                  return ("Can you take {ref} to a person named {client} who lives in {map}? I'll pay you {reward}.")
                     :format(params.item_name, params.target_name, params.map, params.reward)
               end,
            },
         },
         furniture = {
            _1 = {
               title = "A present.",
               desc = function(player, speaker, params)
                  return ("My uncle {client} has built a house in {map} and I'm planning to send {ref} as a gift. I have {reward} in reward.")
                     :format(params.target_name, params.map, params.item_name, params.reward)
               end,
            },
         },
         junk = {
            _1 = {
               title = "Ecologist.",
               desc = function(player, speaker, params)
                  return ("My friend in {map} is collecting waste materials. The name is {client}. If you plan to visit {map}, could you hand him {ref}? I'll pay you {reward}.")
                     :format(params.map, params.target_name, params.map, params.item_name, params.reward)
               end,
            },
         },
         ore = {
            _1 = {
               title = "A small token.",
               desc = function(player, speaker, params)
                  return ("As a token of our long lasting friendship, I decided to give {ref} to {client} who lives in {map}. I'll arrange {reward} for your reward.")
                     :format(params.item_name, params.target_name, params.map, params.reward)
               end,
            },
         },
      },
   }
}

return {
   quest = {
      types = {
         elona = quest
      },
      reward = {
         wear = "equipment",
         magic = "magical goods",
         armor = "armor",
         weapon = "weapons",
         supply = "ores",
         furniture = "furnitures" -- TODO unused?
      }
   }
}
