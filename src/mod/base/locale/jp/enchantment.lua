return {
   enchantment = {
      it = function(desc)
         return ("それは%s"):format(desc)
      end,
      item_ego = {
         major = {
            elona = {
               silence = function(_1) return ("静寂の%s"):format(_1) end,
               res_blind = function(_1) return ("耐盲目の%s"):format(_1) end,
               res_confuse = function(_1) return ("耐混乱の%s"):format(_1) end,
               fire = function(_1) return ("烈火の%s"):format(_1) end,
               cold = function(_1) return ("氷結の%s"):format(_1) end,
               lightning = function(_1) return ("稲妻の%s"):format(_1) end,
               healer = function(_1) return ("癒し手の%s"):format(_1) end,
               res_paralyze = function(_1) return ("耐麻痺の%s"):format(_1) end,
               res_fear = function(_1) return ("耐恐怖の%s"):format(_1) end,
               res_sleep = function(_1) return ("睡眠防止の%s"):format(_1) end,
               defender = function(_1) return ("防衛者の%s"):format(_1) end,
            }
         },
         minor = {
            elona = {
               singing = function(_1) return ("唄う%s"):format(_1) end,
               servants = function(_1) return ("召使の%s"):format(_1) end,
               followers = function(_1) return ("従者の%s"):format(_1) end,
               howling = function(_1) return ("呻く%s"):format(_1) end,
               glowing = function(_1) return ("輝く%s"):format(_1) end,
               conspicuous = function(_1) return ("異彩の%s"):format(_1) end,
               magical = function(_1) return ("魔力を帯びた%s"):format(_1) end,
               enchanted = function(_1) return ("闇を砕く%s"):format(_1) end,
               mighty = function(_1) return ("強力な%s"):format(_1) end,
               trustworthy = function(_1) return ("頼れる%s"):format(_1) end,
            }
         }
      },
      level = "*",
      with_parameters = {
         ammo = {
            max = function(_1)
               return ("[最大%s発]")
                  :format(_1)
            end,
            text = function(_1)
               return ("%sを装填できる")
                  :format(_1)
            end
         },
         attribute = {
            in_food = {
               decreases = function(_1)
                  return ("%sを減衰させる毒素を含んでいる")
                     :format(_1)
               end,
               increases = function(_1)
                  return ("%sを増強させる栄養をもっている")
                     :format(_1)
               end
            },
            other = {
               decreases = function(_1, _2)
                  return ("%sを%s下げる")
                     :format(_1, _2)
               end,
               increases = function(_1, _2)
                  return ("%sを%s上げる")
                     :format(_1, _2)
               end
            }
         },
         extra_damage = function(_1)
            return ("%s属性の追加ダメージを与える")
               :format(_1)
         end,
         invokes = function(_1)
            return ("%sを発動する")
               :format(_1)
         end,
         resistance = {
            decreases = function(_1)
               return ("%sへの耐性を弱化する")
                  :format(_1)
            end,
            increases = function(_1)
               return ("%sへの耐性を授ける")
                  :format(_1)
            end
         },
         skill = {
            decreases = function(_1)
               return ("%sの技能を下げる")
                  :format(_1)
            end,
            increases = function(_1)
               return ("%sの技能を上げる")
                  :format(_1)
            end
         },
         skill_maintenance = {
            in_food = function(_1)
               return ("%sの成長を助ける栄養をもっている")
                  :format(_1)
            end,
            other = function(_1)
               return ("%sを維持する")
                  :format(_1)
            end
         }
      }
   }
}
