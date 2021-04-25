local Gui = require("api.Gui")
local Chara = require("api.Chara")

local Title = {}

local STATES = table.set { "earned", "effect_on" }

function Title.state(title_id)
   data["titles.title"]:ensure(title_id)

   local state = save.titles.title_states[title_id]

   if state ~= nil and not STATES[state] then
      state = nil
   end

   return state
end

function Title.iter_earned()
   return fun.iter_pairs(save.titles.title_states)
end

function Title.earn(title_id)
   local state = Title.state(title_id)

   if state ~= nil then
      return
   end

   Title.set_state(title_id, "earned")
   Gui.play_sound("base.write1")
   Gui.mes_c("titles.earned_new", "Green")
end

function Title.set_state(title_id, state)
   local title = data["titles.title"]:ensure(title_id)

   if state~= nil and not STATES[state] then
      error(("Invalid title state %s"):format(state))
   end

   local old_state = save.titles.title_states[title_id]
   save.titles.title_states[title_id] = state

   local chara = Chara.player()
   local do_refresh = false

   if old_state ~= state then
      local on_toggle_effect = title.on_toggle_effect
      if old_state ~= nil and on_toggle_effect then
         -- TODO maybe have titles separate per party member?
         if state == "effect_on" then
            on_toggle_effect(true, chara)
         elseif state == "earned" then
            on_toggle_effect(false, chara)
         end

      end
      do_refresh = true
   end

   -- Update any titles with :on_refresh() callbacks.
   if do_refresh then
      chara:refresh()
   end
end

function Title.check_earned(chara, title_id)
   if not chara:is_player() then
      return
   end

   local earned_something = false

   local function check_earned(title)
      if title.check_earned then
         if Title.state(title._id) == nil and title.check_earned(chara) then
            earned_something = true
            Title.set_state(title._id, "earned")
         end
      end
   end

   if title_id == nil then
      data["titles.title"]:iter():each(check_earned)
   else
      check_earned(data["titles.title"]:ensure(title_id))
   end

   if earned_something then
      Gui.play_sound("base.write1")
      Gui.mes_c("titles.earned_new", "Green")
   end
end

return Title
