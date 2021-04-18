return {
   weird_thing = {
      greeting = "こんにちは、世界!",
      greeting_custom = function(_1)
         return ("こんにちは、%s!"):format(_1)
      end
   }
}
