-- https://gist.github.com/johndgiese/3e1c6d6e0535d4536692

-- circular buffer factory for lua


local function rotate_indice(i, n)
    return ((i - 1) % n) + 1
end

local CircularBuffer = class.class("CircularBuffer")

function CircularBuffer:filled()
    return #(self.history) == self.max_length
end

function CircularBuffer:len()
    return #(self.history)
end

function CircularBuffer:clear()
   for i, _ in ipairs(self.history) do
      self.history[i] = nil
   end
end

function CircularBuffer:push(value)
    if self:filled() then
        local value_to_be_removed = self.history[self.oldest]
        self.history[self.oldest] = value
        self.oldest = self.oldest == self.max_length and 1 or self.oldest + 1
    else
        self.history[#(self.history) + 1] = value
    end
end

-- positive values index from newest to oldest (starting with 1)
-- negative values index from oldest to newest (starting with -1)
function CircularBuffer:get(i)
    local history_length = #(self.history)
    if i == 0 or math.abs(i) > history_length then
        return nil
    elseif i >= 1 then
        local i_rotated = rotate_indice(self.oldest - i, history_length)
        return self.history[i_rotated]
    elseif i <= -1 then
        local i_rotated = rotate_indice(i + 1 + self.oldest, history_length)
        return self.history[i_rotated]
    end
end

local function iter(state, i)
   if i >= #state.history then
      return nil
   end

   i = i + 1
   local value = CircularBuffer.get(state, i)

   return i, value
end

local function iter_reverse(state, i)
   if i >= #state.history then
      return nil
   end

   i = i + 1
   local value = CircularBuffer.get(state, -i)

   return i, value
end

function CircularBuffer:iter()
   return iter, self, 1
end

function CircularBuffer:iter_reverse()
   return iter_reverse, self, 1
end

function CircularBuffer:__len()
    return #(self.history)
end

function CircularBuffer:init(max_length)
    if type(max_length) ~= 'number' or max_length <= 1 then
        error("Buffer length must be a positive integer")
    end

    self.history = {}
    self.oldest = 1
    self.max_length = max_length
    self.push = CircularBuffer.push
    self.filled = CircularBuffer.filled
    self.len = CircularBuffer.len
    self.clear = CircularBuffer.clear
end

return CircularBuffer
