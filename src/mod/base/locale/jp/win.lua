return {
  win = {
    conquer_lesimas = "信じられない！あなたはネフィアの迷宮「レシマス」を制覇した！",
    watch_event_again = "達成のシーンをもう一度再現する？",
    window = {
      arrived_at_tyris = function(_1, _2, _3)
  return ("%s年%s月%s日に、あなたはノースティリスに到着した。")
  :format(_1, _2, _3)
end,
      caption = "制覇までの軌跡",
      comment = function(_1)
  return ("あなたは「%s」とコメントした。")
  :format(_1)
end,
      have_killed = function(_1, _2)
  return ("最深で%s階相当まで到達し、%s匹の敵を殺して、")
  :format(_1, _2)
end,
      lesimas = function(_1, _2, _3)
  return ("%s年%s月%s日にレシマスを制覇して、")
  :format(_1, _2, _3)
end,
      score = function(_1)
  return ("現在%s点のスコアを叩き出している。")
  :format(_1)
end,
      title = "*勝利*",
      your_journey_continues = "…あなたの旅はまだ終わらない。"
    },
    you_acquired_codex = function(_1, _2)
  return ("%s%sに祝福あれ！あなたは遂にレシマスの秘宝を手にいれた！")
  :format(_1, _2)
end
  }
}