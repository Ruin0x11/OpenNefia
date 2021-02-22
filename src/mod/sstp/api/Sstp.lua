--- @module Sstp

local socket = require("socket")

local Sstp = {}

--- @tparam string resp
--- @treturn table
function Sstp.parse(resp)
   local protocol, version, status_code, body = resp:match("^([A-Z]+)/([0-9.]+) ([0-9]+) (.+)")
   local params = {}
   for line in body:gmatch("(.-)\r\n") do
      print(line)
      local key, value = line:match("^([^:]+): (.+)$")
      if key then
         params[#params+1] = { key, value }
      end
   end

   local spl = string.split(body, "\r\n\r\n")
   local status_message = spl[1]
   local response = spl[5]
   if #params > 0 then
      response = nil
   end

   return {
      protocol = protocol,
      version = version,
      status_code = status_code,
      status_message = status_message,
      params = params,
      response = response
   }
end

--- @tparam string op
--- @tparam string protocol
--- @tparam {{string,string}...} params
--- @tparam[opt] string ip
--- @tparam[opt] uint port
--- @treturn table
function Sstp.send_raw(op, protocol, params, address, port)
   address = address or config.sstp.address
   port = port or config.sstp.port

   local client, err = socket.connect(address, port)
   if client == nil then
      return nil, err
   end
   client:settimeout(1)

   local req = ("%s %s\r\nSender: OpenNefia\r\n"):format(op, protocol)
   for _, pair in ipairs(params) do
      req = req .. ("%s: %s\r\n"):format(pair[1], pair[2])
   end
   req = req .. "Charset: UTF-8\r\n\r\n"

   assert(client:send(req))

   local resp = assert(client:receive("*all"))
   client:close()

   return Sstp.parse(resp)
end

--- @tparam string event_id
--- @tparam[opt] {{string,string}...} params
--- @treturn table
function Sstp.notify(event_id, params)
   params = params or {}
   table.insert(params, 1, {"Event", event_id})
   return Sstp.send_raw("NOTIFY", "SSTP/1.1", params)
end

--- @tparam string script
--- @tparam[opt] {{string,string}...} params
--- @treturn table
function Sstp.send(script, params)
   params = params or {}
   table.insert(params, 1, {"Script", script})
   return Sstp.send_raw("SEND", "SSTP/1.4", params)
end

--- @tparam string command
--- @tparam[opt] string key
--- @tparam[opt] string value
--- @treturn table
function Sstp.execute(command, key, value)
   if key and value then
      command = command .. ("[%s,%s]"):format(key, value)
   elseif key then
      command = command .. ("[%s]"):format(key)
   end
   return Sstp.send_raw("EXECUTE", "SSTP/1.3", {{"Command", command}})
end

--- @tparam string sentence
--- @tparam[opt] string option
--- @treturn table
function Sstp.communicate(sentence, option)
   local params = {{"Sentence", sentence}}
   if option then
      params[#params+1] = {"Option", option}
   end
   return Sstp.send_raw("COMMUNICATE", "SSTP/1.1", params)
end

return Sstp
