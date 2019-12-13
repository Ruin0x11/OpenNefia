local data = require("internal.data")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Log = require("api.Log")

local Ai = {}

local default_module

function Ai.run(id, chara, params)
   if chara == nil then
      Log.warn("Must have character")
      return false
   end

   if type(id) == "function" then
      return id(chara, params)
   end

   local ai = data["base.ai_action"][id]
   if ai == nil then
      Log.warn("Unknown AI %s", id)
      return false
   end

   if type(ai.act) == "table" then
      for _, v in ipairs(ai.act) do
         if Ai.run(v, chara) then
            return true
         end
      end
      return false
   end

   return ai.act(chara, params or {})
end

return Ai
