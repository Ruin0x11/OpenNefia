local IMapObject = require("api.IMapObject")

-- A feat is anything that is a part of the map with a position. Feats
-- also include traps.
local IFeat = interface("IFeat", {}, IMapObject)

function IFeat:build()
end

function IFeat:refresh()
   self.temp = {}
end

function IFeat:on_stepped_on(obj)
end

function IFeat:on_bumped_into(obj)
end

function IFeat:on_open()
end

function IFeat:on_close()
end

return IFeat
