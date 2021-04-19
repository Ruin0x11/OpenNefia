return {
   talk = {
      sleep_event = {
         breakfast = {
            function(_1)
               return ("%sは一仕事やりとげた顔をしている。"):format(name(_1))
            end,
            function(_1)
               return ("%sはなんだかそわそわしている。"):format(name(_1))
            end,
            function(_1)
               return ("「早く来ないとなくなる%s」"):format(yo(_1, 3))
            end,
            function(_1)
               return ("「一日の元気は朝食から%s」"):format(da(_1, 3))
            end
         },
         handmade_gift = {
            function(_1)
               return ("%sは一仕事やりとげた顔をしている。"):format(name(_1))
            end,
            function(_1)
               return ("%sは誇らしげにお手製の品を取り出した。"):format(name(_1))
            end,
            function(_1)
               return ("「割と自信作%s」"):format(dana(_1, 3))
            end,
            "「どやぁ」"
         },
         handknitted_gift = {
            function(_1)
               return ("%sは怪我を隠している。"):format(name(_1))
            end,
            function(_1)
               return ("「頑張って作った%s」"):format(yo(_1, 3))
            end,
            "「家計の足しにでも…」",
            "「ちょっと不恰好だけど…」"
         }
      }
   }
}
