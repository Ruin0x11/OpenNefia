return {
  autoexplore = {
      confused = function(_1)
          return ("You are confused. Stopping %s."):format(_1)
      end,
      enemy_sighted = function(_1, _2)
          return ("An enemy (%s) was sighted. Stopping %s."):format(name(_1), _2)
      end,
      explore = {
          cannot_in_overworld = "You can't explore in the overworld.",
          name = "exploration",
          start = "Exploring."
      },
      key_pressed = function(_1)
          return ("Key was pressed. Stopping %s."):format(_1)
      end,
      pathing = {
          aborted = function(_1)
              return ("Aborting %s."):format(_1)
          end,
          finished = function(_1)
              return ("%s finished."):format(capitalize(_1))
          end,
          halt = {
              chara = function(_1)
                  return ("%s is in the way."):format(name(_1))
              end,
              danger = "Something dangerous is there.",
              default = "There's no unblocked path available.",
              solid = "The destination is blocked.",
              unknown_tile = "You don't know what's there."
          },
      },
      travel = {
          already_there = "You're already there!",
          name = "travel",
          prompt = "Where would you like to go?",
          start = "Traveling."
      },
  }
}