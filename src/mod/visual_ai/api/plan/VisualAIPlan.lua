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
         coroutine.yield("line", x-1, y, { "right", x, y }, self)
         coroutine.yield("empty", x, y, self)
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
      elseif last_block.proto.type == "action" then
         if last_block.proto.is_terminal == false then
            coroutine.yield("line", x-1, y, { "right", x, y }, self)
            coroutine.yield("empty", x, y, self)
         end
      end
   end

   return CoIter.iter(f)
end

function VisualAIPlan:_insert_block(proto_id)
   assert(self:can_add_block())

   local proto = data["visual_ai.block"]:ensure(proto_id)

   local vars = utils.get_default_vars(proto.vars)

   self.blocks[#self.blocks+1] = {
      _id = proto_id,
      proto = proto,
      vars = vars
   }
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

function VisualAIPlan:remove_block(block)
   error("TODO")
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
