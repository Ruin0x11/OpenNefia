local IChipRenderable = class.interface("IChipRenderable", { draw = "function", refresh = "function", release = "function" })

function IChipRenderable:on_scroll()
end

return IChipRenderable
