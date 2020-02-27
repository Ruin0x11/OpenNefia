local Event = require("api.Event")
local World = require("api.World")
local Rand = require("api.Rand")
local Elostocks = require("mod.elostocks.api.Elostocks")

local function make_stock(symbol, risk)
   local roll = Rand.rnd(100)
   local price

   if roll == 99 then
      price = Rand.rnd(3000)
   elseif roll > 85 then
      price = Rand.rnd(500)
   elseif roll > 60 then
      price = Rand.rnd(150)
   elseif roll > 20 then
      price = Rand.rnd(50)
   else
      price = Rand.rnd(15)
   end

   local amount = math.floor(1000000 / price)

   return {
      symbol = symbol,
      amount = amount,
      held = 0,
      risk = risk,
      price = price,
      history = {{price = price, date = World.date():hours()}}
   }
end

local function init_save()
   local s = save.elostocks
   s.stocks = {}
   s.last_report = {}
   s.last_update = 0
end

Event.register("base.on_init_save", "Init save (elostocks)", init_save)

local function init_stocks()
   local s = save.elostocks
   s.stocks = {
      make_stock("PPY", 7),
      make_stock("XAB", 3),
      make_stock("LOM", 1)
   }
   s.last_update = World.date():hours()
end

Event.register("base.on_game_initialize", "Init stocks", init_stocks)

local function update_and_report_stocks()
   local date = World.date():hours()

   local s = save.elostocks
   print(date, s.last_update, date - s.last_update)
   if date - s.last_update > 12 then
      Elostocks.update_stocks()
      Elostocks.report_stocks()
      s.last_update = date
   end
end

Event.register("base.on_hour_passed", "Update and report stocks", update_and_report_stocks)
