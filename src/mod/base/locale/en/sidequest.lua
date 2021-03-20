return {
   sidequest = {
      journal = {
         title = "[Sub Quest]",
         done = "[Done]",
      },
      _ = {
         elona = {
            ambitious_scientist = {
               progress = {
                  _0 = function(_1)
                     return ("Icolle of Port Kapul asked me to bring 5 filled monster balls. I still need to bring him %s of them.")
                        :format(_1)
                  end
               },
               name = "Ambitious scientist Lv5"
            },
            cat_house = {
               progress = {
                  _0 = "Tam of Yowyn asked me to eliminate the cats in his house. The house is located southern part of Yowyn.",
                  _1 = "I've freed Tam's house from the cats. To get the reward, I need to speak Tam again in Yowyn."
               },
               name = "Cat house Lv25"
            },
            defense_line = {
               progress = {
                  _0 = "Colonel Gilbert of Yowyn asked me to help the Juere freedom force fight the Yerles Army. I should speak to him again when I'm ready.",
                  _1 = "I need to destroy the Yerles Army.",
                  _2 = "I've won the war. Now to bring the good news to colonel Gilbert."
               },
               name = "Defense line Lv17"
            },
            guild_fighter_joining = {
               progress = {
                  _0 = function(_1, _2)
                     return ("To join the Fighters Guild, I need to slay %s more %s and talk to the guild guard in Port Kapul.")
                        :format(_1, _2)
                  end
               },
               name = "Joining the Fighters Guild"
            },
            guild_mage_joining = {
               progress = {
                  _0 = function(_1)
                     return ("To join the Mages Guild, I need to gather %s more guild points and talk to the guild guard in Lumiest. I can earn the guild points by collecting ancients books, decrypt them, and put them into the delivery box near the guild guard.")
                        :format(_1)
                  end
               },
               name = "Joining the Mages Guild"
            },
            guild_thief_joining = {
               progress = {
                  _0 = "To join the Thieves Guild, I need to not pay tax for 4 months, that means I'll be a criminal for sure."
               },
               name = "Joining the Thieves Guild"
            },
            kamikaze_attack = {
               progress = {
                  _0 = "Arnord of Port Kapul asked me to help the isolated Palmian 10th regiment from massive Kamikaze attacks. I should prepare and speak to Arnord when ready.",
                  _1 = "I have to hold the battle line to gain time while the Palmian army retreats. A messenger will inform me when it's done.",
                  _2 = "I survived the kamikaze attack. I have to bring the good news to Arnord of Port Kapul."
               },
               name = "Kamikaze attack Lv14"
            },
            little_sister = {
               progress = {
                  _0 = "A strange scientist asked me to bring little sisters to her. To capture a little sister, I need to kill Big daddy first then throw the little ball at her."
               },
               name = "Little sister Lv30"
            },
            mias_dream = {
               progress = {
                  _0 = "Mia of Palmia wants a silver cat, a very rare cat. If I happen to capture one, I should bring it to Mia."
               },
               name = "Mia's dream Lv1"
            },
            minotaur_king = {
               progress = {
                  _0 = "General Conery wants me to hunt the chief of minotaur. The nest is located south of Yowyn.",
                  _1 = "I've killed the chief of minotaur. I should head back to Palmia and speak to General Conery."
               },
               name = "Minotaur king Lv24"
            },
            nightmare = {
               progress = {
                  _0 = "Loyter of Vernis has a dangerous, yet highly profitable job for me. I need to prepare well before talking to him again.",
                  _1 = "I need to eliminate all of the monsters in the test ground.",
                  _2 = "I've survived the nightmare. Now to meet Loyer of Vernis to receive the reward."
               },
               name = "Nightmare Lv50"
            },
            novice_knight = {
               progress = {
                  _0 = "Ainc of Yowyn asked me to help his promotion task. I need to enter the Yeek's dungeon which is located west of Yowyn and kill the chief.",
                  _1 = "I've defeated the chief of Yeek. I should head back to Yowyn and report to Ainc."
               },
               name = "Novice knightLv8"
            },
            pael_and_her_mom = {
               progress = {
                  _0 = "Pael's mother is suffering from Ether Disease and I gave Pael a potion of cure corruption in Noyel. Let's wait until the condition of her mother changes.",
                  _1 = "There's a change in the condition of Pael's mother. I should go check her when I have time."
               },
               name = "Pael and her mom Lv20"
            },
            puppys_cave = {
               progress = {
                  _0 = "Rilian of Vernis asked me to find her puppy named Poppy in the puppy's cave located east of Vernis."
               },
               name = "Puppy's cave Lv4"
            },
            putit_attacks = {
               progress = {
                  _0 = "Miches of Vernis asked me to investigate the house just south of her home.",
                  _1 = "I've wiped out the putit's nest. I have to visit Miches of Vernis to report it."
               },
               name = "Putit attacks Lv6"
            },
            pyramid_trial = {
               progress = {
                  _0 = "I've got a invitation to the pyramid. The pyramid is located north of Port Kapul and it is rumored that it holds great treasure."
               },
               name = "Pyramid trial Lv16"
            },
            guild_fighter_quota = {
               progress = {
                  _0 = function(_1, _2)
                     return ("To raise the rank in the Fighters Guild, I need to slay %s more %s and talk to the guild guard in Port Kapul.")
                        :format(_1, _2)
                  end
               },
               name = "The Fighters Guild quota"
            },
            guild_mage_quota = {
               progress = {
                  _0 = function(_1)
                     return ("To raise the rank in the Mages Guild, you need to gather %s more guild points and talk to the guard in Lumiest. I can earn the guild points by collecting ancients books, decrypt them, and put them into the delivery box near the guild guard.")
                        :format(_1)
                  end
               },
               name = "The Mages Guild quota"
            },
            guild_thief_quota = {
               progress = {
                  _0 = function(_1)
                     return ("To raise the rank in the Thieves Guild, I need to sell stolen goods worth total of %s gold pieces and talk to the guild guard in Derphy.")
                        :format(_1)
                  end
               },
               name = "The Thieves Guild quota"
            },
            rare_books = {
               progress = {
                  _0 = "Renton of Lumiest is looking for the fairy tale books written by Rachael. I should bring it to him if I happen to find one. There're total of 4 books in the series."
               },
               name = "Rare books Lv12"
            },
            red_blossom_in_palmia = {
               progress = {
                  _0 = "Noel of Derphy asked me to set up a bomb in Palmia. I need to place it right on the teddy bear in the inn.",
                  _1 = "I have successfully destroyed Palmia. Now all I need to report back to Noel in Derphy."
               },
               name = "Red blossom in Palmia Lv14"
            },
            sewer_sweeping = {
               progress = {
                  _0 = "Balzak of Lumiest wants me to sweep the entire sewer. I can find the entrance to the sewer around the inn.",
                  _1 = "I've finished sweeping the sewer. I need to report it to Balzak of Lumiest."
               },
               name = "Sewer sweeping Lv23"
            },
            thieves_hideout = {
               progress = {
                  _0 = "Bandits have been stealing things in Vernis. I need to find and destroy their hideout.",
                  _1 = "Those bandits are no more. All I have to do now is bring the news to Shena of Vernis."
               },
               name = "Thieves' hideout Lv2"
            },
            wife_collector = {
               progress = {
                  _0 = "I was asked by Raphael of Port Kapul to bring my wife. What a moron."
               },
               name = "Wife collector Lv3"
            }
         }
      }
   }
}
