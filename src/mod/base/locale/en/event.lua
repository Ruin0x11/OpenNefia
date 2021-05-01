return {
  event = {
    alarm = "*beeeeeep!* An alarm sounds loudly!",
    beggars = "Blaggers pick on you!",
    bomb = "* RRROOM-KABOOOOM*",
    death_penalty_not_applied = "Death penalty won't be applied until you hit Lv 6.",
    ehekatl = "memememw...MEMEMEM...MEWWWWWW!",
    guarded_by_lord = function(_1, _2)
  return ("Be aware! This level is guarded by the lord of %s, %s.")
  :format(_1, basename(_2))
end,
    guest_already_left = "It seems the guest has already left your house.",
    guest_lost_his_way = "The guest lost his way.",
    little_sister = "The little sister slips from Big daddy's shoulder, \"Mr.Bubbles!\"",
    my_eyes = function(_1)
  return ("%s shout%s \"Eyes! My eyes!\"")
  :format(name(_1), s(_1))
end,
    okaeri = { "Welcome home!", "Hey, dear.", "You're back!", "I was waiting for you.", "Nice to see you again." },
    pael = "\"M-mom...!!\"",
    ragnarok = "Let's Ragnarok!",
    reached_deepest_level = "It seems you have reached the deepest level of this dungeon.",
    seal_broken = "The seal of this level is now broken!",
    you_lost_some_money = "You lost some money."
  }
}
