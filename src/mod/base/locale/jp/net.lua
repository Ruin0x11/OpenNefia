return {
  net = {
    alias = {
      cannot_vote_until = function(_1)
  return ("あなたの投票権はまだ復活していない(%sまで)")
  :format(_1)
end,
      choice = "投票項目",
      hint = "決定 [投票する項目を選択]  ",
      i_like = function(_1)
  return ("「%sは素敵！」")
  :format(_1)
end,
      message = "素敵な異名コンテスト♪1",
      need_to_wait = "まだ投票権が復活していない。",
      ok = "オッケー",
      prompt = "どの候補に投票する？",
      rank = function(_1)
  return ("第%s位")
  :format(_1)
end,
      selected = "候補",
      submit = "あなたの異名を登録する",
      title = "投票箱",
      vote = "備考",
      you_vote = "投票した。"
    },
    chat = {
      message = function(_1)
  return ("「%s」")
  :format(_1)
end,
      sent_message = function(_1, _2, _3)
  return ("%s%s%s")
  :format(_1, _2, _3)
end,
      wait_more = "もう少し待った方がいい気がする。"
    },
    death = {
      sent_message = function(_1, _2, _3, _4, _5)
  return ("%s%sは%sで%s%s")
  :format(_1, _2, _4, _3, _5)
end
    },
    failed_to_receive = "受信に失敗した。",
    failed_to_send = "送信に失敗した。",
    news = {
      bomb = function(_1, _2, _3, _4)
  return ("[パルミア・タイムズ %s] %sで核爆弾炸裂。復旧には3日を要する見込み")
  :format(_1, _4)
end,
      ehekatl = function(_1, _2, _3)
  return ("[パルミア・タイムズ %s] %s%sエヘカトル像を入手")
  :format(_1, _2, _3)
end,
      fire = function(_1)
  return ("[パルミア・タイムズ %s] ノイエルで大火災。何者かが巨人を解放か")
  :format(_1)
end,
      void = function(_1, _2, _3, _4)
  return ("[パルミア・タイムズ %s] %s%sすくつ%s階層に到達")
  :format(_1, _2, _3, _4)
end
    },
    wish = {
      sent_message = function(_1, _2, _3, _4)
  return ("%s%sは狂喜して叫んだ。%s%s")
  :format(_1, _2, _3, _4)
end
    }
  }
}