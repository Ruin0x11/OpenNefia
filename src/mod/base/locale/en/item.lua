return {
   item = {
      acid = {
         damaged = function(_1, _2)
            return ("%s%s %s is damaged by acid.")
               :format(name(_1), his_owned(_1), _2)
         end,
         immune = function(_1, _2)
            return ("%s%s %s is immune to acid.")
               :format(name(_1), his_owned(_1), _2)
         end
      },
      approximate_curse_state = {
         cursed = "(Scary)",
         doomed = "(Dreadful)"
      },
      armor_class = {
         heavy = "(Heavy)",
         light = "(Light)",
         medium = "(Medium)"
      },
      charges = function(_1)
         return ("(Charges: %s)")
            :format(_1)
      end,
      chest_empty = "(Empty)",
      cargo_buying_price = function(price)
         return ("(Buying price: %s)"):format(price)
      end,
      aphrodisiac = "(Aphrodisiac)",
      poisoned = "(Poisoned)",
      interval = function(hours)
         return ("(Next: %sh.)"):format(hours)
      end,
      serial_no = function(serial_no)
         return (" serial no.%s"):format(serial_no)
      end,
      altar_god_name = function(god_name)
         return (" <%s>"):format(god_name)
      end,
      harvest_grown = function(weight)
         return (" grown %s"):format(weight)
      end,
      chip = {
         dryrock = "a dryrock",
         field = "a field"
      },
      coldproof_blanket = {
         protects_item = function(_1, _2)
            return ("%s protects %s%s stuff from cold.")
               :format(_1, name(_2), his_owned(_2))
         end,
         is_broken_to_pieces = function(_1)
            return ("%s is broken to pieces.")
               :format(_1)
         end,
      },
      desc = {
         bit = {
            acidproof = "It is acidproof.",
            alive = "It is alive.",
            blessed_by_ehekatl = "It is blessed by Ehekatl.",
            eternal_force = "The enemy dies.",
            fireproof = "It is fireproof.",
            handmade = "It is a hand-made item.",
            precious = "It is precious.",
            showroom_only = "It can be only used in a show room.",
            stolen = "It is a stolen item."
         },
         bonus = function(_1, _2)
            return ("It modifies hit bonus by %s and damage bonus by %s.")
               :format(_1, _2)
         end,
         deck = "Collected cards",
         dv_pv = function(_1, _2)
            return ("It modifies DV by %s and PV by %s.")
               :format(_1, _2)
         end,
         have_to_identify = "You have to identify the item to gain knowledge.",
         it_is_made_of = function(_1)
            return ("It is made of %s.")
               :format(_1)
         end,
         living_weapon = function(growth, experience)
            return ("[Lv:%d Exp:%d%%]")
               :format(growth, experience)
         end,
         no_information = "There is no information about this object.",
         speeds_up_ether_disease = "It speeds up the ether disease while equipping.",
         weapon = {
            heavy = "It is a heavy weapon.",
            it_can_be_wielded = "It can be wielded as a weapon.",
            light = "It is a light weapon.",
            dice = function(dice_x, dice_y, pierce)
               return ("(%dd%d Pierce %d%%)")
                  :format(dice_x, dice_y, pierce)
            end
         },
         window = {
            error = "Unknown item definition. If possible, please report which menu the Known info menu (x key) was opened from (e.g. Drink, Zap, Eat, etc.).",
            title = "Known Information"
         }
      },
      filter_name = {
         elona = {
            equip_ammo = "ammos",
            drink = "potions",
            scroll = "scrolls",
            rod = "rods",
            food = "food",
            furniture = "furniture",
            furniture_well = "well",
            junk = "junks",
            ore = "ores",
         },
         default = "Unknown"
      },
      fireproof_blanket = {
         protects_item = function(_1, _2)
            return ("%s protects %s%s stuff from fire.")
               :format(_1, name(_2), his_owned(_2))
         end,
         turns_to_dust = function(_1)
            return ("%s turns to dust.")
               :format(_1)
         end,
      },
      item_on_the_ground = {
         breaks_to_pieces = function(_1, _2)
            return ("%s on the ground break%s to pieces.")
               :format(_1, s(_2))
         end,
         gets_broiled = function(_1)
            return ("%s on the ground get%s perfectly broiled.")
               :format(_1, s(_1))
         end,
         turns_to_dust = function(_1, _2)
            return ("%s on the ground turn%s to dust.")
               :format(_1, s(_2))
         end,
      },
      items_are_destroyed = "Too many item data! Some items in this area are destroyed.",
      kitty_bank_rank = {
         _0 = "(500 GP)",
         _1 = "(2k GP)",
         _2 = "(10K GP)",
         _3 = "(50K GP)",
         _4 = "(500K GP)",
         _5 = "(5M GP)",
         _6 = "(500M GP)"
      },
      title_paren = {
         great = function(_1)
            return ("<%s>"):format(_1)
         end,
         god = function(_1)
            return ("{%s}"):format(_1)
         end,
      },
      someones_item = {
         breaks_to_pieces = function(_1, _2, _3)
            return ("%s%s %s break%s to pieces.")
               :format(name(_3), his_owned(_3), _1, s(_2))
         end,
         gets_broiled = function(_1, _2)
            return ("%s%s %s get%s perfectly broiled.")
               :format(name(_2), his_owned(_2), _1, s(_1))
         end,
         turns_to_dust = function(_1, _2, _3)
            return ("%s%s %s turn%s to dust.")
               :format(name(_3), his_owned(_3), _1, s(_2))
         end,
         equipment_turns_to_dust = function(_1, _2, _3)
            return ("%s %s equip%s turn%s to dust.")
               :format(_1, name(_3), s(_3), s(_2))
         end,
         falls_and_disappears = "Something falls to the ground and disappears...",
         falls_from_backpack = "Something falls to the ground from your backpack.",
      },
      stacked = function(_1, _2)
         return ("%s has been stacked. (Total:%s)")
            :format(_1, _2)
      end,
      unknown_item = "unknown item (incompatible version)",
      qualified_name = function(name, originalnameref2)
         if (originalnameref2 or "") == "" then
            return tostring(name)
         end
         return ("%s of %s"):format(originalnameref2, name)
      end
   },
}
