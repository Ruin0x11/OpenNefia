local Log = require ("api.Log")

Log.info("Hello from %s!", _MOD_NAME)

data:add {
  _type = "base.chara",
  _id = "chara",
  level = 1,
  faction = "base.enemy",
  race = "elona.slime",
  class = "elona.predator",
  rarity = 0,
  coefficient = 0,
  color = {0, 255, 0}
}