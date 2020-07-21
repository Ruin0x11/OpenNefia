return {
  god = {
    desc = {
      _1 = {
      },
      _2 = {
      },
      _3 = {
      },
      _4 = {
      },
      _5 = {
      },
      _6 = {
      },
      _7 = {
      },
      ability = "特殊能力",
      bonus = "ボーナス",
      offering = "　捧げ物",
      window = {
        abandon = "信仰を捨てる",
        believe = function(_1)
  return ("%sを信仰する")
  :format(_1)
end,
        cancel = "やめる",
        convert = function(_1)
  return ("%sに改宗する")
  :format(_1)
end,
        title = function(_1)
  return ("《 %s 》")
  :format(_1)
end
      }
    },
    enraged = function(_1)
  return ("%sは激怒した。")
  :format(_1)
end,
    indifferent = "あなたの信仰は既に限界まで高まっている。",
    pray = {
      do_not_believe = function()
  return ("%sは神を信仰していないが、試しに祈ってみた。")
  :format(you())
end,
      indifferent = function(_1)
  return ("%sはあなたに無関心だ。")
  :format(_1)
end,
      prompt = "あなたの神に祈りを乞う？",
      servant = {
        no_more = "神の使徒は2匹までしか仲間にできない。",
        party_is_full = "仲間が一杯で、神からの贈り物を受け取ることができなかった。",
        prompt_decline = "この贈り物を諦める？"
      },
      you_pray_to = function(_1)
  return ("%sに祈った。")
  :format(_1)
end
    },
    switch = {
      follower = function(_1)
  return ("あなたは今や%sの信者だ！")
  :format(_1)
end,
      unbeliever = "あなたは今や無信仰者だ。"
    }
  }
}
