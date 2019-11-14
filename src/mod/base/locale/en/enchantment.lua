return {
  enchantment = {
    it = "It ",
    item_ego = {
      major = {
        _0 = "of fire",
        _1 = "of silence",
        _10 = "of resist sleep",
        _2 = "of cold",
        _3 = "of lightning",
        _4 = "of defender",
        _5 = "of healing",
        _6 = "of resist blind",
        _7 = "of resist paralysis",
        _8 = "of resist confusion",
        _9 = "of resist fear"
      },
      minor = {
        _0 = "singing",
        _1 = "servant's",
        _2 = "follower's",
        _3 = "howling",
        _4 = "glowing",
        _5 = "conspicuous",
        _6 = "magical",
        _7 = "enchanted",
        _8 = "mighty",
        _9 = "trustworthy"
      }
    },
    level = "#",
    no_parameters = {
      _21 = "causes random teleport.",
      _22 = "prevents you from teleporting.",
      _23 = "negates the effect of blindness.",
      _24 = "negates the effect of paralysis.",
      _25 = "negates the effect of confusion.",
      _26 = "negates the effect of fear.",
      _27 = "negates the effect of sleep.",
      _28 = "negates the effect of poison.",
      _29 = "speeds up your travel progress.",
      _30 = "protects you from Etherwind.",
      _31 = "negates the effect of being stranded by bad weather.",
      _32 = "floats you.",
      _33 = "protects you from mutation.",
      _34 = "enhances your spells.",
      _35 = "allows you to see invisible creatures.",
      _36 = "absorbs stamina from an enemy.",
      _37 = "brings an end.",
      _38 = "absorbs MP from an enemy.",
      _39 = "gives you a chance to throw an absolute piercing attack.",
      _40 = "occasionally stops time.",
      _41 = "protects you from thieves.",
      _42 = "allows you to digest rotten food.",
      _43 = "protects you from cursing words.",
      _44 = "increases your chance to deliver critical hits.",
      _45 = "sucks blood of the wielder.",
      _46 = "disturbs your growth.",
      _47 = "attracts monsters.",
      _48 = "prevents aliens from entering your body.",
      _49 = "increases the quality of reward.",
      _50 = "increases the chance of extra melee attack.",
      _51 = "increases the chance of extra ranged attack.",
      _52 = "decreases physical damage you take.",
      _53 = "sometimes nullifies damage you take.",
      _54 = "deals cut damage to the attacker.",
      _55 = "diminishes bleeding.",
      _56 = "catches signals from God.",
      _57 = "inflicts massive damage to dragons.",
      _58 = "inflicts massive damage to undeads.",
      _59 = "reveals religion.",
      _60 = "makes audience drunk with haunting tones.",
      _61 = "inflicts massive damage to Gods."
    },
    with_parameters = {
      ammo = {
        kinds = {
          _0 = "rapid ammo",
          _1 = "explosive ammo",
          _2 = "piercing ammo",
          _3 = "magic ammo",
          _4 = "time stop ammo",
          _5 = "burst ammo"
        },
        max = function(_1)
  return ("Max %s")
  :format(_1)
end,
        text = function(_1)
  return ("can be loaded with %s.")
  :format(_1)
end
      },
      attribute = {
        in_food = {
          decreases = function(_1)
  return ("has which deteriorates your %s.")
  :format(_1)
end,
          increases = function(_1)
  return ("has essential nutrients to enhance your %s.")
  :format(_1)
end
        },
        other = {
          decreases = function(_1, _2)
  return ("decreases your %s by %s.")
  :format(_1, _2)
end,
          increases = function(_1, _2)
  return ("increases your %s by %s.")
  :format(_1, _2)
end
        }
      },
      extra_damage = function(_1)
  return ("deals %s damage.")
  :format(_1)
end,
      invokes = function(_1)
  return ("invokes %s.")
  :format(_1)
end,
      resistance = {
        decreases = function(_1)
  return ("weakens your resistance to %s.")
  :format(_1)
end,
        increases = function(_1)
  return ("grants your resistance to %s.")
  :format(_1)
end
      },
      skill = {
        decreases = function(_1)
  return ("decreases your %s skill.")
  :format(_1)
end,
        increases = function(_1)
  return ("improves your %s skill.")
  :format(_1)
end
      },
      skill_maintenance = {
        in_food = function(_1)
  return ("can help you exercise your %s faster.")
  :format(_1)
end,
        other = function(_1)
  return ("maintains %s.")
  :format(_1)
end
      }
    }
  }
}