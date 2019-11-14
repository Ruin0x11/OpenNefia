return {
  item = {
    acid = {
      damaged = function(_1, _2)
  return ("%s%s %s is damaged by acid.")
  :format(name(_1), his_owned(_1), itemname(_2, 0, false))
end,
      immune = function(_1, _2)
  return ("%s%s %s is immune to acid.")
  :format(name(_1), his_owned(_1), itemname(_2, 0, false))
end
    },
    ancient_book_title = {
      _0 = "Voynich Manuscript",
      _1 = "Dhol Chants",
      _10 = "Necronomicon",
      _11 = "The R'lyeh Text",
      _12 = "Eltdown Shards",
      _13 = "The Golden Bough",
      _14 = "Apocalypse",
      _2 = "Ponape Scripture",
      _3 = "Revelations of Glaaki",
      _4 = "G'harne Fragments",
      _5 = "Liber Damnatus",
      _6 = "Book of Dzyan",
      _7 = "Book of Eibon",
      _8 = "Grand Grimoire",
      _9 = "Celaeno Fragments"
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
    bait_rank = {
      _0 = "water flea",
      _1 = "grasshopper",
      _2 = "ladybug",
      _3 = "dragonfly",
      _4 = "locust",
      _5 = "beetle"
    },
    charges = function(_1)
  return ("(Charges: %s)")
  :format(_1)
end,
    chip = {
      dryrock = "a dryrock",
      field = "a field"
    },
    coldproof_blanket_is_broken_to_pieces = function(_1)
  return ("%s is broken to pieces.")
  :format(itemname(_1, 1))
end,
    coldproof_blanket_protects_item = function(_1, _2)
  return ("%s protects %s%s stuff from cold.")
  :format(itemname(_1, 1), name(_2), his_owned(_2))
end,
    desc = {
      bit = {
        acidproof = "It is acidproof.",
        alive = "It is alive.",
        blessed_by_ehekatl = "It is blessed by Ehekatl.",
        eternal_force = "The enemy dies.",
        fireproof = "It is fireproof.",
        handmade = "It is a hand-made item.",
        precious = "It is precious.",
        show_room_only = "It can be only used in a show room.",
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
      no_information = "There is no information about this object.",
      speeds_up_ether_disease = "It speeds up the ether disease while equipping.",
      weapon = {
        heavy = "It is a heavy weapon.",
        it_can_be_wielded = "It can be wielded as a weapon.",
        light = "It is a light weapon.",
        pierce = " Pierce "
      },
      window = {
        error = "Unknown item definition. If possible, please report which menu the Known info menu (x key) was opened from (e.g. Drink, Zap, Eat, etc.).",
        title = "Known Information"
      }
    },
    filter_name = {
      _25000 = "ammos",
      _52000 = "potions",
      _53000 = "scrolls",
      _56000 = "rods",
      _57000 = "food",
      _60000 = "furniture",
      _60001 = "well",
      _64000 = "junks",
      _77000 = "ores",
      default = "Unknown"
    },
    fireproof_blanket_protects_item = function(_1, _2)
  return ("%s protects %s%s stuff from fire.")
  :format(itemname(_1, 1), name(_2), his_owned(_2))
end,
    fireproof_blanket_turns_to_dust = function(_1)
  return ("%s turns to dust.")
  :format(itemname(_1, 1))
end,
    gift_rank = {
      _0 = "cheap",
      _1 = "so so",
      _2 = "exciting",
      _3 = "expensive",
      _4 = "hot and gorgeous",
      _5 = "crazy epic"
    },
    godly_paren = function(_1)
  return ("{%s}")
  :format(_1)
end,
    item_on_the_ground_breaks_to_pieces = function(_1, _2)
  return ("%s on the ground break%s to pieces.")
  :format(_1, s(_2))
end,
    item_on_the_ground_get_broiled = function(_1)
  return ("%s on the ground get%s perfectly broiled.")
  :format(itemname(_1), _s(_1))
end,
    item_on_the_ground_turns_to_dust = function(_1, _2)
  return ("%s on the ground turn%s to dust.")
  :format(_1, s(_2))
end,
    item_someone_equips_turns_to_dust = function(_1, _2, _3)
  return ("%s %s equip%s turn%s to dust.")
  :format(_1, name(_3), s(_3), s(_2))
end,
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
    miracle_paren = function(_1)
  return ("<%s>")
  :format(_1)
end,
    someones_item_breaks_to_pieces = function(_1, _2, _3)
  return ("%s%s %s break%s to pieces.")
  :format(name(_3), his_owned(_3), _1, s(_2))
end,
    someones_item_get_broiled = function(_1, _2)
  return ("%s%s %s get%s perfectly broiled.")
  :format(name(_2), his_owned(_2), itemname(_1, 0, false), _s(_1))
end,
    someones_item_turns_to_dust = function(_1, _2, _3)
  return ("%s%s %s turn%s to dust.")
  :format(name(_3), his_owned(_3), _1, s(_2))
end,
    something_falls_and_disappears = "Something falls to the ground and disappears...",
    something_falls_from_backpack = "Something falls to the ground from your backpack.",
    stacked = function(_1, _2)
  return ("%s has been stacked. (Total:%s)")
  :format(itemname(_1, 1), _2)
end,
    unknown_item = "unknown item (incompatible version)"
  }
}