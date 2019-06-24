-- file: skiplist.lua

--[[------------------------------------------------------------------
The MIT License

Original Python version Copyright (c) 2009 Raymond Hettinger
see http://code.activestate.com/recipes/576930/

Lua conversion + extensions Copyright (c) 2010 Pierre-Yves Gérardy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]------------------------------------------------------------------

local log, floor, ceil, min, random
= math.log, math.floor, math.ceil, math.min, math.random

local makeNode = function(value,size)
	return {
		value=value,
		next={},
		width={},
		size=size
	}
end

local End ={}
local NIL = makeNode(End,0)

local insert = function(self,value)
	local node, chain, stepsAtLevel = self.head, {}, {}
	for i=1, self.maxLevel do stepsAtLevel[i]=0 end
	for level = self.maxLevel, 1, -1 do
		while node.next[level] ~= NIL and node.next[level].value <= value do
			stepsAtLevel[level] = ( stepsAtLevel[level] or 0 ) + node.width[level]
			node = node.next[level]
			--print(level, stepsAtLevel[level],value)
		end
		chain[level]=node
	end

	local nodeLevel = min( self.maxLevel, - floor(log(random()) / log(2) ) )
	local newNode = makeNode( value,  nodeLevel)
	local steps, prevNode = 0
	for level= 1, nodeLevel do
		prevNode = chain[level]
		newNode.next[level] = prevNode.next[level]
		prevNode.next[level] = newNode
		newNode.width[level] = prevNode.width[level] - steps
		prevNode.width[level] = steps + 1
		steps = steps + stepsAtLevel[level]
	end
	for level = nodeLevel + 1, self.maxLevel do
		chain[level].width[level] = chain[level].width[level] +1
	end
	self.size = self.size + 1
end

local delete = function(self,value)
	-- find first node on each level where node.next[levels].value >= value

	node, chain = self.head, {}
	for level = self.maxLevel, 1, -1 do
		while node.next[level] ~= NIL and node.next[level].value < value do
			node = node.next[level]
		end
		chain[level] = node
	end
	if value ~= chain[1].next[1].value then
		return nil, "value not found: "..value
	end

	-- remove one link at each level
	nodeLevel = chain[1].next[1].size
	for level = 1, nodeLevel do
		prevnode = chain[level]
		prevnode.width[level] = prevnode.width[level] + prevnode.next[level].width[level] - 1
		prevnode.next[level] = prevnode.next[level].next[level]
	end
	for level = nodeLevel+1, self.maxLevel do
		chain[level].width[level] = chain[level].width[level] - 1
	end
	self.size = self.size - 1
	return true --success
end


local first = function(self)
	return self.head.next[1].value
end

local pop=function (self)
	if self.size == 0 then return nil, "Trying to pop an empty list" end

	local node, head = self.head.next[1], self.head
	for level = 1, node.size do
		head.next[level]=node.next[level]
		head.width[level]=node.width[level]
	end
	for level = node.size + 1, self.maxLevel do
		head.width[level] = head.width[level] -1
	end
	self.size = self.size - 1
	return node.value
end

-- get the value of the node at index i ( O( log( n ) ) )

local tostring = function (self)
	local t = {}
	for k,v in self:ipairs() do table.insert(t,v) end
	return "( "..table.concat(t,", ").. " )"
end


local islMT = {
	__index = function(self,i)
		if type(i) ~= "number" then return end
		if i > self.size then return end
		local node = self.head

		for level=self.maxLevel, 1, -1 do
			while node.width[level] <= i do
				i = i - node.width[level]
				node = node.next[level]
			end
		end
		return node.value
	end,
	__tostring=tostring
}


local ipairs = function (self)
	local node, size = self.head.next[1] , self.size
	count = 0
	return function()
		value=node.value
		node = node.next[1]
		count = count+1
		return count <= size and count or nil, value
	end
end

local function new (expected_size)
	local size = expected_size or 16
	if not expected_size then
		expected_size = 16
	end

	local maxLevel = floor( log(expected_size) / log(2) )
	local head = makeNode("HEAD",maxLevel)
	for i=1,maxLevel do
		head.next[i] = NIL
		head.width[i] = 1
	end

	return setmetatable( {
		size = 0,
		head = head,
		maxLevel = maxLevel,
		insert = insert,
		delete = delete,
		first = first,
		tostring = tostring,
		ipairs=ipairs,
		pop = pop
		}, islMT
	)
end

return {
	new=new
}
