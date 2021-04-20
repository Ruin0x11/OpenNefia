local ItemEx = require("mod.ffhp.api.ItemEx")

print(ItemEx.convert_item_ex_csv("mod/ceri_items/graphic/item/itemEx.csv", "mod/ceri_items", "ceri_items"))
print(ItemEx.convert_item_ex_csv("mod/ffhp_matome/graphic/item/itemEx.csv", "mod/ffhp_matome", "ffhp_matome"))
