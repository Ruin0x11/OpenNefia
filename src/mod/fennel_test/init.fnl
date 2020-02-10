(local Log (require "api.Log"))

(Log.warn "I'm in a fennel!" 1)

(definst serval base.chip
  (group "chara")
  (image "mod/fennel_test/graphic/serval.png"))

(definst serval base.chara
  (level 10)
  (ai-move 50)
  (ai-dist 2)
  (faction "base.enemy")
  (race "elona.quickling")
  (image "fennel_test.serval")
  (color [215 255 215])
  (rarity 15000)
  (coefficient 400))
