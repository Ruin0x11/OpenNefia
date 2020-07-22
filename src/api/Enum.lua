local Enum = {}

local function enum_index(name)
   return function(t, k)
      local v = rawget(t, k)
      if not v then
         error(("Unknown enum variant '%s.%s'"):format(name, k))
      end
      return v
   end
end

local function enum(name, tbl)
   return setmetatable(tbl, { __index = enum_index(name) })
end

Enum.Quality = enum("Quality", {
   Bad = 1,
   Normal = 2,
   Good = 3,
   Great = 4,
   God = 5,
   Unique = 6,
})

Enum.TileRole = enum("TileRole", {
	None = 0,
	Dryground = 1,
	Crop = 2,
	Water = 3,
	Snow = 4,
	MountainWater = 5,
	HardWall = 6,
	Sand = 7,
	SandHard = 8,
	Coast = 9,
	SandWater = 10
})

Enum.OwnState = enum("OwnState", {
    Inherited = "inherited",       -- -2
    None = "none",                 -- 0
    NotOwned = "not_owned",        -- 1
    Shop = "shop",                 -- 2
    Shelter = "shelter",           -- 3
    Harvested = "harvested",       -- 4
    Unobtainable = "unobtainable", -- 5
})

Enum.IdentifyState = enum("IdentifyState", {
	None = 0,
	Name = 1,
	Quality = 2,
	Full = 3
})

return Enum
