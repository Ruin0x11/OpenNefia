return {
   sleep_event = {
      breakfast = {
         event = {
            title = "Breakfast",
            text = {
               one = function(_1)
                  return ("Apparently, %s is preparing breakfast."):format(name(_1))
               end,
               multiple = function(_1)
                  return ("Apparently, %s and the others are preparing breakfast."):format(name(_1))
               end
            },
            choices = {
               _1 = "(Eat)",
               _2 = "(Leave)"
            }
         },
         rejected = {
            function(_1)
               return ("%sはしょんぼりしている…。"):format(name(_1))
            end,
            function(_1)
               return ("%sは超ショックを受けている！"):format(name(_1))
            end,
            function(_1)
               return ("%sは無言で食器を片づけ始めた。"):format(name(_1))
            end
         }
      },
      handmade_gift = {
         event = {
            title = "手作りのプレゼント",
            text = {
               one = function(_1)
                  return ("%sが夜なべをして防具を作ってくれたようだ。"):format(name(_1))
               end,
               multiple = function(_1)
                  return ("%sたちが夜なべをして防具を作ってくれたようだ。"):format(name(_1))
               end
            },
            choices = {
               _1 = "助かる",
               _2 = "いらない"
            }
         },
         looks_happy = function(_1)
            return ("%sは嬉しそうだ。"):format(name(_1))
         end,
         throws_in_trash = function(_1)
            return ("%sは半泣きで防具をゴミに出した。"):format(name(_1))
         end
      },
      handknitted_gift = {
         event = {
            title = "手編みのプレゼント",
            text = {
               one = function(_1)
                  return ("%sが夜なべをして防具を編んでくれたようだ。"):format(name(_1))
               end,
               multiple = function(_1)
                  return ("%sたちが夜なべをして防具を編んでくれたようだ。"):format(name(_1))
               end
            },
            choices = {
               _1 = "ありがとう",
               _2 = "いらん"
            }
         },
         looks_happy = function(_1)
            return ("%sは上機嫌だ。"):format(name(_1))
         end,
         throws_in_trash = function(_1)
            return ("%sは無言で防具を引き裂いた。"):format(name(_1))
         end
      }
   }
}
