data:add_type {
   name = "indicator"
}

data:add {
   _type = "simple_indicators.indicator",
   _id = "stamina",

   ordering = 100000,

   render = function(player)
      return ("ST:%d/%d"):format(player.stamina, player:calc("max_stamina"))
   end
}
