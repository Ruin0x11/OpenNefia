local env = require("internal.env")
local ReplLayer = require("api.gui.menu.ReplLayer")
local debug_server = require("internal.debug_server")
local console_repl = require("thirdparty.repl.console")
local elona_repl   = console_repl:clone()

local repl_env

function elona_repl.set_environment(_repl_env)
   assert(type(_repl_env) == "table")
   repl_env = _repl_env
end

function elona_repl:getcontext()
  return repl_env or _G
end

-- @see repl:showprompt(prompt)
function elona_repl:compilechunk(text)
   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      return console_repl:compilechunk(text)
   end

   return chunk, err
end

local server = nil

function elona_repl.step_server()
   server:step()
end

-- @see repl:prompt(prompt)
function elona_repl:prompt(level)
   if server == nil or env.server_needs_restart then
      if server then
         server:stop()
      end
      server = debug_server:new()
      server:start()
      env.server_needs_restart = false
   end

   if not self.server_stepped then
      console_repl:prompt(level)
   end

   self.server_stepped = false
end

local super = elona_repl.handleline
function elona_repl:handleline(line)
   if line == "server:step()" then
      self.server_stepped = true
   end
   return super(self, line)
end

local function gather_results(success, ...)
   local n = select('#', ...)
   return success, { n = n, ... }
end

-- @see repl:displayresults(results)
function elona_repl:displayresults(results)
   if self.server_stepped then
      return
   end

   -- omit parens (elona console style)
   if results.n == 1 and type(results[1]) == "function" then
      local success
      success, results = gather_results(xpcall(results[1], function(...) return self:traceback(...) end))
      if not success then
         self:displayerror(results[1])
         return
      end
   end

   local result_text = ReplLayer.format_results(results, true)
   for line in string.lines(result_text) do
      if #line > 2500 then
         line = string.sub(line, 1, 2500) .. "..."
      end
      print(line)
   end
end

return elona_repl
