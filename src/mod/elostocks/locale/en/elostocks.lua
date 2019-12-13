return {
   mod = {
      elostocks = {
         buy_stocks = function(chara, symbol, amount, gold)
            return ("%s buy%s %d stocks in %s for %d gold."):format(name(chara), s(chara), amount, symbol, gold)
         end,
         sell_stocks = function(chara, symbol, amount, gold)
            return ("%s sell%s %d stocks in %s for %d gold."):format(name(chara), s(chara), amount, symbol, gold)
         end,
         none_left = function(symbol) return ("There are no stocks in %s left to buy."):format(symbol) end,
         none_held = function(symbol) return ("You don't have any stocks in %s."):format(symbol) end,
         report = "Stock report:"
      }
   }
}
