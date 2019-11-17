#!/bin/sed -f

s/"White"/{ 255, 255, 255 }/
s/"White2"/{ 255, 255, 255 }/
s/"Green"/{ 175, 255, 175 }/
s/"Red"/{ 255, 155, 155 }/
s/"Blue"/{ 175, 175, 255 }/
s/"Orange"/{ 255, 215, 175 }/
s/"Yellow"/{ 255, 255, 175 }/
s/"Grey"/{ 155, 154, 153 }/
s/"Purple"/{ 185, 155, 215 }/
s/"Cyan"/{ 155, 205, 205 }/
s/"LightRed"/{ 255, 195, 185 }/
s/"Gold"/{ 235, 215, 155 }/
s/"LightBrown"/{ 225, 215, 185 }/
s/"DarkGreen"/{ 105, 235, 105 }/
s/"LightGrey"/{ 205, 205, 205 }/
s/"PaleRed"/{ 255, 225, 225 }/
s/"LightBlue"/{ 225, 225, 255 }/
s/"LightPurple"/{ 225, 195, 255 }/
s/"LightGreen"/{ 215, 255, 215 }/
s/"YellowGreen"/{ 210, 250, 160 }/

s/legacy_id/elona_id/
/dice_x = 0/d
/dice_y = 0/d
/hit_bonus = 0/d
/damage_bonus = 0/d
/pv = 0/d
/dv = 0/d
/material = 0/d
/chargelevel = 0/d
/is_readable = false/d
/is_zappable = false/d
/is_drinkable = false/d
/is_cargo = false/d
/is_usable = false/d
s/is_usable = true/on_use = function() end/
s/is_zappable = true/on_zap = function() end/
s/is_drinkable = true/on_drink = function() end/
s/is_readable = true/on_read = function() end/
/appearance = 0/d
/level = 1,/d
/fltselect = 0/d
/light = 0/d
/tags = {}/d
/rftags = {}/d
/locale_key_prefix/d
/has_random_name = false,/d
/subcategory = 99999,/d
/expiration_date = 0,/d
/rarity = 1000000,/d
/originalnameref2 = ""/d
s/ id = / _id = /
