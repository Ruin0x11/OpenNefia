local Chara = require("api.Chara")
local Fs = require("api.Fs")
local Log = require("api.Log")
local InstancedMap = require("api.InstancedMap")
local Item = require("api.Item")
local Compat = require("mod.elona_sys.api.Compat")

local struct = require("mod.elona_sys.map_loader.thirdparty.struct")

local own_states = {
   [-2] = "inherited",
   [0]  = "none",
   [1]  = "not_owned",
   [3]  = "shelter",
   [4]  = "harvested",
   [5]  = "unobtainable",
}

-- Map chips which are exactly the same in image and parameters between atlases 1 and 2.

local same = {
   0, 6, 10, 11, 19, 45, 47, 48, 49, 50,
   66, 67, 68, 69, 70, 71, 72, 73, 74, 75,
   76, 77, 78, 79, 80, 81, 99, 100, 101, 102,
   103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
   113, 114, 115, 116, 117, 118, 132, 133, 134, 135,
   136, 137, 138, 139, 140, 141, 142, 143, 144, 145,
   146, 147, 148, 149, 150, 151, 165, 166, 167, 168,
   169, 170, 171, 172, 173, 198, 199, 200, 201, 202,
   203, 204, 205, 206, 207, 208, 209, 211, 212, 213,
   214, 215, 216, 217, 264, 266, 267, 268, 269, 270,
   271, 272, 273, 274, 276, 277, 278, 279, 280, 281,
   282, 283, 302, 303, 304, 305, 306, 307, 308, 309,
   310, 311, 312, 313, 314, 315, 316, 330, 331, 332,
   336, 340, 341, 343, 344, 345, 346, 363, 364, 365,
   366, 367, 368, 369, 370, 371, 372, 373, 374, 375,
   376, 377, 378, 379, 380, 381, 382, 396, 397, 398,
   414, 415, 416, 417, 418, 419, 420, 421, 422, 423,
   424, 425, 426, 427, 428, 429, 430, 431, 447, 448,
   449, 450, 451, 452, 453, 454, 455, 456, 457, 458,
   459, 460, 461, 462, 463, 465, 466, 467, 468, 469,
   470, 471, 472, 473, 474, 475, 477, 478, 479, 480,
   481, 482, 483, 484, 485, 486, 487, 488, 489, 490,
   491, 492, 495, 496, 497, 498, 499, 500, 501, 502,
   503, 504, 505, 506, 507, 508, 510, 511, 512, 513,
   514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
   524, 525, 528, 529, 530, 532, 533, 534, 535, 536,
   537, 538, 539, 540, 541, 542, 545, 546, 547, 548,
   549, 550, 551, 552, 553, 554, 555, 556, 557, 558,
   561, 562, 563, 570, 571, 573, 578, 579, 580, 581,
   582, 583, 584, 585, 586, 587, 588, 589, 590, 591,
   592, 593, 594, 595, 596, 597, 598, 599, 600, 601,
   602, 603, 604, 605, 606, 607, 608, 609, 610, 611,
   612, 613, 614, 615, 616, 617, 618, 619, 620, 621,
   622, 623, 624, 625, 626, 631, 632, 633, 634, 639,
   640, 642, 643, 644, 645, 646, 647, 648, 649, 650,
   651, 652, 653, 654, 655, 656, 657, 658, 659, 660,
   661, 662, 663, 664, 665, 666, 670, 671, 672, 673,
   674, 675, 676, 677, 678, 679, 680, 681, 682, 683,
   684, 685, 686, 687, 688, 689, 690, 691, 693, 694,
   695, 696, 697, 698, 699, 700, 701, 702, 703, 704,
   705, 706, 707, 708, 709, 710, 711, 712, 713, 714,
   715, 716, 717, 718, 719, 720, 721, 722, 757, 758,
   759, 760, 761, 762, 763, 764, 765, 767, 768, 769,
   770, 771, 772, 773, 774, 775, 776, 777, 778, 779,
   780, 781, 782, 783, 784, 785, 786, 787, 788, 789,
   790, 791, 792, 793, 794, 795, 796, 797, 798, 799,
   800, 801, 802, 803, 804, 805, 806, 807, 808, 809,
   810, 811, 812, 813, 814, 815, 816, 817, 818, 819,
   820, 821, 822, 823, 824
}

local function build_mapping()
   local mapping = { [0] = {}, [1] = {}, [2] = {} }

   for _, v in data["base.map_tile"]:iter() do
      if v.elona_atlas and v.elona_id then
         mapping[v.elona_atlas][v.elona_id] = v._id
      end
   end

   return mapping
end

local mapping

local function convert_122(gen, params)
   if mapping == nil then
      mapping = build_mapping()
   end

   if not params.name then
      error("Map name must be provided")
   end

   -- HACK
   local base = Fs.join("mod/elona/data/map", params.name)

   if not Fs.exists(base .. ".map") then
      error(string.format("Map doesn't exist: %s", base .. ".map"))
   end

   local idx = Fs.open(base .. ".idx")
   local width, height, atlas_no, regen, stair_up = struct.unpack("iiiii", idx:read(4 * 5))

   local result = InstancedMap:new(width, height)

   idx:close()

   local map = Fs.open(base .. ".map")

   local function unp(cnt, i)
      return { struct.unpack(string.rep("i", cnt), i:read(4 * cnt)) }
   end

   local size = width * height
   local tile_ids = unp(size, map)

   local i = 1
   for y=0,height-1 do
      for x=0,width-1 do
         local tile_id = tile_ids[i]

         local new_tile = mapping[atlas_no][tile_id]

         if new_tile == nil then
            assert(atlas_no == 2)
            assert(same[tile_id])

            -- Find the corresponding tile in atlas 1, since this one
            -- is a duplicate in atlas 2.
            new_tile = mapping[1][tile_id]
            assert(new_tile ~= nil)
         end

         result:set_tile(x, y, new_tile)

         i = i + 1
      end
   end

   map:close()

   local obj = Fs.open(base .. ".obj")

   for j=1,300 do
      local data = { struct.unpack("iiiii", obj:read(4 * 5)) }

      if data[1] ~= 0 then
         if data[5] == 0 then
            local id = Compat.convert_122_id("base.item", data[1])
            assert(id, "unknown 1.22 item ID " .. data[1])

            local x = data[2]
            local y = data[3]
            local own_state = own_states[data[4]]
            Log.trace("item: %s %d %d %d", id, x, y, data[4])

            assert(own_state == "none" or own_state == "not_owned")

            local item, err = Item.create(id, x, y, {}, result)
            if not item then
               Log.warn("Failed to create item %s (%d) at (%d, %d): %s", id, data[1], x, y, err)
            else
               item.ownership = own_state
            end
         elseif data[5] == 1 then
            local id = Compat.convert_122_id("base.chara", data[1])
            assert(id, "unknown 1.22 character ID " .. data[1])

            local x = data[2]
            local y = data[3]

            Log.trace("chara: %s %d %d", id, x, y)
            local chara = Chara.create(id, x, y, {}, result)
            if not chara then
               Log.warn("Failed to create chara %s (%d) at (%d, %d)", id, data[1], x, y)
            end
         elseif data[5] == 2 then
            local id = Compat.convert_122_id("base.feat", data[1])
            local x = data[2]
            local y = data[3]
            local param = data[4]

            Log.trace("feat: %s %d %d %d", id, x, y, param)
            -- cmap.objects[#cmap.objects+1] = {
            --    id = data[1],
            --    x = data[2],
            --    y = data[3],
            --    feat_param_a = v[4] % 1000,
            --    feat_param_b = math.floor(v[4] / 1000)
            -- }
         end
      end
   end

   result.player_start_pos = { x = math.floor(width / 2), y = math.floor(height / 2) }

   return result
end

data:add {
   _type = "base.map_generator",
   _id = "elona122",

   generate = convert_122,
   params = { name = "string" },

   almost_equals = function(a, b)
      return a.name == b.name
   end
}
