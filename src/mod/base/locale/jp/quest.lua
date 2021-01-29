return {
  quest = {
    arena = {
      stairs_appear = "外への階段が現れた。",
      you_are_victorious = "あなたは勝利した！",
      your_team_is_defeated = "あなたのチームは敗北した。",
      your_team_is_victorious = "あなたのチームは勝利した！"
    },
    harvest = {
      complete = "無事に納入を終えた！",
      fail = "納入は間に合わなかった…"
    },
    completed = "クエストを達成した！",
    completed_taken_from = function(_1)
  return ("%sから受けた依頼を完了した。")
  :format(_1)
end,
    conquer = {
      complete = "討伐に成功した！",
      fail = "討伐に失敗した…"
    },
    deliver = {
      you_commit_a_serious_crime = "あなたは重大な罪を犯した!"
    },
    escort = {
      complete = "あなたは無事に護衛の任務を終えた。",
      failed = {
        assassin = "「おい、暗殺者が私の後ろにいるぞ」",
        deadline = function(_1)
  return ("「時間切れだ。こうなったら…」%sは火をかぶった。")
  :format(name(_1))
end,
        poison = "「毒が、毒がー！」"
      },
      you_failed_to_protect = "あなたは護衛の任務を果たせなかった。",
      you_left_your_client = "あなたはクライアントを置き去りにした。"
    },
    failed_taken_from = function(_1)
  return ("%sから受けた依頼は失敗に終わった。")
  :format(_1)
end,
    gain_fame = function(_1)
  return ("%sの名声値を手に入れた。")
  :format(_1)
end,
    giver = {
      complete = {
        done_well = function(_1)
  return ("依頼を無事終わらせたよう%s%s")
  :format(dana(_1), thanks(_1, 2))
end,
        extra_coins = function(_1)
  return ("予想以上にいい働きだったから、幾らか色を付けておいた%s")
  :format(yo(_1))
end,
        music_tickets = function(_1)
  return ("予想以上の盛り上がりだったから、おまけをあげる%s")
  :format(yo(_1))
end,
        take_reward = function(_1)
  return ("報酬の%sを受けとって%s")
  :format(_1, kure(_1))
end
      },
      days_to_perform = function(_1, _2)
  return ("期限は残り%s日%s")
  :format(_1, da(_2))
end,
      have_something_to_ask = function(_1)
  return ("%sに頼みたいことがある%s")
  :format(kimi(_1, 3), nda(_1))
end,
      how_about_it = function(_1)
  return ("依頼を受けてくれるの%s")
  :format(kana(_1, 1))
end
    },
    hunt = {
      complete = "エリアを制圧した！",
      remaining = function(_1)
  return ("[殲滅依頼]残り%s体] ")
  :format(_1)
end
    },
    info = {
      ["and"] = "と",
      collect = {
        target = function(_1)
  return ("%sに住む人物")
  :format(_1)
end,
        text = function(_1, _2)
  return ("依頼人のために%sから%sを調達")
  :format(_2, _1)
end
      },
      conquer = {
        text = function(_1)
  return ("%sの討伐")
  :format(_1)
end,
        unknown_monster = "正体不明の存在"
      },
      days = function(_1)
  return ("%s日")
  :format(_1)
end,
      deliver = {
        deliver = "を配達",
        text = function(_1, _2, _3)
  return ("%sに住む%sに%s")
  :format(_2, _3, _1)
end
      },
      escort = {
        text = function(_1)
  return ("クライアントを%sまで護衛")
  :format(_1)
end
      },
      gold_pieces = function(_1)
  return ("金貨%s枚")
  :format(_1)
end,
      harvest = {
        text = function(_1)
  return ("%sの作物の納入")
  :format(_1)
end
      },
      heavy = "(凄く重い)",
      hunt = {
        text = "全ての敵の殲滅"
      },
      huntex = {
        text = "全ての敵の殲滅"
      },
      no_deadline = "即時",
      now = function(_1)
  return ("(現在%s)")
  :format(_1)
end,
      party = {
        points = function(_1)
  return ("%sポイント")
  :format(_1)
end,
        text = function(_1)
  return ("%sの獲得")
  :format(_1)
end
      },
      supply = {
        text = function(_1)
  return ("%sの納入")
  :format(_1)
end
      }
    },
    journal = {
      client = "依頼: ",
      complete = "依頼 完了",
      deadline = "期限: ",
      detail = "内容: ",
      job = "依頼",
      location = "場所: ",
      remaining = "残り",
      report_to_the_client = "あとは報告するだけだ。",
      reward = "報酬: "
    },
    journal_updated = "ジャーナルが更新された。",
    lose_fame = function(_1)
  return ("名声値を%s失った。")
  :format(_1)
end,
    minutes_left = function(_1)
  return ("クエスト[残り%s分]")
  :format(_1)
end,
    party = {
      complete = "パーティーは大盛況だった！",
      fail = "パーティーはぐだぐだになった…",
      final_score = function(_1)
  return ("最終得点は%sポイントだった！")
  :format(_1)
end,
      is_over = "パーティーは終了した。",
      is_satisfied = function(_1)
  return ("%sは満足した。")
  :format(basename(_1))
end,
      total_bonus = function(_1)
  return ("(合計ボーナス:%s%%) ")
  :format(_1)
      end,
      points = "ポイント"
    },
    you_were_defeated = "あなたは敗北した。"
  }
}
