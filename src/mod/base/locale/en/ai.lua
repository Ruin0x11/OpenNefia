return {
  ai = {
    ally = {
      sells_items = function(_1, _2, _3)
  return ("%s sells %s item%s and earns %s gold piece%s.")
  :format(name(_1), _2, s(_2), _3, s(_3))
end,
      visits_trainer = function(_1)
  return ("%s visits a trainer and develops %s potential!")
  :format(basename(_1), his(_1))
end
    },
    crushes_wall = function(_1)
  return ("%s crush%s the wall!")
  :format(name(_1), s(_1, true))
end,
    fire_giant = { "Filthy monster!", "Go to hell!", "I'll get rid of you.", "Eat this!" },
    makes_snowman = function(_1, _2)
  return ("%s make%s %s!")
  :format(name(_1), s(_1), itemname(_2))
end,
    snail = { "Snail!", "Kill!" },
    snowball = { "*grin*", "Fire in the hole!", "Tee-hee-hee!", "Eat this!", "Watch out!", "Scut!" },
    swap = {
      displace = function(_1, _2)
  return ("%s displace%s %s.")
  :format(name(_1), s(_1), name(_2))
end,
      glare = function(_1, _2)
  return ("%s glare%s at %s.")
  :format(name(_2), s(_2), name(_1))
end
    }
  }
}