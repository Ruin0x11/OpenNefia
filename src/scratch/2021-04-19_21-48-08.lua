-- 	例：%txtHour,JP,gdata13eqv15,gdata185ntv0
-- 		3時のティータイム♪
-- 	この場合、「神の電波をキャッチするエンチャントがある」かつ「15時」の場合にのみ発される
-- その他、MMA/TT用のカスタムゴッド用拡張命令文

-- [MMA][TT]カスタムテキストのタグには変数を指定し、特定の条件でのみ発話する、という事が可能
-- %txtCalm,JP,gdata17eqv0
-- 	この場合、gdata17（天気）の条件が 0（晴れ）と eqv（同等）の場合のみ%txtCalm,JP の条件で発話する

-- ◆CNPC のメッセージ内で使える変数に応じた変換表示方法の追加
-- %txt[MMA]Dialog,JP,kill176euv1000
-- 	お{兄}ちゃんってほんとにひどいよね♪{n}いままでに{kill176}人もの妹を殺してるんだから♪

local Chara = require("api.Chara")
local I18N = require("api.I18N")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Weather = require("mod.elona.api.Weather")

data:add {
   _type = "base.talk_event",
   _id = "hour",
   elona_txt_id = "txtHour",
}

data:add {
   _type = "base.talk_event",
   _id = "calm",
   elona_txt_id = "txtCalm",
}

local chara = Chara.player()

Talk.say(chara, "elona.hour", { hour = save.base.date.hour })

local env = I18N.get_env("jp")

local jp = {
   texts = {
      ["elona.hour"] = {
         {
            pred = function()
               return Chara.player():calc("can_catch_god_signals")
                  and save.base.date.hour == 15
            end,

            text = "3時のティータイム♪"
         }
      },
      ["elona.calm"] = {
         {
            pred = function()
               return Weather.is("elona.sunny")
            end,

            weight = 1000,

            text = {
               "It's summer time and all is fine." ,
               "Just go with me, it seems the thing to do.",
               "We'll go to the ocean and walk right in." ,
               "Splash around and go for a swim.",
            }
         },
      },
      ["elona.dialog"] = {
         {
            pred = function()
               return NpcMemory.killed("elona.younger_sister") >= 1000
            end,

            text = function(_1)
               local killed = NpcMemory.killed("elona.younger_sister")

               return("お%sちゃんってほんとにひどいよね♪\nいままでに%d人もの妹を殺してるんだから♪")
                  :format(env.ext["elona.nii"](_1), killed)
            end
         }
      }
   }
}
