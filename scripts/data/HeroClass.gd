class_name HeroClass
extends Resource

enum Type {
	WARRIOR, ARCHER, MAGE, HEALER, ROGUE, PALADIN, BERSERKER, SUMMONER,
	ENGINEER, DRUID, MONK, BARD, NECROMANCER, KNIGHT, ALCHEMIST, BEASTMASTER,
	PRIEST, ILLUSIONIST, SAMURAI, GUNSLINGER, ELEMENTALIST, TEMPLAR, WITCH,
	ASSASSIN, SHAMAN, VAMPIRE, WARDEN, ORACLE, SAGE, REAPER, CORSAIR,
	GEOMANCER, SWORDSMAN, ENCHANTER, HUNTER, GLADIATOR, MYSTIC, SENTINEL,
	WARLORD, SCRIBE, HERALD, FENCER, JUGGERNAUT, WITCH_DOCTOR, DUELIST,
	PYROMANCER, CRYOMANCER, STORMCALLER, PLAGUE_DOCTOR, RUNEKEEPER, HARBINGER,
	ARTIFICER, SHADOWBLADE, SELLSWORD, BEASTKIN, CHRONOMANCER, INVOKER,
	WITCH_HUNTER, DRAGON_KNIGHT, SPELLBLADE, WOLFRIDER, SUN_PRIEST, MOON_DANCER,
	BLOOD_MAGE, SPIRIT_WALKER, BLADE_DANCER, FROST_KNIGHT, THUNDERLORD,
	SANDSHAPER, WINDRUNNER, STARCALLER, DEMON_HUNTER, RUNESMITH, WITCHFIRE,
	BONE_KNIGHT, MISTWALKER, LANCER, SPELL_THIEF, WILDSHAPER, STORMSINGER,
	HEXBLADE, FEY_KNIGHT, IRONCLAD, PYROCLAST, VENOMANCER, ASTRAL_MAGE,
	DERVISH, WYRMCALLER, GOLEMANCER, FROST_ARCHER, SUNBLADE, NIGHTBLADE,
	STORM_ARCHER, SPIRIT_MAGE, CHRONOKNIGHT
}

static func get_class_name(type: Type) -> String:
	match type:
		Type.WARRIOR: return "Warrior"
		Type.ARCHER: return "Archer"
		Type.MAGE: return "Mage"
		Type.HEALER: return "Healer"
		Type.ROGUE: return "Rogue"
		Type.PALADIN: return "Paladin"
		Type.BERSERKER: return "Berserker"
		Type.SUMMONER: return "Summoner"
		Type.ENGINEER: return "Engineer"
		Type.DRUID: return "Druid"
		Type.MONK: return "Monk"
		Type.BARD: return "Bard"
		Type.NECROMANCER: return "Necromancer"
		Type.KNIGHT: return "Knight"
		Type.ALCHEMIST: return "Alchemist"
		Type.BEASTMASTER: return "Beastmaster"
		Type.PRIEST: return "Priest"
		Type.ILLUSIONIST: return "Illusionist"
		Type.SAMURAI: return "Samurai"
		Type.GUNSLINGER: return "Gunslinger"
		# ... (continue for all 100 classes)
		_: return "Unknown"

static func get_class_description(type: Type) -> String:
	match type:
		Type.WARRIOR: return "Durable melee fighter with defensive abilities"
		Type.ARCHER: return "Ranged physical damage dealer with precision"
		Type.MAGE: return "Magical damage dealer with area effects"
		Type.HEALER: return "Support class focused on healing and buffs"
		Type.ROGUE: return "Stealthy damage dealer with critical strikes"
		# ... (continue for all classes)
		_: return "No description available"

static func get_base_stats(type: Type) -> Stats:
	var stats = Stats.new()
	match type:
		Type.WARRIOR:
			stats.health = 25
			stats.mana = 5
			stats.attack = 6
			stats.defense = 8
			stats.speed = 3
			stats.accuracy = 80
		Type.ARCHER:
			stats.health = 18
			stats.mana = 8
			stats.attack = 7
			stats.defense = 4
			stats.speed = 6
			stats.accuracy = 90
		Type.MAGE:
			stats.health = 15
			stats.mana = 20
			stats.attack = 3
			stats.defense = 2
			stats.speed = 4
			stats.accuracy = 85
		Type.HEALER:
			stats.health = 20
			stats.mana = 18
			stats.attack = 2
			stats.defense = 5
			stats.speed = 4
			stats.accuracy = 75
		# ... (continue for all classes with balanced low stats)
		_:
			stats.health = 20
			stats.mana = 10
			stats.attack = 5
			stats.defense = 3
			stats.speed = 4
			stats.accuracy = 75
	
	return stats
