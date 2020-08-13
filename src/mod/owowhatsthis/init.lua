local Owo = require("mod.owowhatsthis.api.Owo")
local Event = require("api.Event")

require("mod.owowhatsthis.data.language")

local function owoify(_, params, result)
   if result == nil or params.language_id ~= "owowhatsthis.owo" then
      return result
   end

   return Owo.owoify(result)
end

Event.register("base.after_get_translation", "Owoify", owoify)
