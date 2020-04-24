require("mod.bestiary.data")

local ntyris = data["elona_sys.map_template"]["elona.north_tyris"]

table.insert(ntyris.areas, { map = "bestiary.bestiary_chara", x = 28, y = 21 })
table.insert(ntyris.areas, { map = "bestiary.bestiary_item", x = 30, y = 21 })