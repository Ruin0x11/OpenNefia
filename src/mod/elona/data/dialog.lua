data:add {
   _type = "elona_sys.dialog",
   _id = "default",

   root = "",
   nodes = {
      __start = {
         text = {
            {"dialog"}
         },
         choices = function(t)
            local choices = t.speaker:emit("elona.calc_dialog_choices", {}, {})

            table.insert(choices, {"__END__", "__BYE__"})

            return choices
         end
      },
      talk = {
         text = {
            {"talk"}
         },
         choices = "__start"
      },
   },
}

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   root = "",
   nodes = {
      __start = function()
      end,

      buy = function()
         return "elona.default:talk"
      end,
      sell = function()
         return "elona.default:talk"
      end,
   }
}
