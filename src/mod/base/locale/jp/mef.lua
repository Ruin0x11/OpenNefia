return {
  mef = {
    attacks_illusion_in_mist = function(_1)
  return ("%sは霧の中の幻影を攻撃した。")
  :format(name(_1))
end,
    bomb_counter = function(_1)
  return (" *%s* ")
  :format(_1)
end,
    destroys_cobweb = function(_1)
  return ("%sは蜘蛛の巣を振り払った。")
  :format(name(_1))
end,
    is_burnt = function(_1)
  return ("%sは燃えた。")
  :format(name(_1))
end,
    is_caught_in_cobweb = function(_1)
  return ("%sは蜘蛛の巣にひっかかった。")
  :format(name(_1))
end,
    melts = function(_1)
  return ("%sは酸に焼かれた。")
  :format(name(_1))
end,
    steps_in_pool = function(_1)
  return ("%sは地面の液体を浴びた。")
  :format(name(_1))
end
  }
}