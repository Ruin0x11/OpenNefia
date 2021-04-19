local IItemDice = require("mod.elona.api.aspect.IItemDice")

return class.interface("IItemWeapon", {
                          pierce_rate = "number",
                          skill = "string",
                       }, { IItemDice })
