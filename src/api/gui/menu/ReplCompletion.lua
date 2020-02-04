local ReplCompletion = class.class("ReplCompletion")

function ReplCompletion:init()
end

local function last_index_of(str, c)
   return string.find(str, c .. "[^" .. c .. "]*$")
end

function ReplCompletion:find_boundary(line)
   local parens = {}
   local paren_level = 1

   -- We have to find the start of a statement past the first comma
   -- that is found. So first find the last comma, then split the line
   -- there and add the offset of the prefix of the original line so
   -- the offsets are correct.
   local offset = last_index_of(line, ",") or 0
   local past_comma
   if offset then
      offset = offset + 1
   else
      offset = 0
   end

   -- Add existing offset to the substring past the first comma.
   local rest = string.sub(line, offset)
   local offset_b = string.find(rest, "%s")
   if offset_b then
      offset_b = offset_b - 1
   else
      offset_b = 0
   end
   offset = offset + offset_b
   past_comma = string.sub(line, offset-1)

   for i, ch in utf8.chars(past_comma) do
      if ch == "(" then
         parens[paren_level] = offset + i - 2
         paren_level = paren_level + 1
      elseif ch == ")" then
         paren_level = paren_level - 1
      end
   end
   local ind = parens[paren_level-1] or (offset-1)
   return string.split_at_pos(line, ind)
end

function ReplCompletion:complete(line, root_env)
   local prefix, partial = self:find_boundary(line)
   local parts = string.split(partial, ".")

   local has_colon = string.find(parts[#parts], ":")
   if has_colon then
      local part_with_colon = parts[#parts]
      local s = string.split(part_with_colon, ":")
      parts[#parts] = s[1]
      parts[#parts+1] = s[2]
   end

   local cur = root_env

   for i=1,#parts-1 do
      local part = parts[i]
      local next_part = cur[part]

      -- Try to call zero-argument functions along the chain
      if next_part == nil and string.match(part, "%(%)$") then
         local fn_name = string.gsub(part, "(.*)%(%)$", "%1")
         local fn = cur[fn_name]
         if type(fn) == "function" then
            local success, res = pcall(fn)
            if success then
               next_part = res
            end
         end
      end

      if next_part == nil then
         return nil
      end

      cur = next_part
   end

   if cur == nil then
      return nil
   end

   -- Sometimes the REPL environment will be a proxy with no actual
   -- keys. In this case we can't call table.keys on it, so there will
   -- be no completions if the table is in the root environment.
   -- Instead we generate a __keys field in Repl.generate_env and keep
   -- it on the environment's metatable for completion purposes.
   local mt = getmetatable(cur)
   local keys = mt and mt.__keys
   if keys == nil then
      keys = table.keys(cur)
   end

   if cur.__iface and cur.__iface.all_methods then
      for k, v in pairs(cur.__iface.all_methods) do
         keys[#keys+1] = k
         -- keys[#keys+1] = { k, v.iface_path }
      end
   end
   local incomplete = parts[#parts]
   local pos
   if has_colon then
      pos = last_index_of(partial, ":")
   else
      pos = last_index_of(partial, "%.")
   end

   local base = prefix
   if pos then
      base = base .. string.split_at_pos(partial, pos)
   end

   local pred = function(s) return string.has_prefix(s, incomplete) end
   local trans = function(i)
      return {
         text = i,
         type = type(cur[i])
      }
   end

   local candidates = fun.iter(keys):filter(pred):map(trans):to_list()

   if #candidates == 0 then
      return nil
   end

   return {
      prefix = prefix,
      base = base,
      candidates = candidates,
      selected = -1
   }
end

return ReplCompletion
