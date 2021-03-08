return {
   servant = {
      shop_title = {
         armory = function(_1)
            return ("武具店の%s")
               :format(basename(_1))
         end,
         blackmarket = function(_1)
            return ("ブラックマーケットの%s")
               :format(basename(_1))
         end,
         general_store = function(_1)
            return ("雑貨屋の%s")
               :format(basename(_1))
         end,
         goods_store = function(_1)
            return ("何でも屋の%s")
               :format(basename(_1))
         end,
         magic_store = function(_1)
            return ("魔法店の%s")
               :format(basename(_1))
         end
      },
      hire = {
         too_many_guests = "家はすでに人であふれかえっている。",
         who = "誰を雇用する？",
         not_enough_money = "お金が足りない…",
         you_hire = function(_1)
            return ("%sを家に迎えた。")
               :format(basename(_1))
         end
      },
   }
}
