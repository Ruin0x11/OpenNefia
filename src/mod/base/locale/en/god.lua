return {
  god = {
    desc = {
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
