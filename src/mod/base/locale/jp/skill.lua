return {
  skill = {
    _10 = {
      decrease = function(_1)
  return ("%sは少し贅肉が増えたような気がした。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sはより強くなった。")
  :format(name(_1))
end
    },
    _11 = {
      decrease = function(_1)
  return ("%sは我慢ができなくなった。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは我慢することの快感を知った。")
  :format(name(_1))
end
    },
    _12 = {
      decrease = function(_1)
  return ("%sは不器用になった。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは器用になった。")
  :format(name(_1))
end
    },
    _13 = {
      decrease = function(_1)
  return ("%sは感覚のずれを感じた。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは世界をより身近に感じるようになった。")
  :format(name(_1))
end
    },
    _14 = {
      decrease = function(_1)
  return ("%sの学習意欲が低下した。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは急に色々なことを学びたくなった。")
  :format(name(_1))
end
    },
    _15 = {
      decrease = function(_1)
  return ("%sは何でもすぐ諦める。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sの意思は固くなった。")
  :format(name(_1))
end
    },
    _16 = {
      decrease = function(_1)
  return ("%sは魔力の衰えを感じた。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは魔力の上昇を感じた。")
  :format(name(_1))
end
    },
    _17 = {
      decrease = function(_1)
  return ("%sは急に人前に出るのが嫌になった。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは周囲の視線を心地よく感じる。")
  :format(name(_1))
end
    },
    _18 = {
      decrease = function(_1)
  return ("%sは遅くなった。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは周りの動きが遅く見えるようになった。")
  :format(name(_1))
end
    },
    _19 = {
      decrease = function(_1)
  return ("%sは不幸になった。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは幸運になった。")
  :format(name(_1))
end
    },
    _2 = {
      decrease = function(_1)
  return ("%sは生命力の衰えを感じた。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sは生命力の上昇を感じた。")
  :format(name(_1))
end
    },
    _3 = {
      decrease = function(_1)
  return ("%sはマナの衰えを感じた。")
  :format(name(_1))
end,
      increase = function(_1)
  return ("%sはマナの向上を感じた。")
  :format(name(_1))
end
    },
    default = {
      decrease = function(_1, _2)
  return ("%sは%sの技術の衰えを感じた。")
  :format(name(_1), _2)
end,
      increase = function(_1, _2)
  return ("%sは%sの技術の向上を感じた。")
  :format(name(_1), _2)
end
    },
    gained = function(_1)
  return ("あなたは「%s」の能力を得た。")
  :format(_1)
end
  }
}