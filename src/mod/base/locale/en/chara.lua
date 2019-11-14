return {
  chara = {
    age_unknown = "Unknown",
    contract_expired = function(_1)
  return ("The period of contract with %s has been expired.")
  :format(basename(_1))
end,
    corruption = {
      add = "Your disease is getting worse.",
      remove = "The symptoms of the Ether disease seem to calm down.",
      symptom = "The symptom of the Ether disease is shown up on you."
    },
    gain_level = {
      other = function(_1)
  return ("%s %s grown up.")
  :format(name(_1), have(_1))
end,
      self = function(_1)
  return ("%s have gained a level.")
  :format(name(_1))
end
    },
    garbage = "a garbage",
    height = {
      gain = function(_1)
  return ("%s grow%s taller.")
  :format(name(_1), s(_1))
end,
      lose = function(_1)
  return ("%s grow%s smaller.")
  :format(name(_1), s(_1))
end
    },
    impression = {
      gain = function(_1, _2)
  return ("Your relation with %s becomes <%s>!")
  :format(basename(_1), _2)
end,
      lose = function(_1, _2)
  return ("Your relation with %s becomes <%s>...")
  :format(basename(_1), _2)
end
    },
    job = {
      alien = {
        alien_kid = "alien kid",
        child = "child",
        child_of = function(_1)
  return ("child of %s")
  :format(_1)
end
      },
      baker = function(_1)
  return ("%sthe baker")
  :format(trim_job(_1))
end,
      blackmarket = function(_1)
  return ("%sthe blackmarket vendor")
  :format(trim_job(_1))
end,
      blacksmith = function(_1)
  return ("%sthe blacksmith")
  :format(trim_job(_1))
end,
      dye_vendor = function(_1)
  return ("%sthe dye vendor")
  :format(trim_job(_1))
end,
      fanatic = { "Opatos Fanatic", "Mani Fanatic", "Ehekatl Fanatic" },
      fence = function(_1)
  return ("%sthe fence")
  :format(trim_job(_1))
end,
      fisher = function(_1)
  return ("%sthe fisher")
  :format(trim_job(_1))
end,
      food_vendor = function(_1)
  return ("%sthe food vendor")
  :format(trim_job(_1))
end,
      general_vendor = function(_1)
  return ("%sthe general vendor")
  :format(trim_job(_1))
end,
      goods_vendor = function(_1)
  return ("%sthe goods vendor")
  :format(trim_job(_1))
end,
      horse_master = function(_1)
  return ("%sthe horse master")
  :format(trim_job(_1))
end,
      innkeeper = function(_1)
  return ("%sthe innkeeper")
  :format(trim_job(_1))
end,
      magic_vendor = function(_1)
  return ("%sthe magic vendor")
  :format(trim_job(_1))
end,
      of_derphy = function(_1)
  return ("%s of Derphy")
  :format(_1)
end,
      of_lumiest = function(_1)
  return ("%s of Lumiest")
  :format(_1)
end,
      of_noyel = function(_1)
  return ("%s of Noyel")
  :format(_1)
end,
      of_palmia = function(_1)
  return ("%s of Palmia city")
  :format(_1)
end,
      of_port_kapul = function(_1)
  return ("%s of Port Kapul")
  :format(_1)
end,
      of_vernis = function(_1)
  return ("%s of Vernis")
  :format(_1)
end,
      of_yowyn = function(_1)
  return ("%s of Yowyn")
  :format(_1)
end,
      own_name = function(_1, _2)
  return ("%s the %s")
  :format(_2, _1)
end,
      shade = "shade",
      slave_master = "The slave master",
      souvenir_vendor = function(_1)
  return ("%sthe souvenir vendor")
  :format(trim_job(_1))
end,
      spell_writer = function(_1)
  return ("%sthe spell writer")
  :format(trim_job(_1))
end,
      street_vendor = function(_1)
  return ("%sthe street vendor")
  :format(trim_job(_1))
end,
      street_vendor2 = function(_1)
  return ("%sthe street vendor")
  :format(trim_job(_1))
end,
      trader = function(_1)
  return ("%sthe trader")
  :format(trim_job(_1))
end,
      trainer = function(_1)
  return ("%sthe trainer")
  :format(trim_job(_1))
end,
      wandering_vendor = function(_1)
  return ("%sthe wandering vendor")
  :format(trim_job(_1))
end
    },
    place_failure = {
      ally = function(_1)
  return ("%s loses %s way.")
  :format(name(_1), his(_1))
end,
      other = function(_1)
  return ("%s is killed.")
  :format(name(_1))
end
    },
    quality = {
      godly = function(_1)
  return ("{%s}")
  :format(_1)
end,
      miracle = function(_1)
  return ("<%s>")
  :format(_1)
end
    },
    something = "something",
    weight = {
      gain = function(_1)
  return ("%s gain%s weight.")
  :format(name(_1), s(_1))
end,
      lose = function(_1)
  return ("%s lose%s weight.")
  :format(name(_1), s(_1))
end
    },
    you = "you"
  }
}