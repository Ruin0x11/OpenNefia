local Enum = require("api.Enum")

local Util = {}

local COLORS = {
   [0] = "White",
   [1] = "White",
   [2] = "Green",
   [3] = "Red",
   [4] = "Blue",
   [5] = "Yellow",
   [6] = "Brown",
   [7] = "Black",
   [8] = "Purple",
   [9] = "SkyBlue",
   [10] = "Pink",
   [11] = "Orange",
   [12] = "White",
   [13] = "Fresh",
   [14] = "DarkGreen",
   [15] = "Gray",
   [16] = "LightRed",
   [17] = "LightBlue",
   [18] = "LightPurple",
   [19] = "LightGreen",
   [20] = "Talk",
   -- [21] = "RandomFurniture",
   -- [22] = "RandomSeeded",
   -- [23] = "RandomAny"
}

function Util.convert_122_color_index(color_idx)
   local color = COLORS[color_idx]
   assert(color, "Unknown color " .. color_idx)
   return Enum.Color[color]
end

return Util
