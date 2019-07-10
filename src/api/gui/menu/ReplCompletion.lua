local ReplCompletion = class.class("ReplCompletion")

function ReplCompletion:init()
end

function ReplCompletion:find_boundary(line)
   local parens = {}
   local paren_level = 1
   for i, ch in utf8.chars(line) do
      if ch == "(" then
         parens[paren_level] = i
         paren_level = paren_level + 1
      elseif ch == ")" then
         paren_level = paren_level - 1
      end
   end
   return string.sub(line, parens[paren_level-1] or 1)
end

function ReplCompletion:complete(line, repl_env)
   local partial = self:find_boundary(line)
   local parts = string.split(partial, ".")
   _p(partial, parts)

   local cur = repl_env

   for i=1,#parts-1 do
      local part = parts[i]
      cur = cur[part]
      if cur == nil then
         return nil
      end
   end

   if cur == nil then
      return nil
   end

   local keys = table.keys(cur)
   local incomplete = parts[#parts]

   local pred = function(s) return string.has_prefix(s, incomplete) end
   return fun.iter(keys):filter(pred):to_list()
end

return ReplCompletion
