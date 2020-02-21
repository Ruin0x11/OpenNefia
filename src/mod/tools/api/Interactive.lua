local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")

local Interactive = {}

function Interactive.call_interactively()
   local cands = data["tools.interactive_fns"]:iter():to_list()

   cands = {
      '',
      'a',
      'ab',
      'abC',
      'abcd',
      'alphabetacappa',
      'AlphaBetaCappa',
      'thisisatestdir',
      '/////ThisIsATestDir',
      '/this/is/a/test/dir',
      '/test/tiatd',
      '/zzz/path2/path3/path4',
      '/path1/zzz/path3/path4',
      '/path1/path2/zzz/path4',
      '/path1/path2/path3/zzz',
   }

   local opts = {
      max_gap = 5,
      ignore_spaces = true
   }
   local func, canceled = FuzzyFinderPrompt:new(cands, "", opts):query()

   if canceled then
      return
   end
end

return Interactive
