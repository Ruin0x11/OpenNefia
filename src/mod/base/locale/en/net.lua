return {
  net = {
    alias = {
      cannot_vote_until = function(_1)
  return ("You can't vote until %s.")
  :format(_1)
end,
      choice = "Choice",
      hint = "Enter [Vote] ",
      i_like = function(_1)
  return ("\"I like %s!\"")
  :format(_1)
end,
      message = "Your favorite alias♪1",
      need_to_wait = "You need to wait before submitting a new vote.",
      ok = "Ok",
      prompt = "Which one do you want to vote?",
      rank = function(_1)
  return ("%s")
  :format(ordinal(_1))
end,
      selected = "",
      submit = "Submit your alias.",
      title = "Voting Box",
      vote = "Vote",
      you_vote = "You vote."
    },
    chat = {
      message = function(_1)
  return ("\"%s\"")
  :format(_1)
end,
      sent_message = function(_1, _2, _3)
  return ("%s %s says, %s")
  :format(_1, _2, _3)
end,
      wait_more = "You think you should wait a little more."
    },
    death = {
      sent_message = function(_1, _2, _3, _4)
  return ("%s %s %s in %s %s")
  :format(_1, _2, _3, _4, 5)
end
    },
    failed_to_receive = "Failed to receive messages.",
    failed_to_send = "Failed to send a message.",
    news = {
      bomb = function(_1, _2, _3, _4)
  return ("[Palmia Times %s] Atomic Bomb Explosion in %s")
  :format(_1, _4)
end,
      ehekatl = function(_1, _2, _3)
  return ("[Palmia Times %s] %s %s Gets Statue of Ehekatl")
  :format(_1, _2, _3)
end,
      fire = function(_1)
  return ("[Palmia Times %s] Noyel Big Fire, Someone Releases Giant")
  :format(_1)
end,
      void = function(_1, _2, _3, _4)
  return ("[Palmia Times %s] %s %s Reaches Void %s")
  :format(_1, _2, _3, _4)
end
    },
    wish = {
      sent_message = function(_1, _2, _3, _4)
  return ("%s %s goes wild with joy, %s %s")
  :format(_1, _2, _3, _4)
end
    }
  }
}