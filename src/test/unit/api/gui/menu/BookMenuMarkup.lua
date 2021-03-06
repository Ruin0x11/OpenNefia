local BookMenuMarkup = require("api.gui.menu.BookMenuMarkup")
local Assert = require("api.test.Assert")

function test_BookMenuMarkup_parse__carets()
   local lines = BookMenuMarkup.parse("Your memories forever<damaged>")

   local expected = {
      [1] = { color = { 0, 0, 0 }, font = { size = 12 }, line = "Your memories forever<damaged>" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__markup_size()
   local lines = BookMenuMarkup.parse [[
<size=14>Dood
Dood
]]

   local expected = {
      [1] = { color = {0, 0, 0}, font = { size = 14 }, line = "Dood" },
      [2] = { color = {0, 0, 0}, font = { size = 12 }, line = "Dood" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__markup_style()
   local lines = BookMenuMarkup.parse [[
<style=bold>Dood
Dood
]]

   local expected = {
      [1] = { color = {0, 0, 0}, font = { size = 12, style = "bold" }, line = "Dood" },
      [2] = { color = {0, 0, 0}, font = { size = 12 }, line = "Dood" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__markup_color()
   local lines = BookMenuMarkup.parse [[
<color=#2288CC>Dood
Dood
]]

   local expected = {
      [1] = { color = {34, 136, 204}, font = { size = 12 }, line = "Dood" },
      [2] = { color = {0, 0, 0}, font = { size = 12 }, line = "Dood" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__markup_combined()
   local lines = BookMenuMarkup.parse [[
<color=#2288CC><color=#CC8822><style=bold><size=14>Dood
Dood
]]

   local expected = {
      [1] = { color = {204, 136, 34}, font = { size = 14, style = "bold" }, line = "Dood" },
      [2] = { color = {0, 0, 0}, font = { size = 12 }, line = "Dood" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__elona_compat()
   local lines = BookMenuMarkup.parse([[
My book title.
Dood.
]], true)

   local expected = {
      [1] = { color = {0, 0, 0}, font = { size = 12, style = "bold" }, line = "My book title." },
      [2] = { color = {0, 0, 0}, font = { size = 10 }, line = "Dood." }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__escaped_markup()
   local lines = BookMenuMarkup.parse[[
<<
<<style=bold>
<style=bold><<color=#2288CC>
]]

   local expected = {
      [1] = { color = { 0, 0, 0 }, font = { size = 12 }, line = "<" },
      [2] = { color = { 0, 0, 0 }, font = { size = 12 }, line = "<style=bold>" },
      [3] = { color = { 0, 0, 0 }, font = { size = 12, style = "bold" }, line = "<color=#2288CC>" }
   }

   Assert.same(expected, lines)
end

function test_BookMenuMarkup_parse__invalid_markup()
   Assert.throws_error(BookMenuMarkup.parse, "Could not find closing '>' in markup", "<")
   Assert.throws_error(BookMenuMarkup.parse, "Could not find closing '>' in markup", "<size 12")
   Assert.throws_error(BookMenuMarkup.parse, "unknown key '' %(%)", "<>")
   Assert.throws_error(BookMenuMarkup.parse, "unknown key 'size 12'", "<size 12>Dood")
   Assert.throws_error(BookMenuMarkup.parse, "unknown key 'dood' %(dood%)", "<dood>Dood")
   Assert.throws_error(BookMenuMarkup.parse, "invalid value for key 'size' %(nil%)", "<size>Dood")
   Assert.throws_error(BookMenuMarkup.parse, "invalid value for key 'color' %(#ZZZZZZ%)", "<color=#ZZZZZZ>Dood")
   Assert.throws_error(BookMenuMarkup.parse, "invalid value for key 'color' %(#AAZZZZ%)", "<color=#AAZZZZ>Dood")
end
