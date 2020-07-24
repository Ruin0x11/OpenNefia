local Enum = {}

local function enum_index(name)
   return function(t, k)
      if k == "__enum" then
         return true
      end
      local v = rawget(t, k)
      if not v then
         error(("Unknown enum variant '%s.%s'"):format(name, k))
      end
      return v
   end
end

local function try_get(self, k)
   return rawget(self, k)
end

local function to_list(self)
   return rawget(self, k)
end

local function enum(name, tbl)
   tbl.try_get = try_get
   return setmetatable(tbl, { __index = enum_index(name) })
end

Enum.Quality = enum("Quality", {
   Bad    = 1,
   Normal = 2,
   Good   = 3,
   Great  = 4,
   God    = 5,
   Unique = 6,
})

Enum.TileRole = enum("TileRole", {
	None          = 0,
	Dryground     = 1,
	Crop          = 2,
	Water         = 3,
	Snow          = 4,
	MountainWater = 5,
	HardWall      = 6,
	Sand          = 7,
	SandHard      = 8,
	Coast         = 9,
	SandWater     = 10
})

Enum.OwnState = enum("OwnState", {
    Inherited    = "inherited",    -- -2
    None         = "none",         -- 0
    NotOwned     = "not_owned",    -- 1
    Shop         = "shop",         -- 2
    Shelter      = "shelter",      -- 3
    Harvested    = "harvested",    -- 4
    Unobtainable = "unobtainable", -- 5
})

Enum.IdentifyState = enum("IdentifyState", {
	None    =  0,
	Name    =  1,
	Quality =  2,
	Full    =  3
})

Enum.CurseState = enum("CurseState", {
	Doomed  = "doomed",  -- -1
	Cursed  = "cursed",  -- -2
	Normal  = "none",    -- 0
	Blessed = "blessed", -- 1
})

Enum.Color = enum("Color", {
   White =         { 255, 255, 255 },
   Green =         { 175, 255, 175 },
   Red =           { 255, 155, 155 },
   Blue =          { 175, 175, 255 },
   Yellow =        { 255, 215, 175 },
   Brown  =        { 255, 255, 175 },
   Black =         { 155, 154, 153 },
   Purple =        { 185, 155, 215 },
   SkyBlue =       { 155, 205, 205 },
   Pink =          { 255, 195, 185 },
   Orange =        { 235, 215, 155 },
   Fresh =         { 225, 215, 185 },
   DarkGreen =     { 105, 235, 105 },
   Gray =          { 205, 205, 205 },
   LightRed =      { 255, 225, 225 },
   LightBlue =     { 225, 225, 255 },
   LightPurple =   { 225, 195, 255 },
   LightGreen =    { 215, 255, 215 },
   Talk =          { 210, 250, 160 },
})

return Enum
