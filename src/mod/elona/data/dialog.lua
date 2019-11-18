local Chara = require("api.Chara")
local Input = require("api.Input")

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

      buy = function(t)
         Input.query_inventory(Chara.player(), "inv_buy", {target=t.speaker})
         return "elona.default:talk"
      end,
      sell = function(t)
         Input.query_inventory(Chara.player(), "inv_sell", {target=t.speaker})
         return "elona.default:talk"
      end,
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "guard",

   root = "",
   nodes = {
      __start = function()
      end,

      where_is = function(t)
         return "elona.default:talk"
      end,
      lost_item = function(t)
         return "elona.default:talk"
      end,
   }
}
