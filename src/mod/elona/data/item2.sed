#!/bin/sed -f

s/\bcategory = 12000,/\0\nequip_slots = { "elona.head" },/
s/\bcategory = 34000,/\0\nequip_slots = { "elona.neck" },/
s/\bcategory = 20000,/\0\nequip_slots = { "elona.back" },/
s/\bcategory = 16000,/\0\nequip_slots = { "elona.body" },/
s/\bcategory = 10000,/\0\nequip_slots = { "elona.hand" },/
s/\bcategory = 14000,/\0\nequip_slots = { "elona.hand" },/
s/\bcategory = 32000,/\0\nequip_slots = { "elona.ring" },/
s/\bcategory = 22000,/\0\nequip_slots = { "elona.arm" },/
s/\bcategory = 18000,/\0\nequip_slots = { "elona.leg" },/
s/\bcategory = 24000,/\0\nequip_slots = { "elona.ranged" },/
s/\bcategory = 25000,/\0\nequip_slots = { "elona.ammo" },/
s/\bcategory = 19000,/\0\nequip_slots = { "elona.waist" },/
