local Enum = {}


function Enum.try_get(self, k)
   local v = rawget(self, k)
   if v == nil then
      return nil, ("Unknown enum variant '%s.%s'"):format(self.__name, k)
   end
   return v, nil
end

function Enum.ensure_get(self, k)
   return assert(self:try_get(k))
end

function Enum.has_value(self, v)
   for k, o in pairs(self) do
      if v == o then
         return true
      end
   end
   return false, ("Unknown enum value '%s.%s'"):format(self.__name, v)
end

function Enum.to_string(self, v)
   for k, o in pairs(self) do
      if v == o then
         return k
      end
   end
   error(("Unknown enum value '%s.%s'"):format(self.__name, v))
end

function Enum.values(self, v)
   local res = {}
   for _, o in pairs(self) do
      res[#res+1] = o
   end
   return res
end

local function enum_index(name)
   return function(t, k)
      if k == "__enum" then
         return true
      end
      if k == "__name" then
         return name
      end
      if Enum[k] then
         return Enum[k]
      end
      local v, err = Enum.try_get(t, k)
      if not v then
         error(err)
      end
      return v
   end
end

function Enum.new(name, tbl)
   return setmetatable(tbl, { __index = enum_index(name) })
end

Enum.Quality = Enum.new("Quality", {
   Bad    = 1,
   Normal = 2,
   Good   = 3,
   Great  = 4,
   God    = 5,
   Unique = 6,
})

Enum.TileRole = Enum.new("TileRole", {
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

Enum.OwnState = Enum.new("OwnState", {
    Inherited    = -2,
    None         = 0,
    NotOwned     = 1, -- TODO rename to NPC
    Shop         = 2,
    Shelter      = 3,
    Quest        = 4,
    Unobtainable = 5
})

Enum.IdentifyState = Enum.new("IdentifyState", {
	None    =  0,
	Name    =  1,
	Quality =  2,
	Full    =  3
})

Enum.CurseState = Enum.new("CurseState", {
	Doomed  = -2,
	Cursed  = -1,
	Normal  = 0,
	Blessed = 1
})

Enum.Color = Enum.new("Color", {
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

-- >>>>>>>> shade2/init.hsp:280 	#enum global aiNull=0 ..
Enum.AiBehavior = Enum.new("AiBehavior", {
   Null = 0,
   Roam = 1,
   Dull = 2,
   Stand = 3,
   Follow = 4,
   Special = 5
})
-- <<<<<<<< shade2/init.hsp:285 	#enum global aiSpecial ..

-- >>>>>>>> shade2/init.hsp:825 	#enum global fltGoblin=1 ..
Enum.CharaCategory = Enum.new("CharaCategory", {
   None = 0,
   Goblin = 1,
   Orc = 2,
   Slime = 3,
   Elea = 4,
   Kobolt = 5,
   Spider = 6,
   Yeek = 7,
   Mercenary = 8,
   Zombie = 9,
   Dog = 10,
   Bear = 11,
   Kamikaze = 12,
   Mummy = 13,
   HoundFire = 14,
   HoundIce = 15,
   HoundLightning = 16,
   HoundDarkness = 17,
   HoundMind = 18,
   HoundNerve = 19,
   HoundPoison = 20,
   HoundSound = 21,
   HoundNether = 22,
   HoundChaos = 23,
})
-- <<<<<<<< shade2/init.hsp:847 	#enum global fltHoundChaos ...

-- >>>>>>>> shade2/init.hsp:815 	#enum global fltSp=1 ..
Enum.FltSelect = Enum.new("FltSelect", {
	None = 0,
	Sp = 1,
	Unique = 2,
	SpUnique = 3,
	Friend = 4,
	Town = 5,
	SfTown = 6,
	Shop = 7,
	Snow = 8,
	TownSp = 9,
})
-- <<<<<<<< shade2/init.hsp:823 	#enum global fltTownSp ..

-- >>>>>>>> shade2/init.hsp:366 	#define global cAlly		10 ...
Enum.Relation = Enum.new("Relation", {
    Ally = 10,
    Neutral = 0,
    Dislike = -1,
    Hate = -2,
    Enemy = -3
})
-- <<<<<<<< shade2/init.hsp:370 	#define global cEnemy		-3 ..

Enum.Burden = Enum.new("Burden", {
    None = 0,
    Light = 1,
    Moderate = 2,
    Heavy = 3,
    Max = 4
})

Enum.Direction = Enum.new("Direction", {
   North     = "North",
   South     = "South",
   East      = "East",
   West      = "West",
   Northeast = "Northeast",
   Southeast = "Southeast",
   Northwest = "Northwest",
   Southwest = "Southwest",
   Center    = "Center"
})

return Enum
