local VisualAIPlan = class.class("VisualAIPlan")
local CoIter = require("mod.visual_ai.api.CoIter")

function VisualAIPlan:init()
   self.blocks = {}
   self.subplan_true = nil
   self.subplan_false = nil
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
         coroutine.yield("block", x, y, self.blocks[i])
         if i < #self.blocks then
            coroutine.yield("line", x, y, { "right", x + 1, y })
         end

         i = i + 1
         x = x + 1
      end

      local last_block = self:current_block()

      if last_block == nil then
         -- empty plan
         coroutine.yield("line", x-1, y, { "right", x, y })
         coroutine.yield("empty", x, y)
      elseif last_block.proto.type == "condition" then
         coroutine.yield("line", x-1, y, { "right", x, y })
         for _, state, cx, cy, block in self.subplan_true:iter_tiles(x, y) do
            coroutine.yield(state, cx, cy, block)
         end

         local _, height = self.subplan_true:tile_size()
         coroutine.yield("line", x - 1, y, { "down", x - 1, y + height })
         for _, state, cx, cy, block in self.subplan_false:iter_tiles(x-1, y + height) do
            coroutine.yield(state, cx, cy, block)
         end
      elseif last_block.proto.type == "action" then
         if last_block.proto.is_terminal == false then
            coroutine.yield("line", x-1, y, { "right", x, y })
            coroutine.yield("empty", x, y)
         end
      end
   end

   return CoIter.iter(f)
end

local function get_default_var_value(var)
   assert(type(var) == "table")

   local ty = var.type

   if ty == "comparator" then
      return "<"
   elseif ty == "number" or ty == "integer" then
      return var.max_value or var.min_value or 0
   else
      error("unknown block variable type ".. tostring(ty))
   end
end

function VisualAIPlan:_insert_block(proto_id)
   assert(self:can_add_block())

   local proto = data["visual_ai.block"]:ensure(proto_id)

   local vars = {}
   for k, var in pairs(proto.vars or {}) do
      local value = get_default_var_value(var)
      vars[k] = assert(value)
   end

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
      block.proto = data["visual_ai.block"]:ensure(proto_id)
   end
end

return VisualAIPlan
