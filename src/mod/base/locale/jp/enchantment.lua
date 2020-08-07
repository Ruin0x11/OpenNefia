return {
  enchantment = {
    it = function(desc)
       return ("それは%s"):format(desc)
    end,
    item_ego = {
      major = {
        _0 = "烈火の",
        _1 = "静寂の",
        _2 = "氷結の",
        _3 = "稲妻の",
        _4 = "防衛者の",
        _5 = "癒し手の",
        _6 = "耐盲目の",
        _7 = "耐麻痺の",
        _8 = "耐混乱の",
        _9 = "耐恐怖の",
        _10 = "睡眠防止の"
      },
      minor = {
        _0 = "唄う",
        _1 = "召使の",
        _2 = "従者の",
        _3 = "呻く",
        _4 = "輝く",
        _5 = "異彩の",
        _6 = "魔力を帯びた",
        _7 = "闇を砕く",
        _8 = "強力な",
        _9 = "頼れる"
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
