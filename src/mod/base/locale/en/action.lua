return {
   action = {
      ally_joins = {
         party_full = "Your party is already full. You can't invite someone anymore.",
         success = function(_1)
            return ("%s join%s your party!")
               :format(basename(_1), s(_1))
         end
      },
      ammo = {
         current = "Current Ammo Type:",
         is_not_capable = function(_1)
            return ("%s isn't capable of changing ammos.")
               :format(itemname(_1))
         end,
         need_to_equip = "You need to equip an ammo.",
         normal = "Normal",
         unlimited = "Unlimited"
      },
      angband = {
         at = "Ahhhhh!!",
         q = "What...",
         y = "No...no..."
      },
      autopick = {
         reloaded_autopick_file = "Reloaded autopick file."
      },
      backpack_squashing = "Your backpack is squashing you!",
      bash = {
         air = function(_1)
            return ("%s bash%s up the air.")
               :format(name(_1), s(_1, true))
         end,
         choked = {
            dialog = "You saved me!",
            execute = function(_1, _2)
               return ("%s bash%s up %s at full power.")
                  :format(name(_1), s(_1, true), name(_2))
            end,
            spits = function(_1)
               return ("%s spit%s mochi.")
                  :format(name(_1), s(_1))
            end
         },
         disturbs_sleep = function(_1, _2)
            return ("%s disturb%s %s sleep.")
               :format(name(_1), s(_1), his(_2))
         end,
         door = {
            cracked = "The door is cracked a bit.",
            destroyed = "You bash up the door. The door is destroyed.",
            execute = "You bash up the door.",
            hurt = function(_1)
               return ("%s hurt%s %s muscle.")
                  :format(name(_1), s(_1), his(_1))
            end,
            jail = "As might be expected, the door of the Jail is hard."
         },
         execute = function(_1, _2)
            return ("%s bash%s up %s.")
               :format(name(_1), s(_1, true), name(_2))
         end,
         prompt = "Which direction do you want to bash? ",
         shatters_pot = function(_1)
            return ("%s shatter%s the pot.")
               :format(name(_1), s(_1))
         end,
         tree = {
            execute = function(_1)
               return ("You throw your weight against %s.")
                  :format(itemname(_1))
            end,
            falls_down = function(_1)
               return ("%s falls down from the tree.")
                  :format(_1)
            end,
            no_fruits = "It seems there are no fruits left on the tree."
         }
      },
      cannot_do_in_global = "You can't do that while you're in a global area.",
      cast = {
         confused = function(_1)
            return ("%s try%s to cast a spell in confusion.")
               :format(name(_1), s(_1))
         end,
         fail = function(_1)
            return ("%s fail%s to cast a spell.")
               :format(name(_1), s(_1))
         end,
         other = function(_1, _2)
            return ("%s%s")
               :format(name(_1), _2)
         end,
         overcast_warning = "You are going to over-cast the spell. Are you sure?",
         self = function(_1, _2)
            return ("%s cast%s")
               :format(name(_1), _2)
         end,
         silenced = "The mist of silence interrupts a spell."
      },
      close = {
         blocked = "There's something on the floor.",
         execute = function(_1)
            return ("%s close%s the door.")
               :format(name(_1), s(_1))
         end,
         nothing_to_close = "There's nothing to close."
      },
      day_breaks = "Day breaks.",
      dig = {
         prompt = "Which direction do you want to dig? ",
         too_exhausted = "You are too exhausted to do that."
      },
      dip = {
         execute = function(_1, _2)
            return ("You dip %s into %s.")
               :format(itemname(_1), itemname(_2, 1))
         end,
         result = {
            bait_attachment = function(_1, _2)
               return ("You bait %s with %s.")
                  :format(itemname(_1), itemname(_2, 1))
            end,
            becomes_blessed = function(_1)
               return ("%s shine%s silvery.")
                  :format(itemname(_1), s(_1))
            end,
            becomes_cursed = function(_1)
               return ("%s %s wrapped by a dark aura.")
                  :format(itemname(_1), is(_1))
            end,
            blessed_item = function(_1, _2)
               return ("You shower %s on %s.")
                  :format(itemname(_1), itemname(_2, 1))
            end,
            dyeing = function(_1)
               return ("You dye %s.")
                  :format(itemname(_1))
            end,
            empty_bottle_shatters = "You hear the sound of the empty bottle shatters.",
            gains_acidproof = function(_1)
               return ("%s gain%s acidproof.")
                  :format(itemname(_1), s(_1))
            end,
            gains_fireproof = function(_1)
               return ("%s gain%s fireproof.")
                  :format(itemname(_1), s(_1))
            end,
            good_idea_but = "A good idea! But...",
            holy_well_polluted = "The holy well is polluted.",
            love_food = {
               grin = "You grin.",
               guilty = "You kind of feel guilty...",
               made = "You made aphrodisiac food! "
            },
            natural_potion = "You draw water from the well into the empty bottle.",
            natural_potion_drop = "Oops! You drop the empty bottle into the well...",
            natural_potion_dry = function(_1)
               return ("%s is dry.")
                  :format(itemname(_1))
            end,
            poisoned_food = "You grin.",
            put_on = function(_1, _2)
               return ("You put %s on %s.")
                  :format(itemname(_2, 1), itemname(_1))
            end,
            snow_melts = {
               blending = "But the snow just melts.",
               dip = "Snow just melts."
            },
            well_dry = function(_1)
               return ("%s is completely dry.")
                  :format(itemname(_1))
            end,
            well_refill = function(_1, _2)
               return ("You throw %s into %s.")
                  :format(itemname(_1), itemname(_2, 1))
            end,
            well_refilled = function(_1)
               return ("%s shines for a moment.")
                  :format(itemname(_1))
            end
         },
         rots = function(_1)
            return ("%s rots.")
               :format(itemname(_1))
         end,
         rusts = function(_1)
            return ("%s rusts.")
               :format(itemname(_1))
         end,
         unchanged = function(_1)
            return ("%s remains unchanged.")
               :format(itemname(_1))
         end,
         you_get = function(_1)
            return ("You get %s.")
               :format(itemname(_1, 1))
         end
      },
      drink = {
         potion = function(_1, _2)
            return ("%s drink%s %s.")
               :format(name(_1), s(_1), itemname(_2, 1))
         end,
         well = {
            completely_dried_up = function(_1)
               return ("%s has completely dried up.")
                  :format(itemname(_1))
            end,
            draw = function(_1, _2)
               return ("%s draw%s water from %s.")
                  :format(name(_1), s(_1), _2)
            end,
            dried_up = function(_1)
               return ("%s has dried up.")
                  :format(itemname(_1))
            end,
            effect = {
               default = "Phew, fresh water tastes good.",
               falls = {
                  dialog = function(_1)
                     return ("%s yells, \"G-Give me your hands!\"")
                        :format(name(_1))
                  end,
                  floats = function(_1)
                     return ("Soon %s floats up to the surface.")
                        :format(he(_1))
                  end,
                  text = function(_1)
                     return ("%s falls in the well!")
                        :format(name(_1))
                  end
               },
               finds_gold = function(_1)
                  return ("%s find%s some gold pieces in water.")
                     :format(name(_1), s(_1))
               end,
               monster = "Something comes out from the well!",
               pregnancy = function(_1)
                  return ("%s swallow%s something bad.")
                     :format(name(_1), s(_1))
               end,
               wish_too_frequent = "You feel as a stroke of good fortune passed by."
            },
            is_dry = function(_1)
               return ("%s is dry.")
                  :format(_1)
            end
         }
      },
      drop = {
         execute = function(_1)
            return ("You drop %s.")
               :format(_1)
         end,
         too_many_items = "The place is too crowded. You can't drop stuff anymore.",
         water_is_blessed = "The water is blessed."
      },
      eat = {
         snatches = function(_1, _2)
            return ("%s snatch%s %s%s food.")
               :format(name(_1), s(_1), name(_2), his_owned(_2))
         end
      },
      equip = {
         two_handed = {
            fits_well = function(_1)
               return ("%s fits well for two-hand fighting style.")
                  :format(itemname(_1))
            end,
            too_heavy = function(_1)
               return ("%s is too heavy for two-wield fighting style.")
                  :format(itemname(_1))
            end,
            too_heavy_other_hand = function(_1)
               return ("%s is too heavy for two-wield fighting style.")
                  :format(itemname(_1))
            end,
            too_heavy_when_riding = function(_1)
               return ("%s is too heavy to use when riding.")
                  :format(itemname(_1))
            end,
            too_light = function(_1)
               return ("%s is too light for two-hand fighting style.")
                  :format(itemname(_1))
            end
         },
         you_change = "You change your equipment."
      },
      exit = {
         cannot_save_in_usermap = "You can't save the game in a user made map. Exit anyway?",
         choices = {
            cancel = "Cancel",
            exit = "Exit",
            game_setting = "Game Setting",
            return_to_title = "Return to Title"
         },
         prompt = "Do you want to save the game and exit?",
         saved = "Your game has been saved successfully.",
         you_close_your_eyes = "You close your eyes and peacefully fade away. (Hit any key to exit)"
      },
      exit_map = {
         burdened_by_cargo = "The weight of your cargo burdens your traveling speed.",
         cannot_enter_jail = "The guards turn you away from the jail.",
         delivered_to_your_home = "You were delivered to your home.",
         entered = function(_1)
            return ("You entered %s.")
               :format(_1)
         end,
         gate = {
            need_network = "You have to turn on network setting.",
            step_into = "You stepped into the gate. The gate disappears."
         },
         it_is_hot = "It's hot!",
         larna = "You reached the town of Larna.",
         left = function(_1)
            return ("You left %s.")
               :format(_1)
         end,
         mountain_pass = "You entered the Mountain Pass.",
         no_invitation_to_pyramid = "You don't have an invitation.",
         not_permitted = "You are not permitted to explore this dungeon.",
         returned_to = function(_1)
            return ("You returned to %s.")
               :format(_1)
         end,
         surface = {
            left = function(_1)
               return ("You left the surface of %s.")
                  :format(_1)
            end,
            returned_to = function(_1)
               return ("You returned to the surface of %s")
                  :format(_1)
            end
         }
      },
      gatcha = {
         do_not_have = function(_1)
            return ("You don't have %s.")
               :format(_1)
         end,
         prompt = function(_1)
            return ("Pay %s to gasha-gasha?")
               :format(_1)
         end
      },
      get = {
         air = "You grasp at the air.",
         building = {
            prompt = "Really remove this building?",
            remove = "You remove the building."
         },
         cannot_carry = "You can't carry it.",
         not_owned = { "It's not your property.", "You can't just take it.", "It's not yours." },
         plant = {
            dead = "You nip a dead plant.",
            young = "You nip a young plant."
         },
         snow = "You rake up a handful of snow."
      },
      hit_key_for_help = "Hit ? key to display help.",
      interact = {
         change_tone = {
            default_tone = "Default Tone",
            hint = "Enter [Change Tone] ",
            is_somewhat_different = function(_1)
               return ("%s is somewhat different.")
                  :format(name(_1))
            end,
            prompt = function(_1)
               return ("What sentence should %s learn? ")
                  :format(name(_1))
            end,
            title = "Tone of Voice",
            tone_title = "Title"
         },
         choices = {
            appearance = "Appearance",
            attack = "Attack",
            bring_out = "Bring Out",
            change_tone = "Change Tone",
            give = "Give",
            info = "Info",
            inventory = "Inventory",
            name = "Name",
            release = "Release",
            talk = "Talk",
            teach_words = "Teach Words"
         },
         choose = "Choose the direction of the target.",
         name = {
            cancel = "You changed your mind.",
            prompt = function(_1)
               return ("What do you want to call %s? ")
                  :format(him(_1))
            end,
            you_named = function(_1)
               return ("You named %s %s.")
                  :format(him(_1), basename(_1))
            end
         },
         prompt = function(_1)
            return ("What action do you want to perform to %s? ")
               :format(him(_1))
         end,
         release = function(_1)
            return ("You release %s.")
               :format(name(_1))
         end
      },
      look = {
         find_nothing = "You look around and find nothing.",
         target = function(_1)
            return ("You target %s.")
               :format(name(_1))
         end,
         target_ground = "You target the ground."
      },
      melee = {
         shield_bash = function(_1, _2)
            return ("%s bash%s %s with %s shield.")
               :format(name(_1), s(_1, true), name(_2), his(_1))
         end
      },
      move = {
         carry_too_much = "You carry too much to move!",
         confused = "*bump*",
         displace = {
            dialog = { "Oops, sorry.", "Watch it." },
            text = function(_1)
               return ("You displace %s.")
                  :format(name(_1))
            end
         },
         drunk = "*stagger*",
         feature = {
            material = {
               mining = "You can collect materials from the mining spot here.",
               plants = "You can collect materials from plants here.",
               remains = "You can collect materials from the remains lying here.",
               spot = "You can search this location to collect some materials.",
               spring = "You can collect materials from the spring here."
            },
            seed = {
               growth = {
                  bud = function(_1)
                     return ("A %s bud is growing.")
                        :format(_1)
                  end,
                  seed = function(_1)
                     return ("A %s seed is planted.")
                        :format(_1)
                  end,
                  tree = function(_1)
                     return ("A %s tree has bore a lot of fruit.")
                        :format(_1)
                  end,
                  withered = function(_1)
                     return ("A %s tree has withered...")
                        :format(_1)
                  end
               },
               type = {
                  artifact = "artifact",
                  fruit = "fruit",
                  gem = "gem",
                  herb = "herb",
                  magic = "magic",
                  strange = "strange",
                  vegetable = "vegetable"
               }
            },
            stair = {
               down = "There is a stair leading downwards here.",
               up = "There is a stair leading upwards here."
            }
         },
         global = {
            ambush = {
               message = function(_1, _2)
                  return ("Ambush! (Distance from nearest town:%s Enemy strength:%s)")
                     :format(_1, _2)
               end,
               rank = {
                  dragon = "Dragon Rank",
                  drake = "Drake Rank",
                  grizzly_bear = "Grizzly Bear Rank",
                  lich = "Lich Rank",
                  orc = "Orc Rank",
                  putit = "Putit Rank"
               },
            },
            diastrophism = "A sudden diastrophism hits the continent.",
            nap = "You take a nap.",
            weather = {
               heavy_rain = {
                  message = { "It's raining heavily. You lose your way.", "You can't see a thing!" },
                  sound = { "*drip*", "*sip*", "*drizzle*", "*splash*", "*kissh*" }
               },
               snow = {
                  eat = "You are too hungry. You chow down snow.",
                  message = { "Snow delays your travel.", "You are caught in a snowdrift.", "It's hard to walk on a snowy road." },
                  sound = { " *kisssh*", "*thudd*", "*siz*", "*clump*", "*skritch*" }
               }
            }
         },
         interrupt = function(_1)
            return ("%s stares in your face.")
               :format(name(_1))
         end,
         item_on_cell = {
            building = function(_1)
               return ("%s is constructed here.")
                  :format(_1)
            end,
            item = function(_1)
               return ("You see %s here.")
                  :format(_1)
            end,
            more_than_three = function(_1)
               return ("There are %s items lying here.")
                  :format(_1)
            end,
            not_owned = function(_1)
               return ("You see %s placed here.")
                  :format(_1)
            end
         },
         leave = {
            abandoning_quest = "Warning! You are going to abandon your current quest.",
            prompt = function(_1)
               return ("Do you want to leave %s? ")
                  :format(_1)
            end
         },
         sense_something = "You sense something under your foot.",
         trap = {
            activate = {
               blind = "Gallons of ink spreads.",
               confuse = "Smelly gas spreads.",
               mine = "*kabooom*",
               paralyze = "Stimulative gas spreads.",
               poison = "Poisonous gas spreads.",
               sleep = "Sleeping gas spreads.",
               spears = {
                  target_floating = function(_1)
                     return ("But they don't reach %s.")
                        :format(name(_1))
                  end,
                  text = "Several spears fly out from the ground."
               },
               text = function(_1)
                  return ("%s activate%s a trap!")
                     :format(name(_1), s(_1))
               end
            },
            disarm = {
               dismantle = "You dismantle the trap.",
               fail = "You fail to disarm the trap.",
               succeed = "You disarm the trap."
            },
            evade = function(_1)
               return ("%s evade%s a trap.")
                  :format(name(_1), s(_1))
            end
         },
         twinkle = "*twinkle*",
         walk_into = function(_1)
            return ("You walk into %s.")
               :format(_1)
         end
      },
      new_day = "A day passes and a new day begins.",
      npc = {
         arena = { "Come on!", "More blood!", "Beat'em!", "Use your brain!", "Wooooo!", "Go go!", "Good fighting.", "Yeeee!" },
         drunk = {
            annoyed = {
               dialog = "Your time is over, drunk!",
               text = function(_1)
                  return ("%s is pretty annoyed with the drunkard.")
                     :format(name(_1))
               end
            },
            dialog = { "Have a drink baby.", "What are you looking at?", "I ain't drunk.", "Let's have fun." },
            gets_the_worse = function(_1, _2)
               return ("%s gets the worse for drink and catches %s.")
                  :format(name(_1), name(_2))
            end
         },
         is_busy_now = function(_1)
            return ("%s %s busy now.")
               :format(name(_1), is(_1))
         end,
         leash = {
            dialog = { "Ouch!", "Stop it!" },
            untangle = function(_1)
               return ("%s untangle%s the leash.")
                  :format(name(_1), s(_1))
            end
         },
         sand_bag = { "Release me now.", "I won't forget this.", "Hit me!" }
      },
      offer = {
         claim = function(_1)
            return ("%s claims the empty altar.")
               :format(_1)
         end,
         do_not_believe = "You don't believe in God.",
         execute = function(_1, _2)
            return ("You put %s on the altar and mutter the name of %s.")
               :format(itemname(_1), _2)
         end,
         result = {
            best = function(_1)
               return ("%s shine%s all aruond and dissappear%s.")
                  :format(itemname(_1), s(_1), s(_1))
            end,
            good = function(_1)
               return ("%s for a moment and disappear%s. A three-leaved falls from the altar.")
                  :format(itemname(_1), s(_1))
            end,
            okay = function(_1)
               return ("%s shine%s for a moment and disappear%s.")
                  :format(itemname(_1), s(_1), s(_1))
            end,
            poor = function(_1)
               return ("%s disappear%s.")
                  :format(itemname(_1), s(_1))
            end
         },
         take_over = {
            attempt = function(_1, _2)
               return ("Strange fogs surround all over the place. You see shadows of %s and %s make a fierce dance.")
                  :format(_1, _2)
            end,
            fail = function(_1)
               return ("%s keeps the altar.")
                  :format(_1)
            end,
            shadow = "The shadow of your god slowly gets bolder.",
            succeed = function(_1)
               return ("%s takes over the altar.")
                  :format(_1)
            end
         }
      },
      open = {
         door = {
            fail = function(_1)
               return ("%s fail%s to open the door.")
                  :format(name(_1), s(_1))
            end,
            succeed = function(_1)
               return ("%s open%s the door.")
                  :format(name(_1), s(_1))
            end
         },
         empty = "It's empty!",
         goods = function(_1)
            return ("Several quality goods spread out from %s.")
               :format(itemname(_1))
         end,
         new_year_gift = {
            cursed_letter = "You find a cursed letter inside.",
            ring = "*ring ring ring*",
            something_inside = "There's something inside the pack.",
            something_jumps_out = "Something jumps out from the pack!",
            trap = "It's trap! The gift ignites.",
            wonderful = "This is truly a wonderful gift!",
            younger_sister = "The pack contains your younger sister!"
         },
         only_in_home = "You can only use it at your home.",
         only_in_shop = "You can only use it at your shop",
         shackle = {
            dialog = "Moyer yells, \"You idiot!\"",
            text = "You unlock the shackle."
         },
         text = function(_1)
            return ("You open %s.")
               :format(itemname(_1))
         end
      },
      pick_up = {
         do_you_want_to_remove = function(_1)
            return ("Do you want to remove %s?")
               :format(itemname(_1))
         end,
         execute = function(_1, _2)
            return ("%s pick%s up %s.")
               :format(name(_1), s(_1), _2)
         end,
         poison_drips = "Poison drips from your hands.",
         put_in_container = function(_1)
            return ("You put %s in the container.")
               :format(_1)
         end,
         shopkeepers_inventory_is_full = "Shopkeeper's inventory is full.",
         thieves_guild_quota = function(_1)
            return ("You still need to sell stuff worth %s gold pieces in order to advance ranks in the Thieves Guild.")
               :format(_1)
         end,
         used_by_mount = function(_1)
            return ("%s %s using it.")
               :format(name(_1), is(_1))
         end,
         you_absorb_magic = function(_1)
            return ("You absorb magic from %s.")
               :format(itemname(_1))
         end,
         you_buy = function(_1)
            return ("You buy %s.")
               :format(_1)
         end,
         you_sell = function(_1)
            return ("You sell %s.")
               :format(_1)
         end,
         you_sell_stolen = function(_1)
            return ("You sell %s.(Stolen item sold) ")
               :format(_1)
         end,
         your_inventory_is_full = "Your inventory is full."
      },
      plant = {
         cannot_plant_it_here = "You can't plant it here.",
         execute = function(_1)
            return ("You plant %s.")
               :format(_1)
         end,
         harvest = function(_1)
            return ("You harvest %s.")
               :format(_1)
         end,
         new_plant_grows = "A new plant grows!",
         on_field = function(_1)
            return ("You plant %s on the field.")
               :format(_1)
         end
      },
      playtime_report = function(_1)
         return ("You have been playing Elona for %s hour%s.")
            :format(_1, s(_1))
      end,
      quicksave = " *Save* ",
      ranged = {
         equip = {
            need_ammo = "You need to equip ammos or arrows.",
            need_weapon = "You need to equip a firing weapon.",
            wrong_ammo = "You're equipped with wrong type of ammos."
         },
         load_normal_ammo = "You load normal ammo.",
         no_target = "You find no target."
      },
      read = {
         book = {
            already_decoded = "You already have decoded the book.",
            book_of_rachel = "It's a lovely fairy tale written by Rachel.",
            falls_apart = function(_1)
               return ("%s falls apart.")
                  :format(_1)
            end,
            finished_decoding = function(_1)
               return ("You finished decoding %s!")
                  :format(_1)
            end,
            not_interested = "You are not interested in this book. Do you want to read it anyway? ",
            void_permit = "According to the card, you are permitted to explore the void now."
         },
         cannot_see = function(_1)
            return ("%s can see nothing.")
               :format(name(_1))
         end,
         recipe = {
            info = "You can add a recipe of the item you previously created.(Not implemented yet)",
            learned = "You learned the recipe!"
         },
         scroll = {
            dimmed_or_confused = function(_1)
               return ("%s stagger%s.")
                  :format(name(_1), s(_1))
            end,
            execute = function(_1, _2)
               return ("%s read%s %s.")
                  :format(name(_1), s(_1), _2)
            end
         }
      },
      really_attack = function(_1)
         return ("Really attack %s?")
            :format(name(_1))
      end,
      search = {
         crystal = {
            close = "The air around you is filled with strained silence.",
            far = "Still, still lying far ahead.",
            normal = "Your heart starts beating in your chest.",
            sense = "You sense a blue crystal lying somewhere in this area."
         },
         discover = {
            hidden_path = "You discover a hidden path.",
            trap = "You discover a trap."
         },
         execute = "You search the surroundings carefully.",
         small_coin = {
            close = "You see something shines.",
            far = "You sense something.",
            find = "You find a small coin!"
         }
      },
      shortcut = {
         cannot_use_anymore = "You can't use this shortcut any more.",
         cannot_use_spell_anymore = "You can't use that spell anymore.",
         unassigned = "The key is unassigned."
      },
      someone_else_is_using = "Someone else is using the item.",
      take_screenshot = "You took screenshot.",
      target = {
         level = {
            _0 = function(_1)
               return ("You can absolutely beat %s with your eyes closed and arms crossed.")
                  :format(him(_1))
            end,
            _1 = function(_1)
               return ("You bet you can beat %s with your eyes closed.")
                  :format(him(_1))
            end,
            _10 = function(_1)
               return ("If %s is a giant, you are less than a dropping of an ant.")
                  :format(he(_1))
            end,
            _2 = function(_1)
               return ("%s %s an easy opponent.")
                  :format(he(_1), is(_1))
            end,
            _3 = "You will probably win.",
            _4 = "Won't be an easy fight.",
            _5 = "The opponent looks quite strong.",
            _6 = function(_1)
               return ("%s %s at least twice stronger than you.")
                  :format(he(_1), is(_1))
            end,
            _7 = "You will get killed unless miracles happen.",
            _8 = "You will get killed, a hundred percent sure.",
            _9 = function(_1)
               return ("%s can mince you with %s eyes closed.")
                  :format(he(_1), his(_1))
            end
         },
         out_of_sight = "This location is out of sight.",
         you_are_targeting = function(_1, _2)
            return ("You are targeting %s.(Distance %s)")
               :format(name(_1), _2)
         end
      },
      throw = {
         execute = function(_1, _2)
            return ("%s throw%s %s.")
               :format(name(_1), s(_1), _2)
         end,
         hits = function(_1)
            return ("It hits %s!")
               :format(name(_1))
         end,
         monster_ball = {
            cannot_be_captured = "The creature can't be captured.",
            capture = function(_1)
               return ("You capture %s.")
                  :format(name(_1))
            end,
            does_not_work = "This doesn't work in this area.",
            not_enough_power = "Power level of the ball is not enough to capture the creature.",
            not_weak_enough = "You need to weaken the creature to capture it."
         },
         shatters = "It falls on the ground and shatters.",
         snow = {
            dialog = { "Hey!", "Now you did it.", "*chuckle*", "Tee-hee-hee!", "You'll pay for this.", "*grin*" },
            hits_snowman = function(_1)
               return ("It hits %s and breaks it.")
                  :format(_1)
            end,
            melts = "It falls on the ground and melts."
         },
         tomato = "*crumble*"
      },
      time_stop = {
         begins = function(_1)
            return ("%s stop%s time.")
               :format(name(_1), s(_1))
         end,
         ends = "Time starts to run again."
      },
      unlock = {
         do_not_have_lockpicks = "You don't have lockpicks.",
         easy = "Easy.",
         fail = "You fail to unlock it.",
         lockpick_breaks = "Your lockpick breaks.",
         succeed = "You successfully unlock it.",
         too_difficult = "The lock mechanism is beyond your skill.",
         try_again = "Try again?",
         use_lockpick = "You use a lockpick.",
         use_skeleton_key = "You also use the skeleton key."
      },
      use_stairs = {
         blocked_by_barrier = "The path is blocked by a strange barrier.",
         cannot_during_debug = "You can't perform the action while in the debug mode.",
         cannot_go = {
            down = "You can't go down any more.",
            up = "You can't go up any more."
         },
         kotatsu = {
            prompt = "Really get into the Kotatsu?",
            use = "It's dark here!"
         },
         locked = "The door is locked. It seems you need a specific key to unlock the door.",
         lost_balance = "Noooo! You lost your step and roll down!",
         no = {
            downstairs = "There're no downstairs here.",
            upstairs = "There're no upstairs here."
         },
         prompt_give_up_game = "Do you want to give up the game?",
         prompt_give_up_quest = "Really give up the quest and move over?",
         unlock = {
            normal = "You unlock the door",
            stones = "The magic stones shine softly as you approach the sealed door."
         }
      },
      weather = {
         changes = "The weather changes.",
         ether_wind = {
            starts = "Ether Wind starts to blow. You need to find a shelter!",
            stops = "The Ether Wind dissipates."
         },
         rain = {
            becomes_heavier = "The rain becomes heavier.",
            becomes_lighter = "The rain becomes lighter.",
            draw_cloud = "You draw a rain cloud.",
            starts = "It starts to rain.",
            starts_heavy = "Suddenly, rain begins to pour down from the sky.",
            stops = "It stops raining."
         },
         snow = {
            starts = "It starts to snow.",
            stops = "It stops raining."
         }
      },
      which_direction = {
         ask = "Which direction?",
         cannot_see_location = "You can't see the location.",
         default = "Which direction? ",
         door = "Which door do you want to close? ",
         out_of_range = "It's out of range.",
         spell = "Which direction do you want to cast the spell? ",
         wand = "Which direction do you want to zap the wand? "
      },
      zap = {
         execute = function(_1)
            return ("You zap %s.")
               :format(_1)
         end,
         fail = function(_1)
            return ("%s fail to use the power of the rod.")
               :format(name(_1))
         end
      }
   }
}
