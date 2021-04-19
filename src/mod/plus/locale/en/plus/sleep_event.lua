return {
   sleep_event = {
      breakfast = {
         event = {
            title = "Breakfast",
            text = {
               one = function(_1)
                  return ("Apparently, %s is preparing breakfast."):format(name(_1))
               end,
               multiple = function(_1)
                  return ("Apparently, %s and the others are preparing breakfast."):format(name(_1))
               end
            },
            choices = {
               _1 = "(Eat)",
               _2 = "(Leave)"
            },
         },
         rejected = {
            function(_1)
               return ("%s hangs %s head in disappointment..."):format(name(_1), his(_1))
            end,
            function(_1)
               return ("%s is in complete shock over your rejection!"):format(name(_1))
            end,
            function(_1)
               return ("%s begins to put away the tableware in silence."):format(name(_1))
            end
         }
      },
      handmade_gift = {
         event = {
            title = "Handmade gifts",
            text = {
               one = function(_1)
                  return ("%s seems to have made armor for you during the night."):format(name(_1))
               end,
               multiple = function(_1)
                  return ("%s and the others seem to have made armor for you during the night."):format(name(_1))
               end
            },
            choices = {
               _1 =  "Thank you.",
               _2 =  "I don't need it."
            }
         },
         accepted = function(_1)
            return ("%s looks happy."):format(name(_1))
         end,
         rejected = function(_1)
            return ("%s throws the armor in the trash, almost crying."):format(name(_1))
         end
      },
      handknitted_gift = {
         event = {
            title = "Hand-knitted gifts",
            text = {
               one = function(_1)
                  return ("%s seems to have knitted armor for you during the night."):format(name(_1))
               end,
               multiple = function(_1)
                  return ("%s and the others seem to have knitted armor for you during the night."):format(name(_1))
               end
            },
            choices = {
               _1 =  "Thank you.",
               _2 =  "I don't need it."
            }
         },
         accepted = function(_1)
            return ("%s is in a good mood."):format(name(_1))
         end,
         rejected = function(_1)
            return ("%s tore the armor apart in silence."):format(name(_1))
         end
      }
   }
}
