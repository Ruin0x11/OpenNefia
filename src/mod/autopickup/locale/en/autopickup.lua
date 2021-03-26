return {
   autopickup = {
      act = {
         destroy = {
            prompt = function(_1) return ("Destroy %s?"):format(_1) end,
            execute = function(_1) return ("%s was destroyed."):format(_1) end,
         },
         pick_up = {
            prompt = function(_1) return ("Pick up %s?"):format(_1) end,
         },
      },
      predicate = {
         _ = {
            autopickup = {
               all = {
                  identifier = "all"
               },
               unknown = {
                  identifier = "unknown"
               },
               identify_stage_1 = {
                  identifier = "identify stage 1"
               },
               identify_stage_2 = {
                  identifier = "identify stage 2"
               },
               identify_stage_3 = {
                  identifier = "identify stage 3"
               },
               worthless = {
                  identifier = "worthless"
               },
               rotten = {
                  identifier = "rotten"
               },
               zombie = {
                  identifier = "zombie"
               },
               dragon = {
                  identifier = "dragon's"
               },
               empty = {
                  identifier = "empty"
               },
               bad = {
                  identifier = "bad"
               },
               good = {
                  identifier = "good"
               },
               great = {
                  identifier = "great"
               },
               miracle = {
                  identifier = "miracle"
               },
               godly = {
                  identifier = "godly"
               },
               special = {
                  identifier = "special"
               },
               precious = {
                  identifier = "precious"
               },
               blessed = {
                  identifier = "blessed"
               },
               cursed = {
                  identifier = "cursed"
               },
               doomed = {
                  identifier = "doomed"
               },
               alive = {
                  identifier = "alive"
               },
            }
         }
      },
      target = {
         _ = {
            autopickup = {
               item = {
                  identifier = "item",
               },
               equipment = {
                  identifier = "equipment",
               },
               melee_weapon = {
                  identifier = "melee weapon"
               },
               helm = {
                  identifier = "helm"
               },
               shield = {
                  identifier = "shield"
               },
               armor = {
                  identifier = "armor"
               },
               boots = {
                  identifier = "boots"
               },
               belt = {
                  identifier = "belt"
               },
               cloak = {
                  identifier = "cloak"
               },
               gloves = {
                  identifier = "gloves"
               },
               ranged_weapon = {
                  identifier = "ranged weapon"
               },
               ammo = {
                  identifier = "ammo"
               },
               ring = {
                  identifier = "ring"
               },
               necklace = {
                  identifier = "necklace"
               },
               potion = {
                  identifier = "potion"
               },
               scroll = {
                  identifier = "scroll"
               },
               spellbook = {
                  identifier = "spellbook"
               },
               book = {
                  identifier = "book"
               },
               rod = {
                  identifier = "rod"
               },
               food = {
                  identifier = "food"
               },
               tool = {
                  identifier = "tool"
               },
               furniture = {
                  identifier = "furniture"
               },
               well = {
                  identifier = "well"
               },
               altar = {
                  identifier = "altar"
               },
               remains = {
                  identifier = "remains"
               },
               junk = {
                  identifier = "junk"
               },
               gold_piece = {
                  identifier = "gold piece"
               },
               platinum_coin = {
                  identifier = "platinum coin"
               },
               chest = {
                  identifier = "chest"
               },
               ore = {
                  identifier = "ore"
               },
               tree = {
                  identifier = "tree"
               },
               travelers_food = {
                  identifier = "traveler's food"
               },
               cargo = {
                  identifier = "cargo"
               },
            }
         }
      }
   }
}
