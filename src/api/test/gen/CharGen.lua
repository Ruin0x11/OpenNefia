-- from https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/generators/char.lua

local IGenerator = require("api.test.gen.IGenerator")
local IntGen = require("api.test.gen.IntGen")

local LOWEST_ASCII_VALUE = 32    -- 'space'
local HIGHEST_ASCII_VALUE = 126  -- '~'
local space = string.char(LOWEST_ASCII_VALUE)

local CharGen = class.class("CharGen", IGenerator)

-- Generates a random character (ASCII value between 'space' and '~'
-- @return randomly chosen char (string of length 1)
function CharGen:pick()
  return string.char(self.int_gen:pick())
end


--- Shrinks down a previously generated char to a simpler value. Shrinks
--  towards the 'space' ASCII character.
-- @param prev previously generated char value
-- @return shrunk down char value
function CharGen:shrink(prev)
  if string.byte(prev) <= LOWEST_ASCII_VALUE then
    return {}
  end
  return { string.char(string.byte(prev) - 1) }
end


--- Creates a generator for ASCII-chars
-- @return generator that can randomly create ASCII values
function CharGen:init()
   self.int_gen = IntGen:new(LOWEST_ASCII_VALUE, HIGHEST_ASCII_VALUE)
end

return CharGen
