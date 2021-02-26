local ISerializable = require("api.ISerializable")

local VisualAIPlan = class.class("VisualAIPlan", ISerializable)
local CoIter = require("mod.visual_ai.api.CoIter")
local utils = require("mod.visual_ai.internal.utils")

function VisualAIPlan:init()
   self.blocks = {}
   self.subplan_true = nil
   self.subplan_false = nil
   self.parent = nil
end

function VisualAIPlan:serialize_nbt(nbt)
   local function map(block)
      return nbt.newArbitraryTable({_id = block._id, vars = block._vars}, "block")
   end

   local blocks = nbt.newList(nbt.TAG_BYTE_ARRAY, fun.iter(self.blocks):map(map):to_list(), "blocks")
   return {
      blocks = blocks,
      subplan_true = self.subplan_true and nbt.newClassCompound(self.subplan_true),
      subplan_false = self.subplan_false and nbt.newClassCompound(self.subplan_false)
   }
end

function VisualAIPlan:deserialize_nbt(t)
   local function map(n)
      local block = n:getArbitraryTable()
      block.proto = data["visual_ai.block"]:ensure(block._id)
      return block
   end
   self.blocks = fun.iter(t["blocks"]:getValue()):map(map):to_list()

   if t["subplan_true"] then
      self.subplan_true = t["subplan_true"]:getClassCompound()
      self.subplan_true.parent = self
   end
   if t["subplan_false"] then
      self.subplan_false = t["subplan_false"]:getClassCompound()
      self.subplan_false.parent = self
   end

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

   if cur.proto.type == "action" or cur.proto.type == "special" then
      if cur.proto.is_terminal then
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
      while true do
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
         elseif last_block.proto.type == "action"
            or last_block.proto.type == "special"
         then
            if not last_block.proto.is_terminal then
               coroutine.yield("line", x-1, y, { "right", x, y }, self)
               coroutine.yield("empty", x, y, "", self)
            end
         end

         coroutine.yield(nil)
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
   elseif last_block.proto.type == "action" or last_block.proto.type == "special" then
      if not last_block.proto.is_terminal then
         errors[#errors+1] = { message = "Non-terminal action is missing next block.", x = x - 1, y = y }
      end
   end

   return errors
end

function VisualAIPlan:_insert_block(block)
   assert(self:can_add_block())
   assert(block._id)
   assert(block.proto)
   assert(block.vars)

   self.blocks[#self.blocks+1] = block
   return self.blocks[#self.blocks]
end

function VisualAIPlan:add_condition_block(block, subplan_true, subplan_false)
   if block.proto.type ~= "condition" then
      error("Block prototype must be 'condition'.")
   end

   local block = self:_insert_block(block)

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

   return block
end

function VisualAIPlan:add_target_block(block)
   if block.proto.type ~= "target" then
      error("Block prototype must be 'target'.")
   end

   return self:_insert_block(block)
end

function VisualAIPlan:add_action_block(block)
   if block.proto.type ~= "action" then
      error("Block prototype must be 'action'.")
   end

   return self:_insert_block(block)
end

function VisualAIPlan:add_special_block(block)
   if block.proto.type ~= "special" then
      error("Block prototype must be 'special'.")
   end

   return self:_insert_block(block)
end

function VisualAIPlan:add_block(block)
   local idx = table.index_of(self.blocks, block)
   if idx ~= nil then
      error(("Block '%s' already exists in this plan."):format(tostring(block)))
   end
   local proto = block.proto
   if proto.type == "condition" then
      return self:add_condition_block(block, nil, nil)
   elseif proto.type == "target" then
      return self:add_target_block(block)
   elseif proto.type == "action" then
      return self:add_action_block(block)
   elseif proto.type == "special" then
      return self:add_special_block(block)
   else
      error("unknown block type " .. tostring(proto.type))
   end
end

function VisualAIPlan:replace_block(block, new_block)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   local function snip_rest()
      for i = idx, #self.blocks do
         self.blocks[i] = nil
      end
   end

   local proto = new_block.proto

   local current = self:current_block()
   if block == current and current.proto.type == "condition" and proto.type ~= "condition" then
      self.subplan_true = nil
      self.subplan_false = nil
   end

   if proto.type == "condition" then
      if block.proto.type == "condition" then
         self.blocks[idx] = new_block
      else
         snip_rest()
         self:add_condition_block(new_block, nil, nil)
      end
   elseif proto.type == "target" then
      self.blocks[idx] = new_block
   elseif proto.type == "action" then
      if proto.is_terminal then
         snip_rest()
         self:add_action_block(new_block)
      else
         self.blocks[idx] = new_block
      end
   elseif proto.type == "special" then
      if proto.is_terminal then
         snip_rest()
         self:add_special_block(new_block)
      else
         self.blocks[idx] = new_block
      end
   else
      error("unknown block type " .. tostring(proto.type))
   end

   return self.blocks[idx]
end

function VisualAIPlan:merge(other)
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

   local len = #self.blocks
   for i = idx, len do
      local block = self.blocks[i]
      if block.proto.type == "condition" then
         assert(i == len)
         right:add_condition_block(block, self.subplan_true, self.subplan_false)
      else
         right:add_block(block)
      end
      self.blocks[i] = nil
   end
   self.subplan_true = nil
   self.subplan_false = nil
   return right
end

function VisualAIPlan:insert_block_before(block, new_block, split_type)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   local proto = new_block.proto

   local function snip_rest()
      for i = idx, #self.blocks do
         self.blocks[i] = nil
      end
   end

   if proto.type == "condition" then
      local right = self:split(idx)
      if split_type == "true_branch" then
         self:add_condition_block(new_block, right, nil)
      elseif split_type == "false_branch" then
         self:add_condition_block(new_block, nil, right)
      else
         error("unknown split type " .. tostring(split_type))
      end
   elseif proto.type == "target" then
      table.insert(self.blocks, idx, new_block)
   elseif proto.type == "action" then
      if proto.is_terminal then
         snip_rest()
         self:add_action_block(new_block)
      else
         table.insert(self.blocks, idx, new_block)
      end
   elseif proto.type == "special" then
      if proto.is_terminal then
         snip_rest()
         self:add_special_block(new_block)
      else
         table.insert(self.blocks, idx, new_block)
      end
   else
      error("unknown block type " .. tostring(proto.type))
   end

   return self.blocks[idx]
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
      self:merge(to_merge)
   end
end

function VisualAIPlan:remove_block_and_rest(block)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   if block.proto.type == "condition" then
      -- This block must be at the end.
      assert(idx == #self.blocks)
      self.subplan_true = nil
      self.subplan_false = nil
   end

   for i = idx, #self.blocks do
      self.blocks[i] = nil
   end
end

function VisualAIPlan:swap_branches(block)
   local idx = table.index_of(self.blocks, block)
   if idx == nil then
      error(("No block '%s' in this plan."):format(tostring(block)))
   end

   if block.proto.type ~= "condition" then
      return
   end

   local temp = self.subplan_true
   self.subplan_true = self.subplan_false
   self.subplan_false = temp
end

function VisualAIPlan:serialize()
   self.parent = nil
   for _, block in ipairs(self.blocks) do
      block.proto = nil
   end
   if self.subplan_true then
      self.subplan_true.parent = nil
   end
   if self.subplan_false then
      self.subplan_false.parent = nil
   end
end

function VisualAIPlan:deserialize()
   for _, block in ipairs(self.blocks) do
      -- TODO remove block if invalid, don't throw an error
      block.proto = data["visual_ai.block"]:ensure(block._id)
      assert(block.proto)
   end
   if self.subplan_true then
      self.subplan_true.parent = self
   end
   if self.subplan_false then
      self.subplan_false.parent = self
   end
end

return VisualAIPlan
