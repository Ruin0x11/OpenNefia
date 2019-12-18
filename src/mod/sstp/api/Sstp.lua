local socket = assert(require("socket"))

local Sstp = {}

local DEFAULT_IP = "127.0.0.1"
local DEFAULT_PORT = 9821 -- SSP baseware port

function Sstp.parse(resp)
   local protocol, ver, resp_code, body = resp:match("^([A-Z]+)/([0-9.]+) ([0-9]+) (.*)")
   return resp
end

function Sstp.send_raw(op, ver, params, ip, port)
   ip = ip or DEFAULT_IP
   port = port or DEFAULT_PORT

   local client = assert(socket.connect(ip, port))

   local req = ("%s SSTP/%s\nSender: elona-next\n"):format(op, ver)
   for _, pair in ipairs(params) do
      req = req .. ("%s: %s\n"):format(pair[1], pair[2])
   end
   req = req .. "Charset: UTF-8\n\n"

   assert(client:send(req))

   local resp = assert(client:receive("*all"))

   return Sstp.parse(resp)
end

function Sstp.notify(event_id, refs)
end

return Sstp
