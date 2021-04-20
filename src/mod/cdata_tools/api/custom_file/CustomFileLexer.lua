local BYTE_PERCENT = string.byte("%")
local BYTE_LF, BYTE_CR = string.byte("\n"), string.byte("\r")
local Log = require("api.Log")

local CustomFileLexer = class.class("CustomFileLexer")

local function strip_comments(content)
   local result = {}
   for line in string.lines(content) do
      line = line:gsub("//(.*)", "")
      line = line:gsub("[ \t]+$", "")

      if line ~= "" then
         result[#result+1] = line
      end
   end
   return table.concat(result, "\n")
end

function CustomFileLexer:init(src)
   self.src = strip_comments(src)
   self.line = 1
   self.line_offset = 1
   self.offset = 1
   self.in_text = nil
   self.has_event = false
end

local function is_newline(b)
   return (b == BYTE_LF) or (b == BYTE_CR)
end

local function peek_byte(self)
   return string.byte(self.src, self.offset)
end

local function next_byte(self, inc)
   inc = inc or 1
   self.offset = self.offset+inc
   return peek_byte(self)
end

local function skip_until(self, byte)
   local b = peek_byte(self)

   while b ~= byte and b ~= nil do
      b = next_byte(self)
   end

   next_byte(self)

   return b
end

local function skip_until_after_newline(self)
   local b = peek_byte(self)
   while not is_newline(b) and b ~= nil do
      b = next_byte(self)
   end

   local finish = self.offset-1

   b = next_byte(self)

   if b == BYTE_CR then
      b = next_byte(self)
      finish = finish-1
   end

   return b, finish
end

function CustomFileLexer:read_rest_of_line()
   local start = self.offset

   local _, finish = skip_until_after_newline(self)

   local line = string.sub(self.src, start, finish)

   return line
end

function CustomFileLexer:skip_blank_lines()
   local b = peek_byte(self)
   while is_newline(b) do
      b = skip_until_after_newline(self)
   end
end

local function split(s, delimiter)
   local result = {};
   for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match);
   end
   return result;
end

-- %someDirective
function CustomFileLexer:read_directive()
   local b = skip_until(self, BYTE_PERCENT)
   if not b then
      error("end of file")
   end
   print("read")

   local line = self:read_rest_of_line()

   local result = split(line, ",")

   if string.sub(result[1], 1, 3) == "txt" then
      if result[1] == "txt_ucnpc_ev_b" then
         if self.has_event then
            error("Already in event")
         end
         self.has_event = true
      elseif result[1] == "txt_ucnpc_ev_e" then
         if not self.has_event then
            error("Not in event")
         end
         self.has_event = false
      else
         if self.in_text then
            Log.warn("Already in text %s", self.in_text[1])
         end
         self.in_text = result
      end
   elseif string.sub(result[1], 1, 3) == "END" then
      if not self.in_text then
         Log.warn("Not in text")
      end
      self.in_text = nil
   end

   return result
end

local function match(s, p)
   local t = {}
   for k, v in string.gmatch(s, p) do
      t[#t+1] = k
      if v then
         t[#t+1] = v
      end
   end
   return t
end

-- prop. "value"
function CustomFileLexer:read_option()
   local line = self:read_rest_of_line()

   local result = match(line, "(%S+)%.[ \t]+\"(.*)\"")

   if #result == 0 then
      return nil
   end

   return result
end

-- (any line)
function CustomFileLexer:read_line()
   return self:read_rest_of_line()
end

function CustomFileLexer:has_directive()
   return peek_byte(self) == BYTE_PERCENT
end

function CustomFileLexer:end_of_file()
   return peek_byte(self) == nil
end

return CustomFileLexer
