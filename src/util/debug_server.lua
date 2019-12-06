local Log = require("api.Log")
local socket = require("socket")

local function debug_server(port)
   local server, err = socket.bind("127.0.0.1", port)
   if not server then
      Log.error("!!! Failed to start debug server: %s !!!", err)
      return nil
   end

   server:settimeout(0)
   Log.info("Debug server listening on %d.", port)

   local function poll()
      while true do
         local client, _, err = server:accept()

         if err and err ~= "timeout" then
            error(err)
         end

         local result = "waiting"

         if client then
            Log.trace("client recv")

            local text = client:receive("*a")
            Log.trace("Source: %s", text)

            local s, err = loadstring(text)
            if s then
               local success, res = xpcall(s, function(err) return err .. "\n" .. debug.traceback(2) end)
               if success then
                  Log.info("Success: %s", res)
                  result = "success"
               else
                  Log.error("Exec error:\n\t%s", res)
                  result = "exec_error"
               end
            else
               Log.error("Compile error:\n\t%s", err)
               result = "compile_error"
            end
         end

         coroutine.yield(result)
      end
   end

   return coroutine.create(poll)
end

return debug_server
