local VisualAIPlan = require("mod.visual_ai.api.plan.VisualAIPlan")

do
   local plan = VisualAIPlan:new()

   plan:add_target_block("visual_ai.target_player")
   plan:add_target_block("visual_ai.target_player")
   plan:add_target_block("visual_ai.target_player")

   local subplan1 = VisualAIPlan:new()
   subplan1:add_action_block("visual_ai.action_move_close_as_possible")

   local subplan2 = VisualAIPlan:new()

   plan:add_condition_block("visual_ai.condition_hp_threshold", subplan1, subplan2)

   for i, kind, x, y, block in plan:iter_tiles() do
      print(i, kind, x, y, block)
   end
   print(plan:tile_size())
end

print(string.rep("-", 10))

do
   local plan = VisualAIPlan:new()

   local subplan1_1 = VisualAIPlan:new()
   subplan1_1:add_target_block("visual_ai.target_player")
   subplan1_1:add_action_block("visual_ai.action_change_ammo")
   do
      local subplan1_1_1 = VisualAIPlan:new()
      subplan1_1_1:add_action_block("visual_ai.action_move_close_as_possible")

      local subplan1_1_2 = VisualAIPlan:new()
      subplan1_1_2:add_action_block("visual_ai.action_move_close_as_possible")

      subplan1_1:add_condition_block("visual_ai.condition_hp_threshold", subplan1_1_1, subplan1_1_2)
   end

   local subplan1_2 = VisualAIPlan:new()
   do
      local subplan1_2_1 = VisualAIPlan:new()
      subplan1_2_1:add_target_block("visual_ai.target_player")
      subplan1_2_1:add_action_block("visual_ai.action_change_ammo")
      subplan1_2_1:add_action_block("visual_ai.action_change_ammo")
      subplan1_2_1:add_target_block("visual_ai.target_player")
      do
         local subplan1_2_1_1 = VisualAIPlan:new()
         subplan1_2_1_1:add_action_block("visual_ai.action_move_close_as_possible")

         local subplan1_2_1_2 = VisualAIPlan:new()
         do
            local subplan1_2_1_2_1 = VisualAIPlan:new()
            subplan1_2_1_2_1:add_action_block("visual_ai.action_move_close_as_possible")

            local subplan1_2_1_2_2 = VisualAIPlan:new()
            subplan1_2_1_2_2:add_action_block("visual_ai.action_move_close_as_possible")

            subplan1_2_1_2:add_condition_block("visual_ai.condition_hp_threshold", subplan1_2_1_2_1, subplan1_2_1_2_2)
         end

         subplan1_2_1:add_condition_block("visual_ai.condition_hp_threshold", subplan1_2_1_1, subplan1_2_1_2)
      end

      local subplan1_2_2 = VisualAIPlan:new()
      subplan1_2_2:add_target_block("visual_ai.target_player")
      subplan1_2_2:add_action_block("visual_ai.action_change_ammo")
      do
         local subplan1_2_2_1 = VisualAIPlan:new()
         subplan1_2_2_1:add_action_block("visual_ai.action_move_close_as_possible")

         local subplan1_2_2_2 = VisualAIPlan:new()
         subplan1_2_2_2:add_action_block("visual_ai.action_move_close_as_possible")

         subplan1_2_2:add_condition_block("visual_ai.condition_hp_threshold", subplan1_2_2_1, subplan1_2_2_2)
      end

      subplan1_2:add_condition_block("visual_ai.condition_hp_threshold", subplan1_2_1, subplan1_2_2)
   end

   plan:add_condition_block("visual_ai.condition_hp_threshold", subplan1_1, subplan1_2)

   for i, kind, x, y, block in plan:iter_tiles() do
      print(i, kind, x, y, block)
   end
   print(plan:tile_size())
end

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
