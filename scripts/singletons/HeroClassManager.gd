extends Node

# Static helper functions for hero class management

static func get_synergy_bonus(class1: HeroClass.Type, class2: HeroClass.Type) -> Dictionary:
	# Returns stat bonuses when these classes are near each other
	var synergy_map = {
		# Warrior + Healer combo
		[HeroClass.Type.WARRIOR, HeroClass.Type.HEALER]: {"defense": 2, "health": 5},
		[HeroClass.Type.HEALER, HeroClass.Type.WARRIOR]: {"defense": 2, "health": 5},
		
		# Mage + Archer combo
		[HeroClass.Type.MAGE, HeroClass.Type.ARCHER]: {"attack": 3, "accuracy": 10},
		[HeroClass.Type.ARCHER, HeroClass.Type.MAGE]: {"attack": 3, "accuracy": 10},
		
		# Rogue + Warrior combo
		[HeroClass.Type.ROGUE, HeroClass.Type.WARRIOR]: {"attack": 2, "critical_chance": 5},
		[HeroClass.Type.WARRIOR, HeroClass.Type.ROGUE]: {"attack": 2, "critical_chance": 5},
		
		# Paladin + anyone (support)
		[HeroClass.Type.PALADIN, HeroClass.Type.WARRIOR]: {"defense": 3},
		[HeroClass.Type.PALADIN, HeroClass.Type.ARCHER]: {"defense": 3},
		[HeroClass.Type.PALADIN, HeroClass.Type.MAGE]: {"defense": 3},
		[HeroClass.Type.PALADIN, HeroClass.Type.ROGUE]: {"defense": 3},
	}
	
	var key = [class1, class2]
	return synergy_map.get(key, {})

static func get_abilities_for_class(hero_class: HeroClass.Type) -> Array[Ability]:
	# Returns available abilities for a class
	var abilities: Array[Ability] = []
	
	match hero_class:
		HeroClass.Type.WARRIOR:
			abilities = create_warrior_abilities()
		HeroClass.Type.ARCHER:
			abilities = create_archer_abilities()
		HeroClass.Type.MAGE:
			abilities = create_mage_abilities()
		HeroClass.Type.HEALER:
			abilities = create_healer_abilities()
		HeroClass.Type.ROGUE:
			abilities = create_rogue_abilities()
		HeroClass.Type.PALADIN:
			abilities = create_paladin_abilities()
		_:
			# Default basic attack
			abilities = create_basic_abilities()
	
	return abilities

static func get_synergy_classes(hero_class: HeroClass.Type) -> Array[HeroClass.Type]:
	# Returns classes that synergize well with this class
	var synergy_map = {
		HeroClass.Type.WARRIOR: [HeroClass.Type.HEALER, HeroClass.Type.ROGUE, HeroClass.Type.PALADIN],
		HeroClass.Type.ARCHER: [HeroClass.Type.MAGE, HeroClass.Type.ROGUE],
		HeroClass.Type.MAGE: [HeroClass.Type.ARCHER, HeroClass.Type.HEALER],
		HeroClass.Type.HEALER: [HeroClass.Type.WARRIOR, HeroClass.Type.MAGE, HeroClass.Type.PALADIN],
		HeroClass.Type.ROGUE: [HeroClass.Type.WARRIOR, HeroClass.Type.ARCHER],
		HeroClass.Type.PALADIN: [HeroClass.Type.WARRIOR, HeroClass.Type.HEALER],
	}
	
	return synergy_map.get(hero_class, [])

# Helper functions to create abilities for each class
static func create_warrior_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Shield Bash
	var shield_bash = Ability.new()
	shield_bash.ability_name = "Shield Bash"
	shield_bash.description = "Stun an enemy briefly"
	shield_bash.ability_type = Ability.Type.ATTACK
	shield_bash.target_type = Ability.TargetType.ENEMY
	shield_bash.damage = 8
	shield_bash.mana_cost = 3
	shield_bash.range = 1.5
	shield_bash.required_level = 1
	abilities.append(shield_bash)
	
	# Taunt
	var taunt = Ability.new()
	taunt.ability_name = "Taunt"
	taunt.description = "Draw enemy attacks to self"
	taunt.ability_type = Ability.Type.BUFF
	taunt.target_type = Ability.TargetType.SELF
	taunt.mana_cost = 2
	taunt.required_level = 2
	abilities.append(taunt)
	
	return abilities

static func create_archer_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Power Shot
	var power_shot = Ability.new()
	power_shot.ability_name = "Power Shot"
	power_shot.description = "Deal extra damage to a single target"
	power_shot.ability_type = Ability.Type.ATTACK
	power_shot.target_type = Ability.TargetType.ENEMY
	power_shot.damage = 12
	power_shot.mana_cost = 4
	power_shot.range = 6.0
	power_shot.required_level = 1
	abilities.append(power_shot)
	
	# Volley
	var volley = Ability.new()
	volley.ability_name = "Volley"
	volley.description = "Attack multiple enemies in a line"
	volley.ability_type = Ability.Type.AREA_ATTACK
	volley.target_type = Ability.TargetType.ENEMY
	volley.damage = 6
	volley.mana_cost = 5
	volley.range = 5.0
	volley.area_of_effect = 2.0
	volley.required_level = 3
	abilities.append(volley)
	
	return abilities

static func create_mage_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Fireball
	var fireball = Ability.new()
	fireball.ability_name = "Fireball"
	fireball.description = "Area-of-effect fire damage"
	fireball.ability_type = Ability.Type.AREA_ATTACK
	fireball.target_type = Ability.TargetType.GROUND
	fireball.damage = 10
	fireball.mana_cost = 6
	fireball.range = 4.0
	fireball.area_of_effect = 2.0
	fireball.required_level = 1
	abilities.append(fireball)
	
	# Frost Nova
	var frost_nova = Ability.new()
	frost_nova.ability_name = "Frost Nova"
	frost_nova.description = "Slow or freeze nearby enemies"
	frost_nova.ability_type = Ability.Type.DEBUFF
	frost_nova.target_type = Ability.TargetType.ALL_ENEMIES
	frost_nova.damage = 4
	frost_nova.mana_cost = 5
	frost_nova.range = 3.0
	frost_nova.area_of_effect = 3.0
	frost_nova.required_level = 2
	abilities.append(frost_nova)
	
	return abilities

static func create_healer_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Heal
	var heal = Ability.new()
	heal.ability_name = "Heal"
	heal.description = "Restore health to an ally"
	heal.ability_type = Ability.Type.HEAL
	heal.target_type = Ability.TargetType.ALLY
	heal.healing = 15
	heal.mana_cost = 4
	heal.range = 3.0
	heal.required_level = 1
	abilities.append(heal)
	
	# Protective Aura
	var aura = Ability.new()
	aura.ability_name = "Protective Aura"
	aura.description = "Boost defense of nearby allies"
	aura.ability_type = Ability.Type.BUFF
	aura.target_type = Ability.TargetType.ALL_ALLIES
	aura.mana_cost = 6
	aura.range = 4.0
	aura.area_of_effect = 4.0
	aura.required_level = 2
	abilities.append(aura)
	
	return abilities

static func create_rogue_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Backstab
	var backstab = Ability.new()
	backstab.ability_name = "Backstab"
	backstab.description = "High damage from behind"
	backstab.ability_type = Ability.Type.ATTACK
	backstab.target_type = Ability.TargetType.ENEMY
	backstab.damage = 15
	backstab.mana_cost = 3
	backstab.range = 1.0
	backstab.required_level = 1
	abilities.append(backstab)
	
	# Smoke Bomb
	var smoke_bomb = Ability.new()
	smoke_bomb.ability_name = "Smoke Bomb"
	smoke_bomb.description = "Create an area where enemies lose sight"
	smoke_bomb.ability_type = Ability.Type.DEBUFF
	smoke_bomb.target_type = Ability.TargetType.GROUND
	smoke_bomb.mana_cost = 4
	smoke_bomb.range = 2.0
	smoke_bomb.area_of_effect = 3.0
	smoke_bomb.required_level = 2
	abilities.append(smoke_bomb)
	
	return abilities

static func create_paladin_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Holy Strike
	var holy_strike = Ability.new()
	holy_strike.ability_name = "Holy Strike"
	holy_strike.description = "Deal damage and heal self"
	holy_strike.ability_type = Ability.Type.ATTACK
	holy_strike.target_type = Ability.TargetType.ENEMY
	holy_strike.damage = 10
	holy_strike.healing = 5  # Self-heal
	holy_strike.mana_cost = 5
	holy_strike.range = 1.5
	holy_strike.required_level = 1
	abilities.append(holy_strike)
	
	# Sanctuary
	var sanctuary = Ability.new()
	sanctuary.ability_name = "Sanctuary"
	sanctuary.description = "Reduce damage for all nearby allies"
	sanctuary.ability_type = Ability.Type.BUFF
	sanctuary.target_type = Ability.TargetType.ALL_ALLIES
	sanctuary.mana_cost = 7
	sanctuary.range = 4.0
	sanctuary.area_of_effect = 4.0
	sanctuary.required_level = 3
	abilities.append(sanctuary)
	
	return abilities

static func create_basic_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	
	# Basic Attack
	var basic_attack = Ability.new()
	basic_attack.ability_name = "Attack"
	basic_attack.description = "Basic melee attack"
	basic_attack.ability_type = Ability.Type.ATTACK
	basic_attack.target_type = Ability.TargetType.ENEMY
	basic_attack.damage = 5
	basic_attack.mana_cost = 0
	basic_attack.range = 1.0
	basic_attack.required_level = 1
	abilities.append(basic_attack)
	
	return abilities
