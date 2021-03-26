return {
   titles = {
      title = {
         _ = {
            omake_overhaul = {
               decoy = {
                  name = "Decoy",
                  condition = "Defeat <Rodlob> the boss of yeeks",
                  info = {
                     effect = "Able to summon yeeks.",

                     killed = function(_1)
                        return ("<Rodlob> the boss of yeeks killed: %s"):format(_1)
                     end
                  }
               },
               born_in_a_temple = {
                  name = "Born in a Temple",
                  condition = "Defeat <Tuwen> the master of the pyramid",
                  info = {
                     effect = "Sometimes invalidate curses.",

                     killed = function(_1)
                        return ("<Tuwen> the master of the pyramid killed: %s"):format(_1)
                     end
                  }
               },
               god_of_war = {
                  name = "God of War",
                  condition = "Reach 100 in Tactics",
                  info = {
                     effect = "Expands effective range of Swarm.",

                     killed = {
                        bubbles = function(_1)
                           return ("Bubbles killed: %s"):format(_1)
                        end,
                        blue_bubbles = function(_1)
                           return ("Blue bubbles killed: %s"):format(_1)
                        end,
                        mass_monsters = function(_1)
                           return ("Mass monsters killed: %s"):format(_1)
                        end,
                        cubes = function(_1)
                           return ("Cubes killed: %s"):format(_1)
                        end
                     }
                  }
               }
            }
         }
      }
   }
}
