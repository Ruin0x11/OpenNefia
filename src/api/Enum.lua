local Enum = {}

Enum.Quality = {
   Bad = 1,
   Good = 2,
   Great = 3,
   Miracle = 4,
   Godly = 5,
   Special = 6,
}

Enum.TileRole = {
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
}

Enum.OwnState = {
    Inherited = "inherited",       -- -2
    None = "none",                 -- 0
    NotOwned = "not_owned",        -- 1
    Shop = "shop",                 -- 2
    Shelter = "shelter",           -- 3
    Harvested = "harvested",       -- 4
    Unobtainable = "unobtainable", -- 5
}

return Enum
