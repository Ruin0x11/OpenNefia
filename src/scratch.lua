local function gen_regex(text)
   return "(" .. string.gsub(text, " +", ").*(") .. ")"
end

--- Splits a string `str` on separator `sep`.
---
--- @tparam string str
--- @tparam[opt] string sep defaults to "\n"
--- @treturn {string}
function string.split(str,sep)
   sep = sep or "\n"
   local ret={}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = ret[n] or w
      if w=="" then
         n = n + 1
      end
   end
   return ret
end

local query = "ed vio blu"
local get = "roses are red violets are blue block is push baba is you"

local parts = string.split(query, " ")
local regions = {}
local the_start = 0
for _, part in ipairs(parts) do
   local regex = ("(%s).*"):format(part)
   local start, finish, piece = string.find(get, regex, the_start)
   regions[#regions+1] = {start, string.len(part), piece}
   the_start = start
end

print(require"inspect"(regions))

for _, r in ipairs(regions)  do
   get = get:sub(1, r[1]-1) .. string.upper(r[3]) .. get:sub(r[1] + r[2])
end
print(get)
