return {
  effect = {
    elona = {
      bleeding = {
        apply = function(_1)
  return ("%s begin%s to bleed.")
  :format(name(_1), s(_1))
end,
        heal = function(_1)
  return ("%s%s bleeding stops.")
  :format(name(_1), his_owned(_1))
end
      },
      blindness = {
        apply = function(_1)
  return ("%s %s blinded.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s can see again.")
  :format(name(_1))
end
      },
      confusion = {
        apply = function(_1)
  return ("%s %s confused.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s recover%s from confusion.")
  :format(name(_1), s(_1))
end
      },
      dimming = {
        apply = function(_1)
  return ("%s %s dimmed.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s regain%s %s senses.")
  :format(name(_1), s(_1), his(_1))
end
      },
      drunk = {
        apply = function(_1)
  return ("%s get%s drunk.")
  :format(name(_1), s(_1))
end,
        heal = function(_1)
  return ("%s get%s sober.")
  :format(name(_1), s(_1))
end
      },
      fear = {
        apply = function(_1)
  return ("%s %s frightened.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s shake%s off %s fear.")
  :format(name(_1), s(_1), his(_1))
end
      },
      insanity = {
        apply = function(_1)
  return ("%s become%s insane.")
  :format(name(_1), s(_1))
end,
        heal = function(_1)
  return ("%s come%s to %s again.")
  :format(name(_1), s(_1), himself(_1))
end
      },
      paralysis = {
        apply = function(_1)
  return ("%s %s paralyzed.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s recover%s from paralysis.")
  :format(name(_1), s(_1))
end
      },
      poison = {
        apply = function(_1)
  return ("%s %s poisoned.")
  :format(name(_1), is(_1))
end,
        heal = function(_1)
  return ("%s recover%s from poison.")
  :format(name(_1), s(_1))
end
      },
      sick = {
        apply = function(_1)
  return ("%s get%s sick.")
  :format(name(_1), s(_1))
end,
        heal = function(_1)
  return ("%s recover%s from %s illness.")
  :format(name(_1), s(_1), his(_1))
end
      },
      sleep = {
        apply = function(_1)
  return ("%s fall%s asleep.")
  :format(name(_1), s(_1))
end,
        heal = function(_1)
  return ("%s awake%s from %s sleep.")
  :format(name(_1), s(_1), his(_1))
end
      }
    },
    name = {
      angry = {
        _0 = "Fury",
        _1 = "Berserk"
      },
      bleeding = {
        _0 = "Bleeding",
        _1 = "Bleeding!",
        _2 = "Hemorrhage"
      },
      blind = "Blinded",
      burden = {
        _0 = "",
        _1 = "Burden",
        _2 = "Burden!",
        _3 = "Overweight",
        _4 = "Overweight!"
      },
      choked = "Choked",
      confused = "Confused",
      dimmed = {
        _0 = "Dim",
        _1 = "Muddled",
        _2 = "Unconscious"
      },
      drunk = "Drunk",
      fear = "Fear",
      gravity = "Gravity",
      hunger = {
        _0 = "Starving!",
        _1 = "Starving",
        _10 = "Satisfied",
        _11 = "Satisfied!",
        _12 = "Bloated",
        _2 = "Hungry!",
        _3 = "Hungry",
        _4 = "Hungry",
        _5 = "",
        _6 = "",
        _7 = "",
        _8 = "",
        _9 = ""
      },
      insane = {
        _0 = "Unsteady",
        _1 = "Insane",
        _2 = "Paranoia"
      },
      paralyzed = "Paralyzed",
      poison = {
        _0 = "Poisoned",
        _1 = "Poisoned Bad!"
      },
      sick = {
        _0 = "Sick",
        _1 = "Very Sick"
      },
      sleep = {
        _0 = "Sleep",
        _1 = "Deep Sleep"
      },
      sleepy = {
        _0 = "Sleepy",
        _1 = "Need Sleep",
        _2 = "Need Sleep!"
      },
      tired = {
        _0 = "Tired",
        _1 = "Very tired",
        _2 = "VERY tired"
      },
      wet = "Wet"
    }
  }
}
