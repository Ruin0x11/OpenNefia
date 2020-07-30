return {
   buff = {
      elona = {
         holy_shield = {
            apply = function(_1)
               return ("%s begin%s to shine.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases PV by %s/RES+ fear")
                  :format(_1)
            end,
            name = "Holy Shield"
         },
         mist_of_silence = {
            apply = function(_1)
               return ("%s get%s surrounded by hazy mist.")
                  :format(name(_1), s(_1))
            end,
            description = "Inhibits casting",
            name = "Mist of Silence"
         },
         regeneration = {
            apply = function(_1)
               return ("%s start%s to regenerate.")
                  :format(name(_1), s(_1))
            end,
            description = "Enhances regeneration",
            name = "Regeneration"
         },
         elemental_shield = {
            apply = function(_1)
               return ("%s obtain%s resistance to element.")
                  :format(name(_1), s(_1))
            end,
            description = "RES+ fire,cold,lightning",
            name = "Elemental Shield"
         },
         speed = {
            apply = function(_1)
               return ("%s speed%s up.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases speed by %s")
                  :format(_1)
            end,
            name = "Speed"
         },
         slow = {
            apply = function(_1)
               return ("%s slow%s down.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Decreases speed by %s")
                  :format(_1)
            end,
            name = "Slow"
         },
         hero = {
            apply = function(_1)
               return ("%s feel%s heroic.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases STR,DEX by %s/RES+ fear,confusion")
                  :format(_1)
            end,
            name = "Hero"
         },
         mist_of_frailness = {
            apply = function(_1)
               return ("%s feel%s weak.")
                  :format(name(_1), s(_1))
            end,
            description = "Halves DV and PV",
            name = "Mist of Frailness"
         },
         element_scar = {
            apply = function(_1)
               return ("%s lose%s resistance to element.")
                  :format(name(_1), s(_1))
            end,
            description = "RES- fire,cold,lightning",
            name = "Element Scar"
         },
         holy_veil = {
            apply = function(_1)
               return ("%s receive%s holy protection.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("grants hex protection(power:%s)")
                  :format(_1)
            end,
            name = "Holy Veil"
         },
         nightmare = {
            apply = function(_1)
               return ("%s start%s to suffer.")
                  :format(name(_1), s(_1))
            end,
            description = "RES- mind,nerve",
            name = "Nightmare"
         },
         divine_wisdom = {
            apply = function(_1)
               return ("%s start%s to think clearly.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases LER,MAG by %s, literacy skill by %s")
                  :format(_1[1], _1[2])
            end,
            name = "Divine Wisdom"
         },
         punishment = {
            apply = function(_1)
               return ("%s incur%s the wrath of God.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Decreases speed by %s, PV by %s%%")
                  :format(_1[1], _1[2])
            end,
            name = "Punishment"
         },
         lulwys_trick = {
            apply = function(_1)
               return ("%s repeat%s the name of Lulwy.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases speed by %s")
                  :format(_1)
            end,
            name = "Lulwy's Trick"
         },
         incognito = {
            apply = function(_1)
               return ("%s start%s to disguise.")
                  :format(name(_1), s(_1))
            end,
            description = "Grants new identity",
            name = "Incognito"
         },
         death_word = {
            apply = function(_1)
               return ("%s receive%s death verdict.")
                  :format(name(_1), s(_1))
            end,
            description = "Guaranteed death when the hex ends",
            name = "Death Word"
         },
         boost = {
            apply = function(_1)
               return ("%s gain%s massive power.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases speed by %s/Boosts physical attributes")
                  :format(_1)
            end,
            name = "Boost"
         },
         contingency = {
            apply = function(_1)
               return ("%s set%s up contracts with the Reaper.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("%s%% chances taking a lethal damage heals you instead")
                  :format(_1)
            end,
            name = "Contingency"
         },
         lucky = {
            apply = function(_1)
               return ("%s feel%s very lucky today!")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increase luck by %s.")
                  :format(_1)
            end,
            name = "Luck"
         },
         food_str = {
            apply = function(_1)
               return ("%s feel%s rapid STR growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Strength by %s")
                  :format(_1)
            end,
            name = "Grow Strength"
         },
         food_end = {
            apply = function(_1)
               return ("%s feel%s rapid CON growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Constitution by %s")
                  :format(_1)
            end,
            name = "Grow Constitution"
         },
         food_dex = {
            apply = function(_1)
               return ("%s feel%s rapid DEX growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Dexterity by %s")
                  :format(_1)
            end,
            name = "Grow Dexterity"
         },
         food_per = {
            apply = function(_1)
               return ("%s feel%s rapid PER growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Perception by %s")
                  :format(_1)
            end,
            name = "Grow Perception"
         },
         food_ler = {
            apply = function(_1)
               return ("%s feel%s rapid LER growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Learning by %s")
                  :format(_1)
            end,
            name = "Grow Learning"
         },
         food_wil = {
            apply = function(_1)
               return ("%s feel%s rapid WIL growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Will by %s")
                  :format(_1)
            end,
            name = "Grow Will"
         },
         food_mag = {
            apply = function(_1)
               return ("%s feel%s rapid MAG growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Magic by %s")
                  :format(_1)
            end,
            name = "Grow Magic"
         },
         food_chr = {
            apply = function(_1)
               return ("%s feel%s rapid CHR growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Charisma by %s")
                  :format(_1)
            end,
            name = "Grow Charisma"
         },
         food_spd = {
            apply = function(_1)
               return ("%s feel%s rapid SPD growth.")
                  :format(name(_1), s(_1))
            end,
            description = function(_1)
               return ("Increases the growth rate Speed by %s")
                  :format(_1)
            end,
            name = "Grow Speed"
         }
      }
   }
}
