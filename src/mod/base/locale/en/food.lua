return {
  food = {
    anorexia = {
      develops = function(_1)
  return ("%s develop%s anorexia.")
  :format(name(_1), s(_1))
end,
      recovers_from = function(_1)
  return ("%s manage%s to recover from anorexia.")
  :format(name(_1), s(_1))
end
    },
    cook = function(_1, _2, _3)
  return ("You cook %s with %s and make %s.")
  :format(_1, itemname(_2, 1), itemname(_3, 1))
end,
    eat_status = {
      bad = function(_1)
  return ("%s feel%s bad.")
  :format(name(_1), s(_1))
end,
      cursed_drink = function(_1)
  return ("%s feel%s grumpy.")
  :format(name(_1), s(_1))
end,
      good = function(_1)
  return ("%s feel%s good.")
  :format(name(_1), s(_1))
end
    },
    eating_message = {
      bloated = { "Phew! You are pretty bloated.", "You've never eaten this much before!", "Your stomach is unbelievably full!" },
      hungry = { "You are still a bit hungry.", "Not enough...", "You want to eat more.", "Your stomach is still somewhat empty." },
      normal = { "You can eat more.", "You pat your stomach.", "You satisfied your appetite a little." },
      satisfied = { "You are satisfied!", "This hearty meal has filled your stomach.", "You really ate!", "You pat your stomach contentedly." },
      starving = { "It didn't help you from starving!", "It prolonged your death for seconds.", "Empty! Your stomach is still empty!" },
      very_hungry = { "No, it was not enough at all.", "You still feel very hungry.", "You aren't satisfied." }
    },
    effect = {
      ability = {
        deteriorates = function(_1, _2)
  return ("%s%s %s deteriorates.")
  :format(name(_1), his_owned(_1), _2)
end,
        develops = function(_1, _2)
  return ("%s%s %s develops.")
  :format(name(_1), his_owned(_1), _2)
end
      },
      bomb_fish = function(_1, _2)
  return ("「Ugh-Ughu」 %s spew%s up %s.")
  :format(name(_1), s(_1), itemname(_2, 1))
end,
      boring = { "It doesn't taste awful but...", "Very boring food." },
      corpse = {
        alien = function(_1)
  return ("Something gets into %s%s body.")
  :format(name(_1), his_owned(_1))
end,
        at = "You dare to eat @...",
        beetle = "Mighty taste!",
        calm = function(_1)
  return ("Eating this brings %s inner peace.")
  :format(name(_1))
end,
        cat = "How can you eat a cat!!",
        chaos_cloud = function(_1)
  return ("%s %s shaken by a chaotic power.")
  :format(name(_1), is(_1))
end,
        cupid_of_love = function(_1)
  return ("%s feel%s love!")
  :format(name(_1), s(_1))
end,
        deformed_eye = "It tastes really, really strange.",
        ether = function(_1)
  return ("Ether corrupts %s%s body.")
  :format(name(_1), his_owned(_1))
end,
        ghost = "This food is good for your will power.",
        giant = "This food is good for your endurance.",
        grudge = function(_1)
  return ("Something is wrong with %s%s stomach...")
  :format(name(_1), his_owned(_1))
end,
        guard = "Guards hate you.",
        holy_one = function(_1)
  return ("%s feel%s as %s %s been corrupted.")
  :format(name(_1), s(_1), he(_1), have(_1))
end,
        horse = "A horsemeat! It's nourishing",
        imp = "This food is good for your magic.",
        insanity = "Sheer madness!",
        iron = function(_1)
  return ("It's too hard! %s%s stomach screams.")
  :format(name(_1), his_owned(_1))
end,
        lightning = function(_1)
  return ("%s%s nerve is damaged.")
  :format(name(_1), his_owned(_1))
end,
        mandrake = function(_1)
  return ("%s %s magically stimulated.")
  :format(name(_1), is(_1))
end,
        poisonous = "Argh! It's poisonous!",
        putit = function(_1)
  return ("%s%s skin becomes smooth.")
  :format(name(_1), his_owned(_1))
end,
        quickling = function(_1)
  return ("Wow, %s speed%s up!")
  :format(name(_1), s(_1))
end,
        rotten_one = "Of course, it's rotten! Urgh...",
        strength = "This food is good for your strength.",
        troll = "A troll meat. This must be good for your body.",
        vesda = function(_1)
  return ("%s%s body burns up for a second.")
  :format(name(_1), his_owned(_1))
end
      },
      fortune_cookie = function(_1)
  return ("%s read%s the paper fortune.")
  :format(name(_1), s(_1))
end,
      herb = {
        alraunia = "Your hormones are activated.",
        curaria = "This herb invigorates you.",
        mareilon = "You feel magical power springs up inside you.",
        morgia = "You feel might coming through your body.",
        spenseweed = "You feel as your sense is sharpened."
      },
      hero_cheese = "The food is a charm!",
      human = {
        delicious = "Delicious!",
        dislike = "Eeeek! It's human flesh!",
        like = "It's your favorite human flesh!",
        would_have_rather_eaten = "You would've rather eaten human flesh."
      },
      little_sister = function(_1)
  return ("%s evolve%s.")
  :format(name(_1), s(_1))
end,
      poisoned = {
        dialog = { "Gyaaaaa...!", "Ugh!" },
        text = function(_1)
  return ("It's poisoned! %s writhe%s in agony!")
  :format(name(_1), s(_1))
end
      },
      powder = "It tastes like...powder...",
      quality = {
        bad = { "Boy, it gives your stomach trouble!", "Ugh! Yuk!", "Awful taste!!" },
        delicious = { "Wow! Terrific food!", "Yummy! Absolutely yummy!", "It tasted like seventh heaven!" },
        good = { "It tasted good.", "Decent meal." },
        great = { "Delicious!", "Gee what a good taste!", "It tasted pretty good!" },
        so_so = { "Uh-uh, the taste is so so.", "The taste is not bad." }
      },
      raw = "Er...this needs to be cooked.",
      raw_glum = function(_1)
  return ("%s looks glum.")
  :format(name(_1))
end,
      raw_meat = "Ugh...Raw meat...",
      rotten = "Ugh! Rotten food!",
      sisters_love_fueled_lunch = function(_1)
  return ("%s%s heart is warmed.")
  :format(name(_1), his_owned(_1))
end,
      spiked = {
        other = { function(_1)
  return ("%s gasps, \"I f-feel...strange...\"")
  :format(name(_1))
end, function(_1)
  return ("%s gasps \"Uh..uh..What is this feeling...\"")
  :format(name(_1))
end },
        self = "You are excited!"
      }
    },
    hunger_status = {
      hungry = { "You are getting hungry.", "You feel hungry.", "Now what shall I eat?" },
      starving = { "You are starving!", "You are almost dead from hunger." },
      very_hungry = { "Your hunger makes you dizzy.", "You have to eat something NOW." }
    },
    mochi = {
      chokes = function(_1)
  return ("%s choke%s on mochi!")
  :format(name(_1), s(_1))
end,
      dialog = "Mm-ghmm"
    },
    names = {
       elona = {
          meat = {
             _1 = function(_1)
                return ("grotesque %s meat")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("charred %s meat")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("roast %s")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("deep fried %s")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("skewer grilled %s")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("%s croquette")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("%s hamburger")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("%s cutlet")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s steak")
                   :format(_1)
             end,
             default_origin = "beast"
          },
          vegetable = {
             _1 = function(_1)
                return ("kitchen refuse %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("smelly %s")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("%s salad")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("fried %s")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("%s roll")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("%s tempura")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("%s gratin")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("meat and %s stew")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s curry")
                   :format(_1)
             end,
             default_origin = "vegetable"
          },
          fruit = {
             _1 = function(_1)
                return ("dangerous %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("doubtful %s")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("%s jelly salad")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("%s pudding")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("%s sherbet")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("%s ice cream")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("%s crepe")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("%s fruit cake")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s grand parfait")
                   :format(_1)
             end,
             default_origin = "fruit"
          },
          sweet = {
             _1 = function(_1)
                return ("collapsed %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("nasty %s")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("%s cookie")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("%s jelly")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("%s pie")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("%s bun")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("%s cream puff")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("%s cake")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s sachertorte")
                   :format(_1)
             end,
             default_origin = "candy"
          },
          pasta = {
             _1 = function(_1)
                return ("risky %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("exhausted %s")
                   :format(_1)
             end,
             _3 = "salad pasta",
             _4 = "udon",
             _5 = "soba",
             _6 = "peperoncino",
             _7 = "carbonara",
             _8 = "ramen",
             _9 = "meat spaghetti",
             default_origin = "noodle"
          },
          fish = {
             _1 = function(_1)
                return ("leftover %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("bony %s")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("fried %s")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("stewed %s")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("%s soup")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("%s tempura")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("%s sausage")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("%s sashimi")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s sushi")
                   :format(_1)
             end,
             default_origin = "fish"
          },
          bread = {
             _1 = function(_1)
                return ("fearsome %s")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("hard %s")
                   :format(_1)
             end,
             _3 = "walnut bread",
             _4 = "apple pie",
             _5 = "sandwich",
             _6 = "croissant",
             _7 = "croquette sandwich",
             _8 = "chocolate babka",
             _9 = "melon flavored bread",
             default_origin = "bread"
          },
          egg = {
             _1 = function(_1)
                return ("grotesque %s egg")
                   :format(_1)
             end,
             _2 = function(_1)
                return ("overcooked %s egg")
                   :format(_1)
             end,
             _3 = function(_1)
                return ("fried %s egg")
                   :format(_1)
             end,
             _4 = function(_1)
                return ("%s egg toast")
                   :format(_1)
             end,
             _5 = function(_1)
                return ("soft boiled %s egg")
                   :format(_1)
             end,
             _6 = function(_1)
                return ("soup with %s egg")
                   :format(_1)
             end,
             _7 = function(_1)
                return ("mature %s cheese")
                   :format(_1)
             end,
             _8 = function(_1)
                return ("%s cheese cake")
                   :format(_1)
             end,
             _9 = function(_1)
                return ("%s omlet")
                   :format(_1)
             end,
             default_origin = "animal"
          }
       }
    },
    not_affected_by_rotten = function(_1)
       return ("But %s%s stomach isn't affected.")
          :format(name(_1), his_owned(_1))
    end,
    passed_rotten = { "Yuck!!", "....!!", "W-What...", "Are you teasing me?", "You fool!" },
    spits_alien_children = function(_1)
       return ("%s spit%s alien children from %s body!")
          :format(name(_1), s(_1), his(_1))
    end,
    vomits = function(_1)
       return ("%s vomit%s.")
          :format(name(_1), s(_1))
    end
  }
}
