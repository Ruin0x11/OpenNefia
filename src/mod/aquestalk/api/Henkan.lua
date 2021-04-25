local Henkan = {}

local hiragana_to_katakana = {
   ["あ"] = "ア",
   ["い"] = "イ",
   ["う"] = "ウ",
   ["え"] = "エ",
   ["お"] = "オ",

   ["か"] = "カ",
   ["き"] = "キ",
   ["く"] = "ク",
   ["け"] = "ケ",
   ["こ"] = "コ",

   ["さ"] = "サ",
   ["し"] = "シ",
   ["す"] = "ス",
   ["せ"] = "セ",
   ["そ"] = "ソ",

   ["た"] = "タ",
   ["ち"] = "チ",
   ["つ"] = "ツ",
   ["て"] = "テ",
   ["と"] = "ト",

   ["な"] = "ナ",
   ["に"] = "ニ",
   ["ぬ"] = "ヌ",
   ["ね"] = "ネ",
   ["の"] = "ノ",

   ["は"] = "ハ",
   ["ひ"] = "ヒ",
   ["ふ"] = "フ",
   ["へ"] = "ヘ",
   ["ほ"] = "ホ",

   ["ま"] = "マ",
   ["み"] = "ミ",
   ["む"] = "ム",
   ["め"] = "メ",
   ["も"] = "モ",

   ["や"] = "ヤ",
   ["ゆ"] = "ユ",
   ["よ"] = "ヨ",

   ["ら"] = "ラ",
   ["り"] = "リ",
   ["る"] = "ル",
   ["れ"] = "レ",
   ["ろ"] = "ロ",

   ["わ"] = "ワ",
   ["を"] = "ヲ",

   ["ん"] = "ン",

   ["が"] = "ガ",
   ["ぎ"] = "ギ",
   ["ぐ"] = "グ",
   ["げ"] = "ゲ",
   ["ご"] = "ゴ",

   ["ざ"] = "ザ",
   ["じ"] = "ジ",
   ["ず"] = "ズ",
   ["ぜ"] = "ゼ",
   ["ぞ"] = "ゾ",

   ["だ"] = "ダ",
   ["ぢ"] = "ヂ",
   ["づ"] = "ヅ",
   ["で"] = "デ",
   ["ど"] = "ド",

   ["ば"] = "バ",
   ["び"] = "ビ",
   ["ぶ"] = "ブ",
   ["べ"] = "ベ",
   ["ぼ"] = "ボ",

   ["ぱ"] = "パ",
   ["ぴ"] = "ピ",
   ["ぷ"] = "プ",
   ["ぺ"] = "ペ",
   ["ぽ"] = "ポ",

   ["っ"] = "ッ",

   ["ゃ"] = "ャ",
   ["ゅ"] = "ュ",
   ["ょ"] = "ョ",

   ["ー"] = "ー",
}

local katakana_to_hiragana = {}
for k, v in pairs(hiragana_to_katakana) do
   katakana_to_hiragana[v] = k
end

-- HACK for aquestalk
katakana_to_hiragana["ァ"] = "あ"
katakana_to_hiragana["ィ"] = "い"
katakana_to_hiragana["ゥ"] = "う"
katakana_to_hiragana["ェ"] = "え"
katakana_to_hiragana["ォ"] = "お"

katakana_to_hiragana["ぁ"] = "あ"
katakana_to_hiragana["ぃ"] = "い"
katakana_to_hiragana["ぅ"] = "う"
katakana_to_hiragana["ぇ"] = "え"
katakana_to_hiragana["ぉ"] = "お"

function Henkan.katakana_to_hiragana(katakana)
   local s = {}

   for _, c in utf8.codes(katakana) do
      local ch = utf8.char(c)
      local hiragana
      if ch == "ヴ" then
         hiragana = "ぶい"
      else
         hiragana = katakana_to_hiragana[ch]
      end
      if not hiragana and not hiragana_to_katakana[ch] then
         return false, "Text was not completely katakana"
      end
      s[#s+1] = hiragana
   end

   return true, table.concat(s)
end

return Henkan
