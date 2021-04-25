local Gui = require("api.Gui")
local Mecab = require("mod.aquestalk.api.Mecab")
local Henkan = require("mod.aquestalk.api.Henkan")
local Log = require("api.Log")
local IAquesTalkConfig = require("mod.aquestalk.api.aspect.IAquesTalkConfig")

local AquesTalk = {}

local aquestalk = nil

function AquesTalk.set_usr_key(key)
   if aquestalk == nil then
      local ok, lib = pcall(require, "lua_aquestalk")
      if not ok then return false, lib end
      aquestalk = lib
   end

   return aquestalk.set_usr_key(key)
end

function AquesTalk.set_dev_key(key)
   if aquestalk == nil then
      local ok, lib = pcall(require, "lua_aquestalk")
      if not ok then return false, lib end
      aquestalk = lib
   end

   return aquestalk.set_dev_key(key)
end

local ALLOWED_SYMBOLS = table.set {
   "？",
   "、",
}

local PAUSES = table.set {
   "「",
   "」"
}

local LONG_PAUSES = table.set {
   "。",
   "…",
}

local ACCENTS = table.set {
   "！",
}

function AquesTalk.speak(text, x, y, volume, channel, bas, spd, vol, pit, acc, lmd, fsc)
   local ok, words = Mecab.parse(text)
   if not ok then
      return false, words
   end

   local s = {}

   for _, word in ipairs(words) do
      local reading = word.extra.reading
      if reading == "" then
         reading = word.word
      end
      if reading then
         if ALLOWED_SYMBOLS[reading] then
            s[#s+1] = word.extra.reading
         elseif PAUSES[reading] then
            s[#s+1] = "、"
         elseif LONG_PAUSES[reading] then
            s[#s+1] = "、、"
         elseif ACCENTS[reading] then
            s[#s+1] = "ー、"
         else
            local ok, hiragana = Henkan.katakana_to_hiragana(reading)
            if ok then
               s[#s+1] = hiragana
            end
         end
      end
   end

   local hiragana = table.concat(s)
   return AquesTalk.speak_hiragana(hiragana, x, y, volume, channel, bas, spd, vol, pit, acc, lmd, fsc)
end

local CONFIG_TO_BASE = {
   f1e = "F1E",
   f2e = "F2E",
   m1e = "M1E"
}

local ERROR_MESSAGES = {
   [100] = "その他のエラー",
   [101] = "メモリ不足",
   [103] = "音声記号列指定エラー(語頭の長音、促音の連続など)",
   [104] = "音声記号列に有効な読みがない",
   [105] = "音声記号列に未定義の読み記号が指定された",
   [106] = "音声記号列のタグの指定が正しくない",
   [107] = "タグの長さが制限を越えている（または[>]がみつからない）",
   [108] = "タグ内の値の指定が正しくない",
   [120] = "音声記号列が長すぎる",
   [121] = "１つのフレーズ中の読み記号が多すぎる",
   [122] = "音声記号列が長い（内部バッファオーバー1）"
}

function AquesTalk.speak_hiragana(hiragana, x, y, volume, channel, bas, spd, vol, pit, acc, lmd, fsc)
   if aquestalk == nil then
      local ok, lib = pcall(require, "lua_aquestalk")
      if not ok then return false, lib end
      aquestalk = lib
   end

   local VoiceBase = aquestalk.VoiceBase

   bas = VoiceBase[CONFIG_TO_BASE[bas or "f1e"] or "F1E"]

   bas = math.clamp(bas, VoiceBase.F1E, VoiceBase.M1E)
   spd = math.clamp(spd or config.aquestalk.default_spd, 50, 300)
   vol = math.clamp(vol or config.aquestalk.default_vol, 0, 300)
   pit = math.clamp(pit or config.aquestalk.default_pit, 20, 200)
   acc = math.clamp(acc or config.aquestalk.default_acc, 20, 200)
   lmd = math.clamp(lmd or config.aquestalk.default_lmd, 0, 200)
   fsc = math.clamp(fsc or config.aquestalk.default_fsc, 50, 200)

   local wav, err = aquestalk.synth(hiragana, bas, spd, vol, pit, acc, lmd, fsc)

   if err then
      local err_mes = ERROR_MESSAGES[err] or tostring(err)
      Log.error("AquesTalk error: %s (%s)", err_mes, utf8.wide_sub(hiragana, 1, 16))
      return false, err
   end

   local sound = {
      type = "wave",
      data = wav,
      filename = "aquestalk.wav"
   }

   Gui.play_sound(sound, x, y, volume, channel)

   return true, nil
end

function AquesTalk.calc_chara_params(chara)
   local aspect = chara:get_aspect_or_default(IAquesTalkConfig)

   local bas = aspect:calc(chara, "bas")
   local spd = aspect:calc(chara, "spd")
   local vol = aspect:calc(chara, "vol")
   local pit = aspect:calc(chara, "pit")
   local acc = aspect:calc(chara, "acc")
   local lmd = aspect:calc(chara, "lmd")
   local fsc = aspect:calc(chara, "fsc")

   return bas, spd, vol, pit, acc, lmd, fsc
end

return AquesTalk
