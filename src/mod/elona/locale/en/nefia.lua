return {
   nefia = {
      level = function(_1) return ("%s"):format(ordinal(_1)) end,
      prefix = {
         _0 = {
            _0 = function(_1) return ("Beginner's %s"):format(_1) end,
            _1 = function(_1) return ("Adventurer's %s"):format(_1) end,
            _2 = function(_1) return ("Dangerous %s"):format(_1) end,
            _3 = function(_1) return ("Fearful %s"):format(_1) end,
            _4 = function(_1) return ("King's %s"):format(_1) end
         },
         _1 = {
            _0 = function(_1) return ("Safe %s"):format(_1) end,
            _1 = function(_1) return ("Exciting %s"):format(_1) end,
            _2 = function(_1) return ("Servant's %s"):format(_1) end,
            _3 = function(_1) return ("Shadow %s"):format(_1) end,
            _4 = function(_1) return ("Chaotic %s"):format(_1) end
         }
      },
      no_dungeon_master = "This place is pretty dull. The dungeon master is no longer sighted here.",

      _ = {
         elona = {
            dungeon = {
               name = "Dungeon"
            },
            forest = {
               name = "Forest"
            },
            tower = {
               name = "Tower"
            },
            fort = {
               name = "Fort"
            },
         }
      }
   }
}
