local jp = dofile("mod.elona.data.scene.jp")
local en = dofile("mod.elona.data.scene.en")

local keys = table.union(table.set(table.keys(jp)), table.set(table.keys(en)))

for id, _ in pairs(keys) do
  local t = {
    _type = "elona_sys.scene",
    _id = id,

    content = {
       jp = jp[id],
       en = en[id]
    }
  }

  data:add(t)
end
