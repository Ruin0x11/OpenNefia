return {
  quest = {
    journal = {
       common = {
          client = function(_1) return ("依頼: %s"):format(_1) end,
          complete = "依頼 完了",
          deadline = function(_1) return ("期限: %s"):format(_1) end,
          detail = function(_1) return ("内容: %s"):format(_1) end,
          job = "依頼",
          location = function(_1) return ("場所: %s"):format(_1) end,
          remaining = function(_1) return ("残り%s"):format(_1) end,
          report_to_the_client = "あとは報告するだけだ。",
          reward = function(_1) return ("報酬: %s"):format(_1) end
       },
      item = {
        fools_magic_stone = "愚者の魔石",
        kings_magic_stone = "覇者の魔石",
        letter_to_the_king = "ジャビ王への書簡",
        old_talisman = "古びたお守り",
        sages_magic_stone = "賢者の魔石"
      },
      main = {
        progress = {
          _0 = "ヴェルニースの南にあるネフィアの迷宮群のひとつ《レシマス》で、何かが見つかるかもしれない。",
          _1 = "致命傷を負った斥候に、パルミアのジャビ王へ書簡を渡すよう頼まれた。パルミアには、ヴェルニースから東の街道を進めば辿り着ける。",
          _2 = "ジャビ王によると、仕事が欲しい時は城の図書館にいるエリステアを訪ねればいいようだ。",
          _3 = "レシマスに赴き、冒険者カラムという人物を探すよう依頼された。彼は最低でもレシマスの16階より先の階層にいるらしい。",
          _4 = "瀕死のカラムから得た情報を、パルミアのエリステアに伝えなければならない。",
          _5 = "レシマス最下層の封印を解く為に必要な三つの魔石の入手を依頼された。賢者の魔石は《灼熱の塔》に、愚者の魔石は《死者の洞窟》に、覇者の魔石は《古城》にある。",
          _6 = "三つの魔石の力で最下層の封印を解き、レシマスの秘宝を持ち帰るようエリステアに依頼された。",
          _7 = "第一部メインクエスト完了"
        },
        title = "メインクエスト"
      }
    }
  }
}
