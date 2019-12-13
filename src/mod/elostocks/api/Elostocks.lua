local Gui = require("api.Gui")
local Chara = require("api.Chara")
local World = require("api.World")
local Rand = require("api.Rand")

local Elostocks = {}

function Elostocks.update_stocks()
   local date = World.date():hours()

   local s = save.elostocks

   for i, stock in ipairs(s.stocks) do
      local latest = stock.history[#stock.history]

      local price = latest.price
      if price < 100 then
         price = Rand.rnd(100)
      end
      local prev_date = latest.date
      local factor = (date - prev_date) / 12
      local delta = math.floor((Rand.rnd(price) * factor) / (4 * stock.risk))
      if Rand.one_in(2) then
         delta = -delta
      end

      stock.price = math.max(price + delta, 0)

      local new = { price = stock.price, date = date }
      table.insert(stock.history, new)
      s.last_report[i] = delta
   end

   return s.last_report
end

function Elostocks.report_stocks()
   local s = save.elostocks

   Gui.mes_c("mod.elostocks.report", "Gold")
   Gui.mes_continue_sentence()

   for i, stock in ipairs(s.stocks) do
      local delta = s.last_report[i]
      if delta then
         local color = "Green"
         local sym = "▲"
         if delta < 0 then
            color = "Red"
            sym = "▼"
         elseif delta == 0 then
            color = "Gold"
            sym = "■"
         end

         local op = ""
         if delta > 0 then
            op = "+"
         end

         local held = ""
         if stock.held > 0 then
            held = (" (%s%sgp)"):format(op, stock.held * delta)
         end

         local mes = ("%s %s %s%d%s "):format(stock.symbol, sym, op, delta, held)
         Gui.mes_c(mes, color)
         Gui.mes_continue_sentence()
      end
   end
end

function Elostocks.buy(symbol, amount)
   if amount <= 0 then
      return
   end

   local stock = fun.iter(save.elostocks.stocks):filter(function(s) return s.symbol == symbol end):nth(1)
   if stock == nil then
      error("no stock " .. symbol)
   end

   local player = Chara.player()
   local amount = math.min(amount, stock.amount)
   local tax = 0.15
   local total_price = amount * stock.price * tax

   if stock.amount == 0 then
      Gui.mes("mod.elostocks.none_left", stock.symbol)
      return
   end

   if total_price > player.gold then
      Gui.mes("ui.inv.buy.not_enough_money")
      return
   end

   player.gold = player.gold - total_price
   stock.amount = stock.amount - amount
   stock.held = stock.held + amount

   Gui.mes("mod.elostocks.buy_stocks", player, stock.symbol, amount, total_price)
   Gui.play_sound("base.paygold1")
end

function Elostocks.sell(symbol, amount)
   if amount <= 0 then
      return
   end

   local stock = fun.iter(save.elostocks.stocks):filter(function(s) return s.symbol == symbol end):nth(1)
   if stock == nil then
      error("no stock " .. symbol)
   end

   if stock.held == 0 then
      Gui.mes("mod.elostocks.none_held", stock.symbol)
      return
   end

   local player = Chara.player()
   local amount = math.min(amount, stock.held)
   local total_price = amount * stock.price

   player.gold = player.gold + total_price
   stock.amount = stock.amount + amount
   stock.held = stock.held - amount

   Gui.mes("mod.elostocks.sell_stocks", player, stock.symbol, amount, total_price)
   Gui.play_sound("base.getgold1")
end

return Elostocks
