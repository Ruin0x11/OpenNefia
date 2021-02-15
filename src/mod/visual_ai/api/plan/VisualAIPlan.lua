local VisualAIPlan = class.class("VisualAIPlan")
local CoIter = require("mod.visual_ai.api.CoIter")
local utils = require("mod.visual_ai.internal.utils")

function VisualAIPlan:init()
   self.blocks = {}
   self.subplan_true = nil
   self.subplan_false = nil
   self.parent = nil
end

function VisualAIPlan:current_block()
   return self.blocks[#self.blocks]
end

function VisualAIPlan:iter_blocks()
   return fun.iter(self.blocks)
end

function VisualAIPlan:can_add_block()
   local cur = self:current_block()
   if cur == nil then
      return true
   end

   if cur.proto.type == "action" then
      if cur.proto.is_terminal ~= false then
         return false, ("Plan ends in terminal action (%s)."):format(cur.proto._id)
      end
   end

   if cur.proto.type == "condition" then
      return false, ("Plan ends with a condition (%s)."):format(cur.proto._id)
   end

   return true
end

function VisualAIPlan:tile_size()
   local width = #self.blocks
   local height = 1

   if self.subplan_true then
      local w, h = self.subplan_true:tile_size()
      width = width + w
      height = h
   end

   if self.subplan_false then
      local w, h = self.subplan_false:tile_size()
      width = math.max(width, w)
      height = height + h
   end

   return width, height
end

function VisualAIPlan:iter_tiles(x, y)
   x = x or 0
   y = y or 0

   local f = function()
      local i = 1
      while self.blocks[i] do
         coroutine.yield("block", x, y, self.blocks[i], self)
         if i < #self.blocks then
            coroutine.yield("line", x, y, { "right", x + 1, y }, self)
         end

         i = i + 1
         x = x + 1
      end

      local last_block = self:current_block()

      if last_block == nil then
         -- empty plan
         coroutine.yield("empty", x, y, "", self)
      elseif last_block.proto.type == "condition" then
         coroutine.yield("line", x-1, y, { "right", x, y }, self.subplan_true)
         for _, state, cx, cy, block, plan in self.subplan_true:iter_tiles(x, y) do
            coroutine.yield(state, cx, cy, block, plan)
         end

         local _, height = self.subplan_true:tile_size()
         coroutine.yield("line", x - 1, y, { "down", x - 1, y + height }, self.subplan_false)
         for _, state, cx, cy, block, plan in self.subplan_false:iter_tiles(x-1, y + height) do
            coroutine.yield(state, cx, cy, block, plan)
         end
      elseif last_block.proto.type == "target" then
         coroutine.yield("line", x-1, y, { "right", x, y }, self)
         coroutine.yield("empty", x, y, "", self)
      elseif last_block.proto.type == "action" then
         if last_block.proto.is_terminal == false then
            coroutine.yield("line", x-1, y, { "right", x, y }, self)
            coroutine.yield("empty", x, y, "", self)
         end
      end
   end

   return CoIter.iter(f)
end

function VisualAIPlan:check_for_errors(x, y)
   x = x or 0
   y = y or 0

   local errors = {}

   for i, block in ipairs(self.blocks) do
      x = x + 1
   end

   local last_block = self:current_block()

   if last_block == nil then
      errors[#errors+1] = { message = "Branch is missing a final block.", x = x, y = y }
   elseif last_block.proto.type == "condition" then
      assert(self.subplan_true ~= nil)
      assert(self.subplan_false ~= nil)

      table.append(errors, self.subplan_true:check_for_errors(x, y))

      local _, height = self.subplan_true:tile_size()
      table.append(errors, self.subplan_false:check_for_errors(x - 1, y + height))
   elseif last_block.proto.type == "target" then
      errors[#errors+1] = { message = "Target block is missing next block.", x = x - 1, y = y }
   elseif last_block.proto.type == "action" then
      if last_block.proto.is_terminal == false then
         errors[#errors+1] = { message = "Non-terminal action is missing next block.", x = x - 1, y = y }
      end
   end

   return errors
end

local function make_block(proto_id)
   local proto = data["visual_ai.block"]:ensure(proto_id)

   local vars = utils.get_default_vars(proto.vars)

   return {
      _id = proto_id,
      proto = proto,
      vars = vars
   }
end

function VisualAIPlan:_insert_block(proto_id)
   assert(self:can_add_block())
   self.blocks[#self.blocks+1] = make_block(proto_id)
end

function VisualAIPlan:add_condition_block(proto_id, subplan_true, subplan_false)
   local proto = data["visual_ai.block"]:ensure(proto_id)
   if proto.type ~= "condition" then
      error("Block prototype must be 'condition'.")
   end

   self:_insert_block(proto_id)

   if subplan_true then
      -- BUG #118
      -- class.assert_is_an(VisualAIPlan, subplan_true)
      assert(subplan_true ~= subplan_false)
   else
      subplan_true = VisualAIPlan:new()
   end

   if subplan_false then
      -- BUG #118
      -- class.assert_is_an(VisualAIPlan, subplan_false)
   else
      subplan_false = VisualAIPlan:new()
   end

   subplan_true.parent = self
   subplan_false.parent = self

   self.subplan_true = subplan_true
   self.subplan_false = subplan_false
end

function VisualAIPlan:add_target_block(proto_id)
   local proto = data["visual_ai.block"]:ensure(proto_id)
   if proto.type ~= "target" then
      error("Block prototype must be 'target'.")
   end

   self:_insert_block(proto_id)
end

function VisualAIPlan:add_action_block(proto_id)
   local proto = data["visual_ai.block"]:ensure(proto_id)
   if proto.type ~= "action" then
      error("Block prototype must be 'action'.")
   end

   self:_insert_block(proto_id)
end

function VisualAIPlan:add_block(proto_id)
   local proto = data["visual_ai.block"]:ensure(proto_id)
   if proto.type == "condition" then
      self:add_condition_block(proto_id, nil, nil)
   elseif proto.type == "target" then
      self:add_target_block(proto_id)
   elseif proto.type == "action" then
      self:add_action_block(proto_id)
   else
      error("TODO")
   end
end

function VisualAIPlan:replace_block(block, proto_id)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   local function snip_rest()
      for i = idx, #self.blocks do
         self.blocks[i] = nil
      end
   end

   local proto = data["visual_ai.block"]:ensure(proto_id)

   if self:current_block().proto.type == "condition" and proto.type ~= "condition" then
      self.subplan_true = nil
      self.subplan_false = nil
   end

   if proto.type == "condition" then
      if block.proto.type == "condition" then
         self.blocks[idx] = make_block(proto_id)
      else
         snip_rest()
         self:add_condition_block(proto_id, nil, nil)
      end
   elseif proto.type == "target" then
      self.blocks[idx] = make_block(proto_id)
   elseif proto.type == "action" then
      if proto.is_terminal then
         snip_rest()
      end
      self:add_action_block(proto_id)
   else
      error("TODO")
   end
end

function VisualAIPlan:merge_plan(other)
   assert(self:can_add_block())
   self.subplan_true = nil
   self.subplan_false = nil

   if other.subplan_true then
      other.subplan_true.parent = self
      self.subplan_true = other.subplan_true
   end
   if other.subplan_false then
      other.subplan_false.parent = self
      self.subplan_false = other.subplan_false
   end

   table.append(self.blocks, other.blocks)
end

function VisualAIPlan:split(idx)
   assert(idx > 0 and idx <= #self.blocks)
   local right = VisualAIPlan:new()
   for i = idx, #self.blocks do
      local block = self.blocks[i]
      if block.proto.type == "condition" then
         assert(i == #self.blocks)
         pause()
         right:add_condition_block(block.proto._id, self.subplan_true, self.subplan_false)
      else
         right:add_block(block.proto._id)
      end
      self.blocks[i] = nil
   end
   self.subplan_true = nil
   self.subplan_false = nil
   return right
end

function VisualAIPlan:insert_block_before(block, proto_id, split_type)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   local proto = data["visual_ai.block"]:ensure(proto_id)

   local function snip_rest()
      for i = idx, #self.blocks do
         self.blocks[i] = nil
      end
   end

   if proto.type == "condition" then
      local right = self:split(idx)
      if split_type == "true_branch" then
         self:add_condition_block(proto_id, right, nil)
      elseif split_type == "false_branch" then
         self:add_condition_block(proto_id, nil, right)
      else
         error("unknown split type " .. tostring(split_type))
      end
   elseif proto.type == "target" then
      table.insert(self.blocks, idx, make_block(proto_id))
   elseif proto.type == "action" then
      if proto.is_terminal then
         snip_rest()
         self:add_action_block(proto_id)
      else
         table.insert(self.blocks, idx, make_block(proto_id))
      end
   else
      error("TODO")
   end
end

function VisualAIPlan:remove_block(block, merge_type)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   local to_merge

   if block.proto.type == "condition" then
      -- This block must be at the end.
      assert(idx == #self.blocks)
      if merge_type == "true_branch" then
         to_merge = self.subplan_true
      elseif merge_type == "false_branch" then
         to_merge = self.subplan_false
      else
         error("unknown merge type " .. tostring(merge_type))
      end
      self.subplan_true = nil
      self.subplan_false = nil
   end

   table.remove(self.blocks, idx)

   if to_merge then
      self:merge_plan(to_merge)
   end
end

function VisualAIPlan:remove_block_and_rest(block)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   if block.type == "condition" then
      -- This block must be at the end.
      assert(idx == #self.blocks)
      self.subplan_true = nil
      self.subplan_false = nil
   end

   for i = idx, #self.blocks do
      self.blocks[i] = nil
   end
end

function VisualAIPlan:serialize()
   for _, block in ipairs(self.blocks) do
      block.proto = nil
   end
end

function VisualAIPlan:deserialize()
   for _, block in ipairs(self.blocks) do
      -- TODO remove block if invalid, don't throw an error
      block.proto = data["visual_ai.block"]:ensure(block._id)
   end
end

return VisualAIPlan
