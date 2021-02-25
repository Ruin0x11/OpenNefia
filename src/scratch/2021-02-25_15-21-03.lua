local VisualAIPlan = require("mod.visual_ai.api.plan.VisualAIPlan")
local nbt = require("thirdparty.nbt")
local utils = require("mod.visual_ai.internal.utils")
local Fs = require("api.Fs")

local plan = VisualAIPlan:new()

local subplan1_1 = VisualAIPlan:new()
subplan1_1:add_target_block(utils.make_block("visual_ai.target_player"))
subplan1_1:add_action_block(utils.make_block("visual_ai.action_change_ammo"))
do
   local subplan1_1_1 = VisualAIPlan:new()
   subplan1_1_1:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

   local subplan1_1_2 = VisualAIPlan:new()
   subplan1_1_2:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

   subplan1_1:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_1_1, subplan1_1_2)
end

local subplan1_2 = VisualAIPlan:new()
do
   local subplan1_2_1 = VisualAIPlan:new()
   subplan1_2_1:add_target_block(utils.make_block("visual_ai.target_player"))
   subplan1_2_1:add_action_block(utils.make_block("visual_ai.action_change_ammo"))
   subplan1_2_1:add_action_block(utils.make_block("visual_ai.action_change_ammo"))
   subplan1_2_1:add_target_block(utils.make_block("visual_ai.target_player"))
   do
      local subplan1_2_1_1 = VisualAIPlan:new()
      subplan1_2_1_1:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

      local subplan1_2_1_2 = VisualAIPlan:new()
      do
         local subplan1_2_1_2_1 = VisualAIPlan:new()
         subplan1_2_1_2_1:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

         local subplan1_2_1_2_2 = VisualAIPlan:new()
         subplan1_2_1_2_2:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

         subplan1_2_1_2:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_2_1_2_1, subplan1_2_1_2_2)
      end

      subplan1_2_1:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_2_1_1, subplan1_2_1_2)
   end

   local subplan1_2_2 = VisualAIPlan:new()
   subplan1_2_2:add_target_block(utils.make_block("visual_ai.target_player"))
   subplan1_2_2:add_action_block(utils.make_block("visual_ai.action_change_ammo"))
   do
      local subplan1_2_2_1 = VisualAIPlan:new()
      subplan1_2_2_1:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

      local subplan1_2_2_2 = VisualAIPlan:new()
      subplan1_2_2_2:add_action_block(utils.make_block("visual_ai.action_move_close_as_possible"))

      subplan1_2_2:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_2_2_1, subplan1_2_2_2)
   end

   subplan1_2:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_2_1, subplan1_2_2)
end

plan:add_condition_block(utils.make_block("visual_ai.condition_hp_mp_sp_threshold"), subplan1_1, subplan1_2)

-- ==========

for i, kind, x, y, block in plan:iter_tiles() do
   print(i, kind, x, y, block)
end
print(plan:tile_size())

local compound = nbt.newClassCompound(plan, "plan")

print("==========")

local plan_deser = compound:getClassCompound()
for i, kind, x, y, block in plan_deser:iter_tiles() do
   print(i, kind, x, y, block)
end
print(plan_deser:tile_size())


local obj = assert(Fs.open("test2.nbt", "wb"))
assert(obj:write(compound:encode()))
obj:close()
