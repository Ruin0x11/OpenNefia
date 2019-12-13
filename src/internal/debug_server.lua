local Log = require("api.Log")
local Doc = require("api.Doc")
local doc = require("internal.doc")
local doc_store = require("internal.global.doc_store")
local socket = require("socket")
local json = require("thirdparty.json")

local commands = {}

local function error_result(err)
   return {
      success = false,
      message = err
   }
end

function commands.run(text)
   local status, success, result

   local s, err = loadstring(text)
   if s then
      success, result = xpcall(s, function(e) return e .. "\n" .. debug.traceback(2) end)
      if success then
         Log.info("Success: %s", result)
         status = "success"
      else
         Log.error("Exec error:\n\t%s", result)
         status = "exec_error"
      end
   else
      Log.error("Compile error:\n\t%s", err)
      status = "compile_error"
   end

   if not success then
      return error_result(status)
   end

   return {}
end

local function with_candidates(cb)
   return function(text)
      local result, err = Doc.get(text)

      if result then
         if result.entry then
            return cb(result.entry, text)
         else
            return { candidates = result.candidates }
         end
      end

      return error_result(err)
   end
end

commands.help = with_candidates(
   function(_, text)
      return { doc = Doc.help(text) }
   end)

commands.jump_to = with_candidates(
   function(entry)
      return {
         file = entry.file.filename,
         line = entry.lineno,
         column = 0
      }
   end)

function commands.signature(text)
   local result, err = Doc.get(text)

   if not result then
      return {}
   end

   local entry
   if result.candidates then
      result, err = Doc.get(result.candidates[1])
      if not result or not result.entry then
         return {}
      end
   end

   entry = result.entry

   if entry.type ~= "function" then
      return {}
   end

   local name = doc.get_item_full_name(entry)

   local sig = string.format("function %s%s end", name, entry.args)

   return {
      sig = sig,
      params = Doc.make_params_string(entry),
      summary = entry.summary
   }
end

function commands.apropos(text)
   local items = {}

   for _, entry in pairs(doc_store.entries) do
      for k, _ in pairs(entry.items) do
         items[#items+1] = k
      end
      items[#items+1] = entry.full_path
   end

   return {
      items = items
   }
end

local debug_server = class.class("debug_server")

function debug_server:init(port)
   self.port = port or 4567
end

function debug_server:poll()
   local client, _, err = self.server:accept()

   if err and err ~= "timeout" then
      error(err)
   end

   local result = nil

   if client then
      Log.trace("client recv")

      local text = client:receive("*l")
      Log.trace("Request: %s", text)

      local ok, req = pcall(json.decode, text)
      if not ok then
         result = error_result(req)
      else
         local key = req.command
         local content = req.content
         if type(key) ~= "string" or type(content) ~= "string" then
            result = error_result("Request must have 'command' and 'content' keys")
         else
            local cmd = commands[key]
            if cmd == nil then
               result = error_result("No command named " .. key)
            else
               local ok, err = xpcall(cmd, debug.traceback, content)
               if not ok then
                  result = error_result(err)
               else
                  result = err
                  if result.success == nil then
                     result.success = true
                  end
               end
            end
         end
      end

      local ok, resp = pcall(json.encode, result)
      if not ok then
         result = error_result("JSON encoding error: " .. resp)
         resp = json.encode(result)
      end

      Log.trace("Response: %s", resp)

      local byte, err = client:send(resp .. "")
      Log.trace("send %s %s", byte, err)
      client:close()

      result = result.success
   end

   return result
end

function debug_server:start()
   if self.server then
      error("Server is already running.")
   end

   local server, err = socket.bind("127.0.0.1", self.port)
   if not server then
      Log.error("!!! Failed to start debug server: %s !!!", err)
      return nil
   end

   self.server = server
   self.server:settimeout(0)
   Log.info("Debug server listening on %d.", self.port)

   local function poll()
      while true do
         local result = self:poll()

         coroutine.yield(result)
      end
   end

   self.coro = coroutine.create(poll)
end

function debug_server:step(dt)
   local ok, err = coroutine.resume(self.coro, dt)
   if not ok then
      Log.error("%s", debug.traceback(self.coro, err))
      self:stop()
   end
end

function debug_server:stop()
   if self.server == nil then
      return
   end

   Log.info("Stopping debug server.")

   self.server:close()
   self.server = nil
   self.coro = nil
end

return debug_server
