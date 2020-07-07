return {
  death_by = {
    chara = {
      death_cause = function(_1)
  return ("was killed by %s")
  :format(basename(_1))
end,
      destroyed = {
        active = function(_1, _2)
  return ("destroy%s %s.")
  :format(s(_2), him(_1))
end,
        passive = function(_1)
  return ("%s %s killed.")
  :format(name(_1), is(_1))
end
      },
      killed = {
        active = function(_1, _2)
  return ("kill%s %s.")
  :format(s(_2), him(_1))
end,
        passive = function(_1)
  return ("%s %s slain.")
  :format(name(_1), is(_1))
end
      },
      minced = {
        active = function(_1, _2)
  return ("mince%s %s.")
  :format(s(_2), him(_1))
end,
        passive = function(_1)
  return ("%s %s minced.")
  :format(name(_1), is(_1))
end
      },
      transformed_into_meat = {
        active = function(_1, _2)
  return ("transform%s %s into several pieces of meat.")
  :format(s(_2), him(_1))
end,
        passive = function(_1)
  return ("%s %s transformed into several pieces of meat.")
  :format(name(_1), is(_1))
end
      }
    },
    other = {
      _1 = {
        death_cause = "got caught in a trap and died",
        text = function(_1)
  return ("%s %s caught in a trap and die%s.")
  :format(name(_1), is(_1), s(_1))
end
      },
      _11 = {
        death_cause = "got assassinated by the unseen hand",
        text = function(_1)
  return ("%s %s assassinated by the unseen hand.")
  :format(name(_1), is(_1))
end
      },
      _12 = {
        death_cause = "got killed by food poisoning",
        text = function(_1)
  return ("%s %s killed by food poisoning.")
  :format(name(_1), is(_1))
end
      },
      _13 = {
        death_cause = "died from loss of blood",
        text = function(_1)
  return ("%s die%s from loss of blood.")
  :format(name(_1), s(_1))
end
      },
      _14 = {
        death_cause = "died of the Ether disease",
        text = function(_1)
  return ("%s die%s of the Ether disease.")
  :format(name(_1), s(_1))
end
      },
      _15 = {
        death_cause = "melted down",
        text = function(_1)
  return ("%s melt%s down.")
  :format(name(_1), s(_1))
end
      },
      _16 = {
        death_cause = "committed suicide",
        text = function(_1)
  return ("%s shatter%s.")
  :format(name(_1), s(_1))
end
      },
      _17 = {
        death_cause = "was killed by an atomic bomb",
        text = function(_1)
  return ("%s %s turned into atoms.")
  :format(name(_1), is(_1))
end
      },
      _18 = {
        death_cause = "stepped in an iron maiden and died",
        text = function(_1)
  return ("%s step%s into an iron maiden and die%s.")
  :format(name(_1), s(_1), s(_1))
end
      },
      _19 = {
        death_cause = "was guillotined",
        text = function(_1)
  return ("%s %s guillotined and die%s.")
  :format(name(_1), is(_1), s(_1))
end
      },
      _2 = {
        death_cause = "was completely wiped by magic reaction",
        text = function(_1)
  return ("%s die%s from over-casting.")
  :format(name(_1), s(_1))
end
      },
      _20 = {
        death_cause = "commited suicide by hanging",
        text = function(_1)
  return ("%s hang%s %sself.")
  :format(name(_1), s(_1), his(_1))
end
      },
      _21 = {
        death_cause = "ate mochi and died",
        text = function(_1)
  return ("%s choke%s on mochi and die.")
  :format(name(_1), s(_1))
end
      },
      _3 = {
        death_cause = "was starved to death",
        text = function(_1)
  return ("%s %s starved to death.")
  :format(name(_1), is(_1))
end
      },
      _4 = {
        death_cause = "miserably died from poison",
        text = function(_1)
  return ("%s %s killed with poison.")
  :format(name(_1), is(_1))
end
      },
      _5 = {
        death_cause = "died from curse",
        text = function(_1)
  return ("%s die%s from curse.")
  :format(name(_1), s(_1))
end
      },
      _6 = {
        backpack = "backpack",
        death_cause = function(_1)
  return ("was squashed by %s")
  :format(_1)
end,
        text = function(_1, _2)
  return ("%s %s squashed by %s.")
  :format(name(_1), is(_1), _2)
end
      },
      _7 = {
        death_cause = "tumbled from stairs and died",
        text = function(_1)
  return ("%s tumble%s from stairs and die%s.")
  :format(name(_1), s(_1), s(_1))
end
      },
      _8 = {
        death_cause = "was killed by an audience",
        text = function(_1)
  return ("%s %s killed by an audience.")
  :format(name(_1), is(_1))
end
      },
      _9 = {
        death_cause = "was burnt and turned into ash",
        text = function(_1)
  return ("%s %s burnt and turned into ash.")
  :format(name(_1), is(_1))
end
      }
    }
  }
}
