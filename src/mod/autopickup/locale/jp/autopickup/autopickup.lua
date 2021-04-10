return {
   act = {
      destroy = {
         prompt = function(_1) return ("%sを破壊する？"):format(_1) end,
         execute = function(_1) return ("%sを破壊した。"):format(_1) end,
      },
      pick_up = {
         prompt = function(_1) return ("%sを拾う？"):format(_1) end,
      },
   }
}
