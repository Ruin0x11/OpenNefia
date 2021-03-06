local quest = {
   cook = {
      detail = function(params)
         return ("Give %s to the client.")
            :format(params.objective)
      end,

      food_type = {
         elona = {
            meat = {
               _1 = {
                  title = "A reception.",
                  desc = function(player, speaker, params)
                     return ("We will be hosting this very important reception tonight. The guests must be satisfied and made to feel gorgeous. I want you to prepare %s and %s are yours.")
                        :format(params.objective, params.reward)
                  end,
               },
            },
            vegetable = {
               _1 = {
                  title = "On a diet",
                  desc = function(player, speaker, params)
                     return ("Vegetables are essential parts of a healthy diet. Cook %s for me. Your rewards are %s.")
                        :format(params.objective, params.reward)
                  end,
               },
            },
            fruit = {
               _1 = {
                  title = "Cocktail party!",
                  desc = function(player, speaker, params)
                     return ("Run a small errand for us and earn %s. We need a wicked relish for our cocktail party. Say, %s sounds decent.")
                        :format(params.reward, params.objective)
                  end,
               },
            },
            sweet = {
               _1 = {
                  title = "Sweet sweet.",
                  desc = function(player, speaker, params)
                     return ("I prefer cakes and candies to alcoholic drinks. You want %s? Gimme %s!")
                        :format(params.reward, params.objective)
                  end,
               },
            },
            pasta = {
               _1 = {
                  title = "I love noodles!",
                  desc = function(player, speaker, params)
                     return ("I love noodles! Is there anyone that hates noodles? I want to eat %s now! Rewards? Of course. %s sound good? ")
                        :format(params.objective, params.reward)
                  end,
               }
            },
            fish = {
               _1 = {
                  title = "Fussy taste.",
                  desc = function(player, speaker, params)
                     return ("My children won't eat fish. It's killing me. I'm gonna give %s to anyone that makes %s delicious enough to sweep their fuss!")
                        :format(params.reward, params.objective)
                  end,
               },
            },
            bread = {
               _1 = {
                  title = "Going on a picnic.",
                  desc = function(player, speaker, params)
                     return ("First off, the rewards are no more than %s, ok? My kid needs %s for a picnic tomorrow. Please hurry.")
                        :format(params.reward, params.objective)
                  end,
               },
            },
            egg = {
               _1 = {
                  title = "A new recipe!",
                  desc = function(player, speaker, params)
                     return ("As in the capacity of a cooking master, I'm always eager to learn a new recipe. Bring me %s and I'll pay you %s.")
                        :format(params.objective, params.reward)
                  end,
               },
            }
         },
      },
      general = {
         _1 = {
            title = "My stomach!",
            desc = function(player, speaker, params)
               return ("My stomach growls like I'm starving to death habitually. Will you bring a piece to this beast? Maybe %s will do the job. I can give you %s as a reward.")
                  :format(params.objective, params.reward)
            end,
         },
      }
   },
   collect = {
      target_in = function(_1)
         return ("the target in %s")
            :format(_1)
      end,
      detail = function(params)
         return ("Acquire %s from %s for the client.")
            :format(params.item_name, params.target_name)
      end,

      _1 = {
         title = "I want it!",
         desc = function(player, speaker, params)
            return ("Have you seen %s's %s? I want it! I want it! Get it for me by fair means or foul! I'll give you %s.")
               :format(params.target_name, params.item_name, params.reward)
         end,
      },
   },
   conquer = {
      unknown_monster = "unknown monster",
      detail = function(params)
         return ("Slay %s.")
            :format(params.objective)
      end,

      _1 = {
         title = "Challenge",
         desc = function(player, speaker, params)
            return ("Only experienced adventurers should take this task. An unique mutant of %s has been sighted near the town. Slay this monster and we'll give you %s. This is no ordinary mission. The monster's leve is expected to be around %s.")
               :format(params.objective, params.reward, params.enemy_level)
         end,
      },
   },
   escort = {
      detail = function(params)
         return ("Escort the client to %s.")
            :format(params.map)
      end,

      type = {
         protect = {
            _1 = {
               title = "Beauty and the beast",
               desc = function(player, speaker, params)
                  return ("Such great beauty is a sin...My girl friend is followed by her ex-lover and needs an escort. If you safely bring her to %s, I'll give you %s. Please, protect her from the beast.")
                     :format(params.map, params.reward)
               end,
            },
         },
         poison = {
            _1 = {
               title = "Before it's too late.",
               desc = function(player, speaker, params)
                  return ("Terrible thing happened! My dad is affected by a deadly poison. Hurry! Please take him to his doctor in %s. I'll let you have %s if you sucssed!")
                     :format(params.map, params.reward)
               end,
            },
         },
         deadline = {
            _1 = {
               title = "Escort needed.",
               desc = function(player, speaker, params)
                  return ("We have this client secretly heading to %s for certain reasons. We offer you %s if you succeed in escorting this person.")
                     :format(params.map, params.reward)
               end,
            },
         }
      }
   },
   harvest = {
      detail = function(params)
         return ("Gather harvests weight %s.")
            :format(params.required_weight)
      end,

      _1 = {
         title = "The harvest time.",
         desc = function(player, speaker, params)
            return ("At last, the harvest time has come. It is by no means a job that I alone can handle. You get %s if you can gather grown crops weighting %s.")
               :format(params.reward, params.required_weight)
         end,
      },
   },
   hunt = {
      detail = "Eliminate monsters.",

      _1 = {
         title = "Hunting.",
         desc = function(player, speaker, params)
            return ("Filthy creatures are spawning in a forest nearby this city. I'll give you %s if you get rid of them.")
               :format(params.reward)
         end,
      },
   },
   huntex = {
      detail = "Eliminate monsters",

      _1 = {
         title = "Panic.",
         desc = function(player, speaker, params)
            return ("Help! Our town is being seized by several subspecies of %s which are expected to be around %s level. Eliminate them all and I'll reward you with %s on behalf of all the citizen.")
               :format(params.objective, params.enemy_level, params.reward)
         end,
      },
   },
   party = {
      points = function(_1)
         return ("%s points")
            :format(_1)
      end,
      detail = function(params)
         return ("Gather %s.")
            :format(params.required_points)
      end,

      _1 = {
         title = "Party time!",
         desc = function(player, speaker, params)
            return ("I'm throwing a big party today. Many celebrities are going to attend the party so I need someone to keep them entertained. If you successfully gather %s, I'll give you a platinum coin. You'll surely be earning tons of tips while you work, too.")
               :format(params.required_points)
         end,
      },
   },
   supply = {
      detail = function(params)
         return ("Give %s to the client.")
            :format(params.objective)
      end,

      _1 = {
         title = "Birthday.",
         desc = function(player, speaker, params)
            return ("I want to give my kid %s as a birthday present. If you can send me this item, I'll pay you %s in exchange.")
               :format(params.objective, params.reward)
         end,
      },
   },
   deliver = {
      detail = function(params)
         return ("Deliver %s to %s who lives in %s.")
            :format(params.item_name, params.target_name, params.map)
      end,

      elona = {
         spellbook = {
            _1 = {
               title = "Book delivery.",
               desc = function(player, speaker, params)
                  return ("Can you take %s to a person named %s who lives in %s? I'll pay you %s.")
                     :format(params.item_name, params.target_name, params.map, params.reward)
               end,
            },
         },
         furniture = {
            _1 = {
               title = "A present.",
               desc = function(player, speaker, params)
                  return ("My uncle %s has built a house in %s and I'm planning to send %s as a gift. I have %s in reward.")
                     :format(params.target_name, params.map, params.item_name, params.reward)
               end,
            },
         },
         junk = {
            _1 = {
               title = "Ecologist.",
               desc = function(player, speaker, params)
                  return ("My friend in %s is collecting waste materials. The name is %s. If you plan to visit %s, could you hand him %s? I'll pay you %s.")
                     :format(params.map, params.target_name, params.map, params.item_name, params.reward)
               end,
            },
         },
         ore = {
            _1 = {
               title = "A small token.",
               desc = function(player, speaker, params)
                  return ("As a token of our long lasting friendship, I decided to give %s to %s who lives in %s. I'll arrange %s for your reward.")
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
         elona = {
            wear = "equipment",
            magic = "magical goods",
            armor = "armor",
            weapon = "weapons",
            supply = "ores",
            furniture = "furnitures" -- TODO unused?
         }
      }
   }
}
