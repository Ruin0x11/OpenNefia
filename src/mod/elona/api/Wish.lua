local Gui = require("api.Gui")
local Input = require("api.Input")
local I18N = require("api.I18N")
local Save = require("api.Save")
local Chara = require("api.Chara")
local Log = require("api.Log")

local Wish = {}

--- Queries the player for a wish and grants it.
function Wish.query_wish()
   Gui.mes_c("wish.what_do_you_wish_for", "Yellow")
   local wish = Input.query_text(16, false, false)

   Gui.mes(I18N.quote_speech(I18N.get("wish.your_wish", wish)))

   Save.queue_autosave()

   wish = string.strip_whitespace(wish)

   if wish == "" then
      Gui.mes("common.nothing_happens")
      return
   end

   Gui.play_sound("base.ding2")

   Wish.grant_wish(wish)
end

--- Grants a wish, as if it had been typed into the prompt.
---
--- @tparam string wisn
--- @tparam[opt] IChara chara
function Wish.grant_wish(wish, chara)
   chara = chara or Chara.player()

   local sort = function(a, b)
      if a.priority == b.priority then
         return a._id < b._id
      end

      return a.priority < b.priority
   end

   local did_something = false
   for _, handler in data["elona.wish_handler"]:iter():into_sorted(sort) do
      local result = handler.on_wish(wish, chara)
      if result then
         did_something = true
         break
      end
   end

   if not did_something then
      Gui.mes("common.nothing_happens")
   end

   -- TODO net
end

return Wish
