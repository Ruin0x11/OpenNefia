return {
  element = {
    damage = {
      _50 = function(_1)
  return ("%s %s burnt.")
  :format(name(_1), is(_1))
end,
      _51 = function(_1)
  return ("%s %s frozen.")
  :format(name(_1), is(_1))
end,
      _52 = function(_1)
  return ("%s %s shocked.")
  :format(name(_1), is(_1))
end,
      _53 = function(_1)
  return ("%s %s struck by dark force.")
  :format(name(_1), is(_1))
end,
      _54 = function(_1)
  return ("%s suffer%s a splitting headache.")
  :format(name(_1), s(_1))
end,
      _55 = function(_1)
  return ("%s suffer%s from venom.")
  :format(name(_1), s(_1))
end,
      _56 = function(_1)
  return ("%s %s chilled by infernal squall.")
  :format(name(_1), is(_1))
end,
      _57 = function(_1)
  return ("%s %s shocked by a shrill sound.")
  :format(name(_1), is(_1))
end,
      _58 = function(_1)
  return ("%s%s nerves are hurt.")
  :format(name(_1), his_owned(_1))
end,
      _59 = function(_1)
  return ("%s %s hurt by chaotic force.")
  :format(name(_1), is(_1))
end,
      _61 = function(_1)
  return ("%s get%s a cut.")
  :format(name(_1), s(_1))
end,
      _63 = function(_1)
  return ("%s %s burnt by acid.")
  :format(name(_1), is(_1))
end,
      default = function(_1)
  return ("%s %s wounded.")
  :format(name(_1), is(_1))
end
    },
    name = {
      _50 = "burning",
      _51 = "icy",
      _52 = "electric",
      _53 = "gloomy",
      _54 = "psychic",
      _55 = "poisonous",
      _56 = "infernal",
      _57 = "shivering",
      _58 = "numb",
      _59 = "chaotic",
      _61 = "cut",
      _62 = "ether",
      fearful = "fearful",
      rotten = "rotten",
      silky = "silky",
      starving = "starving"
    },
    resist = {
      gain = {
        _50 = function(_1)
  return ("Suddenly, %s feel%s very hot.")
  :format(name(_1), s(_1))
end,
        _51 = function(_1)
  return ("Suddenly, %s feel%s very cool.")
  :format(name(_1), s(_1))
end,
        _52 = function(_1)
  return ("%s%s struck by an electric shock.")
  :format(name(_1), is(_1))
end,
        _53 = function(_1)
  return ("%s no longer fear%s darkness.")
  :format(name(_1), s(_1))
end,
        _54 = function(_1)
  return ("Suddenly, %s%s mind becomes very clear.")
  :format(name(_1), his_owned(_1))
end,
        _55 = function(_1)
  return ("%s now %s antibodies to poisons.")
  :format(name(_1), have(_1))
end,
        _56 = function(_1)
  return ("%s %s no longer afraid of hell.")
  :format(name(_1), is(_1))
end,
        _57 = function(_1)
  return ("%s%s eardrums get thick.")
  :format(name(_1), his_owned(_1))
end,
        _58 = function(_1)
  return ("%s%s nerve is sharpened.")
  :format(name(_1), his_owned(_1))
end,
        _59 = function(_1)
  return ("Suddenly, %s understand%s chaos.")
  :format(name(_1), s(_1))
end,
        _60 = function(_1)
  return ("%s%s body is covered by a magical aura.")
  :format(name(_1), his_owned(_1))
end
      },
      lose = {
        _50 = function(_1)
  return ("%s sweat%s.")
  :format(name(_1), s(_1))
end,
        _51 = function(_1)
  return ("%s shiver%s.")
  :format(name(_1), s(_1))
end,
        _52 = function(_1)
  return ("%s %s shocked.")
  :format(name(_1), is(_1))
end,
        _53 = function(_1)
  return ("Suddenly, %s fear%s darkness.")
  :format(name(_1), s(_1))
end,
        _54 = function(_1)
  return ("%s%s mind becomes slippery.")
  :format(name(_1), his_owned(_1))
end,
        _55 = function(_1)
  return ("%s lose%s antibodies to poisons.")
  :format(name(_1), s(_1))
end,
        _56 = function(_1)
  return ("%s %s afraid of hell.")
  :format(name(_1), is(_1))
end,
        _57 = function(_1)
  return ("%s become%s very sensitive to noises.")
  :format(name(_1), s(_1))
end,
        _58 = function(_1)
  return ("%s become%s dull.")
  :format(name(_1), s(_1))
end,
        _59 = function(_1)
  return ("%s no longer understand%s chaos.")
  :format(name(_1), s(_1))
end,
        _60 = function(_1)
  return ("The magical aura disappears from %s%s body.")
  :format(name(_1), his_owned(_1))
end
      }
    }
  }
}