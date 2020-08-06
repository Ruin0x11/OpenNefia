data:add_type {
    name = "item_material",
    fields = {
        {
            name = "weight",
            default = 10,
            template = true
        },
        {
            name = "value",
            default = 10,
            template = true
        },
        {
            name = "hit_bonus",
            default = 10,
            template = true
        },
        {
            name = "damage_bonus",
            default = 10,
            template = true
        },
        {
            name = "dv",
            default = 10,
            template = true
        },
        {
            name = "pv",
            default = 10,
            template = true
        },
        {
            name = "dice_y",
            default = 100,
            template = true
        },
        {
            name = "color",
            type = "{int,int,int}",
            default = { 255, 255, 255 },
            template = true
        },
        {
            name = "no_furniture",
            default = nil
        }
    },
}

data:add {
    _type="elona.item_material",
    _id="sand",
    elona_id=0,
    a="砂",
    b="子供のおもちゃの",
    c="sand",
    d="toy",
    weight=10,
    value=80,
    hit_bonus=-5,
    damage_bonus=-5,
    dv=-5,
    pv=-5,
    dice_y=100,
    color={ 255, 255, 255 }
}

data:add {
    _type="elona.item_material",
    _id="leather",
    elona_id=1,
    a="革",
    b="全てを包む",
    c="leather",
    d="mysterious",
    weight=100,
    value=150,
    hit_bonus=12,
    damage_bonus=2,
    dv=13,
    pv=6,
    dice_y=100,
    color={ 255, 215, 175 }
}

data:add {
    _type="elona.item_material",
    _id="silk",
    elona_id=2,
    a="シルク",
    b="美しき",
    c="silk",
    d="beautiful",
    weight=40,
    value=190,
    hit_bonus=9,
    damage_bonus=-2,
    dv=10,
    pv=2,
    dice_y=100,
    color={ 255, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.mind" } }
    },

    no_furniture = true
}

data:add {
    _type="elona.item_material",
    _id="cloth",
    elona_id=3,
    a="布",
    b="艶やかなる",
    c="cloth",
    d="charming",
    weight=20,
    value=30,
    hit_bonus=6,
    damage_bonus=-5,
    dv=7,
    pv=2,
    dice_y=100,
    color={ 255, 195, 185 },

    no_furniture = true
}

data:add {
    _type="elona.item_material",
    _id="scale",
    elona_id=4,
    a="鱗",
    b="逆鱗に触れし",
    c="scale",
    d="wrath",
    weight=180,
    value=250,
    hit_bonus=14,
    damage_bonus=6,
    dv=12,
    pv=11,
    dice_y=120,
    color={ 255, 195, 185 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.fire" } }
    },
}

data:add {
    _type="elona.item_material",
    _id="glass",
    elona_id=5,
    a="硝子",
    b="透き通る",
    c="glass",
    d="transparent",
    weight=180,
    value=150,
    hit_bonus=19,
    damage_bonus=0,
    dv=17,
    pv=0,
    dice_y=100,
    color={ 175, 175, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 150, params = { skill_id = "elona.stat_speed" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="mithril",
    elona_id=7,
    a="ミスリル",
    b="古なる",
    c="mithril",
    d="ancient",
    weight=240,
    value=750,
    hit_bonus=20,
    damage_bonus=18,
    dv=25,
    pv=17,
    dice_y=190,
    color={ 175, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_skill", power = 100, params = { skill_id = "elona.casting" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="ether",
    elona_id=8,
    a="エーテル",
    b="永遠なる",
    c="ether",
    d="eternal",
    weight=80,
    value=1200,
    hit_bonus=8,
    damage_bonus=45,
    dv=35,
    pv=8,
    dice_y=250,
    color={ 175, 175, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 200, params = { skill_id = "elona.stat_speed" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="steel",
    elona_id=9,
    a="スティール",
    b="由緒ある",
    c="steel",
    d="historic",
    weight=270,
    value=280,
    hit_bonus=12,
    damage_bonus=13,
    dv=8,
    pv=18,
    dice_y=140,
    color={ 255, 255, 255 },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="iron",
    elona_id=10,
    a="鉄",
    b="鉄塊と呼ばれる",
    c="metal",
    d="mass",
    weight=280,
    value=190,
    hit_bonus=8,
    damage_bonus=8,
    dv=3,
    pv=14,
    dice_y=130,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 25, params = { element_id = "elona.fire" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="crystal",
    elona_id=11,
    a="水晶",
    b="異光を放つ",
    c="crystal",
    d="rainbow",
    weight=200,
    value=800,
    hit_bonus=19,
    damage_bonus=14,
    dv=16,
    pv=19,
    dice_y=150,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_magic" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="bronze",
    elona_id=12,
    a="ブロンズ",
    b="気高き",
    c="bronze",
    d="noble",
    weight=200,
    value=70,
    hit_bonus=2,
    damage_bonus=5,
    dv=1,
    pv=5,
    dice_y=100,
    color={ 255, 215, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.lightning" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="diamond",
    elona_id=13,
    a="ダイヤ",
    b="うつろいなき",
    c="diamond",
    d="ever lasting",
    weight=330,
    value=1100,
    hit_bonus=19,
    damage_bonus=27,
    dv=13,
    pv=31,
    dice_y=220,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.lightning" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="spirit_cloth",
    elona_id=14,
    a="霊布",
    b="この世ならざる",
    c="spirit cloth",
    d="amazing",
    weight=40,
    value=750,
    hit_bonus=3,
    damage_bonus=2,
    dv=34,
    pv=6,
    dice_y=100,
    color={ 175, 175, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 200, params = { skill_id = "elona.stat_speed" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="rubynus",
    elona_id=15,
    a="ルビナス",
    b="赤く染まった",
    c="rubynus",
    d="crimson",
    weight=250,
    value=1000,
    hit_bonus=38,
    damage_bonus=18,
    dv=31,
    pv=24,
    dice_y=190,
    color={ 255, 155, 155 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 125, params = { skill_id = "elona.stat_life" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="paper",
    elona_id=16,
    a="紙",
    b="ふざけた",
    c="paper",
    d="silly",
    weight=10,
    value=20,
    hit_bonus=15,
    damage_bonus=-10,
    dv=12,
    pv=0,
    dice_y=100,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_skill", power = 100, params = { skill_id = "elona.evasion" } }
    },

    no_furniture = true
}
--mtEnc(0,p)=encSkill(rsEvade),100

data:add {
    _type="elona.item_material",
    _id="dawn_cloth",
    elona_id=17,
    a="宵晒",
    b="宵闇を纏いし",
    c="dawn cloth",
    d="dawn",
    weight=45,
    value=850,
    hit_bonus=10,
    damage_bonus=8,
    dv=35,
    pv=15,
    dice_y=100,
    color={ 175, 175, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 200, params = { skill_id = "elona.stat_mana" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="bone",
    elona_id=18,
    a="ボーン",
    b="不死なる",
    c="bone",
    d="immortal",
    weight=120,
    value=300,
    hit_bonus=10,
    damage_bonus=6,
    dv=12,
    pv=11,
    dice_y=140,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.nether" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="chain",
    elona_id=19,
    a="鉄鎖",
    b="連鎖せし",
    c="chain",
    d="spiral",
    weight=200,
    value=300,
    hit_bonus=11,
    damage_bonus=8,
    dv=17,
    pv=14,
    dice_y=100,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.darkness" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="obsidian",
    elona_id=20,
    a="オブシディアン",
    b="神殺しの",
    c="obsidian",
    d="godbane",
    weight=160,
    value=350,
    hit_bonus=16,
    damage_bonus=10,
    dv=13,
    pv=14,
    dice_y=130,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.chaos" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="mica",
    elona_id=21,
    a="ミカ",
    b="儚き",
    c="mica",
    d="ephemeral",
    weight=40,
    value=150,
    hit_bonus=10,
    damage_bonus=-2,
    dv=12,
    pv=0,
    dice_y=100,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_luck" } }
    },

    no_furniture = true
}

data:add {
    _type="elona.item_material",
    _id="pearl",
    elona_id=22,
    a="真珠",
    b="闇を照らす",
    c="perl",
    d="shining",
    weight=240,
    value=400,
    hit_bonus=18,
    damage_bonus=6,
    dv=18,
    pv=12,
    dice_y=140,
    color={ 255, 195, 185 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_perception" } }
    }
}


data:add {
    _type="elona.item_material",
    _id="emerald",
    elona_id=23,
    a="エメラルド",
    b="奇跡を呼ぶ",
    c="emerald",
    d="miracle",
    weight=240,
    value=1050,
    hit_bonus=22,
    damage_bonus=23,
    dv=18,
    pv=28,
    dice_y=190,
    color={ 175, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.nerve" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="dragon_scale",
    elona_id=24,
    a="竜鱗",
    b="竜を統べし",
    c="dragon scale",
    d="dragonbane",
    weight=220,
    value=800,
    hit_bonus=25,
    damage_bonus=24,
    dv=29,
    pv=24,
    dice_y=160,
    color={ 175, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.fire" } },
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.cold" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="silver",
    elona_id=25,
    a="シルバー",
    b="闇を砕く",
    c="silver",
    d="dreadbane",
    weight=230,
    value=250,
    hit_bonus=10,
    damage_bonus=7,
    dv=7,
    pv=11,
    dice_y=130,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.darkness" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="platinum",
    elona_id=26,
    a="白銀",
    b="光を纏いし",
    c="platinum",
    d="brilliant",
    weight=260,
    value=350,
    hit_bonus=16,
    damage_bonus=11,
    dv=14,
    pv=17,
    dice_y=140,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.darkness" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="zylon",
    elona_id=27,
    a="ザイロン",
    b="異国からもたらされし",
    c="zylon",
    d="foreign",
    weight=50,
    value=500,
    hit_bonus=5,
    damage_bonus=4,
    dv=21,
    pv=16,
    dice_y=100,
    color={ 175, 175, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 50, params = { element_id = "elona.nether" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="griffon_scale",
    elona_id=28,
    a="翼鳥鱗",
    b="翼を折られし",
    c="griffon scale",
    d="fallen",
    weight=70,
    value=1000,
    hit_bonus=16,
    damage_bonus=17,
    dv=32,
    pv=24,
    dice_y=120,
    color={ 175, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_skill", power = 100, params = { skill_id = "elona.evasion" } }
    }
}

data:add {
    _type="elona.item_material",
    _id="titanium",
    elona_id=29,
    a="チタン",
    b="色褪せぬ",
    c="titanium",
    d="fadeless",
    weight=200,
    value=750,
    hit_bonus=21,
    damage_bonus=18,
    dv=19,
    pv=22,
    dice_y=160,
    color={ 255, 255, 255 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_strength" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="chrome",
    elona_id=30,
    a="クロム",
    b="真実を暴く",
    c="chrome",
    d="pure",
    weight=320,
    value=500,
    hit_bonus=15,
    damage_bonus=17,
    dv=12,
    pv=22,
    dice_y=150,
    color={ 255, 255, 255 }
}

data:add {
    _type="elona.item_material",
    _id="adamantium",
    elona_id=31,
    a="アダマンタイト",
    b="大地を揺るがす",
    c="adamantium",
    d="earth",
    weight=360,
    value=1150,
    hit_bonus=11,
    damage_bonus=38,
    dv=8,
    pv=42,
    dice_y=240,
    color={ 255, 195, 185 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_constitution" } }
    },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
       item:mod("is_fireproof", true)
    end
}
--mtEnc(0,p)=encAttb(rsEND),100
--mtBit(0,p)=iAcidProof,iFireProof

data:add {
    _type="elona.item_material",
    _id="gold",
    elona_id=32,
    a="ゴールデン",
    b="黄金に輝く",
    c="gold",
    d="golden",
    weight=300,
    value=800,
    hit_bonus=13,
    damage_bonus=18,
    dv=14,
    pv=22,
    dice_y=140,
    color={ 255, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_attribute", power = 100, params = { skill_id = "elona.stat_strength" } }
    },

    on_refresh = function(item)
       item:mod("is_fireproof", true)
    end
}

data:add {
    _type="elona.item_material",
    _id="coral",
    elona_id=33,
    a="珊瑚",
    b="海からもたらされし",
    c="coral",
    d="ocean",
    weight=180,
    value=240,
    hit_bonus=7,
    damage_bonus=2,
    dv=10,
    pv=7,
    dice_y=120,
    color={ 255, 255, 175 },

    fixed_enchantments = {
       { _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.lightning" } }
    }
}
--mtEnc(0,p)=encRes(rsResLightning),100

data:add {
    _type="elona.item_material",
    _id="lead",
    elona_id=34,
    a="鉛",
    b="重き",
    c="iron",
    d="heavy",
    weight=300,
    value=50,
    hit_bonus=3,
    damage_bonus=4,
    dv=-3,
    pv=11,
    dice_y=100,
    color={ 255, 255, 255 },

    on_refresh = function(item)
       item:mod("is_acidproof", true)
    end
}
--mtEnc(0,p)=0
--mtBit(0,p)=iAcidProof

data:add {
    _type="elona.item_material",
    _id="fresh",
    elona_id=35,
    a="生もの",
    b="食用",
    c="raw",
    d="candy",
    weight=100,
    value=50,
    hit_bonus=-5,
    damage_bonus=-5,
    dv=-5,
    pv=-5,
    dice_y=100,
    color={ 255, 255, 255 }
}

data:add {
    _type="elona.item_material",
    _id="wood",
    elona_id=43,
    a="木",
    b="古き",
    c="wood",
    d="old",
    weight=150,
    value=50,
    hit_bonus=-5,
    damage_bonus=-5,
    dv=-5,
    pv=-5,
    dice_y=100,
    color={ 255, 255, 255 }
}


-- placeholders for random generation
data:add {
    _type="elona.item_material",
    _id="metal",
    elona_id=1000,
    weight=0,
    value=0,
    hit_bonus=0,
    damage_bonus=0,
    dv=0,
    pv=0,
    dice_y=0,
    color={ 255, 255, 255 }
}
data:add {
    _type="elona.item_material",
    _id="soft",
    elona_id=1001,
    weight=0,
    value=0,
    hit_bonus=0,
    damage_bonus=0,
    dv=0,
    pv=0,
    dice_y=0,
    color={ 255, 255, 255 }
}
