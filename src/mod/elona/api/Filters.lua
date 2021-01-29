local Rand = require("api.Rand")

local Filters = {}

Filters.fsetarmor = {
   "elona.equip_head",
   "elona.equip_body",
   "elona.equip_back",
   "elona.equip_cloak",
   "elona.equip_leg",
   "elona.equip_wrist",
   "elona.equip_shield",
}

Filters.fsetbarrel = {
   "elona.equip_ammo",
   "elona.food",
   "elona.scroll",
   "elona.drink",
   "elona.ore",
   "elona.junk_in_field",
}

Filters.fsetchest = {
   "elona.equip_melee",
   "elona.equip_ranged",
   "elona.equip_head",
   "elona.equip_body",
   "elona.equip_back",
   "elona.equip_cloak",
   "elona.equip_leg",
   "elona.equip_wrist",
   "elona.equip_shield",
   "elona.equip_ring",
   "elona.equip_neck",
   "elona.spellbook",
   "elona.misc_item",
}

Filters.fsetcollect = {
   "elona.junk_in_field",
   "elona.furniture",
   "elona.food",
   "elona.ore",
}

Filters.fsetdeliver = {
   "elona.furniture",
   "elona.ore",
   "elona.spellbook",
   "elona.junk",
}

Filters.fsetincome = {
   "elona.drink",
   "elona.drink",
   "elona.drink",
   "elona.scroll",
   "elona.scroll",
   "elona.rod",
   "elona.spellbook",
   "elona.ore",
   "elona.food",
   "elona.food",
}

Filters.fsetitem = {
   "elona.drink",
   "elona.drink",
   "elona.scroll",
   "elona.scroll",
   "elona.rod",
   "elona.gold",
   "elona.spellbook",
   "elona.junk_in_field",
   "elona.misc_item",
   "elona.book",
}

Filters.fsetmagic = {
   "elona.scroll",
   "elona.rod",
   "elona.spellbook",
}

Filters.fsetperform = {
   "elona.ore",
   "elona.food",
   "elona.food",
   "elona.food",
   "elona.furniture",
   "elona.equip_leg",
   "elona.equip_back",
   "elona.equip_ring",
   "elona.equip_neck",
   "elona.drink",
   "elona.junk_in_field",
   "elona.junk_in_field",
}

Filters.fsetplantartifact = {
   "elona.equip_ring",
   "elona.equip_neck",
}

Filters.fsetplantunknown = {
   "elona.food",
   "elona.food",
   "elona.spellbook",
   "elona.junk_in_field",
   "elona.ore",
}

Filters.fsetrare = {
   "elona.furniture",
   "elona.container",
   "elona.ore",
   "elona.book",
   "elona.food",
}

Filters.fsetrewardsupply = {
   "elona.drink",
   "elona.scroll",
   "elona.rod",
   "elona.spellbook",
   "elona.food",
}

Filters.fsetsupply = {
   "elona.furniture",
   "elona.ore",
   "elona.rod",
   "elona.spellbook",
   "elona.junk_in_field",
}

Filters.fsetweapon = {
   "elona.equip_melee",
   "elona.equip_ranged",
   "elona.equip_ammo",
}

Filters.fsetwear = {
   "elona.equip_melee",
   "elona.equip_melee",
   "elona.equip_ranged",
   "elona.equip_ranged",
   "elona.equip_ammo",
   "elona.equip_head",
   "elona.equip_body",
   "elona.equip_back",
   "elona.equip_cloak",
   "elona.equip_leg",
   "elona.equip_wrist",
   "elona.equip_shield",
   "elona.equip_ring",
   "elona.equip_neck",
}

Filters.isetcrop = {
   "elona.apple",
   "elona.grape",
   "elona.lemon",
   "elona.strawberry",
   "elona.cherry",
   "elona.lettuce",
   "elona.melon",
}

Filters.isetdeed = {
   "elona.deed",
   "elona.deed_of_museum",
   "elona.deed_of_shop",
   "elona.deed_of_farm",
   "elona.deed_of_storage_house",
   "elona.shelter",
   "elona.deed_of_ranch",
}

Filters.isetfruit = {
   "elona.apple",
   "elona.grape",
   "elona.orange",
   "elona.lemon",
   "elona.strawberry",
   "elona.cherry",
}

Filters.isetgiftgrand = {
   "elona.five_horned_helm",
   "elona.aurora_ring",
   "elona.speed_ring",
   "elona.mauser_c96_custom",
   "elona.lightsabre",
   "elona.goulds_piano",
}

Filters.isetgiftmajor = {
   "elona.kagami_mochi",
   "elona.kagami_mochi",
   "elona.panty",
   "elona.bottle_of_hermes_blood",
   "elona.scroll_of_superior_material",
   "elona.flying_scroll",
   "elona.sisters_love_fueled_lunch",
   "elona.shelter",
   "elona.summoning_crystal",
   "elona.unicorn_horn",
}

Filters.isetgiftminor = {
   "elona.kotatsu",
   "elona.daruma",
   "elona.daruma",
   "elona.mochi",
   "elona.mochi",
   "elona.black_crystal",
   "elona.snow_man",
   "elona.painting_of_landscape",
   "elona.painting_of_sunflower",
   "elona.tree_of_fruits",
   "elona.treasure_ball",
   "elona.deed_of_heirship",
   "elona.rune",
   "elona.remains_heart",
   "elona.remains_blood",
   "elona.upright_piano",
   "elona.dead_fish",
   "elona.shit",
   "elona.small_medal",
   "elona.brand_new_grave",
}

Filters.isethire = {
   "elona.bottle_of_whisky",
   "elona.potion_of_cure_critical_wound",
   "elona.potion_of_healer_odina",
   "elona.raw_ore_of_emerald",
   "elona.potion_of_cure_major_wound",
   "elona.potion_of_healer_jure",
   "elona.long_sword",
   "elona.long_sword",
   "elona.long_sword",
}

Filters.isetthrowpotiongreater = {
   "elona.potion_of_confusion",
   "elona.bottle_of_whisky",
   "elona.potion_of_silence",
   "elona.potion_of_mutation",
   "elona.potion_of_weaken_resistance",
   "elona.potion_of_paralysis",
   "elona.molotov",
}

Filters.isetthrowpotionmajor = {
   "elona.potion_of_confusion",
   "elona.potion_of_slow",
   "elona.bottle_of_whisky",
   "elona.potion_of_silence",
   "elona.potion_of_cure_mutation",
   "elona.potion_of_weakness",
   "elona.molotov",
   "elona.molotov",
}

Filters.isetthrowpotionminor = {
   "elona.potion_of_blindness",
   "elona.potion_of_confusion",
   "elona.potion_of_slow",
   "elona.sleeping_drug",
   "elona.poison",
   "elona.bottle_of_beer",
   "elona.potion_of_hero",
   "elona.bottle_of_sulfuric",
}

function Filters.dungeon()
   if Rand.one_in(20) then
      return Rand.choice(Filters.fsetrare)
   end
   if Rand.one_in(3) then
      return Rand.choice(Filters.fsetwear)
   end
   return Rand.choice(Filters.fsetitem)
end

return Filters
