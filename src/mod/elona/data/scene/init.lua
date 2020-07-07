local jp = dofile("mod.elona.data.scene.jp")
local en = dofile("mod.elona.data.scene.en")

local keys = table.intersection(table.set(table.keys(jp)), table.set(table.keys(en)))

for _, id in ipairs(keys) do
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
