local Fs = require("api.Fs")
local Sjis = require("mod.extlibs.api.Sjis")

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

function Csv.parse(line_iter, opts)
   opts = opts or {}
   local header = opts.header
   local shift_jis = opts.shift_jis
   local strict = opts.strict

   local iter = line_iter
   if shift_jis then
      iter = iter:map(Sjis.to_utf8)
   end

   iter = iter:map(Csv.parse_line)

   local header_
   if header then
      header_ = iter:nth(1)
      iter = iter:drop(1)
   end

   local first = header_ or iter:nth(1)
   if strict and first then
      iter = iter:filter(function(l) return #l == #first end)
   end

   if header then
      local map = function(r)
         local res = {}
         for i, k in ipairs(header_) do
            res[k] = r[i] or ""
         end
         return res
      end
      iter = iter:map(map)
   end

   return iter:unwrap_with_self()
end

function Csv.parse_string(s, opts)
   local iter = fun.wrap(fun.dup(string.lines(s)))
   return Csv.parse(iter, opts)
end

function Csv.parse_file(filename, opts)
   local s, err = Fs.read_all(filename)
   if s == nil then
      return nil, err
   end
   return Csv.parse_string(s, opts)
end

return Csv
