return {
	skill = {
		gained = function(_1)
			return ("あなたは「%s」の能力を得た。"):format(_1)
		end,

		default = {
			on_decrease = function(_1, _2)
				return ("%sは%sの技術の衰えを感じた。"):format(name(_1), _2)
			end,
			on_increase = function(_1, _2)
				return ("%sは%sの技術の向上を感じた。"):format(name(_1), _2)
			end,
		},

		_ = {
			elona = {
				stat_strength = {
					name = "筋力",
					short_name = "筋力",

					on_decrease = function(_1)
						return ("%sは少し贅肉が増えたような気がした。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sはより強くなった。"):format(name(_1))
					end,
				},
				stat_constitution = {
					name = "耐久",
					short_name = "耐久",

					on_decrease = function(_1)
						return ("%sは我慢ができなくなった。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは我慢することの快感を知った。"):format(name(_1))
					end,
				},
				stat_dexterity = {
					name = "器用",
					short_name = "器用",

					on_decrease = function(_1)
						return ("%sは不器用になった。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは器用になった。"):format(name(_1))
					end,
				},
				stat_perception = {
					name = "感覚",
					short_name = "感覚",

					on_decrease = function(_1)
						return ("%sは感覚のずれを感じた。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは世界をより身近に感じるようになった。"):format(name(_1))
					end,
				},
				stat_learning = {
					name = "習得",
					short_name = "習得",

					on_decrease = function(_1)
						return ("%sの学習意欲が低下した。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは急に色々なことを学びたくなった。"):format(name(_1))
					end,
				},
				stat_will = {
					name = "意思",
					short_name = "意思",

					on_decrease = function(_1)
						return ("%sは何でもすぐ諦める。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sの意思は固くなった。"):format(name(_1))
					end,
				},
				stat_magic = {
					name = "魔力",
					short_name = "魔力",

					on_decrease = function(_1)
						return ("%sは魔力の衰えを感じた。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは魔力の上昇を感じた。"):format(name(_1))
					end,
				},
				stat_charisma = {
					name = "魅力",
					short_name = "魅力",

					on_decrease = function(_1)
						return ("%sは急に人前に出るのが嫌になった。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは周囲の視線を心地よく感じる。"):format(name(_1))
					end,
				},
				stat_speed = {
					name = "速度",

					on_decrease = function(_1)
						return ("%sは遅くなった。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは周りの動きが遅く見えるようになった。"):format(name(_1))
					end,
				},
				stat_luck = {
					name = "運勢",

					on_decrease = function(_1)
						return ("%sは不幸になった。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは幸運になった。"):format(name(_1))
					end,
				},
				stat_life = {
					name = "生命力",

					on_decrease = function(_1)
						return ("%sは生命力の衰えを感じた。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sは生命力の上昇を感じた。"):format(name(_1))
					end,
				},
				stat_mana = {
					name = "マナ",

					on_decrease = function(_1)
						return ("%sはマナの衰えを感じた。"):format(name(_1))
					end,
					on_increase = function(_1)
						return ("%sはマナの向上を感じた。"):format(name(_1))
					end,
				},

				ActionAbsorbMagic = {
					description = "マナ回復",
					name = "魔力の吸収",
				},
				SpellAcidGround = {
					description = "酸の発生",
					name = "酸の海",
				},
				Alchemy = {
					description = "様々な材料を調合し、ポーションを作り出す",
					enchantment_description = "錬金の腕を上げる",
					name = "錬金術",
				},
				Anatomy = {
					description = "死体を残しやすくする",
					enchantment_description = "死体を残しやすくする",
					name = "解剖学",
				},
				Axe = {
					description = "斧を扱う技術",
					name = "斧",
				},
				Blunt = {
					description = "鈍器を扱う技術",
					name = "鈍器",
				},
				SpellBuffBoost = {
					name = "ブースト",
				},
				Bow = {
					description = "弓を扱う技術",
					name = "弓",
				},
				Carpentry = {
					description = "木を加工し、アイテムを作り出す",
					enchantment_description = "大工の腕を上げる",
					name = "大工",
				},
				Casting = {
					description = "魔法詠唱の成功率を上げる",
					name = "詠唱",
				},
				ActionChange = {
					description = "対象変容",
					name = "他者変容",
				},
				SpellChaosBall = {
					description = "混沌の球",
					name = "混沌の渦",
				},
				ActionChaosBreath = {
					description = "混沌のブレス",
					name = "混沌のブレス",
				},
				SpellChaosEye = {
					description = "混沌の矢",
					name = "混沌の瞳",
				},
				ActionCheer = {
					description = "視界内仲間強化",
					name = "鼓舞",
				},
				ActionColdBreath = {
					description = "冷気のブレス",
					name = "冷気のブレス",
				},
				SpellBuffContingency = {
					name = "契約",
				},
				ControlMagic = {
					description = "魔法による仲間のまきこみを軽減する",
					name = "魔力制御",
				},
				Cooking = {
					description = "料理の腕を上げる",
					enchantment_description = "料理の腕を上げる",
					name = "料理",
				},
				Crossbow = {
					description = "クロスボウを扱う技術",
					name = "クロスボウ",
				},
				SpellCrystalSpear = {
					description = "無属性の矢",
					name = "魔力の集積",
				},
				SpellCureOfEris = {
					description = "体力回復",
					name = "エリスの癒し",
				},
				SpellCureOfJure = {
					description = "体力回復",
					name = "ジュアの癒し",
				},
				ActionCurse = {
					description = "呪いをかける",
					name = "呪いの言葉",
				},
				SpellDarkEye = {
					description = "暗黒の矢",
					name = "暗黒の矢",
				},
				SpellDarknessBolt = {
					description = "暗黒のボルト",
					name = "暗黒の光線",
				},
				ActionDarknessBreath = {
					description = "暗黒のブレス",
					name = "暗黒のブレス",
				},
				SpellBuffDeathWord = {
					name = "死の宣告",
				},
				ActionDecapitation = {
					description = "対象即死",
					name = "首狩り",
				},
				Detection = {
					description = "隠された場所や罠を見つける",
					enchantment_description = "探知能力を強化する",
					name = "探知",
				},
				ActionDimensionalMove = {
					description = "近くへの瞬間移動",
					name = "空間歪曲",
				},
				DisarmTrap = {
					description = "複雑な罠の解体を可能にする",
					enchantment_description = "罠の解体を容易にする",
					name = "罠解体",
				},
				ActionDistantAttack4 = {
					description = "遠距離打撃",
					name = "遠距離打撃",
				},
				ActionDistantAttack7 = {
					description = "遠距離打撃",
					name = "遠距離打撃",
				},
				SpellBuffDivineWisdom = {
					name = "知者の加護",
				},
				SpellDominate = {
					description = "対象を支配する",
					name = "支配",
				},
				SpellDoorCreation = {
					description = "ドアの生成",
					name = "ドア生成",
				},
				ActionDrainBlood = {
					description = "体力吸収",
					name = "吸血の牙",
				},
				ActionDrawCharge = {
					description = "杖から魔力抽出",
					name = "魔力の抽出",
				},
				ActionDrawShadow = {
					description = "対象をテレポート",
					name = "異次元の手",
				},
				ActionDropMine = {
					description = "足元に地雷設置",
					name = "地雷投下",
				},
				DualWield = {
					description = "複数の武器を扱う技術",
					name = "二刀流",
				},
				SpellBuffElementScar = {
					name = "元素の傷跡",
				},
				SpellBuffElementalShield = {
					name = "元素保護",
				},
				ActionEtherGround = {
					description = "エーテルの発生",
					name = "エーテルの海",
				},
				Evasion = {
					description = "攻撃を回避する",
					name = "回避",
				},
				ActionEyeOfDimness = {
					description = "対象朦朧",
					name = "朦朧の眼差し",
				},
				ActionEyeOfEther = {
					description = "対象エーテル侵食",
					name = "エーテルの眼差し",
				},
				ActionEyeOfInsanity = {
					description = "対象狂気",
					name = "狂気の眼差し",
				},
				ActionEyeOfMana = {
					description = "マナダメージ",
					name = "マナの眼差し",
				},
				EyeOfMind = {
					description = "クリティカル率を高める",
					enchantment_description = "心眼の技術を上昇させる",
					name = "心眼",
				},
				ActionEyeOfMutation = {
					description = "対象変容",
					name = "変容の眼差し",
				},
				Faith = {
					description = "神との距離を近める",
					enchantment_description = "信仰を深める",
					name = "信仰",
				},
				ActionFillCharge = {
					description = "充填",
					name = "魔力の充填",
				},
				SpellFireBall = {
					description = "炎の球",
					name = "ファイアボール",
				},
				SpellFireBolt = {
					description = "火炎のボルト",
					name = "ファイアボルト",
				},
				ActionFireBreath = {
					description = "炎のブレス",
					name = "炎のブレス",
				},
				SpellFireWall = {
					description = "火柱の発生",
					name = "炎の壁",
				},
				Firearm = {
					description = "遠隔機装を扱う技術",
					name = "銃器",
				},
				Fishing = {
					description = "釣りを可能にする",
					enchantment_description = "釣りの腕を上げる",
					name = "釣り",
				},
				SpellFourDimensionalPocket = {
					description = "四次元のポケットを召喚",
					name = "四次元ポケット",
				},
				Gardening = {
					description = "植物を育て、採取する",
					enchantment_description = "栽培の腕を上げる",
					name = "栽培",
				},
				GeneEngineer = {
					description = "仲間合成の知識を高める",
					enchantment_description = "遺伝子学の知識を深める",
					name = "遺伝子学",
				},
				SpellGravity = {
					description = "重力の発生",
					name = "グラビティ",
				},
				GreaterEvasion = {
					description = "不正確な攻撃を確実に避ける",
					enchantment_description = "見切りの腕を上げる",
					name = "見切り",
				},
				ActionGrenade = {
					description = "轟音の球",
					name = "グレネード",
				},
				ActionHarvestMana = {
					description = "マナ回復",
					name = "マナ回復",
				},
				SpellHealCritical = {
					description = "体力回復",
					name = "致命傷治癒",
				},
				SpellHealLight = {
					description = "体力回復",
					name = "軽傷治癒",
				},
				Healing = {
					description = "怪我を自然に治癒する",
					enchantment_description = "体力回復を強化する",
					name = "治癒",
				},
				SpellHealingRain = {
					description = "体力回復の球",
					name = "治癒の雨",
				},
				SpellHealingTouch = {
					description = "体力回復",
					name = "癒しの手",
				},
				HeavyArmor = {
					description = "重い装備を扱う技術",
					enchantment_description = "重装備の技術を上昇させる",
					name = "重装備",
				},
				SpellBuffHero = {
					name = "英雄",
				},
				SpellHolyLight = {
					description = "1つの呪い(hex)除去",
					name = "清浄なる光",
				},
				SpellBuffHolyShield = {
					description = "防御力強化",
					name = "聖なる盾",
				},
				SpellBuffHolyVeil = {
					name = "ホーリーヴェイル",
				},
				SpellIceBall = {
					description = "氷の球",
					name = "アイスボール",
				},
				SpellIceBolt = {
					description = "氷のボルト",
					name = "アイスボルト",
				},
				SpellIdentify = {
					description = "アイテム鑑定",
					name = "鑑定",
				},
				SpellBuffIncognito = {
					name = "インコグニート",
				},
				ActionInsult = {
					description = "対象朦朧",
					name = "罵倒",
				},
				Investing = {
					description = "効果的に投資を行う",
					name = "投資",
				},
				Jeweler = {
					description = "宝石を加工し、アイテムを作り出す",
					enchantment_description = "宝石細工の腕を上げる",
					name = "宝石細工",
				},
				LightArmor = {
					description = "軽い装備を扱う技術",
					enchantment_description = "軽装備の技術を上昇させる",
					name = "軽装備",
				},
				SpellLightningBolt = {
					description = "雷のボルト",
					name = "ライトニングボルト",
				},
				ActionLightningBreath = {
					description = "電撃のブレス",
					name = "電撃のブレス",
				},
				Literacy = {
					description = "難解な本の解読を可能にする",
					enchantment_description = "本の理解を深める",
					name = "読書",
				},
				LockPicking = {
					description = "鍵を開ける",
					enchantment_description = "鍵開けの能力を強化する",
					name = "鍵開け",
				},
				LongSword = {
					description = "刃渡りの長い剣を扱う技術",
					name = "長剣",
				},
				SpellBuffLulwysTrick = {
					name = "ルルウィの憑依",
				},
				MagicCapacity = {
					description = "マナの反動から身を守る",
					enchantment_description = "マナの限界を上昇させる",
					name = "魔力の限界",
				},
				SpellMagicDart = {
					description = "無属性の矢",
					name = "魔法の矢",
				},
				MagicDevice = {
					description = "道具から魔力を効果的に引き出す",
					enchantment_description = "魔道具の効果を上げる",
					name = "魔道具",
				},
				SpellMagicMap = {
					description = "周囲の地形感知",
					name = "魔法の地図",
				},
				SpellMagicStorm = {
					description = "魔法の球",
					name = "魔力の嵐",
				},
				ActionManisDisassembly = {
					description = "敵瀕死",
					name = "マニの分解術",
				},
				Marksman = {
					description = "射撃の威力を上げる",
					enchantment_description = "射撃の理解を深める",
					name = "射撃",
				},
				MartialArts = {
					description = "格闘の技術",
					name = "格闘",
				},
				Meditation = {
					description = "消耗したマナを回復させる",
					enchantment_description = "マナ回復を強化する",
					name = "瞑想",
				},
				MediumArmor = {
					description = "普通の装備を扱う技術",
					enchantment_description = "中装備の技術を上昇させる",
					name = "中装備",
				},
				Memorization = {
					description = "書物から得た知識を記憶する",
					enchantment_description = "魔法の知識の忘却を防ぐ",
					name = "暗記",
				},
				SpellMeteor = {
					description = "全域攻撃",
					name = "メテオ",
				},
				ActionMewmewmew = {
					description = "？",
					name = "うみみゃぁ！",
				},
				SpellMindBolt = {
					description = "幻惑のボルト",
					name = "幻影の光線",
				},
				ActionMindBreath = {
					description = "幻惑のブレス",
					name = "幻惑のブレス",
				},
				Mining = {
					description = "壁を掘る効率を上げる",
					enchantment_description = "採掘能力を強化する",
					name = "採掘",
				},
				ActionMirror = {
					description = "自分の状態の感知",
					name = "自己認識",
				},
				SpellMistOfDarkness = {
					description = "霧の発生",
					name = "闇の霧",
				},
				SpellBuffMistOfFrailness = {
					name = "脆弱の霧",
				},
				SpellBuffMistOfSilence = {
					description = "魔法使用不可",
					name = "沈黙の霧",
				},
				SpellMutation = {
					description = "突然変異",
					name = "自己の変容",
				},
				Negotiation = {
					description = "交渉や商談を有利に進める",
					enchantment_description = "交渉を有利に進めさせる",
					name = "交渉",
				},
				SpellNerveArrow = {
					description = "神経の矢",
					name = "麻痺の矢",
				},
				ActionNerveBreath = {
					description = "神経のブレス",
					name = "神経のブレス",
				},
				SpellNetherArrow = {
					description = "地獄の矢",
					name = "地獄の吐息",
				},
				ActionNetherBreath = {
					description = "地獄のブレス",
					name = "地獄のブレス",
				},
				SpellBuffNightmare = {
					name = "ナイトメア",
				},
				SpellOracle = {
					description = "アーティファクト感知",
					name = "神託",
				},
				Performer = {
					description = "質の高い演奏を可能にする",
					enchantment_description = "演奏の質を上げる",
					name = "演奏",
				},
				Pickpocket = {
					description = "貴重な物品を盗む",
					enchantment_description = "窃盗の腕を上げる",
					name = "窃盗",
				},
				ActionPoisonBreath = {
					description = "毒のブレス",
					name = "毒のブレス",
				},
				Polearm = {
					description = "槍を扱う技術",
					name = "槍",
				},
				ActionPowerBreath = {
					description = "ブレス",
					name = "強力なブレス",
				},
				ActionPrayerOfJure = {
					description = "体力回復",
					name = "ジュアの祈り",
				},
				ActionPregnant = {
					description = "対象妊娠",
					name = "妊娠",
				},
				SpellBuffPunishment = {
					name = "神罰",
				},
				SpellRagingRoar = {
					description = "轟音の球",
					name = "轟音の波動",
				},
				ActionRainOfSanity = {
					description = "狂気回復の球",
					name = "狂気治癒の雨",
				},
				SpellBuffRegeneration = {
					name = "リジェネレーション",
				},
				SpellRestoreBody = {
					description = "肉体の弱体化の治療",
					name = "肉体復活",
				},
				SpellRestoreSpirit = {
					description = "精神の弱体化の治療",
					name = "精神復活",
				},
				SpellResurrection = {
					description = "死者の蘇生",
					name = "復活",
				},
				SpellReturn = {
					description = "特定の場所への帰還",
					name = "帰還",
				},
				Riding = {
					description = "上手に乗りこなす",
					enchantment_description = "乗馬の腕を上げる",
					name = "乗馬",
				},
				ActionScavenge = {
					description = "盗んで食べる",
					name = "食い漁り",
				},
				Scythe = {
					description = "鎌を扱う技術",
					name = "鎌",
				},
				SpellSenseObject = {
					description = "周囲の物質感知",
					name = "物質感知",
				},
				SenseQuality = {
					description = "アイテムの質や種類を感じ取る",
					name = "自然鑑定",
				},
				ActionShadowStep = {
					description = "対象へのテレポート",
					name = "接近",
				},
				Shield = {
					description = "盾を扱う技術",
					name = "盾",
				},
				ShortSword = {
					description = "刃渡りの短い剣を扱う技術",
					name = "短剣",
				},
				SpellShortTeleport = {
					description = "近くへの瞬間移動",
					name = "ショートテレポート",
				},
				SpellBuffSlow = {
					name = "鈍足",
				},
				ActionSoundBreath = {
					description = "轟音のブレス",
					name = "轟音のブレス",
				},
				SpellBuffSpeed = {
					name = "加速",
				},
				Stave = {
					description = "杖を扱う技術",
					name = "杖",
				},
				Stealth = {
					description = "周囲に気づかれず行動する",
					enchantment_description = "隠密能力を強化する",
					name = "隠密",
				},
				ActionSuicideAttack = {
					description = "自爆の球",
					name = "自爆",
				},
				ActionSummonCats = {
					description = "猫を召喚する",
					name = "猫召喚",
				},
				ActionSummonFire = {
					description = "炎の生き物を召喚する",
					name = "炎召喚",
				},
				SpellSummonMonsters = {
					description = "モンスターを召喚する",
					name = "モンスター召喚",
				},
				ActionSummonPawn = {
					description = "駒を召喚する",
					name = "駒召喚",
				},
				ActionSummonSister = {
					description = "妹を召喚する",
					name = "妹召喚",
				},
				SpellSummonWild = {
					description = "野生の生き物を召喚する",
					name = "野生召喚",
				},
				ActionSummonYeek = {
					description = "イークを召喚する",
					name = "イーク召喚",
				},
				ActionSuspiciousHand = {
					description = "盗み",
					name = "スリの指",
				},
				ActionSwarm = {
					description = "隣接対象攻撃",
					name = "スウォーム",
				},
				Tactics = {
					description = "近接攻撃の威力を上げる",
					enchantment_description = "戦術の理解を深める",
					name = "戦術",
				},
				Tailoring = {
					description = "革や蔓を用い、アイテムを作り出す",
					enchantment_description = "裁縫の腕を上げる",
					name = "裁縫",
				},
				SpellTeleport = {
					description = "瞬間移動",
					name = "テレポート",
				},
				SpellTeleportOther = {
					description = "対象を瞬間移動させる",
					name = "テレポートアザー",
				},
				Throwing = {
					description = "投擲道具を扱う技術",
					name = "投擲",
				},
				ActionTouchOfFear = {
					description = "無属性攻撃",
					name = "恐怖の手",
				},
				ActionTouchOfHunger = {
					description = "飢餓攻撃",
					name = "飢餓の手",
				},
				ActionTouchOfNerve = {
					description = "神経攻撃",
					name = "麻痺の手",
				},
				ActionTouchOfPoison = {
					description = "毒攻撃",
					name = "毒の手",
				},
				ActionTouchOfSleep = {
					description = "精神攻撃",
					name = "眠りの手",
				},
				ActionTouchOfWeakness = {
					description = "弱体化",
					name = "弱体化の手",
				},
				Traveling = {
					description = "旅の進行を早め経験を深める",
					enchantment_description = "旅の熟練を上げる",
					name = "旅歩き",
				},
				TwoHand = {
					description = "両手で武器を扱う技術",
					name = "両手持ち",
				},
				SpellUncurse = {
					description = "アイテム解呪",
					name = "解呪",
				},
				ActionVanish = {
					description = "退却する",
					name = "退却",
				},
				SpellVanquishHex = {
					description = "全ての呪い(hex)除去",
					name = "全浄化",
				},
				SpellWallCreation = {
					description = "壁の生成",
					name = "壁生成",
				},
				SpellWeb = {
					description = "蜘蛛の巣発生",
					name = "蜘蛛の巣",
				},
				WeightLifting = {
					description = "重い荷物を持ち運ぶことを可能にする",
					name = "重量挙げ",
				},
				SpellWish = {
					description = "願いの効果",
					name = "願い",
				},
				SpellWizardsHarvest = {
					description = "ランダムな収穫",
					name = "魔術師の収穫",
				},
			},
		},
	},
}
