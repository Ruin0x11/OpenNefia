return {
   nefia = {
      level = function(_1) return ("%s層"):format(ordinal(_1)) end,
      prefix = {
         _0 = {
            _0 = function(_1) return ("はじまりの%s"):format(_1) end,
            _1 = function(_1) return ("冒険者の%s"):format(_1) end,
            _2 = function(_1) return ("迷いの%s"):format(_1) end,
            _3 = function(_1) return ("死の%s"):format(_1) end,
            _4 = function(_1) return ("不帰の%s"):format(_1) end
         },
         _1 = {
            _0 = function(_1) return ("安全な%s"):format(_1) end,
            _1 = function(_1) return ("時めきの%s"):format(_1) end,
            _2 = function(_1) return ("勇者の%s"):format(_1) end,
            _3 = function(_1) return ("闇の%s"):format(_1) end,
            _4 = function(_1) return ("混沌の%s"):format(_1) end
         }
      },
      no_dungeon_master = function(_1)
         return ("辺りからは何の緊張感も感じられない。%sの主はもういないようだ。")
            :format(_1)
      end,

      _ = {
         elona = {
            dungeon = {
               name = "洞窟",
            },
            forest = {
               name = "塔",
            },
            tower = {
               name = "森",
            },
            fort = {
               name = "砦"
            },
         }
      }
   }
}
