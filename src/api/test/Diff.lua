--[[
* Diff Match and Patch
* Copyright 2018 The diff-match-patch Authors.
* https://github.com/google/diff-match-patch
*
* Based on the JavaScript implementation by Neil Fraser.
* Ported to Lua by Duncan Cross.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
--]]

--[[
-- Lua 5.1 and earlier requires the external BitOp library.
-- This library is built-in from Lua 5.2 and later as 'bit32'.
require 'bit'   -- <https://bitop.luajit.org/>
local band, bor, lshift
    = bit.band, bit.bor, bit.lshift
--]]

if jit then
   bit32 = require("bit")
end

local band, bor, lshift
    = bit32.band, bit32.bor, bit32.lshift
local type, setmetatable, ipairs, select
    = type, setmetatable, ipairs, select
local unpack, tonumber, error
    = unpack, tonumber, error
local strsub, strbyte, strchar, gmatch, gsub
    = string.sub, string.byte, string.char, string.gmatch, string.gsub
local strmatch, strfind, strformat
    = string.match, string.find, string.format
local tinsert, tremove, tconcat
    = table.insert, table.remove, table.concat
local max, min, floor, ceil, abs
    = math.max, math.min, math.floor, math.ceil, math.abs
local clock = os.clock


-- Utility functions.

local percentEncode_pattern = '[^A-Za-z0-9%-=;\',./~!@#$%&*%(%)_%+ %?]'
local function percentEncode_replace(v)
  return strformat('%%%02X', strbyte(v))
end

local function indexOf(a, b, start)
  if (#b == 0) then
    return nil
  end
  return strfind(a, b, start, true)
end

local htmlEncode_pattern = '[&<>\n]'
local htmlEncode_replace = {
  ['&'] = '&amp;', ['<'] = '&lt;', ['>'] = '&gt;', ['\n'] = '&para;<br>'
}

-- Public API Functions
-- (Exported at the end of the script)

local diff_main,
      diff_cleanupSemantic,
      diff_cleanupEfficiency

--[[
* The data structure representing a diff is an array of tuples:
* {{DIFF_DELETE, 'Hello'}, {DIFF_INSERT, 'Goodbye'}, {DIFF_EQUAL, ' world.'}}
* which means: delete 'Hello', add 'Goodbye' and keep ' world.'
--]]
local DIFF_DELETE = -1
local DIFF_INSERT = 1
local DIFF_EQUAL = 0

-- Number of seconds to map a diff before giving up (0 for infinity).
local Diff_Timeout = 1.0
-- Cost of an empty edit operation in terms of edit characters.
local Diff_EditCost = 4
-- At what point is no match declared (0.0 = perfection, 1.0 = very loose).
local Match_Threshold = 0.5
-- How far to search for a match (0 = exact location, 1000+ = broad match).
-- A match this many characters away from the expected location will add
-- 1.0 to the score (0.0 is a perfect match).
local Match_Distance = 1000
-- When deleting a large block of text (over ~64 characters), how close do
-- the contents have to be to match the expected contents. (0.0 = perfection,
-- 1.0 = very loose).  Note that Match_Threshold controls how closely the
-- end points of a delete need to match.
local Patch_DeleteThreshold = 0.5
-- Chunk size for context length.
local Patch_Margin = 4
-- The number of bits in an int.
local Match_MaxBits = 32

local function settings(new)
  if new then
    Diff_Timeout = new.Diff_Timeout or Diff_Timeout
    Diff_EditCost = new.Diff_EditCost or Diff_EditCost
    Match_Threshold = new.Match_Threshold or Match_Threshold
    Match_Distance = new.Match_Distance or Match_Distance
    Patch_DeleteThreshold = new.Patch_DeleteThreshold or Patch_DeleteThreshold
    Patch_Margin = new.Patch_Margin or Patch_Margin
    Match_MaxBits = new.Match_MaxBits or Match_MaxBits
  else
    return {
      Diff_Timeout = Diff_Timeout;
      Diff_EditCost = Diff_EditCost;
      Match_Threshold = Match_Threshold;
      Match_Distance = Match_Distance;
      Patch_DeleteThreshold = Patch_DeleteThreshold;
      Patch_Margin = Patch_Margin;
      Match_MaxBits = Match_MaxBits;
    }
  end
end

-- ---------------------------------------------------------------------------
--  DIFF API
-- ---------------------------------------------------------------------------

-- The private diff functions
local _diff_compute,
      _diff_bisect,
      _diff_halfMatchI,
      _diff_halfMatch,
      _diff_cleanupSemanticScore,
      _diff_cleanupSemanticLossless,
      _diff_cleanupMerge,
      _diff_commonPrefix,
      _diff_commonSuffix,
      _diff_commonOverlap,
      _diff_xIndex,
      _diff_bisectSplit

--[[
* Find the differences between two texts.  Simplifies the problem by stripping
* any common prefix or suffix off the texts before diffing.
* @param {string} text1 Old string to be diffed.
* @param {string} text2 New string to be diffed.
* @param {boolean} opt_checklines Has no effect in Lua.
* @param {number} opt_deadline Optional time when the diff should be complete
*     by.  Used internally for recursive calls.  Users should set DiffTimeout
*     instead.
* @return {Array.<Array.<number|string>>} Array of diff tuples.
--]]
function diff_main(text1, text2, opt_checklines, opt_deadline)
  -- Set a deadline by which time the diff must be complete.
  if opt_deadline == nil then
    if Diff_Timeout <= 0 then
      opt_deadline = 2 ^ 31
    else
      opt_deadline = clock() + Diff_Timeout
    end
  end
  local deadline = opt_deadline

  -- Check for null inputs.
  if text1 == nil or text1 == nil then
    error('Null inputs. (diff_main)')
  end

  -- Check for equality (speedup).
  if text1 == text2 then
    if #text1 > 0 then
      return {{DIFF_EQUAL, text1}}
    end
    return {}
  end

  -- LUANOTE: Due to the lack of Unicode support, Lua is incapable of
  -- implementing the line-mode speedup.
  local checklines = false

  -- Trim off common prefix (speedup).
  local commonlength = _diff_commonPrefix(text1, text2)
  local commonprefix
  if commonlength > 0 then
    commonprefix = strsub(text1, 1, commonlength)
    text1 = strsub(text1, commonlength + 1)
    text2 = strsub(text2, commonlength + 1)
  end

  -- Trim off common suffix (speedup).
  commonlength = _diff_commonSuffix(text1, text2)
  local commonsuffix
  if commonlength > 0 then
    commonsuffix = strsub(text1, -commonlength)
    text1 = strsub(text1, 1, -commonlength - 1)
    text2 = strsub(text2, 1, -commonlength - 1)
  end

  -- Compute the diff on the middle block.
  local diffs = _diff_compute(text1, text2, checklines, deadline)

  -- Restore the prefix and suffix.
  if commonprefix then
    tinsert(diffs, 1, {DIFF_EQUAL, commonprefix})
  end
  if commonsuffix then
    diffs[#diffs + 1] = {DIFF_EQUAL, commonsuffix}
  end

  _diff_cleanupMerge(diffs)
  return diffs
end

--[[
* Reduce the number of edits by eliminating semantically trivial equalities.
* @param {Array.<Array.<number|string>>} diffs Array of diff tuples.
--]]
function diff_cleanupSemantic(diffs)
  local changes = false
  local equalities = {}  -- Stack of indices where equalities are found.
  local equalitiesLength = 0  -- Keeping our own length var is faster.
  local lastEquality = nil
  -- Always equal to diffs[equalities[equalitiesLength]][2]
  local pointer = 1  -- Index of current position.
  -- Number of characters that changed prior to the equality.
  local length_insertions1 = 0
  local length_deletions1 = 0
  -- Number of characters that changed after the equality.
  local length_insertions2 = 0
  local length_deletions2 = 0

  while diffs[pointer] do
    if diffs[pointer][1] == DIFF_EQUAL then  -- Equality found.
      equalitiesLength = equalitiesLength + 1
      equalities[equalitiesLength] = pointer
      length_insertions1 = length_insertions2
      length_deletions1 = length_deletions2
      length_insertions2 = 0
      length_deletions2 = 0
      lastEquality = diffs[pointer][2]
    else  -- An insertion or deletion.
      if diffs[pointer][1] == DIFF_INSERT then
        length_insertions2 = length_insertions2 + #(diffs[pointer][2])
      else
        length_deletions2 = length_deletions2 + #(diffs[pointer][2])
      end
      -- Eliminate an equality that is smaller or equal to the edits on both
      -- sides of it.
      if lastEquality
          and (#lastEquality <= max(length_insertions1, length_deletions1))
          and (#lastEquality <= max(length_insertions2, length_deletions2)) then
        -- Duplicate record.
        tinsert(diffs, equalities[equalitiesLength],
         {DIFF_DELETE, lastEquality})
        -- Change second copy to insert.
        diffs[equalities[equalitiesLength] + 1][1] = DIFF_INSERT
        -- Throw away the equality we just deleted.
        equalitiesLength = equalitiesLength - 1
        -- Throw away the previous equality (it needs to be reevaluated).
        equalitiesLength = equalitiesLength - 1
        pointer = (equalitiesLength > 0) and equalities[equalitiesLength] or 0
        length_insertions1, length_deletions1 = 0, 0  -- Reset the counters.
        length_insertions2, length_deletions2 = 0, 0
        lastEquality = nil
        changes = true
      end
    end
    pointer = pointer + 1
  end

  -- Normalize the diff.
  if changes then
    _diff_cleanupMerge(diffs)
  end
  _diff_cleanupSemanticLossless(diffs)

  -- Find any overlaps between deletions and insertions.
  -- e.g: <del>abcxxx</del><ins>xxxdef</ins>
  --   -> <del>abc</del>xxx<ins>def</ins>
  -- e.g: <del>xxxabc</del><ins>defxxx</ins>
  --   -> <ins>def</ins>xxx<del>abc</del>
  -- Only extract an overlap if it is as big as the edit ahead or behind it.
  pointer = 2
  while diffs[pointer] do
    if (diffs[pointer - 1][1] == DIFF_DELETE and
        diffs[pointer][1] == DIFF_INSERT) then
      local deletion = diffs[pointer - 1][2]
      local insertion = diffs[pointer][2]
      local overlap_length1 = _diff_commonOverlap(deletion, insertion)
      local overlap_length2 = _diff_commonOverlap(insertion, deletion)
      if (overlap_length1 >= overlap_length2) then
        if (overlap_length1 >= #deletion / 2 or
            overlap_length1 >= #insertion / 2) then
          -- Overlap found.  Insert an equality and trim the surrounding edits.
          tinsert(diffs, pointer,
              {DIFF_EQUAL, strsub(insertion, 1, overlap_length1)})
          diffs[pointer - 1][2] =
              strsub(deletion, 1, #deletion - overlap_length1)
          diffs[pointer + 1][2] = strsub(insertion, overlap_length1 + 1)
          pointer = pointer + 1
        end
      else
        if (overlap_length2 >= #deletion / 2 or
            overlap_length2 >= #insertion / 2) then
          -- Reverse overlap found.
          -- Insert an equality and swap and trim the surrounding edits.
          tinsert(diffs, pointer,
              {DIFF_EQUAL, strsub(deletion, 1, overlap_length2)})
          diffs[pointer - 1] = {DIFF_INSERT,
              strsub(insertion, 1, #insertion - overlap_length2)}
          diffs[pointer + 1] = {DIFF_DELETE,
              strsub(deletion, overlap_length2 + 1)}
          pointer = pointer + 1
        end
      end
      pointer = pointer + 1
    end
    pointer = pointer + 1
  end
end

--[[
* Reduce the number of edits by eliminating operationally trivial equalities.
* @param {Array.<Array.<number|string>>} diffs Array of diff tuples.
--]]
function diff_cleanupEfficiency(diffs)
  local changes = false
  -- Stack of indices where equalities are found.
  local equalities = {}
  -- Keeping our own length var is faster.
  local equalitiesLength = 0
  -- Always equal to diffs[equalities[equalitiesLength]][2]
  local lastEquality = nil
  -- Index of current position.
  local pointer = 1

  -- The following four are really booleans but are stored as numbers because
  -- they are used at one point like this:
  --
  -- (pre_ins + pre_del + post_ins + post_del) == 3
  --
  -- ...i.e. checking that 3 of them are true and 1 of them is false.

  -- Is there an insertion operation before the last equality.
  local pre_ins = 0
  -- Is there a deletion operation before the last equality.
  local pre_del = 0
  -- Is there an insertion operation after the last equality.
  local post_ins = 0
  -- Is there a deletion operation after the last equality.
  local post_del = 0

  while diffs[pointer] do
    if diffs[pointer][1] == DIFF_EQUAL then  -- Equality found.
      local diffText = diffs[pointer][2]
      if (#diffText < Diff_EditCost) and (post_ins == 1 or post_del == 1) then
        -- Candidate found.
        equalitiesLength = equalitiesLength + 1
        equalities[equalitiesLength] = pointer
        pre_ins, pre_del = post_ins, post_del
        lastEquality = diffText
      else
        -- Not a candidate, and can never become one.
        equalitiesLength = 0
        lastEquality = nil
      end
      post_ins, post_del = 0, 0
    else  -- An insertion or deletion.
      if diffs[pointer][1] == DIFF_DELETE then
        post_del = 1
      else
        post_ins = 1
      end
      --[[
      * Five types to be split:
      * <ins>A</ins><del>B</del>XY<ins>C</ins><del>D</del>
      * <ins>A</ins>X<ins>C</ins><del>D</del>
      * <ins>A</ins><del>B</del>X<ins>C</ins>
      * <ins>A</del>X<ins>C</ins><del>D</del>
      * <ins>A</ins><del>B</del>X<del>C</del>
      --]]
      if lastEquality and (
          (pre_ins+pre_del+post_ins+post_del == 4)
          or
          (
            (#lastEquality < Diff_EditCost / 2)
            and
            (pre_ins+pre_del+post_ins+post_del == 3)
          )) then
        -- Duplicate record.
        tinsert(diffs, equalities[equalitiesLength],
            {DIFF_DELETE, lastEquality})
        -- Change second copy to insert.
        diffs[equalities[equalitiesLength] + 1][1] = DIFF_INSERT
        -- Throw away the equality we just deleted.
        equalitiesLength = equalitiesLength - 1
        lastEquality = nil
        if (pre_ins == 1) and (pre_del == 1) then
          -- No changes made which could affect previous entry, keep going.
          post_ins, post_del = 1, 1
          equalitiesLength = 0
        else
          -- Throw away the previous equality.
          equalitiesLength = equalitiesLength - 1
          pointer = (equalitiesLength > 0) and equalities[equalitiesLength] or 0
          post_ins, post_del = 0, 0
        end
        changes = true
      end
    end
    pointer = pointer + 1
  end

  if changes then
    _diff_cleanupMerge(diffs)
  end
end

-- ---------------------------------------------------------------------------
-- UNOFFICIAL/PRIVATE DIFF FUNCTIONS
-- ---------------------------------------------------------------------------

--[[
* Find the differences between two texts.  Assumes that the texts do not
* have any common prefix or suffix.
* @param {string} text1 Old string to be diffed.
* @param {string} text2 New string to be diffed.
* @param {boolean} checklines Has no effect in Lua.
* @param {number} deadline Time when the diff should be complete by.
* @return {Array.<Array.<number|string>>} Array of diff tuples.
* @private
--]]
function _diff_compute(text1, text2, checklines, deadline)
  if #text1 == 0 then
    -- Just add some text (speedup).
    return {{DIFF_INSERT, text2}}
  end

  if #text2 == 0 then
    -- Just delete some text (speedup).
    return {{DIFF_DELETE, text1}}
  end

  local diffs

  local longtext = (#text1 > #text2) and text1 or text2
  local shorttext = (#text1 > #text2) and text2 or text1
  local i = indexOf(longtext, shorttext)

  if i ~= nil then
    -- Shorter text is inside the longer text (speedup).
    diffs = {
      {DIFF_INSERT, strsub(longtext, 1, i - 1)},
      {DIFF_EQUAL, shorttext},
      {DIFF_INSERT, strsub(longtext, i + #shorttext)}
    }
    -- Swap insertions for deletions if diff is reversed.
    if #text1 > #text2 then
      diffs[1][1], diffs[3][1] = DIFF_DELETE, DIFF_DELETE
    end
    return diffs
  end

  if #shorttext == 1 then
    -- Single character string.
    -- After the previous speedup, the character can't be an equality.
    return {{DIFF_DELETE, text1}, {DIFF_INSERT, text2}}
  end

  -- Check to see if the problem can be split in two.
  do
    local
     text1_a, text1_b,
     text2_a, text2_b,
     mid_common        = _diff_halfMatch(text1, text2)

    if text1_a then
      -- A half-match was found, sort out the return data.
      -- Send both pairs off for separate processing.
      local diffs_a = diff_main(text1_a, text2_a, checklines, deadline)
      local diffs_b = diff_main(text1_b, text2_b, checklines, deadline)
      -- Merge the results.
      local diffs_a_len = #diffs_a
      diffs = diffs_a
      diffs[diffs_a_len + 1] = {DIFF_EQUAL, mid_common}
      for i, b_diff in ipairs(diffs_b) do
        diffs[diffs_a_len + 1 + i] = b_diff
      end
      return diffs
    end
  end

  return _diff_bisect(text1, text2, deadline)
end

--[[
* Find the 'middle snake' of a diff, split the problem in two
* and return the recursively constructed diff.
* See Myers 1986 paper: An O(ND) Difference Algorithm and Its Variations.
* @param {string} text1 Old string to be diffed.
* @param {string} text2 New string to be diffed.
* @param {number} deadline Time at which to bail if not yet complete.
* @return {Array.<Array.<number|string>>} Array of diff tuples.
* @private
--]]
function _diff_bisect(text1, text2, deadline)
  -- Cache the text lengths to prevent multiple calls.
  local text1_length = #text1
  local text2_length = #text2
  local _sub, _element
  local max_d = ceil((text1_length + text2_length) / 2)
  local v_offset = max_d
  local v_length = 2 * max_d
  local v1 = {}
  local v2 = {}
  -- Setting all elements to -1 is faster in Lua than mixing integers and nil.
  for x = 0, v_length - 1 do
    v1[x] = -1
    v2[x] = -1
  end
  v1[v_offset + 1] = 0
  v2[v_offset + 1] = 0
  local delta = text1_length - text2_length
  -- If the total number of characters is odd, then
  -- the front path will collide with the reverse path.
  local front = (delta % 2 ~= 0)
  -- Offsets for start and end of k loop.
  -- Prevents mapping of space beyond the grid.
  local k1start = 0
  local k1end = 0
  local k2start = 0
  local k2end = 0
  for d = 0, max_d - 1 do
    -- Bail out if deadline is reached.
    if clock() > deadline then
      break
    end

    -- Walk the front path one step.
    for k1 = -d + k1start, d - k1end, 2 do
      local k1_offset = v_offset + k1
      local x1
      if (k1 == -d) or ((k1 ~= d) and
          (v1[k1_offset - 1] < v1[k1_offset + 1])) then
        x1 = v1[k1_offset + 1]
      else
        x1 = v1[k1_offset - 1] + 1
      end
      local y1 = x1 - k1
      while (x1 <= text1_length) and (y1 <= text2_length)
          and (strsub(text1, x1, x1) == strsub(text2, y1, y1)) do
        x1 = x1 + 1
        y1 = y1 + 1
      end
      v1[k1_offset] = x1
      if x1 > text1_length + 1 then
        -- Ran off the right of the graph.
        k1end = k1end + 2
      elseif y1 > text2_length + 1 then
        -- Ran off the bottom of the graph.
        k1start = k1start + 2
      elseif front then
        local k2_offset = v_offset + delta - k1
        if k2_offset >= 0 and k2_offset < v_length and v2[k2_offset] ~= -1 then
          -- Mirror x2 onto top-left coordinate system.
          local x2 = text1_length - v2[k2_offset] + 1
          if x1 > x2 then
            -- Overlap detected.
            return _diff_bisectSplit(text1, text2, x1, y1, deadline)
          end
        end
      end
    end

    -- Walk the reverse path one step.
    for k2 = -d + k2start, d - k2end, 2 do
      local k2_offset = v_offset + k2
      local x2
      if (k2 == -d) or ((k2 ~= d) and
          (v2[k2_offset - 1] < v2[k2_offset + 1])) then
        x2 = v2[k2_offset + 1]
      else
        x2 = v2[k2_offset - 1] + 1
      end
      local y2 = x2 - k2
      while (x2 <= text1_length) and (y2 <= text2_length)
          and (strsub(text1, -x2, -x2) == strsub(text2, -y2, -y2)) do
        x2 = x2 + 1
        y2 = y2 + 1
      end
      v2[k2_offset] = x2
      if x2 > text1_length + 1 then
        -- Ran off the left of the graph.
        k2end = k2end + 2
      elseif y2 > text2_length + 1 then
        -- Ran off the top of the graph.
        k2start = k2start + 2
      elseif not front then
        local k1_offset = v_offset + delta - k2
        if k1_offset >= 0 and k1_offset < v_length and v1[k1_offset] ~= -1 then
          local x1 = v1[k1_offset]
          local y1 = v_offset + x1 - k1_offset
          -- Mirror x2 onto top-left coordinate system.
          x2 = text1_length - x2 + 1
          if x1 > x2 then
            -- Overlap detected.
            return _diff_bisectSplit(text1, text2, x1, y1, deadline)
          end
        end
      end
    end
  end
  -- Diff took too long and hit the deadline or
  -- number of diffs equals number of characters, no commonality at all.
  return {{DIFF_DELETE, text1}, {DIFF_INSERT, text2}}
end

--[[
 * Given the location of the 'middle snake', split the diff in two parts
 * and recurse.
 * @param {string} text1 Old string to be diffed.
 * @param {string} text2 New string to be diffed.
 * @param {number} x Index of split point in text1.
 * @param {number} y Index of split point in text2.
 * @param {number} deadline Time at which to bail if not yet complete.
 * @return {Array.<Array.<number|string>>} Array of diff tuples.
 * @private
--]]
function _diff_bisectSplit(text1, text2, x, y, deadline)
  local text1a = strsub(text1, 1, x - 1)
  local text2a = strsub(text2, 1, y - 1)
  local text1b = strsub(text1, x)
  local text2b = strsub(text2, y)

  -- Compute both diffs serially.
  local diffs = diff_main(text1a, text2a, false, deadline)
  local diffsb = diff_main(text1b, text2b, false, deadline)

  local diffs_len = #diffs
  for i, v in ipairs(diffsb) do
    diffs[diffs_len + i] = v
  end
  return diffs
end

--[[
* Determine the common prefix of two strings.
* @param {string} text1 First string.
* @param {string} text2 Second string.
* @return {number} The number of characters common to the start of each
*    string.
--]]
function _diff_commonPrefix(text1, text2)
  -- Quick check for common null cases.
  if (#text1 == 0) or (#text2 == 0) or (strbyte(text1, 1) ~= strbyte(text2, 1))
      then
    return 0
  end
  -- Binary search.
  -- Performance analysis: https://neil.fraser.name/news/2007/10/09/
  local pointermin = 1
  local pointermax = min(#text1, #text2)
  local pointermid = pointermax
  local pointerstart = 1
  while (pointermin < pointermid) do
    if (strsub(text1, pointerstart, pointermid)
        == strsub(text2, pointerstart, pointermid)) then
      pointermin = pointermid
      pointerstart = pointermin
    else
      pointermax = pointermid
    end
    pointermid = floor(pointermin + (pointermax - pointermin) / 2)
  end
  return pointermid
end

--[[
* Determine the common suffix of two strings.
* @param {string} text1 First string.
* @param {string} text2 Second string.
* @return {number} The number of characters common to the end of each string.
--]]
function _diff_commonSuffix(text1, text2)
  -- Quick check for common null cases.
  if (#text1 == 0) or (#text2 == 0)
      or (strbyte(text1, -1) ~= strbyte(text2, -1)) then
    return 0
  end
  -- Binary search.
  -- Performance analysis: https://neil.fraser.name/news/2007/10/09/
  local pointermin = 1
  local pointermax = min(#text1, #text2)
  local pointermid = pointermax
  local pointerend = 1
  while (pointermin < pointermid) do
    if (strsub(text1, -pointermid, -pointerend)
        == strsub(text2, -pointermid, -pointerend)) then
      pointermin = pointermid
      pointerend = pointermin
    else
      pointermax = pointermid
    end
    pointermid = floor(pointermin + (pointermax - pointermin) / 2)
  end
  return pointermid
end

--[[
* Determine if the suffix of one string is the prefix of another.
* @param {string} text1 First string.
* @param {string} text2 Second string.
* @return {number} The number of characters common to the end of the first
*     string and the start of the second string.
* @private
--]]
function _diff_commonOverlap(text1, text2)
  -- Cache the text lengths to prevent multiple calls.
  local text1_length = #text1
  local text2_length = #text2
  -- Eliminate the null case.
  if text1_length == 0 or text2_length == 0 then
    return 0
  end
  -- Truncate the longer string.
  if text1_length > text2_length then
    text1 = strsub(text1, text1_length - text2_length + 1)
  elseif text1_length < text2_length then
    text2 = strsub(text2, 1, text1_length)
  end
  local text_length = min(text1_length, text2_length)
  -- Quick check for the worst case.
  if text1 == text2 then
    return text_length
  end

  -- Start by looking for a single character match
  -- and increase length until no match is found.
  -- Performance analysis: https://neil.fraser.name/news/2010/11/04/
  local best = 0
  local length = 1
  while true do
    local pattern = strsub(text1, text_length - length + 1)
    local found = strfind(text2, pattern, 1, true)
    if found == nil then
      return best
    end
    length = length + found - 1
    if found == 1 or strsub(text1, text_length - length + 1) ==
                     strsub(text2, 1, length) then
      best = length
      length = length + 1
    end
  end
end

--[[
* Does a substring of shorttext exist within longtext such that the substring
* is at least half the length of longtext?
* This speedup can produce non-minimal diffs.
* Closure, but does not reference any external variables.
* @param {string} longtext Longer string.
* @param {string} shorttext Shorter string.
* @param {number} i Start index of quarter length substring within longtext.
* @return {?Array.<string>} Five element Array, containing the prefix of
*    longtext, the suffix of longtext, the prefix of shorttext, the suffix
*    of shorttext and the common middle.  Or nil if there was no match.
* @private
--]]
function _diff_halfMatchI(longtext, shorttext, i)
  -- Start with a 1/4 length substring at position i as a seed.
  local seed = strsub(longtext, i, i + floor(#longtext / 4))
  local j = 0  -- LUANOTE: do not change to 1, was originally -1
  local best_common = ''
  local best_longtext_a, best_longtext_b, best_shorttext_a, best_shorttext_b
  while true do
    j = indexOf(shorttext, seed, j + 1)
    if (j == nil) then
      break
    end
    local prefixLength = _diff_commonPrefix(strsub(longtext, i),
        strsub(shorttext, j))
    local suffixLength = _diff_commonSuffix(strsub(longtext, 1, i - 1),
        strsub(shorttext, 1, j - 1))
    if #best_common < suffixLength + prefixLength then
      best_common = strsub(shorttext, j - suffixLength, j - 1)
          .. strsub(shorttext, j, j + prefixLength - 1)
      best_longtext_a = strsub(longtext, 1, i - suffixLength - 1)
      best_longtext_b = strsub(longtext, i + prefixLength)
      best_shorttext_a = strsub(shorttext, 1, j - suffixLength - 1)
      best_shorttext_b = strsub(shorttext, j + prefixLength)
    end
  end
  if #best_common * 2 >= #longtext then
    return {best_longtext_a, best_longtext_b,
            best_shorttext_a, best_shorttext_b, best_common}
  else
    return nil
  end
end

--[[
* Do the two texts share a substring which is at least half the length of the
* longer text?
* @param {string} text1 First string.
* @param {string} text2 Second string.
* @return {?Array.<string>} Five element Array, containing the prefix of
*    text1, the suffix of text1, the prefix of text2, the suffix of
*    text2 and the common middle.  Or nil if there was no match.
* @private
--]]
function _diff_halfMatch(text1, text2)
  if Diff_Timeout <= 0 then
    -- Don't risk returning a non-optimal diff if we have unlimited time.
    return nil
  end
  local longtext = (#text1 > #text2) and text1 or text2
  local shorttext = (#text1 > #text2) and text2 or text1
  if (#longtext < 4) or (#shorttext * 2 < #longtext) then
    return nil  -- Pointless.
  end

  -- First check if the second quarter is the seed for a half-match.
  local hm1 = _diff_halfMatchI(longtext, shorttext, ceil(#longtext / 4))
  -- Check again based on the third quarter.
  local hm2 = _diff_halfMatchI(longtext, shorttext, ceil(#longtext / 2))
  local hm
  if not hm1 and not hm2 then
    return nil
  elseif not hm2 then
    hm = hm1
  elseif not hm1 then
    hm = hm2
  else
    -- Both matched.  Select the longest.
    hm = (#hm1[5] > #hm2[5]) and hm1 or hm2
  end

  -- A half-match was found, sort out the return data.
  local text1_a, text1_b, text2_a, text2_b
  if (#text1 > #text2) then
    text1_a, text1_b = hm[1], hm[2]
    text2_a, text2_b = hm[3], hm[4]
  else
    text2_a, text2_b = hm[1], hm[2]
    text1_a, text1_b = hm[3], hm[4]
  end
  local mid_common = hm[5]
  return text1_a, text1_b, text2_a, text2_b, mid_common
end

--[[
* Given two strings, compute a score representing whether the internal
* boundary falls on logical boundaries.
* Scores range from 6 (best) to 0 (worst).
* @param {string} one First string.
* @param {string} two Second string.
* @return {number} The score.
* @private
--]]
function _diff_cleanupSemanticScore(one, two)
  if (#one == 0) or (#two == 0) then
    -- Edges are the best.
    return 6
  end

  -- Each port of this function behaves slightly differently due to
  -- subtle differences in each language's definition of things like
  -- 'whitespace'.  Since this function's purpose is largely cosmetic,
  -- the choice has been made to use each language's native features
  -- rather than force total conformity.
  local char1 = strsub(one, -1)
  local char2 = strsub(two, 1, 1)
  local nonAlphaNumeric1 = strmatch(char1, '%W')
  local nonAlphaNumeric2 = strmatch(char2, '%W')
  local whitespace1 = nonAlphaNumeric1 and strmatch(char1, '%s')
  local whitespace2 = nonAlphaNumeric2 and strmatch(char2, '%s')
  local lineBreak1 = whitespace1 and strmatch(char1, '%c')
  local lineBreak2 = whitespace2 and strmatch(char2, '%c')
  local blankLine1 = lineBreak1 and strmatch(one, '\n\r?\n$')
  local blankLine2 = lineBreak2 and strmatch(two, '^\r?\n\r?\n')

  if blankLine1 or blankLine2 then
    -- Five points for blank lines.
    return 5
  elseif lineBreak1 or lineBreak2 then
    -- Four points for line breaks.
    return 4
  elseif nonAlphaNumeric1 and not whitespace1 and whitespace2 then
    -- Three points for end of sentences.
    return 3
  elseif whitespace1 or whitespace2 then
    -- Two points for whitespace.
    return 2
  elseif nonAlphaNumeric1 or nonAlphaNumeric2 then
    -- One point for non-alphanumeric.
    return 1
  end
  return 0
end

--[[
* Look for single edits surrounded on both sides by equalities
* which can be shifted sideways to align the edit to a word boundary.
* e.g: The c<ins>at c</ins>ame. -> The <ins>cat </ins>came.
* @param {Array.<Array.<number|string>>} diffs Array of diff tuples.
--]]
function _diff_cleanupSemanticLossless(diffs)
  local pointer = 2
  -- Intentionally ignore the first and last element (don't need checking).
  while diffs[pointer + 1] do
    local prevDiff, nextDiff = diffs[pointer - 1], diffs[pointer + 1]
    if (prevDiff[1] == DIFF_EQUAL) and (nextDiff[1] == DIFF_EQUAL) then
      -- This is a single edit surrounded by equalities.
      local diff = diffs[pointer]

      local equality1 = prevDiff[2]
      local edit = diff[2]
      local equality2 = nextDiff[2]

      -- First, shift the edit as far left as possible.
      local commonOffset = _diff_commonSuffix(equality1, edit)
      if commonOffset > 0 then
        local commonString = strsub(edit, -commonOffset)
        equality1 = strsub(equality1, 1, -commonOffset - 1)
        edit = commonString .. strsub(edit, 1, -commonOffset - 1)
        equality2 = commonString .. equality2
      end

      -- Second, step character by character right, looking for the best fit.
      local bestEquality1 = equality1
      local bestEdit = edit
      local bestEquality2 = equality2
      local bestScore = _diff_cleanupSemanticScore(equality1, edit)
          + _diff_cleanupSemanticScore(edit, equality2)

      while strbyte(edit, 1) == strbyte(equality2, 1) do
        equality1 = equality1 .. strsub(edit, 1, 1)
        edit = strsub(edit, 2) .. strsub(equality2, 1, 1)
        equality2 = strsub(equality2, 2)
        local score = _diff_cleanupSemanticScore(equality1, edit)
            + _diff_cleanupSemanticScore(edit, equality2)
        -- The >= encourages trailing rather than leading whitespace on edits.
        if score >= bestScore then
          bestScore = score
          bestEquality1 = equality1
          bestEdit = edit
          bestEquality2 = equality2
        end
      end
      if prevDiff[2] ~= bestEquality1 then
        -- We have an improvement, save it back to the diff.
        if #bestEquality1 > 0 then
          diffs[pointer - 1][2] = bestEquality1
        else
          tremove(diffs, pointer - 1)
          pointer = pointer - 1
        end
        diffs[pointer][2] = bestEdit
        if #bestEquality2 > 0 then
          diffs[pointer + 1][2] = bestEquality2
        else
          tremove(diffs, pointer + 1, 1)
          pointer = pointer - 1
        end
      end
    end
    pointer = pointer + 1
  end
end

--[[
* Reorder and merge like edit sections.  Merge equalities.
* Any edit section can move as long as it doesn't cross an equality.
* @param {Array.<Array.<number|string>>} diffs Array of diff tuples.
--]]
function _diff_cleanupMerge(diffs)
  diffs[#diffs + 1] = {DIFF_EQUAL, ''}  -- Add a dummy entry at the end.
  local pointer = 1
  local count_delete, count_insert = 0, 0
  local text_delete, text_insert = '', ''
  local commonlength
  while diffs[pointer] do
    local diff_type = diffs[pointer][1]
    if diff_type == DIFF_INSERT then
      count_insert = count_insert + 1
      text_insert = text_insert .. diffs[pointer][2]
      pointer = pointer + 1
    elseif diff_type == DIFF_DELETE then
      count_delete = count_delete + 1
      text_delete = text_delete .. diffs[pointer][2]
      pointer = pointer + 1
    elseif diff_type == DIFF_EQUAL then
      -- Upon reaching an equality, check for prior redundancies.
      if count_delete + count_insert > 1 then
        if (count_delete > 0) and (count_insert > 0) then
          -- Factor out any common prefixies.
          commonlength = _diff_commonPrefix(text_insert, text_delete)
          if commonlength > 0 then
            local back_pointer = pointer - count_delete - count_insert
            if (back_pointer > 1) and (diffs[back_pointer - 1][1] == DIFF_EQUAL)
                then
              diffs[back_pointer - 1][2] = diffs[back_pointer - 1][2]
                  .. strsub(text_insert, 1, commonlength)
            else
              tinsert(diffs, 1,
                  {DIFF_EQUAL, strsub(text_insert, 1, commonlength)})
              pointer = pointer + 1
            end
            text_insert = strsub(text_insert, commonlength + 1)
            text_delete = strsub(text_delete, commonlength + 1)
          end
          -- Factor out any common suffixies.
          commonlength = _diff_commonSuffix(text_insert, text_delete)
          if commonlength ~= 0 then
            diffs[pointer][2] =
                strsub(text_insert, -commonlength) .. diffs[pointer][2]
            text_insert = strsub(text_insert, 1, -commonlength - 1)
            text_delete = strsub(text_delete, 1, -commonlength - 1)
          end
        end
        -- Delete the offending records and add the merged ones.
        pointer = pointer - count_delete - count_insert
        for i = 1, count_delete + count_insert do
          tremove(diffs, pointer)
        end
        if #text_delete > 0 then
          tinsert(diffs, pointer, {DIFF_DELETE, text_delete})
          pointer = pointer + 1
        end
        if #text_insert > 0 then
          tinsert(diffs, pointer, {DIFF_INSERT, text_insert})
          pointer = pointer + 1
        end
        pointer = pointer + 1
      elseif (pointer > 1) and (diffs[pointer - 1][1] == DIFF_EQUAL) then
        -- Merge this equality with the previous one.
        diffs[pointer - 1][2] = diffs[pointer - 1][2] .. diffs[pointer][2]
        tremove(diffs, pointer)
      else
        pointer = pointer + 1
      end
      count_insert, count_delete = 0, 0
      text_delete, text_insert = '', ''
    end
  end
  if diffs[#diffs][2] == '' then
    diffs[#diffs] = nil  -- Remove the dummy entry at the end.
  end

  -- Second pass: look for single edits surrounded on both sides by equalities
  -- which can be shifted sideways to eliminate an equality.
  -- e.g: A<ins>BA</ins>C -> <ins>AB</ins>AC
  local changes = false
  pointer = 2
  -- Intentionally ignore the first and last element (don't need checking).
  while pointer < #diffs do
    local prevDiff, nextDiff = diffs[pointer - 1], diffs[pointer + 1]
    if (prevDiff[1] == DIFF_EQUAL) and (nextDiff[1] == DIFF_EQUAL) then
      -- This is a single edit surrounded by equalities.
      local diff = diffs[pointer]
      local currentText = diff[2]
      local prevText = prevDiff[2]
      local nextText = nextDiff[2]
      if #prevText == 0 then
        tremove(diffs, pointer - 1)
        changes = true
      elseif strsub(currentText, -#prevText) == prevText then
        -- Shift the edit over the previous equality.
        diff[2] = prevText .. strsub(currentText, 1, -#prevText - 1)
        nextDiff[2] = prevText .. nextDiff[2]
        tremove(diffs, pointer - 1)
        changes = true
      elseif strsub(currentText, 1, #nextText) == nextText then
        -- Shift the edit over the next equality.
        prevDiff[2] = prevText .. nextText
        diff[2] = strsub(currentText, #nextText + 1) .. nextText
        tremove(diffs, pointer + 1)
        changes = true
      end
    end
    pointer = pointer + 1
  end
  -- If shifts were made, the diff needs reordering and another shift sweep.
  if changes then
    -- LUANOTE: no return value, but necessary to use 'return' to get
    -- tail calls.
    return _diff_cleanupMerge(diffs)
  end
end

--[[
* loc is a location in text1, compute and return the equivalent location in
* text2.
* e.g. 'The cat' vs 'The big cat', 1->1, 5->8
* @param {Array.<Array.<number|string>>} diffs Array of diff tuples.
* @param {number} loc Location within text1.
* @return {number} Location within text2.
--]]
function _diff_xIndex(diffs, loc)
  local chars1 = 1
  local chars2 = 1
  local last_chars1 = 1
  local last_chars2 = 1
  local x
  for _x, diff in ipairs(diffs) do
    x = _x
    if diff[1] ~= DIFF_INSERT then   -- Equality or deletion.
      chars1 = chars1 + #diff[2]
    end
    if diff[1] ~= DIFF_DELETE then   -- Equality or insertion.
      chars2 = chars2 + #diff[2]
    end
    if chars1 > loc then   -- Overshot the location.
      break
    end
    last_chars1 = chars1
    last_chars2 = chars2
  end
  -- Was the location deleted?
  if diffs[x + 1] and (diffs[x][1] == DIFF_DELETE) then
    return last_chars2
  end
  -- Add the remaining character length.
  return last_chars2 + (loc - last_chars1)
end

-- Expose the API
local Diff = {}

Diff.DIFF_DELETE = DIFF_DELETE
Diff.DIFF_INSERT = DIFF_INSERT
Diff.DIFF_EQUAL = DIFF_EQUAL

Diff.diff = diff_main
Diff.cleanup_semantic = diff_cleanupSemantic
Diff.cleanup_efficiency = diff_cleanupEfficiency

return Diff
