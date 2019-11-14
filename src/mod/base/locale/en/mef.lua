return {
  mef = {
    attacks_illusion_in_mist = function(_1)
  return ("%s attack%s an illusion in the mist.")
  :format(name(_1), s(_1))
end,
    bomb_counter = function(_1)
  return ("*%s*")
  :format(_1)
end,
    destroys_cobweb = function(_1)
  return ("%s destroy%s the cobweb.")
  :format(name(_1), s(_1))
end,
    is_burnt = function(_1)
  return ("%s %s burnt.")
  :format(name(_1), is(_1))
end,
    is_caught_in_cobweb = function(_1)
  return ("%s %s caught in a cobweb.")
  :format(name(_1), is(_1))
end,
    melts = function(_1)
  return ("%s melt%s.")
  :format(name(_1), s(_1))
end,
    steps_in_pool = function(_1)
  return ("%s step%s in the pool.")
  :format(name(_1), s(_1))
end
  }
}