local Rand = require("api.Rand")
local Owo = {}

local KAWAII_FACES = {
	"(o´ω｀o)",
	"(´･ω･`);",
	"｡◕‿◕｡",
	"(✿◠‿◠)",
	"(≧◡≦)",
	"(´ω｀)",
	"＼(*^▽^*)/",
	"(•⊙ω⊙•)",
	"(¤﹏¤)",
	"(✖﹏✖)",
	"o(╥﹏╥)o",
	"(◕﹏◕✿)",
	"(>.<)",
	"≧∇≦",
	"(≖︿≖✿)",
	"(╯3╰)",
	"(n˘v˘•)¬",
}

local REPLACEMENTS = {
    { "%f[%a]the%f[%A]", {"twa", "tba", "da"} },
    { "%f[%a]yes%f[%A]", {"mmhmb"} },
    { "%f[%a]you%f[%A]", {"uwu", "uwu", "uwu", "u"} },
    { "%f[%a]your%f[%A]", {"uwus", "uwus", "uwus", "ur"} },
    { "%f[%a]and%f[%A]", {"awnd", "awd"} },
    { "%f[%a]of%f[%A]", {"ob", "obf", "owf", "owbf"} },
    { "%f[%a]but%f[%A]", {"bwt", "bwut"} },
    { "%f[%a]in%f[%A]", {"ibn", "ib", "iwn", "iwn", "iwn", "iwbn"} },
    { "%f[%a]as%f[%A]", {"az", "abs", "aws"} },
    { "%f[%a]to%f[%A]", {"two", "twu", "twu", "tu", "tbu"} },

    { "on%f[%A]", {"ob", "own", "own", "own", "own", "owbn"} },
    { "ws", {"wbs", "ws", "ws"} },
    { "ell", {"eww"} },
    { "ll", {"l", "bl"} },
    { "off", {"awf", "owf", "owf", "owff"} },
    { "ng[s?]%f[%A]", {"nb%1", "nb%1", "nb%1", "inb%1"} },
    { "%f[%a]c%w[^h]", {"cw"} },
    { "(%w)f(%w)", {"%1b%2"} },
    { "[%w]v", {"%1bv"} },
    { "%f[%a]v", {"b"} },
    { "%f[%a]my", {"mwie"} },
    { "ight", {"ibte"} },
    { "igh", {"i"} },
    { "lt", {"wld", "wld", "wld", "wlbd"} },
    { "ine", {"iwne"} },
    { "lf", {"lbf"} },
    { "(e[ae])(d)", {"%1bd"} },
    { "e[ae]", {"ee", "ii", "ie"} },
    { "%f[%a]h([aeiouy])", {"hw%1"} },
    { "uce", {"ubs"} },
    { "(%w)one%f[%A]", {"%1own"} },
    { "([pbcst])l", {"%1w"} },
    { "od", {"owd"} },
    { "%f[%a]l|r", {"w"} },
    { "wh", {"w", "wb"} },
    { "ch", {"cw"} },
    -- { ([aeiou]|\b)l([aeiouy]), ["%1l%2"] },
    { "sh(%w)", {"sw%1"} },
    { "(%w)sh", {"%1bsh"} },
    { "(%w)o", {"%1owo", "%1o", "%1o", "%1o"} },
    { "ng(%w)", {"ngb%1"} },
    { "(%w)me%f[%A]", {"%1mbe"} },
    { "qu", {"kw"} },
    { "([uo])t", {"%1bt"} },
    { "isc", {"ibsk"} },
    { "ck", {"k"} },
    { "us", {"uws"} },
    { "([aeiouy])st", {"%1wst"} },
    { "tt", {"t", "t", "t", "d"} },
    { "%f[%a]th", {"d"} },
    { "th", {"tw", "dt"} },
    { "(%w)tio(%w)", {"%1two%2"} },
    { "(%w)m([aeiou])", {"%1mb%2"} },
    { "no", {"noo"} },
    { "rs", {"s"} },
    { "ant", {"abnt"} },
    { "any", {"awny"} },
    { "!$", {" !", "!", " !!", "! !", "!", "!!!!", " !! !"}, true },
    { "! ", {" ! ", "! ", " !! ", "! ! ", "! ", "!!!! ", " !! ! "}, true },
    { "%?$", {"??", "???", " ?? ?", "??? ?!", " ?!", "!?", " ??!!", "!?? !", "!??", "!???!?!!??", " !!? !?"}, true },
    { "%? ", {"?? ", "??? ", " ?? ? ", "??? ?! ", " ?! ", "!? ", " ??!! ", "!?? ! ", "!?? ", "!???!?!!?? ", " !!? !? "}, true },
    { ",", {",,", ",", "...,,"} },
    { "(%w)%.%f[%A]", {"%1, ", "%1,, ", "%1... ", "%1. ", "%1. . ", "%1,. ", "%1! ", "%1! ! "}, true },
	{ "%.%.%.%f[%A]", {",,.. ", "... ", "...... ", ". .... ", ",...... "} },
}

function Owo.owoify(text)
   for _, entry in ipairs(REPLACEMENTS) do
      local pattern = entry[1]
      local replacements = entry[2]
      local include_face = entry[3]

      local replacement = Rand.choice(replacements)

      if include_face and Rand.percent_chance(60) then
         text = text:gsub(pattern, replacement .. Rand.choice(KAWAII_FACES))
      else
         text = text:gsub(pattern, replacement)
      end
   end

   return text
end

return Owo
