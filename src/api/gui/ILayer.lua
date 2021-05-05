local IDrawable = require("api.gui.IDrawable")
local ILayer = class.interface("ILayer", { relayout = "function" }, { IDrawable })

ILayer.DEFAULT_Z_ORDER = 100000

function ILayer:default_z_order()
   return nil
end

function ILayer:release()
end

function ILayer:on_hotload_layer()
end

return ILayer
