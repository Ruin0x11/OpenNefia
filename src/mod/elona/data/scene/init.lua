local en = require("mod.elona.data.scene.en")
local jp = require("mod.elona.data.scene.jp")

for id, scene in pairs(jp) do
  local t = {
    _type = "elona_sys.scene",
    _id = id,

    content = {
      jp = scene
    }
  }

  if en[id] then
    t.content.en = en[id]
  end

  data:add(t)
end
