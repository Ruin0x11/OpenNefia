return {
  casino = {
    blackjack = {
      choices = {
        bet = function(_1)
  return ("Bet %s chip%s.")
  :format(_1, s(_1))
end,
        quit = "I quit."
      },
      desc = {
        _0 = "In Blackjack, the hand with the highest total wins as long as it",
        _1 = "doesn't exceed 21. J,Q,K are counted as 10 and A is counted as 1 or 11.",
        _2 = "More bets means better rewards.",
        _3 = "How many tips would you like to bet?"
      },
      game = {
        bad_feeling = "I have a bad feeling about this card...",
        bets = function(_1)
  return ("Bets: %s")
  :format(_1)
end,
        cheat = {
          dialog = "Cheater!",
          response = "I didn't do it!",
          text = "You are caught in cheating..."
        },
        choices = {
          cheat = function(_1)
  return ("Cheat. (Dex:%s)")
  :format(_1)
end,
          hit = "Hit me. (Luck)",
          stay = "Stay."
        },
        dealer = "Dealer",
        dealers_hand = function(_1)
  return ("The dealer's hand is %s.")
  :format(_1)
end,
        leave = "Great.",
        loot = function(_1)
  return ("%s has been added to your loot list!")
  :format(itemname(_1))
end,
        result = {
          choices = {
            leave = "Bah...!",
            next_round = "To the next round."
          },
          draw = "The match is a draw.",
          lose = "You lose.",
          win = "Congratulations, you win."
        },
        total_wins = function(_1)
  return ("Congratulations! You've won %s times in a row.")
  :format(_1)
end,
        wins = function(_1)
  return ("Wins: %s")
  :format(_1)
end,
        you = "   You",
        your_hand = function(_1)
  return ("Your hand is %s.")
  :format(_1)
end
      },
      no_chips = "Sorry sir, you don't seem to have casino chips."
    },
    can_acquire = "There're some items you can acquire.",
    chips_left = function(_1)
  return ("Casino chips left: %s")
  :format(_1)
end,
    talk_to_dealer = "You talk to the dealer.",
    window = {
      choices = {
        blackjack = "I want to play Blackjack.",
        leave = "Later."
      },
      desc = {
        _0 = "Welcome to the casino, Fortune cookie!",
        _1 = "You can bet the casino chips you have and play some games.",
        _2 = "Enjoy your stay."
      },
      first = {
        _0 = "Looks like you play for the first time, sir.",
        _1 = "We're offering you 10 free casino chips to try our games."
      },
      title = "Casino <<Fortune Cookie>>"
    },
    you_get = function(_1, _2, _3)
  return ("You get %s %s%s! (Total:%s)")
  :format(_1, _2, s(_1), _3)
end,
    you_lose = function(_1, _2, _3)
  return ("You lose %s %s%s. (Total:%s)")
  :format(_1, _2, s(_1), _3)
end
  }
}