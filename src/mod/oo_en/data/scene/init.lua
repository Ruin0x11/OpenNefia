local en = dofile("mod.oo_en.data.scene.en")

local keys = table.keys(en)

-- TODO immutable data edits
for _, _id in ipairs(keys) do
   local full_id = "elona." .. _id
   local scene_proto = data["elona_sys.scene"][full_id]
   if scene_proto then
      scene_proto.content.en = en[_id]
   end
end
