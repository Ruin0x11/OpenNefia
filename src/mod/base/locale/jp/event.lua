return {
  event = {
    alarm = "けたたましい警報が鳴り響いた！",
    beggars = "強盗があなたに目をつけた！",
    bomb = " *ゴゴゴゴゴゴ* ",
    death_penalty_not_applied = "レベル6に達していないので能力値の減少はない。",
    ehekatl = "…ぅっぅぅ…っぅぅっぅううううみみゃぁ！！！",
    guarded_by_lord = function(_1, _2)
  return ("気をつけろ！この階は%sの守護者、%sによって守られている。")
  :format(_1, basename(_2))
end,
    guest_already_left = "ゲストはすでに居なくなっていた。",
    guest_lost_his_way = "ゲストは行方不明になった。",
    little_sister = "ビッグダディの肩から、リトルシスターが滑り落ちた。「Mr Bubbles！！」",
    my_eyes = function(_1)
  return ("%s「目が！目がー！！」")
  :format(name(_1))
end,
    okaeri = { "「おかえり」", "「よう戻ったか」", "「無事で何よりです」", "「おかか♪」", "「待ってたよ」", "「おかえりなさい！」" },
    pael = "パエル「おかあさんーー！！」",
    ragnarok = "終末の日が訪れた。",
    reached_deepest_level = "どうやら最深層まで辿り着いたらしい…",
    seal_broken = "この階の封印が解けたようだ！",
    you_lost_some_money = "金貨を幾らか失った…"
  }
}
