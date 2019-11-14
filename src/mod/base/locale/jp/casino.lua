return {
  casino = {
    blackjack = {
      choices = {
        bet = function(_1)
  return ("%s枚賭ける")
  :format(_1)
end,
        quit = "やめる"
      },
      desc = {
        _0 = "ブラックジャックは、カードの合計を21に近づけるゲームです。",
        _1 = "J,Q,Kは10に、Aは1または11に数えられます。21を越えると負けです。",
        _2 = "では、賭けるチップを宣言してください。",
        _3 = "チップが多いほど、景品の質があがります。"
      },
      game = {
        bad_feeling = "このカードは悪い予感がする…",
        bets = function(_1)
  return ("賭けチップ %s枚")
  :format(_1)
end,
        cheat = {
          dialog = "イカサマだ！",
          response = "濡れ衣だ！",
          text = "イカサマが見つかってしまった…"
        },
        choices = {
          cheat = function(_1)
  return ("イカサマ(器用%s)")
  :format(_1)
end,
          hit = "もう一枚引く(運)",
          stay = "これに決める"
        },
        dealer = "　親",
        dealers_hand = function(_1)
  return ("親の合計は%sです。")
  :format(_1)
end,
        leave = "戻る",
        loot = function(_1)
  return ("アイテム：%sを戦利品に加えた！")
  :format(itemname(_1))
end,
        result = {
          choices = {
            leave = "戻る",
            next_round = "次の勝負へ"
          },
          draw = "勝負は引き分けです。",
          lose = "あなたの負けです。",
          win = "おめでとうございます。あなたの勝ちです。"
        },
        total_wins = function(_1)
  return ("おめでとうございます。あなたは%s連勝しました。")
  :format(_1)
end,
        wins = function(_1)
  return ("現在%s連勝中")
  :format(_1)
end,
        you = "あなた",
        your_hand = function(_1)
  return ("あなたの合計は%sです。")
  :format(_1)
end
      },
      no_chips = "お客様はチップをもっていません。"
    },
    can_acquire = "幾つかの戦利品がある。",
    chips_left = function(_1)
  return ("カジノチップ残り %s枚")
  :format(_1)
end,
    talk_to_dealer = "ディーラーに話しかけた。",
    window = {
      choices = {
        blackjack = "ブラックジャック",
        leave = "店を出る"
      },
      desc = {
        _0 = "カジノ《フォーチュンクッキー》へようこそ。",
        _1 = "チップマテリアルと引き換えにゲームをすることができます。",
        _2 = "ごゆっくりお楽しみ下さい。"
      },
      first = {
        _0 = "お客様は初めてのご利用のようですね。",
        _1 = "当店からチップマテリアルを10枚進呈します。"
      },
      title = "カジノ《フォーチュンクッキー》"
    },
    you_get = function(_1, _2, _3)
  return ("%sを%s個手に入れた！(所持数:%s個)")
  :format(_2, _1, _3)
end,
    you_lose = function(_1, _2, _3)
  return ("%sを%s個失った(残り:%s個)")
  :format(_2, _1, _3)
end
  }
}