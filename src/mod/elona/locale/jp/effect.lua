return {
  status_ailment = {
    message = {
      bleeding = {
        apply = function(_1)
  return ("%sは血を流し始めた。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sの出血は止まった。")
  :format(name(_1))
end
      },
      blindness = {
        apply = function(_1)
  return ("%sは盲目になった。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは盲目から回復した。")
  :format(name(_1))
end
      },
      confusion = {
        apply = function(_1)
  return ("%sは混乱した。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは混乱から回復した。")
  :format(name(_1))
end
      },
      dimming = {
        apply = function(_1)
  return ("%sは朦朧とした。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sの意識ははっきりした。")
  :format(name(_1))
end
      },
      drunk = {
        apply = function(_1)
  return ("%sは酔っ払った。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sの酔いは覚めた。")
  :format(name(_1))
end
      },
      fear = {
        apply = function(_1)
  return ("%sは恐怖に侵された。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは恐怖から立ち直った。")
  :format(name(_1))
end
      },
      insanity = {
        apply = function(_1)
  return ("%sは気が狂った。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは正気に戻った。")
  :format(name(_1))
end
      },
      paralysis = {
        apply = function(_1)
  return ("%sは麻痺した。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは麻痺から回復した。")
  :format(name(_1))
end
      },
      poison = {
        apply = function(_1)
  return ("%sは毒におかされた。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは毒から回復した。")
  :format(name(_1))
end
      },
      sick = {
        apply = function(_1)
  return ("%sは病気になった。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sの病気は治った。")
  :format(name(_1))
end
      },
      sleep = {
        apply = function(_1)
  return ("%sは眠りにおちた。")
  :format(name(_1))
end,
        heal = function(_1)
  return ("%sは心地よい眠りから覚めた。")
  :format(name(_1))
end
      }
    },
    name = {
      angry = {
        _0 = "激怒",
        _1 = "狂乱"
      },
      bleeding = {
        _0 = "切り傷",
        _1 = "出血",
        _2 = "大出血"
      },
      blind = "盲目",
      burden = {
        _0 = "",
        _1 = "重荷",
        _2 = "圧迫",
        _3 = "超過",
        _4 = "潰れ中"
      },
      choked = "窒息",
      confused = "混乱",
      dimmed = {
        _0 = "朦朧",
        _1 = "混濁",
        _2 = "気絶"
      },
      drunk = "酔払い",
      fear = "恐怖",
      gravity = "重力",
      hunger = {
        _0 = "餓死中",
        _1 = "飢餓",
        _10 = "満腹",
        _11 = "満腹",
        _12 = "食過ぎ",
        _2 = "空腹",
        _3 = "空腹",
        _4 = "空腹",
        _5 = "",
        _6 = "",
        _7 = "",
        _8 = "",
        _9 = ""
      },
      insane = {
        _0 = "不安定",
        _1 = "狂気",
        _2 = "崩壊"
      },
      paralyzed = "麻痺",
      poison = {
        _0 = "毒",
        _1 = "猛毒"
      },
      sick = {
        _0 = "病気",
        _1 = "重病"
      },
      sleep = {
        _0 = "睡眠",
        _1 = "爆睡"
      },
      sleepy = {
        _0 = "睡眠可",
        _1 = "要睡眠",
        _2 = "要睡眠"
      },
      tired = {
        _0 = "軽疲労",
        _1 = "疲労",
        _2 = "過労"
      },
      wet = "濡れ"
    }
  }
}
