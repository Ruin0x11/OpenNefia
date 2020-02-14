--- A class for generating serializable Lua code which can be compiled
--- with `loadstring`.
---
--- It is modified from `inspect.lua` since serialization is
--- explicitly not one of its features.

local tostring = tostring

local CodeGenerator = class.class("CodeGenerator")

local KEY       = setmetatable({}, {__tostring = function() return 'CodeGenerator.KEY' end})
local METATABLE = setmetatable({}, {__tostring = function() return 'CodeGenerator.METATABLE' end})

local function rawpairs(t)
   return next, t, nil
end

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smart_quote(str)
   if str:match('"') and not str:match("'") then
      return "'" .. str .. "'"
   end
   return '"' .. str:gsub('"', '\\"') .. '"'
end

-- \a => '\\a', \0 => '\\0', 31 => '\31'
local short_control_char_escapes = {
   ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n",
   ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}
local long_control_char_escapes = {} -- \a => nil, \0 => \000, 31 => \031
for i=0, 31 do
   local ch = string.char(i)
   if not short_control_char_escapes[ch] then
      short_control_char_escapes[ch] = "\\"..i
      long_control_char_escapes[ch]  = string.format("\\%03d", i)
   end
end

local function escape(str)
   return (str:gsub("\\", "\\\\")
              :gsub("(%c)%f[0-9]", long_control_char_escapes)
              :gsub("%c", short_control_char_escapes))
end

local function is_identifier(str)
   return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function is_sequence_key(k, sequence_length)
   return type(k) == 'number'
      and 1 <= k
      and k <= sequence_length
      and math.floor(k) == k
end

local defaultTypeOrders = {
   ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
   ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sort_keys(a, b)
   local ta, tb = type(a), type(b)

   -- strings and numbers are sorted numerically/alphabetically
   if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

   local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
   -- Two default types are compared according to the defaultTypeOrders table
   if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
   elseif dta     then return true  -- default types before custom ones
   elseif dtb     then return false -- custom types after default ones
   end

   -- custom types are sorted out alphabetically
   return ta < tb
end

-- For implementation reasons, the behavior of rawlen & # is "undefined" when
-- tables aren't pure sequences. So we implement our own # operator.
local function get_sequence_length(t)
   local len = 1
   local v = rawget(t,len)
   while v ~= nil do
      len = len + 1
      v = rawget(t,len)
   end
   return len - 1
end

local function get_non_sequential_keys(t)
   local keys, keys_length = {}, 0
   local sequence_length = get_sequence_length(t)
   for k,_ in rawpairs(t) do
      if not is_sequence_key(k, sequence_length) then
         keys_length = keys_length + 1
         keys[keys_length] = k
      end
   end
   table.sort(keys, sort_keys)
   return keys, keys_length, sequence_length
end



-------------------------------------------------------------------

function CodeGenerator:write(...)
   local args   = {...}
   local buffer = self.buffer
   local len    = #buffer
   for i=1, #args do
      len = len + 1
      buffer[len] = args[i]
   end
   self.bol = false
end

function CodeGenerator:write_table_start(opts)
   if self.in_table[#self.in_table] then
      self:tabify()
   end
   self.in_table[#self.in_table+1] = false

   self:write("{")
   if opts and opts.no_indent then
      self:write(" ")
   else
      self.level = self.level + 1
   end
end

function CodeGenerator:write_table_end(opts)
   local it = self.in_table[#self.in_table]
   self.in_table[#self.in_table] = nil

   if opts and opts.no_indent then
      self:write(" }")
      self:tabify()
   else
      self.level = self.level - 1
      if it then
         self:tabify()
      end
      self:write("}")
   end
end

function CodeGenerator:down(f)
   self.level = self.level + 1
   f()
   self.level = self.level - 1
end

function CodeGenerator:tabify(opts)
   if self.in_table[#self.in_table] then
      self:write(",")
      self.in_table[#self.in_table] = false
   end
   local level = (opts and opts.indent) or self.level
   self:write(self.newline, string.rep(self.indent, level))
   self.bol = true
end

function CodeGenerator:already_visited(v)
   return self.ids[v] ~= nil
end

function CodeGenerator:get_id(v)
   local id = self.ids[v]
   if not id then
      local tv = type(v)
      id              = (self.max_ids[tv] or 0) + 1
      self.max_ids[tv] = id
      self.ids[v]     = id
   end
   return tostring(id)
end

function CodeGenerator:write_key(k)
   if is_identifier(k) then return self:write(k) end
   self:write("[")
   self:write_value(k)
   self:write("]")
end

function CodeGenerator:write_table(t)
   if t == KEY or t == METATABLE then
      self:write(tostring(t))
   elseif self:already_visited(t) then
      self:write('<table ', self:get_id(t), '>')
   elseif self.level >= self.depth then
      self:write('{...}')
   else
      local non_sequential_keys, non_sequential_keys_length, sequence_length = get_non_sequential_keys(t)
      local mt                = getmetatable(t)

      self:write('{')
      self:down(function()
            local count = 0
            for i=1, sequence_length do
               if count > 0 then self:write(',') end
               self:write(' ')
               self:write_value(t[i])
               count = count + 1
            end

            for i=1, non_sequential_keys_length do
               local k = non_sequential_keys[i]
               if count > 0 then self:write(',') end
               self:tabify()
               self:write_key(k)
               self:write(' = ')
               self:write_value(t[k])
               count = count + 1
            end
      end)

      if non_sequential_keys_length > 0 or type(mt) == 'table' then -- result is multi-lined. Justify closing }
         self:tabify()
      elseif sequence_length > 0 then -- array tables have one extra space before closing }
         self:write(' ')
      end

      self:write('}')
   end
end

function CodeGenerator:write_value(v)
   local tv = type(v)

   if tv == 'string' then
      self:write(smart_quote(escape(v)))
   elseif tv == 'number' or tv == 'boolean' or tv == 'nil' or
   tv == 'cdata' or tv == 'ctype' then
      self:write(tostring(v))
   elseif tv == 'table' then
      local mt = getmetatable(v)
      local codegen_type = mt and mt.__codegen_type
      if codegen_type == "literal" then
         self:write(v[1])
      elseif codegen_type == "block_string" then
         self:write("[[")
         self:write(v[1])
         self:write("]]")
      else
         self:write_table(v)
      end
   else
      error(("cannot output value of type '%s' as lua code"):format(tv))
   end
end

function CodeGenerator:gen_block_string(str)
   return setmetatable({str}, {__codegen_type="block_string"})
end

function CodeGenerator:gen_literal(str)
   return setmetatable({str}, {__codegen_type="literal"})
end

function CodeGenerator:write_return()
   assert(not self.in_table[#self.in_table], "cannot write return inside table")
   self:write("return ")
end

function CodeGenerator:write_local()
   assert(not self.in_table[#self.in_table], "cannot write local inside table")
   self:write("local ")
end

function CodeGenerator:write_assignment(name)
   assert(not self.in_table[#self.in_table], "cannot write assignment inside table")
   self:write(name, " = ")
end

function CodeGenerator:write_ident(name)
   self:write(name)
end

function CodeGenerator:write_comment(body, opts)
   if self.in_table[#self.in_table] then
      self.in_table[#self.in_table] = false
   end
   if not self.bol then
      self:write(" ")
   end
   for line in string.lines(body) do
      if opts and opts.type == "docstring" then
         self:write("--- ")
      else
         self:write("-- ")
      end
      self:write(line)
      self:tabify()
   end
end

function CodeGenerator:write_block_comment(body, opts)
   if not self.bol then
      self:tabify({indent = 0})
   end
   if self.in_table[#self.in_table] then
      self.in_table[#self.in_table] = false
   end
   if opts and opts.type == "docstring" then
      self:write("---[[")
   else
      self:write("--[[")
   end
   self:write(body)
   if opts and opts.type == "docstring" then
      self:write("---]]")
   else
      self:write("--]]")
   end
   self:tabify()
end

function CodeGenerator:write_key_value(k, v)
   if not self.bol then
      self:tabify()
   end
   self:write_key(k)
   self:write(" = ")
   self:write_value(v)
   self.in_table[#self.in_table] = true
end

function CodeGenerator:init(options)
   options       = options or {}

   local depth   = options.depth   or math.huge
   local newline = options.newline or '\n'
   local indent  = options.indent  or '  '

   self.depth            = depth
   self.level            = 0
   self.buffer           = {}
   self.ids              = {}
   self.max_ids          = {}
   self.in_table         = {}
   self.newline          = newline
   self.indent           = indent
   self.bol              = true
end

function CodeGenerator:__tostring()
   return table.concat(self.buffer)
end

return CodeGenerator
