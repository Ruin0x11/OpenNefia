local Chara = require("api.Chara")
local Item = require("api.Item")
local Log = require("api.Log")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local VisualAIEditor = require("mod.visual_ai.api.gui.VisualAIEditor")

local VisualAI = {}

local function target_filter_never()
   return false
end

local function target_filter_in_fov(block, chara, candidate)
   if class.is_an(InstancedMap, candidate.location) then
      return chara:has_los(candidate.x, candidate.y)
         and Pos.dist(chara.x, chara.y, candidate.x, candidate.y) <= chara:calc("fov")
   end
   return true
end

local TARGET_SOURCES = {
   all = function(chara, map) return map:iter() end,
   character = function(chara, map) return Chara.iter(map) end,
   items_on_ground = function(chara, map) return Item.iter(map) end,
   items_on_self = function(chara, map) return chara:iter_items() end
}

local function choose_target(chara, block, state)
   if state.tried_to_choose_target then
      return state.chosen_target
   end

   local pred = function(candidate)
      for _, target_filter in ipairs(state.target_filters) do
         if not target_filter(block, chara, candidate) then
            return false
         end
      end
      return true
   end

   local source = assert(TARGET_SOURCES[state.target_source] or "all")

   local candidates = source(chara, chara:current_map()):filter(pred):to_list()

   if state.target_order then
      table.sort(candidates, state.target_order)
   end

   state.chosen_target = candidates[1]
   state.tried_to_choose_target = true
   if state.chosen_target then
      chara:set_target(state.chosen_target)
   end

   return state.chosen_target
end

local function run_block_condition(chara, block, state)
   if state.chosen_target == nil then
      if not choose_target(chara, block, state) then
         return false
      end
   end

   local success = block.proto.condition(block, chara, state.chosen_target)

   return success
end

local function run_block_target(chara, block, state)
   if state.chosen_target then
      return false
   end

   if block.proto.target_filter then
      table.insert(state.target_filters, block.proto.target_filter)
   end

   if block.proto.target_order then
      state.target_order = block.proto.target_order
   end

   if block.proto.target_source then
      if state.target_source then
         if block.proto.target_source ~= state.target_source then
            -- Differing target source found. This is an error, just ensure nothing gets filtered.
            table.insert(state.target_filters, target_filter_never)
         end
      else
         state.target_source = block.proto.target_source
      end
   end
end

local function run_block_action(chara, block, state)
   if state.chosen_target == nil then
      if not choose_target(chara, block, state) then
         return false
      end
   end

   block.proto.action(block, chara, state.chosen_target)
end

local function run_one_plan(chara, plan, state)
   for _, block in plan:iter_blocks() do
      if block.proto.type == "condition" then
         local success = run_block_condition(chara, block, state)
         if success then
            return plan.subplan_true
         else
            return plan.subplan_false
         end
      elseif block.proto.type == "target" then
         run_block_target(chara, block, state)
      elseif block.proto.type == "action" then
         run_block_action(chara, block, state)
      else
         error("TODO")
      end
   end

   return nil
end

function VisualAI.run(chara, plan)
   -- BUG: #118
   -- class.assert_is_an(IChara, chara)
   -- class.assert_is_an(VisualAIPlan, plan)

   local errors = plan:check_for_errors()
   if #errors > 0 then
      local concat = function(acc, t) return (acc and (acc .. "  ") or "  ") .. ("(%d,%d): %s\n"):format(t.x, t.y, t.message) end
      local error_text = fun.iter(errors):foldl(concat)
      error(("Plan has %d errors:\n%s"):format(#errors, error_text))
   end

   local state = {
      target_source = nil,
      target_filters = { target_filter_in_fov },
      target_order = nil,
      chosen_target = nil,
      tried_to_choose_target = false
   }

   while plan do
      plan = run_one_plan(chara, plan, state)
   end
end

function VisualAI.set_plan(chara, plan)
   local ext = chara:get_mod_data("visual_ai")
   ext.visual_ai_plan = plan
   ext.visual_ai_enabled = true
end

function VisualAI.edit(chara)
   local ext = chara:get_mod_data("visual_ai")
   local plan = ext.visual_ai_plan or nil
   local ok, canceled = VisualAIEditor:new(plan):query()

   ext.visual_ai_plan = plan
   ext.visual_ai_enabled = true
end

return VisualAI
