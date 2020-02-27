local SkipList = require("api.SkipList")

local FuzzyMatch = {}

local BASE_DISTANCE_PENALTY = 0.6;
local ADDITIONAL_DISTANCE_PENALTY = 0.05;
local MIN_DISTANCE_PENALTY = 0.2 + 1/10^9;
local MAX_MEMO_SIZE = 10000;

local sbyte = string.byte
local slen = string.len

local function recursive_match(info, haystack_idx, needle_idx)
   if needle_idx == slen(info.needle) + 1 then
      return 1
   end

   local memoized = info.memoized[needle_idx * slen(info.haystack) + haystack_idx]
   if memoized then
      return memoized
   end

   local score = 0.0
   local best_match_idx = 0
   local c = sbyte(info.needle_cased, needle_idx)

   if info.ignore_spaces and c == sbyte(" ") then
      return recursive_match(info, haystack_idx, needle_idx + 1)
   end

   local limit = info.last_match[needle_idx]
   if needle_idx > 1 and info.max_gap then
      limit = haystack_idx + info.max_gap
   end

   local last_slash_idx = 0
   local dist_penalty = BASE_DISTANCE_PENALTY

   for j=haystack_idx, limit+1 do
      local d = sbyte(info.haystack_cased, j)
      if needle_idx == 1 and (d == sbyte("/") or d == sbyte("\\")) then
         last_slash_idx = j
      end

      if c == d then
         local char_score = 1.0
         if j > haystack_idx then
            local last = sbyte(info.haystack, j-1)
            local curr = sbyte(info.haystack, j)
            if last == sbyte("/") then
               char_score = 0.9
            elseif last == sbyte("-")
               or last == sbyte("_")
               or last == sbyte(" ")
               or (last >= sbyte("0") and last <= sbyte("9"))
            then
               char_score = 0.8
            elseif last >= sbyte("a") and last <= sbyte("z")
               and curr >= sbyte("A") and curr < sbyte("Z")
            then
               char_score = 0.7
            else
               char_score = dist_penalty
            end
            if needle_idx > 1 and dist_penalty > MIN_DISTANCE_PENALTY then
               dist_penalty = dist_penalty - ADDITIONAL_DISTANCE_PENALTY
            end
         end

         if info.smart_case
            and sbyte(info.needle, needle_idx) ~= sbyte(info.haystack, j)
         then
            char_score = char_score * 0.9
         end

         local new_score = char_score * recursive_match(info, j + 1, needle_idx + 1)

         if needle_idx == 1 then
            new_score = new_score / (slen(info.haystack) - last_slash_idx)
         end

         if new_score > score then
            score = new_score
            best_match_idx = j
            if new_score == 1 then
               break
            end
         end
      end
   end

   if info.best_match then
      info.best_match[needle_idx * slen(info.haystack) + haystack_idx] = best_match_idx
   end

   info.memoized[needle_idx * slen(info.haystack) + haystack_idx] = score

   return score
end

function FuzzyMatch.match_one(haystack, needle, opts, match_indexes)
   if slen(needle) == 0 then
      return 1.0
   end

   opts = opts or {}

   local haystack_cased
   if opts.case_sensitive then
      haystack_cased = haystack
   else
      haystack_cased = string.lower(haystack)
   end

   local needle_cased
   if opts.case_sensitive then
      needle_cased = needle
   else
      needle_cased = string.lower(needle)
   end

   local last_match = {}

   local info = {
      haystack = haystack,
      needle = needle,
      haystack_cased = haystack_cased,
      needle_cased = needle_cased,
      smart_case = opts.smart_case,
      max_gap = opts.max_gap or 10,
      ignore_spaces = opts.ignore_spaces,
      last_match = last_match
   }

   local hindex = slen(info.haystack)
   for i=slen(info.needle), 1, -1 do
      if not info.ignore_spaces or sbyte(info.needle_cased, i) ~= sbyte(" ") then
         while hindex >= 1 and sbyte(info.haystack_cased, hindex) ~= sbyte(info.needle_cased, i) do
            hindex = hindex - 1
         end
         if hindex < 1 then
            return 0
         end
      end
      last_match[i] = hindex
      hindex = hindex - 1
   end

   local memo_size = slen(info.haystack) * slen(info.needle)
   if memo_size >= MAX_MEMO_SIZE then
      local penalty = 1.0
      if match_indexes then
         for i = 1, slen(info.needle) do
            match_indexes[i] = last_match[i]
            if i > 1 and last_match[i] ~= last_match[i-1] + 1 then
               penalty = penalty * BASE_DISTANCE_PENALTY
            end
         end
      end
      return penalty * slen(info.needle) / slen(info.haystack)
   end

   if match_indexes then
      info.best_match = {}
   else
      info.best_match = nil
   end

   info.memoized = {}

   local score = slen(info.needle) * recursive_match(info, 1, 1)
   if score <= 0 then
      return 0.0
   end

   if match_indexes then
      local curr_start = 1
      for i=1,slen(info.needle) do
         match_indexes[i] = info.best_match[i * slen(info.haystack) + curr_start]
         curr_start = match_indexes[i] + 1
      end
   end

   return score
end

--- @tparam string query
--- @tparam {string,...} query
--- @tparam[opt] table opts
function FuzzyMatch.match(query, candidates, opts)
   opts = opts or {}
   opts.max_gap = opts.max_gap or 0
   opts.case_sensitive = opts.case_sensitive or false
   opts.smart_case = opts.smart_case or false
   opts.ignore_spaces = opts.ignore_spaces or false

   local results = SkipList:new(#candidates+1)

   for _, cand in ipairs(candidates) do
      local str
      if type(cand) == "table" then
         str = cand[1]
      else
         str = cand
      end
      local score = FuzzyMatch.match_one(str, query, opts)
      if score > 0 then
         local res
         if type(cand) == "table" then
            cand[2] = score
            res = cand
         else
            res = { cand, score }
         end
         results:insert(score, cand)
      end
   end

   local ret = {}
   for i = results:length(), 1, -1 do
      local _, res = results:pop()
      ret[i] = res
   end
   return ret
end

return FuzzyMatch
