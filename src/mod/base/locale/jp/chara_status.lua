return {
  chara_status = {
    gain_new_body_part = function(_1, _2)
  return ("%sの身体から新たな%sが生えてきた！")
  :format(name(_1), _2)
end,
    karma = {
      changed = function(_1)
  return ("カルマ変動(%s) ")
  :format(_1)
end,
      you_are_criminal_now = "あなたは今や罪人だ。",
      you_are_no_longer_criminal = "あなたの罪は軽くなった。"
    }
  }
}