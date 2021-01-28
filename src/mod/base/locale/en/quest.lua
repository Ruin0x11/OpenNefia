return {
  quest = {
    arena = {
      stairs_appear = "Stairs appear.",
      you_are_victorious = "You are victorious!",
      your_team_is_defeated = "Your team is defeated.",
      your_team_is_victorious = "Your team is victorious!"
    },
    collect = {
      complete = "You complete the task!",
      fail = "You fail to fulfill your task..."
    },
    completed = "You have completed the quest!",
    completed_taken_from = function(_1)
  return ("You have completed the quest taken from %s.")
  :format(_1)
end,
    conquer = {
      complete = "You successfully slay the target.",
      fail = "You failed to slay the target..."
    },
    deliver = {
      you_commit_a_serious_crime = "You commit a serious crime!"
    },
    escort = {
      complete = "You complete the escort.",
      failed = {
        assassin = "Hey, the assassins are killing me.",
        deadline = function(_1)
  return ("\"I missed the deadline. I don't have a right to live anymore.\" %s pours a bottole of molotov cocktail over %s.")
  :format(name(_1), himself(_1))
end,
        poison = "Poison! P-P-Poison in my vein!!"
      },
      you_failed_to_protect = "You have failed to protect the client.",
      you_left_your_client = "You left your client."
    },
    failed_taken_from = function(_1)
  return ("You have failed the quest taken from %s.")
  :format(_1)
end,
    gain_fame = function(_1)
  return ("You gain %s fame.")
  :format(_1)
end,
    giver = {
      complete = {
        done_well = "You've done well. Thanks. Here's your reward.",
        extra_coins = "I've added some extra coins since you worked really hard.",
        music_tickets = "The party was terrific! I'll give you these tickets as an extra bonus.",
        take_reward = ""
      },
      days_to_perform = function(_1)
  return ("You have %s days to perform the task.")
  :format(_1)
end,
      have_something_to_ask = "",
      how_about_it = "How about it?"
    },
    hunt = {
      complete = "The area is secured!",
      remaining = function(_1)
  return ("%s more to go.")
  :format(_1)
end
    },
    info = {
      ["and"] = " and ",
      collect = {
        target = function(_1)
  return ("the target in %s")
  :format(_1)
end,
        text = function(_1, _2)
  return ("Acquire %s from %s for the client.")
  :format(_1, _2)
end
      },
      conquer = {
        text = function(_1)
  return ("Slay %s.")
  :format(_1)
end,
        unknown_monster = "unknown monster"
      },
      days = function(_1)
  return ("%sd")
  :format(_1)
end,
      deliver = {
        deliver = "",
        text = function(_1, _2, _3)
  return ("Deliver %s to %s who lives in %s.")
  :format(_1, _3, _2)
end
      },
      escort = {
        text = function(_1)
  return ("Escort the client to %s.")
  :format(_1)
end
      },
      gold_pieces = function(_1)
  return ("%s gold pieces")
  :format(_1)
end,
      harvest = {
        text = function(_1)
  return ("Gather harvests weight %s.")
  :format(_1)
end
      },
      heavy = "(Heavy!)",
      hunt = {
        text = "Eliminate monsters."
      },
      huntex = {
        text = "Eliminate monsters"
      },
      no_deadline = "-",
      now = function(_1)
  return (" (Now %s)")
  :format(_1)
end,
      party = {
        points = function(_1)
  return ("%s points")
  :format(_1)
end,
        text = function(_1)
  return ("Gather %s.")
  :format(_1)
end
      },
      supply = {
        text = function(_1)
  return ("Give %s to the client.")
  :format(_1)
end
      }
    },
    journal = {
      client = "Client  : ",
      complete = "Complete",
      deadline = "Deadline: ",
      detail = "Detail  : ",
      job = "Job",
      location = "Location: ",
      remaining = "",
      report_to_the_client = "Report to the client.",
      reward = "Reward  : "
    },
    journal_updated = "Your journal has been updated.",
    lose_fame = function(_1)
  return ("You lose %s fame.")
  :format(_1)
end,
    minutes_left = function(_1)
  return ("%s min left for the quest.")
  :format(_1)
end,
    party = {
      complete = "People had a hell of a good time!",
      fail = "The party turned out to be a big flop...",
      final_score = function(_1)
  return ("Your final score is %s points!")
  :format(_1)
end,
      is_over = "The party is over.",
      is_satisfied = function(_1)
  return ("%s %s satisfied.")
  :format(basename(_1), is(_1))
end,
      total_bonus = function(_1)
  return ("(Total Bonus:%s%%)")
  :format(_1)
      end,
      points = "points"
    },
    you_were_defeated = "You were defeated."
  }
}
