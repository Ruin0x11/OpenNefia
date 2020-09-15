Rand = require("api.Rand")
Event = require("api.Event")
Log = require("api.Log")

Log.set_level("debug")
data:add {
   _type = "base.event",
   _id = "test"
}

local function run_before(total_runs)
   local total = 0
   do
      local runs = {}
      for _ = 0, total_runs do
         local before = collectgarbage("count")
         local args = { Rand.rnd(10000), Rand.rnd(10000), { Rand.rnd(10000) } }
         local result = Event.trigger("base.test", args, {})
         local after = collectgarbage("count")
         local diff = after - before
         if diff > 0 then
            total = total + diff
            runs[#runs+1] = diff
         end
      end
      local average = total / #runs
   end
   return total
end

local table_pool = {}
local max_pool_size = 200000
local pools = {}

function table_pool.fetch(tag, narr, nrec)
   local pool = pools[tag]
   if not pool then
      pool = {}
      pools[tag] = pool
      pool.c = 0
      pool[0] = 0
   else
      local len = pool[0]
      if len > 0 then
         local obj = pool[len]
         pool[len] = nil
         pool[0] = len - 1
         return obj
      end
   end

   return {}
end

local function clear(tbl)
   for k, v in pairs(tbl) do
      tbl[k] = nil
   end
end

function table_pool.release(tag, obj, noclear)
   if not obj then
      error("object empty")
   end
   local pool = pools[tag]
   if not pool then
      pool = {}
      pools[tag] = pool
      pool.c = 0
      pool[0] = 0
   end

   if not noclear then
      clear(obj)
   end

   do
      local cnt = pool.c + 1
      if cnt >= 20000 then
         pool = {}
         pools[tag] = pool
         pool.c = 0
         pool[0] = 0
         return
      end
      pool.c = cnt
   end

   local len = pool[0] + 1
   if len > max_pool_size then
      clear(pool)
      pool.c = 0
      pool[0] = 1
      len = 1
   end

   pool[len] = obj
   pool[0] = len
end

local function run_after(total_runs)
   local total2 = 0
   do
      local runs = {}
      for _ = 0, total_runs do
         local before = collectgarbage("count")
         local args = table_pool.fetch("event")
         args[1] = Rand.rnd(10000)
         args[2] = Rand.rnd(10000)
         local inner = table_pool.fetch("event")
         inner[1] = Rand.rnd(10000)
         args[3] = inner
         local default = table_pool.fetch("event")
         local result = Event.trigger("base.test", args, default)
         table_pool.release("event", args)
         table_pool.release("event", inner)
         table_pool.release("event", default)
         local after = collectgarbage("count")
         local diff = after - before
         if diff > 0 then
            total2 = total2 + diff
            runs[#runs+1] = diff
         end
      end
      local average = total2 / #runs
   end
   return total2
end

local function run()
   print("runs,before,after,diff")
   for total_runs = 1000, 100000, 1000 do
      total = run_before(total_runs)
      total2 = run_after(total_runs)
      print(("%d,%d,%d,%f"):format(total_runs, total, total2, total / total2))
   end
end

run()

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
