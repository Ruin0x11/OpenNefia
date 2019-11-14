return {
  chara_status = {
    gain_new_body_part = function(_1, _2)
  return ("%s grow%s a new %s!")
  :format(name(_1), s(_1), _2)
end,
    karma = {
      changed = function(_1)
  return ("Karma(%s)")
  :format(_1)
end,
      you_are_criminal_now = "You are a criminal now.",
      you_are_no_longer_criminal = "You are no longer a criminal."
    }
  }
}