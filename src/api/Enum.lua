local Enum = {}


function Enum.try_get(self, k)
   local v = rawget(self, k)
   if v == nil then
      return nil, ("Unknown enum variant '%s.%s'"):format(self.__name, k)
   end
   return v, nil
end

function Enum.has_value(self, v)
   for k, o in pairs(self) do
      if v == o then
         return true
      end
   end
   return false
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

local function enum(name, tbl)
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
    Inherited    = -2,
    None         = 0,
    NotOwned     = 1, -- TODO rename to NPC
    Shop         = 2,
    Shelter      = 3,
    Quest        = 4,
    Unobtainable = 5
})

Enum.IdentifyState = enum("IdentifyState", {
	None    =  0,
	Name    =  1,
	Quality =  2,
	Full    =  3
})

Enum.CurseState = enum("CurseState", {
	Doomed  = -2,
	Cursed  = -1,
	Normal  = 0,
	Blessed = 1
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

-- >>>>>>>> shade2/init.hsp:280 	#enum global aiNull=0 ..
Enum.AiBehavior = enum("AiBehavior", {
   Null = 0,
   Roam = 1,
   Dull = 2,
   Stand = 3,
   Follow = 4,
   Special = 5
})
-- <<<<<<<< shade2/init.hsp:285 	#enum global aiSpecial ..

-- >>>>>>>> shade2/init.hsp:825 	#enum global fltGoblin=1 ..
Enum.CharaCategory = enum("CharaCategory", {
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
Enum.FltSelect = enum("FltSelect", {
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
Enum.Relation = enum("Relation", {
    Ally = 10,
    Neutral = 0,
    Dislike = -1,
    Hate = -2,
    Enemy = -3
})
-- <<<<<<<< shade2/init.hsp:370 	#define global cEnemy		-3 ..

Enum.Burden = enum("Burden", {
    None = 0,
    Light = 1,
    Moderate = 2,
    Heavy = 3,
    Max = 4
})

return Enum
