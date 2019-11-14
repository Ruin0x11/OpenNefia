return {
  god = {
    desc = {
      _1 = {
        ability = "Mani's decomposition (Passive: Extract materials<br>from traps.)<p>",
        bonus = "DEX/PER/Firearm/Healing/Detection/Jeweler/Lockpick/Carpentry<p>",
        offering = "Corpses/Guns/Machinery<p>",
        text = "Mani is a clockwork god of machinery. Those faithful to Mani<br>receive immense knowledge of machines and learn a way to use them<br>effectively.<p>"
      },
      _2 = {
        ability = "Lulwy's trick (Boost your speed for a short time.)<p>",
        bonus = "PER/SPD/Bow/Crossbow/Stealth/Magic Device<p>",
        offering = "Corpses/Bows<p>",
        text = "Lulwy is a goddess of wind. Those faithful to Lulwy receive<br>the blessing of wind and can move swiftly.<p>"
      },
      _3 = {
        ability = "Absorb mana (Absorb mana from the air.)<p>",
        bonus = "MAG/Meditation/RES Fire/RES Cold/RES Lightning<p>",
        offering = "Corpses/Staves<p>",
        text = "Itzpalt is a god of elements. Those faithful to Itzpalt are<br>protected from elemental damages and learn to absorb mana from<br>their surroundings.<p>"
      },
      _4 = {
        ability = "Ehekatl school of magic (Passive: Randomize casting mana<br>cost.)<p>",
        bonus = "CHR/LUCK/Evasion/Magic Capacity/Fishing/Lockpick<p>",
        offering = "Corpses/Fish<p>",
        text = "Ehekatl is a goddess of luck. Those faithful to Ehekatl are<br>really lucky.<p><p>"
      },
      _5 = {
        ability = "Opatos' shell (Passive: Reduce any physical damage you<br>receive.)<p>",
        bonus = "STR/CON/Shield/Weight Lifting/Mining/Magic Device<p>",
        offering = "Corpses/Ores<p>",
        text = "Opatos is a god of earth. Those faithful to Opatos have massive<br>strength and defense.<p><p>"
      },
      _6 = {
        ability = "Prayer of Jure (Heal yourself.)<p>",
        bonus = "WIL/Healing/Meditation/Anatomy/Cooking/Magic Device/Magic Capacity<p>",
        offering = "Corpses/Ores<p>",
        text = "Jure is a god of healing. Those faithful to Jure can heal wounds.<p><p>"
      },
      _7 = {
        ability = "Kumiromi's recycle (Passive: Extract seeds from rotten <p>foods.)<p>",
        bonus = "PER/DEX/LER/Gardening/Alchemy/Tailoring/Literacy<p>",
        offering = "Corpses/Vegetables/Seeds<p>",
        text = "Kumiromi is a god of harvest. Those faithful to Kumiromi receive<br>the blessings of nature.<p><p>"
      },
      ability = " Ability",
      bonus = "   Bonus",
      offering = "Offering",
      window = {
        abandon = "Abandon God",
        believe = function(_1)
  return ("Believe in %s")
  :format(_1)
end,
        cancel = "Cancel",
        convert = function(_1)
  return ("Convert to %s")
  :format(_1)
end,
        title = function(_1)
  return ("< %s >")
  :format(_1)
end
      }
    },
    enraged = function(_1)
  return ("%s is enraged.")
  :format(_1)
end,
    indifferent = " Your God becomes indifferent to your gift.",
    pray = {
      do_not_believe = "You don't believe in God.",
      indifferent = function(_1)
  return ("%s is indifferent to you.")
  :format(_1)
end,
      prompt = "Really pray to your God?",
      servant = {
        desc = {
          ehekatl = "Weapons and armor licked by this cat receive a blessing of Ehekatl which adds an extra enchantment.",
          itzpalt = "This exile can cast several spells in a row.",
          jure = "This defender can use Lay on hand to heal a mortally wounded ally. The ability becomes re-useable after sleeping.",
          kumiromi = "This fairy generates a seed after eating.",
          lulwy = "This black angel shows enormous strength when boosting.",
          mani = "This android shows enormous strength when boosting.",
          opatos = "This knight can hold really heavy stuff for you."
        },
        no_more = "No more than 2 God's servants are allowed in your party.",
        party_is_full = "Your party is full. The gift is reserved.",
        prompt_decline = "Do you want to decline this gift?"
      },
      you_pray_to = function(_1)
  return ("You pray to %s.")
  :format(_1)
end
    },
    switch = {
      follower = function(_1)
  return ("You become a follower of %s!")
  :format(_1)
end,
      unbeliever = "You are an unbeliever now."
    }
  }
}