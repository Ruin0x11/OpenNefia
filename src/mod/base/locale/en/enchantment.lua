return {
  enchantment = {
    it = function(desc)
       return ("It %s"):format(desc)
    end,
    item_ego = {
      major = {
        _0 = "of fire",
        _1 = "of silence",
        _2 = "of cold",
        _3 = "of lightning",
        _4 = "of defender",
        _5 = "of healing",
        _6 = "of resist blind",
        _7 = "of resist paralysis",
        _8 = "of resist confusion",
        _9 = "of resist fear",
        _10 = "of resist sleep"
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
    with_parameters = {
      ammo = {
        max = function(_1)
  return ("[Max %s]")
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
