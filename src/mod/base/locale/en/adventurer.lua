return {
  news = {
    accomplishment = {
      text = function(_1, _2, _3)
  return ("%s %s has finished a quest and gained %s fame.")
  :format(_1, _2, _3)
end,
      title = "Accomplishment"
    },
    discovery = {
      text = function(_1, _2, _3, _4)
  return ("%s %s has discovered %s in %s.")
  :format(_1, _2, _3, _4)
end,
      title = "Discovery"
    },
    growth = {
      text = function(_1, _2, _3)
  return ("%s %s has gained experience and achieved level %s.")
  :format(_1, _2, _3)
end,
      title = "Growth"
    },
    recovery = {
      text = function(_1, _2)
  return ("%s %s has fully recovered from injury.")
  :format(_1, _2)
end,
      title = "Recovery from injury"
    },
    retirement = {
      text = function(_1, _2)
  return ("%s %s realizes the limitations and leaves North Tyris.")
  :format(_1, _2)
end,
      title = "Retirement"
    }
  }
}