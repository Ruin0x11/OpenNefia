local I18N = require("api.I18N")

local q = I18N.quote

local jp = {
   ["base.calm"] = {
      "「誰だ？誰かが私を見ている」",
      "「悔しいけど…」"
   },
   ["base.aggro"] = {
      "「こいつ、動くよ」",
      "「戦いが終わったらぐっすり眠れるっていう保証がある？」",
      "「見える。動きが見える！」",
   },
   ["base.dead"] = {
      "「では、この私たちの出会いはなんなんだ！」",
      "「これが、た、戦い。」"
   },
   ["base.killed"] = {
      "「と、取り返しのつかない事を…取り返しのつかない事をしてしまった…」",
      "「自信があってやる訳じゃないのに」"
   },
   ["base.welcome"] = {
      "「間違いない。やつだ、やつが来たんだ」"
   },
   ["base.dialog"] = {
      "なんだい？",
      "（ちっ)"
   }
}

local en = {
   ["base.calm"] = {
      q("Weee."),
      q("Brother!")
   },
   ["base.aggro"] = {
      q("Scum!")
   },
   ["base.dead"] = {
      q("I'm dead.")
   },
   ["base.killed"] = {
      q("I killed it.")
   },
   ["base.welcome"] = {
      q("Welcome back.")
   },
   ["base.dialog"] = {
      "Hi.",
      "What's up?",
      "Dude..."
   }
}

data:add {
   _type = "base.tone",
   _id = "example",

   texts = {
      jp = jp,
      en = en
   }
}
