return {
   act = {
      destroy = {
         prompt = function(_1) return ("Destroy %s?"):format(_1) end,
         execute = function(_1) return ("%s was destroyed."):format(_1) end,
      },
      pick_up = {
         prompt = function(_1) return ("Pick up %s?"):format(_1) end,
      },
   }
}
