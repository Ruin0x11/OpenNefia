local socket = require("socket")

local function debug_server(port)
   local server = socket.bind("127.0.0.1", port)
   if not server then
      return nil
   end

   server:settimeout(0)
   print(string.format("Debug server listening on %d.", port))

   local function poll()
      while true do
         local client, _, err = server:accept()

         if err and err ~= "timeout" then
            error(err)
         end

         local result = "waiting"

         if client then
            print("client")
            local text = client:receive("*a")
            print("[Server] GET " .. text)
            local s, err = loadstring(text)
            if s then
               local success, res = xpcall(s, function(err) return err .. "\n" .. debug.traceback(2) end)
               if success then
                  print("[Server] Result: " .. tostring(res))
                  result = "success"
               else
                  print("[Server] Exec error:\n\t" .. tostring(res))
                  result = "exec_error"
               end
            else
               print("[Server] Compile error:\n\t" .. err)
               result = "compile_error"
            end
         end

         coroutine.yield(result)
      end
   end

   return coroutine.create(poll)
end

return debug_server
