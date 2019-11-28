local Fs = require("api.Fs")

local Csv = {}

-- from http://lua-users.org/wiki/CsvUtils
function Csv.parse_line (s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

function Csv.parse(s)
   local iter = fun.wrap(fun.dup(string.lines(s))):map(Csv.parse_line)
   local first = iter:nth(1)
   if first then
      iter = iter:filter(function(l) return #l == #first end)
   end

   return iter
end

function Csv.parse_file(filename)
   local s, err = Fs.read_all(filename)
   if s == nil then
      return nil, err
   end
   return Csv.parse(s)
end

return Csv
