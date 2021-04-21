local Event = require("api.Event")
local ChatBubbleConfigMenu = require("mod.chat_bubbles.api.gui.menu.ChatBubbleConfigMenu")

local function talk_settings(chara)
   ChatBubbleConfigMenu:new(chara, false):query()
end

local function add_interact_action(chara, params, actions)
   local function add_option(text, callback)
      table.insert(actions, { text = text, callback = callback })
   end

   if chara:is_in_player_party() then
      add_option("chat_bubbles:interact.talk_settings", talk_settings)
   end

   return actions
end
Event.register("elona_sys.on_build_interact_actions", "Add talk settings option", add_interact_action, { priority = 200000 })
