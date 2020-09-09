local ICoordinateTransform = require("mod.plot.api.ICoordinateTransform")

local IBBoxTransform = class.interface("IBBoxTransform",
                                       {
                                          get_bounds = "function"
                                       }, {ICoordinateTransform})

return IBBoxTransform
