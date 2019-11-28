skip_list = require 'thirdparty.skip_list'

sl = skip_list:new()

local size = 1e4
-----------------------------
-- TEST INSERTION & ITERATE
-----------------------------
print 'Running insertion and iteration test'
local list = {}
for i = 1,size do
	local v = math.random(1,size)
	table.insert(list,v)
	sl:insert(v)
end
sl:check()

table.sort(list)

local i = 0
for k,v in sl:iterate() do
	i = i + 1
	if k ~= list[i] then
		error('Invalid key in skip list: '..k..' vs '..list[i])
	end
end

-----------------------------
-- TEST FIND
-----------------------------
print 'Running find test'
for i = 1,size do
	local k,v,node = sl:find(list[math.random(1,size)])
	assert(k == node.key and v == node.value)
end

-----------------------------
-- TEST POP
-----------------------------
print 'Running pop test'
for i = 1,math.floor(.1*size) do
	local peeked = sl:peek()
	local popped = sl:pop()
	assert(popped == table.remove(list,1) and popped == peeked)
end
sl:check()

-----------------------------
-- TEST DELETE
-----------------------------
print 'Running delete test'
for i = 1,math.floor(.4*size) do
	local x = math.random(1,i)
	assert(sl:delete(list[x]) == table.remove(list,x),x)
end
sl:check()

-----------------------------
-- CHECK AGAIN VIA ITERATION
-----------------------------
local j = 1

local i = 0
for k,v in sl:iterate() do
	i = i + 1
	assert(k == list[j])
	j = j + 1
end

------------------------------------
-- TEST KEY-VALUE PAIR AND STABILITY
------------------------------------
print 'Running key-value pair and stability test'
sl:clear()

local kvlist = {}
for i = 1,size do
	kvlist[i] = {key = math.random(1,size),value = i}
	sl:insert(kvlist[i].key,kvlist[i].value)
end
sl:check()
table.sort(kvlist,function(a,b)
	return a.key < b.key or a.key == b.key and a.value < b.value
end)

local i = 0
for k,v in sl:iterate() do
	i = i + 1
	assert(k == kvlist[i].key and v == kvlist[i].value)
end

-----------------------------
-- TEST REVERSE ORDER
-----------------------------
print 'Running reverse iteration test'
sl = skip_list:new(nil,function(a,b) return a > b end)

local list = {}
for i = 1,size do
	local v = math.random(1,size)
	table.insert(list,v)
	sl:insert(v)
end
sl:check()

table.sort(list,function(a,b) return a > b end)

local i = sl:length()
for k,v in sl:iterate('reverse') do
	if k ~= list[i] then
		error('Invalid key in skip list: '..k..' vs '..list[i])
	end
	i = i - 1
end

---------------------------------
-- TEST INSERT & POP & DELETE MIX
---------------------------------

local insert_count = 100
local pop_count    = 25
local delete_count = 25
local runs         = 200
local range        = 10000
local comp         = function(a,b) return a < b end

sl = skip_list:new(nil,comp)
local copy_list = {}
print 'Running skip list integrity test:'
for i = 1,runs do
	for j = 1,insert_count do
		local key = math.random(range)
		sl:insert(key)
		table.insert(copy_list,key)
		if sl:length() % 10 == 0 then
			io.write('Step: ',i,'/',runs,': List size: ',sl:length(),'\r')
		end
	end
	table.sort(copy_list,comp)
	sl:check()

	local low = 0
	for k = 1,pop_count do
		local peeked = sl:peek()
		local key    = sl:pop()
		local key2   = table.remove(copy_list,1)
		assert(peeked == key, 'Invalid peeked key!')
		assert(key2 == key, 'Invalid popped key!')
		if not comp(low,key) and low ~= key then
			error(string.format('Popped %d after %d',key,low))
		end
		low = key
		if sl:length() % 10 == 0 then
			io.write('Step: ',i,'/',runs,': List size: ',sl:length(),'\r')
		end
	end
	sl:check()

	for l = delete_count,1,-1 do
		local index = math.random(sl:length())
		local key   = sl:delete(copy_list[index])
		local key2  = table.remove(copy_list,index)
		if key ~= key2 then
			error(string.format('Deletion failed: %s ~= %s',tostring(key),tostring(key2)))
		end
		if sl:length() % 10 == 0 then
			io.write('Step: ',i,'/',runs,': List size: ',sl:length(),'\r')
		end
	end
	sl:check()
end
print '\nEmptying skip list...'
local low = 0
while sl:length() > 0 do
	local key = sl:pop()
	if not comp(low,key) and low ~= key then
		error(string.format('Invalid pop order: %s before %s',tostring(low),tostring(key)))
	end
	low = key
end
for i,v in pairs(sl.head) do
	error 'Skip list was not emptied properly!'
end
print 'Done'
