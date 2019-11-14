return {
  tcg = {
    action = {
      block = "↑   ブロックする。",
      declare_attack = "↑   攻撃を宣言する。",
      no_action_available = "可能な行動はない。",
      put = "↑   カードを出す。",
      sacrifice = "↓   カードを捧げてマナを得る(1ターンに1回)。",
      surrender = "降参する",
      use_skill = "決定 スキルを使用する。"
    },
    card = {
      creature = "クリーチャー",
      domain = "ドメイン",
      land = "土地",
      race = "種族",
      rare = "レア度",
      skill = "スキル",
      spell = "スペル"
    },
    card_not_available = "未実装のカード",
    deck = {
      choices = {
        edit = "デッキの構築",
        set_as_main = "メインデッキに設定"
      },
      color = {
        black = "黒",
        blue = "青",
        red = "赤",
        silver = "銀",
        white = "白"
      },
      name = function(_1)
  return ("%sのデッキ")
  :format(_1)
end,
      new = "新規作成"
    },
    domain = {
      jure = "ジュア",
      kumiromi = "クミロミ",
      lulwy = "ルルウィ",
      mani = "マニ",
      yacatect = "ヤカテクト"
    },
    end_main_phase = "メインフェイズを終了する。",
    menu = {
      deck = "デッキ",
      just_exit = "セーブしないで終了",
      list = "候補",
      save_and_exit = "セーブして終了"
    },
    no_blocker = "ブロックしない。",
    put = {
      field_full = "これ以上は場に出せない。",
      not_enough_mana = "マナが足りない。"
    },
    ref = {
      choose_one_card = "自分のデッキからカードを1枚選び受け取る。",
      draws_two_cards = "プレイヤーはカードを2枚ドローする。",
      return_creature = "場のクリーチャー1体を選択し、所有者の手札に戻す。"
    },
    sacrifice = {
      opponent = "相手はカードを捧げた。",
      you = "カードを捧げた。"
    },
    select = {
      hint = ",Tab [フィルター切替]  決定ｷｰ [カード選択]  ｷｬﾝｾﾙｷｰ [終了]"
    }
  }
}