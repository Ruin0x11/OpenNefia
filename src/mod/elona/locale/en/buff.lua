return {
  buff = {
    _1 = {
      apply = function(_1)
  return ("%s begin%s to shine.")
  :format(name(_1), s(_1))
end,
      description = function(_1)
  return ("Increases PV by %s /RES+ fear")
  :format(_1)
end,
      name = "Holy Shield"
    },
    _10 = {
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
    _11 = {
      apply = function(_1)
  return ("%s start%s to suffer.")
  :format(name(_1), s(_1))
end,
      description = "RES- mind,nerve",
      name = "Nightmare"
    },
    _12 = {
      apply = function(_1)
  return ("%s start%s to think clearly.")
  :format(name(_1), s(_1))
end,
      description = function(_1, _2)
  return ("Increases LER,MAG by %s, literacy skill by %s")
  :format(_1, _2)
end,
      name = "Divine Wisdom"
    },
    _13 = {
      apply = function(_1)
  return ("%s incur%s the wrath of God.")
  :format(name(_1), s(_1))
end,
      description = function(_1, _2)
  return ("Decreases speed by %s, PV by %s%")
  :format(_1, _2)
end,
      name = "Punishment"
    },
    _14 = {
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
    _15 = {
      apply = function(_1)
  return ("%s start%s to disguise.")
  :format(name(_1), s(_1))
end,
      description = "Grants new identity",
      name = "Incognito"
    },
    _16 = {
      apply = function(_1)
  return ("%s receive%s death verdict.")
  :format(name(_1), s(_1))
end,
      description = "Guaranteed death when the hex ends",
      name = "Death Word"
    },
    _17 = {
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
    _18 = {
      apply = function(_1)
  return ("%s set%s up contracts with the Reaper.")
  :format(name(_1), s(_1))
end,
      description = function(_1)
  return ("%s% chances taking a lethal damage heals you instead")
  :format(_1)
end,
      name = "Contingency"
    },
    _19 = {
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
    _2 = {
      apply = function(_1)
  return ("%s get%s surrounded by hazy mist.")
  :format(name(_1), s(_1))
end,
      description = "Inhibits casting",
      name = "Mist of Silence"
    },
    _20 = {
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
    _21 = {
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
    _22 = {
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
    _23 = {
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
    _24 = {
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
    _25 = {
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
    _26 = {
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
    _27 = {
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
    _28 = {
      apply = function(_1)
  return ("%s feel%s rapid SPD growth.")
  :format(name(_1), s(_1))
end,
      description = function(_1)
  return ("Increases the growth rate Speed by %s")
  :format(_1)
end,
      name = "Grow Speed"
    },
    _29 = {
      apply = function(_1)
  return ("%s feel%s rapid LCK growth.")
  :format(name(_1), s(_1))
end,
      description = function(_1)
  return ("Increases the growth rate Luck by %s")
  :format(_1)
end,
      name = "Grow Luck"
    },
    _3 = {
      apply = function(_1)
  return ("%s start%s to regenerate.")
  :format(name(_1), s(_1))
end,
      description = "Enhances regeneration",
      name = "Regeneration"
    },
    _4 = {
      apply = function(_1)
  return ("%s obtain%s resistance to element.")
  :format(name(_1), s(_1))
end,
      description = "RES+ fire,cold,lightning",
      name = "Elemental Shield"
    },
    _5 = {
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
    _6 = {
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
    _7 = {
      apply = function(_1)
  return ("%s feel%s heroic.")
  :format(name(_1), s(_1))
end,
      description = function(_1)
  return ("Increases STR,DEX by %s /RES+ fear,confusion")
  :format(_1)
end,
      name = "Hero"
    },
    _8 = {
      apply = function(_1)
  return ("%s feel%s weak.")
  :format(name(_1), s(_1))
end,
      description = "Halves DV and PV",
      name = "Mist of Frailness"
    },
    _9 = {
      apply = function(_1)
  return ("%s lose%s resistance to element.")
  :format(name(_1), s(_1))
end,
      description = "RES- fire,cold,lightning",
      name = "Element Scar"
    }
  }
}