local Chara = require("api.Chara")
local Item = require("api.Item")
local Log = require("api.Log")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local VisualAIEditor = require("mod.visual_ai.api.gui.VisualAIEditor")
local MapObject = require("api.MapObject")
local VisualAIPlan = require("mod.visual_ai.api.plan.VisualAIPlan")

local VisualAI = {}

local function is_position(obj)
   return type(obj) == "table" and not MapObject.is_map_object(obj) and obj.x and obj.y
end

local target_filter_never = {
   block = nil,
   filter = function()
      return false
   end
}

local target_filter_in_fov = {
   block = nil,
   filter = function(_block, chara, candidate)
      if is_position(candidate) then
         return true
      end
      if class.is_an(InstancedMap, candidate.location) then
         return chara:has_los(candidate.x, candidate.y)
            and Pos.dist(chara.x, chara.y, candidate.x, candidate.y) <= chara:calc("fov") / 2
      end
      return false
   end
}

local TARGET_SOURCES = {
   all = {
      type = "map_object",
      get = function(chara, map) return map:iter() end,
   },
   character = {
      type = "map_object",
      get = function(chara, map) return Chara.iter(map):filter(Chara.is_alive) end,
   },
   items_on_ground = {
      type = "map_object",
      get = function(chara, map) return Item.iter(map) end,
   },
   items_on_self = {
      type = "map_object",
      get = function(chara, map) return chara:iter_items() end,
   },
   position = {
      type = "position",
      get = function(chara, map)
         return Pos.iter_rect(0, 0, map:width(), map:height()):map(function(x, y) return {x = x, y = y} end)
      end
   },
}

local function applies_to(proto_requirement, target_type)
   return proto_requirement == "any" or proto_requirement == target_type
end

local function choose_target(chara, block, state)
   if state.tried_to_choose_target then
      return state.chosen_target
   end

   local pred = function(candidate)
      for _, f in ipairs(state.target_filters) do
         local target_type = is_position(candidate) and "position" or "map_object"
         if not f.filter(f.block, chara, candidate, target_type) then
            Log.debug("Failed predicate %s", f.block and f.block.proto._id)
            return false
         end
      end
      return true
   end

   local source = assert(TARGET_SOURCES[state.target_source] or TARGET_SOURCES["all"])

   local candidates = source.get(chara, chara:current_map()):filter(pred):to_list()

   if state.target_order then
      local sort = function(a, b)
         local t = state.target_order
         return t.order(t.block, chara, a, b)
      end
      table.sort(candidates, sort)
   end

   local target = candidates[1]

   state.chosen_target = target
   state.target_type = source.type
   state.tried_to_choose_target = true
   Log.debug("Target: %s (%s)", tostring(target), state.target_type)

   return state.chosen_target
end

local function run_block_condition(chara, block, state)
   if state.chosen_target == nil then
      if not choose_target(chara, block, state) then
         return false
      end
   end

   if block.proto.applies_to and not applies_to(block.proto.applies_to, state.target_type) then
      return false
   end

   local success = block.proto.condition(block, chara, state.chosen_target, state.target_type)

   return success
end

local function run_block_target(chara, block, state)
   if state.chosen_target then
      Log.debug("Target already chosen")
      return false
   end

   if not block.proto.applies_to and not applies_to(block.proto.applies_to, state.target_type) then
      Log.debug("Block does not apply: %s %s", block.proto._id, state.target_type)
      return false
   end

   if block.proto.target_filter then
      Log.debug("Add target filter")
      table.insert(state.target_filters, { block = block, filter = block.proto.target_filter })
   end

   if block.proto.target_order then
      state.target_order = { block = block, order = block.proto.target_order }
   end

   if block.proto.target_source then
      if state.target_source then
         if block.proto.target_source ~= state.target_source then
            -- Differing target source found. This is an error, just ensure nothing gets filtered.
            table.insert(state.target_filters, target_filter_never)
         end
      else
         state.target_source = block.proto.target_source
         state.target_type = TARGET_SOURCES[block.proto.target_source].type
      end
   end
end

local function run_block_action(chara, block, state)
   if state.chosen_target == nil then
      if not choose_target(chara, block, state) then
         return
      end
   end

   if block.proto.applies_to and not applies_to(block.proto.applies_to, state.target_type) then
      return
   end

   block.proto.action(block, chara, state.chosen_target, state.target_type)
end

local function clear_target(state)
   state.target_source = nil
   state.target_filters = { target_filter_in_fov }
   state.target_order = nil
   state.chosen_target = nil
   state.tried_to_choose_target = false
   state.target_type = nil
end

local function run_block_special(chara, block, state)
   if block.proto._id == "visual_ai.special_clear_target" then
      clear_target(state)
   else
      error("Unimplemented special block " .. block.proto._id)
   end
end

local function run_one_plan(chara, plan, state)
   for _, block in plan:iter_blocks() do
      Log.debug("Running block: %s", block.proto._id)

      if block.proto.type == "condition" then
         local success = run_block_condition(chara, block, state)
         if success then
            Log.debug("Branch: true", block.proto._id)
            return plan.subplan_true
         else
            Log.debug("Branch: false", block.proto._id)
            return plan.subplan_false
         end
      elseif block.proto.type == "target" then
         run_block_target(chara, block, state)
      elseif block.proto.type == "action" then
         run_block_action(chara, block, state)
      elseif block.proto.type == "special" then
         run_block_special(chara, block, state)
      else
         error("unknown block type " .. tostring(block.proto.type))
      end
   end

   Log.debug("Plan finished.")
   return nil
end

function VisualAI.run(chara, plan)
   local ext = chara:get_mod_data("visual_ai")
   plan = plan or ext.visual_ai_plan

   -- BUG: #118
   -- class.assert_is_an(IChara, chara)
   -- class.assert_is_an(VisualAIPlan, plan)

   Log.debug("+++ Running Visual AI for %s +++", chara.name)

   local errors = plan:check_for_errors()
   if #errors > 0 then
      local concat = function(acc, t) return (acc and (acc .. "  ") or "  ") .. ("(%d,%d): %s\n"):format(t.x, t.y, t.message) end
      local error_text = fun.iter(errors):foldl(concat)
      error(("Plan has %d errors:\n%s"):format(#errors, error_text))
   end

   if ext.stored_target and not target_filter_in_fov.filter(nil, chara, ext.stored_target) then
      ext.stored_target = nil
   end

   local state = {
      target_source = nil,
      target_filters = { target_filter_in_fov },
      target_order = nil,
      chosen_target = nil,
      tried_to_choose_target = false,
      target_type = nil
   }

   while plan do
      plan = run_one_plan(chara, plan, state)
   end

   -- local target = state.chosen_target
   -- if MapObject.is_map_object(target) and target._type == "base.chara" then
   --    chara:set_target(target)
   -- elseif is_position(target) then
   --    chara.target_location = { x = target.x, y = target.y }
   -- end
end

function VisualAI.set_plan(chara, plan)
   local ext = chara:get_mod_data("visual_ai")
   ext.visual_ai_plan = plan
   ext.visual_ai_enabled = true
end

function VisualAI.edit(chara)
   local ext = chara:get_mod_data("visual_ai")
   local plan = ext.visual_ai_plan or VisualAIPlan:new()
   local ok, canceled = VisualAIEditor:new(plan, {chara=chara}):query()

   ext.visual_ai_plan = plan
   ext.visual_ai_enabled = true
end

return VisualAI
