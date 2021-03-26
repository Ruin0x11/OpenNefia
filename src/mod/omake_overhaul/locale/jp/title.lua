return {
   titles = {
      title = {
         _ = {
            omake_overhaul = {
               decoy = {
                  name = "替え玉",
                  condition = "イークの首領『ルードルボ』を撃破",
                  info = {
                     effect = "イークを召喚できるようになる。",

                     killed = function(_1)
                        return ("イークの首領『ルードルボ』殺害数：%s"):format(_1)
                     end
                  }
               },
               born_in_a_temple = {
                  name = "寺生まれ",
                  condition = "ピラミッドの主『ツェン』を撃破",
                  info = {
                     effect = "たまに呪いを無効にする。",

                     killed = function(_1)
                        return ("ピラミッドの主『ツェン』殺害数：%s"):format(_1)
                     end
                  }
               },
               god_of_war = {
                  name = "戦鬼",
                  condition = "戦術スキルレベル100到達",
                  info = {
                     effect = "スウォームの効果範囲が拡大する。",

                     killed = {
                        bubbles = function(_1)
                           return ("バブル殺害数：%s"):format(_1)
                        end,
                        blue_bubbles = function(_1)
                           return ("ブルーバブル殺害数：%s"):format(_1)
                        end,
                        mass_monsters = function(_1)
                           return ("塊の怪物殺害数：%s"):format(_1)
                        end,
                        cubes = function(_1)
                           return ("キューブ殺害数：%s"):format(_1)
                        end
                     }
                  }
               }
            }
         }
      }
   }
}
