local IBBoxTransform = require("mod.plot.api.IBBoxTransform")
local CompositeBBox = class.class("CompositeBBox", IBBoxTransform)

function CompositeBBox:init(from, bbox)
    assert(class.is_an(IBBoxTransform, from))
    self.coords_from = from
    self.bbox = bbox

    self._valid = false
    self._bounds = nil
end

function CompositeBBox:get_bounds()
    if not self._valid then
        local x_min, y_min = self.coords_from:transform(self.bbox[1][1],
                                                        self.bbox[2][1])
        local x_max, y_max = self.coords_from:transform(self.bbox[1][2],
                                                        self.bbox[2][2])
        self._bounds = {{x_min, x_max}, {y_min, y_max}}
    end
    return self._bounds
end

function CompositeBBox:invalidate()
    self.valid = false
    self._bounds = nil

    self.coords_from:invalidate()
end

function CompositeBBox:transform(x, y)
    local n_trans = {self.coords_from:transform(x, y)}
    local axes_from = self.coords_from:get_bounds()

    local results = {}
    for i = 1, #n_trans do
        local n = n_trans[i]
        local axis_from = axes_from[i]
        local axis_to = self.bbox[i]

        if axis_from == nil then
            error("No axis from for dimension " .. i)
        end
        if axis_to == nil then error("No axis to for dimension " .. i) end

        results[#results + 1] = math.map(n, axis_from[1], axis_from[2],
                                         axis_to[1], axis_to[2])
    end

    return table.unpack(results)
end

return CompositeBBox
