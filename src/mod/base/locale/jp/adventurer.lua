return {
  news = {
    accomplishment = {
      text = function(_1, _2, _3)
  return ("%s%sはクエストを達成し、%sの名声を手にした。")
  :format(_1, _2, _3)
end,
      title = "クエストの達成"
    },
    discovery = {
      text = function(_1, _2, _3, _4)
  return ("%s%sは%sで%sを入手した。")
  :format(_1, _2, _4, _3)
end,
      title = "アイテム発見"
    },
    growth = {
      text = function(_1, _2, _3)
  return ("%s%sは経験をつみ、レベル%sになった。")
  :format(_1, _2, _3)
end,
      title = "新たなる力"
    },
    recovery = {
      text = function(_1, _2)
  return ("%s%sは怪我から回復した。")
  :format(_1, _2)
end,
      title = "怪我からの復帰"
    },
    retirement = {
      text = function(_1, _2)
  return ("%s%sは自分の力の限界を悟り、ノースティリスから去っていった。")
  :format(_1, _2)
end,
      title = "引退"
    }
  }
}