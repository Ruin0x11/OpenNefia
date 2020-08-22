-- Snippet to either train more skills immediately after confirmation, or
-- training skills without prompting for confirmation at all.

local Event = require("api.Event")
local Advice = require("api.Advice")

local no_confirm = true

local function skip_train_confirm(_, params, next_node)
   if no_confirm then
      if params.prev_node_id == "elona.trainer:train"
         and next_node.node_id == "elona.trainer:train_confirm"
      then
         next_node.node_id = "elona.trainer:train_accept"
         return next_node
      end
   end

   if params.prev_node_id == "elona.trainer:train_accept"
      and next_node.node_id == "elona.default:__start"
   then
      next_node.node_id = "elona.trainer:train"
   end

   return next_node
end
Event.register("elona_sys.on_step_dialog", "Go back to train menu after selection", skip_train_confirm)

local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
local SkillStatusMenu = require("api.gui.menu.SkillStatusMenu")

local menu_position = nil
local function restore_menu_position(self)
   if (self.mode == "trainer_learn" or self.mode == "trainer_train") and menu_position then
      local sublayer = self.sublayers:current_sublayer()
      if class.is_an(SkillStatusMenu, sublayer) then
         sublayer.pages:select(menu_position)
         self.sublayers:refresh_page_from_sublayer()
      end
   end
end

Advice.add("after", CharacterInfoMenu.init, "Restore menu position", restore_menu_position)

local function save_menu_position(self)
   if (self.mode == "trainer_learn" or self.mode == "trainer_train") then
      local sublayer = self.sublayers:current_sublayer()
      if class.is_an(SkillStatusMenu, sublayer) then
         menu_position = sublayer.pages:selected_index()
      end
   end
end

Advice.add("after", CharacterInfoMenu.update, "Save menu position", save_menu_position)
